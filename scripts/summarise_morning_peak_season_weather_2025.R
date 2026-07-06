#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

defaults <- list(
  class_path = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/intensity_classes/event_intensity_class_0_3_10_2025_site_day.csv",
  level0_root = "E:/Dataset_Level0",
  output_dir = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/season_weather_groups",
  year = 2025L,
  timezone = "Asia/Shanghai"
)

parse_args <- function(args) {
  opts <- defaults
  opts$self_test <- FALSE
  for (arg in args) {
    if (arg == "--self-test") {
      opts$self_test <- TRUE
    } else if (grepl("^--class-path=", arg)) {
      opts$class_path <- sub("^--class-path=", "", arg)
    } else if (grepl("^--level0-root=", arg)) {
      opts$level0_root <- sub("^--level0-root=", "", arg)
    } else if (grepl("^--output-dir=", arg)) {
      opts$output_dir <- sub("^--output-dir=", "", arg)
    } else if (grepl("^--year=", arg)) {
      opts$year <- as.integer(sub("^--year=", "", arg))
    } else if (grepl("^--timezone=", arg)) {
      opts$timezone <- sub("^--timezone=", "", arg)
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/summarise_morning_peak_season_weather_2025.R [options]\n",
        "  --class-path=E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/intensity_classes/event_intensity_class_0_3_10_2025_site_day.csv\n",
        "  --level0-root=E:/Dataset_Level0\n",
        "  --output-dir=E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/season_weather_groups\n",
        "  --year=2025\n",
        "  --timezone=Asia/Shanghai\n",
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
  fread(path, encoding = "UTF-8")
}

parse_time <- function(x, tz) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = tz)
}

floor_30min <- function(x, tz) {
  as.POSIXct(floor(as.numeric(x) / 1800) * 1800, origin = "1970-01-01", tz = tz)
}

as_num <- function(x) suppressWarnings(as.numeric(x))

season_from_date <- function(x) {
  m <- as.integer(format(as.IDate(x), "%m"))
  fifelse(m %in% c(3L, 4L, 5L), "spring",
    fifelse(m %in% c(6L, 7L, 8L), "summer",
      fifelse(m %in% c(9L, 10L, 11L), "autumn", "winter")
    )
  )
}

assign_tercile <- function(x) {
  out <- rep(NA_character_, length(x))
  ok <- is.finite(x)
  if (!any(ok)) return(out)
  r <- frank(x[ok], ties.method = "average")
  p <- (r - 0.5) / length(r)
  out[ok] <- fifelse(p <= 1 / 3, "low",
    fifelse(p <= 2 / 3, "middle", "high")
  )
  out
}

circ_mean <- function(deg) {
  deg <- deg[is.finite(deg)]
  if (length(deg) == 0) return(NA_real_)
  rad <- deg * pi / 180
  out <- atan2(mean(sin(rad)), mean(cos(rad))) * 180 / pi
  ifelse(out < 0, out + 360, out)
}

read_toa5 <- function(path) {
  lines <- readLines(path, n = 2, warn = FALSE)
  if (length(lines) < 2) return(data.table())
  header <- as.character(fread(text = lines[2], header = FALSE))
  fread(path, skip = 4, header = FALSE, col.names = make.unique(header), colClasses = "character", fill = TRUE, showProgress = FALSE)
}

pick_field <- function(dt, candidates) {
  hit <- intersect(candidates, names(dt))
  if (length(hit) == 0) NA_character_ else hit[1]
}

met_config <- function(site) {
  if (site == "CVT") {
    list(
      ws = c("WS_43m", "WS_43m_Avg"),
      wd = c("WD_43m", "WD_43m_Avg"),
      ta_low = c("Ta_1m_Avg", "Ta_1m"),
      ta_high = c("Ta_43m_Avg", "Ta_43m")
    )
  } else {
    list(
      ws = c("WS_5_Avg", "WS_5"),
      wd = c("WD_5", "WD_5_Avg"),
      ta_low = c("TA_Avg(1)", "TA(1)", "TA_1"),
      ta_high = c("TA_Avg(5)", "TA(5)", "TA_5")
    )
  }
}

