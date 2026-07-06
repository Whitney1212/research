#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

defaults <- list(
  input_dir = "E:/Dataset_Level1/MorningPeak/W2_2025_foundation",
  output_dir = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025",
  year = 2025L,
  timezone = "Asia/Shanghai",
  pre_start_hr = 0,
  pre_end_hr = 2.5,
  peak_start_hr = 2.5,
  peak_end_hr = 4.5
)

parse_args <- function(args) {
  opts <- defaults
  opts$self_test <- FALSE

  for (arg in args) {
    if (arg == "--self-test") {
      opts$self_test <- TRUE
    } else if (grepl("^--input-dir=", arg)) {
      opts$input_dir <- sub("^--input-dir=", "", arg)
    } else if (grepl("^--output-dir=", arg)) {
      opts$output_dir <- sub("^--output-dir=", "", arg)
    } else if (grepl("^--year=", arg)) {
      opts$year <- as.integer(sub("^--year=", "", arg))
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/detect_morning_peak_events_2025.R [options]\n",
        "  --input-dir=E:/Dataset_Level1/MorningPeak/W2_2025_foundation\n",
        "  --output-dir=E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025\n",
        "  --year=2025\n",
        "  --self-test\n",
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
  if (!file.exists(path)) stop("Missing required file: ", path, call. = FALSE)
  fread(path, encoding = "UTF-8", colClasses = "character")
}

parse_time <- function(x, tz) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = tz)
}

first_min <- function(dt) {
  if (nrow(dt) == 0) return(dt[0])
  dt[order(co2_mean, window_start)][1]
}

first_max <- function(dt) {
  if (nrow(dt) == 0) return(dt[0])
  dt[order(-co2_mean, window_start)][1]
}

has_overall_decline <- function(x) {
  length(x) >= 2 && tail(x, 1) < x[1]
}

has_overall_rise <- function(x) {
  length(x) >= 2 && tail(x, 1) > x[1]
}

find_peak_shape <- function(records, pre, peak) {
  pre_min <- first_min(pre)
  peak_max <- first_max(peak)
  if (nrow(pre_min) == 0) {
    return(list(ok = FALSE, reason = "missing_pre_window"))
  }
  if (nrow(peak_max) == 0) {
    return(list(ok = FALSE, reason = "missing_peak_window"))
  }

  decline_seq <- pre[window_start <= pre_min$window_start][order(window_start)]
  rise_seq <- records[
    window_start >= pre_min$window_start &
      window_start <= peak_max$window_start
  ][order(window_start)]

  if (!has_overall_decline(decline_seq$co2_mean)) {
    return(list(ok = FALSE, reason = "pre_not_overall_decline"))
  }
  if (!has_overall_rise(rise_seq$co2_mean)) {
    return(list(ok = FALSE, reason = "post_min_not_overall_rise"))
  }

  list(ok = TRUE, reason = "ok", pre_min = pre_min, peak_max = peak_max)
}

build_site_day_events <- function(ap, qc, sunrise, opts) {
  ap[, `:=`(
    date = as.IDate(date),
    window_start = parse_time(window_start, opts$timezone),
    co2_mean = as.numeric(co2_mean)
  )]
  qc[, date := as.IDate(date)]
  sunrise[, `:=`(
    date = as.IDate(date),
    sunrise_ref = parse_time(sunrise_ref_sw, opts$timezone)
  )]

  base <- merge(qc, sunrise[, .(date, sunrise_ref)], by = "date", all.x = TRUE)
  setorder(base, site, date)

  rows <- vector("list", nrow(base))
  for (i in seq_len(nrow(base))) {
    b <- base[i]
    records <- ap[site == b$site & date == b$date & is.finite(co2_mean)]
    if (b$coverage_status == "full_day" && !is.na(b$sunrise_ref)) {
      rel_hr <- as.numeric(difftime(records$window_start, b$sunrise_ref, units = "hours"))
      pre <- records[rel_hr >= opts$pre_start_hr & rel_hr <= opts$pre_end_hr]
      peak <- records[rel_hr > opts$peak_start_hr & rel_hr <= opts$peak_end_hr]
    } else {
      pre <- records[0]
      peak <- records[0]
    }

    shape <- if (b$coverage_status == "full_day" && !is.na(b$sunrise_ref)) {
      find_peak_shape(records, pre, peak)
    } else {
      list(ok = FALSE, reason = NA_character_)
    }
    usable <- b$coverage_status == "full_day" &&
      !is.na(b$sunrise_ref) &&
      isTRUE(shape$ok)

    reason <- if (usable) {
      shape$reason
    } else if (b$coverage_status != "full_day") {
      b$coverage_status
    } else if (is.na(b$sunrise_ref)) {
      "missing_sunrise_ref"
    } else {
      shape$reason
    }

    amp <- if (usable) shape$peak_max$co2_mean - shape$pre_min$co2_mean else NA_real_
    rows[[i]] <- data.table(
      site = b$site,
      date = b$date,
      usable_for_event_rule = usable,
      exclusion_reason = reason,
      coverage_status = b$coverage_status,
      sunrise_ref = if (is.na(b$sunrise_ref)) NA_character_ else format(b$sunrise_ref, "%Y-%m-%d %H:%M:%S", tz = opts$timezone),
      pre_min_window_hr = sprintf("%.1f-%.1f", opts$pre_start_hr, opts$pre_end_hr),
      peak_window_hr = sprintf("(%.1f,%.1f]", opts$peak_start_hr, opts$peak_end_hr),
      pre_min_time = if (usable) format(shape$pre_min$window_start, "%Y-%m-%d %H:%M:%S", tz = opts$timezone) else NA_character_,
      pre_min_co2 = if (usable) shape$pre_min$co2_mean else NA_real_,
      peak_time = if (usable) format(shape$peak_max$window_start, "%Y-%m-%d %H:%M:%S", tz = opts$timezone) else NA_character_,
      peak_co2 = if (usable) shape$peak_max$co2_mean else NA_real_,
      amp_ppm = amp,
      peak_by_diff = !is.na(amp) & amp > 0,
      event_5ppm = !is.na(amp) & amp >= 5,
      event_10ppm = !is.na(amp) & amp >= 10,
      n_pre_windows = nrow(pre),
      n_peak_windows = nrow(peak)
    )
  }

  rbindlist(rows)
}

