#!/usr/bin/env Rscript

suppressPackageStartupMessages({ library(data.table); library(ggplot2) })

root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"
inputs <- c(
  bin_10m = "BPF_0_245_PF8_2ensemble_no_rotation_common_pass_bin_10m.csv",
  bpf_8bin = "BPF_0_245_PF8_2ensemble_no_rotation_common_pass_bin_BPF8.csv"
)
labels <- c(bin_10m = "10 m position bins", bpf_8bin = "BPF fixed 8 bins (30.625 m)")
cols <- c(no_rotation_common = "#4E79A7", BPF_PF8_2ensemble = "#D55E00")

summarise_metric <- function(x, metrics) {
  long <- melt(x, id.vars = c("pass_uid", "position_bin_id", "position_bin_min_m", "position_bin_max_m", "position_bin_mid_m", "coordinate_method"), measure.vars = metrics, variable.name = "metric", value.name = "value")
  long[is.finite(value), .(n_passes = uniqueN(pass_uid), median = median(value), q25 = as.numeric(quantile(value, .25)), q75 = as.numeric(quantile(value, .75))), by = .(position_bin_id, position_bin_min_m, position_bin_max_m, position_bin_mid_m, coordinate_method, metric)]
}

plot_all <- function(key, input) {
  x <- fread(file.path(root, "tables", input))
  stopifnot(all(x$track_scope == "0_245_m"), !anyDuplicated(x[, .(pass_uid, position_bin_id, coordinate_method)]))
  fig <- file.path(root, "figures"); tab <- file.path(root, "tables")
  air <- summarise_metric(x, c("q_net_m_s", "q_gross_m_s"))
  co2 <- summarise_metric(unique(x[coordinate_method == "no_rotation_common"], by = c("pass_uid", "position_bin_id")), "co2_anom_mean_ppm")
  co2[, coordinate_method := "shared_common_mask"]
  transport <- summarise_metric(x, c("F_EC_cov_ppm_m_s", "F_EA_anom_ppm_m_s"))
  fwrite(rbindlist(list(air, co2, transport), fill = TRUE), file.path(tab, paste0("BPF_0_245_PF8_2ensemble_no_rotation_common_", key, "_visual_summary.csv")))
  title <- labels[[key]]
  p_air <- ggplot(air, aes(position_bin_mid_m, median, colour = coordinate_method, fill = coordinate_method)) + geom_hline(yintercept = 0, colour = "grey60", linewidth = .3) + geom_ribbon(aes(ymin = q25, ymax = q75), alpha = .14, colour = NA) + geom_line(linewidth = .75) + geom_point(size = 1.5) + facet_wrap(~ metric, scales = "free_y", ncol = 1, labeller = as_labeller(c(q_net_m_s = "Net vertical air motion (q_net)", q_gross_m_s = "Vertical air-motion intensity (q_gross)"))) + scale_colour_manual(values = cols, labels = c(no_rotation_common = "No rotation (common mask)", BPF_PF8_2ensemble = "BPF PF8")) + scale_fill_manual(values = cols, labels = c(no_rotation_common = "No rotation (common mask)", BPF_PF8_2ensemble = "BPF PF8")) + scale_x_continuous("Track position (m; 0 = south, 245 = north)", limits = c(0, 245)) + ylab("m s-1") + labs(title = paste("FL paired air-motion profile —", title), subtitle = "Line = pass median; ribbon = 25th–75th percentile; fw/bw pooled", colour = NULL, fill = NULL) + theme_bw(base_size = 11) + theme(legend.position = "top", panel.grid.minor = element_blank())
  ggsave(file.path(fig, paste0("FL_paired_position_", key, "_air_motion.png")), p_air, width = 10, height = 7, dpi = 300)
  p_co2 <- ggplot(co2, aes(position_bin_mid_m, median)) + geom_hline(yintercept = 0, colour = "grey60", linewidth = .3) + geom_ribbon(aes(ymin = q25, ymax = q75), fill = "#00BA38", alpha = .18) + geom_line(colour = "#00BA38", linewidth = .8) + geom_point(colour = "#00BA38", size = 1.6) + scale_x_continuous("Track position (m; 0 = south, 245 = north)", limits = c(0, 245)) + ylab("CO2 anomaly relative to pass mean (ppm)") + labs(title = paste("FL CO2 anomaly profile —", title), subtitle = "Common BPF-valid samples only; line = pass median; ribbon = 25th–75th percentile") + theme_bw(base_size = 11) + theme(panel.grid.minor = element_blank())
  ggsave(file.path(fig, paste0("FL_paired_position_", key, "_co2_anomaly.png")), p_co2, width = 10, height = 4.8, dpi = 300)
  p_transport <- ggplot(transport, aes(position_bin_mid_m, median, colour = coordinate_method, fill = coordinate_method)) + geom_hline(yintercept = 0, colour = "grey60", linewidth = .3) + geom_ribbon(aes(ymin = q25, ymax = q75), alpha = .14, colour = NA) + geom_line(linewidth = .75) + geom_point(size = 1.4) + facet_grid(metric ~ coordinate_method, scales = "free_y", labeller = as_labeller(c(F_EC_cov_ppm_m_s = "EC covariance diagnostic", F_EA_anom_ppm_m_s = "EA CO2-anomaly transport diagnostic", no_rotation_common = "No rotation", BPF_PF8_2ensemble = "BPF PF8"))) + scale_colour_manual(values = cols, guide = "none") + scale_fill_manual(values = cols, guide = "none") + scale_x_continuous("Track position (m; 0 = south, 245 = north)", limits = c(0, 245)) + ylab("ppm m s-1") + labs(title = paste("FL EC/EA transport diagnostics —", title), subtitle = "Pass-level median and 25th–75th percentile; diagnostic quantities, not ecosystem CO2 flux") + theme_bw(base_size = 11) + theme(panel.grid.minor = element_blank())
  ggsave(file.path(fig, paste0("FL_paired_position_", key, "_ec_ea_transport.png")), p_transport, width = 12, height = 7.5, dpi = 300)
}

if ("--self-check" %in% commandArgs(trailingOnly = TRUE)) { stopifnot(identical(names(inputs), c("bin_10m", "bpf_8bin"))); message("Self-check passed."); quit(save = "no") }
for (key in names(inputs)) plot_all(key, inputs[[key]])
