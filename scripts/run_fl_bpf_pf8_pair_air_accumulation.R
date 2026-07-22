#!/usr/bin/env Rscript

# Paired high-frequency BPF/no-rotation air accumulation.  This deliberately
# reads the accepted PF8 two-ensemble table, never BPF_default.
suppressPackageStartupMessages(library(data.table))

source_script <- "D:/00 博士阶段/99 Project/06 EA/scripts/run_fl_no_rotation_pass_air_accumulation.R"
Sys.setenv(NO_ROTATION_SOURCE_ONLY = "1")
source(source_script, local = .GlobalEnv)

default_parameters <- "E:/Dataset_Level1/Flares/Eddy Accumulation/tables/BPF_0_245_PF8_2ensemble_parameters_for_flux.csv"
pair_required_cols <- c(
  "pass_uid", "source_group", "source_pass_id", "start_time_local", "end_time_local", "pass_mid_time_local", "direction", "track_scope", "track_south_m", "track_north_m", "fs_hz", "pass_duration_seconds",
  "n_raw", "n_diag_sonic_zero", "n_base_valid", "n_running_interpolated", "n_position_in_track", "n_parameter_bin", "n_bpf_valid", "n_common_valid", "bpf_valid_seconds", "common_valid_seconds", "bpf_coverage_fraction", "common_coverage_fraction", "n_bins_covered", "bin_ids_covered",
  "Q_up_BPF_m", "Q_down_BPF_m", "Q_net_BPF_m", "Q_gross_BPF_m", "Q_up_no_rotation_common_m", "Q_down_no_rotation_common_m", "Q_net_no_rotation_common_m", "Q_gross_no_rotation_common_m",
  "BPF_closure_net_error", "BPF_closure_gross_error", "no_rotation_common_closure_net_error", "no_rotation_common_closure_gross_error", "bpf_qc_status", "bpf_qc_reason", "no_rotation_common_qc_status", "no_rotation_common_qc_reason"
)

pair_parse_args <- function(args) {
  o <- list(bundle = default_bundle, raw_root = default_raw_root, metadata = default_metadata, output_root = default_output_root, parameters = default_parameters, month = NA_character_, self_check = FALSE)
  for (a in args) {
    if (grepl("^--bundle=", a)) o$bundle <- sub("^--bundle=", "", a)
    else if (grepl("^--raw-root=", a)) o$raw_root <- sub("^--raw-root=", "", a)
    else if (grepl("^--metadata=", a)) o$metadata <- sub("^--metadata=", "", a)
    else if (grepl("^--output-root=", a)) o$output_root <- sub("^--output-root=", "", a)
    else if (grepl("^--parameters=", a)) o$parameters <- sub("^--parameters=", "", a)
    else if (grepl("^--month=", a)) o$month <- sub("^--month=", "", a)
    else if (a == "--self-check") o$self_check <- TRUE
    else if (a %in% c("-h", "--help")) { cat("Usage: Rscript run_fl_bpf_pf8_pair_air_accumulation.R [--month=YYYY_MM] [--parameters=PATH] [--self-check]\n"); quit(save = "no", status = 0) }
    else stop("Unknown argument: ", a, call. = FALSE)
  }
  if (!is.na(o$month) && !grepl("^[0-9]{4}_[0-9]{2}$", o$month)) stop("--month must be YYYY_MM.", call. = FALSE)
  o
}

