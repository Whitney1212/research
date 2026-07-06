#!/usr/bin/env Rscript

level0_root <- "E:/Dataset_Level0/MT/EC"
flux_file <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv"
out_dir <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/time_reading_diagnostics_202307_202312"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

tz_local <- "Asia/Shanghai"
start_date <- as.Date("2023-07-01")
end_date <- as.Date("2023-12-31")

theme_diag <- function(base_size = 13) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      legend.position = "top",
      legend.title = element_blank(),
      strip.background = element_rect(fill = "grey92", colour = "grey70"),
      plot.title = element_text(face = "bold")
    )
}

parse_ts <- function(x) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%OS", tz = tz_local)
}

clean_csv_first_field <- function(line) {
  if (length(line) == 0 || is.na(line) || !nzchar(line)) return(NA_character_)
  sub('^"([^"]+)".*$', "\\1", line)
}

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
    txt <- rawToChar(raw_acc)
    lines <- strsplit(txt, "\r\n|\n|\r", perl = TRUE)[[1]]
    lines <- lines[nzchar(lines)]
    if (length(lines) >= 1 && (pos == 0 || length(lines) >= 2)) return(tail(lines, 1))
    if (pos == 0) return(if (length(lines) > 0) tail(lines, 1) else NA_character_)
  }
}

extract_nominal_time <- function(path) {
  base <- basename(path)
  m <- regexec("_(20[0-9]{2})_([0-9]{2})_([0-9]{2})_([0-9]{4})\\.dat$", base)
  hit <- regmatches(base, m)[[1]]
  if (length(hit) < 5) return(as.POSIXct(NA_real_, origin = "1970-01-01", tz = tz_local))
  parse_ts(sprintf("%s-%s-%s %s:%s:00", hit[2], hit[3], hit[4], substr(hit[5], 1, 2), substr(hit[5], 3, 4)))
}

all_files <- list.files(
  level0_root,
  pattern = "^TOA5_.*\\.Time_Series_.*\\.dat$",
  full.names = TRUE,
  recursive = TRUE,
  ignore.case = TRUE
)
nominal <- as.POSIXct(
  vapply(all_files, function(p) {
    x <- extract_nominal_time(p)
    if (is.na(x)) return(NA_character_)
    format(x, "%Y-%m-%d %H:%M:%S", tz = tz_local)
  }, character(1)),
  format = "%Y-%m-%d %H:%M:%S",
  tz = tz_local
)
file_tbl <- data.table(path = all_files, nominal_time = nominal)
file_tbl <- file_tbl[
  as.Date(nominal_time, tz = tz_local) >= start_date &
    as.Date(nominal_time, tz = tz_local) <= end_date
]
setorder(file_tbl, nominal_time, path)
if (nrow(file_tbl) == 0) stop("No raw TOA5 files found in the requested nominal date range.", call. = FALSE)

file_diag <- rbindlist(lapply(seq_len(nrow(file_tbl)), function(i) {
  this_path <- file_tbl$path[i]
  this_nominal <- file_tbl$nominal_time[i]
  first_data_line <- readLines(this_path, n = 5, warn = FALSE)[5]
  last_data_line <- read_last_line(this_path)
  first_ts_char <- clean_csv_first_field(first_data_line)
  last_ts_char <- clean_csv_first_field(last_data_line)
  first_ts <- parse_ts(first_ts_char)
  last_ts <- parse_ts(last_ts_char)
  data.table(
    file = basename(this_path),
    directory = basename(dirname(this_path)),
    nominal_time = this_nominal,
    first_ts_char = first_ts_char,
    last_ts_char = last_ts_char,
    first_ts = first_ts,
    last_ts = last_ts,
    first_minus_nominal_sec = as.numeric(difftime(first_ts, this_nominal, units = "secs")),
    duration_hours = as.numeric(difftime(last_ts, first_ts, units = "hours")),
    first_minute = as.integer(format(first_ts, "%M", tz = tz_local)),
    first_second = as.numeric(format(first_ts, "%OS", tz = tz_local)),
    last_minute = as.integer(format(last_ts, "%M", tz = tz_local)),
    last_second = as.numeric(format(last_ts, "%OS", tz = tz_local))
  )
}))

file_diag[, next_first_ts := shift(first_ts, type = "lead")]
file_diag[, next_file := shift(file, type = "lead")]
file_diag[, gap_to_next_sec := as.numeric(difftime(next_first_ts, last_ts, units = "secs"))]
file_diag[, month := format(first_ts, "%Y-%m", tz = tz_local)]
fwrite(file_diag, file.path(out_dir, "MT_202307_202312_raw_file_time_char_diagnostics.csv"))

flux <- fread(flux_file, colClasses = list(character = c("timestamp", "date", "time")))
flux[, timestamp_local := parse_ts(timestamp)]
bad <- is.na(flux$timestamp_local)
if (any(bad)) {
  flux[bad, timestamp_local := as.POSIXct(paste(date, time), format = "%Y-%m-%d %H:%M", tz = tz_local)]
}
flux_win <- flux[
  as.Date(timestamp_local, tz = tz_local) >= start_date &
    as.Date(timestamp_local, tz = tz_local) <= end_date
]
flux_win[, month := format(timestamp_local, "%Y-%m", tz = tz_local)]
flux_win[, minute := as.integer(format(timestamp_local, "%M", tz = tz_local))]
flux_win[, second := as.numeric(format(timestamp_local, "%OS", tz = tz_local))]
flux_win[, phase_label := sprintf("%02d:%04.1f", minute, second)]
setorder(flux_win, timestamp_local)
flux_win[, next_timestamp := shift(timestamp_local, type = "lead")]
flux_win[, gap_to_next_min := as.numeric(difftime(next_timestamp, timestamp_local, units = "mins"))]

