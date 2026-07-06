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
    day_end_hour = 18,
    short_gap_max = 2L,
    donor_input = NULL,
    donor_site = NULL,
    apply_qc_filter = "TRUE",
    apply_flag9_filter = NULL,
    output_tag = NULL
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
  out$ustar_threshold <- as.numeric(out$ustar_threshold)
  out$day_start_hour <- as.numeric(out$day_start_hour)
  out$day_end_hour <- as.numeric(out$day_end_hour)
  out$short_gap_max <- as.integer(out$short_gap_max)
  out$apply_qc_filter <- tolower(as.character(out$apply_qc_filter)) %in% c("true", "t", "1", "yes", "y")
  if (is.null(out$apply_flag9_filter) || identical(out$apply_flag9_filter, "")) {
    out$apply_flag9_filter <- out$apply_qc_filter
  } else {
    out$apply_flag9_filter <- tolower(as.character(out$apply_flag9_filter)) %in% c("true", "t", "1", "yes", "y")
  }
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

season_from_month <- function(month_value) {
  fcase(
    month_value %in% c(12L, 1L, 2L), "DJF",
    month_value %in% c(3L, 4L, 5L), "MAM",
    month_value %in% c(6L, 7L, 8L), "JJA",
    month_value %in% c(9L, 10L, 11L), "SON",
    default = NA_character_
  )
}

annotate_gap_blocks <- function(is_gap, short_gap_max = 2L) {
  n <- length(is_gap)
  out <- data.table(
    gap_block_id = rep(NA_integer_, n),
    gap_block_halfhours = rep(NA_integer_, n),
    gap_block_class = rep(NA_character_, n)
  )
  if (!any(is_gap)) {
    return(out)
  }

  r <- rle(is_gap)
  ends <- cumsum(r$lengths)
  starts <- ends - r$lengths + 1L
  gap_id <- 0L

  for (k in seq_along(r$values)) {
    if (!r$values[[k]]) next
    gap_id <- gap_id + 1L
    idx <- starts[[k]]:ends[[k]]
    gap_len <- length(idx)
    out[idx, `:=`(
      gap_block_id = gap_id,
      gap_block_halfhours = gap_len,
      gap_block_class = if (gap_len <= short_gap_max) "short" else "long"
    )]
  }

  out
}

fill_short_linear <- function(x, max_gap = 2L) {
  y <- x
  n <- length(y)
  is_na <- is.na(y)
  if (!any(is_na)) {
    return(list(values = y, methods = rep(NA_character_, n)))
  }

  r <- rle(is_na)
  ends <- cumsum(r$lengths)
  starts <- ends - r$lengths + 1L
  methods <- rep(NA_character_, n)

  for (k in seq_along(r$values)) {
    if (!r$values[[k]]) next
    gap_len <- r$lengths[[k]]
    if (gap_len > max_gap) next
    s <- starts[[k]]
    e <- ends[[k]]
    left <- s - 1L
    right <- e + 1L
    if (left < 1L || right > n) next
    if (is.na(y[[left]]) || is.na(y[[right]])) next

    step <- (y[[right]] - y[[left]]) / (gap_len + 1L)
    for (j in seq_len(gap_len)) {
      idx <- s + j - 1L
      y[[idx]] <- y[[left]] + step * j
      methods[[idx]] <- "linear_short_gap"
    }
  }

  list(values = y, methods = methods)
}

