#!/usr/bin/env Rscript

# Time-aligned BPF vertical-motion and CO2 concentration daily cycles.
suppressPackageStartupMessages({ library(data.table); library(ggplot2) })

root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"

main <- function() {
  wind <- fread(file.path(root, "tables", "BPF_0_245_PF8_2ensemble_no_rotation_common_diurnal_30min_daily_median.csv"))
  co2 <- fread(file.path(root, "tables", "BPF_0_245_common_mask_co2_diurnal_30min_daily_median.csv"))
  wind <- wind[coordinate_method %in% c("BPF PF8 two-ensemble", "No rotation (common mask)") & metric %in% c("q_up_m_s", "q_down_m_s", "q_net_m_s")]
  if (nrow(wind) != 288L || nrow(co2) != 48L) stop("Unexpected daily-cycle inputs.", call. = FALSE)
  wind[, `:=`(plot_median = ifelse(metric == "q_down_m_s", -median, median), plot_q25 = ifelse(metric == "q_down_m_s", -q75, q25), plot_q75 = ifelse(metric == "q_down_m_s", -q25, q75), series = factor(metric, levels = c("q_up_m_s", "q_down_m_s", "q_net_m_s"), labels = c("Upward", "Downward (drawn negative)", "Net (upward - downward)")), panel = paste0("Vertical air motion (m s-1): ", ifelse(coordinate_method == "BPF PF8 two-ensemble", "BPF", "No rotation")))]
  z_wind <- wind[, .(half_hour_bin, half_hour_local, panel, series, median = plot_median, q25 = plot_q25, q75 = plot_q75)]
  z_co2 <- co2[, .(half_hour_bin, half_hour_local, panel = "CO2 concentration (ppm)", series = factor("CO2"), median = median_ppm, q25 = q25_ppm, q75 = q75_ppm)]
  z <- rbindlist(list(z_wind, z_co2), use.names = TRUE)
  stopifnot(uniqueN(z[panel == "Vertical air motion (m s-1): BPF", half_hour_bin]) == 48L, uniqueN(z[panel == "Vertical air motion (m s-1): No rotation", half_hour_bin]) == 48L, uniqueN(z[panel == "CO2 concentration (ppm)", half_hour_bin]) == 48L)
  ribbon <- z[series != "Net (upward - downward)"]
  p <- ggplot(z, aes(half_hour_bin, median, colour = series, fill = series)) + geom_hline(data = data.table(panel = c("Vertical air motion (m s-1): BPF", "Vertical air motion (m s-1): No rotation")), aes(yintercept = 0), inherit.aes = FALSE, colour = "grey55", linewidth = .3) + geom_ribbon(data = ribbon, aes(ymin = q25, ymax = q75), alpha = .16, colour = NA) + geom_line(linewidth = .75) + facet_grid(panel ~ ., scales = "free_y") + scale_colour_manual(values = c("Upward" = "#C44E52", "Downward (drawn negative)" = "#4E79A7", "Net (upward - downward)" = "#000000", "CO2" = "#2E8B57")) + scale_fill_manual(values = c("Upward" = "#C44E52", "Downward (drawn negative)" = "#4E79A7", "CO2" = "#2E8B57")) + scale_x_continuous("Local time (Asia/Shanghai)", breaks = seq(0, 24, 3), limits = c(0, 23.5), labels = function(v) sprintf("%02d:00", as.integer(v))) + ylab(NULL) + labs(title = "FL paired vertical air motion and CO2 concentration", subtitle = "Same date/half-hour pass median, then median and 25th-75th percentile across dates", caption = "0-245 m BPF-common mask; black line = net vertical air motion. CO2 is a concentration diagnostic, not flux.") + theme_bw(base_size = 11) + theme(panel.grid.minor = element_blank(), legend.position = "top", legend.title = element_blank(), strip.background = element_rect(fill = "grey94"), strip.text = element_text(face = "bold"), plot.title = element_text(face = "bold"))
  ggsave(file.path(root, "figures", "BPF_0_245_paired_wind_q_up_q_down_and_co2_diurnal.png"), p, width = 10, height = 7.2, dpi = 300)
  message("Wrote time-aligned wind/CO2 panel figure.")
}
main()