build_day_pair <- function(site_day, tz) {
  keep <- site_day[, .(
    date, site, usable_for_event_rule, amp_ppm, peak_by_diff, event_5ppm, event_10ppm,
    pre_min_time, peak_time
  )]
  wide <- dcast(
    keep,
    date ~ site,
    value.var = c(
      "usable_for_event_rule", "amp_ppm", "peak_by_diff", "event_5ppm", "event_10ppm",
      "pre_min_time", "peak_time"
    )
  )
  for (col in c("peak_by_diff_CVT", "peak_by_diff_MT", "event_5ppm_CVT", "event_5ppm_MT", "event_10ppm_CVT", "event_10ppm_MT")) {
    if (col %in% names(wide)) set(wide, which(is.na(wide[[col]])), col, FALSE)
  }
  wide[, `:=`(
    peak_by_diff_any = peak_by_diff_CVT | peak_by_diff_MT,
    peak_by_diff_both = peak_by_diff_CVT & peak_by_diff_MT,
    event_5ppm_any = event_5ppm_CVT | event_5ppm_MT,
    event_5ppm_both = event_5ppm_CVT & event_5ppm_MT,
    event_10ppm_any = event_10ppm_CVT | event_10ppm_MT,
    event_10ppm_both = event_10ppm_CVT & event_10ppm_MT
  )]
  wide[, peak_lag_mt_minus_cvt_min := as.numeric(difftime(
    parse_time(peak_time_MT, tz),
    parse_time(peak_time_CVT, tz),
    units = "mins"
  ))]
  wide[, pre_min_lag_mt_minus_cvt_min := as.numeric(difftime(
    parse_time(pre_min_time_MT, tz),
    parse_time(pre_min_time_CVT, tz),
    units = "mins"
  ))]
  setorder(wide, date)
  wide[]
}

