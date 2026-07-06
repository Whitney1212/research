#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

tz <- "Asia/Shanghai"
path <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/rerun_202401_202403_after_timefix/MT_flux_sector_pf_202401_202403_after_timefix.csv"
out_summary <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/rerun_202401_202403_after_timefix/MT_flux_sector_pf_202403_remaining_shift_fix_summary.csv"

parse_ts <- function(x) as.POSIXct(sub("\\.$", "", x), format = "%Y-%m-%d %H:%M:%OS", tz = tz)
fmt <- function(x) format(x, "%Y-%m-%d %H:%M:%OS1", tz = tz)

dt <- fread(path, colClasses = list(character = c("timestamp", "date", "time")))
dt[, ts := parse_ts(timestamp)]
if (anyNA(dt$ts)) stop("Timestamp parse failed.")

windows <- data.table(
  start = as.POSIXct(c("2024-03-20 08:00:00"), tz = tz),
  end = as.POSIXct(c("2024-03-21 08:00:00"), tz = tz)
)

dt[, shifted := FALSE]
for (i in seq_len(nrow(windows))) {
  idx <- dt$ts >= windows$start[i] & dt$ts < windows$end[i]
  dt[idx, `:=`(ts = ts - 8 * 3600, shifted = TRUE)]
}

dt[, timestamp := fmt(ts)]
dt[, date := substr(timestamp, 1, 10)]
dt[, time := substr(timestamp, 12, 23)]
setorder(dt, ts)

summary <- data.table(
  shifted_rows = dt[shifted == TRUE, .N],
  duplicate_timestamps_after = nrow(dt) - uniqueN(dt$timestamp),
  has_20240315_start = any(dt$timestamp == "2024-03-15 00:00:00.0"),
  has_20240319_start = any(dt$timestamp == "2024-03-19 00:00:00.0"),
  has_20240320_start = any(dt$timestamp == "2024-03-20 00:00:00.0"),
  has_20240331_start = any(dt$timestamp == "2024-03-31 00:00:00.0")
)
dt[, c("ts", "shifted") := NULL]
fwrite(dt, path)
fwrite(summary, out_summary)
message(sprintf("Shifted rows=%d", summary$shifted_rows))
