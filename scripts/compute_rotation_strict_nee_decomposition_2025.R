#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

output_root <- "E:/Dataset_Level1/Rotation"
year <- 2025L
reference_method <- "no_rotation"
half_hour_gC_factor <- 1800 * 12e-6

read_method <- function(site, method) {
  file <- file.path(
    "E:/Dataset_Level1", site, "EC", "whole year computation",
    "rotation_sensitivity_standardized_2025", method,
    sprintf("%s_nee_%d_estimate_30min_gapfilled.csv", site, year)
  )
  if (!file.exists(file)) stop("Missing strict gapfill detail: ", file, call. = FALSE)
  x <- fread(file, select = c("ts_key", "flux_observed_final", "valid_final", "total_component_gC_m2"))
  if (anyDuplicated(x$ts_key)) stop("Duplicate strict timestamp: ", file, call. = FALSE)
  x[, `:=`(
    valid_final = as.logical(valid_final),
    flux_observed_final = as.numeric(flux_observed_final),
    total_component_gC_m2 = as.numeric(total_component_gC_m2)
  )]
  x[, observed_component_gC_m2 := fifelse(
    valid_final & is.finite(flux_observed_final),
    flux_observed_final * half_hour_gC_factor,
    0
  )]
  setnames(x, c("valid_final", "observed_component_gC_m2", "total_component_gC_m2"),
           c(paste0("valid_", method), paste0("observed_", method), paste0("full_", method)))
  x[, c("flux_observed_final") := NULL]
  x
}

methods_by_site <- list(
  MT = c("no_rotation", "dr", "global_pf", "sector_pf"),
  CVT = c("no_rotation", "dr", "global_pf", "sector_pf")
)
all_summaries <- list()

for (site in names(methods_by_site)) {
  methods <- methods_by_site[[site]]
  wide <- Reduce(function(left, right) merge(left, right, by = "ts_key", all = TRUE, sort = TRUE),
                 lapply(methods, function(method) read_method(site, method)))
  valid_cols <- paste0("valid_", methods)
  common_valid <- Reduce(`&`, lapply(wide[, ..valid_cols], function(x) !is.na(x) & x))

  absolute <- rbindlist(lapply(methods, function(method) {
    observed <- wide[[paste0("observed_", method)]]
    full <- wide[[paste0("full_", method)]]
    common <- sum(observed[common_valid], na.rm = TRUE)
    self <- sum(observed, na.rm = TRUE)
    full_value <- sum(full, na.rm = TRUE)
    data.table(
      site = site,
      year = year,
      method = method,
      n_common_windows = sum(common_valid),
      nee_observed_common_gC_m2 = common,
      nee_observed_self_gC_m2 = self,
      nee_full_gapfilled_gC_m2 = full_value,
      selection_effect_absolute_gC_m2 = self - common,
      gapfill_effect_absolute_gC_m2 = full_value - self
    )
  }))
  ref <- absolute[method == reference_method]
  stopifnot(nrow(ref) == 1L)
  summary <- copy(absolute)
  summary[, `:=`(
    reference_method = reference_method,
    common_window_flux_effect_gC_m2 = nee_observed_common_gC_m2 - ref$nee_observed_common_gC_m2,
    window_selection_effect_gC_m2 = selection_effect_absolute_gC_m2 - ref$selection_effect_absolute_gC_m2,
    gapfill_effect_gC_m2 = gapfill_effect_absolute_gC_m2 - ref$gapfill_effect_absolute_gC_m2,
    total_annual_nee_difference_gC_m2 = nee_full_gapfilled_gC_m2 - ref$nee_full_gapfilled_gC_m2
  )]
  summary[, decomposition_residual_gC_m2 := total_annual_nee_difference_gC_m2 -
    common_window_flux_effect_gC_m2 - window_selection_effect_gC_m2 - gapfill_effect_gC_m2]
  setcolorder(summary, c(
    "site", "year", "method", "reference_method", "n_common_windows",
    "common_window_flux_effect_gC_m2", "window_selection_effect_gC_m2", "gapfill_effect_gC_m2",
    "total_annual_nee_difference_gC_m2", "decomposition_residual_gC_m2",
    "nee_observed_common_gC_m2", "nee_observed_self_gC_m2", "nee_full_gapfilled_gC_m2",
    "selection_effect_absolute_gC_m2", "gapfill_effect_absolute_gC_m2"
  ))

  output_dir <- file.path(output_root, site, "strict_nee_decomposition_2025")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  fwrite(summary, file.path(output_dir, sprintf("%s_rotation_strict_nee_decomposition_2025.csv", site)))
  all_summaries[[site]] <- summary

  # Small runnable check: the three relative components reconstruct every total difference.
  stopifnot(all(abs(summary$decomposition_residual_gC_m2) < 1e-10))
}

fwrite(rbindlist(all_summaries), file.path(output_root, "rotation_strict_nee_decomposition_2025_all_sites.csv"))
