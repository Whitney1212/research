#!/usr/bin/env Rscript

# Same-date, same-half-hour pass medians, then across-date daily-cycle summaries.
suppressPackageStartupMessages({ library(data.table); library(ggplot2) })

source("D:/00 博士阶段/99 Project/06 EA/scripts/lib_fl_pass_core.R", local = .GlobalEnv)

root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"
input_name <- "BPF_0_245_PF8_2ensemble_no_rotation_common_pass_pair_0_245m.csv"
methods <- c(no_rotation = "No rotation (common mask)", BPF = "BPF PF8 two-ensemble")
cols <- c(no_rotation = "#4E79A7", BPF = "#D55E00")

atomic_fwrite <- function(x, path) { tmp <- paste0(path, ".tmp.", Sys.getpid()); on.exit(unlink(tmp), add = TRUE); fwrite(x, tmp, na = ""); if (file.exists(path)) unlink(path); if (!file.rename(tmp, path)) stop("Could not publish ", path, call. = FALSE) }

read_input <- function() {
  p <- file.path(root, "tables", input_name); x <- read_fl_pass_table_local(p)
  need <- c("pass_uid", "pass_mid_time_local", "track_scope", "is_common_valid", "q_up_no_rotation_m_s", "q_down_no_rotation_m_s", "q_net_no_rotation_m_s", "q_gross_no_rotation_m_s", "I_A_no_rotation", "f_up_no_rotation", "f_down_no_rotation", "mean_w_when_up_no_rotation_m_s", "mean_abs_w_when_down_no_rotation_m_s", "q_up_BPF_m_s", "q_down_BPF_m_s", "q_net_BPF_m_s", "q_gross_BPF_m_s", "I_A_BPF", "f_up_BPF", "f_down_BPF", "mean_w_when_up_BPF_m_s", "mean_abs_w_when_down_BPF_m_s")
  if (length(miss <- setdiff(need, names(x)))) stop("Input missing: ", paste(miss, collapse = ", "), call. = FALSE)
  x <- x[track_scope == "0_245_m" & is_common_valid == TRUE]
  if (!nrow(x) || anyDuplicated(x$pass_uid)) stop("Invalid paired pass input.", call. = FALSE)
  for (m in names(methods)) for (d in c("up", "down")) {
    q <- x[[paste0("q_", d, "_", m, "_m_s")]]; f <- x[[paste0("f_", d, "_", m)]]; w <- x[[if (d == "up") paste0("mean_w_when_up_", m, "_m_s") else paste0("mean_abs_w_when_down_", m, "_m_s")]]
    if (any(abs(q[f > 0] - f[f > 0] * w[f > 0]) > 1e-12) || any(abs(q[f == 0]) > 1e-12)) stop("Pass-level q decomposition failed for ", m, " ", d, call. = FALSE)
  }
  tt <- parse_bundle_time(x$pass_mid_time_local)
  if (anyNA(tt)) stop("Invalid pass-mid timestamps.", call. = FALSE)
  x[, `:=`(date_local = format(tt, "%Y-%m-%d", tz = "Asia/Shanghai"), half_hour_bin = as.integer(format(tt, "%H", tz = "Asia/Shanghai")) + 0.5 * (as.integer(format(tt, "%M", tz = "Asia/Shanghai")) >= 30))]
  x[, half_hour_local := sprintf("%02d:%02d", floor(half_hour_bin), ifelse(half_hour_bin %% 1 == 0, 0, 30))]
  x
}

to_long <- function(x) {
  rbindlist(lapply(names(methods), function(m) {
    data.table(pass_uid = x$pass_uid, date_local = x$date_local, half_hour_bin = x$half_hour_bin, half_hour_local = x$half_hour_local, coordinate_method = m,
      q_up_m_s = x[[paste0("q_up_", m, "_m_s")]], q_down_m_s = x[[paste0("q_down_", m, "_m_s")]], q_net_m_s = x[[paste0("q_net_", m, "_m_s")]], q_gross_m_s = x[[paste0("q_gross_", m, "_m_s")]], I_A = x[[paste0("I_A_", m)]], f_up = x[[paste0("f_up_", m)]], f_down = x[[paste0("f_down_", m)]], mean_w_when_up_m_s = x[[paste0("mean_w_when_up_", m, "_m_s")]], mean_abs_w_when_down_m_s = x[[paste0("mean_abs_w_when_down_", m, "_m_s")]])
  }))
}

summarise_daily <- function(long) {
  z <- melt(long, id.vars = c("pass_uid", "date_local", "half_hour_bin", "half_hour_local", "coordinate_method"), variable.name = "metric", value.name = "value")[is.finite(value)]
  daily <- z[, .(date_median = median(value), n_passes_day = .N), by = .(date_local, half_hour_bin, half_hour_local, coordinate_method, metric)]
  out <- daily[, .(n_dates = .N, n_passes = sum(n_passes_day), median = median(date_median), q25 = as.numeric(quantile(date_median, .25, names = FALSE)), q75 = as.numeric(quantile(date_median, .75, names = FALSE))), by = .(half_hour_bin, half_hour_local, coordinate_method, metric)]
  out[, coordinate_method := factor(coordinate_method, levels = names(methods), labels = unname(methods))]
  setorder(out, metric, coordinate_method, half_hour_bin); out[]
}

