#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

site_cols <- c(CVT = "#F8766D", MT = "#619CFF")

out_root <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025"
figure_dir <- file.path(out_root, "figures_diurnal")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

scenario_configs <- data.table(
  qc_scenario = c("Strict QC", "No qc_co2 / flag9"),
  run_plan = c(
    file.path(out_root, "rotation_sensitivity_standardized_2025_run_plan.csv"),
    "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025_no_qc_no_flag9/rotation_sensitivity_standardized_2025_no_qc_no_flag9_run_plan.csv"
  ),
  output_tag = c("", "no_qc_no_flag9")
)

theme_regov <- function(base_size = 13) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.major = element_line(colour = "grey88", linewidth = 0.25),
      panel.grid.minor = element_blank(),
      legend.position = "top",
      legend.title = element_blank(),
      legend.key = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.text = element_text(colour = "grey20"),
      plot.caption = element_text(colour = "grey35", size = rel(0.8), hjust = 0)
    )
}

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path)
}

build_gapfilled_file <- function(tower, method_output_dir, output_tag) {
  prefix <- sprintf("%s_nee_2025_estimate", tower)
  if (!identical(output_tag, "")) prefix <- sprintf("%s_%s", prefix, output_tag)
  file.path(method_output_dir, sprintf("%s_30min_gapfilled.csv", prefix))
}

read_case_30min <- function(case_row, qc_scenario, output_tag) {
  path <- build_gapfilled_file(case_row$tower[[1]], case_row$method_output_dir[[1]], output_tag)
  dt <- read_required(path)
  keep_cols <- intersect(c("hhmm", "hour", "minute", "gapfilled_co2_flux"), names(dt))
  dt <- dt[, ..keep_cols]
  if (!all(c("hhmm", "gapfilled_co2_flux") %in% names(dt))) {
    stop("Missing required columns in ", path, call. = FALSE)
  }
  if (!all(c("hour", "minute") %in% names(dt))) {
    dt[, `:=`(
      hour = as.integer(substr(hhmm, 1, 2)),
      minute = as.integer(substr(hhmm, 4, 5))
    )]
  }
  dt[, `:=`(
    tower = case_row$tower[[1]],
    qc_scenario = qc_scenario,
    half_hour_bin = as.integer(hour) + as.integer(minute) / 60
  )]
  dt[is.finite(gapfilled_co2_flux)]
}

build_diurnal_stats <- function(cfg) {
  run_plan <- read_required(cfg$run_plan)
  run_plan <- run_plan[method == "no_rotation"]
  if (nrow(run_plan) != 2L) stop("Expected two no_rotation cases in ", cfg$run_plan, call. = FALSE)
  dt <- rbindlist(
    lapply(seq_len(nrow(run_plan)), function(i) {
      read_case_30min(run_plan[i], cfg$qc_scenario, cfg$output_tag)
    }),
    use.names = TRUE,
    fill = TRUE
  )
  dt[, .(
    n_windows = .N,
    q25 = as.numeric(stats::quantile(gapfilled_co2_flux, probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_flux = stats::median(gapfilled_co2_flux, na.rm = TRUE),
    q75 = as.numeric(stats::quantile(gapfilled_co2_flux, probs = 0.75, na.rm = TRUE, names = FALSE)),
    mean_flux = mean(gapfilled_co2_flux, na.rm = TRUE)
  ), by = .(tower, qc_scenario, hhmm, half_hour_bin)]
}

stats_dt <- rbindlist(
  lapply(seq_len(nrow(scenario_configs)), function(i) build_diurnal_stats(scenario_configs[i])),
  use.names = TRUE,
  fill = TRUE
)
stats_dt[, `:=`(
  tower = factor(tower, levels = c("CVT", "MT")),
  qc_scenario = factor(qc_scenario, levels = scenario_configs$qc_scenario)
)]
setorder(stats_dt, tower, qc_scenario, half_hour_bin)

count_check <- stats_dt[, .N, by = .(tower, qc_scenario)]
stopifnot(all(count_check$N == 48L))

csv_file <- file.path(out_root, "fixed_tower_no_rotation_qc_contrast_diurnal_2025_plot_data.csv")
plot_file <- file.path(figure_dir, "fixed_tower_no_rotation_qc_contrast_diurnal_2025.png")
summary_file <- file.path(out_root, "fixed_tower_no_rotation_qc_contrast_diurnal_2025_summary.txt")

p <- ggplot(
  stats_dt,
  aes(x = half_hour_bin, y = median_flux, colour = tower, linetype = qc_scenario, group = interaction(tower, qc_scenario))
) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
  geom_line(linewidth = 0.45) +
  scale_colour_manual(values = site_cols, drop = FALSE) +
  scale_linetype_manual(values = c("Strict QC" = "solid", "No qc_co2 / flag9" = "longdash")) +
  scale_x_continuous(
    breaks = seq(0, 24, by = 3),
    limits = c(0, 23.5),
    labels = function(x) sprintf("%02d:00", as.integer(x))
  ) +
  scale_y_continuous(breaks = function(x) pretty(x, n = 12)) +
  labs(
    title = "Fixed-tower 2025 no-rotation diurnal NEE proxy: QC contrast",
    subtitle = "Line = median gapfilled 30 min CO2 flux by half-hour across 2025 dates; colour = tower; linetype = downstream QC scenario.",
    x = "Local half-hour bin",
    y = expression("Gapfilled 30 min CO"[2] * " flux / NEE proxy (" * mu * "mol m"^-2 * " s"^-1 * ")"),
    caption = "Strict QC uses qc_co2 <= 1 + flag9_co2 <= 3 + night u*. No qc_co2 / flag9 keeps night u* but disables qc_co2 and flag9 exclusions."
  ) +
  theme_regov(base_size = 13)

ggsave(plot_file, p, width = 10.8, height = 6.7, dpi = 300)

plot_out <- copy(stats_dt)
plot_out[, `:=`(
  tower = as.character(tower),
  qc_scenario = as.character(qc_scenario)
)]
fwrite(plot_out, csv_file)

writeLines(c(
  "Fixed-tower 2025 no-rotation QC-contrast diurnal plot",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  "",
  "Outputs:",
  paste0("- ", csv_file),
  paste0("- ", plot_file),
  "",
  "Notes:",
  "- Uses existing per-tower no_rotation 30 min gapfilled outputs.",
  "- Central line = median gapfilled_co2_flux by half-hour across all 2025 dates.",
  "- Tower colours follow project memory: CVT = #F8766D, MT = #619CFF.",
  "- Strict QC uses qc_co2 <= 1 + flag9_co2 <= 3 + night u*.",
  "- No qc_co2 / flag9 keeps night u* but disables qc_co2 and flag9 exclusions."
), summary_file, useBytes = TRUE)

message("Wrote no-rotation QC-contrast diurnal plot to: ", plot_file)
