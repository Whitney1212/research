#!/usr/bin/env Rscript

tz <- "Asia/Shanghai"
com_rotation_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
ecpreproc_dir <- "D:/00 博士阶段/博一/05 Project/ecpreproc"
level0_root <- "E:/Dataset_Level0/CVT/EC"
meta_path <- "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata"
out_root <- "E:/Dataset_Level1/CVT/EC/PF"

dir.create(out_root, recursive = TRUE, showWarnings = FALSE)

source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")
cfg <- list(project_dir = out_root, package_dir = ecpreproc_dir, tz = tz)
load_ecpreproc(cfg)
meta <- ec_read_metadata(meta_path)

files <- list.files(level0_root, pattern = "^TOA5_.*\\.Time_Series_.*\\.dat$",
                    full.names = TRUE, recursive = TRUE)
files <- sort(files)
if (length(files) == 0) stop("No CVT Time_Series TOA5 files found.")
dup <- names(which(table(basename(files)) > 1))
if (length(dup) > 0) stop("Duplicate basenames: ", paste(dup, collapse = ", "))

started <- Sys.time()
res <- process_rep_flux(
  data_dir = level0_root,
  meta_data = meta,
  file_pattern = "^TOA5_.*\\.Time_Series_.*\\.dat$",
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
if (!all(c("date", "time") %in% names(flux))) stop("Missing date/time columns in flux output.")
flux$timestamp <- paste(flux$date, flux$time)
flux$pf_scheme <- "sector_pf"
main_csv <- file.path(out_root, "CVT_flux_sector_pf.csv")
utils::write.csv(flux, main_csv, row.names = FALSE, fileEncoding = "UTF-8")

saveRDS(res$details$config, file.path(out_root, "CVT_flux_sector_pf_config.rds"))
if (!is.null(res$details$rotation)) {
  saveRDS(res$details$rotation, file.path(out_root, "CVT_flux_sector_pf_rotation_details.rds"))
  if (!is.null(res$details$rotation$sector_summary)) {
    utils::write.csv(res$details$rotation$sector_summary,
                     file.path(out_root, "CVT_sector_pf_sector_summary.csv"),
                     row.names = FALSE, fileEncoding = "UTF-8")
  }
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
utils::write.csv(summary, file.path(out_root, "CVT_flux_sector_pf_run_summary.csv"),
                 row.names = FALSE, fileEncoding = "UTF-8")

message(sprintf("Done | files=%d | rows=%d | output=%s", length(files), nrow(flux), main_csv))