prepare_reference_data <- function(input_file,
                                   tz_local = default_tz,
                                   day_start_hour = 6,
                                   day_end_hour = 18,
                                   ustar_threshold = 0.15,
                                   apply_qc_filter = TRUE,
                                   apply_flag9_filter = TRUE) {
  if (!file.exists(input_file)) stop("Missing input file: ", input_file, call. = FALSE)

  dt <- fread(
    input_file,
    encoding = "UTF-8",
    colClasses = list(character = c("timestamp", "date", "time"))
  )
  if (!"timestamp" %in% names(dt) && all(c("date", "time") %in% names(dt))) {
    dt[, timestamp := paste(date, time)]
  }

  dt[, timestamp_local := parse_timestamp_local(timestamp, date, time, tz_local = tz_local)]
  dt <- dt[!is.na(timestamp_local)]
  dt[, exact_halfhour := is_exact_halfhour(timestamp_local, tz_local = tz_local)]
  dt <- dt[exact_halfhour == TRUE]

  numeric_cols <- intersect(c("co2_flux", "qc_co2", "flag9_co2", "u_star"), names(dt))
  if (length(numeric_cols) > 0L) {
    dt[, (numeric_cols) := lapply(.SD, as.numeric), .SDcols = numeric_cols]
  }

  dt[, ts_key := timestamp_key(timestamp_local, tz_local = tz_local)]
  agg <- dt[, .(
    n_records = .N,
    co2_flux = first_or_na(co2_flux),
    qc_co2 = first_or_na(qc_co2),
    flag9_co2 = first_or_na(flag9_co2),
    u_star = first_or_na(u_star)
  ), by = .(ts_key, timestamp_local)]

  agg[, `:=`(
    year_local = as.integer(format(timestamp_local, "%Y", tz = tz_local)),
    month = as.integer(format(timestamp_local, "%m", tz = tz_local)),
    hhmm = format(timestamp_local, "%H:%M", tz = tz_local),
    hour = as.integer(format(timestamp_local, "%H", tz = tz_local)),
    minute = as.integer(format(timestamp_local, "%M", tz = tz_local))
  )]
  agg[, season := season_from_month(month)]
  agg[, hour_decimal := hour + minute / 60]
  agg[, day_night := fifelse(hour_decimal >= day_start_hour & hour_decimal < day_end_hour, "day", "night")]
  agg[, `:=`(
    duplicate_exact_record = n_records > 1L,
    has_flux = is.finite(co2_flux),
    qc_co2_pass = is.finite(qc_co2) & qc_co2 <= 1,
    flag9_co2_pass = is.finite(flag9_co2) & flag9_co2 <= 3,
    u_star_available = is.finite(u_star)
  )]
  agg[, valid_base := !duplicate_exact_record & has_flux]
  if (isTRUE(apply_qc_filter)) {
    agg[, valid_base := valid_base & qc_co2_pass]
  }
  if (isTRUE(apply_flag9_filter)) {
    agg[, valid_base := valid_base & flag9_co2_pass]
  }
  agg[, ustar_pass_night := day_night == "day" | (u_star_available & u_star >= ustar_threshold)]
  agg[, valid_final := valid_base & ustar_pass_night]
  setorder(agg, timestamp_local)
  agg
}

build_bridge_model <- function(target_ref, donor_ref) {
  overlap <- merge(
    target_ref[valid_final == TRUE, .(ts_key, target_flux = co2_flux)],
    donor_ref[valid_final == TRUE, .(ts_key, donor_flux = co2_flux)],
    by = "ts_key"
  )
  if (nrow(overlap) < 10L || !is.finite(sd(overlap$donor_flux)) || sd(overlap$donor_flux) == 0) {
    return(list(
      overlap_n = nrow(overlap),
      intercept = NA_real_,
      slope = NA_real_,
      r_squared = NA_real_
    ))
  }

  fit <- lm(target_flux ~ donor_flux, data = overlap)
  coefs <- coef(fit)
  list(
    overlap_n = nrow(overlap),
    intercept = unname(coefs[[1L]]),
    slope = if (length(coefs) >= 2L) unname(coefs[[2L]]) else NA_real_,
    r_squared = summary(fit)$r.squared
  )
}