read_met_30min <- function(level0_root, year, tz) {
  out <- list()
  for (site in c("CVT", "MT")) {
    files <- list.files(file.path(level0_root, site, "MET"), pattern = paste0(year), full.names = TRUE, recursive = TRUE)
    cfg <- met_config(site)
    parts <- vector("list", length(files))
    for (i in seq_along(files)) {
      raw <- read_toa5(files[i])
      fields <- c(
        ws = pick_field(raw, cfg$ws),
        wd = pick_field(raw, cfg$wd),
        ta_low = pick_field(raw, cfg$ta_low),
        ta_high = pick_field(raw, cfg$ta_high)
      )
      if (!("TIMESTAMP" %in% names(raw)) || any(is.na(fields))) next
      ts <- parse_time(raw$TIMESTAMP, tz)
      keep <- !is.na(ts) & as.integer(format(ts, "%Y")) == year
      if (!any(keep)) next
      ws <- as_num(raw[[fields[["ws"]]]][keep])
      wd <- as_num(raw[[fields[["wd"]]]][keep])
      ta_low <- as_num(raw[[fields[["ta_low"]]]][keep])
      ta_high <- as_num(raw[[fields[["ta_high"]]]][keep])
      ws[!is.finite(ws) | ws < 0 | ws > 60] <- NA_real_
      wd[!is.finite(wd) | wd < 0 | wd > 360] <- NA_real_
      parts[[i]] <- data.table(
        site = site,
        window_start = floor_30min(ts[keep], tz),
        wind_speed = ws,
        wind_dir = wd,
        temp_low = ta_low,
        temp_high = ta_high
      )
    }
    site_raw <- rbindlist(parts, fill = TRUE)
    if (nrow(site_raw) == 0) next
    out[[site]] <- site_raw[, .(
      wind_speed_mean = mean(wind_speed, na.rm = TRUE),
      wind_dir_circmean = circ_mean(wind_dir),
      temp_gradient_high_minus_low = mean(temp_high - temp_low, na.rm = TRUE)
    ), by = .(site, window_start)]
  }
  rbindlist(out, fill = TRUE)
}

nearest_value <- function(dt, target_time, value_col) {
  if (is.na(target_time) || nrow(dt) == 0) return(NA_real_)
  idx <- which.min(abs(as.numeric(difftime(dt$window_start, target_time, units = "secs"))))
  dt[[value_col]][idx]
}

summarise_met_context <- function(met, site_day) {
  met[, date := as.IDate(format(window_start, "%Y-%m-%d"))]
  rows <- vector("list", nrow(site_day))
  for (i in seq_len(nrow(site_day))) {
    s <- site_day[i]
    records <- met[site == s$site & date == s$date]
    rel <- as.numeric(difftime(records$window_start, s$sunrise_ref_time, units = "hours"))
    morning <- records[rel >= 0 & rel <= 4.5]
    rows[[i]] <- data.table(
      site = s$site,
      date = s$date,
      morning_ws_mean = if (nrow(morning)) mean(morning$wind_speed_mean, na.rm = TRUE) else NA_real_,
      morning_wd_circmean = if (nrow(morning)) circ_mean(morning$wind_dir_circmean) else NA_real_,
      morning_temp_gradient_mean = if (nrow(morning)) mean(morning$temp_gradient_high_minus_low, na.rm = TRUE) else NA_real_,
      peak_ws_nearest = nearest_value(records, s$peak_time_posix, "wind_speed_mean"),
      peak_wd_nearest = nearest_value(records, s$peak_time_posix, "wind_dir_circmean"),
      peak_temp_gradient_nearest = nearest_value(records, s$peak_time_posix, "temp_gradient_high_minus_low")
    )
  }
  rbindlist(rows)
}

summarise_groups <- function(dt, group_col, group_type) {
  site_total <- dt[, .(site_total_events = .N), by = site]
  out <- dt[!is.na(get(group_col)), .(
    event_days = .N,
    weak_days = sum(intensity_class_0_3_10 == "weak", na.rm = TRUE),
    moderate_days = sum(intensity_class_0_3_10 == "moderate", na.rm = TRUE),
    strong_days = sum(intensity_class_0_3_10 == "strong", na.rm = TRUE),
    weak_prop_in_group = mean(intensity_class_0_3_10 == "weak", na.rm = TRUE),
    moderate_prop_in_group = mean(intensity_class_0_3_10 == "moderate", na.rm = TRUE),
    strong_prop_in_group = mean(intensity_class_0_3_10 == "strong", na.rm = TRUE),
    amp_median_ppm = median(amp_ppm, na.rm = TRUE),
    amp_p75_ppm = as.numeric(quantile(amp_ppm, probs = 0.75, na.rm = TRUE))
  ), by = .(site, group = get(group_col))]
  out[, group_type := group_type]
  out <- site_total[out, on = "site"]
  out[, share_of_site_events := event_days / site_total_events]
  setcolorder(out, c(
    "group_type", "site", "group", "event_days", "site_total_events", "share_of_site_events",
    "weak_days", "moderate_days", "strong_days",
    "weak_prop_in_group", "moderate_prop_in_group", "strong_prop_in_group",
    "amp_median_ppm", "amp_p75_ppm"
  ))
  out[]
}

summarise_ranges <- function(dt, value_col, group_col, group_type) {
  out <- dt[is.finite(get(value_col)) & !is.na(get(group_col)), .(
    n_days = .N,
    value_q05 = as.numeric(quantile(get(value_col), probs = 0.05, na.rm = TRUE)),
    value_q25 = as.numeric(quantile(get(value_col), probs = 0.25, na.rm = TRUE)),
    value_median = median(get(value_col), na.rm = TRUE),
    value_q75 = as.numeric(quantile(get(value_col), probs = 0.75, na.rm = TRUE)),
    value_q95 = as.numeric(quantile(get(value_col), probs = 0.95, na.rm = TRUE))
  ), by = .(site, group = get(group_col))]
  out[, `:=`(group_type = group_type, value_col = value_col)]
  setcolorder(out, c("group_type", "value_col", "site", "group", "n_days", "value_q05", "value_q25", "value_median", "value_q75", "value_q95"))
  out[]
}

