#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

default_tz <- "Asia/Shanghai"

parse_cli_args <- function(args) {
  out <- list(
    site = NULL,
    input = NULL,
    output_dir = NULL,
    year = 2025L,
    tz = default_tz,
    ustar_threshold = 0.15,
    day_start_hour = 6,
    day_end_hour = 18
  )

  i <- 1L
  while (i <= length(args)) {
    arg <- args[[i]]
    if (startsWith(arg, "--") && grepl("=", arg, fixed = TRUE)) {
      key <- sub("^--", "", sub("=.*$", "", arg))
      value <- sub("^[^=]+=", "", arg)
    } else if (startsWith(arg, "--")) {
      key <- sub("^--", "", arg)
      i <- i + 1L
      if (i > length(args)) stop("Missing value for --", key, call. = FALSE)
      value <- args[[i]]
    } else {
      stop("Unrecognized argument: ", arg, call. = FALSE)
    }

    if (!key %in% names(out)) stop("Unsupported argument --", key, call. = FALSE)
    out[[key]] <- value
    i <- i + 1L
  }

  required <- c("site", "input", "output_dir")
  missing_required <- required[vapply(required, function(x) is.null(out[[x]]) || identical(out[[x]], ""), logical(1))]
  if (length(missing_required) > 0L) {
    stop("Missing required arguments: ", paste0("--", missing_required, collapse = ", "), call. = FALSE)
  }

  out$year <- as.integer(out$year)
  if (!is.finite(out$year)) stop("Invalid --year value.", call. = FALSE)
  out$ustar_threshold <- as.numeric(out$ustar_threshold)
  out$day_start_hour <- as.numeric(out$day_start_hour)
  out$day_end_hour <- as.numeric(out$day_end_hour)
  out
}

parse_timestamp_local <- function(timestamp_chr, date_chr = NULL, time_chr = NULL, tz_local = default_tz) {
  timestamp_chr <- trimws(as.character(timestamp_chr))
  timestamp_chr[timestamp_chr == ""] <- NA_character_

  parsed <- as.POSIXct(timestamp_chr, format = "%Y-%m-%d %H:%M:%OS", tz = tz_local)

  if (!is.null(date_chr) && !is.null(time_chr)) {
    fallback_chr <- ifelse(
      is.na(date_chr) | is.na(time_chr),
      NA_character_,
      paste(trimws(as.character(date_chr)), trimws(as.character(time_chr)))
    )
    bad <- is.na(parsed) & !is.na(fallback_chr)
    if (any(bad)) {
      parsed[bad] <- as.POSIXct(fallback_chr[bad], format = "%Y-%m-%d %H:%M", tz = tz_local)
    }
  }

  parsed
}

is_exact_halfhour <- function(x, tz_local = default_tz) {
  lt <- as.POSIXlt(x, tz = tz_local)
  !is.na(x) &
    lt$min %in% c(0L, 30L) &
    floor(lt$sec) == 0L &
    abs(lt$sec) < 1e-9
}

