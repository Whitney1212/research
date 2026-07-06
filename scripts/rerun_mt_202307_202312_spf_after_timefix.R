tz <- "Asia/Shanghai"

com_rotation_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
ecpreproc_dir <- "D:/00 博士阶段/博一/05 Project/ecpreproc"
mt_level0_root <- "E:/Dataset_Level0/MT/EC"
meta_path <- "D:/00EDDYPRO/sh_MT.metadata"

out_root <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/rerun_202307_202312_after_timefix"
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(out_root, "logs"), recursive = TRUE, showWarnings = FALSE)

source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")

cfg <- list(project_dir = out_root, package_dir = ecpreproc_dir, tz = tz)
load_ecpreproc(cfg)

meta <- ec_read_metadata(meta_path)
start_time <- as.POSIXct("2023-07-01 00:00:00", tz = tz)
end_time <- as.POSIXct("2024-01-01 00:00:00", tz = tz)

all_files <- sort(list.files(
  mt_level0_root,
  pattern = "^TOA5_.*\\.Time_Series_.*\\.dat$",
  full.names = TRUE,
  recursive = TRUE
))
files <- all_files[grepl("2023_(07|08|09|10|11|12)_", basename(all_files))]
if (length(files) == 0) stop("No MT TOA5 files found for 2023-07..2023-12.")

dup <- names(which(table(basename(files)) > 1))
if (length(dup) > 0) stop("Duplicate basenames would make file_pattern ambiguous: ", paste(dup, collapse = ", "))

file_pattern <- basename_pattern(files)
message(sprintf("Running MT SPF after timestamp read fix | files=%d", length(files)))

started <- Sys.time()
res <- process_rep_flux(
  data_dir = mt_level0_root,
  meta_data = meta,
  file_pattern = file_pattern,
  recursive = TRUE,
  tz = tz,
  rotation_method = "spf",
  detrend_method = "block_average",
  qc_params = list(
    pf_params = list(allow_bias = TRUE, n_sectors = 12, min_points = 10, min_win = 50)
  ),
  lag_params = list(),
  fit_results = NULL,
  output_dir = out_root,
  show_progress = TRUE,
  keep_block_details = FALSE
)
finished <- Sys.time()

if (is.null(res$results) || nrow(res$results) == 0) stop("process_rep_flux returned no rows.")

flux <- res$results
if (!inherits(flux$timestamp, "POSIXct")) {
  flux$timestamp <- as.POSIXct(flux$timestamp, tz = tz)
}
flux <- flux[!is.na(flux$timestamp) & flux$timestamp >= start_time & flux$timestamp < end_time, , drop = FALSE]
flux <- flux[order(flux$timestamp), , drop = FALSE]
if (nrow(flux) == 0) stop("No flux rows remain after 2023-07..2023-12 filtering.")

ts_posix <- flux$timestamp
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
flux$timestamp <- round_ts_text(format(ts_posix, "%Y-%m-%d %H:%M:%OS3", tz = tz))
if ("date" %in% names(flux)) flux$date <- substr(flux$timestamp, 1, 10)
if ("time" %in% names(flux)) flux$time <- substr(flux$timestamp, 12, 23)
flux$pf_scheme <- "sector_pf_202307_202312_after_timefix"

main_csv <- file.path(out_root, "MT_flux_sector_pf_202307_202312_after_timefix.csv")
utils::write.csv(flux, main_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.null(res$details$config)) {
  saveRDS(res$details$config, file.path(out_root, "MT_flux_sector_pf_202307_202312_after_timefix_config.rds"))
}
if (!is.null(res$details$rotation)) {
  saveRDS(res$details$rotation, file.path(out_root, "MT_flux_sector_pf_202307_202312_after_timefix_rotation_details.rds"))
  if (!is.null(res$details$rotation$sector_summary)) {
    utils::write.csv(
      res$details$rotation$sector_summary,
      file.path(out_root, "MT_sector_pf_202307_202312_sector_summary.csv"),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
  }
}

has_time <- function(target) {
  target_time <- as.POSIXct(target, format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  any(abs(as.numeric(ts_posix - target_time)) < 0.6, na.rm = TRUE)
}

phase <- data.frame(
  minute_second = sub("^.*:", "", flux$time),
  stringsAsFactors = FALSE
)
phase <- as.data.frame(sort(table(phase$minute_second), decreasing = TRUE))
names(phase) <- c("minute_second", "n_rows")
utils::write.csv(phase, file.path(out_root, "MT_flux_sector_pf_202307_202312_phase_counts.csv"),
                 row.names = FALSE, fileEncoding = "UTF-8")

checks <- data.frame(
  check = c("expected_raw_start_present", "old_plus8_shift_absent"),
  value = c(
    has_time("2023-08-13 23:55:27.8"),
    !has_time("2023-08-14 07:55:27.8")
  ),
  stringsAsFactors = FALSE
)
utils::write.csv(checks, file.path(out_root, "MT_flux_sector_pf_202307_202312_timefix_checks.csv"),
                 row.names = FALSE, fileEncoding = "UTF-8")
if (!all(checks$value)) {
  stop("Timestamp phase self-check failed; see MT_flux_sector_pf_202307_202312_timefix_checks.csv")
}

summary <- data.frame(
  output_csv = main_csv,
  n_input_files = length(files),
  n_flux_rows = nrow(flux),
  first_timestamp = flux$timestamp[1],
  last_timestamp = flux$timestamp[nrow(flux)],
  started = as.character(started),
  finished = as.character(finished),
  elapsed_min = as.numeric(difftime(finished, started, units = "mins")),
  stringsAsFactors = FALSE
)
utils::write.csv(summary, file.path(out_root, "MT_flux_sector_pf_202307_202312_rerun_summary.csv"),
                 row.names = FALSE, fileEncoding = "UTF-8")

report <- c(
  "# MT 2023-07..2023-12 SPF rerun after timestamp read fix",
  "",
  sprintf("- Input files: `%d`", length(files)),
  sprintf("- Output rows: `%d`", nrow(flux)),
  sprintf("- First timestamp: `%s`", flux$timestamp[1]),
  sprintf("- Last timestamp: `%s`", flux$timestamp[nrow(flux)]),
  sprintf("- Main output: `%s`", main_csv),
  "- Timestamp read path: `read_toa5()` after forcing timestamp columns to character before parsing.",
  "- Self-checks: expected raw `2023-08-13 23:55:27.8` present; old shifted `2023-08-14 07:55:27.8` absent."
)
writeLines(report, file.path(out_root, "MT_flux_sector_pf_202307_202312_rerun_report.md"), useBytes = TRUE)

message(sprintf("Done | rows=%d | output=%s", nrow(flux), main_csv))