write_outputs <- function(site_day, day_pair, opts) {
  dirs <- file.path(opts$output_dir, c("metrics", "events_10ppm", "events_5ppm", "qc", "summary"))
  invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))

  amplitude_inventory <- site_day[usable_for_event_rule == TRUE][order(site, date)]
  amplitude_quantiles <- amplitude_inventory[, as.list(quantile(
    amp_ppm,
    probs = c(0, 0.05, 0.1, 0.25, 0.5, 0.75, 0.9, 0.95, 1),
    na.rm = TRUE,
    names = FALSE
  )), by = site]
  setnames(amplitude_quantiles, c("site", "q00", "q05", "q10", "q25", "q50", "q75", "q90", "q95", "q100"))

  fwrite(site_day, file.path(opts$output_dir, "metrics", sprintf("morning_peak_events_%s_site_day.csv", opts$year)))
  fwrite(day_pair, file.path(opts$output_dir, "metrics", sprintf("morning_peak_events_%s_day_pair.csv", opts$year)))
  fwrite(amplitude_inventory, file.path(opts$output_dir, "metrics", sprintf("morning_peak_amplitude_inventory_%s_site_day.csv", opts$year)))
  fwrite(amplitude_quantiles, file.path(opts$output_dir, "summary", sprintf("morning_peak_amplitude_quantiles_%s_by_site.csv", opts$year)))
  fwrite(site_day[event_10ppm == TRUE], file.path(opts$output_dir, "events_10ppm", sprintf("morning_peak_events_%s_robust_site_days.csv", opts$year)))
  fwrite(day_pair[event_10ppm_any == TRUE], file.path(opts$output_dir, "events_10ppm", sprintf("morning_peak_events_%s_robust_days_any_tower.csv", opts$year)))
  fwrite(site_day[event_5ppm == TRUE], file.path(opts$output_dir, "events_5ppm", sprintf("morning_peak_events_%s_loose_site_days.csv", opts$year)))
  fwrite(day_pair[event_5ppm_any == TRUE], file.path(opts$output_dir, "events_5ppm", sprintf("morning_peak_events_%s_loose_days_any_tower.csv", opts$year)))
  fwrite(site_day[usable_for_event_rule == FALSE], file.path(opts$output_dir, "qc", sprintf("morning_peak_events_%s_exclusions.csv", opts$year)))

  summary <- site_day[, .(
    total_site_days = .N,
    usable_days = sum(usable_for_event_rule),
    peak_by_diff_days = sum(peak_by_diff),
    event_5ppm_days = sum(event_5ppm),
    event_10ppm_days = sum(event_10ppm),
    mean_amp_ppm = mean(amp_ppm, na.rm = TRUE),
    median_amp_ppm = median(amp_ppm, na.rm = TRUE)
  ), by = site]
  fwrite(summary, file.path(opts$output_dir, "summary", sprintf("morning_peak_events_%s_summary_by_site.csv", opts$year)))

  day_summary <- data.table(
    total_days = nrow(day_pair),
    peak_by_diff_any_days = sum(day_pair$peak_by_diff_any),
    peak_by_diff_both_days = sum(day_pair$peak_by_diff_both),
    event_5ppm_any_days = sum(day_pair$event_5ppm_any),
    event_5ppm_both_days = sum(day_pair$event_5ppm_both),
    event_10ppm_any_days = sum(day_pair$event_10ppm_any),
    event_10ppm_both_days = sum(day_pair$event_10ppm_both)
  )
  fwrite(day_summary, file.path(opts$output_dir, "summary", sprintf("morning_peak_events_%s_summary_by_day.csv", opts$year)))

  notes <- c(
    "Morning peak event detection by R.",
    sprintf("Input directory: %s", opts$input_dir),
    sprintf("Output directory: %s", opts$output_dir),
    sprintf("Year: %s", opts$year),
    "sunrise_ref: CVT MET shortwave 30 min first SW_in >= 20 W m^-2 from foundation table.",
    sprintf("pre_min_window: sunrise_ref + %.1f h to +%.1f h.", opts$pre_start_hr, opts$pre_end_hr),
    sprintf("peak_window: sunrise_ref + >%.1f h to +%.1f h.", opts$peak_start_hr, opts$peak_end_hr),
    "Event shape rule: profile-mean CO2 must show an overall decline from sunrise_ref to pre_min_time, then an overall rise from pre_min_time to peak_time.",
    "amp_ppm = profile_mean_CO2(peak_time) - profile_mean_CO2(pre_min_time).",
    "peak_by_diff = amp_ppm > 0; this is the threshold-free amplitude inventory entry point.",
    "event_5ppm = amp_ppm >= 5; event_10ppm = amp_ppm >= 10; these are provisional threshold flags, not the only event definition."
  )
  writeLines(notes, file.path(opts$output_dir, "summary", sprintf("morning_peak_events_%s_run_notes.txt", opts$year)))
  list(site = summary, day = day_summary)
}

run_self_test <- function() {
  opts <- defaults
  ap <- data.table(
    site = rep("CVT", 10),
    window_start = sprintf("2025-01-01 %02d:%02d:00", c(7, 8, 8, 9, 9, 10, 10, 11, 11, 12), c(30, 0, 30, 0, 30, 0, 30, 0, 30, 0)),
    date = "2025-01-01",
    co2_mean = c(450, 449, 445, 446, 447, 452, 456, 455, 450, 448)
  )
  qc <- data.table(site = "CVT", date = "2025-01-01", coverage_status = "full_day")
  sunrise <- data.table(date = "2025-01-01", sunrise_ref_sw = "2025-01-01 07:30:00")
  out <- build_site_day_events(ap, qc, sunrise, opts)
  stopifnot(nrow(out) == 1)
  stopifnot(isTRUE(out$event_10ppm))
  stopifnot(abs(out$amp_ppm - 11) < 1e-9)
  ap_bad <- copy(ap)
  ap_bad$co2_mean <- c(445, 446, 447, 448, 449, 452, 456, 455, 450, 448)
  out_bad <- build_site_day_events(ap_bad, qc, sunrise, opts)
  stopifnot(!isTRUE(out_bad$usable_for_event_rule))
  stopifnot(identical(out_bad$exclusion_reason, "pre_not_overall_decline"))
  cat("self-test ok\n")
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  if (opts$self_test) {
    run_self_test()
    quit(save = "no", status = 0)
  }

  ap <- must_read(file.path(opts$input_dir, sprintf("fixed_tower_ap_%s_30min.csv", opts$year)))
  qc <- must_read(file.path(opts$input_dir, sprintf("fixed_tower_ap_%s_daily_qc.csv", opts$year)))
  sunrise <- must_read(file.path(opts$input_dir, sprintf("cvt_sw_sunrise_%s.csv", opts$year)))

  site_day <- build_site_day_events(ap, qc, sunrise, opts)
  day_pair <- build_day_pair(site_day, opts$timezone)
  summary <- write_outputs(site_day, day_pair, opts)

  print(summary$site)
  print(summary$day)
  cat("Wrote outputs to ", opts$output_dir, "\n", sep = "")
}

main()