theme_pair <- function() theme_bw(base_size = 11) + theme(panel.grid.minor = element_blank(), legend.position = "top", legend.title = element_blank(), strip.background = element_rect(fill = "grey94"), strip.text = element_text(face = "bold"))
time_scale <- function() scale_x_continuous("Local time (Asia/Shanghai)", breaks = seq(0, 24, 3), limits = c(0, 23.5), labels = function(v) sprintf("%02d:00", as.integer(v)))

plot_strength <- function(s) {
  z <- s[metric %in% c("q_up_m_s", "q_down_m_s")]; z[, plot_median := ifelse(metric == "q_down_m_s", -median, median)]; z[, `:=`(plot_q25 = ifelse(metric == "q_down_m_s", -q75, q25), plot_q75 = ifelse(metric == "q_down_m_s", -q25, q75), metric = factor(metric, levels = c("q_up_m_s", "q_down_m_s"), labels = c("Upward", "Downward (drawn negative)")))]
  ggplot(z, aes(half_hour_bin, plot_median, colour = metric, fill = metric)) + geom_hline(yintercept = 0, colour = "grey55") + geom_ribbon(aes(ymin = plot_q25, ymax = plot_q75), alpha = .14, colour = NA) + geom_line() + facet_wrap(~coordinate_method) + time_scale() + ylab("q (m s-1)") + labs(title = "FL vertical passing intensity", subtitle = "Same date/half-hour pass median, then median and 25th-75th percentile across dates") + theme_pair()
}

plot_direction <- function(s) {
  z <- s[metric %in% c("q_net_m_s", "I_A")]; z[, metric := factor(metric, levels = c("q_net_m_s", "I_A"), labels = c("q_net (m s-1)", "I_A"))]
  ggplot(z, aes(half_hour_bin, median, colour = coordinate_method, fill = coordinate_method)) + geom_hline(yintercept = 0, colour = "grey55") + geom_ribbon(aes(ymin = q25, ymax = q75), alpha = .14, colour = NA) + geom_line() + facet_grid(metric ~ coordinate_method, scales = "free_y") + scale_colour_manual(values = unname(cols)) + scale_fill_manual(values = unname(cols)) + time_scale() + ylab(NULL) + labs(title = "FL vertical-direction tendency") + theme_pair()
}

plot_gross <- function(s) {
  z <- s[metric == "q_gross_m_s"]
  ggplot(z, aes(half_hour_bin, median, colour = coordinate_method, fill = coordinate_method)) + geom_ribbon(aes(ymin = q25, ymax = q75), alpha = .14, colour = NA) + geom_line() + scale_colour_manual(values = unname(cols)) + scale_fill_manual(values = unname(cols)) + time_scale() + ylab("q_gross (m s-1)") + labs(title = "FL total vertical air-motion intensity") + theme_pair()
}

plot_duration_intensity <- function(s) {
  z <- s[metric %in% c("f_up", "mean_w_when_up_m_s", "f_down", "mean_abs_w_when_down_m_s")]
  z[, metric := factor(metric, levels = c("f_up", "mean_w_when_up_m_s", "f_down", "mean_abs_w_when_down_m_s"), labels = c("Upward duration fraction", "Upward conditional speed (m s-1)", "Downward duration fraction", "Downward conditional speed (m s-1)"))]
  ggplot(z, aes(half_hour_bin, median, colour = coordinate_method, fill = coordinate_method)) + geom_ribbon(aes(ymin = q25, ymax = q75), alpha = .14, colour = NA) + geom_line() + facet_grid(metric ~ coordinate_method, scales = "free_y") + scale_colour_manual(values = unname(cols)) + scale_fill_manual(values = unname(cols)) + time_scale() + ylab(NULL) + labs(title = "FL duration versus conditional vertical-motion intensity", subtitle = "Pass-level identity verified: q = duration fraction × conditional speed") + theme_pair()
}

main <- function() {
  if (identical(commandArgs(trailingOnly = TRUE), "--self-check")) { fl_pass_core_self_check(); stopifnot(median(c(1, 3, 9)) == 3); message("Self-check passed."); return() }
  s <- summarise_daily(to_long(read_input()))
  stopifnot(nrow(s) > 0L, all(s$n_dates > 0L), all(s$n_passes >= s$n_dates), all(s$q25 <= s$median), all(s$median <= s$q75), !any(grepl("fw|bw", names(s))))
  tables <- file.path(root, "tables"); figures <- file.path(root, "figures")
  atomic_fwrite(s, file.path(tables, "BPF_0_245_PF8_2ensemble_no_rotation_common_diurnal_30min_daily_median.csv"))
  ggsave(file.path(figures, "BPF_0_245_pass_pair_diurnal_q_up_q_down.png"), plot_strength(s), width = 10, height = 5.6, dpi = 300)
  ggsave(file.path(figures, "BPF_0_245_pass_pair_diurnal_q_net_I_A.png"), plot_direction(s), width = 10, height = 7.2, dpi = 300)
  ggsave(file.path(figures, "BPF_0_245_pass_pair_diurnal_q_gross.png"), plot_gross(s), width = 10, height = 4.8, dpi = 300)
  ggsave(file.path(figures, "BPF_0_245_pass_pair_diurnal_duration_intensity.png"), plot_duration_intensity(s), width = 10, height = 10, dpi = 300)
  message("Wrote daily-cycle summary and four figures to: ", root)
}
main()
