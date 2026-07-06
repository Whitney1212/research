#!/usr/bin/env Rscript

tz <- "Asia/Shanghai"
com_rotation_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
ecpreproc_dir <- "D:/00 博士阶段/博一/05 Project/ecpreproc"
out_root <- "E:/Dataset_Level1/FixedTower/EC/Flux_ecprecproc_no_rotation"
file_pattern <- "^TOA5_.*\\.Time_Series_.*\\.dat$"

source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")

cfg <- list(project_dir = out_root, package_dir = ecpreproc_dir, tz = tz)
load_ecpreproc(cfg)

sites <- list(
  MT = list(
    level0_root = "E:/Dataset_Level0/MT/EC",
    meta_path = "D:/00EDDYPRO/sh_MT.metadata"
  ),
  CVT = list(
    level0_root = "E:/Dataset_Level0/CVT/EC",
    meta_path = "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata"
  )
)

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

format_flux_timestamp <- function(ts) {
  if (!inherits(ts, "POSIXct")) ts <- as.POSIXct(ts, tz = tz)
  round_ts_text(format(ts, "%Y-%m-%d %H:%M:%OS3", tz = tz))
}

self_check <- function() {
  x <- as.POSIXct("2024-01-03 00:00:00.1", format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  stopifnot(identical(format_flux_timestamp(x), "2024-01-03 00:00:00.1"))
}
self_check()

run_site <- function(site, spec) {
  out_dir <- file.path(out_root, site)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  files <- sort(list.files(
    spec$level0_root,
    pattern = file_pattern,
    full.names = TRUE,
    recursive = TRUE
  ))
  if (length(files) == 0) stop("No TOA5 Time_Series files found for ", site)

  started <- Sys.time()
  meta <- ec_read_metadata(spec$meta_path)
  res <- process_rep_flux(
    data_dir = spec$level0_root,
    meta_data = meta,
    file_pattern = file_pattern,
    recursive = TRUE,
    tz = tz,
    rotation_method = "none",
    detrend_method = "block_average",
    qc_params = list(),
    lag_params = list(),
    fit_results = NULL,
    output_dir = out_dir,
    show_progress = TRUE,
    keep_block_details = FALSE
  )
  finished <- Sys.time()

  if (is.null(res$results) || nrow(res$results) == 0) {
    stop("process_rep_flux returned no rows for ", site)
  }

  flux <- res$results
  if (!"timestamp" %in% names(flux)) stop("Missing timestamp column for ", site)
  flux <- flux[order(flux$timestamp), , drop = FALSE]
  ts_text <- format_flux_timestamp(flux$timestamp)
  flux$timestamp <- ts_text
  if ("date" %in% names(flux)) flux$date <- substr(ts_text, 1, 10)
  if ("time" %in% names(flux)) flux$time <- substr(ts_text, 12, 23)
  flux$rotation_method <- "none"
  flux$flux_scheme <- "no_rotation"

  main_csv <- file.path(out_dir, paste0(site, "_flux_no_rotation.csv"))
  utils::write.csv(flux, main_csv, row.names = FALSE, fileEncoding = "UTF-8")

  if (!is.null(res$details$config)) {
    saveRDS(res$details$config, file.path(out_dir, paste0(site, "_flux_no_rotation_config.rds")))
  }
  if (!is.null(res$details$rotation)) {
    saveRDS(res$details$rotation, file.path(out_dir, paste0(site, "_flux_no_rotation_rotation_details.rds")))
  }

  validation <- data.frame(
    site = site,
    output_csv = main_csv,
    n_input_files = length(files),
    n_flux_rows = nrow(flux),
    first_timestamp = flux$timestamp[1],
    last_timestamp = flux$timestamp[nrow(flux)],
    n_duplicate_timestamp = nrow(flux) - length(unique(flux$timestamp)),
    rotation_requested = "none",
    timestamp_read_rule = "TOA5 timestamp column is read as character in ecpreproc::read_toa5(), then parsed with Asia/Shanghai.",
    started = as.character(started),
    finished = as.character(finished),
    elapsed_min = as.numeric(difftime(finished, started, units = "mins")),
    stringsAsFactors = FALSE
  )
  utils::write.csv(
    validation,
    file.path(out_dir, paste0(site, "_flux_no_rotation_validation_summary.csv")),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )

  phase <- as.data.frame(sort(table(sub("^.*:", "", flux$time)), decreasing = TRUE))
  names(phase) <- c("minute_second", "n_rows")
  utils::write.csv(
    phase,
    file.path(out_dir, paste0(site, "_flux_no_rotation_phase_counts.csv")),
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )

  validation
}

all_validation <- do.call(rbind, lapply(names(sites), function(site) run_site(site, sites[[site]])))
dir.create(out_root, recursive = TRUE, showWarnings = FALSE)
utils::write.csv(
  all_validation,
  file.path(out_root, "fixed_tower_flux_no_rotation_validation_summary.csv"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

print(all_validation)