read_pair_parameters <- function(path) {
  if (!file.exists(path)) stop("Missing required PF8 parameter table: ", path, call. = FALSE)
  p <- fread(path, showProgress = FALSE)
  need <- c("method", "bin_id", "bin_min", "bin_max", "intercept_a", "slope_b_u", "slope_c_v", "fit_ok")
  if (length(miss <- setdiff(need, names(p)))) stop("Parameter table missing: ", paste(miss, collapse = ", "), call. = FALSE)
  p <- p[method == "BPF_0_245_PF8_2ensemble"]
  expected <- data.table(bin_id = 1:8, bin_min = seq(0, 245 - 245 / 8, length.out = 8), bin_max = seq(245 / 8, 245, length.out = 8))
  setorder(p, bin_id)
  if (nrow(p) != 8L || anyDuplicated(p$bin_id) || !identical(as.integer(p$bin_id), expected$bin_id) || !isTRUE(all.equal(p$bin_min, expected$bin_min, tolerance = 0)) || !isTRUE(all.equal(p$bin_max, expected$bin_max, tolerance = 0)) || !all(p$fit_ok) || any(!is.finite(as.matrix(p[, .(intercept_a, slope_b_u, slope_c_v)])))) stop("PF8 parameter table is not the valid fixed 0-245 m / 8-bin two-ensemble table.", call. = FALSE)
  p[]
}

pair_read_running_records <- function(bundle_row) {
  rr <- fread(bundle_row$cache_csv, select = c("time", "speed", "position", "pass_id"), colClasses = list(character = c("time", "pass_id")), showProgress = FALSE)
  rr[, `:=`(time = parse_bundle_time(time), speed_cm_s = to_num(speed), position = to_num(position), source_group = bundle_row$source_group, source_pass_id = as.character(pass_id))]
  rr <- rr[!is.na(time) & is.finite(position)]
  rr <- rr[, .(speed_cm_s = { z <- speed_cm_s[is.finite(speed_cm_s)]; if (length(z)) median(z) else NA_real_ }, position = median(position)), by = .(source_group, source_pass_id, time)]
  setorder(rr, source_group, source_pass_id, time)
  rr[, `:=`(dt_s = as.numeric(difftime(time, shift(time), units = "secs")), dposition_m = position - shift(position)), by = .(source_group, source_pass_id)]
  rr[, position_speed_cm_s := fifelse(is.finite(dt_s) & dt_s > 0 & dt_s <= 15, 100 * dposition_m / dt_s, NA_real_)]
  rr[]
}

pair_add_running_fields <- function(x, rr) {
  x[, `:=`(position = NA_real_, cart_speed_m_s = NA_real_, running_gap_s = NA_real_, running_interp_ok = FALSE)]
  for (k in seq_len(nrow(unique(x[, .(pass_uid, source_group, source_pass_id)])))) {
    key <- unique(x[, .(pass_uid, source_group, source_pass_id)])[k]
    idx <- which(x$pass_uid == key$pass_uid); r <- rr[source_group == key$source_group & source_pass_id == key$source_pass_id]
    if (nrow(r) < 2L) next
    xt <- as.numeric(x$TIMESTAMP[idx]); rt <- as.numeric(r$time); at <- findInterval(xt, rt)
    ok <- at >= 1L & at < nrow(r); gap <- rep(NA_real_, length(idx)); gap[ok] <- rt[at[ok] + 1L] - rt[at[ok]]; ok <- ok & is.finite(gap) & gap <= 15
    pos <- approx(rt, r$position, xout = xt, rule = 1, ties = "ordered")$y
    speed <- approx(rt, r$speed_cm_s, xout = xt, rule = 1, ties = "ordered")$y
    fallback <- approx(rt, r$position_speed_cm_s, xout = xt, rule = 1, ties = "ordered")$y
    speed[!is.finite(speed)] <- fallback[!is.finite(speed)]
    pos[!ok] <- NA_real_; speed[!ok] <- NA_real_
    x$position[idx] <- pos; x$cart_speed_m_s[idx] <- speed / 100; x$running_gap_s[idx] <- gap; x$running_interp_ok[idx] <- ok
  }
  x
}

