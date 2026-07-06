#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

input_file <- "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/metrics/morning_peak_amplitude_inventory_2025_site_day.csv"
output_dir <- "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/figures/amplitude"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

site_colors <- c(CVT = "#F8766D", MT = "#619CFF")

theme_report <- function(base_size = 13) {
  theme_bw(base_size = base_size) +
    theme(
      legend.position = "top",
      legend.title = element_blank(),
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "grey92", color = "grey70"),
      plot.title = element_text(face = "bold")
    )
}

amp <- fread(input_file, encoding = "UTF-8")
amp[, `:=`(
  date = as.IDate(date),
  amp_ppm = as.numeric(amp_ppm),
  site = factor(site, levels = c("CVT", "MT"))
)]
amp <- amp[is.finite(amp_ppm)]

ranked <- amp[order(site, -amp_ppm)]
ranked[, rank_desc := seq_len(.N), by = site]
ranked[, exceedance_fraction := rank_desc / .N, by = site]

vline_data <- data.table(x = c(0, 5, 10), label = c("0", "5", "10"))

p_dist <- ggplot(amp, aes(x = amp_ppm, fill = site, color = site)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50, alpha = 0.35, linewidth = 0.2) +
  geom_density(linewidth = 0.9, adjust = 1.1, na.rm = TRUE) +
  geom_vline(data = vline_data, aes(xintercept = x), inherit.aes = FALSE, linetype = "dashed", color = "grey35") +
  facet_wrap(~site, ncol = 1, scales = "free_y") +
  scale_fill_manual(values = site_colors) +
  scale_color_manual(values = site_colors) +
  labs(
    title = "Morning peak amplitude distribution, 2025",
    subtitle = "amp_ppm = peak-window max CO2 - pre-min-window min CO2; dashed lines: 0, 5, 10 ppm",
    x = "Amplitude (ppm)",
    y = "Density",
    caption = "Input: morning_peak_amplitude_inventory_2025_site_day.csv"
  ) +
  theme_report()

p_rank <- ggplot(ranked, aes(x = exceedance_fraction, y = amp_ppm, color = site)) +
  geom_hline(yintercept = c(0, 5, 10), linetype = "dashed", color = "grey35") +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.2, alpha = 0.65) +
  scale_color_manual(values = site_colors) +
  scale_x_continuous(labels = function(x) paste0(round(x * 100), "%")) +
  labs(
    title = "Morning peak amplitude exceedance curve, 2025",
    subtitle = "Dates sorted from largest to smallest amplitude within each tower",
    x = "Rank fraction",
    y = "Amplitude (ppm)",
    caption = "Dashed lines are reference levels, not frozen event thresholds."
  ) +
  theme_report()

ggsave(file.path(output_dir, "morning_peak_amplitude_distribution_2025.png"), p_dist, width = 11, height = 8, dpi = 300)
ggsave(file.path(output_dir, "morning_peak_amplitude_exceedance_curve_2025.png"), p_rank, width = 11, height = 7, dpi = 300)

summary_tbl <- amp[, .(
  n = .N,
  n_amp_gt_0 = sum(amp_ppm > 0),
  n_amp_ge_5 = sum(amp_ppm >= 5),
  n_amp_ge_10 = sum(amp_ppm >= 10),
  median_amp = median(amp_ppm),
  q75_amp = as.numeric(quantile(amp_ppm, 0.75)),
  q90_amp = as.numeric(quantile(amp_ppm, 0.90)),
  q95_amp = as.numeric(quantile(amp_ppm, 0.95))
), by = site]
fwrite(summary_tbl, file.path(output_dir, "morning_peak_amplitude_plot_summary_2025.csv"))

message("Wrote amplitude figures to: ", output_dir)