timestamp_key <- function(x, tz_local = default_tz) {
  format(x, "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

first_or_na <- function(x) {
  if (length(x) == 0L) return(NA)
  x[[1L]]
}

build_gap_blocks <- function(audit) {
  gap_idx <- which(audit$fill_needed_ustar)
  if (length(gap_idx) == 0L) {
    return(data.table(
      site = character(),
      gap_block_id = integer(),
      start_timestamp = character(),
      end_timestamp = character(),
      n_halfhours = integer(),
      gap_hours = numeric(),
      reasons = character(),
      first_reason = character(),
      has_any_record = logical(),
      all_missing_no_record = logical()
    ))
  }

  gap_block_id <- cumsum(c(TRUE, diff(gap_idx) != 1L))
  x <- copy(audit[gap_idx])
  x[, gap_block_id := gap_block_id]

  x[, .(
    site = first_or_na(site),
    start_timestamp = timestamp_key(first_or_na(timestamp_local)),
    end_timestamp = timestamp_key(timestamp_local[.N]),
    n_halfhours = .N,
    gap_hours = .N * 0.5,
    reasons = paste(unique(gap_reason_ustar), collapse = ","),
    first_reason = first_or_na(gap_reason_ustar),
    has_any_record = any(has_record),
    all_missing_no_record = all(gap_reason_ustar == "missing_no_record")
  ), by = gap_block_id]
}

run_fixed_tower_ec_year_audit <- function(site,
                                          input_file,
                                          output_dir,
                                          year = 2025L,
                                          tz_local = default_tz,
                                          ustar_threshold = 0.15,
                                          day_start_hour = 6,
                                          day_end_hour = 18) {
  if (!file.exists(input_file)) stop("Missing input file: ", input_file, call. = FALSE)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  dt <- fread(
    input_file,
    encoding = "UTF-8",
    colClasses = list(character = c("timestamp", "date", "time"))
  )

  if (!"timestamp" %in% names(dt) && all(c("date", "time") %in% names(dt))) {
    dt[, timestamp := paste(date, time)]
  }
  if (!"timestamp" %in% names(dt)) stop("Input is missing timestamp columns.", call. = FALSE)

  dt[, row_id := .I]
  dt[, timestamp_local := parse_timestamp_local(timestamp, date, time, tz_local = tz_local)]
  dt <- dt[!is.na(timestamp_local)]
  dt[, year_local := as.integer(format(timestamp_local, "%Y", tz = tz_local))]
  dt_year <- dt[year_local == year]

  grid_start <- as.POSIXct(sprintf("%04d-01-01 00:00:00", year), tz = tz_local)
  grid_end <- as.POSIXct(sprintf("%04d-12-31 23:30:00", year), tz = tz_local)
  grid <- data.table(timestamp_local = seq(from = grid_start, to = grid_end, by = "30 min"))
  grid[, `:=`(
    site = site,
    timestamp_key = timestamp_key(timestamp_local, tz_local = tz_local),
    date = as.IDate(format(timestamp_local, "%Y-%m-%d", tz = tz_local)),
    hour = as.integer(format(timestamp_local, "%H", tz = tz_local)),
    minute = as.integer(format(timestamp_local, "%M", tz = tz_local))
  )]
  grid[, hour_decimal := hour + minute / 60]
  grid[, day_night := fifelse(hour_decimal >= day_start_hour & hour_decimal < day_end_hour, "day", "night")]

  if (nrow(dt_year) == 0L) {
    stop("No rows found for year ", year, " in: ", input_file, call. = FALSE)
  }

  dt_year[, `:=`(
    exact_halfhour = is_exact_halfhour(timestamp_local, tz_local = tz_local),
    parsed_timestamp = timestamp_key(timestamp_local, tz_local = tz_local)
  )]

  offgrid <- dt_year[exact_halfhour == FALSE, .(
    site = site,
    row_id,
    timestamp_raw = timestamp,
    parsed_timestamp,
    co2_flux = suppressWarnings(as.numeric(co2_flux)),
    qc_co2 = suppressWarnings(as.numeric(qc_co2)),
    flag9_co2 = suppressWarnings(as.numeric(flag9_co2)),
    u_star = suppressWarnings(as.numeric(u_star)),
    reason = "not_exact_halfhour"
  )]

  exact <- dt_year[exact_halfhour == TRUE]
  numeric_cols <- intersect(c("co2_flux", "qc_co2", "flag9_co2", "u_star", "H", "LE"), names(exact))
  if (length(numeric_cols) > 0L) {
    exact[, (numeric_cols) := lapply(.SD, as.numeric), .SDcols = numeric_cols]
  }

  duplicate_keys <- exact[, .N, by = parsed_timestamp][N > 1L, parsed_timestamp]
  duplicate_details <- exact[parsed_timestamp %in% duplicate_keys, .(
    site = site,
    parsed_timestamp,
    row_id,
    timestamp_raw = timestamp,
    co2_flux,
    qc_co2,
    flag9_co2,
    u_star
  )]

  exact_agg <- exact[, .(
    n_records = .N,
    co2_flux = first_or_na(co2_flux),
    qc_co2 = first_or_na(qc_co2),
    flag9_co2 = first_or_na(flag9_co2),
    u_star = first_or_na(u_star),
    H = first_or_na(H),
    LE = first_or_na(LE)
  ), by = parsed_timestamp]
  setnames(exact_agg, "parsed_timestamp", "timestamp_key")

  audit <- merge(grid, exact_agg, by = "timestamp_key", all.x = TRUE, sort = FALSE)
  audit[, `:=`(
    has_record = !is.na(n_records),
    duplicate_exact_record = !is.na(n_records) & n_records > 1L,
    has_flux = is.finite(co2_flux),
    has_qc_co2 = is.finite(qc_co2),
    qc_co2_pass = is.finite(qc_co2) & qc_co2 <= 1,
    has_flag9_co2 = is.finite(flag9_co2),
    flag9_co2_pass = is.finite(flag9_co2) & flag9_co2 <= 3,
    u_star_available = is.finite(u_star)
  )]

  audit[, valid_ec_base := has_record &
    !duplicate_exact_record &
    has_flux &
    qc_co2_pass &
    flag9_co2_pass]
  audit[, ustar_threshold := as.numeric(ustar_threshold)]
  audit[, ustar_threshold_available := is.finite(ustar_threshold)]
  audit[, ustar_threshold_pass := day_night == "day" | (u_star_available & is.finite(ustar_threshold) & u_star >= ustar_threshold)]
  audit[, valid_ec_ustar := valid_ec_base & ustar_threshold_pass]

  audit[, gap_reason := fifelse(
    !has_record, "missing_no_record",
    fifelse(
      duplicate_exact_record, "duplicate_exact_record",
      fifelse(
        !has_flux, "present_no_flux",
        fifelse(
          !has_qc_co2, "present_no_qc_co2",
          fifelse(
            !qc_co2_pass, "qc_co2_fail",
            fifelse(
              !has_flag9_co2, "present_no_flag9_co2",
              fifelse(!flag9_co2_pass, "flag9_co2_fail", "observed_valid")
            )
          )
        )
      )
    )
  )]
  audit[, gap_reason_ustar := fifelse(
    gap_reason != "observed_valid", gap_reason,
    fifelse(
      day_night == "day", "observed_valid",
      fifelse(
        !u_star_available, "present_no_u_star",
        fifelse(!ustar_threshold_pass, "u_star_below_threshold", "observed_valid")
      )
    )
  )]
  audit[, fill_needed_base := !valid_ec_base]
  audit[, fill_needed_ustar := !valid_ec_ustar]
  audit[, fill_scope_note := fifelse(
    fill_needed_ustar,
    "needs_gapfill_after_provisional_u_star_before_storage",
    "observed_valid_after_provisional_u_star_before_storage"
  )]

  gap_blocks <- build_gap_blocks(audit)

  daily <- audit[, .(
    windows_total = .N,
    windows_has_record = sum(has_record),
    windows_valid_ec_base = sum(valid_ec_base),
    windows_valid_ec_ustar = sum(valid_ec_ustar),
    windows_fill_needed_base = sum(fill_needed_base),
    windows_fill_needed_ustar = sum(fill_needed_ustar),
    windows_missing_no_record = sum(gap_reason == "missing_no_record"),
    windows_duplicate_exact = sum(gap_reason == "duplicate_exact_record"),
    windows_present_no_flux = sum(gap_reason == "present_no_flux"),
    windows_qc_fail = sum(gap_reason == "qc_co2_fail" | gap_reason == "flag9_co2_fail"),
    windows_present_no_u_star = sum(gap_reason_ustar == "present_no_u_star"),
    windows_u_star_below_threshold = sum(gap_reason_ustar == "u_star_below_threshold")
  ), by = .(site, date)]
  daily[, coverage_status_base := fifelse(
    windows_valid_ec_base == 0L, "no_valid_ec",
    fifelse(windows_valid_ec_base == windows_total, "full_day_valid", "partial_day_valid")
  )]
  daily[, coverage_status_ustar := fifelse(
    windows_valid_ec_ustar == 0L, "no_valid_ec_after_ustar",
    fifelse(windows_valid_ec_ustar == windows_total, "full_day_valid_after_ustar", "partial_day_valid_after_ustar")
  )]

  summary_tbl <- data.table(
    site = site,
    year = year,
    ustar_threshold = ustar_threshold,
    expected_halfhours = nrow(grid),
    raw_rows_in_year = nrow(dt_year),
    exact_halfhour_rows = nrow(exact),
    offgrid_rows = nrow(offgrid),
    duplicate_exact_rows = nrow(duplicate_details),
    duplicate_exact_timestamps = uniqueN(duplicate_details$parsed_timestamp),
    windows_has_record = sum(audit$has_record),
    windows_valid_ec_base = sum(audit$valid_ec_base),
    windows_valid_ec_ustar = sum(audit$valid_ec_ustar),
    windows_fill_needed_base = sum(audit$fill_needed_base),
    windows_fill_needed_ustar = sum(audit$fill_needed_ustar),
    fill_fraction_base = round(mean(audit$fill_needed_base), 6),
    fill_fraction_ustar = round(mean(audit$fill_needed_ustar), 6),
    days_full_valid = sum(daily$coverage_status_base == "full_day_valid"),
    days_partial_valid = sum(daily$coverage_status_base == "partial_day_valid"),
    days_no_valid = sum(daily$coverage_status_base == "no_valid_ec"),
    days_full_valid_ustar = sum(daily$coverage_status_ustar == "full_day_valid_after_ustar"),
    days_partial_valid_ustar = sum(daily$coverage_status_ustar == "partial_day_valid_after_ustar"),
    days_no_valid_ustar = sum(daily$coverage_status_ustar == "no_valid_ec_after_ustar")
  )

  audit_out <- copy(audit)
  audit_out[, timestamp_local := timestamp_key(timestamp_local, tz_local = tz_local)]
  daily_out <- copy(daily)

  prefix <- sprintf("%s_ec_%d_year_audit", site, year)
  fwrite(audit_out, file.path(output_dir, sprintf("%s_30min.csv", prefix)))
  fwrite(daily_out, file.path(output_dir, sprintf("%s_daily_summary.csv", prefix)))
  fwrite(gap_blocks, file.path(output_dir, sprintf("%s_gap_blocks.csv", prefix)))
  fwrite(duplicate_details, file.path(output_dir, sprintf("%s_duplicate_exact_records.csv", prefix)))
  fwrite(offgrid, file.path(output_dir, sprintf("%s_offgrid_records.csv", prefix)))
  fwrite(summary_tbl, file.path(output_dir, sprintf("%s_summary.csv", prefix)))

  notes <- c(
    sprintf("%s %d EC year coverage audit", site, year),
    sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    sprintf("Input: %s", input_file),
    sprintf("Output directory: %s", output_dir),
    "",
    "Base validity used in this audit:",
    "- timestamp must land exactly on the 30 min grid (:00 or :30, second == 0).",
    "- co2_flux must be finite.",
    "- qc_co2 <= 1.",
    "- flag9_co2 <= 3.",
    sprintf("- day = %.1f:00 to < %.1f:00; night windows only apply u* threshold.", day_start_hour, day_end_hour),
    sprintf("- provisional night u* filter: u_star >= %.3f m s^-1.", ustar_threshold),
    "",
    "Not yet applied in this audit:",
    "- no storage term merge or storage availability check.",
    "- no annual gapfilling itself; this is only the coverage audit.",
    "",
    "Output files:",
    sprintf("- %s_30min.csv", prefix),
    sprintf("- %s_daily_summary.csv", prefix),
    sprintf("- %s_gap_blocks.csv", prefix),
    sprintf("- %s_duplicate_exact_records.csv", prefix),
    sprintf("- %s_offgrid_records.csv", prefix),
    sprintf("- %s_summary.csv", prefix)
  )
  writeLines(notes, file.path(output_dir, sprintf("%s_run_notes.txt", prefix)), useBytes = TRUE)

  summary_tbl
}

main <- function() {
  args <- parse_cli_args(commandArgs(trailingOnly = TRUE))
  summary_tbl <- run_fixed_tower_ec_year_audit(
    site = args$site,
    input_file = args$input,
    output_dir = args$output_dir,
    year = args$year,
    tz_local = args$tz,
    ustar_threshold = as.numeric(args$ustar_threshold),
    day_start_hour = args$day_start_hour,
    day_end_hour = args$day_end_hour
  )
  print(summary_tbl)
}

if (sys.nframe() == 0L) {
  main()
}
