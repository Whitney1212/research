suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

in_dir <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/mechanism_diagnostics"
figure_dir <- file.path(in_dir, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

method_levels <- c("No rotation", "Double rotation", "Global PF", "Sector PF")
method_cols <- c(
  "No rotation" = "#4E79A7",
  "Double rotation" = "#F28E2B",
  "Global PF" = "#59A14F",
  "Sector PF" = "#E15759"
)
site_cols <- c(
  "CVT" = "#F8766D",
  "MT" = "#619CFF"
)

theme_regov <- function(base_size = 13) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.major = element_line(colour = "grey88", linewidth = 0.25),
      panel.grid.minor = element_blank(),
      legend.position = "top",
      legend.title = element_blank(),
      legend.key = element_blank(),
      strip.background = element_rect(fill = "grey94", colour = "grey80"),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold"),
      axis.text = element_text(colour = "grey20"),
      axis.text.x = element_text(angle = 20, hjust = 1, vjust = 1),
      plot.caption = element_text(colour = "grey35", size = rel(0.8), hjust = 0)
    )
}

plot_sigma_w <- function() {
  x <- fread(file.path(in_dir, "rotation_wmean_wc_diurnal_summary.csv"))[
    variable == "w' / sigma_w (m s^-1)"
  ][
    , method_label := factor(method_label, levels = method_levels)
  ]

  stopifnot(nrow(x) > 0L)

  p <- ggplot(x, aes(x = hour_decimal, y = median_value, colour = method_label, fill = method_label, group = method_label)) +
    geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.13, colour = NA) +
    geom_line(linewidth = 0.55) +
    facet_wrap(~ site, ncol = 1, scales = "free_y") +
    scale_colour_manual(values = method_cols, drop = FALSE) +
    scale_fill_manual(values = method_cols, drop = FALSE) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(v) sprintf("%02d:00", as.integer(v))
    ) +
    scale_y_continuous(breaks = function(v) pretty(v, n = 10)) +
    labs(
      title = "Fixed-tower common-period sigma_w diurnal comparison across rotation methods",
      subtitle = "Median line with 25-75% ribbon; common four methods only.",
      x = "Local half-hour bin",
      y = expression(sigma[w]~"(m s"^-1*")"),
      caption = "Source = existing four-method rotation diagnostics. sigma_w is used as the 30 min observable scale of w'."
    ) +
    theme_regov(base_size = 13)

  out_png <- file.path(figure_dir, "rotation_sigma_w_diurnal_comparison_2025.png")
  ggsave(out_png, p, width = 11.2, height = 8.8, dpi = 300)
  fwrite(x, file.path(in_dir, "rotation_sigma_w_diurnal_plot_data.csv"))
  out_png
}

plot_sigma_co2 <- function() {
  dt <- fread(file.path(in_dir, "rotation_sigma_co2_paired_common_periods.csv"))
  stopifnot(nrow(dt) > 0L)

  x <- dt[
    ,
    .(
      n_windows = .N,
      q25 = as.numeric(stats::quantile(sigma_co2, probs = 0.25, na.rm = TRUE, names = FALSE)),
      median_value = stats::median(sigma_co2, na.rm = TRUE),
      q75 = as.numeric(stats::quantile(sigma_co2, probs = 0.75, na.rm = TRUE, names = FALSE))
    ),
    by = .(site, hour_decimal)
  ][order(site, hour_decimal)]

  p <- ggplot(x, aes(x = hour_decimal, y = median_value, colour = site, fill = site, group = site)) +
    geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.16, colour = NA) +
    geom_line(linewidth = 0.55) +
    facet_wrap(~ site, ncol = 1, scales = "free_y") +
    scale_colour_manual(values = site_cols, drop = FALSE) +
    scale_fill_manual(values = site_cols, drop = FALSE) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(v) sprintf("%02d:00", as.integer(v))
    ) +
    scale_y_continuous(breaks = function(v) pretty(v, n = 10)) +
    labs(
      title = "Fixed-tower common-period sigma_co2 diurnal pattern",
      subtitle = "Median line with 25-75% ribbon; paired common-period half-hours only.",
      x = "Local half-hour bin",
      y = expression(sigma[CO[2]]~"(umol mol"^-1*")"),
      caption = "Source = common-period Level0 CO2 series summarized to 30 min. Median-based summary reduces the influence of MT outlier spikes."
    ) +
    theme_regov(base_size = 13)

  out_png <- file.path(figure_dir, "rotation_sigma_co2_diurnal_common_periods.png")
  ggsave(out_png, p, width = 11.2, height = 8.8, dpi = 300)
  fwrite(x, file.path(in_dir, "rotation_sigma_co2_diurnal_plot_data.csv"))
  out_png
}

main <- function() {
  sigma_w_png <- plot_sigma_w()
  sigma_co2_png <- plot_sigma_co2()
  message("Wrote: ", sigma_w_png)
  message("Wrote: ", sigma_co2_png)
}

if (sys.nframe() == 0L) {
  main()
}
