#!/usr/bin/env Rscript

# Daily-cycle summaries from the completed paired pass product only.
suppressPackageStartupMessages({ library(data.table); library(ggplot2) })

default_root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"
input_name <- "BPF_0_245_PF8_2ensemble_pair_pass_air_accumulation_all.csv"
method_levels <- c("no_rotation_common", "BPF_PF8_2ensemble")
method_labels <- c(no_rotation_common = "No rotation (common mask)", BPF_PF8_2ensemble = "BPF PF8 two-ensemble")
method_cols <- c(no_rotation_common = "#4E79A7", BPF_PF8_2ensemble = "#D55E00")

parse_args <- function(args) {
  o <- list(root = default_root, self_check = FALSE)
  for (a in args) {
    if (grepl("^--root=", a)) o$root <- sub("^--root=", "", a)
    else if (a == "--self-check") o$self_check <- TRUE
    else if (a %in% c("-h", "--help")) { cat("Usage: Rscript summarise_fl_bpf_pf8_pair_diurnal.R [--root=PATH] [--self-check]\n"); quit(save = "no", status = 0) }
    else stop("Unknown argument: ", a, call. = FALSE)
  }
  o
}

atomic_fwrite <- function(x, path) {
  tmp <- paste0(path, ".tmp.", Sys.getpid()); if (file.exists(tmp)) unlink(tmp)
  fwrite(x, tmp, na = "")
  if (file.exists(path)) unlink(path)
  if (!file.rename(tmp, path)) stop("Could not publish ", path, call. = FALSE)
}

read_pair_input <- function(root) {
  path <- file.path(root, "tables", input_name)
  if (!file.exists(path)) stop("Missing paired pass input: ", path, call. = FALSE)
  x <- fread(path, colClasses = list(character = c("pass_uid", "pass_mid_time_local", "direction", "track_scope", "bpf_qc_status", "no_rotation_common_qc_status")), showProgress = FALSE)
  need <- c("pass_uid", "pass_mid_time_local", "direction", "track_scope", "n_bpf_valid", "n_common_valid", "bpf_valid_seconds", "bpf_qc_status", "no_rotation_common_qc_status", "Q_up_BPF_m", "Q_down_BPF_m", "Q_net_BPF_m", "Q_gross_BPF_m", "Q_up_no_rotation_common_m", "Q_down_no_rotation_common_m", "Q_net_no_rotation_common_m", "Q_gross_no_rotation_common_m")
  if (length(miss <- setdiff(need, names(x)))) stop("Paired input missing: ", paste(miss, collapse = ", "), call. = FALSE)
  x <- x[bpf_qc_status == "ok" & no_rotation_common_qc_status == "ok"]
  if (!nrow(x) || anyDuplicated(x$pass_uid) || any(x$n_bpf_valid != x$n_common_valid) || any(!is.finite(x$bpf_valid_seconds) | x$bpf_valid_seconds <= 0)) stop("Paired common-mask input validation failed.", call. = FALSE)
  x[, `:=`(date_local = substr(pass_mid_time_local, 1L, 10L), hour_local = as.integer(substr(pass_mid_time_local, 12L, 13L)), minute_local = as.integer(substr(pass_mid_time_local, 15L, 16L)))]
  if (any(!is.finite(x$hour_local) | !is.finite(x$minute_local))) stop("Invalid pass-mid timestamp.", call. = FALSE)
  x[, `:=`(half_hour_local = sprintf("%02d:%02d", hour_local, 30L * (minute_local %/% 30L)), half_hour_bin = hour_local + 0.5 * (minute_local >= 30L))]
  x
}

method_long <- function(x, method) {
  suffix <- if (method == "BPF_PF8_2ensemble") "BPF" else "no_rotation_common"
  q <- function(name) x[[paste0(name, "_", suffix, "_m")]]
  out <- data.table(
    pass_uid = x$pass_uid, track_scope = x$track_scope, direction = x$direction, date_local = x$date_local, half_hour_local = x$half_hour_local, half_hour_bin = x$half_hour_bin, valid_seconds = x$bpf_valid_seconds, n_common_valid = x$n_common_valid, coordinate_method = method,
    Q_up_m = q("Q_up"), Q_down_m = q("Q_down"), Q_net_m = q("Q_net"), Q_gross_m = q("Q_gross")
  )
  out[, `:=`(q_up_m_s = Q_up_m / valid_seconds, q_down_m_s = Q_down_m / valid_seconds, q_net_m_s = Q_net_m / valid_seconds, q_gross_m_s = Q_gross_m / valid_seconds, imbalance_index = Q_net_m / Q_gross_m)]
  melt(out, id.vars = c("pass_uid", "track_scope", "direction", "date_local", "half_hour_local", "half_hour_bin", "valid_seconds", "n_common_valid", "coordinate_method"), measure.vars = c("Q_up_m", "Q_down_m", "Q_net_m", "Q_gross_m", "q_up_m_s", "q_down_m_s", "q_net_m_s", "q_gross_m_s", "imbalance_index"), variable.name = "metric", value.name = "value")
}

