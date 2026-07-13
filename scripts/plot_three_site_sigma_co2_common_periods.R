#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

fixed_csv <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/mechanism_diagnostics/rotation_sigma_co2_diurnal_plot_data.csv"
fl_csv <- "E:/Dataset_Level1/Flares/EC_ecpreproc/FL_sigma_co2_raw_common_periods_diurnal_plot_data.csv"
out_root <- "E:/Dataset_Level1/FixedTower/EC/rotation_comparison_with_FL"
figure_dir <- file.path(out_root, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

tower_cols <- c(
  CVT = "#F8766D",
  FL = "#00BA38",
  MT = "#619CFF"
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
  fread(path, showProgress = FALSE)
}

read_fixed_tower <- function() {
  dt <- read_required(fixed_csv)
  need <- c("site", "hour_decimal", "n_windows", "q25", "median_value", "q75")
  miss <- setdiff(need, names(dt))
  if (length(miss) > 0L) stop("Fixed-tower sigma_co2 plot data missing columns: ", paste(miss, collapse = ", "), call. = FALSE)
  dt[, .(
    tower = site,
    hour_decimal,
    n_windows,
    q25,
    median_value,
    q75
  )]
}

read_fl <- function() {
  dt <- read_required(fl_csv)
  need <- c("hour_decimal", "n_windows", "q25", "median_value", "q75")
  miss <- setdiff(need, names(dt))
  if (length(miss) > 0L) stop("FL sigma_co2 plot data missing columns: ", paste(miss, collapse = ", "), call. = FALSE)
  dt[, .(
    tower = "FL",
    hour_decimal,
    n_windows,
    q25,
    median_value,
    q75
  )]
}

self_check <- function(dt) {
  counts <- dt[, .N, by = tower]
  stopifnot(nrow(counts) == 3L)
  stopifnot(all(counts$N == 48L))
  stopifnot(all(dt$q25 <= dt$median_value))
  stopifnot(all(dt$median_value <= dt$q75))
}

fixed_dt <- read_fixed_tower()
fl_dt <- read_fl()
plot_dt <- rbindlist(list(fixed_dt, fl_dt), use.names = TRUE)
plot_dt[, tower := factor(tower, levels = c("MT", "CVT", "FL"))]
setorder(plot_dt, tower, hour_decimal)
self_check(plot_dt)

plot_csv <- file.path(out_root, "three_site_sigma_co2_common_periods_plot_data.csv")
plot_png <- file.path(figure_dir, "three_site_sigma_co2_common_periods.png")
summary_txt <- file.path(out_root, "three_site_sigma_co2_common_periods_summary.txt")

p <- ggplot(
  plot_dt,
  aes(x = hour_decimal, y = median_value, colour = tower, fill = tower, group = tower)
) +
  geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.12, colour = NA) +
  geom_line(linewidth = 0.6) +
  scale_colour_manual(values = tower_cols, drop = FALSE) +
  scale_fill_manual(values = tower_cols, drop = FALSE) +
  scale_x_continuous(
    breaks = seq(0, 24, by = 3),
    limits = c(0, 23.5),
    labels = function(x) sprintf("%02d:00", as.integer(x))
  ) +
  scale_y_continuous(breaks = function(x) pretty(x, n = 10)) +
  labs(
    title = "MT / CVT / FL sigma_co2 diurnal comparison",
    subtitle = "Line = median; ribbon = 25th-75th percentile. No faceting.",
    x = "Local half-hour bin",
    y = expression(sigma[CO[2]]~"(umol mol"^-1*")"),
    caption = "MT/CVT use fixed-tower common-period raw sigma_co2. FL uses raw CO2 sigma_co2 on three-method common half-hours after pass-window clipping."
  ) +
  theme_regov(base_size = 13)

ggsave(plot_png, p, width = 10.5, height = 6.4, dpi = 300)
fwrite(plot_dt, plot_csv)

coverage <- plot_dt[, .(
  n_half_hour_bins = .N,
  n_windows_min = min(n_windows, na.rm = TRUE),
  n_windows_max = max(n_windows, na.rm = TRUE),
  median_sigma_min = min(median_value, na.rm = TRUE),
  median_sigma_max = max(median_value, na.rm = TRUE)
), by = tower]

writeLines(
  c(
    "Three-site sigma_co2 common-period summary",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    "",
    "Inputs:",
    paste0("- Fixed-tower sigma plot data: ", fixed_csv),
    paste0("- FL raw sigma plot data: ", fl_csv),
    "",
    "Outputs:",
    paste0("- ", plot_csv),
    paste0("- ", plot_png),
    "",
    "Notes:",
    "- Single panel, colour only, no faceting.",
    "- MT/CVT are the fixed-tower common-period raw sigma_co2 summaries.",
    "- FL is the raw CO2 sigma_co2 summary over three-method common half-hours.",
    "",
    "Coverage by tower:",
    apply(coverage, 1, function(x) {
      sprintf(
        "- %s: bins=%s, n_windows range=%s-%s, median sigma range=%.4f-%.4f",
        x[["tower"]], x[["n_half_hour_bins"]], x[["n_windows_min"]], x[["n_windows_max"]],
        as.numeric(x[["median_sigma_min"]]), as.numeric(x[["median_sigma_max"]])
      )
    })
  ),
  summary_txt,
  useBytes = TRUE
)

message("Wrote: ", plot_png)
