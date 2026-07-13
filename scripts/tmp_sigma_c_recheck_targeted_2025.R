library(data.table)

out_dir <- "C:/Users/admin/.codex/visualizations/2026/07/12/019f5658-5105-7383-b7e0-dad15240aad7"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

files <- c(
  MT = "E:/Dataset_Level1/MT/EC/whole year computation/rotation_sensitivity_standardized_2025/no_rotation/MT_common_four_method_valid_window_exchange_diagnostics_2025.csv",
  CVT = "E:/Dataset_Level1/CVT/EC/whole year computation/rotation_sensitivity_standardized_2025/no_rotation/CVT_common_four_method_valid_window_exchange_diagnostics_2025.csv"
)

base <- rbindlist(lapply(names(files), function(nm) {
  dt <- fread(
    files[[nm]],
    select = c("tower", "ts_key", "sigma_c", "source_file"),
    colClasses = c(ts_key = "character")
  )
  dt[, ts_key_chr := ts_key]
  dt[, hour := as.integer(substr(ts_key_chr, 12L, 13L))]
  dt[, tower := nm]
  dt
}), use.names = TRUE, fill = TRUE)

# ponytail: -99999 contamination creates sd around 7e2-1.3e3; fix only those windows.
suspicious <- base[!is.na(sigma_c) & sigma_c > 100, .(tower, ts_key_chr, source_file, sigma_c_old = sigma_c)]

recalc_one <- function(file, ts_key_chr) {
  hdr <- readLines(file, n = 2L, warn = FALSE)
  cols <- trimws(gsub('^"|"$', "", strsplit(hdr[2], ",", fixed = TRUE)[[1L]]))
  co2_name <- if ("CO2" %in% cols) "CO2" else if ("CO2_mixratio" %in% cols) "CO2_mixratio" else stop("No CO2 column")
  idx <- match(c("TIMESTAMP", co2_name), cols)
  dt <- fread(
    file,
    skip = 4L,
    header = FALSE,
    select = idx,
    col.names = c("time_chr", "co2"),
    na.strings = c("NA", "", "-9999", "-9999.0", "-99999", "-99999.0", "NaN", "NAN", "INF", "-INF"),
    showProgress = FALSE
  )
  dt[, time := as.POSIXct(time_chr, format = "%Y-%m-%d %H:%M:%OS", tz = "Asia/Shanghai")]
  st <- as.POSIXct(ts_key_chr, tz = "Asia/Shanghai")
  ed <- st + 1800
  x <- dt[time >= st & time < ed]
  x[, co2 := suppressWarnings(as.numeric(co2))]
  data.table(
    ts_key_chr = ts_key_chr,
    source_file = file,
    sigma_c_new = sd(x$co2, na.rm = TRUE),
    n_bad_points = sum(x$co2 <= -9999, na.rm = TRUE)
  )
}

fix_dt <- rbindlist(lapply(seq_len(nrow(suspicious)), function(i) {
  recalc_one(suspicious$source_file[[i]], suspicious$ts_key_chr[[i]])
}), use.names = TRUE, fill = TRUE)

fixed <- merge(base, fix_dt, by = c("ts_key_chr", "source_file"), all.x = TRUE)
fixed[, sigma_c_fix := fifelse(!is.na(sigma_c_new), sigma_c_new, sigma_c)]
fixed[, contaminated := !is.na(sigma_c_new)]

summary_dt <- fixed[!is.na(sigma_c_fix), {
  q <- quantile(sigma_c_fix, c(0.25, 0.5, 0.75, 0.95, 0.99), na.rm = TRUE, names = FALSE)
  q95_cut <- q[4]
  q99_cut <- q[5]
  .(
    n_windows = .N,
    median_sigma_c = q[2],
    q25 = q[1],
    q75 = q[3],
    q95 = q[4],
    q99 = q[5],
    max_sigma_c = max(sigma_c_fix, na.rm = TRUE),
    mean_sigma_c = mean(sigma_c_fix, na.rm = TRUE),
    mean_excl_top1pct = mean(sigma_c_fix[sigma_c_fix <= q99_cut], na.rm = TRUE),
    n_gt_q95 = sum(sigma_c_fix > q95_cut, na.rm = TRUE),
    n_gt_q99 = sum(sigma_c_fix > q99_cut, na.rm = TRUE),
    n_contaminated_windows = sum(contaminated, na.rm = TRUE),
    old_mean_sigma_c = mean(sigma_c, na.rm = TRUE),
    old_median_sigma_c = median(sigma_c, na.rm = TRUE)
  )
}, by = tower]

hourly_dt <- fixed[!is.na(sigma_c_fix), .(
  n_windows = .N,
  median_sigma_c = median(sigma_c_fix, na.rm = TRUE),
  q25 = as.numeric(quantile(sigma_c_fix, 0.25, na.rm = TRUE)),
  q75 = as.numeric(quantile(sigma_c_fix, 0.75, na.rm = TRUE)),
  mean_sigma_c = mean(sigma_c_fix, na.rm = TRUE),
  contaminated_windows = sum(contaminated, na.rm = TRUE)
), by = .(tower, hour)][order(tower, hour)]

extreme_dt <- fixed[order(tower, -sigma_c_fix), .(
  tower, ts_key_chr, sigma_c_old = sigma_c, sigma_c_fix, contaminated, n_bad_points, source_file
)][, head(.SD, 20), by = tower]

fwrite(summary_dt, file.path(out_dir, "sigma_c_recheck_targeted_summary.csv"))
fwrite(hourly_dt, file.path(out_dir, "sigma_c_recheck_targeted_hourly.csv"))
fwrite(extreme_dt, file.path(out_dir, "sigma_c_recheck_targeted_extremes.csv"))

print(summary_dt)
cat("--- hourly MT ---\n")
print(hourly_dt[tower == "MT"])
cat("--- hourly CVT ---\n")
print(hourly_dt[tower == "CVT"])
cat("--- extremes ---\n")
print(extreme_dt)