summarise_diurnal <- function(long) {
  combined <- copy(long); combined[, direction := "fw_bw_combined"]
  z <- rbindlist(list(long, combined), use.names = TRUE)
  out <- z[is.finite(value), .(
    n_passes = .N, n_dates = uniqueN(date_local), n_common_samples = sum(n_common_valid), total_valid_seconds = sum(valid_seconds),
    median = median(value), q25 = as.numeric(quantile(value, .25, names = FALSE)), q75 = as.numeric(quantile(value, .75, names = FALSE)), mean = mean(value)
  ), by = .(track_scope, direction, coordinate_method, metric, half_hour_local, half_hour_bin)]
  out[, coordinate_method := factor(coordinate_method, levels = method_levels, labels = unname(method_labels[method_levels]))]
  setorder(out, track_scope, direction, metric, coordinate_method, half_hour_bin)
  out[]
}

summarise_delta <- function(x) {
  z <- copy(x)[, .(pass_uid, track_scope, direction, date_local, half_hour_local, half_hour_bin, valid_seconds = bpf_valid_seconds,
    delta_Q_net_m = Q_net_BPF_m - Q_net_no_rotation_common_m,
    delta_q_net_m_s = (Q_net_BPF_m - Q_net_no_rotation_common_m) / bpf_valid_seconds,
    delta_imbalance_index = Q_net_BPF_m / Q_gross_BPF_m - Q_net_no_rotation_common_m / Q_gross_no_rotation_common_m)]
  combined <- copy(z); combined[, direction := "fw_bw_combined"]; z <- rbindlist(list(z, combined), use.names = TRUE)
  out <- melt(z, id.vars = c("pass_uid", "track_scope", "direction", "date_local", "half_hour_local", "half_hour_bin", "valid_seconds"), variable.name = "metric", value.name = "value")[is.finite(value), .(n_passes = .N, n_dates = uniqueN(date_local), total_valid_seconds = sum(valid_seconds), median = median(value), q25 = as.numeric(quantile(value, .25, names = FALSE)), q75 = as.numeric(quantile(value, .75, names = FALSE)), mean = mean(value)), by = .(track_scope, direction, metric, half_hour_local, half_hour_bin)]
  setorder(out, track_scope, direction, metric, half_hour_bin)
  out[]
}

check_outputs <- function(stats, delta, n_input) {
  stopifnot(nrow(stats) > 0L, nrow(delta) > 0L, all(stats$half_hour_bin >= 0 & stats$half_hour_bin <= 23.5), all(delta$half_hour_bin >= 0 & delta$half_hour_bin <= 23.5), all(stats$q25 <= stats$median), all(stats$median <= stats$q75), all(delta$q25 <= delta$median), all(delta$median <= delta$q75), all(stats$n_passes > 0L), all(stats$n_dates > 0L), n_input > 0L)
}

theme_pair <- function() theme_bw(base_size = 11) + theme(panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "grey88", linewidth = .25), legend.position = "top", legend.title = element_blank(), strip.background = element_rect(fill = "grey94", colour = "grey75"), strip.text = element_text(face = "bold"), plot.title = element_text(face = "bold"))

copy_self <- function(root) {
  self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
  if (!is.na(self) && file.exists(self)) { dir.create(file.path(root, "scripts"), recursive = TRUE, showWarnings = FALSE); file.copy(self, file.path(root, "scripts", "summarise_fl_bpf_pf8_pair_diurnal.R"), overwrite = TRUE) }
}

