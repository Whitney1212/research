#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

input_manifest <- "E:/Dataset_Level1/Rotation/rotation_hard_qc_baseline_manifest.csv"
output_root <- "E:/Dataset_Level1/Rotation"
year <- 2025L
reference_method <- "no_rotation"
half_hour_gC_factor <- 1800 * 12e-6

stopifnot(file.exists(input_manifest))
products <- fread(input_manifest)
stopifnot(all(c("site", "rotation_method", "destination_file") %in% names(products)))
site_common_wide <- list()

read_flux <- function(file, method) {
  x <- fread(file, select = c("timestamp", "co2_flux"), colClasses = list(character = "timestamp"))
  x[, timestamp := substr(trimws(timestamp), 1L, 19L)]
  x <- x[startsWith(timestamp, sprintf("%d-", year))]
  x[, co2_flux := as.numeric(co2_flux)]
  if (anyDuplicated(x$timestamp)) stop("Duplicate timestamp in ", method, call. = FALSE)
  setnames(x, "co2_flux", method)
  x
}

for (site_name in unique(products$site)) {
  cases <- products[site == site_name]
  stopifnot(reference_method %in% cases$rotation_method)
  method_order <- c(reference_method, setdiff(cases$rotation_method, reference_method))
  cases <- cases[match(method_order, rotation_method)]

  wide <- Reduce(
    function(left, right) merge(left, right, by = "timestamp", all = TRUE, sort = TRUE),
    Map(read_flux, cases$destination_file, cases$rotation_method)
  )
  common_valid <- Reduce(`&`, lapply(wide[, ..method_order], is.finite))
  common <- wide[common_valid, c("timestamp", method_order), with = FALSE]

  long <- melt(common, id.vars = "timestamp", variable.name = "rotation_method", value.name = "co2_flux")
  long[, reference_co2_flux := common[[reference_method]][match(timestamp, common$timestamp)]]
  long[, delta_co2_flux := co2_flux - reference_co2_flux]
  long[, delta_nee_flux_gC_m2_halfhour := delta_co2_flux * half_hour_gC_factor]
  long[, cumulative_delta_nee_flux_gC_m2 := cumsum(delta_nee_flux_gC_m2_halfhour), by = rotation_method]

  summary <- long[, .(
    n_common_windows = .N,
    common_window_hours = .N * 0.5,
    delta_nee_flux_gC_m2 = sum(delta_nee_flux_gC_m2_halfhour),
    mean_delta_co2_flux_umol_m2_s = mean(delta_co2_flux)
  ), by = rotation_method]
  absolute <- data.table(
    rotation_method = method_order,
    nee_common_gC_m2 = vapply(method_order, function(method) sum(common[[method]]) * half_hour_gC_factor, numeric(1))
  )
  summary <- merge(summary, absolute, by = "rotation_method", sort = FALSE)
  reference_nee <- absolute[rotation_method == reference_method, nee_common_gC_m2]
  summary[, `:=`(
    nee_no_rotation_common_gC_m2 = reference_nee,
    R_abs_no_rotation_over_delta = fifelse(rotation_method == reference_method | delta_nee_flux_gC_m2 == 0,
                                            NA_real_, abs(reference_nee) / delta_nee_flux_gC_m2),
    delta_as_pct_of_no_rotation_common = if (abs(reference_nee) == 0) NA_real_ else 100 * abs(delta_nee_flux_gC_m2) / abs(reference_nee)
  )]
  summary[, `:=`(
    site = site_name,
    reference_method = reference_method,
    year = year,
    effect_component = "delta_NEE_flux_common_window",
    filters_not_applied = "qc_co2,flag9_co2,night_ustar,stationarity,spectral_qc,gapfill"
  )]
  setcolorder(summary, c("site", "year", "rotation_method", "reference_method", "effect_component",
                         "n_common_windows", "common_window_hours", "nee_common_gC_m2", "nee_no_rotation_common_gC_m2",
                         "delta_nee_flux_gC_m2", "R_abs_no_rotation_over_delta", "delta_as_pct_of_no_rotation_common",
                         "mean_delta_co2_flux_umol_m2_s", "filters_not_applied"))

  output_dir <- file.path(output_root, site_name, "common_window_flux_effect_2025")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  fwrite(long, file.path(output_dir, sprintf("%s_rotation_common_window_flux_effect_2025_by_halfhour.csv", site_name)))
  fwrite(summary, file.path(output_dir, sprintf("%s_rotation_common_window_flux_effect_2025_summary.csv", site_name)))
  site_common_wide[[site_name]] <- common

  # Small runnable check: reference is exactly zero and each summary is its half-hour sum.
  stopifnot(all(long[rotation_method == reference_method, delta_nee_flux_gC_m2_halfhour] == 0))
  check <- long[, .(recomputed = sum(delta_nee_flux_gC_m2_halfhour)), by = rotation_method]
  stopifnot(all.equal(check$recomputed, summary$delta_nee_flux_gC_m2, tolerance = 1e-12) == TRUE)
}

cross_keys <- Reduce(intersect, lapply(site_common_wide, function(x) x$timestamp))
cross_site <- rbindlist(lapply(names(site_common_wide), function(site_name) {
  x <- site_common_wide[[site_name]][timestamp %chin% cross_keys]
  rbindlist(lapply(setdiff(names(x), "timestamp"), function(method) data.table(
    site = site_name,
    rotation_method = method,
    n_cross_site_common_windows = nrow(x),
    nee_cross_site_common_gC_m2 = sum(x[[method]]) * half_hour_gC_factor
  )))
}))
cross_difference <- dcast(cross_site, rotation_method + n_cross_site_common_windows ~ site,
                          value.var = "nee_cross_site_common_gC_m2")
cross_difference[, mt_minus_cvt_nee_cross_site_common_gC_m2 := MT - CVT]
fwrite(cross_difference, file.path(output_root, "rotation_hard_qc_mt_minus_cvt_cross_site_common_2025.csv"))
