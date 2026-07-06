#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

tz <- "Asia/Shanghai"
full_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv"
fixed_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/rerun_202401_202403_after_timefix/MT_flux_sector_pf_202401_202403_after_timefix.csv"
backup_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf_before_202401_202403_timefix.csv"
summary_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf_202401_202403_timefix_overwrite_summary.csv"

parse_ts <- function(dt) {
  ts <- as.POSIXct(sub("\\.$", "", dt$timestamp), format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  bad <- is.na(ts)
  if (any(bad) && all(c("date", "time") %in% names(dt))) {
    ts[bad] <- as.POSIXct(paste(dt$date[bad], dt$time[bad]), format = "%Y-%m-%d %H:%M:%OS", tz = tz)
    bad <- is.na(ts)
    if (any(bad)) ts[bad] <- as.POSIXct(paste(dt$date[bad], dt$time[bad]), format = "%Y-%m-%d %H:%M", tz = tz)
  }
  ts
}

full <- fread(full_csv, colClasses = list(character = c("timestamp", "date", "time")))
fixed <- fread(fixed_csv, colClasses = list(character = c("timestamp", "date", "time")))
full[, ts := parse_ts(.SD)]
fixed[, ts := parse_ts(.SD)]
if (anyNA(full$ts) || anyNA(fixed$ts)) stop("Timestamp parse failed.")

full[, month := format(ts, "%Y-%m", tz = tz)]
fixed[, month := format(ts, "%Y-%m", tz = tz)]
months <- c("2024-01", "2024-03")
old_n <- full[month %in% months, .N]
fixed_n <- fixed[month %in% months, .N]
if (old_n != fixed_n) stop(sprintf("Row count mismatch: old=%d fixed=%d", old_n, fixed_n))

if (!file.exists(backup_csv)) file.copy(full_csv, backup_csv)

fixed[, pf_scheme := "sector_pf"]
cols <- setdiff(names(full), c("ts", "month"))
out <- rbindlist(
  list(full[!month %in% months, ..cols], fixed[, ..cols]),
  use.names = TRUE,
  fill = TRUE
)
out[, ts := parse_ts(.SD)]
setorder(out, ts)
out[, ts := NULL]
fwrite(out, full_csv)

summary <- data.table(
  full_csv = full_csv,
  backup_csv = backup_csv,
  fixed_csv = fixed_csv,
  months_replaced = paste(months, collapse = ";"),
  old_rows_replaced = old_n,
  output_rows = nrow(out),
  first_timestamp = out$timestamp[1],
  last_timestamp = out$timestamp[nrow(out)],
  fixed_20240103_start_present = any(out$timestamp == "2024-01-03 00:00:00.1")
)
fwrite(summary, summary_csv)
message(sprintf("Overwrote %s | replaced rows=%d | output rows=%d", full_csv, old_n, nrow(out)))