main <- function() {
  opt <- parse_args(commandArgs(trailingOnly = TRUE)); x <- read_pair_input(opt$root)
  long <- rbindlist(lapply(method_levels, function(m) method_long(x, m)), use.names = TRUE); stats <- summarise_diurnal(long); delta <- summarise_delta(x); check_outputs(stats, delta, nrow(x))
  if (opt$self_check) { message("Self-check passed."); return(invisible(NULL)) }
  tables <- file.path(opt$root, "tables"); figures <- file.path(opt$root, "figures"); dir.create(figures, recursive = TRUE, showWarnings = FALSE); copy_self(opt$root)
  stats_file <- file.path(tables, "BPF_0_245_PF8_2ensemble_pair_diurnal_30min.csv"); delta_file <- file.path(tables, "BPF_0_245_PF8_2ensemble_pair_diurnal_BPF_minus_no_rotation_common_30min.csv"); atomic_fwrite(stats, stats_file); atomic_fwrite(delta, delta_file)
  qnet <- stats[metric == "q_net_m_s"]; qnet[, direction := factor(direction, levels = c("fw_bw_combined", "fw", "bw"), labels = c("fw + bw", "forward", "backward"))]
  p_qnet <- ggplot(qnet, aes(half_hour_bin, median, colour = coordinate_method, fill = coordinate_method, group = coordinate_method)) + geom_hline(yintercept = 0, colour = "grey55", linewidth = .35) + geom_ribbon(aes(ymin = q25, ymax = q75), alpha = .12, colour = NA) + geom_line(linewidth = .65) + facet_grid(track_scope ~ direction, drop = FALSE) + scale_colour_manual(values = unname(method_cols[method_levels])) + scale_fill_manual(values = unname(method_cols[method_levels])) + scale_x_continuous("Local time (Asia/Shanghai)", breaks = seq(0, 24, 3), limits = c(0, 23.5), labels = function(v) sprintf("%02d:00", as.integer(v))) + ylab(expression("Net vertical air motion " * (m~s^{-1}))) + labs(title = "FL paired BPF versus no-rotation common-mask diurnal pattern", subtitle = "Median by half-hour; ribbon = 25th-75th percentile across paired passes", caption = "Only BPF-valid high-frequency samples are included. Track scopes remain separate; this is an air-motion diagnostic, not a CO2 flux.") + theme_pair()
  qnet_file <- file.path(figures, "BPF_0_245_PF8_2ensemble_pair_diurnal_qnet_comparison.png"); ggsave(qnet_file, p_qnet, width = 12, height = 6.4, dpi = 300)
  dq <- delta[metric == "delta_q_net_m_s"]; dq[, direction := factor(direction, levels = c("fw_bw_combined", "fw", "bw"), labels = c("fw + bw", "forward", "backward"))]
  p_delta <- ggplot(dq, aes(half_hour_bin, median, group = 1)) + geom_hline(yintercept = 0, colour = "grey55", linewidth = .35) + geom_ribbon(aes(ymin = q25, ymax = q75), fill = "grey55", alpha = .22) + geom_line(colour = "#222222", linewidth = .7) + facet_grid(track_scope ~ direction, drop = FALSE) + scale_x_continuous("Local time (Asia/Shanghai)", breaks = seq(0, 24, 3), limits = c(0, 23.5), labels = function(v) sprintf("%02d:00", as.integer(v))) + ylab(expression(Delta * " net vertical air motion (BPF - no rotation, m " * s^{-1} * ")")) + labs(title = "FL paired coordinate-method difference by time of day", subtitle = "Median BPF minus common-mask no-rotation; ribbon = 25th-75th percentile", caption = "Computed within pass on exactly matched high-frequency samples.") + theme_pair()
  delta_png <- file.path(figures, "BPF_0_245_PF8_2ensemble_pair_diurnal_qnet_difference.png"); ggsave(delta_png, p_delta, width = 12, height = 6.4, dpi = 300)
  coverage <- stats[metric == "q_net_m_s", .(n_half_hours = .N, n_dates_min = min(n_dates), n_dates_max = max(n_dates), n_passes_min = min(n_passes), n_passes_max = max(n_passes)), by = .(track_scope, direction, coordinate_method)]
  writeLines(c("FL paired BPF/no-rotation common-mask diurnal summary", paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")), "Status: provisional", paste("Input:", file.path(tables, input_name)), paste("Eligible paired passes:", nrow(x)), "Methods: BPF PF8 two-ensemble and no-rotation recomputed on the same BPF-valid samples", "Grouping: local half-hour, track_scope, and direction (plus fw+bw pooled rows)", "Center/ribbon: pass-level median and 25th-75th percentile", "Boundary: vertical air-motion diagnostic only; not a CO2 flux or advection claim", "Outputs:", paste("-", stats_file), paste("-", delta_file), paste("-", qnet_file), paste("-", delta_png), "Coverage:", capture.output(print(coverage))), file.path(opt$root, "BPF_0_245_PF8_2ensemble_pair_diurnal_summary.txt"), useBytes = TRUE)
  message("Wrote paired diurnal outputs to: ", opt$root)
}

main()
