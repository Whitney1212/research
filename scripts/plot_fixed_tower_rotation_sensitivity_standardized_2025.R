#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

out_root <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025"
figure_dir <- file.path(out_root, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

annual_summary_file <- file.path(out_root, "rotation_sensitivity_standardized_2025_annual_summary_all_methods.csv")
delta_file <- file.path(out_root, "rotation_sensitivity_standardized_2025_delta_vs_sector_pf.csv")
tower_diff_file <- file.path(out_root, "rotation_sensitivity_standardized_2025_mt_cvt_method_difference_summary.csv")

method_levels <- c("no_rotation", "dr", "global_pf", "sector_pf", "season_sector_pf")
method_labels <- c(
  no_rotation = "No rotation",
  dr = "Double rotation",
  global_pf = "Global PF",
  sector_pf = "Sector PF",
  season_sector_pf = "Season-sector PF"
)
site_cols <- c(CVT = "#F8766D", MT = "#619CFF")

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
      axis.text.x = element_text(angle = 20, hjust = 1, vjust = 1, colour = "grey20"),
      axis.text.y = element_text(colour = "grey20"),
      plot.caption = element_text(colour = "grey35", size = rel(0.8), hjust = 0)
    )
}

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path)
}

annual_all <- read_required(annual_summary_file)
delta_dt <- read_required(delta_file)
tower_diff <- read_required(tower_diff_file)

common_methods <- method_levels[1:4]
annual_plot_dt <- annual_all[method %in% common_methods]
delta_plot_methods <- common_methods

annual_all[, method := factor(method, levels = method_levels, labels = method_labels[method_levels])]
annual_plot_dt[, method := factor(method, levels = common_methods, labels = method_labels[common_methods])]
delta_dt[, method := factor(method, levels = method_levels, labels = method_labels[method_levels])]
tower_diff[, method := factor(method, levels = method_levels[1:4], labels = method_labels[method_levels[1:4]])]

annual_all[, tower := factor(tower, levels = c("MT", "CVT"))]
annual_plot_dt[, tower := factor(tower, levels = c("MT", "CVT"))]
delta_dt[, tower := factor(tower, levels = c("MT", "CVT"))]

annual_all[, observed_fraction := observed_valid_windows / expected_halfhours]
annual_all[, gapfilled_fraction := gapfilled_windows / expected_halfhours]
annual_plot_dt[, observed_fraction := observed_valid_windows / expected_halfhours]
annual_plot_dt[, gapfilled_fraction := gapfilled_windows / expected_halfhours]

stopifnot(
  all(annual_all$method %in% method_labels),
  all(abs(annual_all$observed_fraction + annual_all$gapfilled_fraction - 1) < 1e-9)
)

annual_plot <- ggplot(
  annual_plot_dt,
  aes(x = method, y = annual_nee_estimate_gC_m2, group = tower, colour = tower)
) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_line(linewidth = 0.8, na.rm = TRUE) +
  geom_point(size = 2.3, na.rm = TRUE) +
  facet_wrap(~ tower, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = site_cols) +
  labs(
    title = "Fixed-tower 2025 annual NEE sensitivity to rotation method",
    subtitle = "Standardized 30 min inputs; strict downstream = qc_co2 <= 1 + flag9_co2 <= 3 + night u* + existing W3 gapfilling",
    x = NULL,
    y = expression("Annual NEE estimate (gC m"^-2 * ")"),
    caption = "Only the common four methods are shown: no_rotation, dr, global_pf, sector_pf."
  ) +
  theme_regov(base_size = 13)

ggsave(
  file.path(figure_dir, "fixed_tower_rotation_sensitivity_annual_nee_by_method.png"),
  annual_plot,
  width = 10.6,
  height = 8.2,
  dpi = 300
)

coverage_plot <- ggplot(annual_plot_dt, aes(x = method)) +
  geom_col(aes(y = 1), fill = "grey92", width = 0.72) +
  geom_col(aes(y = observed_fraction, fill = tower), width = 0.72) +
  geom_text(
    aes(
      y = pmin(observed_fraction + 0.04, 1.03),
      label = sprintf("%d / %d", observed_valid_windows, expected_halfhours),
      colour = tower
    ),
    size = 3.15,
    show.legend = FALSE
  ) +
  facet_wrap(~ tower, ncol = 1) +
  scale_fill_manual(values = site_cols) +
  scale_colour_manual(values = site_cols) +
  scale_y_continuous(
    limits = c(0, 1.05),
    breaks = seq(0, 1, by = 0.2),
    labels = function(x) sprintf("%.0f%%", x * 100)
  ) +
  labs(
    title = "Observed valid-window share by rotation method",
    subtitle = "Grey column = full year; coloured segment = observed_valid_windows; remainder is gapfilled_windows",
    x = NULL,
    y = "Observed valid share of 2025 half-hours",
    fill = NULL,
    caption = "Text labels show observed_valid_windows / expected_halfhours."
  ) +
  theme_regov(base_size = 13)