build_gap_block_table <- function(x, tz_local = default_tz) {
  gap_rows <- x[!is.na(gap_block_id)]
  if (nrow(gap_rows) == 0L) {
    return(data.table(
      site = character(),
      gap_block_id = integer(),
      gap_block_class = character(),
      start_timestamp = character(),
      end_timestamp = character(),
      n_halfhours = integer(),
      gap_days = numeric(),
      primary_fill_method = character(),
      fill_methods = character(),
      gap_reasons = character()
    ))
  }

  gap_rows[, .(
    site = first_or_na(site),
    gap_block_class = first_or_na(gap_block_class),
    start_timestamp = timestamp_key(first_or_na(timestamp_local), tz_local = tz_local),
    end_timestamp = timestamp_key(timestamp_local[.N], tz_local = tz_local),
    n_halfhours = .N,
    gap_days = .N / 48,
    primary_fill_method = names(sort(table(fill_method), decreasing = TRUE))[1L],
    fill_methods = paste(unique(fill_method), collapse = ","),
    gap_reasons = paste(unique(gap_reason_final), collapse = ",")
  ), by = gap_block_id]
}

gap_check <- annotate_gap_blocks(c(FALSE, TRUE, TRUE, FALSE, TRUE), short_gap_max = 2L)
stopifnot(
  identical(gap_check$gap_block_halfhours, c(NA_integer_, 2L, 2L, NA_integer_, 1L)),
  identical(gap_check$gap_block_class, c(NA_character_, "short", "short", NA_character_, "short"))
)

