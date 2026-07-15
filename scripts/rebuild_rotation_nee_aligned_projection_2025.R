#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
arg_value <- function(prefix, default = NULL) {
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) return(default)
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

year <- as.integer(arg_value("--year=", "2025"))
tower_filter <- toupper(arg_value("--tower=", "ALL"))
file_pattern_override <- arg_value("--file-pattern=", NULL)
reuse_intermediate <- "--reuse-intermediate" %in% args
tz <- "Asia/Shanghai"
methods <- c("no_rotation", "dr", "global_pf", "sector_pf")
rotation_codes <- c(no_rotation = "none", dr = "dr", global_pf = "pf", sector_pf = "spf")
output_root <- arg_value("--output-root=", sprintf("E:/Dataset_Level1/Rotation/nee_aligned_projection_%d_rebuild", year))
manifest_file <- "E:/Dataset_Level1/FixedTower/EC/fixed_tower_full_flux_standardized_30min_manifest.csv"
baseline_root <- "E:/Dataset_Level1/Rotation"
meta_paths <- c(MT = "D:/00EDDYPRO/sh_MT.metadata", CVT = "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata")
level0_roots <- c(MT = "E:/Dataset_Level0/MT/EC", CVT = "E:/Dataset_Level0/CVT/EC")

phase_root <- dirname(dirname(normalizePath(getwd(), winslash = "/")))
phase_dirs <- list.dirs(phase_root, recursive = TRUE, full.names = TRUE)
com_rotation_dir <- phase_dirs[basename(phase_dirs) == "com_rotation"][1L]
ecpreproc_dir <- phase_dirs[basename(phase_dirs) == "ecpreproc"][1L]
if (is.na(com_rotation_dir) || is.na(ecpreproc_dir)) stop("Cannot locate com_rotation/ecpreproc.", call. = FALSE)
source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")
load_ecpreproc(list(project_dir = output_root, package_dir = ecpreproc_dir, tz = tz))

manifest <- fread(manifest_file)
manifest <- manifest[product %in% as.vector(outer(c("MT", "CVT"), methods, paste, sep = "_"))]
manifest[, c("tower", "method") := tstrsplit(product, "_", fixed = TRUE, keep = c(1L, 2L))]
manifest[grepl("_global_pf$", product), method := "global_pf"]
manifest[grepl("_no_rotation$", product), method := "no_rotation"]
manifest[grepl("_sector_pf$", product), method := "sector_pf"]
if (tower_filter != "ALL") manifest <- manifest[tower == tower_filter]
if (!nrow(manifest)) stop("No products matched.", call. = FALSE)

fit_path <- function(input_file) sub("\\.csv$", "_rotation_details.rds", input_file)
snap_key <- function(x) {
  raw <- as.numeric(as.POSIXct(x, tz = tz))
  snapped <- round(raw / 1800) * 1800
  data.table(
    timestamp = format(as.POSIXct(snapped, origin = "1970-01-01", tz = tz), "%Y-%m-%d %H:%M:%S", tz = tz),
    snap_delta_sec = raw - snapped
  )
}

capture_processed_components <- function(data, l0) {
  required <- c("u", "v", "w", "w_rot", "w_rot_prime", "co2_prime", "rho_air", "rho_v")
  if (!all(required %in% names(data))) return(NULL)

  wind_ok <- complete.cases(data[, c("u", "v", "w", "w_rot")])
  cov_ok <- complete.cases(data[, c("u", "v", "w", "w_rot_prime", "co2_prime")])
  if (sum(wind_ok) < 4L || sum(cov_ok) < 2L) return(NULL)

  xyz <- as.matrix(data[wind_ok, c("u", "v", "w")])
  xyz <- sweep(xyz, 2L, colMeans(xyz), "-")
  w_rot_centered <- data$w_rot[wind_ok] - mean(data$w_rot[wind_ok])
  coefficients <- tryCatch(qr.solve(xyz, w_rot_centered), error = function(e) rep(NA_real_, 3L))
  if (any(!is.finite(coefficients))) return(NULL)
  names(coefficients) <- c("a", "b", "c")
  transform_residual <- max(abs(w_rot_centered - drop(xyz %*% coefficients)))

  cov_u_c <- cov(data$u[cov_ok], data$co2_prime[cov_ok])
  cov_v_c <- cov(data$v[cov_ok], data$co2_prime[cov_ok])
  cov_w_c <- cov(data$w[cov_ok], data$co2_prime[cov_ok])
  projected <- sum(coefficients * c(cov_u_c, cov_v_c, cov_w_c))

  data.table(
    timestamp_raw = as.POSIXct(l0$timestamp, tz = tz),
    cov_u_c_processed = cov_u_c,
    cov_v_c_processed = cov_v_c,
    cov_w_c_processed = cov_w_c,
    cov_w_rot_c_processed = l0$cov_wco2,
    rotation_a = coefficients[["a"]],
    rotation_b = coefficients[["b"]],
    rotation_c = coefficients[["c"]],
    raw_projection_sum = projected,
    raw_projection_residual = l0$cov_wco2 - projected,
    transform_fit_max_abs_residual = transform_residual,
    rho_air_mean = mean(data$rho_air, na.rm = TRUE),
    rho_v_mean = mean(data$rho_v, na.rm = TRUE),
    n_component_samples = sum(cov_ok)
  )
}