pair_empty_result <- function(has_raw_candidate) list(
  n_raw = 0L, n_diag_sonic_zero = 0L, n_base_valid = 0L, n_running_interpolated = 0L, n_position_in_track = 0L, n_parameter_bin = 0L, n_bpf_valid = 0L, n_common_valid = 0L, bpf_valid_seconds = NA_real_, common_valid_seconds = NA_real_, bpf_coverage_fraction = NA_real_, common_coverage_fraction = NA_real_, n_bins_covered = 0L, bin_ids_covered = NA_character_,
  Q_up_BPF_m = NA_real_, Q_down_BPF_m = NA_real_, Q_net_BPF_m = NA_real_, Q_gross_BPF_m = NA_real_, Q_up_no_rotation_common_m = NA_real_, Q_down_no_rotation_common_m = NA_real_, Q_net_no_rotation_common_m = NA_real_, Q_gross_no_rotation_common_m = NA_real_, BPF_closure_net_error = NA_real_, BPF_closure_gross_error = NA_real_, no_rotation_common_closure_net_error = NA_real_, no_rotation_common_closure_gross_error = NA_real_, bpf_qc_status = "failed", bpf_qc_reason = if (has_raw_candidate) "no_samples_in_pass" else "no_raw_file", no_rotation_common_qc_status = "failed", no_rotation_common_qc_reason = if (has_raw_candidate) "no_samples_in_pass" else "no_raw_file"
)

pair_flux_result <- function(pass, samples, fs_hz, params, has_raw_candidate) {
  empty <- as.data.table(pair_empty_result(has_raw_candidate)); if (is.null(samples) || !nrow(samples)) return(empty)
  setorder(samples, TIMESTAMP, RECORD, source_file); samples <- unique(samples, by = c("TIMESTAMP", "RECORD")); n_raw <- nrow(samples)
  diag_ok <- is.finite(samples$diag_sonic) & samples$diag_sonic == 0; n_diag <- sum(diag_ok)
  range_ok <- is.finite(samples$Ux) & is.finite(samples$Uy) & is.finite(samples$Uz) & abs(samples$Ux) <= 30 & abs(samples$Uy) <= 30 & sqrt(samples$Ux^2 + samples$Uy^2) <= 45 & abs(samples$Uz) <= 10
  # The same VM-prepared vertical series is used by both products; no pass mean is removed.
  samples[, Uz_shared := vm_despike_w(ifelse(diag_ok & range_ok, Uz, NA_real_))]
  base_ok <- is.finite(samples$Uz_shared); n_base <- sum(base_ok)
  if (!n_base) { empty[, `:=`(n_raw = n_raw, n_diag_sonic_zero = n_diag, n_base_valid = 0L, bpf_qc_reason = if (!n_diag) "no_diag_sonic_zero" else if (!any(diag_ok & range_ok)) "no_samples_after_range" else "no_samples_after_despike", no_rotation_common_qc_reason = bpf_qc_reason)]; return(empty) }
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
  if (!n_bpf) { reason <- if (!n_diag) "no_diag_sonic_zero" else if (!any(samples$running_interp_ok, na.rm = TRUE)) "no_running_record_interpolation" else if (!any(position_ok, na.rm = TRUE)) "no_position_or_speed_in_track" else "no_parameter_bin_match"; empty[, `:=`(n_raw = n_raw, n_diag_sonic_zero = n_diag, n_base_valid = n_base, n_running_interpolated = n_running, n_position_in_track = n_position, n_parameter_bin = n_parameter, bpf_qc_reason = reason, no_rotation_common_qc_reason = reason)]; return(empty) }
  samples[, w_bpf := Uz_shared - (intercept_a + slope_b_u * U_east_corrected + slope_c_v * U_north_corrected)]
  wb <- samples$w_bpf[bpf_ok]; wn <- samples$Uz_shared[bpf_ok]; dt <- 1 / fs_hz; dur <- as.numeric(difftime(pass$end_time, pass$start_time, units = "secs"))
  accum <- function(w) { up <- sum(pmax(w, 0) * dt); down <- sum(pmax(-w, 0) * dt); list(up = up, down = down, net = up - down, gross = up + down, net_raw = sum(w * dt), gross_raw = sum(abs(w) * dt)) }
  b <- accum(wb); n <- accum(wn); bins <- sort(unique(samples$bin_id[bpf_ok])); t_valid <- n_bpf / fs_hz
  as.data.table(list(n_raw = n_raw, n_diag_sonic_zero = n_diag, n_base_valid = n_base, n_running_interpolated = n_running, n_position_in_track = n_position, n_parameter_bin = n_parameter, n_bpf_valid = n_bpf, n_common_valid = n_bpf, bpf_valid_seconds = t_valid, common_valid_seconds = t_valid, bpf_coverage_fraction = t_valid / dur, common_coverage_fraction = t_valid / dur, n_bins_covered = length(bins), bin_ids_covered = paste(bins, collapse = ";"), Q_up_BPF_m = b$up, Q_down_BPF_m = b$down, Q_net_BPF_m = b$net, Q_gross_BPF_m = b$gross, Q_up_no_rotation_common_m = n$up, Q_down_no_rotation_common_m = n$down, Q_net_no_rotation_common_m = n$net, Q_gross_no_rotation_common_m = n$gross, BPF_closure_net_error = b$net - b$net_raw, BPF_closure_gross_error = b$gross - b$gross_raw, no_rotation_common_closure_net_error = n$net - n$net_raw, no_rotation_common_closure_gross_error = n$gross - n$gross_raw, bpf_qc_status = "ok", bpf_qc_reason = "ok", no_rotation_common_qc_status = "ok", no_rotation_common_qc_reason = "ok"))
}

