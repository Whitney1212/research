#!/usr/bin/env Rscript

tz <- "Asia/Shanghai"
com_rotation_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
ecpreproc_dir <- "D:/00 博士阶段/博一/05 Project/ecpreproc"
mt_level0_root <- "E:/Dataset_Level0/MT/EC"
meta_path <- "D:/00EDDYPRO/sh_MT.metadata"
out_root <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/rerun_202401_202403_after_timefix"

dir.create(out_root, recursive = TRUE, showWarnings = FALSE)
source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")

cfg <- list(project_dir = out_root, package_dir = ecpreproc_dir, tz = tz)
load_ecpreproc(cfg)
meta <- ec_read_metadata(meta_path)

all_files <- sort(list.files(mt_level0_root, pattern = "^TOA5_.*\\.Time_Series_.*\\.dat$",
                             full.names = TRUE, recursive = TRUE))
files <- all_files[grepl("2024_(01|03)_", basename(all_files))]
if (length(files) == 0) stop("No MT TOA5 files found for 2024-01/03.")
dup <- names(which(table(basename(files)) > 1))
if (length(dup) > 0) stop("Duplicate basenames: ", paste(dup, collapse = ", "))

started <- Sys.time()
res <- process_rep_flux(
  data_dir = mt_level0_root,
  meta_data = meta,
  file_pattern = basename_pattern(files),
  recursive = TRUE,
  tz = tz,
  rotation_method = "spf",
  detrend_method = "block_average",
  qc_params = list(pf_params = list(allow_bias = TRUE, n_sectors = 12, min_points = 10, min_win = 50)),
  lag_params = list(),
  fit_results = NULL,
  output_dir = out_root,
  show_progress = TRUE,
  keep_block_details = FALSE
)
finished <- Sys.time()

if (is.null(res$results) || nrow(res$results) == 0) stop("process_rep_flux returned no rows.")
flux <- res$results
if (!inherits(flux$timestamp, "POSIXct")) flux$timestamp <- as.POSIXct(flux$timestamp, tz = tz)
month <- format(flux$timestamp, "%Y-%m", tz = tz)
flux <- flux[month %in% c("2024-01", "2024-03"), , drop = FALSE]
flux <- flux[order(flux$timestamp), , drop = FALSE]
if (nrow(flux) == 0) stop("No rows remain after month filtering.")

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

ts_posix <- flux$timestamp
flux$timestamp <- round_ts_text(format(ts_posix, "%Y-%m-%d %H:%M:%OS3", tz = tz))
if ("date" %in% names(flux)) flux$date <- substr(flux$timestamp, 1, 10)
if ("time" %in% names(flux)) flux$time <- substr(flux$timestamp, 12, 23)
flux$pf_scheme <- "sector_pf_202401_202403_after_timefix"

main_csv <- file.path(out_root, "MT_flux_sector_pf_202401_202403_after_timefix.csv")
utils::write.csv(flux, main_csv, row.names = FALSE, fileEncoding = "UTF-8")
saveRDS(res$details$config, file.path(out_root, "MT_flux_sector_pf_202401_202403_after_timefix_config.rds"))
if (!is.null(res$details$rotation)) {
  saveRDS(res$details$rotation, file.path(out_root, "MT_flux_sector_pf_202401_202403_after_timefix_rotation_details.rds"))
  if (!is.null(res$details$rotation$sector_summary)) {
    utils::write.csv(res$details$rotation$sector_summary,
                     file.path(out_root, "MT_sector_pf_202401_202403_sector_summary.csv"),
                     row.names = FALSE, fileEncoding = "UTF-8")
  }
}

has_time <- function(target) target %in% flux$timestamp
checks <- data.frame(
  check = c(
    "raw_20240103_start_present",
    "raw_20240115_start_present",
    "raw_20240315_start_present",
    "raw_20240331_start_present"
  ),
  value = c(
    has_time("2024-01-03 00:00:00.1"),
    has_time("2024-01-15 00:00:00.1"),
    has_time("2024-03-15 00:00:00.0"),
    has_time("2024-03-31 00:00:00.1")
  )
)
utils::write.csv(checks, file.path(out_root, "MT_flux_sector_pf_202401_202403_timefix_checks.csv"),
                 row.names = FALSE, fileEncoding = "UTF-8")
if (!all(checks$value)) stop("Timestamp self-check failed.")

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
utils::write.csv(summary, file.path(out_root, "MT_flux_sector_pf_202401_202403_rerun_summary.csv"),
                 row.names = FALSE, fileEncoding = "UTF-8")

message(sprintf("Done | files=%d | rows=%d | output=%s", length(files), nrow(flux), main_csv))
