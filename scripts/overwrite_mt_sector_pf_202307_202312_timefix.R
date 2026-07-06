#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

tz <- "Asia/Shanghai"
full_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv"
fixed_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/rerun_202307_202312_after_timefix/MT_flux_sector_pf_202307_202312_after_timefix.csv"
backup_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf_before_202307_202312_timefix.csv"
summary_csv <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf_202307_202312_timefix_overwrite_summary.csv"

parse_ts <- function(dt) {
  ts <- as.POSIXct(sub("\\.$", "", dt$timestamp), format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  bad <- is.na(ts)
  if (any(bad) && all(c("date", "time") %in% names(dt))) {
    ts[bad] <- as.POSIXct(paste(dt$date[bad], dt$time[bad]), format = "%Y-%m-%d %H:%M:%OS", tz = tz)
    bad <- is.na(ts)
    if (any(bad)) {
      ts[bad] <- as.POSIXct(paste(dt$date[bad], dt$time[bad]), format = "%Y-%m-%d %H:%M", tz = tz)
    }
  }
  ts
}

full <- fread(full_csv, colClasses = list(character = c("timestamp", "date", "time")))
fixed <- fread(fixed_csv, colClasses = list(character = c("timestamp", "date", "time")))

full[, ts := parse_ts(.SD)]
fixed[, ts := parse_ts(.SD)]
if (anyNA(full$ts) || anyNA(fixed$ts)) stop("Timestamp parse failed.")

start <- as.POSIXct("2023-07-01 00:00:00", tz = tz)
end <- as.POSIXct("2024-01-01 00:00:00", tz = tz)
old_period_n <- full[ts >= start & ts < end, .N]
fixed_period_n <- fixed[ts >= start & ts < end, .N]
if (old_period_n != fixed_period_n) {
  stop(sprintf("Row count mismatch: old=%d fixed=%d", old_period_n, fixed_period_n))
}

if (!file.exists(backup_csv)) file.copy(full_csv, backup_csv)

fixed[, pf_scheme := "sector_pf"]
cols <- setdiff(names(full), "ts")
out <- rbindlist(
  list(full[!(ts >= start & ts < end), ..cols], fixed[, ..cols]),
  use.names = TRUE,
  fill = TRUE
)
out[, ts := parse_ts(.SD)]
setorder(out, ts)

if (out[timestamp == "2023-08-14 07:55:27.8", .N] != 0L) stop("Old +8h shifted timestamp remains.")
if (out[timestamp == "2023-08-13 23:55:27.8", .N] != 1L) stop("Expected fixed raw timestamp missing.")

out[, ts := NULL]
fwrite(out, full_csv)

summary <- data.table(
  full_csv = full_csv,
  backup_csv = backup_csv,
  fixed_csv = fixed_csv,
  old_period_rows_replaced = old_period_n,
  output_rows = nrow(out),
  first_timestamp = out$timestamp[1],
  last_timestamp = out$timestamp[nrow(out)],
  expected_raw_start_present = TRUE,
  old_plus8_shift_absent = TRUE
)
fwrite(summary, summary_csv)

message(sprintf("Overwrote %s | replaced rows=%d | output rows=%d", full_csv, old_period_n, nrow(out)))
