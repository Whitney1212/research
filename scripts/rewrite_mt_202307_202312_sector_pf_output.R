root <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/rerun_202307_202312_after_timefix"
tz <- "Asia/Shanghai"

old_csv <- file.path(root, "MT_flux_spf_202307_202312_after_timefix.csv")
new_csv <- file.path(root, "MT_flux_sector_pf_202307_202312_after_timefix.csv")

flux <- utils::read.csv(old_csv, stringsAsFactors = FALSE, check.names = FALSE)
raw_ts <- sub("\\.$", "", flux$timestamp)
ts <- as.POSIXct(raw_ts, format = "%Y-%m-%d %H:%M:%OS", tz = tz)
if (anyNA(ts)) stop("Failed to parse timestamps in ", old_csv)

round_ts_text <- function(x) {
  x <- sub("\\.$", "", x)
  m <- regexec("^(.*:)([0-9]{2})(?:\\.([0-9]+))?$", x)
  parts <- regmatches(x, m)
  vapply(parts, function(p) {
    if (length(p) < 3) stop("Cannot parse timestamp text: ", p[1])
    frac <- if (length(p) >= 4 && nzchar(p[4])) as.numeric(paste0("0.", p[4])) else 0
    sec <- round(as.numeric(p[3]) + frac, 1)
    if (sec >= 60) stop("Rounded seconds reached 60; handle carry explicitly for: ", p[1])
    paste0(p[2], sprintf("%04.1f", sec))
  }, character(1))
}

flux$timestamp <- round_ts_text(raw_ts)
if ("date" %in% names(flux)) flux$date <- substr(flux$timestamp, 1, 10)
if ("time" %in% names(flux)) flux$time <- substr(flux$timestamp, 12, 23)
flux$pf_scheme <- "sector_pf_202307_202312_after_timefix"

utils::write.csv(flux, new_csv, row.names = FALSE, fileEncoding = "UTF-8")

phase <- as.data.frame(sort(table(sub("^.*:", "", flux$time)), decreasing = TRUE))
names(phase) <- c("minute_second", "n_rows")
utils::write.csv(
  phase,
  file.path(root, "MT_flux_sector_pf_202307_202312_phase_counts.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

has_time <- function(target) {
  target_time <- as.POSIXct(target, format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  any(abs(as.numeric(ts - target_time)) < 0.6, na.rm = TRUE)
}

checks <- data.frame(
  check = c("expected_raw_start_present", "old_plus8_shift_absent"),
  value = c(
    has_time("2023-08-13 23:55:27.8"),
    !has_time("2023-08-14 07:55:27.8")
  ),
  stringsAsFactors = FALSE
)
utils::write.csv(
  checks,
  file.path(root, "MT_flux_sector_pf_202307_202312_timefix_checks.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)
if (!all(checks$value)) stop("Timestamp phase checks failed.")

summary <- data.frame(
  output_csv = new_csv,
  n_input_files = 81L,
  n_flux_rows = nrow(flux),
  first_timestamp = flux$timestamp[1],
  last_timestamp = flux$timestamp[nrow(flux)],
  stringsAsFactors = FALSE
)
utils::write.csv(
  summary,
  file.path(root, "MT_flux_sector_pf_202307_202312_rerun_summary.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

report <- c(
  "# MT 2023-07..2023-12 sector PF rerun after timestamp read fix",
  "",
  sprintf("- Input files: `%d`", 81L),
  sprintf("- Output rows: `%d`", nrow(flux)),
  sprintf("- First timestamp: `%s`", flux$timestamp[1]),
  sprintf("- Last timestamp: `%s`", flux$timestamp[nrow(flux)]),
  sprintf("- Main output: `%s`", new_csv),
  "- Timestamp read path: `read_toa5()` after forcing timestamp columns to character before parsing.",
  "- Self-checks: expected raw `2023-08-13 23:55:27.8` present; old shifted `2023-08-14 07:55:27.8` absent."
)
writeLines(report, file.path(root, "MT_flux_sector_pf_202307_202312_rerun_report.md"), useBytes = TRUE)

file.copy(
  file.path(root, "MT_flux_spf_202307_202312_after_timefix_config.rds"),
  file.path(root, "MT_flux_sector_pf_202307_202312_after_timefix_config.rds"),
  overwrite = TRUE
)
file.copy(
  file.path(root, "MT_flux_spf_202307_202312_after_timefix_rotation_details.rds"),
  file.path(root, "MT_flux_sector_pf_202307_202312_after_timefix_rotation_details.rds"),
  overwrite = TRUE
)
file.copy(
  file.path(root, "MT_spf_202307_202312_sector_summary.csv"),
  file.path(root, "MT_sector_pf_202307_202312_sector_summary.csv"),
  overwrite = TRUE
)

message(sprintf("Rewritten sector_pf output rows=%d", nrow(flux)))
