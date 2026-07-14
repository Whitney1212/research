#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

baseline_manifest <- "E:/Dataset_Level1/Rotation/rotation_hard_qc_baseline_manifest.csv"
output_root <- "E:/Dataset_Level1/Rotation"
year <- 2025L
reference_method <- "sector_pf"
half_hour_gC_factor <- 1800 * 12e-6

stopifnot(file.exists(baseline_manifest))
cases_all <- fread(baseline_manifest)

strict_file <- function(site, method) {
  file.path(
    "E:/Dataset_Level1", site, "EC", "whole year computation",
    "rotation_sensitivity_standardized_2025", method,
    sprintf("%s_nee_%d_estimate_30min_gapfilled.csv", site, year)
  )
}

read_case <- function(site, method) {
  file <- strict_file(site, method)
  if (!file.exists(file)) stop("Missing strict result: ", file, call. = FALSE)
  x <- fread(file, select = c("ts_key", "co2_flux", "flux_observed_final", "gapfilled_co2_flux"))
  setnames(x, "ts_key", "timestamp")
  if (anyDuplicated(x$timestamp)) stop("Duplicate timestamp in ", file, call. = FALSE)
  x[, `:=`(
    observed = as.logical(flux_observed_final),
    co2_flux = as.numeric(co2_flux),
    gapfilled_co2_flux = as.numeric(gapfilled_co2_flux),
    rotation_method = method
  )]
  x[is.na(observed), observed := FALSE]
  if (any(!is.finite(x$gapfilled_co2_flux))) stop("Non-finite gapfilled flux in ", file, call. = FALSE)
  x
}

for (site_name in unique(cases_all$site)) {
  methods <- cases_all[site == site_name, rotation_method]
  stopifnot(reference_method %in% methods)
  methods <- c(reference_method, setdiff(methods, reference_method))
  cases <- lapply(methods, function(method) read_case(site_name, method))
  names(cases) <- methods

  observed_wide <- Reduce(
    function(left, right) merge(left, right, by = "timestamp", all = TRUE, sort = TRUE),
    lapply(cases, function(x) {
      values <- x[observed == TRUE, .(timestamp, co2_flux)]
      setnames(values, "co2_flux", x$rotation_method[[1L]])
      values
    })
  )
  common_mask <- Reduce(`&`, lapply(methods, function(method) is.finite(observed_wide[[method]])))
  common <- observed_wide[common_mask, c("timestamp", methods), with = FALSE]

  absolute <- rbindlist(lapply(cases, function(x) {
    method <- x$rotation_method[[1L]]
    observed_self <- sum(x[observed == TRUE & is.finite(co2_flux), co2_flux]) * half_hour_gC_factor
    full_gapfilled <- sum(x$gapfilled_co2_flux) * half_hour_gC_factor
    observed_common <- sum(common[[method]]) * half_hour_gC_factor
    data.table(
      site = site_name,
      year = year,
      rotation_method = method,
      nee_observed_common_gC_m2 = observed_common,
      nee_observed_self_gC_m2 = observed_self,
      nee_full_gapfilled_gC_m2 = full_gapfilled,
      selection_effect_gC_m2 = observed_self - observed_common,
      gapfill_effect_gC_m2 = full_gapfilled - observed_self
    )
  }))

  reference <- absolute[rotation_method == reference_method]
  result <- merge(absolute, reference, by = c("site", "year"), suffixes = c("", "_reference"), allow.cartesian = TRUE)
  result[, `:=`(
    reference_method = reference_method,
    common_window_count = nrow(common),
    common_window_hours = nrow(common) * 0.5,
    common_window_flux_effect_vs_reference_gC_m2 = nee_observed_common_gC_m2 - nee_observed_common_gC_m2_reference,
    window_selection_effect_vs_reference_gC_m2 = selection_effect_gC_m2 - selection_effect_gC_m2_reference,
    gapfill_effect_vs_reference_gC_m2 = gapfill_effect_gC_m2 - gapfill_effect_gC_m2_reference,
    total_annual_difference_vs_reference_gC_m2 = nee_full_gapfilled_gC_m2 - nee_full_gapfilled_gC_m2_reference
  )]
  result[, decomposition_residual_gC_m2 := total_annual_difference_vs_reference_gC_m2 -
    common_window_flux_effect_vs_reference_gC_m2 - window_selection_effect_vs_reference_gC_m2 - gapfill_effect_vs_reference_gC_m2]
  result[, qc_context := "strict_qc_co2_le_1_flag9_co2_le_3_night_ustar; strict observed and gapfilled products"]

  keep <- c(
    "site", "year", "rotation_method", "reference_method", "common_window_count", "common_window_hours",
    "common_window_flux_effect_vs_reference_gC_m2", "window_selection_effect_vs_reference_gC_m2",
    "gapfill_effect_vs_reference_gC_m2", "total_annual_difference_vs_reference_gC_m2",
    "decomposition_residual_gC_m2", "nee_observed_common_gC_m2", "nee_observed_self_gC_m2",
    "nee_full_gapfilled_gC_m2", "qc_context"
  )
  output_dir <- file.path(output_root, site_name, "strict_nee_decomposition_2025")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  fwrite(result[, ..keep], file.path(output_dir, sprintf("%s_rotation_nee_decomposition_2025_vs_sector_pf.csv", site_name)))
  fwrite(absolute, file.path(output_dir, sprintf("%s_rotation_nee_decomposition_2025_absolute_components.csv", site_name)))

  # Small runnable check: the three effects reproduce every full annual difference.
  stopifnot(all(abs(result$decomposition_residual_gC_m2) < 1e-9))
}
