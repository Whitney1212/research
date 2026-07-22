#!/usr/bin/env Rscript

# Same common-mask samples as the paired pass product, summarized by location.
suppressPackageStartupMessages(library(data.table))
Sys.setenv(FL_PAIR_SOURCE_ONLY = "1")
source("D:/00 博士阶段/99 Project/06 EA/scripts/run_fl_bpf_pf8_pair_air_accumulation.R", local = .GlobalEnv)

out_names <- c(bin_10m = "BPF_0_245_PF8_2ensemble_no_rotation_common_pass_bin_10m.csv", bpf_8bin = "BPF_0_245_PF8_2ensemble_no_rotation_common_pass_bin_BPF8.csv")

motion <- function(w, c, ref, dt) {
  n_air <- length(w); up <- w > 0; down <- w < 0
  qu <- sum(w[up]) * dt; qd <- sum(-w[down]) * dt; sec <- n_air * dt
  co2 <- is.finite(c); wc <- w[co2]; cc <- c[co2]
  list(n_air = n_air, n_co2 = sum(co2), valid_seconds = sec,
    Q_up_m = qu, Q_down_m = qd, Q_net_m = qu - qd, Q_gross_m = qu + qd,
    q_up_m_s = qu / sec, q_down_m_s = qd / sec, q_net_m_s = (qu - qd) / sec, q_gross_m_s = (qu + qd) / sec,
    I_A = if ((qu + qd) > 0) (qu - qd) / (qu + qd) else NA_real_,
    f_up = sum(up) / n_air, f_down = sum(down) / n_air, f_zero = sum(w == 0) / n_air,
    mean_w_when_up_m_s = if (any(up)) mean(w[up]) else NA_real_, mean_abs_w_when_down_m_s = if (any(down)) mean(abs(w[down])) else NA_real_,
    co2_mean_ppm = if (length(cc)) mean(cc) else NA_real_, co2_anom_mean_ppm = if (length(cc)) mean(cc - ref) else NA_real_,
    F_EC_cov_ppm_m_s = if (length(cc) > 1L) cov(wc, cc) else NA_real_,
    F_EA_total_ppm_m_s = if (length(cc)) mean(wc * cc) else NA_real_,
    F_EA_anom_ppm_m_s = if (length(cc)) mean(wc * (cc - ref)) else NA_real_,
    c_up_ppm = if (any(up & co2)) weighted.mean(c[up & co2], w[up & co2]) else NA_real_,
    c_down_ppm = if (any(down & co2)) weighted.mean(c[down & co2], -w[down & co2]) else NA_real_)
}

one_method <- function(x, w_name, method, ref, dt, ids, scheme, lo, hi) {
  rbindlist(lapply(sort(unique(ids)), function(id) {
    take <- ids == id; z <- motion(x[[w_name]][take], x$CO2[take], ref, dt)
    as.data.table(c(list(bin_scheme = scheme, position_bin_id = id, position_bin_min_m = lo[id], position_bin_max_m = hi[id], position_bin_mid_m = (lo[id] + hi[id]) / 2, coordinate_method = method), z))
  }))
}

bin_metrics <- function(pass, samples, fs_hz, params) {
  if (is.null(samples) || !nrow(samples)) return(data.table())
  setorder(samples, TIMESTAMP, RECORD, source_file); samples <- unique(samples, by = c("TIMESTAMP", "RECORD"))
  diag_ok <- is.finite(samples$diag_sonic) & samples$diag_sonic == 0
  range_ok <- is.finite(samples$Ux) & is.finite(samples$Uy) & is.finite(samples$Uz) & abs(samples$Ux) <= 30 & abs(samples$Uy) <= 30 & sqrt(samples$Ux^2 + samples$Uy^2) <= 45 & abs(samples$Uz) <= 10
  samples[, Uz_shared := vm_despike_w(ifelse(diag_ok & range_ok, Uz, NA_real_))]
  track_rad <- 129.551 * pi / 180; samples[, U_h_raw := sqrt(Ux^2 + Uy^2)]; samples[, wind_from_geo_rad := (((270 - atan2(Uy, Ux) * 180 / pi) %% 360 + 300) %% 360) * pi / 180]
  samples[, `:=`(U_east_corrected = -U_h_raw * sin(wind_from_geo_rad) + cart_speed_m_s * sin(track_rad), U_north_corrected = -U_h_raw * cos(wind_from_geo_rad) + cart_speed_m_s * cos(track_rad))]
  breaks <- c(params$bin_min[1], params$bin_max); samples[, bpf_bin_id := findInterval(position, breaks, rightmost.closed = TRUE)]
  samples <- params[samples, on = c(bin_id = "bpf_bin_id")]
  ok <- is.finite(samples$Uz_shared) & samples$running_interp_ok & is.finite(samples$position) & is.finite(samples$cart_speed_m_s) & samples$position >= 0 & samples$position <= 245 & is.finite(samples$intercept_a) & is.finite(samples$slope_b_u) & is.finite(samples$slope_c_v)
  if (!any(ok)) return(data.table())
  samples <- samples[ok]; samples[, w_BPF := Uz_shared - (intercept_a + slope_b_u * U_east_corrected + slope_c_v * U_north_corrected)]
  ref <- mean(samples$CO2[is.finite(samples$CO2)]); if (!is.finite(ref)) return(data.table())
  samples[, bin_10m_id := pmin(floor(position / 10) + 1L, 25L)]
  schemes <- list(bin_10m = list(id = samples$bin_10m_id, lo = c(seq(0, 230, 10), 240), hi = c(seq(10, 240, 10), 245)), bpf_8bin = list(id = samples$bin_id, lo = params$bin_min, hi = params$bin_max))
  out <- rbindlist(lapply(names(schemes), function(s) {
    g <- schemes[[s]]; rbindlist(list(one_method(samples, "Uz_shared", "no_rotation_common", ref, 1 / fs_hz, g$id, s, g$lo, g$hi), one_method(samples, "w_BPF", "BPF_PF8_2ensemble", ref, 1 / fs_hz, g$id, s, g$lo, g$hi)))
  }), fill = TRUE)
  out[, `:=`(pass_uid = pass$pass_uid, source_group = pass$source_group, source_pass_id = pass$source_pass_id, pass_mid_time_local = pass$pass_mid_time_local, direction = pass$direction, track_scope = pass$track_scope, co2_ref_pass_ppm = ref)]
  out[]
}

