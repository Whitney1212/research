#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

defaults <- list(
  event_dir = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025",
  foundation_dir = "E:/Dataset_Level1/MorningPeak/W2_2025_foundation",
  level0_root = "E:/Dataset_Level0",
  output_dir = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/event_typing",
  year = 2025L,
  timezone = "Asia/Shanghai",
  sync_threshold_min = 30
)

parse_args <- function(args) {
  opts <- defaults
  opts$self_test <- FALSE
  for (arg in args) {
    if (arg == "--self-test") {
      opts$self_test <- TRUE
    } else if (grepl("^--event-dir=", arg)) {
      opts$event_dir <- sub("^--event-dir=", "", arg)
    } else if (grepl("^--foundation-dir=", arg)) {
      opts$foundation_dir <- sub("^--foundation-dir=", "", arg)
    } else if (grepl("^--level0-root=", arg)) {
      opts$level0_root <- sub("^--level0-root=", "", arg)
    } else if (grepl("^--output-dir=", arg)) {
      opts$output_dir <- sub("^--output-dir=", "", arg)
    } else if (grepl("^--year=", arg)) {
      opts$year <- as.integer(sub("^--year=", "", arg))
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/build_morning_peak_event_types_2025.R [options]\n",
        "  --event-dir=E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025\n",
        "  --foundation-dir=E:/Dataset_Level1/MorningPeak/W2_2025_foundation\n",
        "  --level0-root=E:/Dataset_Level0\n",
        "  --output-dir=E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/event_typing\n",
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

floor_30min <- function(x, tz) {
  as.POSIXct(floor(as.numeric(x) / 1800) * 1800, origin = "1970-01-01", tz = tz)
}

as_num <- function(x) suppressWarnings(as.numeric(x))

as_bool <- function(x) {
  x == TRUE | toupper(as.character(x)) == "TRUE"
}

event_class <- function(cvt, mt) {
  fifelse(cvt & mt, "both",
    fifelse(cvt & !mt, "CVT_only",
      fifelse(!cvt & mt, "MT_only", "none")
    )
  )
}

event_class_with_unknown <- function(cvt_event, mt_event, cvt_usable, mt_usable) {
  fifelse(cvt_usable & mt_usable, event_class(cvt_event, mt_event),
    fifelse(cvt_usable & cvt_event & !mt_usable, "CVT_observed_MT_unknown",
      fifelse(mt_usable & mt_event & !cvt_usable, "MT_observed_CVT_unknown", "insufficient_data")
    )
  )
}

phase_class <- function(dt_min, threshold_min = 30) {
  fifelse(is.na(dt_min), "unclear",
    fifelse(abs(dt_min) <= threshold_min, "near_sync",
      fifelse(dt_min < -threshold_min, "CVT_leads", "MT_leads")
    )
  )
}

circ_mean <- function(deg) {
  deg <- deg[is.finite(deg)]
  if (length(deg) == 0) return(NA_real_)
  rad <- deg * pi / 180
  out <- atan2(mean(sin(rad)), mean(cos(rad))) * 180 / pi
  ifelse(out < 0, out + 360, out)
}

trapz <- function(x, y) {
  ok <- is.finite(x) & is.finite(y)
  x <- x[ok]
  y <- y[ok]
  if (length(x) < 2) return(NA_real_)
  ord <- order(x)
  x <- x[ord]
  y <- y[ord]
  sum(diff(x) * (head(y, -1) + tail(y, -1)) / 2)
}

read_toa5 <- function(path) {
  lines <- readLines(path, n = 2, warn = FALSE)
  if (length(lines) < 2) return(data.table())
  header <- as.character(fread(text = lines[2], header = FALSE))
  fread(path, skip = 4, header = FALSE, col.names = make.unique(header), colClasses = "character", fill = TRUE, showProgress = FALSE)
}

nearest_value <- function(dt, target_time, value_col) {
  if (is.na(target_time) || nrow(dt) == 0) return(NA_real_)
  idx <- which.min(abs(as.numeric(difftime(dt$window_start, target_time, units = "secs"))))
  dt[[value_col]][idx]
}

summarise_ap_context <- function(ap, site_day, tz) {
  ap[, `:=`(
    window_start = parse_time(window_start, tz),
    date = as.IDate(date),
    co2_mean = as_num(co2_mean)
  )]
  site_day[, `:=`(
    date = as.IDate(date),
    sunrise_ref_time = parse_time(sunrise_ref, tz),
    peak_time_posix = parse_time(peak_time, tz),
    pre_min_time_posix = parse_time(pre_min_time, tz),
    peak_co2 = as_num(peak_co2)
  )]

  rows <- vector("list", nrow(site_day))
  for (i in seq_len(nrow(site_day))) {
    s <- site_day[i]
    records <- ap[site == s$site & date == s$date & is.finite(co2_mean)]
    rel <- as.numeric(difftime(records$window_start, s$sunrise_ref_time, units = "hours"))
    night <- records[rel >= -3 & rel < 0]
    post <- records[!is.na(s$peak_time_posix) & window_start > s$peak_time_posix & rel <= 6.5]
    post_min <- if (nrow(post)) post[order(co2_mean, window_start)][1] else post[0]
    decline <- if (nrow(post_min) && is.finite(s$peak_co2)) s$peak_co2 - post_min$co2_mean else NA_real_
    hours <- if (nrow(post_min)) as.numeric(difftime(post_min$window_start, s$peak_time_posix, units = "hours")) else NA_real_
    rows[[i]] <- data.table(
      site = s$site,
      date = s$date,
      night_co2_background_ppm = if (nrow(night)) mean(night$co2_mean, na.rm = TRUE) else NA_real_,
      night_co2_max_ppm = if (nrow(night)) max(night$co2_mean, na.rm = TRUE) else NA_real_,
      sunrise_to_peak_lag_min = as.numeric(difftime(s$peak_time_posix, s$sunrise_ref_time, units = "mins")),
      rise_to_peak_lag_min = as.numeric(difftime(s$peak_time_posix, s$pre_min_time_posix, units = "mins")),
      post_min_time = if (nrow(post_min)) format(post_min$window_start, "%Y-%m-%d %H:%M:%S") else NA_character_,
      post_min_co2 = if (nrow(post_min)) post_min$co2_mean else NA_real_,
      post_decline_ppm = decline,
      post_decline_rate_ppm_h = if (is.finite(hours) && hours > 0) decline / hours else NA_real_
    )
  }
  rbindlist(rows)
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
      ta_low = c("TA_Avg(1)", "TA(1)"),
      ta_high = c("TA_Avg(5)", "TA(5)")
    )
  }
}

pick_field <- function(dt, candidates) {
  hit <- intersect(candidates, names(dt))
  if (length(hit) == 0) NA_character_ else hit[1]
}

read_met_30min <- function(level0_root, year, tz) {
  out <- list()
  for (site in c("CVT", "MT")) {
    files <- list.files(file.path(level0_root, site, "MET"), pattern = paste0(year), full.names = TRUE, recursive = TRUE)
    cfg <- met_config(site)
    parts <- vector("list", length(files))
    for (i in seq_along(files)) {
      dt <- read_toa5(files[i])
      fields <- c(
        ws = pick_field(dt, cfg$ws),
        wd = pick_field(dt, cfg$wd),
        ta_low = pick_field(dt, cfg$ta_low),
        ta_high = pick_field(dt, cfg$ta_high)
      )
      if (!("TIMESTAMP" %in% names(dt)) || any(is.na(fields))) next
      ts <- parse_time(dt$TIMESTAMP, tz)
      keep <- !is.na(ts) & as.integer(format(ts, "%Y")) == year
      if (!any(keep)) next
      parts[[i]] <- data.table(
        site = site,
        window_start = floor_30min(ts[keep], tz),
        wind_speed = as_num(dt[[fields[["ws"]]]][keep]),
        wind_dir = as_num(dt[[fields[["wd"]]]][keep]),
        temp_low = as_num(dt[[fields[["ta_low"]]]][keep]),
        temp_high = as_num(dt[[fields[["ta_high"]]]][keep])
      )
    }
    raw <- rbindlist(parts, fill = TRUE)
    if (nrow(raw) == 0) next
    out[[site]] <- raw[, .(
      wind_speed_mean = mean(wind_speed, na.rm = TRUE),
      wind_dir_circmean = circ_mean(wind_dir),
      temp_low_mean = mean(temp_low, na.rm = TRUE),
      temp_high_mean = mean(temp_high, na.rm = TRUE),
      temp_gradient_high_minus_low = mean(temp_high - temp_low, na.rm = TRUE),
      n_met = .N
    ), by = .(site, window_start)]
  }
  rbindlist(out, fill = TRUE)
}

summarise_met_context <- function(met, site_day, tz) {
  if (nrow(met) == 0) return(site_day[, .(site, date)][, `:=`(
    night_ws_mean = NA_real_, night_wd_circmean = NA_real_,
    morning_ws_mean = NA_real_, morning_wd_circmean = NA_real_,
    morning_temp_gradient_mean = NA_real_, peak_ws_nearest = NA_real_,
    peak_wd_nearest = NA_real_, peak_temp_gradient_nearest = NA_real_
  )])
  met[, date := as.IDate(format(window_start, "%Y-%m-%d"))]
  rows <- vector("list", nrow(site_day))
  for (i in seq_len(nrow(site_day))) {
    s <- site_day[i]
    records <- met[site == s$site & date == s$date]
    rel <- as.numeric(difftime(records$window_start, s$sunrise_ref_time, units = "hours"))
    night <- records[rel >= -3 & rel < 0]
    morning <- records[rel >= 0 & rel <= 4.5]
    rows[[i]] <- data.table(
      site = s$site,
      date = s$date,
      night_ws_mean = if (nrow(night)) mean(night$wind_speed_mean, na.rm = TRUE) else NA_real_,
      night_wd_circmean = if (nrow(night)) circ_mean(night$wind_dir_circmean) else NA_real_,
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

profile_map <- function(site) {
  if (site == "CVT") {
    data.table(valve_number = c(6L, 7L, 8L), level = c("c24", "c32", "c43"), height_m = c(24, 32, 43), low = "c24", top = "c43")
  } else {
    data.table(valve_number = 1:5, level = c("c8", "c13", "c17", "c20", "c29p5"), height_m = c(8, 13, 17, 20, 29.5), low = "c8", top = "c29p5")
  }
}

read_profile_30min <- function(level0_root, year, tz) {
  out <- list()
  for (site in c("CVT", "MT")) {
    files <- list.files(file.path(level0_root, site, "AP"), pattern = paste0("SiteAvg_", year), full.names = TRUE, recursive = TRUE)
    pmap <- profile_map(site)
    parts <- vector("list", length(files))
    for (i in seq_along(files)) {
      dt <- read_toa5(files[i])
      need <- c("TIMESTAMP", "valve_number", "diag_AP200_Avg", "CO2_Avg")
      if (!all(need %in% names(dt))) next
      ts <- parse_time(dt$TIMESTAMP, tz)
      valve <- as.integer(as_num(dt$valve_number))
      co2 <- as_num(dt$CO2_Avg)
      diag <- as.integer(as_num(dt$diag_AP200_Avg))
      keep <- !is.na(ts) & as.integer(format(ts, "%Y")) == year &
        valve %in% pmap$valve_number & diag == 0 & is.finite(co2) & co2 >= 200 & co2 <= 1200
      if (site == "CVT") {
        keep <- keep & !(valve == 7L & ts > parse_time("2025-03-23 17:53:30", tz))
      }
      if (!any(keep)) next
      parts[[i]] <- data.table(
        site = site,
        window_start = floor_30min(ts[keep], tz),
        date = as.IDate(format(ts[keep], "%Y-%m-%d")),
        valve_number = valve[keep],
        co2 = co2[keep]
      )
    }
    raw <- rbindlist(parts)
    if (nrow(raw) == 0) next
    raw <- pmap[, .(valve_number, level, height_m)][raw, on = "valve_number"]
    lev <- raw[, .(co2 = mean(co2, na.rm = TRUE)), by = .(site, window_start, date, level, height_m)]
    wide <- dcast(lev, site + window_start + date ~ level, value.var = "co2")
    low <- pmap$low[1]
    top <- pmap$top[1]
    wide[, `:=`(
      profile_gradient_index = get(low) - get(top),
      profile_low_level = low,
      profile_top_level = top
    )]
    out[[site]] <- wide
  }
  rbindlist(out, fill = TRUE)
}

read_foundation_profile_30min <- function(path, tz) {
  dt <- must_read(path)
  dt[, `:=`(
    window_start = parse_time(window_start, tz),
    date = as.IDate(date),
    profile_gradient_index = as_num(profile_gradient_index)
  )]
  level_cols <- intersect(c("c8", "c13", "c17", "c20", "c29p5", "c24", "c32", "c43"), names(dt))
  dt[, (level_cols) := lapply(.SD, as_num), .SDcols = level_cols]
  dt
}

add_column_proxy <- function(profile, site_day, tz) {
  maps <- rbindlist(lapply(c("CVT", "MT"), profile_map))[, .(site = rep(c("CVT", "MT"), c(3, 5)), level, height_m)]
  profile[, date := as.IDate(date)]
  profile <- merge(profile, unique(site_day[, .(site, date, sunrise_ref_time)]), by = c("site", "date"), all.x = TRUE)
  level_cols <- intersect(unique(maps$level), names(profile))
  long <- melt(profile, id.vars = c("site", "date", "window_start", "sunrise_ref_time"), measure.vars = level_cols, variable.name = "level", value.name = "co2", variable.factor = FALSE)
  long <- maps[long, on = c("site", "level")]
  long[, rel_hr := as.numeric(difftime(window_start, sunrise_ref_time, units = "hours"))]
  ref <- long[rel_hr >= -3 & rel_hr < 0, .(ref_co2 = mean(co2, na.rm = TRUE)), by = .(site, date, level)]
  long <- ref[long, on = c("site", "date", "level")]
  long[, anomaly := co2 - ref_co2]
  proxy <- long[, .(
    column_CO2_anomaly_proxy = trapz(height_m, anomaly),
    n_profile_levels = sum(is.finite(co2))
  ), by = .(site, date, window_start)]
  proxy[profile, on = c("site", "date", "window_start")]
}

summarise_profile_context <- function(profile, site_day, tz) {
  if (nrow(profile) == 0) return(site_day[, .(site, date)])
  rows <- vector("list", nrow(site_day))
  for (i in seq_len(nrow(site_day))) {
    s <- site_day[i]
    records <- profile[site == s$site & date == s$date]
    rel <- as.numeric(difftime(records$window_start, s$sunrise_ref_time, units = "hours"))
    end_time <- if (!is.na(s$peak_time_posix)) s$peak_time_posix else s$sunrise_ref_time + 4.5 * 3600
    sw <- records[rel >= -1 & window_start <= end_time & is.finite(profile_gradient_index)]
    sw[, prev_g := shift(profile_gradient_index)]
    crossed <- sw[profile_gradient_index <= 0 & prev_g > 0]
    already <- nrow(sw) > 0 && is.finite(sw$profile_gradient_index[1]) && sw$profile_gradient_index[1] <= 0
    switch_time <- if (nrow(crossed)) crossed$window_start[1] else if (already) sw$window_start[1] else as.POSIXct(NA)
    switch_status <- if (nrow(crossed)) "crossed_positive_to_nonpositive" else if (already) "already_nonpositive_at_window_start" else if (nrow(sw) == 0) "insufficient_profile" else "no_switch"
    g_sun <- nearest_value(records, s$sunrise_ref_time, "profile_gradient_index")
    g_peak <- nearest_value(records, s$peak_time_posix, "profile_gradient_index")
    p_sun <- nearest_value(records, s$sunrise_ref_time, "column_CO2_anomaly_proxy")
    p_peak <- nearest_value(records, s$peak_time_posix, "column_CO2_anomaly_proxy")
    rows[[i]] <- data.table(
      site = s$site,
      date = s$date,
      profile_switch_time = if (is.na(switch_time)) NA_character_ else format(switch_time, "%Y-%m-%d %H:%M:%S"),
      profile_switch_status = switch_status,
      profile_switch_lag_to_peak_min = as.numeric(difftime(switch_time, s$peak_time_posix, units = "mins")),
      profile_gradient_index_at_sunrise = g_sun,
      profile_gradient_index_at_pre_min = nearest_value(records, s$pre_min_time_posix, "profile_gradient_index"),
      profile_gradient_index_at_peak = g_peak,
      gradient_change_before_peak = g_peak - g_sun,
      column_CO2_anomaly_proxy_at_sunrise = p_sun,
      column_CO2_anomaly_proxy_at_peak = p_peak,
      column_CO2_anomaly_proxy_change_before_peak = p_peak - p_sun
    )
  }
  rbindlist(rows)
}

build_summary <- function(site_metrics) {
  site_metrics[, .(
    n_site_days = .N,
    n_usable = sum(usable_for_event_rule, na.rm = TRUE),
    n_event_10ppm = sum(event_10ppm, na.rm = TRUE),
    night_co2_background_mean = mean(night_co2_background_ppm, na.rm = TRUE),
    amp_ppm_mean = mean(amp_ppm, na.rm = TRUE),
    peak_hour_mean = mean(peak_hour, na.rm = TRUE),
    sunrise_to_peak_lag_min_mean = mean(sunrise_to_peak_lag_min, na.rm = TRUE),
    morning_ws_mean = mean(morning_ws_mean, na.rm = TRUE),
    morning_wd_circmean = circ_mean(morning_wd_circmean),
    morning_temp_gradient_mean = mean(morning_temp_gradient_mean, na.rm = TRUE),
    profile_gradient_at_peak_mean = mean(profile_gradient_index_at_peak, na.rm = TRUE),
    gradient_change_before_peak_mean = mean(gradient_change_before_peak, na.rm = TRUE),
    column_proxy_at_peak_mean = mean(column_CO2_anomaly_proxy_at_peak, na.rm = TRUE),
    post_decline_rate_ppm_h_mean = mean(post_decline_rate_ppm_h, na.rm = TRUE),
    profile_switch_before_peak_n = sum(profile_switch_lag_to_peak_min < 0, na.rm = TRUE)
  ), by = .(event_class, site)][order(event_class, site)]
}

build_threshold_tables <- function(site_day, class_col, opts) {
  sd <- copy(site_day)
  sd[, event_class := get(class_col)]
  sd[, c("event_class_10ppm", "event_class_5ppm") := NULL]

  value_cols <- setdiff(names(sd), c("site", "date", "event_class"))
  day_metrics <- dcast(sd, date + event_class ~ site, value.var = value_cols)

  both <- day_metrics[event_class == "both"]
  both[, `:=`(
    dt_peak_cvt_minus_mt_min = as.numeric(difftime(parse_time(peak_time_CVT, opts$timezone), parse_time(peak_time_MT, opts$timezone), units = "mins")),
    dt_rise_cvt_minus_mt_min = as.numeric(difftime(parse_time(pre_min_time_CVT, opts$timezone), parse_time(pre_min_time_MT, opts$timezone), units = "mins"))
  )]
  both[, `:=`(
    phase_class_peak = phase_class(dt_peak_cvt_minus_mt_min, opts$sync_threshold_min),
    phase_class_rise = phase_class(dt_rise_cvt_minus_mt_min, opts$sync_threshold_min)
  )]
  both[, lead_lag_class := fifelse(phase_class_peak == phase_class_rise, phase_class_peak, "unclear")]

  list(
    site_day = sd,
    day_metrics = day_metrics,
    both = both,
    counts = day_metrics[, .N, by = event_class][order(event_class)],
    summary = build_summary(sd[event_class %in% c("CVT_only", "MT_only", "both", "none")]),
    lead_lag_counts = both[, .N, by = .(lead_lag_class, phase_class_peak, phase_class_rise)][order(lead_lag_class, phase_class_peak, phase_class_rise)]
  )
}

one_site_missing <- function(day_metrics) {
  xor(as_bool(day_metrics$usable_for_event_rule_CVT), as_bool(day_metrics$usable_for_event_rule_MT))
}

with_threshold <- function(day_metrics, threshold_ppm) {
  out <- copy(day_metrics)
  out[, threshold_ppm := threshold_ppm]
  setcolorder(out, c("threshold_ppm", setdiff(names(out), "threshold_ppm")))
  out
}

build_fixed_collections <- function(site_day, threshold_10, threshold_5) {
  paired_long <- rbindlist(list(
    with_threshold(threshold_10$day_metrics, 10L),
    with_threshold(threshold_5$day_metrics, 5L)
  ), fill = TRUE)

  site_valid_events <- copy(site_day[usable_for_event_rule == TRUE])
  site_valid_events[, collection := "site_valid_events"]
  setcolorder(site_valid_events, c("collection", setdiff(names(site_valid_events), "collection")))

  paired_valid_typing <- copy(paired_long[event_class %in% c("CVT_only", "MT_only", "both", "none")])
  paired_valid_typing[, collection := "paired_valid_typing"]
  setcolorder(paired_valid_typing, c("collection", setdiff(names(paired_valid_typing), "collection")))

  paired_missing_one_site <- copy(paired_long[one_site_missing(paired_long)])
  paired_missing_one_site[, `:=`(
    collection = "paired_missing_one_site",
    available_site = fifelse(as_bool(usable_for_event_rule_CVT), "CVT", "MT"),
    missing_site = fifelse(as_bool(usable_for_event_rule_CVT), "MT", "CVT")
  )]
  setcolorder(paired_missing_one_site, c(
    "collection", "threshold_ppm", "date", "available_site", "missing_site", "event_class",
    setdiff(names(paired_missing_one_site), c("collection", "threshold_ppm", "date", "available_site", "missing_site", "event_class"))
  ))

  list(
    site_valid_events = site_valid_events,
    paired_valid_typing = paired_valid_typing,
    paired_missing_one_site = paired_missing_one_site
  )
}

transition_meaning <- function(class_5, class_10) {
  fcase(
    class_5 == "none" & class_10 == "none", "stable_no_event",
    class_5 == "CVT_only" & class_10 == "CVT_only", "stable_CVT_type",
    class_5 == "MT_only" & class_10 == "MT_only", "stable_MT_type_review",
    class_5 == "both" & class_10 == "both", "stable_synchronous_type",
    class_5 == "both" & class_10 == "CVT_only", "weak_sync_strong_CVT",
    class_5 == "both" & class_10 == "MT_only", "weak_sync_strong_MT_review",
    class_5 == "CVT_only" & class_10 == "both", "weak_CVT_strong_synchronous",
    class_5 == "MT_only" & class_10 == "both", "weak_MT_strong_synchronous_review",
    class_5 == "CVT_only" & class_10 == "none", "weak_CVT_only",
    class_5 == "MT_only" & class_10 == "none", "weak_MT_only_review",
    class_5 == "both" & class_10 == "none", "weak_synchronous_only",
    class_5 == "none" & class_10 != "none", "check_10ppm_without_5ppm",
    default = "site_type_switch_check"
  )
}

build_upgrade_matrix <- function(threshold_5, threshold_10) {
  valid_classes <- c("none", "CVT_only", "both", "MT_only")
  t5 <- threshold_5$day_metrics[event_class %in% valid_classes, .(date, event_class_5ppm = event_class)]
  t10 <- threshold_10$day_metrics[event_class %in% valid_classes, .(
    date,
    event_class_10ppm = event_class,
    amp_ppm_CVT,
    amp_ppm_MT,
    peak_time_CVT,
    peak_time_MT
  )]
  day_transitions <- merge(t5, t10, by = "date")
  day_transitions[, `:=`(
    transition_id = paste(event_class_5ppm, event_class_10ppm, sep = "__to__"),
    transition_meaning = transition_meaning(event_class_5ppm, event_class_10ppm)
  )]
  setcolorder(day_transitions, c(
    "date", "event_class_5ppm", "event_class_10ppm", "transition_id", "transition_meaning",
    setdiff(names(day_transitions), c("date", "event_class_5ppm", "event_class_10ppm", "transition_id", "transition_meaning"))
  ))

  grid <- CJ(event_class_5ppm = valid_classes, event_class_10ppm = valid_classes, sorted = FALSE)
  grid[, `:=`(
    class_5_order = match(event_class_5ppm, valid_classes),
    class_10_order = match(event_class_10ppm, valid_classes)
  )]
  counts <- day_transitions[, .(n_days = .N), by = .(event_class_5ppm, event_class_10ppm)]
  matrix <- counts[grid, on = c("event_class_5ppm", "event_class_10ppm")]
  matrix[is.na(n_days), n_days := 0L]
  matrix[, `:=`(
    n_paired_valid_days = nrow(day_transitions),
    prop_paired_valid_days = n_days / nrow(day_transitions),
    transition_meaning = transition_meaning(event_class_5ppm, event_class_10ppm)
  )]
  setorder(matrix, class_5_order, class_10_order)
  matrix[, c("class_5_order", "class_10_order") := NULL]

  list(matrix = matrix, day_transitions = day_transitions)
}

run_self_test <- function() {
  stopifnot(identical(event_class(c(TRUE, TRUE, FALSE, FALSE), c(TRUE, FALSE, TRUE, FALSE)), c("both", "CVT_only", "MT_only", "none")))
  stopifnot(identical(event_class_with_unknown(c(TRUE, FALSE), c(FALSE, TRUE), c(TRUE, FALSE), c(FALSE, TRUE)), c("CVT_observed_MT_unknown", "MT_observed_CVT_unknown")))
  demo <- data.table(usable_for_event_rule_CVT = c(TRUE, FALSE, TRUE, FALSE), usable_for_event_rule_MT = c(FALSE, TRUE, TRUE, FALSE))
  stopifnot(identical(one_site_missing(demo), c(TRUE, TRUE, FALSE, FALSE)))
  stopifnot(identical(transition_meaning(c("none", "both"), c("CVT_only", "CVT_only")), c("check_10ppm_without_5ppm", "weak_sync_strong_CVT")))
  stopifnot(identical(phase_class(c(-60, 60, 0, NA_real_), 30), c("CVT_leads", "MT_leads", "near_sync", "unclear")))
  stopifnot(abs(circ_mean(c(350, 10)) - 360) < 1e-9 || abs(circ_mean(c(350, 10))) < 1e-9)
  cat("self-test ok\n")
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  if (opts$self_test) {
    run_self_test()
    quit(save = "no", status = 0)
  }

  site_day_path <- file.path(opts$event_dir, "metrics", sprintf("morning_peak_events_%s_site_day.csv", opts$year))
  day_pair_path <- file.path(opts$event_dir, "metrics", sprintf("morning_peak_events_%s_day_pair.csv", opts$year))
  ap_path <- file.path(opts$foundation_dir, sprintf("fixed_tower_ap_%s_30min.csv", opts$year))

  site_day <- must_read(site_day_path)
  day_pair <- must_read(day_pair_path)
  ap <- must_read(ap_path)

  day_pair[, `:=`(
    date = as.IDate(date),
    event_5ppm_CVT = as_bool(event_5ppm_CVT),
    event_5ppm_MT = as_bool(event_5ppm_MT),
    event_10ppm_CVT = as_bool(event_10ppm_CVT),
    event_10ppm_MT = as_bool(event_10ppm_MT),
    usable_for_event_rule_CVT = as_bool(usable_for_event_rule_CVT),
    usable_for_event_rule_MT = as_bool(usable_for_event_rule_MT)
  )]
  day_pair[, event_class_10ppm := event_class_with_unknown(
    event_10ppm_CVT, event_10ppm_MT,
    usable_for_event_rule_CVT, usable_for_event_rule_MT
  )]
  day_pair[, event_class_5ppm := event_class_with_unknown(
    event_5ppm_CVT, event_5ppm_MT,
    usable_for_event_rule_CVT, usable_for_event_rule_MT
  )]
  site_day[, date := as.IDate(date)]
  site_day[, `:=`(
    usable_for_event_rule = as_bool(usable_for_event_rule),
    event_5ppm = as_bool(event_5ppm),
    event_10ppm = as_bool(event_10ppm),
    amp_ppm = as_num(amp_ppm),
    pre_min_co2 = as_num(pre_min_co2),
    peak_co2 = as_num(peak_co2),
    n_pre_windows = as.integer(as_num(n_pre_windows)),
    n_peak_windows = as.integer(as_num(n_peak_windows))
  )]
  site_day <- day_pair[, .(date, event_class_10ppm, event_class_5ppm)][site_day, on = "date"]
  site_day[, peak_hour := as.numeric(substr(peak_time, 12, 13)) + as.numeric(substr(peak_time, 15, 16)) / 60]

  ap_context <- summarise_ap_context(ap, site_day, opts$timezone)
  site_day <- ap_context[site_day, on = c("site", "date")]

  cat("Reading MET Level0 and summarising 30 min...\n")
  met <- read_met_30min(opts$level0_root, opts$year, opts$timezone)
  met_context <- summarise_met_context(met, site_day, opts$timezone)
  site_day <- met_context[site_day, on = c("site", "date")]

  profile_qc_path <- file.path(opts$foundation_dir, sprintf("fixed_tower_ap_profile_%s_30min.csv", opts$year))
  if (file.exists(profile_qc_path)) {
    cat("Reading AP profile QC foundation and building proxies...\n")
    profile_30 <- read_foundation_profile_30min(profile_qc_path, opts$timezone)
  } else {
    cat("Reading AP profile Level0 and building proxies...\n")
    profile_30 <- read_profile_30min(opts$level0_root, opts$year, opts$timezone)
  }
  profile_30 <- add_column_proxy(profile_30, site_day, opts$timezone)
  profile_context <- summarise_profile_context(profile_30, site_day, opts$timezone)
  site_day <- profile_context[site_day, on = c("site", "date")]

  threshold_10 <- build_threshold_tables(site_day, "event_class_10ppm", opts)
  threshold_5 <- build_threshold_tables(site_day, "event_class_5ppm", opts)
  collections <- build_fixed_collections(site_day, threshold_10, threshold_5)
  upgrade <- build_upgrade_matrix(threshold_5, threshold_10)

  out_dirs <- file.path(opts$output_dir, c("tables", "summary", "qc", "collections"))
  invisible(lapply(out_dirs, dir.create, recursive = TRUE, showWarnings = FALSE))
  fwrite(collections$site_valid_events, file.path(opts$output_dir, "collections", sprintf("site_valid_events_%s.csv", opts$year)))
  fwrite(collections$paired_valid_typing, file.path(opts$output_dir, "collections", sprintf("paired_valid_typing_%s.csv", opts$year)))
  fwrite(collections$paired_missing_one_site, file.path(opts$output_dir, "collections", sprintf("paired_missing_one_site_%s.csv", opts$year)))
  fwrite(upgrade$matrix, file.path(opts$output_dir, "summary", sprintf("event_class_5to10_upgrade_matrix_%s.csv", opts$year)))
  fwrite(upgrade$day_transitions, file.path(opts$output_dir, "tables", sprintf("event_class_5to10_day_transitions_%s.csv", opts$year)))
  fwrite(threshold_10$day_metrics, file.path(opts$output_dir, "tables", sprintf("event_class_%s_day_metrics.csv", opts$year)))
  fwrite(threshold_10$site_day, file.path(opts$output_dir, "tables", sprintf("event_class_%s_site_day_metrics.csv", opts$year)))
  fwrite(threshold_5$day_metrics, file.path(opts$output_dir, "tables", sprintf("event_class_5ppm_%s_day_metrics.csv", opts$year)))
  fwrite(threshold_5$site_day, file.path(opts$output_dir, "tables", sprintf("event_class_5ppm_%s_site_day_metrics.csv", opts$year)))
  fwrite(profile_30, file.path(opts$output_dir, "tables", sprintf("profile_proxy_%s_30min.csv", opts$year)))
  fwrite(threshold_10$summary, file.path(opts$output_dir, "summary", sprintf("event_class_%s_summary_by_class_site.csv", opts$year)))
  fwrite(threshold_10$counts, file.path(opts$output_dir, "summary", sprintf("event_class_%s_counts.csv", opts$year)))
  fwrite(threshold_10$both, file.path(opts$output_dir, "tables", sprintf("both_10ppm_lead_lag_%s.csv", opts$year)))
  fwrite(threshold_10$lead_lag_counts,
    file.path(opts$output_dir, "summary", sprintf("both_10ppm_lead_lag_%s_counts.csv", opts$year))
  )
  fwrite(threshold_5$summary, file.path(opts$output_dir, "summary", sprintf("event_class_5ppm_%s_summary_by_class_site.csv", opts$year)))
  fwrite(threshold_5$counts, file.path(opts$output_dir, "summary", sprintf("event_class_5ppm_%s_counts.csv", opts$year)))
  fwrite(threshold_5$both, file.path(opts$output_dir, "tables", sprintf("both_5ppm_lead_lag_%s.csv", opts$year)))
  fwrite(threshold_5$lead_lag_counts,
    file.path(opts$output_dir, "summary", sprintf("both_5ppm_lead_lag_%s_counts.csv", opts$year))
  )

  notes <- c(
    "Morning peak event typing and AP proxy integration.",
    sprintf("Input event dir: %s", opts$event_dir),
    sprintf("Output dir: %s", opts$output_dir),
    "Fixed collection files: collections/site_valid_events_YEAR.csv, collections/paired_valid_typing_YEAR.csv, collections/paired_missing_one_site_YEAR.csv.",
    "site_valid_events: single-tower usable days for single-site frequency, seasonality, and long-term occurrence.",
    "paired_valid_typing: both towers usable; only CVT_only, MT_only, both, none; use for dual-tower mechanism typing.",
    "paired_missing_one_site: exactly one tower usable; documents gaps and is excluded from dual-tower mechanism judgment.",
    "5-to-10 upgrade matrix uses paired_valid_typing dates only; paired_missing_one_site is excluded.",
    "event_class legacy files use 10 ppm threshold: CVT_only, MT_only, both, none, observed_unknown labels, insufficient_data.",
    "event_class_5ppm files use the same rule with 5 ppm threshold.",
    "observed_unknown labels mark one tower reaching threshold while the other tower is not usable; these days are kept in counts and day metrics but excluded from summary_by_class_site judgment summaries.",
    "night CO2 background: AP mean over sunrise_ref -3 h to sunrise_ref.",
    "meteorology: CVT uses WS_43m/WD_43m and Ta_43m_Avg-Ta_1m_Avg; MT uses WS_5_Avg/WD_5 and TA_Avg(5)-TA_Avg(1).",
    "rise_time proxy for lead-lag is pre_min_time.",
    sprintf("near_sync threshold for lead-lag: abs(delta_t) <= %s min.", opts$sync_threshold_min),
    "profile_gradient_index = low level CO2 - top level CO2; CVT c24-c43, MT c8-c29p5.",
    "column_CO2_anomaly_proxy uses trapezoidal integration over available AP profile heights relative to sunrise_ref -3 h to sunrise_ref level means.",
    "No storage flux is calculated or named."
  )
  writeLines(notes, file.path(opts$output_dir, "summary", sprintf("event_typing_%s_run_notes.txt", opts$year)))

  cat("10 ppm event classes:\n")
  print(threshold_10$counts)
  cat("10 ppm both lead-lag:\n")
  print(threshold_10$both[, .N, by = lead_lag_class][order(lead_lag_class)])
  cat("5 ppm event classes:\n")
  print(threshold_5$counts)
  cat("5 ppm both lead-lag:\n")
  print(threshold_5$both[, .N, by = lead_lag_class][order(lead_lag_class)])
  cat("5 ppm to 10 ppm upgrade matrix:\n")
  print(upgrade$matrix)
  cat("Wrote outputs to ", opts$output_dir, "\n", sep = "")
}

main()
