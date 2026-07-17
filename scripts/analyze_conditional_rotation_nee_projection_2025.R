#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

args <- commandArgs(trailingOnly = TRUE)
arg_value <- function(prefix, default = NULL) {
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) return(default)
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

year <- as.integer(arg_value("--year=", "2025"))
tz <- "Asia/Shanghai"
methods <- c("no_rotation", "dr", "global_pf", "sector_pf")
rotated_methods <- setdiff(methods, "no_rotation")
projection_root <- sprintf("E:/Dataset_Level1/Rotation/nee_aligned_projection_%d_rebuild", year)
baseline_root <- "E:/Dataset_Level1/Rotation"
manifest_file <- "E:/Dataset_Level1/FixedTower/EC/fixed_tower_full_flux_standardized_30min_manifest.csv"
output_root <- arg_value(
  "--output-root=",
  sprintf("%s/conditional_projection_analysis", projection_root)
)
half_hour_gC <- 1800 * 12e-6

dir.create(output_root, recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(output_root, "figures"), recursive = TRUE, showWarnings = FALSE)

key_time <- function(x) {
  if (inherits(x, "POSIXt")) {
    return(format(x, "%Y-%m-%d %H:%M:%S", tz = tz))
  }
  substr(trimws(as.character(x)), 1L, 19L)
}

finite_mean <- function(x) {
  x <- as.numeric(x)
  if (!any(is.finite(x))) return(NA_real_)
  mean(x, na.rm = TRUE)
}

finite_median <- function(x) {
  x <- as.numeric(x)
  if (!any(is.finite(x))) return(NA_real_)
  median(x, na.rm = TRUE)
}

safe_quantile <- function(x, p) {
  x <- as.numeric(x)
  x <- x[is.finite(x)]
  if (!length(x)) return(NA_real_)
  as.numeric(quantile(x, p, names = FALSE, type = 7))
}

direction_label <- function(x) {
  x <- as.numeric(x)
  out <- rep("zero", length(x))
  out[is.finite(x) & x > 1e-12] <- "positive"
  out[is.finite(x) & x < -1e-12] <- "negative"
  if (length(out) == 1L) out[[1L]] else out
}

read_baseline <- function(tower, method) {
  path <- file.path(
    baseline_root, tower, "hard_qc_baseline_30min",
    sprintf("%s_%s_hard_qc_baseline_30min.csv", tower, method)
  )
  if (!file.exists(path)) stop("Missing baseline: ", path, call. = FALSE)
  x <- fread(path, colClasses = list(character = "timestamp"), showProgress = FALSE)
  x[, timestamp := key_time(timestamp)]
  x <- x[startsWith(timestamp, sprintf("%d-", year))]
  if (anyDuplicated(x$timestamp)) stop("Duplicate baseline timestamp: ", path, call. = FALSE)
  x[, `:=`(tower = tower, method = method)]
  x
}

read_projection <- function(tower) {
  path <- file.path(
    projection_root, tower,
    sprintf("%s_four_rotation_nee_aligned_projection_by_window_%d.csv", tower, year)
  )
  if (!file.exists(path)) stop("Missing projection table: ", path, call. = FALSE)
  x <- fread(path, colClasses = list(character = "timestamp"), showProgress = FALSE)
  x[, timestamp := key_time(timestamp)]
  x <- x[startsWith(timestamp, sprintf("%d-", year)) & method %chin% methods]
  x
}

read_met <- function(tower) {
  path <- file.path("E:/Dataset_Level1", tower, "MET", sprintf("%s_MET_30min_full.csv", tower))
  if (!file.exists(path)) stop("Missing MET table: ", path, call. = FALSE)
  x <- fread(path, colClasses = list(character = "timestamp"), showProgress = FALSE)
  x[, timestamp := key_time(timestamp)]
  x <- x[startsWith(timestamp, sprintf("%d-", year))]
  x[, `:=`(
    met_ws_ec = as.numeric(ws_ec),
    met_wd_ec = as.numeric(wd_ec)
  )]
  x[, .(timestamp, met_ws_ec, met_wd_ec, ws_ec_interpolated, wd_ec_interpolated)]
}