process_month <- function(inv, raw_files, rr_cache, fs_hz, params) {
  parts <- setNames(vector("list", nrow(inv)), inv$pass_uid); has_raw <- inv[, vapply(seq_len(.N), function(i) any(raw_files$date_token %in% unique(format(as.Date(c(start_time[i], end_time[i]), tz = tz_local), "%Y_%m_%d"))), logical(1))]
  pi <- inv[, .(pass_uid, source_group, source_pass_id, source_priority, pass_start = start_time, pass_end = end_time)]; setkey(pi, pass_start, pass_end)
  for (f in raw_files$file) { got <- read_toa5_wind(f); x <- got$data; if (!nrow(x)) next; x[, `:=`(t0 = TIMESTAMP, t1 = TIMESTAMP)]; setkey(x, t0, t1); m <- foverlaps(x, pi, by.x = c("t0", "t1"), by.y = c("pass_start", "pass_end"), type = "within", nomatch = 0L); if (!nrow(m)) next; setorder(m, TIMESTAMP, RECORD, source_priority, pass_start, pass_uid); m <- unique(m, by = c("TIMESTAMP", "RECORD")); for (g in unique(m$source_group)) if (is.null(rr_cache[[g]])) rr_cache[[g]] <- pair_read_running_records(attr(inv, "bundle")[source_group == g][1]); m <- pair_add_running_fields(m, rbindlist(rr_cache[unique(m$source_group)], use.names = TRUE, fill = TRUE)); for (uid in unique(m$pass_uid)) parts[[uid]][[length(parts[[uid]]) + 1L]] <- m[pass_uid == uid] }
  list(rows = rbindlist(lapply(seq_len(nrow(inv)), function(i) { s <- if (length(parts[[inv$pass_uid[i]]])) rbindlist(parts[[inv$pass_uid[i]]], use.names = TRUE, fill = TRUE) else NULL; bin_metrics(inv[i], s, fs_hz, params) }), fill = TRUE), rr_cache = rr_cache)
}

if ("--self-check" %in% commandArgs(trailingOnly = TRUE)) {
  z <- motion(c(-2, 0, 4), c(400, 405, 410), 405, .5)
  stopifnot(z$Q_net_m == 1, z$f_up == 1 / 3, z$f_down == 1 / 3, z$f_zero == 1 / 3)
  message("Self-check passed."); quit(save = "no")
}

main <- function() {
  params <- read_pair_parameters(default_parameters); fs_hz <- read_fs(default_metadata); built <- build_inventory(default_bundle); inv <- built$inventory[track_scope == "0_245_m"]; attr(inv, "bundle") <- fread(default_bundle); raw <- raw_index(default_raw_root); rr_cache <- list(); all <- list()
  for (ym in sort(unique(inv$year_month))) { expected <- inv[year_month == ym]; attr(expected, "bundle") <- attr(inv, "bundle"); dates <- unique(unlist(lapply(seq_len(nrow(expected)), function(i) format(as.Date(c(expected$start_time[i], expected$end_time[i]), tz = tz_local), "%Y_%m_%d")))); message("Computing bin diagnostics: ", ym); z <- process_month(expected, raw[date_token %in% dates], rr_cache, fs_hz, params); rr_cache <- z$rr_cache; all[[ym]] <- z$rows }
  x <- rbindlist(all, fill = TRUE); stopifnot(all(x$track_scope == "0_245_m"), all(x$n_air > 0L), all(abs(x$f_up + x$f_down + x$f_zero - 1) < 1e-12), all(abs(x$I_A) <= 1 + 1e-12))
  for (s in names(out_names)) { y <- x[bin_scheme == s]; path <- file.path(default_output_root, "tables", out_names[[s]]); tmp <- paste0(path, ".tmp.", Sys.getpid()); fwrite(y, tmp, na = ""); if (file.exists(path)) unlink(path); stopifnot(file.rename(tmp, path)); message("Wrote ", nrow(y), ": ", path) }
}
main()
