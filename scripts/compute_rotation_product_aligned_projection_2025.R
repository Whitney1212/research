#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
arg_value <- function(prefix, default) {
  hit <- args[startsWith(args, prefix)]
  if (length(hit) == 0L) return(default)
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

year <- as.integer(arg_value("--year=", "2025"))
tower_filter <- toupper(arg_value("--tower=", "ALL"))
tz <- "Asia/Shanghai"
methods <- c("no_rotation", "dr", "global_pf", "sector_pf")
rotation_method <- c(no_rotation = "none", dr = "dr", global_pf = "pf", sector_pf = "spf")
root <- "E:/Dataset_Level1/Rotation"
run_plan_file <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d/rotation_sensitivity_standardized_%d_run_plan.csv", year, year)
phase_root <- dirname(dirname(normalizePath(getwd(), winslash = "/")))
phase_dirs <- list.dirs(phase_root, recursive = TRUE, full.names = TRUE)
com_rotation_dir <- phase_dirs[basename(phase_dirs) == "com_rotation"][1L]
ecpreproc_dir <- phase_dirs[basename(phase_dirs) == "ecpreproc"][1L]
if (is.na(com_rotation_dir) || is.na(ecpreproc_dir)) stop("Cannot locate com_rotation or ecpreproc from project root.")
meta_paths <- c(MT = "D:/00EDDYPRO/sh_MT.metadata", CVT = "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata")
level0_roots <- c(MT = "E:/Dataset_Level0/MT/EC", CVT = "E:/Dataset_Level0/CVT/EC")

source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")
load_ecpreproc(list(project_dir = root, package_dir = ecpreproc_dir, tz = tz))

to_key <- function(x) {
  x <- as.POSIXct(x, tz = tz)
  format(as.POSIXct(floor(as.numeric(x) / 1800) * 1800, origin = "1970-01-01", tz = tz), "%Y-%m-%d %H:%M:%S", tz = tz)
}
fit_path <- function(input_file) sub("\\.csv$", "_rotation_details.rds", sub("_standardized_30min\\.csv$", ".csv", input_file))

run_plan <- fread(run_plan_file)[common_method == TRUE & method %in% methods]
if (tower_filter != "ALL") run_plan <- run_plan[tower == tower_filter]
if (nrow(run_plan) == 0L) stop("No matching run-plan rows.")

run_one <- function(row, common_keys) {
  method <- row$method[[1L]]
  tower <- row$tower[[1L]]
  fit <- NULL
  if (method %in% c("global_pf", "sector_pf")) {
    p <- fit_path(row$input_file[[1L]])
    if (!file.exists(p)) stop("Missing rotation details: ", p)
    fit <- readRDS(p)
  }
  message(sprintf("[%s/%s] product-aligned rerun started", tower, method))
  res <- process_rep_flux(
    data_dir = level0_roots[[tower]], meta_data = ec_read_metadata(meta_paths[[tower]]),
    file_pattern = sprintf("^TOA5_.*\\.Time_Series_.*_%d_.*\\.dat$", year), recursive = TRUE, tz = tz,
    rotation_method = rotation_method[[method]], detrend_method = "block_average",
    qc_params = list(pf_params = list(allow_bias = TRUE, n_sectors = 12, min_points = 10, min_win = 50)),
    lag_params = list(), fit_results = fit, show_progress = TRUE,
    keep_covariance_components = TRUE
  )
  out <- as.data.table(res$results)
  out[, ts_key := to_key(timestamp)]
  out <- out[ts_key %chin% common_keys]
  if (nrow(out) == 0L) stop("No common-window rows returned for ", tower, "/", method)
  setorder(out, ts_key)
  out[, .SD[1L], by = ts_key]
}

for (tower_name in unique(run_plan$tower)) {
  tower_plan <- run_plan[tower == tower_name][match(method, methods)]
  if (nrow(tower_plan) != length(methods)) stop("Incomplete method set for ", tower_name)
  base <- lapply(methods, function(method) {
    p <- file.path(root, tower_name, "hard_qc_baseline_30min", sprintf("%s_%s_hard_qc_baseline_30min.csv", tower_name, method))
    x <- fread(p, select = c("timestamp", "co2_flux"))
    x[, timestamp := format(timestamp, "%Y-%m-%d %H:%M:%S", tz = tz)]
    x <- x[startsWith(timestamp, sprintf("%d-", year))]
    setnames(x, "co2_flux", method)
    x
  })
  names(base) <- methods
  wide <- Reduce(function(x, y) merge(x, y, by = "timestamp"), base)
  common_keys <- wide[Reduce(`&`, lapply(.SD, is.finite)), timestamp, .SDcols = methods]
  results <- lapply(seq_len(nrow(tower_plan)), function(i) run_one(tower_plan[i], common_keys))
  names(results) <- methods
  complete_keys <- Reduce(intersect, lapply(results, function(x) x[is.finite(co2_flux_projection_sum) & is.finite(co2_flux), ts_key]))
  if (length(complete_keys) == 0L) stop("No complete aligned projections for ", tower_name)
  out_dir <- file.path(root, tower_name, sprintf("hard_qc_product_aligned_projection_%d", year))
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  for (method in methods) {
    x <- results[[method]][ts_key %chin% complete_keys]
    ref <- base[[method]][, .(ts_key = timestamp, co2_flux_baseline = get(method))]
    x <- merge(x, ref, by = "ts_key", all.x = TRUE, sort = FALSE)
    x[, rerun_minus_baseline_co2_flux := co2_flux - co2_flux_baseline]
    if (any(abs(x$co2_flux_projection_residual) > 1e-10, na.rm = TRUE)) stop("Projection closure failed for ", tower_name, "/", method)
    fwrite(x, file.path(out_dir, sprintf("%s_%s_hard_qc_product_aligned_projection_%d.csv", tower_name, method, year)))
  }
  summary <- rbindlist(lapply(methods, function(method) {
    x <- results[[method]][ts_key %chin% complete_keys]
    data.table(tower = tower_name, method = method, n_common_windows = nrow(x),
      max_abs_projection_residual = max(abs(x$co2_flux_projection_residual), na.rm = TRUE))
  }))
  fwrite(summary, file.path(out_dir, sprintf("%s_hard_qc_product_aligned_projection_%d_summary.csv", tower_name, year)))
}