run_product <- function(row) {
  tower <- row$tower[[1L]]
  method <- row$method[[1L]]
  input_file <- row$input_file[[1L]]
  intermediate_file <- file.path(output_root, "_intermediate", sprintf("%s_%s_standardized_projection.csv", tower, method))
  if (reuse_intermediate && file.exists(intermediate_file)) {
    message(sprintf("[%s/%s] reusing intermediate table", tower, method))
    return(fread(intermediate_file, colClasses = list(character = "timestamp")))
  }
  fit <- NULL
  if (method %in% c("global_pf", "sector_pf")) {
    p <- fit_path(input_file)
    if (!file.exists(p)) stop("Missing rotation details: ", p, call. = FALSE)
    fit <- readRDS(p)
  }

  captures <- list()
  capture_n <- 0L
  original_calc <- calc_level0_fluxes
  calc_wrapper <- function(data, params, varnames, constants = list(k = 0.40, g = 9.81), measurement_height = NULL) {
    l0 <- original_calc(data = data, params = params, varnames = varnames, constants = constants, measurement_height = measurement_height)
    item <- capture_processed_components(data, l0)
    if (is.null(item)) item <- data.table(
      timestamp_raw = as.POSIXct(l0$timestamp, tz = tz),
      cov_u_c_processed = NA_real_, cov_v_c_processed = NA_real_, cov_w_c_processed = NA_real_,
      cov_w_rot_c_processed = l0$cov_wco2, rotation_a = NA_real_, rotation_b = NA_real_, rotation_c = NA_real_,
      raw_projection_sum = NA_real_, raw_projection_residual = NA_real_, transform_fit_max_abs_residual = NA_real_,
      rho_air_mean = NA_real_, rho_v_mean = NA_real_, n_component_samples = NA_integer_
    )
    capture_n <<- capture_n + 1L
    captures[[capture_n]] <<- item
    l0
  }
  assign("calc_level0_fluxes", calc_wrapper, envir = .GlobalEnv)
  on.exit(assign("calc_level0_fluxes", original_calc, envir = .GlobalEnv), add = TRUE)

  pattern <- if (is.null(file_pattern_override)) {
    sprintf("^TOA5_.*\\.Time_Series_.*_%d_.*\\.dat$", year)
  } else {
    file_pattern_override
  }
  message(sprintf("[%s/%s] processing pattern: %s", tower, method, pattern))
  result <- process_rep_flux(
    data_dir = level0_roots[[tower]],
    meta_data = ec_read_metadata(meta_paths[[tower]]),
    file_pattern = pattern,
    recursive = TRUE,
    tz = tz,
    rotation_method = rotation_codes[[method]],
    detrend_method = "block_average",
    qc_params = list(pf_params = list(allow_bias = TRUE, n_sectors = 12, min_points = 10, min_win = 50)),
    lag_params = list(),
    fit_results = fit,
    output_dir = NULL,
    show_progress = TRUE,
    keep_block_details = FALSE
  )
  assign("calc_level0_fluxes", original_calc, envir = .GlobalEnv)

  flux <- as.data.table(result$results)
  component <- rbindlist(captures, use.names = TRUE, fill = TRUE)
  flux[, timestamp_raw := as.POSIXct(timestamp, tz = tz)]
  flux[, occurrence := seq_len(.N), by = timestamp_raw]
  component[, occurrence := seq_len(.N), by = timestamp_raw]
  joined <- merge(flux, component, by = c("timestamp_raw", "occurrence"), all = FALSE, sort = FALSE)
  if (nrow(joined) != nrow(flux) || nrow(joined) != nrow(component)) {
    stop(sprintf("Capture join mismatch for %s/%s: flux=%d component=%d joined=%d", tower, method, nrow(flux), nrow(component), nrow(joined)), call. = FALSE)
  }

  joined[, rho_m_dry := (rho_air_mean - rho_v_mean) / 0.02896]
  joined[!is.finite(rho_m_dry) | rho_m_dry <= 10, rho_m_dry := 41.6]
  joined[, component_scale := rho_m_dry * scf_co2]
  joined[, `:=`(
    co2_flux_projection_u = component_scale * rotation_a * cov_u_c_processed,
    co2_flux_projection_v = component_scale * rotation_b * cov_v_c_processed,
    co2_flux_projection_w = component_scale * rotation_c * cov_w_c_processed
  )]
  joined[, co2_flux_projection_sum := co2_flux_projection_u + co2_flux_projection_v + co2_flux_projection_w]
  joined[, co2_flux_projection_residual := co2_flux - co2_flux_projection_sum]

  snap <- snap_key(joined$timestamp_raw)
  joined[, `:=`(timestamp_30min = as.character(snap$timestamp), snap_delta_sec = snap$snap_delta_sec)]
  joined <- joined[abs(snap_delta_sec) <= 120]
  numeric_out <- c(
    "co2_flux", "co2_flux_projection_u", "co2_flux_projection_v", "co2_flux_projection_w",
    "co2_flux_projection_sum", "co2_flux_projection_residual", "cov_u_c_processed",
    "cov_v_c_processed", "cov_w_c_processed", "cov_w_rot_c_processed", "rotation_a",
    "rotation_b", "rotation_c", "raw_projection_residual", "transform_fit_max_abs_residual",
    "rho_m_dry", "scf_co2", "n_component_samples", "snap_delta_sec"
  )
  standardized <- joined[, c(
    list(n_merged_rows = .N),
    lapply(.SD, function(x) mean(as.numeric(x), na.rm = TRUE))
  ), by = timestamp_30min, .SDcols = numeric_out]
  setnames(standardized, "timestamp_30min", "timestamp")
  standardized[, timestamp := as.character(timestamp)]
  standardized[, `:=`(tower = tower, method = method)]
  setcolorder(standardized, c("tower", "method", "timestamp", setdiff(names(standardized), c("tower", "method", "timestamp"))))
  intermediate_dir <- file.path(output_root, "_intermediate")
  dir.create(intermediate_dir, recursive = TRUE, showWarnings = FALSE)
  fwrite(standardized, intermediate_file)
  message(sprintf("[%s/%s] standardized rows=%d finite_projection=%d range=%s..%s",
                  tower, method, nrow(standardized), sum(is.finite(standardized$co2_flux_projection_sum)),
                  min(standardized$timestamp), max(standardized$timestamp)))
  standardized
}