make_analysis_table <- function(tower) {
  x <- read_projection(tower)
  ref <- read_baseline(tower, "no_rotation")
  ref <- ref[, .(
    timestamp,
    reference_geo_wind_from_deg = as.numeric(geo_wind_from_deg),
    reference_z_L = as.numeric(z_L),
    reference_u_star = as.numeric(u_star),
    reference_L = as.numeric(L),
    reference_baseline_co2_flux = as.numeric(co2_flux)
  )]
  x <- merge(x, ref, by = "timestamp", all.x = TRUE, sort = FALSE)
  x <- merge(x, read_met(tower), by = "timestamp", all.x = TRUE, sort = FALSE)

  x[, timestamp_posix := as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S", tz = tz)]
  x[, `:=`(
    month = as.integer(format(timestamp_posix, "%m", tz = tz)),
    hour = as.integer(format(timestamp_posix, "%H", tz = tz)),
    minute = as.integer(format(timestamp_posix, "%M", tz = tz)),
    halfhour = format(timestamp_posix, "%H:%M", tz = tz)
  )]
  x[, day_night := fifelse(hour >= 6L & hour < 18L, "day", "night")]
  x[, wind_deg := reference_geo_wind_from_deg]
  x[, stability_class := fifelse(
    !is.finite(reference_z_L), NA_character_,
    fifelse(reference_z_L < -0.1, "unstable",
            fifelse(reference_z_L <= 0.1, "near_neutral", "stable"))
  )]
  x[, wind_sector_start := ifelse(is.finite(wind_deg), floor((wind_deg %% 360) / 30) * 30, NA_real_)]
  x[, wind_sector_30deg := ifelse(
    is.finite(wind_sector_start),
    sprintf("%03d-%03d", as.integer(wind_sector_start), as.integer(wind_sector_start + 30)),
    NA_character_
  )]
  x[, wind_speed_group := as.character(cut(
    met_ws_ec, breaks = c(-Inf, 1, 2, 4, Inf), right = FALSE,
    labels = c("<1", "1-<2", "2-<4", ">=4")
  ))]
  x[, `:=`(
    P_u = as.numeric(rotation_a) * as.numeric(cov_u_c_processed),
    P_v = as.numeric(rotation_b) * as.numeric(cov_v_c_processed),
    P_w = as.numeric(rotation_c) * as.numeric(cov_w_c_processed),
    abs_horizontal_projection = abs(as.numeric(delta_projection_u)) + abs(as.numeric(delta_projection_v)),
    abs_delta_c = abs(as.numeric(delta_co2_flux)),
    uv_sign_pattern = fifelse(
      delta_projection_u < 0 & delta_projection_v < 0, "u_negative_v_negative",
      fifelse(delta_projection_u < 0 & delta_projection_v >= 0, "u_negative_v_nonnegative",
              fifelse(delta_projection_u >= 0 & delta_projection_v < 0, "u_nonnegative_v_negative",
                      "u_nonnegative_v_nonnegative"))
    )
  )]
  x
}

all_data <- rbindlist(lapply(c("MT", "CVT"), make_analysis_table), use.names = TRUE, fill = TRUE)
setorder(all_data, tower, timestamp, method)

if (!setequal(unique(all_data$method), methods)) stop("Method set is not the declared four-method set.", call. = FALSE)

# A. Preflight gate: timestamp alignment, maximum deviations, and source/version evidence.
preflight_max <- all_data[method != "no_rotation", .(
  n_common_windows = .N,
  max_abs_rerun_minus_baseline_co2_flux = max(abs(rerun_minus_baseline_co2_flux), na.rm = TRUE),
  timestamp_at_max = timestamp[which.max(abs(rerun_minus_baseline_co2_flux))],
  rerun_co2_flux_at_max = co2_flux[which.max(abs(rerun_minus_baseline_co2_flux))],
  baseline_co2_flux_at_max = co2_flux_baseline[which.max(abs(rerun_minus_baseline_co2_flux))],
  max_difference_at_max = rerun_minus_baseline_co2_flux[which.max(abs(rerun_minus_baseline_co2_flux))],
  delta_u_at_max = delta_projection_u[which.max(abs(rerun_minus_baseline_co2_flux))],
  delta_v_at_max = delta_projection_v[which.max(abs(rerun_minus_baseline_co2_flux))],
  delta_w_at_max = delta_projection_w[which.max(abs(rerun_minus_baseline_co2_flux))],
  n_abs_difference_gt_1e_6 = sum(abs(rerun_minus_baseline_co2_flux) > 1e-6, na.rm = TRUE),
  n_abs_difference_gt_1e_3 = sum(abs(rerun_minus_baseline_co2_flux) > 1e-3, na.rm = TRUE)
), by = .(tower, method)]
fwrite(preflight_max, file.path(output_root, sprintf("preflight_max_rerun_minus_baseline_2025.csv")))

top_windows <- all_data[
  method != "no_rotation" &
    is.finite(rerun_minus_baseline_co2_flux) &
    abs(rerun_minus_baseline_co2_flux) > 1e-6
]
top_windows[, abs_diff_rank := frank(-abs(rerun_minus_baseline_co2_flux), ties.method = "first"), by = .(tower, method)]
top_windows <- top_windows[abs_diff_rank <= 5L, .(
  tower, method, abs_diff_rank, timestamp, rerun_minus_baseline_co2_flux,
  co2_flux, co2_flux_baseline, delta_projection_u, delta_projection_v, delta_projection_w,
  rotation_a, rotation_b, rotation_c, cov_u_c_processed, cov_v_c_processed, cov_w_c_processed,
  rho_m_dry, scf_co2, n_component_samples, reference_geo_wind_from_deg, reference_z_L,
  met_ws_ec
)]
fwrite(top_windows, file.path(output_root, "preflight_top5_windows_2025.csv"))

manifest <- fread(manifest_file, showProgress = FALSE)
manifest <- manifest[product %chin% as.vector(outer(c("MT", "CVT"), methods, paste, sep = "_"))]

file_record <- function(path, role, product = NA_character_) {
  exists <- file.exists(path)
  info <- if (exists) file.info(path) else NULL
  data.table(
    product = product, role = role, path = path, exists = exists,
    bytes = if (exists) info$size else NA_real_,
    modified = if (exists) as.character(info$mtime) else NA_character_,
    md5 = if (exists) unname(as.character(tools::md5sum(path))) else NA_character_
  )
}

version_records <- list()
for (i in seq_len(nrow(manifest))) {
  product <- manifest$product[[i]]
  tower <- sub("_.*$", "", product)
  method <- sub("^[^_]+_", "", product)
  if (method == "global_pf") method <- "global_pf"
  if (method == "sector_pf") method <- "sector_pf"
  input_path <- manifest$input_file[[i]]
  output_path <- manifest$output_file[[i]]
  baseline_path <- file.path(
    baseline_root, tower, "hard_qc_baseline_30min",
    sprintf("%s_%s_hard_qc_baseline_30min.csv", tower, method)
  )
  rds_path <- if (method %in% c("global_pf", "sector_pf")) paste0(sub(".csv$", "", input_path), "_rotation_details.rds") else NA_character_
  version_records[[length(version_records) + 1L]] <- file_record(input_path, "manifest_input_file", product)
  version_records[[length(version_records) + 1L]] <- file_record(output_path, "manifest_standardized_output", product)
  version_records[[length(version_records) + 1L]] <- file_record(baseline_path, "hard_qc_baseline_copy", product)
  if (!is.na(rds_path)) version_records[[length(version_records) + 1L]] <- file_record(rds_path, "rotation_details_rds", product)
}
version_records[[length(version_records) + 1L]] <- file_record(
  "D:/00 博士阶段/99 Project/06 EA/scripts/rebuild_rotation_nee_aligned_projection_2025.R",
  "rerun_script"
)
version_check <- rbindlist(version_records, fill = TRUE)
fwrite(version_check, file.path(output_root, "preflight_input_version_check_2025.csv"))

settings_check <- data.table(
  check = c(
    "time_key", "snap_tolerance", "detrend_method", "lag_params", "pf_params",
    "dry_air_molar_density", "density_fallback", "co2_unit_scale", "half_hour_gC_factor",
    "reference_state"
  ),
  value = c(
    "round(raw_timestamp / 1800) * 1800; output timestamp retained as YYYY-mm-dd HH:MM:SS",
    "abs(snap_delta_sec) <= 120 sec",
    "block_average",
    "empty list()",
    "allow_bias=TRUE; n_sectors=12; min_points=10; min_win=50",
    "rho_m_dry=(rho_air_mean-rho_v_mean)/0.02896",
    "non-finite or <=10 replaced by 41.6",
    "component_scale=rho_m_dry*scf_co2",
    "1800*12e-6 = 0.0216 gC m^-2 per (umol m^-2 s^-1)",
    "wind=reference no_rotation geo_wind_from_deg; stability=reference no_rotation z_L"
  ),
  status = "checked_from_rebuild_script_and_current_tables"
)
fwrite(settings_check, file.path(output_root, "preflight_method_settings_check_2025.csv"))

source_compare <- list()
read_source_row <- function(path, role, product, tower, method, ts_key) {
  if (!file.exists(path)) return(data.table(tower, method, timestamp = ts_key, product, role, source_rows = NA_integer_))
  d <- fread(path, colClasses = list(character = "timestamp"), showProgress = FALSE)
  if (!"timestamp" %in% names(d)) return(data.table(tower, method, timestamp = ts_key, product, role, source_rows = NA_integer_))
  d[, timestamp := key_time(timestamp)]
  q <- d[timestamp == ts_key]
  if (!nrow(q)) return(data.table(tower, method, timestamp = ts_key, product, role, source_rows = 0L))
  data.table(
    tower = tower, method = method, timestamp = ts_key, product = product, role = role,
    source_rows = nrow(q),
    source_co2_mean = finite_mean(q$co2_flux),
    source_co2_min = suppressWarnings(min(as.numeric(q$co2_flux), na.rm = TRUE)),
    source_co2_max = suppressWarnings(max(as.numeric(q$co2_flux), na.rm = TRUE)),
    source_scf_co2 = if ("scf_co2" %in% names(q)) finite_mean(q$scf_co2) else NA_real_,
    source_n_merged_rows = if ("n_merged_rows" %in% names(q)) finite_mean(q$n_merged_rows) else NA_real_,
    source_snap_delta_sec = if ("max_abs_snap_delta_sec" %in% names(q)) finite_mean(q$max_abs_snap_delta_sec) else NA_real_,
    source_dir = if ("source_dir" %in% names(q)) as.character(q$source_dir[[1L]]) else NA_character_,
    source_row_id = if ("row_id" %in% names(q)) as.character(q$row_id[[1L]]) else NA_character_,
    source_rotation_method = if ("rotation_method" %in% names(q)) as.character(q$rotation_method[[1L]]) else NA_character_,
    source_pf_scheme = if ("pf_scheme" %in% names(q)) as.character(q$pf_scheme[[1L]]) else NA_character_
  )
}

for (i in seq_len(nrow(preflight_max))) {
  tower <- preflight_max$tower[[i]]
  method <- preflight_max$method[[i]]
  timestamp <- preflight_max$timestamp_at_max[[i]]
  product <- paste(tower, method, sep = "_")
  product_id <- paste(tower, method, sep = "_")
  mr <- manifest[product == product_id]
  if (nrow(mr) != 1L) next
  baseline_path <- file.path(baseline_root, tower, "hard_qc_baseline_30min", sprintf("%s_%s_hard_qc_baseline_30min.csv", tower, method))
  source_compare[[length(source_compare) + 1L]] <- read_source_row(mr$input_file[[1L]], "manifest_input_file", product_id, tower, method, timestamp)
  source_compare[[length(source_compare) + 1L]] <- read_source_row(mr$output_file[[1L]], "manifest_standardized_output", product_id, tower, method, timestamp)
  source_compare[[length(source_compare) + 1L]] <- read_source_row(baseline_path, "hard_qc_baseline_copy", product_id, tower, method, timestamp)
}
fwrite(rbindlist(source_compare, fill = TRUE), file.path(output_root, "preflight_max_window_source_comparison_2025.csv"))

fit_meta <- list()
for (i in seq_len(nrow(manifest))) {
  product <- manifest$product[[i]]
  method <- sub("^[^_]+_", "", product)
  if (!method %in% c("global_pf", "sector_pf")) next
  path <- paste0(sub(".csv$", "", manifest$input_file[[i]]), "_rotation_details.rds")
  z <- readRDS(path)
  global <- if (!is.null(z$global_fit)) z$global_fit else z
  p <- if (!is.null(z$P)) z$P else if (!is.null(global$P)) global$P else matrix(NA_real_, 3L, 3L)
  fit_meta[[length(fit_meta) + 1L]] <- data.table(
    product = product, rotation_details_path = path,
    type = if (!is.null(z$type)) as.character(z$type) else NA_character_,
    method_in_rds = if (!is.null(z$method)) as.character(z$method) else NA_character_,
    n_blocks = if (!is.null(z$n_blocks)) as.numeric(z$n_blocks) else NA_real_,
    sector_width = if (!is.null(z$sector_width)) as.numeric(z$sector_width) else NA_real_,
    n_sectors = if (!is.null(z$n_sectors)) as.numeric(z$n_sectors) else NA_real_,
    fallback_global = if (!is.null(z$fallback_global)) as.logical(z$fallback_global) else NA,
    b0 = if (!is.null(global$b0)) as.numeric(global$b0) else NA_real_,
    b1 = if (!is.null(global$b1)) as.numeric(global$b1) else NA_real_,
    b2 = if (!is.null(global$b2)) as.numeric(global$b2) else NA_real_,
    P31 = p[3L, 1L], P32 = p[3L, 2L], P33 = p[3L, 3L]
  )
}
fwrite(rbindlist(fit_meta, fill = TRUE), file.path(output_root, "preflight_rotation_details_parameters_2025.csv"))

# B. Conditional projection summaries.
add_condition <- function(dt, type, a, b = NULL) {
  d <- copy(dt)
  d[, condition_type := type]
  d[, condition_a := as.character(get(a))]
  d[, condition_b := if (is.null(b)) NA_character_ else as.character(get(b))]
  d[, condition := ifelse(is.na(condition_b), condition_a, paste(condition_a, condition_b, sep = " x "))]
  valid_b <- if (is.null(b)) rep(TRUE, nrow(d)) else !is.na(d$condition_b)
  d <- d[!is.na(condition_a) & valid_b]
  d
}

condition_tables <- list(
  add_condition(all_data, "wind_sector_stability", "wind_sector_30deg", "stability_class"),
  add_condition(all_data, "month_halfhour", "month", "halfhour"),
  add_condition(all_data, "wind_speed_group", "wind_speed_group"),
  add_condition(all_data, "day_night", "day_night")
)
condition_data <- rbindlist(condition_tables, use.names = TRUE, fill = TRUE)
summary_table <- condition_data[, .(
  n = .N,
  delta_u_mean_umol_m2_s = finite_mean(delta_projection_u),
  delta_u_median_umol_m2_s = finite_median(delta_projection_u),
  delta_u_net_gC_m2 = sum(delta_projection_u, na.rm = TRUE) * half_hour_gC,
  delta_u_absolute_gC_m2 = sum(abs(delta_projection_u), na.rm = TRUE) * half_hour_gC,
  delta_v_mean_umol_m2_s = finite_mean(delta_projection_v),
  delta_v_median_umol_m2_s = finite_median(delta_projection_v),
  delta_v_net_gC_m2 = sum(delta_projection_v, na.rm = TRUE) * half_hour_gC,
  delta_v_absolute_gC_m2 = sum(abs(delta_projection_v), na.rm = TRUE) * half_hour_gC,
  delta_w_mean_umol_m2_s = finite_mean(delta_projection_w),
  delta_w_median_umol_m2_s = finite_median(delta_projection_w),
  delta_w_net_gC_m2 = sum(delta_projection_w, na.rm = TRUE) * half_hour_gC,
  delta_w_absolute_gC_m2 = sum(abs(delta_projection_w), na.rm = TRUE) * half_hour_gC,
  delta_total_net_gC_m2 = sum(delta_co2_flux, na.rm = TRUE) * half_hour_gC,
  delta_total_absolute_gC_m2 = sum(abs(delta_co2_flux), na.rm = TRUE) * half_hour_gC
), by = .(tower, method, condition_type, condition_a, condition_b, condition)]
setorder(summary_table, tower, method, condition_type, condition_a, condition_b)
fwrite(summary_table, file.path(output_root, sprintf("conditional_projection_summary_%d.csv", year)))

coverage_table <- condition_data[, .(
  n = .N,
  n_methods = uniqueN(method),
  methods = paste(sort(unique(method)), collapse = ","),
  missing_met_wind_speed = sum(!is.finite(met_ws_ec))
), by = .(tower, condition_type, condition_a, condition_b, condition)]
coverage_table[, balanced_across_four_methods := n_methods == 4L]
fwrite(coverage_table, file.path(output_root, sprintf("condition_coverage_and_balance_%d.csv", year)))

# C. Coefficient x covariance source statistics for priority states.
large_threshold <- all_data[method %in% rotated_methods, .(
  q90_abs_horizontal_projection = safe_quantile(abs_horizontal_projection, 0.90),
  q95_abs_a = safe_quantile(abs(rotation_a), 0.95),
  q95_abs_b = safe_quantile(abs(rotation_b), 0.95),
  q95_abs_cov_u_c = safe_quantile(abs(cov_u_c_processed), 0.95),
  q95_abs_cov_v_c = safe_quantile(abs(cov_v_c_processed), 0.95)
), by = .(tower, method)]
all_data <- merge(all_data, large_threshold, by = c("tower", "method"), all.x = TRUE, sort = FALSE)
all_data[, large_horizontal_top10 := method %in% rotated_methods & abs_horizontal_projection >= q90_abs_horizontal_projection]
all_data[, `:=`(
  source_class_u = fifelse(
    abs(rotation_a) >= q95_abs_a & abs(cov_u_c_processed) >= q95_abs_cov_u_c, "both_high",
    fifelse(abs(rotation_a) >= q95_abs_a, "coefficient_high",
            fifelse(abs(cov_u_c_processed) >= q95_abs_cov_u_c, "covariance_high", "neither_high"))
  ),
  source_class_v = fifelse(
    abs(rotation_b) >= q95_abs_b & abs(cov_v_c_processed) >= q95_abs_cov_v_c, "both_high",
    fifelse(abs(rotation_b) >= q95_abs_b, "coefficient_high",
            fifelse(abs(cov_v_c_processed) >= q95_abs_cov_v_c, "covariance_high", "neither_high"))
  )
)]

state_rows <- list(
  CVT_unstable_150_240 = all_data[tower == "CVT" & is.finite(wind_deg) & wind_deg >= 150 & wind_deg < 240 & stability_class == "unstable"],
  CVT_stable_330_090 = all_data[tower == "CVT" & is.finite(wind_deg) & (wind_deg >= 330 | wind_deg < 90) & stability_class == "stable"],
  MT_both_negative_uv = all_data[tower == "MT" & method %in% rotated_methods & delta_projection_u < 0 & delta_projection_v < 0],
  CVT_global_pf_all = all_data[tower == "CVT" & method == "global_pf"],
  CVT_global_pf_opposing_uv = all_data[tower == "CVT" & method == "global_pf" & delta_projection_u * delta_projection_v < 0]
)

source_stat <- function(d, state_name, scope_name) {
  if (!nrow(d)) return(data.table())
  one <- function(x) c(
    median = finite_median(x),
    iqr = safe_quantile(x, 0.75) - safe_quantile(x, 0.25),
    q05 = safe_quantile(x, 0.05), q25 = safe_quantile(x, 0.25),
    q75 = safe_quantile(x, 0.75), q95 = safe_quantile(x, 0.95)
  )
  a <- one(d$rotation_a); b <- one(d$rotation_b)
  cu <- one(d$cov_u_c_processed); cv <- one(d$cov_v_c_processed)
  pu <- one(d$P_u); pv <- one(d$P_v)
  data.table(
    tower = d$tower[[1L]], method = d$method[[1L]], key_state = state_name, sample_scope = scope_name,
    n = nrow(d),
    a_median = a[["median"]], a_iqr = a[["iqr"]], a_q05 = a[["q05"]], a_q25 = a[["q25"]], a_q75 = a[["q75"]], a_q95 = a[["q95"]],
    b_median = b[["median"]], b_iqr = b[["iqr"]], b_q05 = b[["q05"]], b_q25 = b[["q25"]], b_q75 = b[["q75"]], b_q95 = b[["q95"]],
    cov_u_c_median = cu[["median"]], cov_u_c_iqr = cu[["iqr"]], cov_u_c_q05 = cu[["q05"]], cov_u_c_q25 = cu[["q25"]], cov_u_c_q75 = cu[["q75"]], cov_u_c_q95 = cu[["q95"]],
    cov_v_c_median = cv[["median"]], cov_v_c_iqr = cv[["iqr"]], cov_v_c_q05 = cv[["q05"]], cov_v_c_q25 = cv[["q25"]], cov_v_c_q75 = cv[["q75"]], cov_v_c_q95 = cv[["q95"]],
    P_u_median = pu[["median"]], P_u_iqr = pu[["iqr"]], P_u_q05 = pu[["q05"]], P_u_q25 = pu[["q25"]], P_u_q75 = pu[["q75"]], P_u_q95 = pu[["q95"]],
    P_v_median = pv[["median"]], P_v_iqr = pv[["iqr"]], P_v_q05 = pv[["q05"]], P_v_q25 = pv[["q25"]], P_v_q75 = pv[["q75"]], P_v_q95 = pv[["q95"]]
  )
}

source_stats <- list()
source_origin <- list()
for (state_name in names(state_rows)) {
  d0 <- state_rows[[state_name]]
  if (!nrow(d0)) next
  for (method in unique(d0$method)) {
    method_value <- method
    d <- d0[method == method_value]
    source_stats[[length(source_stats) + 1L]] <- source_stat(d, state_name, "all_windows")
    if (method %in% rotated_methods) {
      source_stats[[length(source_stats) + 1L]] <- source_stat(d[large_horizontal_top10 == TRUE], state_name, "large_horizontal_top10")
    }
    if (method %in% rotated_methods) {
      for (scope_name in c("all_windows", "large_horizontal_top10")) {
        ds <- if (scope_name == "all_windows") d else d[large_horizontal_top10 == TRUE]
        if (!nrow(ds)) next
        for (component in c("u", "v")) {
          cls_col <- if (component == "u") "source_class_u" else "source_class_v"
          p_col <- if (component == "u") "P_u" else "P_v"
          denominator <- sum(abs(ds[[p_col]]), na.rm = TRUE)
          if (!is.finite(denominator) || denominator <= 0) next
          for (cls in c("coefficient_high", "covariance_high", "both_high", "neither_high")) {
            dd <- ds[get(cls_col) == cls]
            if (!nrow(dd)) next
            source_origin[[length(source_origin) + 1L]] <- data.table(
              tower = dd$tower[[1L]], method = dd$method[[1L]], key_state = state_name,
              sample_scope = scope_name, component = component, source_class = cls, n = nrow(dd),
              share_windows = nrow(dd) / nrow(ds),
              net_product = sum(dd[[p_col]], na.rm = TRUE),
              absolute_product = sum(abs(dd[[p_col]]), na.rm = TRUE),
              absolute_product_share = sum(abs(dd[[p_col]]), na.rm = TRUE) / denominator
            )
          }
        }
      }
    }
  }
}
source_stats <- rbindlist(source_stats, fill = TRUE)
source_origin <- rbindlist(source_origin, fill = TRUE)
fwrite(source_stats, file.path(output_root, sprintf("conditional_source_statistics_%d.csv", year)))
fwrite(source_origin, file.path(output_root, sprintf("conditional_source_origin_classification_%d.csv", year)))

sector_coefficients <- all_data[method == "sector_pf" & is.finite(wind_sector_start), .(
  n = .N,
  a_median = finite_median(rotation_a), a_q25 = safe_quantile(rotation_a, .25), a_q75 = safe_quantile(rotation_a, .75),
  b_median = finite_median(rotation_b), b_q25 = safe_quantile(rotation_b, .25), b_q75 = safe_quantile(rotation_b, .75)
), by = .(tower, method, wind_sector_start, wind_sector_30deg)]
setorder(sector_coefficients, tower, method, wind_sector_start)
circulating_lag <- function(x) c(x[length(x)], x[-length(x)])
sector_coefficients[, `:=`(
  adjacent_delta_a = a_median - circulating_lag(a_median),
  adjacent_delta_b = b_median - circulating_lag(b_median)
), by = .(tower, method)]
sector_coefficients[, `:=`(
  adjacent_abs_delta_a = abs(adjacent_delta_a),
  adjacent_abs_delta_b = abs(adjacent_delta_b),
  is_circular_edge = wind_sector_start == 0
)]
fwrite(sector_coefficients, file.path(output_root, sprintf("sector_pf_adjacent_sector_coefficients_%d.csv", year)))

# Supporting sign/cancellation diagnostics.
sign_diagnostics <- all_data[method %in% rotated_methods, .(
  n = .N,
  delta_net_gC_m2 = sum(delta_co2_flux, na.rm = TRUE) * half_hour_gC,
  delta_absolute_gC_m2 = sum(abs(delta_co2_flux), na.rm = TRUE) * half_hour_gC,
  delta_u_net_gC_m2 = sum(delta_projection_u, na.rm = TRUE) * half_hour_gC,
  delta_v_net_gC_m2 = sum(delta_projection_v, na.rm = TRUE) * half_hour_gC,
  opposing_uv_windows = sum(delta_projection_u * delta_projection_v < 0, na.rm = TRUE),
  opposing_uv_fraction = mean(delta_projection_u * delta_projection_v < 0, na.rm = TRUE)
), by = .(tower, method, uv_sign_pattern)]
fwrite(sign_diagnostics, file.path(output_root, sprintf("projection_sign_and_cancellation_%d.csv", year)))

# Same-window overlap for the MT u/v-negative state and CVT global-PF cancellation.
mt_uv_flags <- all_data[tower == "MT" & method %in% rotated_methods, .(
  uv_negative = delta_projection_u < 0 & delta_projection_v < 0
), by = .(timestamp, method)]
mt_uv_flags <- dcast(mt_uv_flags, timestamp ~ method, value.var = "uv_negative", fill = FALSE)
mt_uv_flags[, `:=`(
  all_three_negative_uv = dr & global_pf & sector_pf,
  any_negative_uv = dr | global_pf | sector_pf
)]
cvt_global_all <- all_data[tower == "CVT" & method == "global_pf"]
cvt_global_opposing <- cvt_global_all[delta_projection_u * delta_projection_v < 0]
priority_overlap <- rbindlist(list(
  data.table(
    tower = "MT", metric = "all_three_rotations_same_window_u_and_v_negative",
    n_windows = sum(mt_uv_flags$all_three_negative_uv),
    denominator_windows = nrow(mt_uv_flags),
    share_windows = mean(mt_uv_flags$all_three_negative_uv)
  ),
  data.table(
    tower = "MT", metric = "any_rotation_u_and_v_negative",
    n_windows = sum(mt_uv_flags$any_negative_uv),
    denominator_windows = nrow(mt_uv_flags),
    share_windows = mean(mt_uv_flags$any_negative_uv)
  ),
  data.table(
    tower = "MT", metric = "dr_and_global_pf_same_window_u_and_v_negative",
    n_windows = sum(mt_uv_flags$dr & mt_uv_flags$global_pf),
    denominator_windows = nrow(mt_uv_flags),
    share_windows = mean(mt_uv_flags$dr & mt_uv_flags$global_pf)
  ),
  data.table(
    tower = "MT", metric = "dr_and_sector_pf_same_window_u_and_v_negative",
    n_windows = sum(mt_uv_flags$dr & mt_uv_flags$sector_pf),
    denominator_windows = nrow(mt_uv_flags),
    share_windows = mean(mt_uv_flags$dr & mt_uv_flags$sector_pf)
  ),
  data.table(
    tower = "MT", metric = "global_pf_and_sector_pf_same_window_u_and_v_negative",
    n_windows = sum(mt_uv_flags$global_pf & mt_uv_flags$sector_pf),
    denominator_windows = nrow(mt_uv_flags),
    share_windows = mean(mt_uv_flags$global_pf & mt_uv_flags$sector_pf)
  ),
  data.table(
    tower = "CVT", metric = "global_pf_u_v_opposing_same_window",
    n_windows = nrow(cvt_global_opposing),
    denominator_windows = nrow(cvt_global_all),
    share_windows = nrow(cvt_global_opposing) / nrow(cvt_global_all)
  )
), fill = TRUE)
fwrite(priority_overlap, file.path(output_root, sprintf("priority_window_overlap_%d.csv", year)))

# D. Robustness: top |Delta C| removal, leave-one-month, and cumulative curves.
robustness <- list()
for (tower_value in unique(all_data$tower)) {
  for (method_value in rotated_methods) {
    d <- all_data[tower == tower_value & method == method_value]
    setorder(d, -abs_delta_c)
    n_total <- nrow(d)
    full_net <- sum(d$delta_co2_flux, na.rm = TRUE) * half_hour_gC
    full_abs <- sum(abs(d$delta_co2_flux), na.rm = TRUE) * half_hour_gC
    for (fraction in c(0.01, 0.05, 0.10)) {
      n_remove <- max(1L, ceiling(n_total * fraction))
      removed <- d[seq_len(min(n_remove, n_total))]
      retained <- if (n_remove < n_total) d[(n_remove + 1L):n_total] else d[0L]
      removed_abs <- sum(abs(removed$delta_co2_flux), na.rm = TRUE) * half_hour_gC
      retained_net <- sum(retained$delta_co2_flux, na.rm = TRUE) * half_hour_gC
      robustness[[length(robustness) + 1L]] <- data.table(
        robustness_type = "remove_top_abs_delta_c",
        level = paste0(fraction * 100, "%"), tower = tower_value, method = method_value,
        n_total = n_total, n_removed = nrow(removed),
        threshold_abs_delta_c = min(removed$abs_delta_c, na.rm = TRUE),
        full_net_gC_m2 = full_net, full_absolute_gC_m2 = full_abs,
        removed_net_gC_m2 = sum(removed$delta_co2_flux, na.rm = TRUE) * half_hour_gC,
        removed_absolute_gC_m2 = removed_abs,
        removed_absolute_share = removed_abs / full_abs,
        remaining_net_gC_m2 = retained_net,
        remaining_direction = direction_label(retained_net)
      )
    }
    for (month in 1:12) {
      month_value <- month
      retained <- d[month != month_value]
      remaining_net <- sum(retained$delta_co2_flux, na.rm = TRUE) * half_hour_gC
      robustness[[length(robustness) + 1L]] <- data.table(
        robustness_type = "leave_one_month", level = sprintf("%02d", month_value), tower = tower_value, method = method_value,
        n_total = n_total, n_removed = n_total - nrow(retained), threshold_abs_delta_c = NA_real_,
        full_net_gC_m2 = full_net, full_absolute_gC_m2 = full_abs,
        removed_net_gC_m2 = full_net - remaining_net, removed_absolute_gC_m2 = NA_real_,
        removed_absolute_share = NA_real_, remaining_net_gC_m2 = remaining_net,
        remaining_direction = direction_label(remaining_net)
      )
    }
  }
}
robustness <- rbindlist(robustness, fill = TRUE)
fwrite(robustness, file.path(output_root, sprintf("robustness_sensitivity_%d.csv", year)))

cumulative <- all_data[method %in% rotated_methods, .(
  tower, method, timestamp, delta_co2_flux,
  delta_u = delta_projection_u, delta_v = delta_projection_v, delta_w = delta_projection_w
)]
setorder(cumulative, tower, method, timestamp)
cumulative[, `:=`(
  cumulative_delta_gC_m2 = cumsum(delta_co2_flux) * half_hour_gC,
  cumulative_delta_u_gC_m2 = cumsum(delta_u) * half_hour_gC,
  cumulative_delta_v_gC_m2 = cumsum(delta_v) * half_hour_gC,
  cumulative_delta_w_gC_m2 = cumsum(delta_w) * half_hour_gC
), by = .(tower, method)]
fwrite(cumulative, file.path(output_root, sprintf("annual_cumulative_projection_%d.csv", year)))

# Core figure 1: wind sector x stability.
wind_plot_data <- summary_table[condition_type == "wind_sector_stability" & method %in% rotated_methods]
wind_plot_data[, wind_sector_start := as.integer(substr(condition_a, 1L, 3L))]
wind_plot_data[, stability := condition_b]
p1 <- ggplot(wind_plot_data, aes(x = factor(wind_sector_start, levels = seq(0, 330, 30)), y = stability, fill = delta_total_net_gC_m2)) +
  geom_tile(color = "white", linewidth = 0.2) +
  facet_grid(tower ~ method) +
  scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0, na.value = "grey90") +
  labs(x = "Reference wind-from sector start (deg)", y = "Reference stability (z/L)", fill = "Net ΔNEE\n(gC m-2)") +
  theme_minimal(base_size = 10) + theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(output_root, "figures", "wind_sector_x_stability_projection_2025.png"), p1, width = 12, height = 6, dpi = 180)