shift_check <- copy(file_diag)
shift_check[, first_ts_plus_8h := first_ts + 8 * 3600]
shift_check[, plus8_in_flux := first_ts_plus_8h %in% flux_win$timestamp_local]
shift_check[, first_ts_plus_8h_char := format(first_ts_plus_8h, "%Y-%m-%d %H:%M:%OS", tz = tz_local)]
fwrite(
  shift_check[, .(file, first_ts_char, first_ts_plus_8h_char, plus8_in_flux)],
  file.path(out_dir, "MT_202307_202312_raw_first_time_plus8_flux_matches.csv")
)

flux_phase <- flux_win[, .N, by = .(month, phase_label, minute, second)][order(month, minute, second)]
flux_month <- flux_win[, .(
  n_rows = .N,
  first_timestamp = min(timestamp_local),
  last_timestamp = max(timestamp_local),
  n_phase_labels = uniqueN(phase_label),
  phase_labels = paste(unique(phase_label), collapse = "; "),
  n_non_00_30 = sum(!(minute %in% c(0L, 30L) & second == 0), na.rm = TRUE),
  n_duplicate_timestamp = .N - uniqueN(timestamp_local),
  n_gap_not_30_min = sum(is.finite(gap_to_next_min) & abs(gap_to_next_min - 30) > 1e-6)
), by = month][order(month)]

fwrite(flux_phase, file.path(out_dir, "MT_202307_202312_flux_timestamp_phase_counts.csv"))
fwrite(flux_month, file.path(out_dir, "MT_202307_202312_flux_month_time_summary.csv"))

gap_diag <- file_diag[
  is.finite(gap_to_next_sec) & (gap_to_next_sec < 0 | gap_to_next_sec > 1.1),
  .(file, last_ts, next_file, next_first_ts, gap_to_next_sec)
]
fwrite(gap_diag, file.path(out_dir, "MT_202307_202312_raw_file_gap_flags.csv"))

p_phase <- ggplot(flux_phase, aes(x = phase_label, y = N, fill = phase_label)) +
  geom_col(width = 0.75) +
  facet_wrap(~month, scales = "free_y", ncol = 3) +
  labs(
    title = "MT sector PF flux timestamp phase counts, 2023-07 to 2023-12",
    x = "Minute:second phase",
    y = "Rows",
    caption = "Flux timestamps were read as character before explicit Asia/Shanghai parsing."
  ) +
  theme_diag() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(out_dir, "MT_202307_202312_flux_timestamp_phase_counts.png"),
       p_phase, width = 12, height = 8, dpi = 300)

p_gap <- ggplot(file_diag[is.finite(gap_to_next_sec)], aes(x = first_ts, y = gap_to_next_sec)) +
  geom_hline(yintercept = 0.1, colour = "grey65", linewidth = 0.35) +
  geom_point(colour = "#619CFF", size = 1.5, alpha = 0.8) +
  facet_wrap(~month, scales = "free_x", ncol = 2) +
  labs(
    title = "MT raw TOA5 file-to-file timestamp gaps, 2023-07 to 2023-12",
    x = "File first timestamp",
    y = "Gap to next file first timestamp (s)",
    caption = "Raw file first/last timestamps were read from quoted strings without type guessing."
  ) +
  theme_diag()
ggsave(file.path(out_dir, "MT_202307_202312_raw_file_gap_seconds.png"),
       p_gap, width = 12, height = 8, dpi = 300)

summary_lines <- c(
  "# MT 2023-07 to 2023-12 time reading diagnostics",
  "",
  paste0("- Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  paste0("- Level0 root: ", level0_root),
  paste0("- Flux file: ", flux_file),
  paste0("- Raw TOA5 files by nominal filename date: ", nrow(file_diag)),
  paste0("- Flux rows in date window: ", nrow(flux_win)),
  paste0("- Raw files with first timestamp parse failure: ", sum(is.na(file_diag$first_ts))),
  paste0("- Raw files with last timestamp parse failure: ", sum(is.na(file_diag$last_ts))),
  paste0("- Raw file gaps flagged (<0 or >1.1 s): ", nrow(gap_diag)),
  paste0("- Raw file first timestamps whose +8 h value appears in current flux table: ",
         sum(shift_check$plus8_in_flux), " / ", nrow(shift_check)),
  paste0("- Flux month summaries: ", file.path(out_dir, "MT_202307_202312_flux_month_time_summary.csv")),
  "",
  "## Month summary",
  paste(capture.output(print(flux_month)), collapse = "\n"),
  "",
  "## Interpretation guard",
  "- This diagnostic intentionally reads timestamp fields as character strings first, then parses with Asia/Shanghai.",
  "- If raw local timestamps appear in the current flux table after +8 h, the existing flux table likely used UTC-guessed POSIX timestamps before writing.",
  "- It checks time parsing and timestamp phase only; it does not prove or disprove physical flux phase differences."
)
writeLines(summary_lines, file.path(out_dir, "MT_202307_202312_time_reading_diagnostic_report.md"), useBytes = TRUE)

message("Wrote diagnostics to: ", out_dir)
