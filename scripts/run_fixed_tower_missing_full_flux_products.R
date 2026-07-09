#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

arg_value <- function(prefix, default = NULL) {
  hit <- args[startsWith(args, prefix)]
  if (length(hit) == 0) return(default)
  sub(prefix, "", hit[1], fixed = TRUE)
}

jobs_arg <- arg_value("--jobs=", "mt_dr,cvt_dr,cvt_global_pf")
jobs_to_run <- trimws(strsplit(jobs_arg, ",", fixed = TRUE)[[1]])
jobs_to_run <- jobs_to_run[nzchar(jobs_to_run)]
max_files <- as.integer(arg_value("--max-files=", "0"))
if (!is.finite(max_files) || max_files < 0) max_files <- 0L
show_progress <- !("--no-progress" %in% args)

tz <- "Asia/Shanghai"
file_pattern <- "^TOA5_.*\\.Time_Series_.*\\.dat$"
com_rotation_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
ecpreproc_dir <- "D:/00 博士阶段/博一/05 Project/ecpreproc"

jobs <- list(
  mt_dr = list(
    level0_root = "E:/Dataset_Level0/MT/EC",
    meta_path = "D:/00EDDYPRO/sh_MT.metadata",
    out_root = "E:/Dataset_Level1/MT/EC/dr_ecpreproc",
    results_dir = "E:/Dataset_Level1/MT/EC/dr_ecpreproc/results",
    rotation_method = "dr",
    fit_results = NULL,
    main_csv = "MT_flux_dr.csv",
    run_summary_csv = "MT_flux_dr_run_summary.csv",
    validation_summary_csv = "MT_flux_dr_validation_summary.csv",
    phase_counts_csv = "MT_flux_dr_phase_counts.csv",
    config_rds = "MT_flux_dr_config.rds",
    rotation_rds = "MT_flux_dr_rotation_details.rds"
  ),
  cvt_dr = list(
    level0_root = "E:/Dataset_Level0/CVT/EC",
    meta_path = "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata",
    out_root = "E:/Dataset_Level1/CVT/EC/dr_ecpreproc",
    results_dir = "E:/Dataset_Level1/CVT/EC/dr_ecpreproc/results",
    rotation_method = "dr",
    fit_results = NULL,
    main_csv = "CVT_flux_dr.csv",
    run_summary_csv = "CVT_flux_dr_run_summary.csv",
    validation_summary_csv = "CVT_flux_dr_validation_summary.csv",
    phase_counts_csv = "CVT_flux_dr_phase_counts.csv",
    config_rds = "CVT_flux_dr_config.rds",
    rotation_rds = "CVT_flux_dr_rotation_details.rds"
  ),
  cvt_global_pf = list(
    level0_root = "E:/Dataset_Level0/CVT/EC",
    meta_path = "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata",
    out_root = "E:/Dataset_Level1/CVT/EC/PF/flux_runs/global_pf",
    results_dir = "E:/Dataset_Level1/CVT/EC/PF/flux_runs/global_pf",
    rotation_method = "pf",
    fit_results = NULL,
    main_csv = "CVT_flux_global_pf.csv",
    run_summary_csv = "CVT_flux_global_pf_run_summary.csv",
    validation_summary_csv = NULL,
    phase_counts_csv = NULL,
    config_rds = "CVT_flux_global_pf_config.rds",
    rotation_rds = "CVT_flux_global_pf_rotation_details.rds"
  )
)

bad_jobs <- setdiff(jobs_to_run, names(jobs))
if (length(bad_jobs) > 0) stop("Unknown jobs: ", paste(bad_jobs, collapse = ", "))

source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")
cfg <- list(project_dir = getwd(), package_dir = ecpreproc_dir, tz = tz)
load_ecpreproc(cfg)

required_flux_cols <- c("date", "time", "co2_flux", "H", "LE", "u_star", "rotation_method")

make_timestamp <- function(x) {
  if (!all(c("date", "time") %in% names(x))) stop("Missing date/time columns in flux output.")
  paste(x$date, x$time)
}

self_check <- function() {
  demo <- data.frame(date = "2024-11-01", time = "00:30", stringsAsFactors = FALSE)
  stopifnot(identical(make_timestamp(demo), "2024-11-01 00:30"))
}
self_check()

count_phase <- function(time_vec) {
  out <- as.data.frame(sort(table(sub("^.*:", "", time_vec)), decreasing = TRUE))
  names(out) <- c("minute_second", "n_rows")
  out
}

