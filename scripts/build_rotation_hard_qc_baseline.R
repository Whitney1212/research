#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

# The source flux products already include calculation-stage hard QC.
# This step only freezes the standardized 30 min tables for rotation comparison.
manifest_file <- "E:/Dataset_Level1/FixedTower/EC/fixed_tower_full_flux_standardized_30min_manifest.csv"
output_root <- "E:/Dataset_Level1/Rotation"

stopifnot(file.exists(manifest_file))
manifest <- fread(manifest_file)
required <- c("product", "output_file")
stopifnot(all(required %in% names(manifest)))
manifest <- manifest[product != "MT_season_sector_pf"]

manifest[, c("site", "rotation_method") := tstrsplit(product, "_", fixed = TRUE, keep = c(1L, 2L))]
manifest[product %in% c("MT_global_pf", "CVT_global_pf"), rotation_method := "global_pf"]
manifest[product %in% c("MT_no_rotation", "CVT_no_rotation"), rotation_method := "no_rotation"]
manifest[product %in% c("MT_sector_pf", "CVT_sector_pf"), rotation_method := "sector_pf"]

manifest[, destination_file := file.path(
  output_root, site, "hard_qc_baseline_30min",
  sprintf("%s_%s_hard_qc_baseline_30min.csv", site, rotation_method)
)]

for (i in seq_len(nrow(manifest))) {
  source_file <- manifest$output_file[[i]]
  destination_file <- manifest$destination_file[[i]]
  if (!file.exists(source_file)) stop("Missing source table: ", source_file, call. = FALSE)
  dir.create(dirname(destination_file), recursive = TRUE, showWarnings = FALSE)
  file.copy(source_file, destination_file, overwrite = TRUE)
  if (!file.exists(destination_file) || file.info(destination_file)$size != file.info(source_file)$size) {
    stop("Copy verification failed: ", destination_file, call. = FALSE)
  }
}

manifest[, `:=`(
  qc_basis = "hard_qc_completed_during_flux_calculation",
  additional_filters_applied = "none",
  excluded_downstream_filters = "qc_co2,flag9_co2,night_ustar,stationarity,spectral_qc",
  comparison_role = "baseline_30min_flux"
)]

fwrite(
  manifest[, .(product, site, rotation_method, output_file, destination_file,
               qc_basis, additional_filters_applied, excluded_downstream_filters, comparison_role)],
  file.path(output_root, "rotation_hard_qc_baseline_manifest.csv")
)

# Small runnable check: every declared product has one byte-identical-size copy.
stopifnot(all(file.exists(manifest$destination_file)))
stopifnot(all(file.info(manifest$output_file)$size == file.info(manifest$destination_file)$size))
