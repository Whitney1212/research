#!/usr/bin/env Rscript

# Export one 0-245 m pass-level comparison table without replacing either
# completed accumulation product.  Both methods use the same BPF-valid samples.
suppressPackageStartupMessages(library(data.table))

pair_runner <- "D:/00 博士阶段/99 Project/06 EA/scripts/run_fl_bpf_pf8_pair_air_accumulation.R"
Sys.setenv(FL_PAIR_SOURCE_ONLY = "1")
source(pair_runner, local = .GlobalEnv)

output_name <- "BPF_0_245_PF8_2ensemble_no_rotation_common_pass_pair_0_245m.csv"
motion_cols <- c(
  "up_time_fraction_BPF", "down_time_fraction_BPF", "zero_time_fraction_BPF", "mean_w_when_up_BPF_m_s", "mean_abs_w_when_down_BPF_m_s",
  "up_time_fraction_no_rotation_common", "down_time_fraction_no_rotation_common", "zero_time_fraction_no_rotation_common", "mean_w_when_up_no_rotation_common_m_s", "mean_abs_w_when_down_no_rotation_common_m_s"
)
co2_cols <- c("n_co2_common_valid", "co2_mean_ppm")
pair_required_cols <- c(pair_required_cols, motion_cols, co2_cols)

parse_args <- function(args) {
  o <- list(root = default_output_root, self_check = FALSE)
  for (a in args) {
    if (grepl("^--root=", a)) o$root <- sub("^--root=", "", a)
    else if (a == "--self-check") o$self_check <- TRUE
    else if (a %in% c("-h", "--help")) { cat("Usage: Rscript build_fl_bpf_no_rotation_pass_pair_0_245.R [--root=PATH] [--self-check]\n"); quit(save = "no", status = 0) }
    else stop("Unknown argument: ", a, call. = FALSE)
  }
  o
}

motion_summary <- function(w, dt) {
  n <- length(w); up <- w > 0; down <- w < 0
  q_up <- sum(w[up] * dt); q_down <- sum(-w[down] * dt)
  list(
    Q_up_m = q_up, Q_down_m = q_down, Q_net_m = q_up - q_down, Q_gross_m = q_up + q_down,
    up_time_fraction = sum(up) / n, down_time_fraction = sum(down) / n, zero_time_fraction = sum(w == 0) / n,
    mean_w_when_up_m_s = if (any(up)) mean(w[up]) else NA_real_,
    mean_abs_w_when_down_m_s = if (any(down)) mean(abs(w[down])) else NA_real_
  )
}

pair_empty_result_with_motion <- function(has_raw_candidate) {
  x <- as.data.table(pair_empty_result(has_raw_candidate))
  x[, (motion_cols) := lapply(motion_cols, function(...) NA_real_)]
  x[, (co2_cols) := lapply(co2_cols, function(...) NA_real_)]
  x
}