ggsave(
  file.path(figure_dir, "fixed_tower_rotation_sensitivity_observed_fraction_by_method.png"),
  coverage_plot,
  width = 10.6,
  height = 8.2,
  dpi = 300
)

delta_plot_dt <- rbindlist(list(
  delta_dt[method %in% method_labels[delta_plot_methods], .(
    facet_label = sprintf("%s delta vs Sector PF", tower),
    method,
    value = annual_nee_delta_vs_sector_pf_gC_m2,
    group_colour = as.character(tower)
  )],
  tower_diff[, .(
    facet_label = "MT - CVT annual NEE difference",
    method,
    value = mt_minus_cvt_annual_nee_estimate_gC_m2,
    group_colour = "MT_minus_CVT"
  )]
), use.names = TRUE)

delta_plot_dt[, facet_label := factor(
  facet_label,
  levels = c("MT delta vs Sector PF", "CVT delta vs Sector PF", "MT - CVT annual NEE difference")
)]

delta_cols <- c(site_cols, MT_minus_CVT = "grey25")

delta_plot <- ggplot(delta_plot_dt, aes(x = method, y = value, fill = group_colour)) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_col(width = 0.72, colour = "white", linewidth = 0.25) +
  facet_wrap(~ facet_label, ncol = 1, scales = "free_y") +
  scale_fill_manual(values = delta_cols) +
  labs(
    title = "Rotation-method annual NEE deltas and tower contrast",
    subtitle = "Upper panels: within-tower delta relative to Sector PF; lower panel: MT minus CVT under the common four methods",
    x = NULL,
    y = expression(Delta * " annual NEE estimate (gC m"^-2 * ")"),
    caption = "Positive delta vs Sector PF means the method is less negative than Sector PF."
  ) +
  theme_regov(base_size = 13)

ggsave(
  file.path(figure_dir, "fixed_tower_rotation_sensitivity_annual_nee_delta_summary.png"),
  delta_plot,
  width = 10.6,
  height = 10.2,
  dpi = 300
)

plot_data_absolute <- annual_all[, .(
  tower,
  method = as.character(method),
  common_method,
  expected_halfhours,
  observed_valid_windows,
  gapfilled_windows,
  observed_fraction,
  gapfilled_fraction,
  annual_nee_estimate_gC_m2
)]
plot_data_delta <- delta_plot_dt[, .(
  facet_label = as.character(facet_label),
  method = as.character(method),
  value,
  group_colour
)]

fwrite(plot_data_absolute, file.path(out_root, "fixed_tower_rotation_sensitivity_plot_data_absolute.csv"))
fwrite(plot_data_delta, file.path(out_root, "fixed_tower_rotation_sensitivity_plot_data_delta.csv"))

writeLines(c(
  "Fixed-tower 2025 rotation sensitivity summary figures",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  "",
  "Inputs:",
  paste0("- ", annual_summary_file),
  paste0("- ", delta_file),
  paste0("- ", tower_diff_file),
  "",
  "Outputs:",
  "- fixed_tower_rotation_sensitivity_plot_data_absolute.csv",
  "- fixed_tower_rotation_sensitivity_plot_data_delta.csv",
  "- figures/fixed_tower_rotation_sensitivity_annual_nee_by_method.png",
  "- figures/fixed_tower_rotation_sensitivity_observed_fraction_by_method.png",
  "- figures/fixed_tower_rotation_sensitivity_annual_nee_delta_summary.png",
  "",
  "Style notes:",
  "- Follows project-memory REgov style: theme_bw white background, no minor grid, top legend.",
  "- Tower colours follow project memory: CVT = #F8766D, MT = #619CFF.",
  "- Annual NEE panels include y = 0 reference lines because sign matters physically.",
  "- Season-sector PF is intentionally excluded from the figures because the user requested common four-method plots only."
), file.path(out_root, "fixed_tower_rotation_sensitivity_figures_summary.txt"), useBytes = TRUE)

message("Wrote rotation sensitivity summary figures to: ", figure_dir)
