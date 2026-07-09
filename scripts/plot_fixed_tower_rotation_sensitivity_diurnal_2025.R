#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

method_levels <- c("no_rotation", "dr", "global_pf", "sector_pf")
method_labels <- c(
  no_rotation = "No rotation",
  dr = "Double rotation",
  global_pf = "Global PF",
  sector_pf = "Sector PF"
)
method_cols <- c(
  no_rotation = "#4E79A7",
  dr = "#F28E2B",
  global_pf = "#59A14F",
  sector_pf = "#E15759"
)
method_cols_labeled <- unname(method_cols[method_levels])
names(method_cols_labeled) <- method_labels[method_levels]

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
      plot.caption = element_text(colour = "grey35", size = rel(0.8), hjust = 0)
    )
}

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path)
}

scenario_configs <- list(
  strict = list(
    root = "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025",
    run_plan = "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/rotation_sensitivity_standardized_2025_run_plan.csv",
    output_tag = "",
    plot_stub = "fixed_tower_rotation_sensitivity_diurnal_strict",
    subtitle = "Strict downstream: qc_co2 <= 1 + flag9_co2 <= 3 + night u*; line = median; ribbon = 25th-75th percentile across 2025 dates."
  ),
  no_qc_no_flag9 = list(
    root = "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025_no_qc_no_flag9",
    run_plan = "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025_no_qc_no_flag9/rotation_sensitivity_standardized_2025_no_qc_no_flag9_run_plan.csv",
    output_tag = "no_qc_no_flag9",
    plot_stub = "fixed_tower_rotation_sensitivity_diurnal_no_qc_no_flag9",
    subtitle = "No qc_co2 / flag9_co2 exclusion; night u* still applied; line = median; ribbon = 25th-75th percentile across 2025 dates."
  )
)

build_gapfilled_file <- function(tower, method_output_dir, output_tag) {
  prefix <- sprintf("%s_nee_2025_estimate", tower)
  if (!identical(output_tag, "")) prefix <- sprintf("%s_%s", prefix, output_tag)
  file.path(method_output_dir, sprintf("%s_30min_gapfilled.csv", prefix))
}

read_case_30min <- function(case_row, output_tag) {
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
    method = case_row$method[[1]],
    half_hour_bin = as.integer(hour) + as.integer(minute) / 60
  )]
  dt[is.finite(gapfilled_co2_flux)]
}

build_diurnal_stats <- function(run_plan, output_tag) {
  run_plan <- run_plan[common_method == TRUE]
  case_list <- lapply(seq_len(nrow(run_plan)), function(i) read_case_30min(run_plan[i], output_tag))
  dt <- rbindlist(case_list, use.names = TRUE, fill = TRUE)
  stats <- dt[, .(
    n_dates = .N,
    q25 = as.numeric(stats::quantile(gapfilled_co2_flux, probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_flux = stats::median(gapfilled_co2_flux, na.rm = TRUE),
    q75 = as.numeric(stats::quantile(gapfilled_co2_flux, probs = 0.75, na.rm = TRUE, names = FALSE)),
    mean_flux = mean(gapfilled_co2_flux, na.rm = TRUE)
  ), by = .(tower, method, hhmm, half_hour_bin)]
  stats[, `:=`(
    tower = factor(tower, levels = c("MT", "CVT")),
    method = factor(method, levels = method_levels, labels = method_labels[method_levels])
  )]
  setorder(stats, tower, method, half_hour_bin)
  stats
}

self_check <- function(stats_dt) {
  count_check <- stats_dt[, .N, by = .(tower, method)]
  stopifnot(all(count_check$N == 48L))
  stopifnot(all(stats_dt$q25 <= stats_dt$median_flux))
  stopifnot(all(stats_dt$median_flux <= stats_dt$q75))
}

plot_scenario <- function(cfg) {
  figure_dir <- file.path(cfg$root, "figures_diurnal")
  dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

  run_plan <- read_required(cfg$run_plan)
  stats_dt <- build_diurnal_stats(run_plan, cfg$output_tag)
  self_check(stats_dt)

  plot_file <- file.path(figure_dir, sprintf("%s.png", cfg$plot_stub))
  csv_file <- file.path(cfg$root, sprintf("%s_plot_data.csv", cfg$plot_stub))
  summary_file <- file.path(cfg$root, sprintf("%s_summary.txt", cfg$plot_stub))

  p <- ggplot(
    stats_dt,
    aes(x = half_hour_bin, y = median_flux, colour = method, fill = method, group = method)
  ) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
    geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.13, colour = NA) +
    geom_line(linewidth = 0.6) +
    facet_wrap(~ tower, ncol = 1) +
    scale_colour_manual(values = method_cols_labeled, drop = FALSE) +
    scale_fill_manual(values = method_cols_labeled, drop = FALSE) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(x) sprintf("%02d:00", as.integer(x))
    ) +
    scale_y_continuous(breaks = function(x) pretty(x, n = 8)) +
    labs(
      title = "Fixed-tower 2025 diurnal NEE proxy by rotation method",
      subtitle = cfg$subtitle,
      x = "Local half-hour bin",
      y = expression("Gapfilled 30 min CO"[2] * " flux / NEE proxy (" * mu * "mol m"^-2 * " s"^-1 * ")"),
      caption = "Each ribbon shows the 25th-75th percentile range across all 2025 dates in that half-hour bin. Only the common four methods are shown."
    ) +
    theme_regov(base_size = 13)

  ggsave(plot_file, p, width = 11.4, height = 9.2, dpi = 300)

  plot_out <- copy(stats_dt)
  plot_out[, `:=`(
    tower = as.character(tower),
    method = as.character(method)
  )]
  fwrite(plot_out, csv_file)

  writeLines(c(
    "Fixed-tower 2025 rotation-method diurnal summary",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    paste0("Scenario root: ", cfg$root),
    paste0("Run plan: ", cfg$run_plan),
    "",
    "Outputs:",
    paste0("- ", csv_file),
    paste0("- ", plot_file),
    "",
    "Notes:",
    "- Uses per-method 30 min gapfilled outputs, not raw full-flux tables.",
    "- Central line = median gapfilled_co2_flux by half-hour across all 2025 dates.",
    "- Ribbon = 25th to 75th percentile by half-hour across all 2025 dates.",
    "- Only the common four methods are shown: no_rotation, dr, global_pf, sector_pf."
  ), summary_file, useBytes = TRUE)

  message("Wrote diurnal outputs to: ", figure_dir)
}

invisible(lapply(scenario_configs, plot_scenario))
