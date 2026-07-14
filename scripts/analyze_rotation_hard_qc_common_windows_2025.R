#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

input_manifest <- "E:/Dataset_Level1/Rotation/rotation_hard_qc_baseline_manifest.csv"
output_root <- "E:/Dataset_Level1/Rotation"
year <- 2025L
reference_method <- "no_rotation"
half_hour_gC_factor <- 1800 * 12e-6

read_flux <- function(file, method, include_state = FALSE) {
  cols <- c("timestamp", "co2_flux")
  if (include_state) cols <- c(cols, "geo_wind_from_deg", "u_star", "z_L")
  x <- fread(file, select = cols, colClasses = list(character = "timestamp"))
  x[, timestamp := substr(trimws(timestamp), 1L, 19L)]
  x <- x[startsWith(timestamp, sprintf("%d-", year))]
  x[, co2_flux := as.numeric(co2_flux)]
  if (anyDuplicated(x$timestamp)) stop("Duplicate timestamp: ", file, call. = FALSE)
  if (include_state) x[, c("geo_wind_from_deg", "u_star", "z_L") := lapply(.SD, as.numeric),
                       .SDcols = c("geo_wind_from_deg", "u_star", "z_L")]
  setnames(x, "co2_flux", method)
  x
}

flux_summary <- function(x, by_cols) {
  x[, .(
    n_windows = .N,
    delta_nee_flux_gC_m2 = sum(delta_nee_flux_gC_m2_halfhour),
    mean_delta_co2_flux_umol_m2_s = mean(delta_co2_flux)
  ), by = c(by_cols, "rotation_method")]
}

sign_label <- function(x) fifelse(x > 0, "positive", fifelse(x < 0, "negative", "zero"))