# This is the established paired mask, with only the requested sign-duration
# and conditional-speed summaries added to its returned row.
pair_flux_result <- function(pass, samples, fs_hz, params, has_raw_candidate) {
  empty <- pair_empty_result_with_motion(has_raw_candidate)
  if (is.null(samples) || !nrow(samples)) return(empty)
  setorder(samples, TIMESTAMP, RECORD, source_file); samples <- unique(samples, by = c("TIMESTAMP", "RECORD")); n_raw <- nrow(samples)
  diag_ok <- is.finite(samples$diag_sonic) & samples$diag_sonic == 0; n_diag <- sum(diag_ok)
  range_ok <- is.finite(samples$Ux) & is.finite(samples$Uy) & is.finite(samples$Uz) & abs(samples$Ux) <= 30 & abs(samples$Uy) <= 30 & sqrt(samples$Ux^2 + samples$Uy^2) <= 45 & abs(samples$Uz) <= 10
  samples[, Uz_shared := vm_despike_w(ifelse(diag_ok & range_ok, Uz, NA_real_))]
  base_ok <- is.finite(samples$Uz_shared); n_base <- sum(base_ok)
  if (!n_base) {
    empty[, `:=`(n_raw = n_raw, n_diag_sonic_zero = n_diag, n_base_valid = 0L, bpf_qc_reason = if (!n_diag) "no_diag_sonic_zero" else if (!any(diag_ok & range_ok)) "no_samples_after_range" else "no_samples_after_despike", no_rotation_common_qc_reason = bpf_qc_reason)]
    return(empty)
  }
  track_rad <- 129.551 * pi / 180
  samples[, `:=`(U_h_raw = sqrt(Ux^2 + Uy^2), wind_from_sonic_deg = (270 - atan2(Uy, Ux) * 180 / pi) %% 360)]
  samples[, wind_from_geo_rad := ((wind_from_sonic_deg + 300) %% 360) * pi / 180]
  samples[, `:=`(U_east = -U_h_raw * sin(wind_from_geo_rad), U_north = -U_h_raw * cos(wind_from_geo_rad))]
  samples[, `:=`(U_east_corrected = U_east + cart_speed_m_s * sin(track_rad), U_north_corrected = U_north + cart_speed_m_s * cos(track_rad))]
  breaks <- c(params$bin_min[1], params$bin_max); samples[, bin_id := findInterval(position, breaks, rightmost.closed = TRUE)]
  samples <- params[samples, on = "bin_id"]
  position_ok <- samples$running_interp_ok & is.finite(samples$position) & is.finite(samples$cart_speed_m_s) & samples$position >= 0 & samples$position <= 245
  parameter_ok <- position_ok & is.finite(samples$intercept_a) & is.finite(samples$slope_b_u) & is.finite(samples$slope_c_v)
  bpf_ok <- base_ok & parameter_ok
  n_running <- sum(samples$running_interp_ok, na.rm = TRUE); n_position <- sum(position_ok, na.rm = TRUE); n_parameter <- sum(parameter_ok, na.rm = TRUE); n_bpf <- sum(bpf_ok, na.rm = TRUE)
  if (!n_bpf) {
    reason <- if (!n_diag) "no_diag_sonic_zero" else if (!any(samples$running_interp_ok, na.rm = TRUE)) "no_running_record_interpolation" else if (!any(position_ok, na.rm = TRUE)) "no_position_or_speed_in_track" else "no_parameter_bin_match"
    empty[, `:=`(n_raw = n_raw, n_diag_sonic_zero = n_diag, n_base_valid = n_base, n_running_interpolated = n_running, n_position_in_track = n_position, n_parameter_bin = n_parameter, bpf_qc_reason = reason, no_rotation_common_qc_reason = reason)]
    return(empty)
  }
  samples[, w_bpf := Uz_shared - (intercept_a + slope_b_u * U_east_corrected + slope_c_v * U_north_corrected)]
  dt <- 1 / fs_hz; b <- motion_summary(samples$w_bpf[bpf_ok], dt); n <- motion_summary(samples$Uz_shared[bpf_ok], dt)
  co2_ok <- bpf_ok & is.finite(samples$CO2) & is.finite(samples$diag_irga) & samples$diag_irga == 0
  bins <- sort(unique(samples$bin_id[bpf_ok])); t_valid <- n_bpf / fs_hz; dur <- as.numeric(difftime(pass$end_time, pass$start_time, units = "secs"))
  as.data.table(list(
    n_raw = n_raw, n_diag_sonic_zero = n_diag, n_base_valid = n_base, n_running_interpolated = n_running, n_position_in_track = n_position, n_parameter_bin = n_parameter, n_bpf_valid = n_bpf, n_common_valid = n_bpf, bpf_valid_seconds = t_valid, common_valid_seconds = t_valid, bpf_coverage_fraction = t_valid / dur, common_coverage_fraction = t_valid / dur, n_bins_covered = length(bins), bin_ids_covered = paste(bins, collapse = ";"),
    Q_up_BPF_m = b$Q_up_m, Q_down_BPF_m = b$Q_down_m, Q_net_BPF_m = b$Q_net_m, Q_gross_BPF_m = b$Q_gross_m,
    Q_up_no_rotation_common_m = n$Q_up_m, Q_down_no_rotation_common_m = n$Q_down_m, Q_net_no_rotation_common_m = n$Q_net_m, Q_gross_no_rotation_common_m = n$Q_gross_m,
    up_time_fraction_BPF = b$up_time_fraction, down_time_fraction_BPF = b$down_time_fraction, zero_time_fraction_BPF = b$zero_time_fraction, mean_w_when_up_BPF_m_s = b$mean_w_when_up_m_s, mean_abs_w_when_down_BPF_m_s = b$mean_abs_w_when_down_m_s,
    up_time_fraction_no_rotation_common = n$up_time_fraction, down_time_fraction_no_rotation_common = n$down_time_fraction, zero_time_fraction_no_rotation_common = n$zero_time_fraction, mean_w_when_up_no_rotation_common_m_s = n$mean_w_when_up_m_s, mean_abs_w_when_down_no_rotation_common_m_s = n$mean_abs_w_when_down_m_s,
    n_co2_common_valid = sum(co2_ok), co2_mean_ppm = if (any(co2_ok)) mean(samples$CO2[co2_ok]) else NA_real_,
    BPF_closure_net_error = b$Q_net_m - sum(samples$w_bpf[bpf_ok] * dt), BPF_closure_gross_error = b$Q_gross_m - sum(abs(samples$w_bpf[bpf_ok]) * dt), no_rotation_common_closure_net_error = n$Q_net_m - sum(samples$Uz_shared[bpf_ok] * dt), no_rotation_common_closure_gross_error = n$Q_gross_m - sum(abs(samples$Uz_shared[bpf_ok]) * dt),
    bpf_qc_status = "ok", bpf_qc_reason = "ok", no_rotation_common_qc_status = "ok", no_rotation_common_qc_reason = "ok"
  ))
}