pair_validate_month <- function(path, expected) {
  x <- fread(path, showProgress = FALSE)
  if (!identical(names(x), pair_required_cols) || nrow(x) != nrow(expected) || anyDuplicated(x$pass_uid) || !setequal(x$pass_uid, expected$pass_uid)) stop("Pair month schema or inventory mismatch: ", path, call. = FALSE)
  ok <- x[bpf_qc_status == "ok"]
  if (nrow(ok)) { if (any(ok$n_bpf_valid != ok$n_common_valid) || any(ok$Q_up_BPF_m < 0 | ok$Q_down_BPF_m < 0 | ok$Q_up_no_rotation_common_m < 0 | ok$Q_down_no_rotation_common_m < 0)) stop("Invalid paired accumulation fields: ", path, call. = FALSE); tol <- 1e-10 * pmax(1, abs(c(ok$Q_net_BPF_m, ok$Q_gross_BPF_m, ok$Q_net_no_rotation_common_m, ok$Q_gross_no_rotation_common_m))); err <- abs(c(ok$BPF_closure_net_error, ok$BPF_closure_gross_error, ok$no_rotation_common_closure_net_error, ok$no_rotation_common_closure_gross_error)); if (any(err > tol)) stop("Paired closure failure: ", path, call. = FALSE) }
  invisible(x)
}

pair_process_month <- function(inv, raw_files, rr_cache, fs_hz, params) {
  parts <- setNames(vector("list", nrow(inv)), inv$pass_uid)
  has_raw <- inv[, vapply(seq_len(.N), function(i) any(raw_files$date_token %in% unique(format(as.Date(c(start_time[i], end_time[i]), tz = tz_local), "%Y_%m_%d"))), logical(1))]
  pi <- inv[, .(pass_uid, source_group, source_pass_id, source_priority, pass_start = start_time, pass_end = end_time)]; setkey(pi, pass_start, pass_end)
  for (f in raw_files$file) {
    got <- read_toa5_wind(f); x <- got$data; if (!nrow(x)) next
    x[, `:=`(t0 = TIMESTAMP, t1 = TIMESTAMP)]; setkey(x, t0, t1); m <- foverlaps(x, pi, by.x = c("t0", "t1"), by.y = c("pass_start", "pass_end"), type = "within", nomatch = 0L); if (!nrow(m)) next
    setorder(m, TIMESTAMP, RECORD, source_priority, pass_start, pass_uid); m <- unique(m, by = c("TIMESTAMP", "RECORD"))
    for (g in unique(m$source_group)) if (is.null(rr_cache[[g]])) rr_cache[[g]] <- pair_read_running_records(attr(inv, "bundle")[source_group == g][1])
    m <- pair_add_running_fields(m, rbindlist(rr_cache[unique(m$source_group)], use.names = TRUE, fill = TRUE))
    for (uid in unique(m$pass_uid)) parts[[uid]][[length(parts[[uid]]) + 1L]] <- m[pass_uid == uid]
  }
  rows <- rbindlist(lapply(seq_len(nrow(inv)), function(i) { p <- inv[i]; s <- if (length(parts[[p$pass_uid]])) rbindlist(parts[[p$pass_uid]], use.names = TRUE, fill = TRUE) else NULL; cbind(p[, .(pass_uid)], pair_flux_result(p, s, fs_hz, params, has_raw[[i]])) }), fill = TRUE)
  out <- merge(inv, rows, by = "pass_uid", all.x = TRUE, sort = FALSE); out[, `:=`(fs_hz = fs_hz, pass_duration_seconds = as.numeric(difftime(end_time, start_time, units = "secs")))]; out <- out[, ..pair_required_cols]
  list(month = out[], rr_cache = rr_cache)
}