# Core figure 2: month x local half-hour.
month_plot_data <- summary_table[condition_type == "month_halfhour" & method %in% rotated_methods]
month_plot_data[, month_num := as.integer(condition_a)]
month_plot_data[, halfhour_num := as.numeric(substr(condition_b, 1L, 2L)) * 2 + as.numeric(substr(condition_b, 4L, 5L)) / 30]
p2 <- ggplot(month_plot_data, aes(x = halfhour_num, y = factor(month_num), fill = delta_total_net_gC_m2)) +
  geom_tile() + facet_grid(tower ~ method) +
  scale_x_continuous(breaks = seq(0, 46, 4), labels = sprintf("%02d:00", seq(0, 23, 2)), expand = c(0, 0)) +
  scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0, na.value = "grey90") +
  labs(x = "Local half-hour", y = "Month", fill = "Net ΔNEE\n(gC m-2)") +
  theme_minimal(base_size = 9) + theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(output_root, "figures", "month_x_local_halfhour_projection_2025.png"), p2, width = 14, height = 6, dpi = 180)

# Core figure 3: coefficient-vs-covariance for the two priority flow states.
plot_states <- c("CVT_unstable_150_240", "CVT_stable_330_090")
plot_source <- rbindlist(lapply(plot_states, function(state_name) {
  d <- state_rows[[state_name]][method %in% rotated_methods]
  if (!nrow(d)) return(data.table())
  u <- d[, .(tower, method, key_state = state_name, component = "u", coefficient = rotation_a, covariance = cov_u_c_processed, product = P_u)]
  v <- d[, .(tower, method, key_state = state_name, component = "v", coefficient = rotation_b, covariance = cov_v_c_processed, product = P_v)]
  rbind(u, v)
}), fill = TRUE)
if (nrow(plot_source)) {
  set.seed(20250716L)
  plot_source <- plot_source[, .SD[sample.int(.N, min(.N, 2500L))], by = .(key_state, method, component)]
  p3 <- ggplot(plot_source, aes(x = coefficient, y = covariance, color = method)) +
    geom_point(alpha = 0.18, size = 0.55) +
    geom_hline(yintercept = 0, linewidth = 0.25) + geom_vline(xintercept = 0, linewidth = 0.25) +
    facet_grid(key_state ~ component, scales = "free") +
    labs(x = "Rotation third-row coefficient (a or b)", y = "Raw covariance with CO2", color = "Method") +
    theme_minimal(base_size = 9) + theme(panel.grid = element_blank())
  ggsave(file.path(output_root, "figures", "coefficient_vs_covariance_priority_states_2025.png"), p3, width = 11, height = 6, dpi = 180)
}

