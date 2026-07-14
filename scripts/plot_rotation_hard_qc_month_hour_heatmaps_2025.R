#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

output_root <- "E:/Dataset_Level1/Rotation"

for (site in c("MT", "CVT")) {
  output_dir <- file.path(output_root, site, "hard_qc_common_window_diagnostics_2025")
  input_file <- file.path(output_dir, sprintf("%s_hard_qc_common_window_by_month_hour_2025.csv", site))
  x <- fread(input_file)[rotation_method != "no_rotation"]
  x[, halfhour := factor(halfhour, levels = sprintf("%02d:%02d", rep(0:23, each = 2), rep(c(0, 30), 24)))]
  x[, month := factor(month, levels = 1:12, labels = month.abb)]
  limit <- max(abs(x$delta_nee_flux_gC_m2))
  p <- ggplot(x, aes(x = halfhour, y = month, fill = delta_nee_flux_gC_m2)) +
    geom_tile() +
    facet_wrap(~rotation_method, ncol = 1) +
    scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0, limits = c(-limit, limit), oob = scales::squish) +
    scale_x_discrete(breaks = sprintf("%02d:00", seq(0, 21, by = 3))) +
    labs(
      title = paste(site, "hard-QC common-window rotation difference"),
      subtitle = "Monthly × half-hour cumulative ΔNEE relative to No rotation; no downstream QC or gapfill",
      x = "Local half-hour", y = NULL, fill = expression(Delta * "NEE (gC m"^-2 * ")")
    ) +
    theme_minimal(base_size = 11) +
    theme(panel.grid = element_blank(), strip.text = element_text(face = "bold"))
  ggsave(file.path(output_dir, sprintf("%s_hard_qc_common_window_month_hour_cumulative_difference_2025.png", site)), p,
         width = 10, height = 8, dpi = 180)

  state_file <- file.path(output_dir, sprintf("%s_hard_qc_common_window_by_wind_sector_stability_2025.csv", site))
  state <- fread(state_file)[rotation_method != "no_rotation"]
  sector_levels <- sprintf("%03d-%03d", seq(0, 330, by = 30), seq(30, 360, by = 30))
  state[, `:=`(
    wind_sector_30deg = factor(wind_sector_30deg, levels = sector_levels),
    stability_class = factor(stability_class, levels = c("stable", "near_neutral", "unstable"))
  )]
  state_limit <- max(abs(state$delta_nee_flux_gC_m2))
  p_state <- ggplot(state, aes(x = wind_sector_30deg, y = stability_class, fill = delta_nee_flux_gC_m2)) +
    geom_tile() +
    facet_wrap(~rotation_method, ncol = 1) +
    scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0,
                         limits = c(-state_limit, state_limit), oob = scales::squish) +
    labs(
      title = paste(site, "hard-QC wind-sector × stability difference"),
      subtitle = "30° wind-from sectors; z/L: stable > 0.1, near-neutral −0.1 to 0.1, unstable < −0.1",
      x = "Wind-from sector (degrees)", y = "Stability class", fill = expression(Delta * "NEE (gC m"^-2 * ")")
    ) +
    theme_minimal(base_size = 11) +
    theme(panel.grid = element_blank(), strip.text = element_text(face = "bold"), axis.text.x = element_text(angle = 45, hjust = 1))
  ggsave(file.path(output_dir, sprintf("%s_hard_qc_common_window_wind_sector_stability_cumulative_difference_2025.png", site)), p_state,
         width = 10, height = 7, dpi = 180)
}