products <- fread(input_manifest)
for (site_name in unique(products$site)) {
  cases <- products[site == site_name]
  methods <- c(reference_method, setdiff(cases$rotation_method, reference_method))
  cases <- cases[match(methods, rotation_method)]
  pieces <- Map(read_flux, cases$destination_file, cases$rotation_method, cases$rotation_method == reference_method)
  wide <- Reduce(function(left, right) merge(left, right, by = "timestamp", all = TRUE, sort = TRUE), pieces)
  valid <- Reduce(`&`, lapply(wide[, ..methods], is.finite))
  common <- wide[valid]
  common[, `:=`(
    month = as.integer(substr(timestamp, 6L, 7L)),
    hour = as.integer(substr(timestamp, 12L, 13L)),
    minute = as.integer(substr(timestamp, 15L, 16L))
  )]
  common[, halfhour := sprintf("%02d:%02d", hour, minute)]
  common[, wind_sector_30deg := fifelse(
    is.finite(geo_wind_from_deg), sprintf("%03d-%03d", floor((geo_wind_from_deg %% 360) / 30) * 30,
                                           floor((geo_wind_from_deg %% 360) / 30) * 30 + 30), NA_character_
  )]
  common[, stability_class := fifelse(
    !is.finite(z_L), NA_character_,
    fifelse(z_L < -0.1, "unstable", fifelse(z_L <= 0.1, "near_neutral", "stable"))
  )]
  common[, ustar_bin := cut(u_star, breaks = c(-Inf, 0.1, 0.2, 0.4, Inf), right = FALSE,
                             labels = c("<0.10", "0.10-<0.20", "0.20-<0.40", ">=0.40"))]

  long <- melt(common, id.vars = c("timestamp", "month", "hour", "halfhour", "wind_sector_30deg", "u_star", "ustar_bin", "z_L", "stability_class"),
               measure.vars = methods, variable.name = "rotation_method", value.name = "co2_flux")
  reference_flux <- common[[reference_method]][match(long$timestamp, common$timestamp)]
  long[, `:=`(
    reference_co2_flux = reference_flux,
    delta_co2_flux = co2_flux - reference_flux,
    delta_nee_flux_gC_m2_halfhour = (co2_flux - reference_flux) * half_hour_gC_factor,
    reference_sign = sign_label(reference_flux),
    method_sign = sign_label(co2_flux)
  )]
  long[, sign_changed := method_sign != reference_sign]

  by_month_hour <- flux_summary(long, c("month", "halfhour"))
  by_wind_sector <- flux_summary(long[!is.na(wind_sector_30deg)], "wind_sector_30deg")
  by_ustar_stability <- flux_summary(long[!is.na(ustar_bin) & !is.na(stability_class)], c("ustar_bin", "stability_class"))
  by_wind_sector_stability <- flux_summary(long[!is.na(wind_sector_30deg) & !is.na(stability_class)], c("wind_sector_30deg", "stability_class"))
  sign_summary <- long[, .(
    n_windows = .N,
    sign_changed_windows = sum(sign_changed),
    sign_changed_fraction = mean(sign_changed),
    delta_nee_flux_gC_m2 = sum(delta_nee_flux_gC_m2_halfhour)
  ), by = .(rotation_method, reference_sign, method_sign)]
  sign_cancellation <- sign_summary[rotation_method != reference_method, .(
    total_delta_nee_flux_gC_m2 = sum(delta_nee_flux_gC_m2),
    gross_absolute_group_contribution_gC_m2 = sum(abs(delta_nee_flux_gC_m2)),
    cancellation_rate = 1 - abs(sum(delta_nee_flux_gC_m2)) / sum(abs(delta_nee_flux_gC_m2)),
    sign_flip_gross_contribution_gC_m2 = sum(abs(delta_nee_flux_gC_m2[reference_sign != method_sign])),
    sign_flip_share_of_gross = sum(abs(delta_nee_flux_gC_m2[reference_sign != method_sign])) / sum(abs(delta_nee_flux_gC_m2))
  ), by = rotation_method]

  output_dir <- file.path(output_root, site_name, "hard_qc_common_window_diagnostics_2025")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  fwrite(long, file.path(output_dir, sprintf("%s_hard_qc_common_window_rotation_diagnostics_2025.csv", site_name)))
  fwrite(by_month_hour, file.path(output_dir, sprintf("%s_hard_qc_common_window_by_month_hour_2025.csv", site_name)))
  fwrite(by_wind_sector, file.path(output_dir, sprintf("%s_hard_qc_common_window_by_wind_sector_2025.csv", site_name)))
  fwrite(by_ustar_stability, file.path(output_dir, sprintf("%s_hard_qc_common_window_by_ustar_stability_2025.csv", site_name)))
  fwrite(by_wind_sector_stability, file.path(output_dir, sprintf("%s_hard_qc_common_window_by_wind_sector_stability_2025.csv", site_name)))
  fwrite(sign_summary, file.path(output_dir, sprintf("%s_hard_qc_common_window_flux_sign_2025.csv", site_name)))
  fwrite(sign_cancellation, file.path(output_dir, sprintf("%s_hard_qc_common_window_sign_flip_cancellation_2025.csv", site_name)))
  fwrite(data.table(
    site = site_name,
    requested_output = "u_prime_c_prime_v_prime_c_prime_w_prime_c_prime_projection",
    status = "not_available_from_current_30min_products",
    reason = "The 30 min products contain final co2_flux only; rotation-detail RDS files do not retain per-window covariance components.",
    required_input = "per-window u_prime_c_prime, v_prime_c_prime, w_prime_c_prime or the corresponding high-frequency rotated series"
  ), file.path(output_dir, sprintf("%s_hard_qc_common_window_covariance_projection_unavailable_2025.csv", site_name)))
  fwrite(data.table(
    requested_dimension = c("month_hour", "wind_direction_sector", "u_star", "stability_z_L", "horizontal_wind_speed", "rotation_angle", "u_prime_c_prime", "v_prime_c_prime", "w_prime_c_prime"),
    status = c("available", "available", "available", "available", "not_in_30min_flux_table", "not_in_30min_flux_table", "not_in_30min_flux_table", "not_in_30min_flux_table", "co2_flux_only_not_raw_covariance"),
    handling = c("summarised", "30 degree sectors", "reported as u_star; not labelled wind speed", "z_L classes", "requires high-frequency or additional 30 min diagnostics", "requires per-window rotation transform output", "requires high-frequency covariance output", "requires high-frequency covariance output", "reported only as final co2_flux, not as raw covariance")
  ), file.path(output_dir, sprintf("%s_hard_qc_common_window_dimension_availability_2025.csv", site_name)))

  # Small runnable check: every method's grouped month-hour sum reconstructs the common-window total.
  overall <- long[, .(overall = sum(delta_nee_flux_gC_m2_halfhour)), by = rotation_method]
  grouped <- by_month_hour[, .(grouped = sum(delta_nee_flux_gC_m2)), by = rotation_method]
  stopifnot(all.equal(overall$overall, grouped$grouped, tolerance = 1e-12) == TRUE)
}