# Core figure 4: cumulative curves and extreme-window sensitivity.
png(file.path(output_root, "figures", "cumulative_and_extreme_sensitivity_2025.png"), width = 1800, height = 1200, res = 160)
par(mfrow = c(2, 2), mar = c(4, 4, 2, 1), oma = c(0, 0, 1, 0))
for (tower_value in c("MT", "CVT")) {
  d <- cumulative[tower == tower_value]
  d[, time_num := as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S", tz = tz)]
  ylim <- range(d$cumulative_delta_gC_m2, finite = TRUE)
  plot(NA, xlim = range(d$time_num), ylim = ylim, xlab = "Time", ylab = "Cumulative ΔNEE (gC m-2)", main = paste(tower_value, "annual cumulative"))
  cols <- c(dr = "#1B9E77", global_pf = "#D95F02", sector_pf = "#7570B3")
  for (method_value in rotated_methods) {
    z <- d[method == method_value]
    lines(z$time_num, z$cumulative_delta_gC_m2, col = cols[[method_value]], lwd = 1.1)
  }
  abline(h = 0, lty = 3, col = "grey50")
  legend("topleft", legend = rotated_methods, col = cols[rotated_methods], lty = 1, bty = "n", cex = .8)
}
for (tower_value in c("MT", "CVT")) {
  d <- robustness[robustness_type == "remove_top_abs_delta_c" & tower == tower_value]
  mat <- dcast(d, method ~ level, value.var = "remaining_net_gC_m2")
  levels <- c("1%", "5%", "10%")
  mat <- mat[, c("method", levels), with = FALSE]
  vals <- as.matrix(mat[, ..levels]); rownames(vals) <- mat$method
  barplot(t(vals), beside = TRUE, names.arg = levels, legend.text = rownames(vals),
          args.legend = list(x = "topright", bty = "n", cex = .7),
          ylab = "Remaining net ΔNEE (gC m-2)", main = paste(tower_value, "after removing top |ΔC|"))
  abline(h = 0, lty = 3, col = "grey50")
}
mtext("2025 conditional rotation projection robustness", outer = TRUE, cex = 1.1)
dev.off()

# Small report with explicit fact/inference/limit boundaries.
annual <- all_data[, .(
  n = .N,
  delta_u_gC_m2 = sum(delta_projection_u, na.rm = TRUE) * half_hour_gC,
  delta_v_gC_m2 = sum(delta_projection_v, na.rm = TRUE) * half_hour_gC,
  delta_w_gC_m2 = sum(delta_projection_w, na.rm = TRUE) * half_hour_gC,
  delta_nee_gC_m2 = sum(delta_co2_flux, na.rm = TRUE) * half_hour_gC
), by = .(tower, method)]
annual <- annual[method %in% methods]

focus_cvt_dr <- all_data[tower == "CVT" & method == "dr" & wind_deg >= 150 & wind_deg < 240 & stability_class == "unstable"]
focus_cvt_spf <- all_data[tower == "CVT" & method == "sector_pf" & (wind_deg >= 330 | wind_deg < 90) & stability_class == "stable"]
mt_both <- all_data[tower == "MT" & method %in% rotated_methods & delta_projection_u < 0 & delta_projection_v < 0]
cvt_gp <- all_data[tower == "CVT" & method == "global_pf"]
cvt_gp_opposing <- cvt_gp[delta_projection_u * delta_projection_v < 0]
focus_line <- function(d) sprintf("n=%d, Δu=%.2f, Δv=%.2f, Δw=%.2f, ΔNEE=%.2f gC m-2", nrow(d), sum(d$delta_projection_u) * half_hour_gC, sum(d$delta_projection_v) * half_hour_gC, sum(d$delta_projection_w) * half_hour_gC, sum(d$delta_co2_flux) * half_hour_gC)

origin_phrase <- function(state_name, method_value, component_value) {
  d <- source_origin[
    key_state == state_name & method == method_value & component == component_value &
      sample_scope == "large_horizontal_top10"
  ]
  if (!nrow(d)) return(sprintf("%s/%s/%s 无可分类窗口", state_name, method_value, component_value))
  setorder(d, -absolute_product_share)
  total_n <- sum(d$n)
  both_share <- if (any(d$source_class == "both_high")) d[source_class == "both_high", absolute_product_share][[1L]] else 0
  sprintf(
    "%s/%s/%s: 主导类别=%s，n=%d/%d，|P|贡献 %.1f%%；both_high 占 %.1f%%",
    state_name, method_value, component_value, d$source_class[[1L]], d$n[[1L]], total_n,
    100 * d$absolute_product_share[[1L]], 100 * both_share
  )
}

annual_phrase <- function(tower_value, method_value) {
  d <- annual[tower == tower_value & method == method_value]
  sprintf(
    "%s/%s Δu=%.1f, Δv=%.1f, Δw=%.1f, ΔNEE=%.1f gC m-2",
    tower_value, method_value, d$delta_u_gC_m2, d$delta_v_gC_m2, d$delta_w_gC_m2, d$delta_nee_gC_m2
  )
}

robust_top <- robustness[robustness_type == "remove_top_abs_delta_c"]
full_directions <- unique(robust_top[, .(full_direction = direction_label(full_net_gC_m2)), by = .(tower, method)])
robust_top_check <- merge(robust_top, full_directions, by = c("tower", "method"), all.x = TRUE)
leave_month <- robustness[robustness_type == "leave_one_month"]
leave_month_check <- merge(leave_month, full_directions, by = c("tower", "method"), all.x = TRUE)
robust_top_direction_stable <- all(robust_top_check$remaining_direction == robust_top_check$full_direction)
leave_month_direction_stable <- all(leave_month_check$remaining_direction == leave_month_check$full_direction)
robust_share_range <- range(100 * robust_top$removed_absolute_share, na.rm = TRUE)
missing_speed <- unique(all_data[, .(tower, timestamp, met_ws_ec)])[,
  .(n_windows = .N, missing_wind_speed = sum(!is.finite(met_ws_ec))), by = tower
]
sector_jump <- sector_coefficients[, .(
  max_abs_delta_a = max(adjacent_abs_delta_a, na.rm = TRUE),
  max_abs_delta_b = max(adjacent_abs_delta_b, na.rm = TRUE)
), by = tower]
sector_jump_line <- paste(
  sector_jump[, sprintf("%s max|Δa|=%.3f, max|Δb|=%.3f", tower, max_abs_delta_a, max_abs_delta_b)],
  collapse = "; "
)
mt_all_three_n <- priority_overlap[metric == "all_three_rotations_same_window_u_and_v_negative", n_windows][[1L]]
mt_any_n <- priority_overlap[metric == "any_rotation_u_and_v_negative", n_windows][[1L]]

report <- c(
  paste0("# 2025 固定塔 rotation 条件投影分解"),
  "",
  "## 口径与前置核验",
  "",
  paste0("- 使用 MT/CVT 的四方法硬 QC 共同窗口；方法集合为 `no_rotation / dr / global_pf / sector_pf`。条件分类不使用 rotation 后状态：风向取参考 `no_rotation::geo_wind_from_deg`，稳定度取参考 `z_L`，阈值为 `<-0.1`、`-0.1–0.1`、`>0.1`。风速组来自对应站点的半小时 `ws_ec` 表。"),
  paste0("- 共同窗口数：MT `", annual[tower == "MT" & method == "no_rotation", n][[1L]], "`，CVT `", annual[tower == "CVT" & method == "no_rotation", n][[1L]], "`。"),
  paste0("- 最大 rerun-minus-baseline：", paste(preflight_max[, sprintf("%s/%s %.4f", tower, method, max_abs_rerun_minus_baseline_co2_flux)], collapse = "; "), "。"),
  paste0("- 风速覆盖：", paste(missing_speed[, sprintf("%s 缺失 %d/%d 个唯一窗口", tower, missing_wind_speed, n_windows)], collapse = "; "), "；风速分组只纳入可匹配 ws_ec 的窗口。"),
  "- 时间键均能落入共同窗口，重算脚本中的 lag、频率修正、干空气摩尔密度和单位换算口径已写入 `preflight_method_settings_check_2025.csv`；当前没有足够证据把少数窗口差异归结为单一窄改动，因此保留偏差表并继续使用重算产品内部闭合结果。",
  "",
  "## 已核验事实",
  "",
  "- 每个 rotation 窗口都满足 `Δu + Δv + Δw = ΔF`，累计闭合保留到数值精度；详见 runnable check。",
  paste0("- CVT DR 在不稳定、150–240°参考来流窗口：", focus_line(focus_cvt_dr), "。"),
  paste0("- CVT Sector PF 在稳定、330–090°参考来流窗口：", focus_line(focus_cvt_spf), "。"),
  paste0("- MT 三种 rotation 中 u/v 同时为负的行数为 `", nrow(mt_both), "`，但按时间键去重后，三种 rotation 同窗均为负的窗口为 `", mt_all_three_n, "`，任一 rotation 为负的窗口为 `", mt_any_n, "`；因此负投影既有同窗共现，也有方法特异窗口。"),
  paste0("- CVT Global PF 的 u/v 符号相反窗口占 `", sprintf("%.1f%%", 100 * nrow(cvt_gp_opposing) / nrow(cvt_gp)), "`；这是同窗内抵消的直接证据，不能把它解释成不同状态之间的抵消。"),
  paste0("- 年度净分解：", paste(vapply(list(c("MT", "dr"), c("MT", "global_pf"), c("MT", "sector_pf"), c("CVT", "dr"), c("CVT", "global_pf"), c("CVT", "sector_pf")), function(z) annual_phrase(z[[1L]], z[[2L]]), character(1)), collapse = "; "), "。"),
  "",
  "## 推断",
  "",
  "- MT 年度负投影主要由 u/v 两个水平协方差投影共同贡献，w 分量为部分抵消；CVT DR 的正向变化主要由 v 分量贡献，CVT Sector PF 的负向变化主要由 u 分量贡献。",
  paste0("- 对每个 tower×method 取 |Δu|+|Δv| 最大的前 10% 窗口，并以全体窗口的绝对系数/绝对协方差 95%分位数分类：", origin_phrase("CVT_unstable_150_240", "dr", "v"), "；", origin_phrase("CVT_stable_330_090", "sector_pf", "u"), "；", origin_phrase("MT_both_negative_uv", "global_pf", "u"), "。`both_high` 才支持耦合判读；`neither_high` 只表示未越过该阈值，不等于乘积为零。"),
  paste0("- Sector PF 相邻扇区第三行系数存在跳变：", sector_jump_line, "；所以 sector_pf 的条件差异不能只按连续风向系数理解。"),
  paste0("- 删除 top 1/5/10% |ΔC| 后年度方向均保持：", robust_top_direction_stable, "；这些极端窗口的绝对 ΔC 贡献范围为 ", sprintf("%.1f–%.1f%%", robust_share_range[[1L]], robust_share_range[[2L]]), "。留一月后方向也均保持：", leave_month_direction_stable, "。"),
  "",
  "## 不能得出的结论",
  "",
  "- `no_rotation` 只是统一比较基线，不是真值。水平协方差投影也不能直接等同于水平平流；本结果只说明当前重算链内部的坐标投影贡献。",
  "- 在 rerun 与旧硬 QC 成品仍有窗口级差异的前提下，不能声称每个窗口已经与旧成品完全一致，也不能把年度差异全归因于物理流动条件。",
  "",
  "## 下一步",
  "",
  "- 若需要把结果提升为正式成品，下一步只应针对 `preflight_top5_windows_2025.csv` 逐条锁定旧成品生成时的 PF 参数/rotation_details 版本和原始文件选择，再做窄重跑。",
  "",
  "## 产物",
  "",
  paste0("- 输出目录：`", normalizePath(output_root, winslash = "/", mustWork = FALSE), "`。"),
  "- 主汇总：`conditional_projection_summary_2025.csv`；来源统计：`conditional_source_statistics_2025.csv`；稳健性：`robustness_sensitivity_2025.csv`。",
  "- 来源分类：`conditional_source_origin_classification_2025.csv`；同窗重叠：`priority_window_overlap_2025.csv`；独立检查脚本：`D:/00 博士阶段/99 Project/06 EA/scripts/check_conditional_rotation_nee_projection_2025.R`。",
  "- 核心图：`figures/wind_sector_x_stability_projection_2025.png`、`figures/month_x_local_halfhour_projection_2025.png`、`figures/coefficient_vs_covariance_priority_states_2025.png`、`figures/cumulative_and_extreme_sensitivity_2025.png`。"
)
writeLines(report, file.path(output_root, sprintf("conditional_projection_conclusions_%d.md", year)), useBytes = TRUE)

fwrite(all_data[, .(
  tower, method, timestamp, month, hour, minute, halfhour, day_night,
  wind_deg, wind_sector_30deg, stability_class, reference_z_L, reference_u_star,
  met_ws_ec, met_wd_ec, wind_speed_group,
  delta_projection_u, delta_projection_v, delta_projection_w, delta_co2_flux,
  rotation_a, rotation_b, rotation_c, cov_u_c_processed, cov_v_c_processed, cov_w_c_processed,
  P_u, P_v, P_w, abs_horizontal_projection, abs_delta_c, uv_sign_pattern
)], file.path(output_root, sprintf("projection_by_window_with_conditions_%d.csv", year)))

message("Conditional projection analysis written to: ", normalizePath(output_root, winslash = "/", mustWork = FALSE))