method_columns <- function(x, method) {
  suffix <- if (method == "BPF") "BPF" else "no_rotation_common"
  prefix <- if (method == "BPF") "BPF" else "no_rotation"
  up <- x[[paste0("Q_up_", suffix, "_m")]]; down <- x[[paste0("Q_down_", suffix, "_m")]]; net <- x[[paste0("Q_net_", suffix, "_m")]]; gross <- x[[paste0("Q_gross_", suffix, "_m")]]; seconds <- x$common_valid_seconds
  setNames(list(up, down, net, gross, up / seconds, down / seconds, net / seconds, gross / seconds, fifelse(gross > 0, net / gross, NA_real_), x[[paste0("up_time_fraction_", suffix)]], x[[paste0("down_time_fraction_", suffix)]], x[[paste0("zero_time_fraction_", suffix)]], x[[paste0("mean_w_when_up_", suffix, "_m_s")]], x[[paste0("mean_abs_w_when_down_", suffix, "_m_s")]]), c(paste0("Q_up_", prefix, "_m"), paste0("Q_down_", prefix, "_m"), paste0("Q_net_", prefix, "_m"), paste0("Q_gross_", prefix, "_m"), paste0("q_up_", prefix, "_m_s"), paste0("q_down_", prefix, "_m_s"), paste0("q_net_", prefix, "_m_s"), paste0("q_gross_", prefix, "_m_s"), paste0("I_A_", prefix), paste0("f_up_", prefix), paste0("f_down_", prefix), paste0("f_zero_", prefix), paste0("mean_w_when_up_", prefix, "_m_s"), paste0("mean_abs_w_when_down_", prefix, "_m_s")))
}

atomic_fwrite_pair <- function(x, path) {
  tmp <- paste0(path, ".tmp.", Sys.getpid()); on.exit(unlink(tmp), add = TRUE)
  fwrite(x, tmp, na = "")
  if (file.exists(path)) unlink(path)
  if (!file.rename(tmp, path)) stop("Could not publish ", path, call. = FALSE)
}

