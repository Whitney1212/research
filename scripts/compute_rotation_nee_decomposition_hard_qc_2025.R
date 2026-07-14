#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

project_root <- "D:/00 博士阶段/99 Project/06 EA"
source(file.path(project_root, "scripts/estimate_fixed_tower_nee_2025.R"))

input_manifest <- "E:/Dataset_Level1/Rotation/rotation_hard_qc_baseline_manifest.csv"
output_root <- "E:/Dataset_Level1/Rotation"
year <- 2025L
gC_factor <- 1800 * 12e-6
products <- fread(input_manifest)

run_gapfill <- function(site_name, method, input_file, donor_file, donor_site) {
  output_dir <- file.path(output_root, site_name, "hard_qc_gapfill_2025", method)
  estimate_fixed_tower_nee(
    site = site_name,
    input_file = input_file,
    output_dir = output_dir,
    year = year,
    donor_input = donor_file,
    donor_site = donor_site,
    apply_qc_filter = FALSE,
    apply_flag9_filter = FALSE,
    apply_ustar_filter = FALSE,
    output_tag = "hard_qc_baseline"
  )
}

for (site_name in unique(products$site)) {
  other_site <- if (site_name == "MT") "CVT" else "MT"
  for (i in which(products$site == site_name)) {
    method <- products$rotation_method[[i]]
    donor_method <- if (method == "season_sector_pf") "sector_pf" else method
    donor <- products[site == other_site & rotation_method == donor_method, destination_file]
    if (length(donor) != 1L) stop("Missing donor product for ", site_name, " ", method, call. = FALSE)
    run_gapfill(site_name, method, products$destination_file[[i]], donor[[1L]], other_site)
  }
}

read_method <- function(site_name, method) {
  file <- file.path(output_root, site_name, "hard_qc_gapfill_2025", method,
                    sprintf("%s_nee_%d_estimate_hard_qc_baseline_30min_gapfilled.csv", site_name, year))
  x <- fread(file, select = c("timestamp_local", "flux_observed_final", "gapfilled_co2_flux"))
  setnames(x, "timestamp_local", "timestamp")
  setnames(x, c("flux_observed_final", "gapfilled_co2_flux"), c(paste0(method, "_observed"), paste0(method, "_full")))
  x
}
pairs <- data.table(
  site = c("MT", "MT", "MT", "CVT", "CVT"),
  method = c("dr", "global_pf", "sector_pf", "dr", "global_pf"),
  reference_method = c("no_rotation", "no_rotation", "no_rotation", "sector_pf", "sector_pf")
)
results <- list()
for (site_name in unique(pairs$site)) {
  methods <- products[site == site_name, rotation_method]
  wide <- Reduce(function(a, b) merge(a, b, by = "timestamp", all = TRUE, sort = TRUE),
                 lapply(methods, function(m) read_method(site_name, m)))
  observed_cols <- paste0(methods, "_observed")
  common_valid <- Reduce(`&`, lapply(wide[, ..observed_cols], is.finite))

  component <- rbindlist(lapply(methods, function(m) {
    observed <- wide[[paste0(m, "_observed")]]
    full <- wide[[paste0(m, "_full")]]
    data.table(
      method = m,
      nee_observed_common_gC_m2 = sum(observed[common_valid]) * gC_factor,
      nee_observed_self_gC_m2 = sum(observed, na.rm = TRUE) * gC_factor,
      nee_full_gapfilled_gC_m2 = sum(full) * gC_factor
    )
  }))
  component[, `:=`(
    site = site_name,
    n_common_windows = sum(common_valid),
    selection_effect_gC_m2 = nee_observed_self_gC_m2 - nee_observed_common_gC_m2,
    gapfill_effect_gC_m2 = nee_full_gapfilled_gC_m2 - nee_observed_self_gC_m2
  )]

  site_pairs <- pairs[site == site_name]
  for (j in seq_len(nrow(site_pairs))) {
    target <- component[method == site_pairs$method[[j]]]
    ref <- component[method == site_pairs$reference_method[[j]]]
    results[[length(results) + 1L]] <- data.table(
      site = site_name,
      method = target$method,
      reference_method = ref$method,
      n_common_windows = target$n_common_windows,
      common_window_flux_effect_gC_m2 = target$nee_observed_common_gC_m2 - ref$nee_observed_common_gC_m2,
      window_selection_effect_gC_m2 = target$selection_effect_gC_m2 - ref$selection_effect_gC_m2,
      gapfill_effect_gC_m2 = target$gapfill_effect_gC_m2 - ref$gapfill_effect_gC_m2,
      total_annual_difference_gC_m2 = target$nee_full_gapfilled_gC_m2 - ref$nee_full_gapfilled_gC_m2
    )
  }

  output_dir <- file.path(output_root, site_name, "nee_decomposition_2025")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  fwrite(component, file.path(output_dir, sprintf("%s_rotation_nee_components_hard_qc_2025.csv", site_name)))
}

results <- rbindlist(results)
results[, decomposition_residual_gC_m2 := total_annual_difference_gC_m2 -
  common_window_flux_effect_gC_m2 - window_selection_effect_gC_m2 - gapfill_effect_gC_m2]
stopifnot(all(abs(results$decomposition_residual_gC_m2) < 1e-9))
fwrite(results, file.path(output_root, "rotation_nee_decomposition_hard_qc_2025.csv"))
