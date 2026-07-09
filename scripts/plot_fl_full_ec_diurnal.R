#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

out_root <- "E:/Dataset_Level1/Flares/EC_ecpreproc"
figure_dir <- file.path(out_root, "figures_diurnal")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

source_levels <- c("oldcode_0_245", "batch_b_complete", "main_complete")
method_levels <- c("no_rotation", "dr", "PF_8bin_2ensemble")
method_labels <- c(
  no_rotation = "No rotation",
  dr = "Double rotation",
  PF_8bin_2ensemble = "PF_8bin_2ensemble"
)
method_cols <- c(
  no_rotation = "#4E79A7",
  dr = "#F28E2B",
  PF_8bin_2ensemble = "#59A14F"
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
      plot.caption = element_text(colour = "grey35", size = rel(0.8), hjust = 0)
    )
}

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(
    path,
    showProgress = FALSE,
    colClasses = list(character = c("timestamp", "date", "time", "block_start", "block_end", "sample_start", "sample_end"))
  )
}

build_input_plan <- function() {
  CJ(source_group = source_levels, rotation_method = method_levels, unique = TRUE)[
    ,
    `:=`(
      file = file.path(out_root, source_group, "results", sprintf("FL_flux_%s.csv", rotation_method)),
      method_label = method_labels[rotation_method]
    )
  ]
}

read_case <- function(row) {
  dt <- read_required(row$file[[1]])
  if (!"F_EC_cov_valid_umol_m2_s" %in% names(dt)) {
    stop("Missing F_EC_cov_valid_umol_m2_s in ", row$file[[1]], call. = FALSE)
  }
  dt[, `:=`(
    hhmm = substr(timestamp, 12, 16),
    hour = as.integer(substr(timestamp, 12, 13)),
    minute = as.integer(substr(timestamp, 15, 16)),
    source_group = row$source_group[[1]],
    rotation_method = row$rotation_method[[1]],
    method_label = row$method_label[[1]]
  )]
  dt[, half_hour_bin := hour + minute / 60]
  dt[is.finite(F_EC_cov_valid_umol_m2_s)]
}

build_diurnal_stats <- function(plan_dt) {
  dt <- rbindlist(lapply(seq_len(nrow(plan_dt)), function(i) read_case(plan_dt[i])), use.names = TRUE, fill = TRUE)
  stats <- dt[, .(
    n_windows = .N,
    n_dates = uniqueN(date),
    n_source_groups = uniqueN(source_group),
    q25 = as.numeric(stats::quantile(F_EC_cov_valid_umol_m2_s, probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_flux = stats::median(F_EC_cov_valid_umol_m2_s, na.rm = TRUE),
    q75 = as.numeric(stats::quantile(F_EC_cov_valid_umol_m2_s, probs = 0.75, na.rm = TRUE, names = FALSE)),
    mean_flux = mean(F_EC_cov_valid_umol_m2_s, na.rm = TRUE)
  ), by = .(rotation_method, method_label, hhmm, half_hour_bin)]
  stats[, method_label := factor(method_label, levels = unname(method_labels[method_levels]))]
  setorder(stats, rotation_method, half_hour_bin)
  stats
}

self_check <- function(stats_dt) {
  stopifnot(nrow(stats_dt) > 0L)
  stopifnot(all(stats_dt$half_hour_bin >= 0 & stats_dt$half_hour_bin <= 23.5))
  stopifnot(all(stats_dt$q25 <= stats_dt$median_flux))
  stopifnot(all(stats_dt$median_flux <= stats_dt$q75))
  stopifnot(all(stats_dt$n_dates >= 1L))
}

plan_dt <- build_input_plan()
stats_dt <- build_diurnal_stats(plan_dt)
self_check(stats_dt)

plot_csv <- file.path(out_root, "FL_full_ec_diurnal_plot_data.csv")
plot_png <- file.path(figure_dir, "FL_full_ec_diurnal.png")
summary_txt <- file.path(out_root, "FL_full_ec_diurnal_summary.txt")

p <- ggplot(
  stats_dt,
  aes(x = half_hour_bin, y = median_flux, colour = method_label, fill = method_label, group = method_label)
) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
  geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.13, colour = NA) +
  geom_line(linewidth = 0.6) +
  scale_colour_manual(values = unname(method_cols[method_levels]), drop = FALSE) +
  scale_fill_manual(values = unname(method_cols[method_levels]), drop = FALSE) +
  scale_x_continuous(
    breaks = seq(0, 24, by = 3),
    limits = c(0, 23.5),
    labels = function(x) sprintf("%02d:00", as.integer(x))
  ) +
  scale_y_continuous(breaks = function(x) pretty(x, n = 8)) +
  labs(
    title = "FL full-data EC diurnal flux by rotation method",
    subtitle = "All source_groups pooled: line = median 30 min CO2 flux by half-hour; ribbon = 25th-75th percentile across windows.",
    x = "Local half-hour bin",
    y = expression("30 min CO"[2] * " flux (" * mu * "mol m"^-2 * " s"^-1 * ")"),
    caption = "Inputs are the delivered FL full EC outputs under E:/Dataset_Level1/Flares/EC_ecpreproc. Timestamps are read as character and interpreted in Asia/Shanghai."
  ) +
  theme_regov(base_size = 13)

ggsave(plot_png, p, width = 12, height = 9, dpi = 300)

plot_out <- copy(stats_dt)
plot_out[, method_label := as.character(method_label)]
fwrite(plot_out, plot_csv)

summary_lines <- c(
  "FL full EC diurnal summary",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  paste0("Output root: ", out_root),
  "",
  "Outputs:",
  paste0("- ", plot_csv),
  paste0("- ", plot_png),
  "",
  "Notes:",
  "- Uses delivered FL full EC 30 min outputs only; does not recompute flux.",
  "- Central line = median F_EC_cov_valid_umol_m2_s by half-hour across dates.",
  "- Ribbon = 25th to 75th percentile by half-hour across pooled windows.",
  "- All source_groups are pooled into one full-data diurnal plot.",
  "- Methods shown: no_rotation, dr, PF_8bin_2ensemble."
)

method_summary <- plot_out[, .(
  n_half_hour_bins = uniqueN(hhmm),
  n_dates_min = min(n_dates),
  n_dates_max = max(n_dates),
  n_windows_min = min(n_windows),
  n_windows_max = max(n_windows),
  n_source_groups = max(n_source_groups)
), by = .(method_label)]

writeLines(
  c(
    summary_lines,
    "",
    "Coverage by method:",
    apply(method_summary, 1, function(x) {
      sprintf("- %s: bins=%s, n_dates range=%s-%s, n_windows range=%s-%s, pooled source_groups=%s", x[["method_label"]], x[["n_half_hour_bins"]], x[["n_dates_min"]], x[["n_dates_max"]], x[["n_windows_min"]], x[["n_windows_max"]], x[["n_source_groups"]])
    })
  ),
  summary_txt,
  useBytes = TRUE
)

message("Wrote FL full EC diurnal outputs to: ", figure_dir)