validate_pair_table <- function(x, prior) {
  ok <- x[is_common_valid == TRUE]
  stopifnot(nrow(x) == nrow(prior), !anyDuplicated(x$pass_uid), all(x$track_scope == "0_245_m"), identical(x$pass_uid, prior$pass_uid), identical(x$bpf_qc_status, prior$bpf_qc_status), identical(x$no_rotation_common_qc_status, prior$no_rotation_common_qc_status))
  for (method in c("BPF", "no_rotation")) {
    up <- ok[[paste0("Q_up_", method, "_m")]]; down <- ok[[paste0("Q_down_", method, "_m")]]; net <- ok[[paste0("Q_net_", method, "_m")]]; gross <- ok[[paste0("Q_gross_", method, "_m")]]
    stopifnot(all(abs(net - (up - down)) < 1e-12), all(abs(gross - (up + down)) < 1e-12), all(abs(ok[[paste0("I_A_", method)]]) <= 1 + 1e-12), all(abs(ok[[paste0("f_up_", method)]] + ok[[paste0("f_down_", method)]] + ok[[paste0("f_zero_", method)]] - 1) < 1e-12))
  }
  q_cols <- grep("^Q_(up|down|net|gross)_", names(prior), value = TRUE)
  stopifnot(all(vapply(q_cols, function(col) isTRUE(all.equal(x[[sub("_no_rotation_common", "_no_rotation", col, fixed = TRUE)]], prior[[col]], tolerance = 1e-12, check.attributes = FALSE)), logical(1))))
}

main <- function() {
  opt <- parse_args(commandArgs(trailingOnly = TRUE))
  if (opt$self_check) {
    z <- motion_summary(c(-2, 0, 4), 0.5)
    stopifnot(identical(z$Q_net_m, 1), identical(z$up_time_fraction, 1 / 3), identical(z$down_time_fraction, 1 / 3), identical(z$zero_time_fraction, 1 / 3))
    message("Self-check passed."); return(invisible(NULL))
  }
  params <- read_pair_parameters(default_parameters); fs_hz <- read_fs(default_metadata)
  built <- build_inventory(default_bundle); inv <- built$inventory[track_scope == "0_245_m"]; attr(inv, "bundle") <- fread(default_bundle, showProgress = FALSE)
  prior <- fread(file.path(opt$root, "tables", "BPF_0_245_PF8_2ensemble_pair_pass_air_accumulation_all.csv"))[track_scope == "0_245_m"]
  setorder(inv, pass_uid); setorder(prior, pass_uid)
  raw <- raw_index(default_raw_root); rr_cache <- list(); parts <- list()
  for (ym in sort(unique(inv$year_month))) {
    expected <- inv[year_month == ym]; attr(expected, "bundle") <- attr(inv, "bundle")
    dates <- unique(unlist(lapply(seq_len(nrow(expected)), function(i) format(as.Date(c(expected$start_time[i], expected$end_time[i]), tz = tz_local), "%Y_%m_%d"))))
    message("Computing paired sign metrics: ", ym, " (", nrow(expected), " passes)")
    result <- pair_process_month(expected, raw[date_token %in% dates], rr_cache, fs_hz, params); rr_cache <- result$rr_cache; parts[[ym]] <- result$month
  }
  x <- rbindlist(parts, use.names = TRUE, fill = TRUE); setorder(x, pass_uid)
  x[, `:=`(track_position_mid_m = (track_south_m + track_north_m) / 2, is_common_valid = bpf_qc_status == "ok" & no_rotation_common_qc_status == "ok")]
  out <- cbind(x[, .(pass_uid, source_group, source_pass_id, pass_mid_time_local, direction, track_scope, track_south_m, track_north_m, track_position_mid_m, n_common_valid, common_valid_seconds, common_coverage_fraction, n_bins_covered, bin_ids_covered, n_co2_common_valid, co2_mean_ppm, bpf_qc_status, bpf_qc_reason, no_rotation_common_qc_status, no_rotation_common_qc_reason, is_common_valid)], as.data.table(method_columns(x, "no_rotation")), as.data.table(method_columns(x, "BPF")))
  validate_pair_table(out, prior)
  path <- file.path(opt$root, "tables", output_name); atomic_fwrite_pair(out, path)
  message("Wrote ", nrow(out), " pass pairs: ", path)
}

main()
