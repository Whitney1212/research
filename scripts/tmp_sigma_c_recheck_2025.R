library(data.table)

out_dir <- "C:/Users/admin/.codex/visualizations/2026/07/12/019f5658-5105-7383-b7e0-dad15240aad7"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

read_sigma_corrected <- function(result_csv) {
  base <- fread(result_csv, select = c("tower", "ts_key", "source_file", "sigma_c"))
  base <- base[!is.na(source_file) & !is.na(ts_key)]
  base[, ts_key_chr := format(as.POSIXct(ts_key, tz = "Asia/Shanghai"), "%Y-%m-%d %H:%M:%S", tz = "Asia/Shanghai")]
  targets <- unique(base[, .(tower, ts_key_chr, source_file, sigma_c_old = sigma_c)])
  setorder(targets, source_file, ts_key_chr)

  res <- vector("list", uniqueN(targets$source_file))
  i <- 0L
  for (sf in unique(targets$source_file)) {
    i <- i + 1L
    hdr <- readLines(sf, n = 2L, warn = FALSE)
    cols <- trimws(gsub('^"|"$', "", strsplit(hdr[2], ",", fixed = TRUE)[[1L]]))
    co2_name <- if ("CO2" %in% cols) "CO2" else if ("CO2_mixratio" %in% cols) "CO2_mixratio" else next
    idx <- match(c("TIMESTAMP", co2_name), cols)
    dt <- fread(
      sf,
      skip = 4L,
      header = FALSE,
      select = idx,
      col.names = c("time_chr", "co2_raw"),
      na.strings = c("NA", "", "-9999", "-9999.0", "-99999", "-99999.0", "NaN", "NAN", "INF", "-INF"),
      showProgress = FALSE
    )
    dt[, time := as.POSIXct(time_chr, format = "%Y-%m-%d %H:%M:%OS", tz = "Asia/Shanghai")]
    dt[, co2_num := suppressWarnings(as.numeric(co2_raw))]
    dt[, block_time := as.POSIXct(floor(as.numeric(time) / 1800) * 1800, origin = "1970-01-01", tz = "Asia/Shanghai")]
    dt[, ts_key_chr := format(block_time, "%Y-%m-%d %H:%M:%S", tz = "Asia/Shanghai")]

    tgt <- targets[source_file == sf, unique(ts_key_chr)]
    raw_bad <- dt[
      ts_key_chr %chin% tgt & !is.na(co2_num) & co2_num <= -9999,
      .(n_bad_points = .N, min_raw = min(co2_num, na.rm = TRUE), max_raw = max(co2_num, na.rm = TRUE)),
      by = ts_key_chr
    ]
    keep <- dt[
      ts_key_chr %chin% tgt & is.finite(co2_num),
      .(n_points = .N, co2_mean = mean(co2_num), sigma_c_new = sd(co2_num)),
      by = ts_key_chr
    ]
    keep <- merge(keep, raw_bad, by = "ts_key_chr", all.x = TRUE)
    keep[is.na(n_bad_points), `:=`(n_bad_points = 0L, min_raw = NA_real_, max_raw = NA_real_)]
    keep[, source_file := sf]
    res[[i]] <- keep
  }

  out <- merge(targets, rbindlist(res, use.names = TRUE, fill = TRUE), by = c("ts_key_chr", "source_file"), all.x = TRUE)
  out[, hour := as.integer(format(as.POSIXct(ts_key_chr, tz = "Asia/Shanghai"), "%H"))]
  out[, contaminated := n_bad_points > 0]
  out
}

files <- c(
  MT = "E:/Dataset_Level1/MT/EC/whole year computation/rotation_sensitivity_standardized_2025/no_rotation/MT_common_four_method_valid_window_exchange_diagnostics_2025.csv",
  CVT = "E:/Dataset_Level1/CVT/EC/whole year computation/rotation_sensitivity_standardized_2025/no_rotation/CVT_common_four_method_valid_window_exchange_diagnostics_2025.csv"
)

all_dt <- rbindlist(lapply(files, read_sigma_corrected), use.names = TRUE, fill = TRUE)

summary_dt <- all_dt[!is.na(sigma_c_new), {
  q <- quantile(sigma_c_new, c(0.25, 0.5, 0.75, 0.95, 0.99), na.rm = TRUE, names = FALSE)
  q95_cut <- q[4]
  q99_cut <- q[5]
  .(
    n_windows = .N,
    median_sigma_c = q[2],
    q25 = q[1],
    q75 = q[3],
    q95 = q[4],
    q99 = q[5],
    max_sigma_c = max(sigma_c_new, na.rm = TRUE),
    mean_sigma_c = mean(sigma_c_new, na.rm = TRUE),
    mean_excl_top1pct = mean(sigma_c_new[sigma_c_new <= q99_cut], na.rm = TRUE),
    n_gt_q95 = sum(sigma_c_new > q95_cut, na.rm = TRUE),
    n_gt_q99 = sum(sigma_c_new > q99_cut, na.rm = TRUE),
    n_contaminated_windows = sum(contaminated, na.rm = TRUE),
    mean_sigma_c_old = mean(sigma_c_old, na.rm = TRUE),
    median_sigma_c_old = median(sigma_c_old, na.rm = TRUE)
  )
}, by = tower]

hourly_dt <- all_dt[!is.na(sigma_c_new), .(
  n_windows = .N,
  median_sigma_c = median(sigma_c_new, na.rm = TRUE),
  q25 = as.numeric(quantile(sigma_c_new, 0.25, na.rm = TRUE)),
  q75 = as.numeric(quantile(sigma_c_new, 0.75, na.rm = TRUE)),
  mean_sigma_c = mean(sigma_c_new, na.rm = TRUE),
  contaminated_windows = sum(contaminated, na.rm = TRUE)
), by = .(tower, hour)][order(tower, hour)]

extreme_dt <- all_dt[!is.na(sigma_c_new)][order(tower, -sigma_c_new), .(
  tower, ts_key_chr, sigma_c_old, sigma_c_new, contaminated, n_bad_points, min_raw, max_raw, source_file
)][, head(.SD, 15), by = tower]

fwrite(summary_dt, file.path(out_dir, "sigma_c_recheck_summary.csv"))
fwrite(hourly_dt, file.path(out_dir, "sigma_c_recheck_hourly.csv"))
fwrite(extreme_dt, file.path(out_dir, "sigma_c_recheck_extremes.csv"))

print(summary_dt)
cat("--- hourly MT ---\n")
print(hourly_dt[tower == "MT"])
cat("--- hourly CVT ---\n")
print(hourly_dt[tower == "CVT"])
cat("--- extremes ---\n")
print(extreme_dt)
