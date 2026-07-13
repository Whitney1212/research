#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

fixed_csv <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/mechanism_diagnostics/rotation_wmean_wc_diurnal_summary.csv"
fl_csv <- "E:/Dataset_Level1/Flares/EC_ecpreproc/FL_full_ec_wmean_diurnal_plot_data.csv"
out_root <- "E:/Dataset_Level1/FixedTower/EC/rotation_comparison_with_FL"
figure_dir <- file.path(out_root, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

tower_cols <- c(
  MT = "#619CFF",
  CVT = "#F8766D",
  FL = "#00BA38"
)

panel_levels <- c("No rotation", "PF")

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
  dt <- read_required(fixed_csv)[variable == "w_mean (m s^-1)"]
  need <- c("site", "method_label", "hour_decimal", "n_windows", "q25", "median_value", "q75")
  miss <- setdiff(need, names(dt))
  if (length(miss) > 0L) stop("Fixed-tower w_mean summary missing columns: ", paste(miss, collapse = ", "), call. = FALSE)
  dt <- dt[method_label %in% c("No rotation", "Sector PF")]
  dt[, panel := fifelse(method_label == "Sector PF", "PF", "No rotation")]
  dt[, .(
    tower = site,
    panel,
    hour_decimal,
    n_windows,
    q25,
    median_value,
    q75
  )]
}

read_fl <- function() {
  dt <- read_required(fl_csv)
  need <- c("rotation_method", "method_label", "half_hour_bin", "n_windows", "q25", "median_value", "q75")
  miss <- setdiff(need, names(dt))
  if (length(miss) > 0L) stop("FL w_mean plot data missing columns: ", paste(miss, collapse = ", "), call. = FALSE)
  dt <- dt[rotation_method %in% c("no_rotation", "PF_8bin_2ensemble")]
  dt[, panel := fifelse(rotation_method == "PF_8bin_2ensemble", "PF", "No rotation")]
  dt[, .(
    tower = "FL",
    panel,
    hour_decimal = half_hour_bin,
    n_windows,
    q25,
    median_value,
    q75
  )]
}

self_check <- function(dt) {
  counts <- dt[, .N, by = .(tower, panel)]
  stopifnot(nrow(counts) == 6L)
  stopifnot(all(counts$N == 48L))
  stopifnot(all(dt$q25 <= dt$median_value))
  stopifnot(all(dt$median_value <= dt$q75))
}

fixed_dt <- read_fixed_tower()
fl_dt <- read_fl()
plot_dt <- rbindlist(list(fixed_dt, fl_dt), use.names = TRUE)
plot_dt[, `:=`(
  tower = factor(tower, levels = c("MT", "CVT", "FL")),
  panel = factor(panel, levels = panel_levels)
)]
setorder(plot_dt, panel, tower, hour_decimal)
self_check(plot_dt)

plot_csv <- file.path(out_root, "three_site_wmean_no_rotation_pf_plot_data.csv")
plot_png <- file.path(figure_dir, "three_site_wmean_no_rotation_pf.png")
summary_txt <- file.path(out_root, "three_site_wmean_no_rotation_pf_summary.txt")

p <- ggplot(
  plot_dt,
  aes(x = hour_decimal, y = median_value, colour = tower, fill = tower, group = tower)
) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
  geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.11, colour = NA) +
  geom_line(linewidth = 0.6) +
  facet_wrap(~ panel, nrow = 1) +
  scale_colour_manual(values = tower_cols, drop = FALSE) +
  scale_fill_manual(values = tower_cols, drop = FALSE) +
  scale_x_continuous(
    breaks = seq(0, 24, by = 3),
    limits = c(0, 23.5),
    labels = function(x) sprintf("%02d:00", as.integer(x))
  ) +
  scale_y_continuous(breaks = function(x) pretty(x, n = 12)) +
  labs(
    title = "MT / CVT / FL mean vertical wind by rotation method",
    subtitle = "Two panels only: No rotation and PF. Line = median; ribbon = 25th-75th percentile.",
    x = "Local half-hour bin",
    y = expression("Mean vertical wind " * w[mean] * " (m s"^-1 * ")"),
    caption = "PF panel uses sector_pf for MT/CVT and PF_8bin_2ensemble (BPF) for FL. Colours: MT blue, CVT red, FL green."
  ) +
  theme_regov(base_size = 13)

ggsave(plot_png, p, width = 13.6, height = 6.2, dpi = 300)
fwrite(copy(plot_dt)[, `:=`(tower = as.character(tower), panel = as.character(panel))], plot_csv)

coverage <- plot_dt[, .(
  n_half_hour_bins = .N,
  n_windows_min = min(n_windows, na.rm = TRUE),
  n_windows_max = max(n_windows, na.rm = TRUE),
  median_wmean_min = min(median_value, na.rm = TRUE),
  median_wmean_max = max(median_value, na.rm = TRUE)
), by = .(tower, panel)]

writeLines(
  c(
    "Three-site w_mean no-rotation vs PF summary",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    "",
    "Inputs:",
    paste0("- Fixed-tower w_mean summary: ", fixed_csv),
    paste0("- FL w_mean plot data: ", fl_csv),
    "",
    "Outputs:",
    paste0("- ", plot_csv),
    paste0("- ", plot_png),
    "",
    "Notes:",
    "- No-rotation panel uses MT/CVT No rotation and FL no_rotation.",
    "- PF panel uses MT/CVT Sector PF and FL PF_8bin_2ensemble (BPF).",
    "- Single shared y-axis across panels for direct comparison.",
    "",
    "Coverage by tower x panel:",
    apply(coverage, 1, function(x) {
      sprintf(
        "- %s / %s: bins=%s, n_windows range=%s-%s, median w_mean range=%.4f-%.4f",
        x[["tower"]], x[["panel"]], x[["n_half_hour_bins"]],
        x[["n_windows_min"]], x[["n_windows_max"]],
        as.numeric(x[["median_wmean_min"]]), as.numeric(x[["median_wmean_max"]])
      )
    })
  ),
  summary_txt,
  useBytes = TRUE
)

message("Wrote: ", plot_png)
