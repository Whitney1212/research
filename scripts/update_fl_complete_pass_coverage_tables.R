#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

default_root <- "E:/Dataset_Level1/Flares/PFparameter_expanded_training"
default_two_root <- "E:/Dataset_Level1/Flares/PFparameter_expanded_training_2ensemble"

parse_args <- function(args) {
  opts <- list(
    root = default_root,
    two_root = default_two_root,
    timezone = "Asia/Shanghai"
  )

  for (arg in args) {
    if (grepl("^--root=", arg)) {
      opts$root <- sub("^--root=", "", arg)
    } else if (grepl("^--two-root=", arg)) {
      opts$two_root <- sub("^--two-root=", "", arg)
    } else if (grepl("^--timezone=", arg)) {
      opts$timezone <- sub("^--timezone=", "", arg)
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/update_fl_complete_pass_coverage_tables.R [options]\n",
        "  --root=E:/Dataset_Level1/Flares/PFparameter_expanded_training\n",
        "  --two-root=E:/Dataset_Level1/Flares/PFparameter_expanded_training_2ensemble\n",
        "  --timezone=Asia/Shanghai\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  opts
}

must_read <- function(path) {
  if (!file.exists(path)) {
    stop("Missing required file: ", path, call. = FALSE)
  }
  fread(path)
}

parse_local <- function(x, tz) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%OS", tz = tz)
}

finite_or_na <- function(x, fn) {
  x <- x[is.finite(x)]
  if (length(x) == 0) NA_real_ else fn(x)
}

add_pass_date_month <- function(dt, preferred_start_cols) {
  start_col <- intersect(preferred_start_cols, names(dt))[1]
  if (is.na(start_col)) {
    stop(
      "Could not find a start-time column. Tried: ",
      paste(preferred_start_cols, collapse = ", "),
      call. = FALSE
    )
  }
  dt[, `:=`(
    pass_date = as.Date(substr(get(start_col), 1, 10)),
    month = substr(get(start_col), 1, 7)
  )]
  dt[]
}

summarise_passes <- function(passes, by_cols) {
  passes[, .(
    strict_passes = .N,
    n_fw = sum(direction == "fw", na.rm = TRUE),
    n_bw = sum(direction == "bw", na.rm = TRUE),
    first_pass_start_local = format(min(start_time), "%Y-%m-%d %H:%M:%S"),
    last_pass_end_local = format(max(end_time), "%Y-%m-%d %H:%M:%S"),
    total_pass_hours = sum(duration_min, na.rm = TRUE) / 60,
    span_hours = as.numeric(difftime(max(end_time), min(start_time), units = "hours")),
    median_duration_min = finite_or_na(duration_min, median),
    median_abs_speed_cm_s = finite_or_na(median_abs_speed_cm_s, median),
    median_position_speed_cm_s = finite_or_na(median_position_speed_cm_s, median),
    median_position_coverage = finite_or_na(position_coverage, median)
  ), by = by_cols]
}

first_nonzero_note <- function(strict_passes, raw_files, passbin_passes, two_ensembles, four_ensembles) {
  fifelse(
    strict_passes > 0 & passbin_passes == 0,
    "strict_pass_only_no_valid_passbin",
    fifelse(
      passbin_passes > 0 & four_ensembles == 0 & two_ensembles > 0,
      "usable_for_2ensemble_not_4ensemble",
      fifelse(
        passbin_passes > 0 & two_ensembles == 0 & four_ensembles == 0,
        "passbin_available_no_valid_ensemble",
        fifelse(
          raw_files == 0,
          "no_raw_file_matched",
          "ok"
        )
      )
    )
  )
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))

  strict_path <- file.path(opts$root, "fl_complete_passes_strict.csv")
  raw_path <- file.path(opts$root, "cache", "PF_8bin_raw_files_used.csv")
  pass_bin_path <- file.path(opts$root, "PF_8bin_pass_bin_means.csv")
  four_pass_path <- file.path(opts$root, "cache", "PF_8bin_four_pass_ensembles.csv")
  four_points_path <- file.path(opts$root, "pf_input_points.csv")
  two_pass_path <- file.path(opts$two_root, "PF_8bin_2ensemble_passes.csv")
  two_points_path <- file.path(opts$two_root, "pf_input_points.csv")

  passes <- must_read(strict_path)
  passes[, `:=`(
    start_time = parse_local(start_time_local, opts$timezone),
    end_time = parse_local(end_time_local, opts$timezone),
    pass_date = as.Date(substr(start_time_local, 1, 10)),
    month = substr(start_time_local, 1, 7)
  )]
  setorder(passes, start_time, pass_id)

  raw <- must_read(raw_path)
  raw[, `:=`(
    raw_date = as.Date(gsub("_", "-", date_token)),
    month = substr(gsub("_", "-", date_token), 1, 7)
  )]

  pass_bin <- must_read(pass_bin_path)
  pass_bin[, `:=`(
    pass_date = as.Date(substr(pass_start_local, 1, 10)),
    month = substr(pass_start_local, 1, 7)
  )]

  four_passes <- must_read(four_pass_path)
  four_passes <- add_pass_date_month(four_passes, c("start_time_local", "pass_start_local"))

  two_passes <- must_read(two_pass_path)
  two_passes <- add_pass_date_month(two_passes, c("pass_start_local", "start_time_local"))

  four_points <- must_read(four_points_path)
  four_points[, `:=`(
    pass_date = as.Date(substr(point_start_local, 1, 10)),
    month = substr(point_start_local, 1, 7)
  )]

  two_points <- must_read(two_points_path)
  two_points[, `:=`(
    pass_date = as.Date(substr(point_start_local, 1, 10)),
    month = substr(point_start_local, 1, 7)
  )]

  by_day <- "pass_date"
  by_month <- "month"

  daily <- summarise_passes(passes, by_day)
  daily <- raw[, .(raw_files = .N, raw_file_days = uniqueN(raw_date)), by = .(pass_date = raw_date)][daily, on = "pass_date"]
  daily <- pass_bin[, .(passbin_rows = .N, passbin_passes = uniqueN(pass_id)), by = pass_date][daily, on = "pass_date"]
  daily <- four_passes[ensemble_valid == TRUE, .(
    four_valid_passes_all_strict = .N,
    four_ensembles_all_strict = uniqueN(ensemble_id)
  ), by = pass_date][daily, on = "pass_date"]
  daily <- four_passes[ensemble_valid == TRUE & pass_id %in% unique(pass_bin$pass_id), .(
    four_valid_passes_with_passbin = .N,
    four_ensembles_with_passbin = uniqueN(ensemble_id)
  ), by = pass_date][daily, on = "pass_date"]
  daily <- two_passes[ensemble_valid == TRUE & pass_id %in% unique(pass_bin$pass_id), .(
    two_valid_passes_with_passbin = .N,
    two_ensembles_with_passbin = uniqueN(ensemble_id)
  ), by = pass_date][daily, on = "pass_date"]
  daily <- four_points[, .(pf4_input_points = .N), by = pass_date][daily, on = "pass_date"]
  daily <- two_points[, .(pf2_input_points = .N), by = pass_date][daily, on = "pass_date"]

  monthly <- summarise_passes(passes, by_month)
  monthly[, strict_days := uniqueN(passes[month == .BY$month]$pass_date), by = month]
  monthly <- raw[, .(raw_files = .N, raw_file_days = uniqueN(raw_date)), by = month][monthly, on = "month"]
  monthly <- pass_bin[, .(passbin_rows = .N, passbin_passes = uniqueN(pass_id), passbin_days = uniqueN(pass_date)), by = month][monthly, on = "month"]
  monthly <- four_passes[ensemble_valid == TRUE, .(
    four_valid_passes_all_strict = .N,
    four_ensembles_all_strict = uniqueN(ensemble_id)
  ), by = month][monthly, on = "month"]
  monthly <- four_passes[ensemble_valid == TRUE & pass_id %in% unique(pass_bin$pass_id), .(
    four_valid_passes_with_passbin = .N,
    four_ensembles_with_passbin = uniqueN(ensemble_id)
  ), by = month][monthly, on = "month"]
  monthly <- two_passes[ensemble_valid == TRUE & pass_id %in% unique(pass_bin$pass_id), .(
    two_valid_passes_with_passbin = .N,
    two_ensembles_with_passbin = uniqueN(ensemble_id)
  ), by = month][monthly, on = "month"]
  monthly <- four_points[, .(pf4_input_points = .N), by = month][monthly, on = "month"]
  monthly <- two_points[, .(pf2_input_points = .N), by = month][monthly, on = "month"]

  fill_zero_cols <- c(
    "raw_files", "raw_file_days", "passbin_rows", "passbin_passes", "passbin_days",
    "four_valid_passes_all_strict", "four_ensembles_all_strict",
    "four_valid_passes_with_passbin", "four_ensembles_with_passbin",
    "two_valid_passes_with_passbin", "two_ensembles_with_passbin",
    "pf4_input_points", "pf2_input_points"
  )
  for (dt in list(daily, monthly)) {
    cols <- intersect(fill_zero_cols, names(dt))
    for (col in cols) set(dt, which(is.na(dt[[col]])), col, 0L)
  }

  daily[, coverage_note := first_nonzero_note(
    strict_passes, raw_files, passbin_passes,
    two_ensembles_with_passbin, four_ensembles_with_passbin
  )]
  monthly[, coverage_note := first_nonzero_note(
    strict_passes, raw_files, passbin_passes,
    two_ensembles_with_passbin, four_ensembles_with_passbin
  )]

  setorder(daily, pass_date)
  setorder(monthly, month)

  daily_path <- file.path(opts$root, "fl_complete_pass_coverage_daily_updated.csv")
  monthly_path <- file.path(opts$root, "fl_complete_pass_coverage_monthly_updated.csv")
  fwrite(daily, daily_path)
  fwrite(monthly, monthly_path)

  cat("Strict passes: ", nrow(passes), "\n", sep = "")
  cat("Daily coverage rows: ", nrow(daily), "\n", sep = "")
  cat("Monthly coverage rows: ", nrow(monthly), "\n", sep = "")
  cat("Daily output: ", daily_path, "\n", sep = "")
  cat("Monthly output: ", monthly_path, "\n", sep = "")
}

main()