pair_progress_cols <- c("year_month", "status", "n_inventory", "n_output", "n_bpf_success", "n_bpf_failed", "file_path", "file_size_bytes", "sha256", "max_abs_closure_error", "validated_at_local", "run_id")
pair_read_progress <- function(path) if (file.exists(path)) { x <- fread(path); if (!identical(names(x), pair_progress_cols)) stop("Unexpected pair progress schema.", call. = FALSE); x } else data.table(year_month = character(), status = character(), n_inventory = integer(), n_output = integer(), n_bpf_success = integer(), n_bpf_failed = integer(), file_path = character(), file_size_bytes = numeric(), sha256 = character(), max_abs_closure_error = numeric(), validated_at_local = character(), run_id = character())
pair_write_progress <- function(x, path) atomic_fwrite(x[, ..pair_progress_cols], path)

pair_main <- function() {
  opt <- pair_parse_args(commandArgs(trailingOnly = TRUE)); if (opt$self_check) { p <- data.table(method = "BPF_0_245_PF8_2ensemble", bin_id = 1:8, bin_min = seq(0, 245 - 245 / 8, length.out = 8), bin_max = seq(245 / 8, 245, length.out = 8), intercept_a = 0, slope_b_u = 0, slope_c_v = 0, fit_ok = TRUE); stopifnot(nrow(read_pair_parameters({ f <- tempfile(fileext = ".csv"); fwrite(p, f); f })) == 8L); message("Self-check passed."); return(invisible(NULL)) }
  params <- read_pair_parameters(opt$parameters); dir.create(opt$output_root, recursive = TRUE, showWarnings = FALSE); tables_dir <- file.path(opt$output_root, "tables"); scripts_dir <- file.path(opt$output_root, "scripts"); dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE); dir.create(scripts_dir, recursive = TRUE, showWarnings = FALSE)
  fs_hz <- read_fs(opt$metadata); built <- build_inventory(opt$bundle); inv <- built$inventory; attr(inv, "bundle") <- fread(opt$bundle, showProgress = FALSE); atomic_fwrite(inv[, .(pass_uid, source_group, source_pass_id, start_time_local, end_time_local, pass_mid_time_local, direction, track_scope, track_south_m, track_north_m, year_month)], file.path(tables_dir, "BPF_0_245_PF8_2ensemble_pair_pass_inventory.csv")); atomic_fwrite(built$audit, file.path(tables_dir, "BPF_0_245_PF8_2ensemble_pair_duplicate_pass_audit.csv"))
  months <- sort(unique(inv$year_month)); if (!is.na(opt$month)) months <- intersect(months, opt$month); raw <- raw_index(opt$raw_root); progress_path <- file.path(tables_dir, "BPF_0_245_PF8_2ensemble_pair_monthly_progress.csv"); progress <- pair_read_progress(progress_path); rr_cache <- list(); run_id <- paste0(format(Sys.time(), "%Y%m%dT%H%M%S", tz = tz_local), "_", Sys.getpid())
  for (ym in months) { expected <- inv[year_month == ym]; attr(expected, "bundle") <- attr(inv, "bundle"); month_path <- file.path(tables_dir, paste0("BPF_0_245_PF8_2ensemble_pair_pass_air_accumulation_", ym, ".csv")); complete <- progress[year_month == ym & status == "complete"]; if (nrow(complete) == 1L && file.exists(month_path) && identical(sha256(month_path), complete$sha256) && isTRUE(tryCatch({ pair_validate_month(month_path, expected); TRUE }, error = function(e) FALSE))) { message("Skipping verified month: ", ym); next }; if (file.exists(month_path)) archive_superseded(month_path, "invalid_pair_validation"); message("Processing paired BPF month: ", ym, " (", nrow(expected), " passes)"); dates <- unique(unlist(lapply(seq_len(nrow(expected)), function(i) format(as.Date(c(expected$start_time[i], expected$end_time[i]), tz = tz_local), "%Y_%m_%d")))); result <- pair_process_month(expected, raw[date_token %in% dates], rr_cache, fs_hz, params); rr_cache <- result$rr_cache; atomic_fwrite(result$month, month_path, function(tmp) pair_validate_month(tmp, expected)); x <- result$month; errors <- abs(c(x$BPF_closure_net_error, x$BPF_closure_gross_error, x$no_rotation_common_closure_net_error, x$no_rotation_common_closure_gross_error)); err <- if (any(is.finite(errors))) max(errors, na.rm = TRUE) else NA_real_; row <- data.table(year_month = ym, status = "complete", n_inventory = nrow(x), n_output = nrow(x), n_bpf_success = sum(x$bpf_qc_status == "ok"), n_bpf_failed = sum(x$bpf_qc_status != "ok"), file_path = month_path, file_size_bytes = file.info(month_path)$size, sha256 = sha256(month_path), max_abs_closure_error = err, validated_at_local = fmt_time(Sys.time()), run_id = run_id); progress <- rbind(progress[year_month != ym], row, fill = TRUE); setorder(progress, year_month); pair_write_progress(progress, progress_path) }
  if (setequal(sort(unique(inv$year_month)), sort(progress[status == "complete", year_month]))) { files <- file.path(tables_dir, paste0("BPF_0_245_PF8_2ensemble_pair_pass_air_accumulation_", sort(unique(inv$year_month)), ".csv")); all_dt <- rbindlist(lapply(files, fread), use.names = TRUE, fill = TRUE); atomic_fwrite(all_dt, file.path(tables_dir, "BPF_0_245_PF8_2ensemble_pair_pass_air_accumulation_all.csv")); atomic_fwrite(all_dt[, .(n_passes = .N, n_bpf_success = sum(bpf_qc_status == "ok"), n_bpf_failed = sum(bpf_qc_status != "ok"), n_bpf_native_samples = sum(n_bpf_valid, na.rm = TRUE), n_common_samples = sum(n_common_valid, na.rm = TRUE)), by = .(track_scope, direction)], file.path(tables_dir, "BPF_0_245_PF8_2ensemble_pair_position_bin_coverage.csv")); reasons <- all_dt[bpf_qc_status != "ok", .N, by = bpf_qc_reason][order(-N)]; write_text(c("BPF PF8 paired high-frequency air accumulation", "status: provisional", paste("parameters_exact_path:", normalizePath(opt$parameters, winslash = "/")), paste("parameters_sha256:", sha256(opt$parameters)), "formula: w_bpf = Uz_shared - (a + b*Ueast_corrected + c*Unorth_corrected); no pass w_mean subtraction", "common_mask: BPF-valid high-frequency samples; no-rotation recomputed within this run", "coverage_exception: missing training source-dates do not block computable raw dates; missing TOA5 passes remain explicit no_raw_file", "failure_reasons:", capture.output(print(reasons))), file.path(opt$output_root, "BPF_0_245_PF8_2ensemble_pair_manifest.txt")) }
}

if (!identical(Sys.getenv("FL_PAIR_SOURCE_ONLY"), "1")) pair_main()