export_rotation_tables <- function(rotation, out_dir, prefix) {
  if (is.null(rotation) || !is.list(rotation)) return(invisible(NULL))
  for (nm in names(rotation)) {
    obj <- rotation[[nm]]
    if (!is.data.frame(obj)) next
    utils::write.csv(
      obj,
      file.path(out_dir, paste0(prefix, "_", nm, ".csv")),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
  }
  invisible(NULL)
}

run_job <- function(job_name) {
  job <- jobs[[job_name]]
  dir.create(job$out_root, recursive = TRUE, showWarnings = FALSE)
  dir.create(job$results_dir, recursive = TRUE, showWarnings = FALSE)

  files <- sort(list.files(
    job$level0_root,
    pattern = file_pattern,
    full.names = TRUE,
    recursive = TRUE
  ))
  if (max_files > 0) files <- files[seq_len(min(length(files), max_files))]
  if (length(files) == 0) stop("No input files found for job: ", job_name)

  message_ts("Running %s | files=%d | rotation=%s", job_name, length(files), job$rotation_method)
  started <- Sys.time()
  meta <- ec_read_metadata(job$meta_path)
  res <- process_rep_flux(
    data_dir = job$level0_root,
    meta_data = meta,
    file_pattern = if (max_files > 0) basename_pattern(files) else file_pattern,
    recursive = TRUE,
    tz = tz,
    rotation_method = job$rotation_method,
    detrend_method = "block_average",
    qc_params = list(
      pf_params = list(allow_bias = TRUE, n_sectors = 12, min_points = 10, min_win = 50)
    ),
    lag_params = list(),
    fit_results = job$fit_results,
    output_dir = job$out_root,
    show_progress = show_progress,
    keep_block_details = FALSE
  )
  finished <- Sys.time()

  if (is.null(res$results) || nrow(res$results) == 0) {
    stop("process_rep_flux returned no rows for job: ", job_name)
  }

  flux <- res$results
  missing_cols <- setdiff(required_flux_cols, names(flux))
  if (length(missing_cols) > 0) {
    stop("Missing required columns for job ", job_name, ": ", paste(missing_cols, collapse = ", "))
  }
  flux$timestamp <- make_timestamp(flux)

  rotation_values <- unique(stats::na.omit(as.character(flux$rotation_method)))
  if (!identical(rotation_values, job$rotation_method)) {
    stop(
      "rotation_method check failed for job ", job_name,
      ". Expected ", job$rotation_method,
      " but got: ", paste(rotation_values, collapse = ", ")
    )
  }

  main_csv <- file.path(job$results_dir, job$main_csv)
  utils::write.csv(flux, main_csv, row.names = FALSE, fileEncoding = "UTF-8")

  if (!is.null(res$details$config)) {
    saveRDS(res$details$config, file.path(job$results_dir, job$config_rds))
  }
  if (!is.null(res$details$rotation)) {
    saveRDS(res$details$rotation, file.path(job$results_dir, job$rotation_rds))
    export_rotation_tables(res$details$rotation, job$results_dir, tools::file_path_sans_ext(job$main_csv))
  }

  run_summary <- data.frame(
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
  utils::write.csv(
    run_summary,
    file.path(job$results_dir, job$run_summary_csv),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )

  if (!is.null(job$validation_summary_csv)) {
    validation <- data.frame(
      file = main_csv,
      n_rows = nrow(flux),
      first_timestamp = flux$timestamp[1],
      last_timestamp = flux$timestamp[nrow(flux)],
      duplicate_timestamp_count = nrow(flux) - length(unique(flux$timestamp)),
      rotation_method = job$rotation_method,
      required_columns_present = all(c("co2_flux", "H", "LE", "u_star") %in% names(flux)),
      stringsAsFactors = FALSE
    )
    utils::write.csv(
      validation,
      file.path(job$results_dir, job$validation_summary_csv),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
  }

  if (!is.null(job$phase_counts_csv)) {
    utils::write.csv(
      count_phase(flux$time),
      file.path(job$results_dir, job$phase_counts_csv),
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )
  }

  message_ts("Finished %s | rows=%d | output=%s", job_name, nrow(flux), main_csv)
  invisible(run_summary)
}

summaries <- lapply(jobs_to_run, run_job)
print(do.call(rbind, summaries))
