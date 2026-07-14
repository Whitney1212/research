#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

output_root <- "E:/Dataset_Level1/Rotation"
year <- 2025L
reference_method <- "no_rotation"
methods_by_site <- list(
  MT = c("no_rotation", "dr", "global_pf", "sector_pf"),
  CVT = c("no_rotation", "dr", "global_pf", "sector_pf")
)

read_method <- function(site, method) {
  file <- file.path(
    output_root, site, sprintf("hard_qc_common_window_covariance_%d", year),
    sprintf("%s_%s_common_four_method_valid_window_exchange_diagnostics_%d_hard_qc.csv", site, method, year)
  )
  if (!file.exists(file)) stop("Missing covariance product: ", file, call. = FALSE)
  x <- fread(file, select = c("ts_key", "method", "cov_w_rot_c", "projection_u_c", "projection_v_c", "projection_w_c", "projection_sum", "projection_residual"))
  if (anyDuplicated(x$ts_key)) stop("Duplicate timestamp: ", file, call. = FALSE)
  stopifnot(all(x$method == method))
  x
}

for (site in names(methods_by_site)) {
  methods <- methods_by_site[[site]]
  parts <- setNames(lapply(methods, function(method) read_method(site, method)), methods)
  keys <- Reduce(intersect, lapply(parts, function(x) x$ts_key))
  ref <- parts[[reference_method]][ts_key %chin% keys][order(ts_key)]
  output <- rbindlist(lapply(methods, function(method) {
    x <- parts[[method]][ts_key %chin% keys][order(ts_key)]
    stopifnot(identical(x$ts_key, ref$ts_key))
    data.table(
      site = site,
      year = year,
      ts_key = x$ts_key,
      rotation_method = method,
      reference_method = reference_method,
      cov_w_rot_c = x$cov_w_rot_c,
      delta_projection_u_c = x$projection_u_c - ref$projection_u_c,
      delta_projection_v_c = x$projection_v_c - ref$projection_v_c,
      delta_projection_w_c = x$projection_w_c - ref$projection_w_c,
      delta_cov_w_rot_c = x$cov_w_rot_c - ref$cov_w_rot_c,
      delta_projection_sum_c = x$projection_sum - ref$projection_sum,
      projection_closure_residual_c = (x$projection_sum - ref$projection_sum) - (x$cov_w_rot_c - ref$cov_w_rot_c)
    )
  }))
  output[, delta_projection_total_c := delta_projection_u_c + delta_projection_v_c + delta_projection_w_c]
  output[, `:=`(
    projection_u_share = fifelse(delta_projection_total_c == 0, NA_real_, delta_projection_u_c / delta_projection_total_c),
    projection_v_share = fifelse(delta_projection_total_c == 0, NA_real_, delta_projection_v_c / delta_projection_total_c),
    projection_w_share = fifelse(delta_projection_total_c == 0, NA_real_, delta_projection_w_c / delta_projection_total_c)
  )]
  summary <- output[, .(
    n_common_diagnostic_windows = .N,
    mean_delta_projection_u_c = mean(delta_projection_u_c),
    mean_delta_projection_v_c = mean(delta_projection_v_c),
    mean_delta_projection_w_c = mean(delta_projection_w_c),
    mean_delta_total_c = mean(delta_projection_total_c),
    sum_delta_projection_u_c = sum(delta_projection_u_c),
    sum_delta_projection_v_c = sum(delta_projection_v_c),
    sum_delta_projection_w_c = sum(delta_projection_w_c),
    sum_delta_total_c = sum(delta_projection_total_c),
    max_abs_window_closure_residual_c = max(abs(projection_closure_residual_c)),
    aggregate_closure_residual_c = sum(projection_closure_residual_c)
  ), by = .(site, year, rotation_method, reference_method)]
  summary[, `:=`(
    aggregate_projection_u_share = fifelse(sum_delta_total_c == 0, NA_real_, sum_delta_projection_u_c / sum_delta_total_c),
    aggregate_projection_v_share = fifelse(sum_delta_total_c == 0, NA_real_, sum_delta_projection_v_c / sum_delta_total_c),
    aggregate_projection_w_share = fifelse(sum_delta_total_c == 0, NA_real_, sum_delta_projection_w_c / sum_delta_total_c),
    units_note = "covariance units from high-frequency CO2 series; not density-converted NEE"
  )]
  output_dir <- file.path(output_root, site, sprintf("hard_qc_covariance_projection_%d", year))
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  fwrite(output, file.path(output_dir, sprintf("%s_hard_qc_covariance_projection_by_window_%d.csv", site, year)))
  fwrite(summary, file.path(output_dir, sprintf("%s_hard_qc_covariance_projection_summary_%d.csv", site, year)))

  # Small runnable check: three projection changes reconstruct the rotated vertical-covariance change.
  stopifnot(all(abs(output$projection_closure_residual_c) < 1e-12))
}
