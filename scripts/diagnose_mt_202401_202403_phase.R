#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

level0_root <- "E:/Dataset_Level0/MT/EC"
flux_file <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv"
out_dir <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/time_reading_diagnostics_202401_202403"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

tz <- "Asia/Shanghai"
months_keep <- c("2024-01", "2024-03")

parse_local <- function(x) {
  x <- sub("\\.$", "", as.character(x))
  m <- regexec("^(\\d{4}-\\d{2}-\\d{2}) 24:(\\d{2}:\\d{2}(?:\\.\\d+)?)$", x)
  hit <- regmatches(x, m)
  is_24 <- vapply(hit, length, integer(1)) == 4L
  if (any(is_24)) {
    d <- as.Date(vapply(hit[is_24], `[[`, character(1), 2L)) + 1L
    rest <- vapply(hit[is_24], `[[`, character(1), 3L)
    x[is_24] <- paste(d, paste0("00:", rest))
  }
  ts <- as.POSIXct(x, format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  bad <- is.na(ts)
  if (any(bad)) ts[bad] <- as.POSIXct(x[bad], format = "%Y-%m-%d %H:%M", tz = tz)
  ts
}

first_field <- function(line) sub('^"([^"]+)".*$', "\\1", line)

read_last_line <- function(path, chunk_size = 65536L) {
  con <- file(path, "rb")
  on.exit(close(con), add = TRUE)
  size <- file.info(path)$size
  if (!is.finite(size) || size <= 0) return(NA_character_)
  pos <- size
  raw_acc <- raw(0)
  repeat {
    n <- min(chunk_size, pos)
    pos <- pos - n
    seek(con, where = pos, origin = "start")
    raw_acc <- c(readBin(con, "raw", n), raw_acc)
    lines <- strsplit(rawToChar(raw_acc), "\r\n|\n|\r", perl = TRUE)[[1]]
    lines <- lines[nzchar(lines)]
    if (length(lines) >= 1 && (pos == 0 || length(lines) >= 2)) return(tail(lines, 1))
    if (pos == 0) return(if (length(lines) > 0) tail(lines, 1) else NA_character_)
  }
}

nominal_from_name <- function(path) {
  hit <- regmatches(basename(path), regexec("_(20\\d{2})_(\\d{2})_(\\d{2})_(\\d{4})\\.dat$", basename(path)))[[1]]
  if (length(hit) < 5) return(as.POSIXct(NA_real_, origin = "1970-01-01", tz = tz))
  parse_local(sprintf("%s-%s-%s %s:%s:00", hit[2], hit[3], hit[4], substr(hit[5], 1, 2), substr(hit[5], 3, 4)))
}

all_files <- sort(list.files(level0_root, pattern = "^TOA5_.*\\.Time_Series_.*\\.dat$", full.names = TRUE, recursive = TRUE))
nominal <- as.POSIXct(vapply(all_files, function(p) format(nominal_from_name(p), "%Y-%m-%d %H:%M:%S", tz = tz), character(1)),
                      format = "%Y-%m-%d %H:%M:%S", tz = tz)
files <- data.table(path = all_files, nominal_time = nominal)
files[, nominal_month := format(nominal_time, "%Y-%m", tz = tz)]
files <- files[nominal_month %in% months_keep]
if (nrow(files) == 0) stop("No files found for requested months.")

raw <- rbindlist(lapply(seq_len(nrow(files)), function(i) {
  p <- files$path[i]
  first_line <- readLines(p, n = 5, warn = FALSE)[5]
  last_line <- read_last_line(p)
  data.table(
    file = basename(p),
    directory = basename(dirname(p)),
    nominal_time = files$nominal_time[i],
    nominal_month = files$nominal_month[i],
    first_ts_char = first_field(first_line),
    last_ts_char = first_field(last_line)
  )
}))
raw[, first_ts := parse_local(first_ts_char)]
raw[, last_ts := parse_local(last_ts_char)]
raw[, first_phase := format(first_ts, "%H:%M:%OS1", tz = tz)]
raw[, last_phase := format(last_ts, "%H:%M:%OS1", tz = tz)]
raw[, first_minus_nominal_sec := as.numeric(difftime(first_ts, nominal_time, units = "secs"))]
fwrite(raw, file.path(out_dir, "MT_202401_202403_raw_file_time_char_diagnostics.csv"))

flux <- fread(flux_file, colClasses = list(character = c("timestamp", "date", "time")))
flux[, ts := parse_local(timestamp)]
bad <- is.na(flux$ts)
if (any(bad)) flux[bad, ts := parse_local(paste(date, time))]
if (anyNA(flux$ts)) stop("Flux timestamp parse failed.")
flux[, month := format(ts, "%Y-%m", tz = tz)]
flux_win <- flux[month %in% months_keep]
flux_win[, phase_label := format(ts, "%H:%M:%OS1", tz = tz)]
setorder(flux_win, ts)
flux_win[, gap_min := as.numeric(difftime(shift(ts, type = "lead"), ts, units = "mins"))]

num_ts <- as.numeric(flux_win$ts)
has_near <- function(t) any(abs(num_ts - as.numeric(t)) < 0.6, na.rm = TRUE)

match_tbl <- copy(raw)
match_tbl[, first_exact_in_flux := vapply(first_ts, has_near, logical(1))]
match_tbl[, first_plus8_in_flux := vapply(first_ts + 8 * 3600, has_near, logical(1))]
match_tbl[, verdict := fifelse(!first_exact_in_flux & first_plus8_in_flux, "suspect_plus8_shift",
                         fifelse(first_exact_in_flux & !first_plus8_in_flux, "exact_only",
                         fifelse(first_exact_in_flux & first_plus8_in_flux, "exact_and_plus8_ambiguous", "no_boundary_match")))]
fwrite(match_tbl, file.path(out_dir, "MT_202401_202403_raw_first_time_flux_shift_checks.csv"))

month_summary <- flux_win[, .(
  n_rows = .N,
  first_timestamp = min(ts),
  last_timestamp = max(ts),
  n_phase_labels = uniqueN(phase_label),
  phase_labels = paste(unique(phase_label), collapse = "; "),
  n_gap_not_30_min = sum(is.finite(gap_min) & abs(gap_min - 30) > 1e-6)
), by = month][order(month)]
fwrite(month_summary, file.path(out_dir, "MT_202401_202403_flux_month_time_summary.csv"))

verdict_summary <- match_tbl[, .N, by = .(nominal_month, verdict)][order(nominal_month, verdict)]
fwrite(verdict_summary, file.path(out_dir, "MT_202401_202403_shift_verdict_summary.csv"))

suspects <- match_tbl[verdict == "suspect_plus8_shift"]
fwrite(suspects, file.path(out_dir, "MT_202401_202403_suspect_plus8_shift_events.csv"))

report <- c(
  "# MT 2024-01 and 2024-03 timestamp phase diagnostic",
  "",
  sprintf("- Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  sprintf("- Raw files checked: %d", nrow(raw)),
  sprintf("- Flux rows checked: %d", nrow(flux_win)),
  sprintf("- Raw parse failures: first=%d, last=%d", sum(is.na(raw$first_ts)), sum(is.na(raw$last_ts))),
  sprintf("- Suspect +8h shifted first-boundary events: %d", nrow(suspects)),
  "",
  "## Verdict summary",
  paste(capture.output(print(verdict_summary)), collapse = "\n"),
  "",
  "## Flux month summary",
  paste(capture.output(print(month_summary)), collapse = "\n"),
  "",
  "## Interpretation",
  "- `suspect_plus8_shift` means the raw first timestamp is absent from the current flux table while raw+8h is present.",
  "- `exact_and_plus8_ambiguous` is common for regular 00:00/00:30 phases; it is not by itself evidence of an error.",
  "- Raw timestamps with `24:00:00.x` were normalized to the next day's `00:00:00.x` for parsing only."
)
writeLines(report, file.path(out_dir, "MT_202401_202403_phase_diagnostic_report.md"), useBytes = TRUE)

message("Wrote diagnostics to: ", out_dir)