run_self_test <- function() {
  demo_dates <- as.IDate(c("2025-01-15", "2025-04-15", "2025-07-15", "2025-10-15"))
  stopifnot(identical(season_from_date(demo_dates), c("winter", "spring", "summer", "autumn")))
  stopifnot(identical(assign_tercile(c(1, 2, 3, 4, 5, 6)), c("low", "low", "middle", "middle", "high", "high")))
  stopifnot(all(is.na(assign_tercile(c(NA_real_, NA_real_)))))
  cat("self-test ok\n")
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  if (opts$self_test) {
    run_self_test()
    quit(save = "no", status = 0)
  }

  class_dt <- must_read(opts$class_path)
  class_dt[, date := as.IDate(date)]
  class_dt[, usable_for_event_rule := usable_for_event_rule == TRUE | toupper(as.character(usable_for_event_rule)) == "TRUE"]
  class_dt <- class_dt[usable_for_event_rule == TRUE]
  class_dt[, `:=`(
    sunrise_ref_time = parse_time(sunrise_ref, opts$timezone),
    peak_time_posix = parse_time(peak_time, opts$timezone)
  )]

  met <- read_met_30min(opts$level0_root, opts$year, opts$timezone)
  met_context <- summarise_met_context(met, class_dt)
  dt <- merge(class_dt, met_context, by = c("site", "date"), all.x = TRUE)

  dt[, season := season_from_date(date)]
  dt[, morning_ws_group := assign_tercile(morning_ws_mean), by = site]
  dt[, peak_ws_group := assign_tercile(peak_ws_nearest), by = site]
  dt[, morning_temp_gradient_group := assign_tercile(morning_temp_gradient_mean), by = site]
  dt[, peak_temp_gradient_group := assign_tercile(peak_temp_gradient_nearest), by = site]

  dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)

  season_summary <- summarise_groups(dt, "season", "season")
  weather_summary <- rbindlist(list(
    summarise_groups(dt, "morning_ws_group", "morning_ws_tercile"),
    summarise_groups(dt, "peak_ws_group", "peak_ws_tercile"),
    summarise_groups(dt, "morning_temp_gradient_group", "morning_temp_gradient_tercile"),
    summarise_groups(dt, "peak_temp_gradient_group", "peak_temp_gradient_tercile")
  ), fill = TRUE)
  weather_ranges <- rbindlist(list(
    summarise_ranges(dt, "morning_ws_mean", "morning_ws_group", "morning_ws_tercile"),
    summarise_ranges(dt, "peak_ws_nearest", "peak_ws_group", "peak_ws_tercile"),
    summarise_ranges(dt, "morning_temp_gradient_mean", "morning_temp_gradient_group", "morning_temp_gradient_tercile"),
    summarise_ranges(dt, "peak_temp_gradient_nearest", "peak_temp_gradient_group", "peak_temp_gradient_tercile")
  ), fill = TRUE)

  fwrite(dt, file.path(opts$output_dir, sprintf("event_days_with_season_weather_groups_%s.csv", opts$year)))
  fwrite(season_summary, file.path(opts$output_dir, sprintf("season_intensity_summary_%s_by_site.csv", opts$year)))
  fwrite(weather_summary, file.path(opts$output_dir, sprintf("weather_group_intensity_summary_%s_by_site.csv", opts$year)))
  fwrite(weather_ranges, file.path(opts$output_dir, sprintf("weather_group_value_ranges_%s_by_site.csv", opts$year)))

  notes <- c(
    "Morning peak season and weather grouping under the current fixed rule.",
    sprintf("Class input: %s", opts$class_path),
    sprintf("MET Level0 root: %s", opts$level0_root),
    sprintf("Output dir: %s", opts$output_dir),
    "Current fixed rule makes usable days effectively coincide with amp>0 event days; summaries therefore describe event-day composition rather than event-vs-non-event frequency.",
    "Intensity classes are fixed as weak: 0-3 ppm, moderate: 3-10 ppm, strong: >=10 ppm.",
    "Seasons use DJF/MAM/JJA/SON.",
    "Weather groups use site-specific terciles because CVT and MT meteorological heights differ.",
    "Weather variables are rebuilt directly from Level0 MET as morning_ws_mean, peak_ws_nearest, morning_temp_gradient_mean, and peak_temp_gradient_nearest.",
    "Wind-direction values are rebuilt too, but grouped summaries here focus on wind speed and temperature-gradient structure."
  )
  writeLines(notes, file.path(opts$output_dir, sprintf("season_weather_grouping_%s_run_notes.txt", opts$year)))

  cat("Season summary:\n")
  print(season_summary)
  cat("Weather summary (first 24 rows):\n")
  print(weather_summary[1:min(.N, 24L)])
  cat("Wrote outputs to ", opts$output_dir, "\n", sep = "")
}

main()
