#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

year <- 2025L
tz_local <- "Asia/Shanghai"
out_dir <- "E:/Dataset_Level1/MorningPeak/W2_2025_foundation"

site_inputs <- list(
  CVT = list(
    path = "E:/Dataset_Level1/CVT/AP/20240704-20260622/CVT_AP_profile_cycle_after_qc_20241112_20260622.csv",
    levels = c("c24", "c32", "c43"),
    low = "c24",
    top = "c43"
  ),
  MT = list(
    path = "E:/Dataset_Level1/MT/AP/20240704-20260622/MT_AP_profile_cycle_after_qc_20240704_20260622.csv",
    levels = c("c8", "c13", "c17", "c20", "c29p5"),
    low = "c8",
    top = "c29p5"
  )
)

parse_time <- function(x) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

floor_30min <- function(x) {
  as.POSIXct(floor(as.numeric(x) / 1800) * 1800, origin = "1970-01-01", tz = tz_local)
}

read_site <- function(site, cfg) {
  dt <- fread(cfg$path, encoding = "UTF-8", colClasses = "character")
  dt[, cycle_time := parse_time(cycle_time)]
  dt[, qc_keep_cycle := toupper(qc_keep_cycle) == "TRUE"]
  dt <- dt[qc_keep_cycle == TRUE & as.integer(format(cycle_time, "%Y")) == year]
  dt[, `:=`(
    site = site,
    window_start = floor_30min(cycle_time),
    date = as.IDate(format(cycle_time, "%Y-%m-%d"))
  )]
  dt[, (cfg$levels) := lapply(.SD, as.numeric), .SDcols = cfg$levels]

  long <- melt(
    dt,
    id.vars = c("site", "window_start", "date"),
    measure.vars = cfg$levels,
    variable.name = "level",
    value.name = "co2",
    variable.factor = FALSE
  )[is.finite(co2)]

  ap <- long[, .(
    co2_mean = mean(co2),
    co2_sd = sd(co2),
    n_total = .N,
    n_diag0 = .N,
    n_valid = .N,
    n_valves = uniqueN(level),
    valves = paste(sort(unique(level)), collapse = ",")
  ), by = .(site, window_start, date)]

  prof <- dcast(
    long[, .(co2_mean = mean(co2), n = .N), by = .(site, window_start, date, level)],
    site + window_start + date ~ level,
    value.var = "co2_mean"
  )
  prof[, `:=`(
    profile_gradient_index = get(cfg$low) - get(cfg$top),
    profile_low_level = cfg$low,
    profile_top_level = cfg$top
  )]

  list(ap = ap, profile = prof)
}

parts <- lapply(names(site_inputs), function(site) read_site(site, site_inputs[[site]]))
ap_30 <- rbindlist(lapply(parts, `[[`, "ap"), fill = TRUE)
profile_30 <- rbindlist(lapply(parts, `[[`, "profile"), fill = TRUE)

ap_30[, hour := as.numeric(format(window_start, "%H")) + as.numeric(format(window_start, "%M")) / 60]
setcolorder(ap_30, c("site", "window_start", "date", "hour", "co2_mean", "co2_sd", "n_total", "n_diag0", "n_valid", "n_valves", "valves"))
setorder(ap_30, site, window_start)
setorder(profile_30, site, window_start)

all_days <- CJ(site = names(site_inputs), date = as.IDate(seq(as.Date(sprintf("%s-01-01", year)), as.Date(sprintf("%s-12-31", year)), by = "day")))
daily <- ap_30[, .(
  windows_valid = uniqueN(window_start),
  morning_windows_valid = uniqueN(window_start[hour >= 4 & hour <= 12]),
  valid_obs = sum(n_valid, na.rm = TRUE)
), by = .(site, date)]
daily <- daily[all_days, on = c("site", "date")]
daily[is.na(windows_valid), `:=`(windows_valid = 0L, morning_windows_valid = 0L, valid_obs = 0L)]
daily[, windows_total := 48L]
daily[, coverage_status := fifelse(windows_valid == 0, "no_data", fifelse(windows_valid >= 48, "full_day", "partial_day"))]
setcolorder(daily, c("site", "date", "windows_total", "windows_valid", "morning_windows_valid", "valid_obs", "coverage_status"))
setorder(daily, site, date)

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
ap_out <- copy(ap_30)
profile_out <- copy(profile_30)
ap_out[, window_start := format(window_start, "%Y-%m-%d %H:%M:%S", tz = tz_local)]
profile_out[, window_start := format(window_start, "%Y-%m-%d %H:%M:%S", tz = tz_local)]
fwrite(ap_out, file.path(out_dir, sprintf("fixed_tower_ap_%s_30min.csv", year)))
fwrite(daily, file.path(out_dir, sprintf("fixed_tower_ap_%s_daily_qc.csv", year)))
fwrite(profile_out, file.path(out_dir, sprintf("fixed_tower_ap_profile_%s_30min.csv", year)))

summary_tbl <- daily[, .(
  total_days = .N,
  full_day = sum(coverage_status == "full_day"),
  partial_day = sum(coverage_status == "partial_day"),
  no_data = sum(coverage_status == "no_data")
), by = site]
fwrite(summary_tbl, file.path(out_dir, sprintf("fixed_tower_ap_%s_qc_foundation_summary.csv", year)))

stopifnot(nrow(ap_30) > 0, nrow(profile_30) > 0, all(c("CVT", "MT") %in% daily$site))
print(summary_tbl)