estimate_fixed_tower_nee <- function(site,
                                     input_file,
                                     output_dir,
                                     year = 2025L,
                                     tz_local = default_tz,
                                     ustar_threshold = 0.15,
                                     day_start_hour = 6,
                                     day_end_hour = 18,
                                     short_gap_max = 2L,
                                     donor_input = NULL,
                                     donor_site = NULL,
                                     apply_qc_filter = TRUE,
                                     apply_flag9_filter = TRUE,
                                     output_tag = NULL) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  target_ref <- prepare_reference_data(
    input_file = input_file,
    tz_local = tz_local,
    day_start_hour = day_start_hour,
    day_end_hour = day_end_hour,
    ustar_threshold = ustar_threshold,
    apply_qc_filter = apply_qc_filter,
    apply_flag9_filter = apply_flag9_filter
  )
  target_year_ref <- target_ref[year_local == year]
  if (nrow(target_year_ref) == 0L) stop("No rows found for year ", year, " in ", input_file, call. = FALSE)

  grid <- data.table(timestamp_local = seq(
    from = as.POSIXct(sprintf("%04d-01-01 00:00:00", year), tz = tz_local),
    to = as.POSIXct(sprintf("%04d-12-31 23:30:00", year), tz = tz_local),
    by = "30 min"
  ))
  grid[, `:=`(
    ts_key = timestamp_key(timestamp_local, tz_local = tz_local),
    site = site,
    date = as.IDate(format(timestamp_local, "%Y-%m-%d", tz = tz_local)),
    month = as.integer(format(timestamp_local, "%m", tz = tz_local)),
    season = season_from_month(as.integer(format(timestamp_local, "%m", tz = tz_local))),
    hhmm = format(timestamp_local, "%H:%M", tz = tz_local),
    hour = as.integer(format(timestamp_local, "%H", tz = tz_local)),
    minute = as.integer(format(timestamp_local, "%M", tz = tz_local))
  )]

  keep_cols <- c(
    "ts_key", "co2_flux", "qc_co2", "flag9_co2", "u_star", "n_records",
    "duplicate_exact_record", "has_flux", "qc_co2_pass", "flag9_co2_pass",
    "u_star_available", "valid_base", "ustar_pass_night", "valid_final"
  )
  x <- merge(grid, target_year_ref[, ..keep_cols], by = "ts_key", all.x = TRUE, sort = FALSE)
  x[, hour_decimal := hour + minute / 60]
  x[, day_night := fifelse(hour_decimal >= day_start_hour & hour_decimal < day_end_hour, "day", "night")]
  x[, `:=`(
    has_record = !is.na(n_records),
    duplicate_exact_record = !is.na(n_records) & n_records > 1L,
    has_flux = is.finite(co2_flux),
    qc_co2_pass = is.finite(qc_co2) & qc_co2 <= 1,
    flag9_co2_pass = is.finite(flag9_co2) & flag9_co2 <= 3,
    u_star_available = is.finite(u_star)
  )]
  x[, valid_base := has_record & !duplicate_exact_record & has_flux]
  if (isTRUE(apply_qc_filter)) {
    x[, valid_base := valid_base & qc_co2_pass]
  }
  if (isTRUE(apply_flag9_filter)) {
    x[, valid_base := valid_base & flag9_co2_pass]
  }
  x[, ustar_pass_night := day_night == "day" | (u_star_available & u_star >= ustar_threshold)]
  x[, valid_final := valid_base & ustar_pass_night]

  x[, flux_observed_final := fifelse(valid_final, co2_flux, NA_real_)]
  gap_meta <- annotate_gap_blocks(is.na(x$flux_observed_final), short_gap_max = short_gap_max)
  x <- cbind(x, gap_meta)

  linear <- fill_short_linear(x$flux_observed_final, max_gap = short_gap_max)
  x[, `:=`(
    flux_after_linear = linear$values,
    fill_method = fifelse(valid_final, "observed_valid", linear$methods),
    gapfilled_co2_flux = linear$values
  )]

  bridge_model <- list(overlap_n = 0L, intercept = NA_real_, slope = NA_real_, r_squared = NA_real_)
  donor_year_lookup <- NULL
  if (!is.null(donor_input) && !identical(donor_input, "")) {
    donor_ref <- prepare_reference_data(
      input_file = donor_input,
      tz_local = tz_local,
      day_start_hour = day_start_hour,
      day_end_hour = day_end_hour,
      ustar_threshold = ustar_threshold,
      apply_qc_filter = apply_qc_filter,
      apply_flag9_filter = apply_flag9_filter
    )
    bridge_model <- build_bridge_model(target_ref, donor_ref)
    if (is.finite(bridge_model$intercept) && is.finite(bridge_model$slope)) {
      donor_year_lookup <- donor_ref[year_local == year & valid_final == TRUE, .(
        ts_key,
        donor_flux_same_timestamp = co2_flux,
        donor_pred_same_timestamp = bridge_model$intercept + bridge_model$slope * co2_flux
      )]
      x <- merge(x, donor_year_lookup, by = "ts_key", all.x = TRUE, sort = FALSE)
      x[is.na(gapfilled_co2_flux) & is.finite(donor_pred_same_timestamp), `:=`(
        gapfilled_co2_flux = donor_pred_same_timestamp,
        fill_method = "other_tower_same_timestamp_regression"
      )]
    } else {
      x[, `:=`(
        donor_flux_same_timestamp = NA_real_,
        donor_pred_same_timestamp = NA_real_
      )]
    }
  } else {
    x[, `:=`(
      donor_flux_same_timestamp = NA_real_,
      donor_pred_same_timestamp = NA_real_
    )]
  }

  same_tower_ref <- target_ref[valid_final == TRUE, .(year_local, month, season, hhmm, day_night, co2_flux)]
  same_tower_years <- sort(unique(same_tower_ref$year_local))
  clim_mhdn <- same_tower_ref[, .(fill_value = mean(co2_flux)), by = .(month, hhmm, day_night)]
  clim_shdn <- same_tower_ref[, .(fill_value = mean(co2_flux)), by = .(season, hhmm, day_night)]
  clim_mh <- same_tower_ref[, .(fill_value = mean(co2_flux)), by = .(month, hhmm)]
  clim_hdn <- same_tower_ref[, .(fill_value = mean(co2_flux)), by = .(hhmm, day_night)]
  clim_h <- same_tower_ref[, .(fill_value = mean(co2_flux)), by = .(hhmm)]
  clim_dn <- same_tower_ref[, .(fill_value = mean(co2_flux)), by = .(day_night)]
  overall_mean <- mean(same_tower_ref$co2_flux)

  x[clim_mhdn, fill_value_mhdn := i.fill_value, on = .(month, hhmm, day_night)]
  x[clim_shdn, fill_value_shdn := i.fill_value, on = .(season, hhmm, day_night)]
  x[clim_mh, fill_value_mh := i.fill_value, on = .(month, hhmm)]
  x[clim_hdn, fill_value_hdn := i.fill_value, on = .(hhmm, day_night)]
  x[clim_h, fill_value_h := i.fill_value, on = .(hhmm)]
  x[clim_dn, fill_value_dn := i.fill_value, on = .(day_night)]

  x[is.na(gapfilled_co2_flux) & is.finite(fill_value_mhdn), `:=`(
    gapfilled_co2_flux = fill_value_mhdn,
    fill_method = "climatology_multiyear_month_halfhour_daynight"
  )]
  x[is.na(gapfilled_co2_flux) & is.finite(fill_value_shdn), `:=`(
    gapfilled_co2_flux = fill_value_shdn,
    fill_method = "climatology_multiyear_season_halfhour_daynight"
  )]
  x[is.na(gapfilled_co2_flux) & is.finite(fill_value_mh), `:=`(
    gapfilled_co2_flux = fill_value_mh,
    fill_method = "climatology_multiyear_month_halfhour"
  )]
  x[is.na(gapfilled_co2_flux) & is.finite(fill_value_hdn), `:=`(
    gapfilled_co2_flux = fill_value_hdn,
    fill_method = "climatology_multiyear_halfhour_daynight"
  )]
  x[is.na(gapfilled_co2_flux) & is.finite(fill_value_h), `:=`(
    gapfilled_co2_flux = fill_value_h,
    fill_method = "climatology_multiyear_halfhour"
  )]
  x[is.na(gapfilled_co2_flux) & is.finite(fill_value_dn), `:=`(
    gapfilled_co2_flux = fill_value_dn,
    fill_method = "climatology_multiyear_daynight"
  )]
  x[is.na(gapfilled_co2_flux), `:=`(
    gapfilled_co2_flux = overall_mean,
    fill_method = "climatology_multiyear_overall"
  )]

  x[, filled_by_gapfill := fill_method != "observed_valid"]
  x[, fill_source_group := fcase(
    fill_method == "observed_valid", "observed",
    fill_method == "linear_short_gap", "short_gap_linear",
    fill_method == "other_tower_same_timestamp_regression", "other_tower_same_timestamp_regression",
    startsWith(fill_method, "climatology_multiyear"), "same_tower_multiyear_climatology",
    default = "other"
  )]
  x[, gap_scope := fcase(
    fill_method == "observed_valid", "observed",
    gap_block_class == "short", "short_gap",
    gap_block_class == "long", "long_gap",
    default = "gapfill_unknown"
  )]
  x[, gap_reason_final := fifelse(
    !has_record, "missing_no_record",
    fifelse(
      duplicate_exact_record, "duplicate_exact_record",
      fifelse(
        !has_flux, "present_no_flux",
        fifelse(
          isTRUE(apply_qc_filter) & !qc_co2_pass, "qc_co2_fail",
          fifelse(
          isTRUE(apply_flag9_filter) & !flag9_co2_pass, "flag9_co2_fail",
            fifelse(
              day_night == "night" & !u_star_available, "night_no_u_star",
              fifelse(day_night == "night" & u_star < ustar_threshold, "night_u_star_below_threshold", "observed_valid")
            )
          )
        )
      )
    )
  )]

  x[, `:=`(
    observed_component_gC_m2 = fifelse(valid_final, co2_flux * 1800 * 12e-6, 0),
    filled_component_gC_m2 = fifelse(filled_by_gapfill, gapfilled_co2_flux * 1800 * 12e-6, 0),
    total_component_gC_m2 = gapfilled_co2_flux * 1800 * 12e-6
  )]

  summary_tbl <- data.table(
    site = site,
    year = year,
    qc_filter_applied = apply_qc_filter,
    flag9_filter_applied = apply_flag9_filter,
    ustar_threshold = ustar_threshold,
    day_start_hour = day_start_hour,
    day_end_hour = day_end_hour,
    short_gap_max = short_gap_max,
    expected_halfhours = nrow(x),
    observed_valid_windows = sum(x$valid_final),
    gapfilled_windows = sum(x$filled_by_gapfill),
    short_gapfilled_windows = sum(x$filled_by_gapfill & x$gap_scope == "short_gap"),
    long_gapfilled_windows = sum(x$filled_by_gapfill & x$gap_scope == "long_gap"),
    linear_filled_windows = sum(x$fill_method == "linear_short_gap"),
    other_tower_same_timestamp_windows = sum(x$fill_method == "other_tower_same_timestamp_regression"),
    same_tower_multiyear_climatology_windows = sum(startsWith(x$fill_method, "climatology_multiyear")),
    annual_nee_estimate_gC_m2 = sum(x$total_component_gC_m2),
    observed_component_gC_m2 = sum(x$observed_component_gC_m2),
    gapfilled_component_gC_m2 = sum(x$filled_component_gC_m2),
    short_gapfilled_component_gC_m2 = sum(x$filled_component_gC_m2[x$gap_scope == "short_gap"]),
    long_gapfilled_component_gC_m2 = sum(x$filled_component_gC_m2[x$gap_scope == "long_gap"]),
    other_tower_same_timestamp_component_gC_m2 = sum(x$filled_component_gC_m2[x$fill_method == "other_tower_same_timestamp_regression"]),
    same_tower_reference_valid_windows = nrow(same_tower_ref),
    same_tower_reference_year_count = length(same_tower_years),
    bridge_overlap_windows = bridge_model$overlap_n,
    bridge_intercept = bridge_model$intercept,
    bridge_slope = bridge_model$slope,
    bridge_r_squared = bridge_model$r_squared,
    mean_gapfilled_co2_flux = mean(x$gapfilled_co2_flux),
    min_gapfilled_co2_flux = min(x$gapfilled_co2_flux),
    max_gapfilled_co2_flux = max(x$gapfilled_co2_flux)
  )

  method_counts <- x[, .N, by = .(fill_method, gap_scope, fill_source_group)][order(gap_scope, fill_method)]
  gap_scope_summary <- x[filled_by_gapfill == TRUE, .(
    filled_windows = .N,
    filled_component_gC_m2 = sum(filled_component_gC_m2)
  ), by = .(gap_scope, fill_source_group, fill_method)][order(gap_scope, fill_source_group, fill_method)]
  daily <- x[, .(
    observed_valid_windows = sum(valid_final),
    gapfilled_windows = sum(filled_by_gapfill),
    daily_nee_estimate_gC_m2 = sum(total_component_gC_m2)
  ), by = .(site, date)]
  gap_blocks <- build_gap_block_table(x, tz_local = tz_local)
  long_gap_blocks_ge_1day <- gap_blocks[gap_block_class == "long" & n_halfhours >= 48]

  prefix <- sprintf("%s_nee_%d_estimate", site, year)
  if (!is.null(output_tag) && !identical(output_tag, "")) {
    prefix <- sprintf("%s_%s", prefix, output_tag)
  }
  out_main <- copy(x)
  out_main[, timestamp_local := timestamp_key(timestamp_local, tz_local = tz_local)]
  fwrite(out_main, file.path(output_dir, sprintf("%s_30min_gapfilled.csv", prefix)))
  fwrite(daily, file.path(output_dir, sprintf("%s_daily_summary.csv", prefix)))
  fwrite(summary_tbl, file.path(output_dir, sprintf("%s_summary.csv", prefix)))
  fwrite(method_counts, file.path(output_dir, sprintf("%s_fill_method_counts.csv", prefix)))
  fwrite(gap_scope_summary, file.path(output_dir, sprintf("%s_gapfill_scope_summary.csv", prefix)))
  fwrite(gap_blocks, file.path(output_dir, sprintf("%s_gap_blocks.csv", prefix)))
  fwrite(long_gap_blocks_ge_1day, file.path(output_dir, sprintf("%s_long_gap_blocks_ge_1day.csv", prefix)))

  notes <- c(
    sprintf("%s %d EC-only NEE estimate", site, year),
    sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    sprintf("Input: %s", input_file),
    sprintf("Output directory: %s", output_dir),
    "",
    "Current estimate scope:",
    "- PF-corrected fixed-tower co2_flux only.",
    "- This is an EC-only annual NEE estimate / proxy, not a final carbon-budget closure result.",
    "",
    "Rules:",
    "- exact 30 min timestamps only.",
    if (isTRUE(apply_qc_filter) && isTRUE(apply_flag9_filter)) {
      "- valid_base requires finite co2_flux, qc_co2 <= 1, flag9_co2 <= 3, and no duplicate exact timestamp."
    } else if (isTRUE(apply_qc_filter) && !isTRUE(apply_flag9_filter)) {
      "- valid_base requires finite co2_flux, qc_co2 <= 1, and no duplicate exact timestamp; flag9_co2 is not used for exclusion."
    } else {
      "- valid_base requires finite co2_flux and no duplicate exact timestamp; qc_co2 and flag9_co2 are not used for exclusion."
    },
    sprintf("- day = %.1f:00 to < %.1f:00; night windows only apply u* threshold.", day_start_hour, day_end_hour),
    sprintf("- provisional night u* threshold = %.3f m s^-1.", ustar_threshold),
    sprintf("- short gaps <= %d half-hours use linear interpolation when both sides are valid.", short_gap_max),
    sprintf("- same-tower multiyear reference years used: %s.", paste(same_tower_years, collapse = ", ")),
    "- remaining gaps use multiyear climatology, priority = month x halfhour x day/night, season x halfhour x day/night, month x halfhour, halfhour x day/night, halfhour, day/night, then overall.",
    if (!is.null(donor_input) && !identical(donor_input, "")) {
      sprintf("- donor tower bridge: %s -> %s, overlap windows = %d, R^2 = %s.", donor_site, site, bridge_model$overlap_n, ifelse(is.finite(bridge_model$r_squared), sprintf("%.3f", bridge_model$r_squared), "NA"))
    } else {
      "- donor tower bridge not used."
    },
    "",
    "Units:",
    "- co2_flux keeps the original sign convention from the source table.",
    "- annual_nee_estimate_gC_m2 sums 30 min fluxes as flux * 1800 s * 12e-6 gC per umol."
  )
  writeLines(notes, file.path(output_dir, sprintf("%s_run_notes.txt", prefix)), useBytes = TRUE)

  summary_tbl
}

main <- function() {
  args <- parse_cli_args(commandArgs(trailingOnly = TRUE))
  summary_tbl <- estimate_fixed_tower_nee(
    site = args$site,
    input_file = args$input,
    output_dir = args$output_dir,
    year = args$year,
    tz_local = args$tz,
    ustar_threshold = args$ustar_threshold,
    day_start_hour = args$day_start_hour,
    day_end_hour = args$day_end_hour,
    short_gap_max = args$short_gap_max,
    donor_input = args$donor_input,
    donor_site = args$donor_site,
    apply_qc_filter = args$apply_qc_filter,
    apply_flag9_filter = args$apply_flag9_filter,
    output_tag = args$output_tag
  )
  print(summary_tbl)
}

if (sys.nframe() == 0L) {
  main()
}