all_results <- list()
for (tower_name in unique(manifest$tower)) {
  rows <- manifest[tower == tower_name][match(methods, method)]
  if (nrow(rows) != length(methods) || anyNA(rows$method)) stop("Incomplete four-method manifest for ", tower_name, call. = FALSE)

  baseline <- lapply(methods, function(method_name) {
    p <- file.path(baseline_root, tower_name, "hard_qc_baseline_30min", sprintf("%s_%s_hard_qc_baseline_30min.csv", tower_name, method_name))
    x <- fread(p, select = c("timestamp", "co2_flux"), colClasses = list(character = "timestamp"))
    x <- x[startsWith(timestamp, sprintf("%d-", year))]
    setnames(x, "co2_flux", method_name)
    x
  })
  names(baseline) <- methods
  baseline_wide <- Reduce(function(x, y) merge(x, y, by = "timestamp"), baseline)
  common_valid <- Reduce(`&`, lapply(baseline_wide[, ..methods], is.finite))
  common_keys <- as.character(baseline_wide[common_valid][["timestamp"]])

  method_results <- lapply(seq_len(nrow(rows)), function(i) run_product(rows[i]))
  names(method_results) <- methods
  for (method_name in methods) {
    method_results[[method_name]][, timestamp := as.character(timestamp)]
    message(sprintf("[%s/%s] hard-common timestamp matches=%d", tower_name, method_name,
                    sum(method_results[[method_name]]$timestamp %chin% common_keys)))
  }
  complete_keys <- Reduce(intersect, lapply(method_results, function(x) {
    x[timestamp %chin% common_keys & is.finite(co2_flux_projection_sum)][["timestamp"]]
  }))
  if (!length(complete_keys)) stop("No complete common projection windows for ", tower_name, call. = FALSE)

  site_dir <- file.path(output_root, tower_name)
  dir.create(site_dir, recursive = TRUE, showWarnings = FALSE)
  for (method_name in methods) {
    x <- method_results[[method_name]][timestamp %chin% complete_keys]
    ref <- baseline[[method_name]][, .(timestamp, co2_flux_baseline = get(method_name))]
    x <- merge(x, ref, by = "timestamp", all.x = TRUE, sort = FALSE)
    x[, rerun_minus_baseline_co2_flux := co2_flux - co2_flux_baseline]
    fwrite(x, file.path(site_dir, sprintf("%s_%s_nee_aligned_projection_%d.csv", tower_name, method_name, year)))
    method_results[[method_name]] <- x
  }

  reference <- method_results$no_rotation[, .(
    timestamp,
    ref_u = co2_flux_projection_u, ref_v = co2_flux_projection_v,
    ref_w = co2_flux_projection_w, ref_flux = co2_flux
  )]
  comparison <- rbindlist(lapply(methods, function(method_name) {
    x <- merge(method_results[[method_name]], reference, by = "timestamp", all.x = TRUE)
    x[, `:=`(
      delta_projection_u = co2_flux_projection_u - ref_u,
      delta_projection_v = co2_flux_projection_v - ref_v,
      delta_projection_w = co2_flux_projection_w - ref_w,
      delta_co2_flux = co2_flux - ref_flux
    )]
    x[, delta_projection_sum := delta_projection_u + delta_projection_v + delta_projection_w]
    x
  }))
  comparison[, `:=`(
    projection_closure_residual = co2_flux - co2_flux_projection_sum,
    delta_projection_closure_residual = delta_co2_flux - delta_projection_sum
  )]
  fwrite(comparison, file.path(site_dir, sprintf("%s_four_rotation_nee_aligned_projection_by_window_%d.csv", tower_name, year)))

  halfhour_gC <- 1800 * 12e-6
  summary <- comparison[, .(
    n_common_windows = .N,
    nee_rerun_gC_m2 = sum(co2_flux) * halfhour_gC,
    projection_u_gC_m2 = sum(co2_flux_projection_u) * halfhour_gC,
    projection_v_gC_m2 = sum(co2_flux_projection_v) * halfhour_gC,
    projection_w_gC_m2 = sum(co2_flux_projection_w) * halfhour_gC,
    delta_nee_gC_m2 = sum(delta_co2_flux) * halfhour_gC,
    delta_projection_u_gC_m2 = sum(delta_projection_u) * halfhour_gC,
    delta_projection_v_gC_m2 = sum(delta_projection_v) * halfhour_gC,
    delta_projection_w_gC_m2 = sum(delta_projection_w) * halfhour_gC,
    max_abs_flux_projection_residual = max(abs(projection_closure_residual), na.rm = TRUE),
    max_abs_delta_projection_residual = max(abs(delta_projection_closure_residual), na.rm = TRUE),
    max_abs_rerun_minus_baseline = max(abs(rerun_minus_baseline_co2_flux), na.rm = TRUE),
    max_abs_transform_fit_residual = max(abs(transform_fit_max_abs_residual), na.rm = TRUE)
  ), by = .(tower, method)]
  fwrite(summary, file.path(site_dir, sprintf("%s_four_rotation_nee_aligned_projection_summary_%d.csv", tower_name, year)))

  if (summary[, max(max_abs_flux_projection_residual)] > 1e-8 ||
      summary[, max(max_abs_delta_projection_residual)] > 1e-8 ||
      summary[, max(max_abs_transform_fit_residual)] > 1e-8 ||
      summary[, max(max_abs_rerun_minus_baseline)] > 1e-6) {
    stop("Projection closure validation failed for ", tower_name, call. = FALSE)
  }
  all_results[[tower_name]] <- summary
}

dir.create(output_root, recursive = TRUE, showWarnings = FALSE)
summary_suffix <- if (tower_filter == "ALL") "" else paste0("_", tower_filter)
fwrite(rbindlist(all_results), file.path(output_root, sprintf("four_rotation_nee_aligned_projection_summary_%d%s.csv", year, summary_suffix)))
