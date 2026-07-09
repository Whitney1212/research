#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

manifest_csv <- "E:/Dataset_Level1/FixedTower/EC/fixed_tower_full_flux_standardized_30min_manifest.csv"
fl_plot_data_csv <- "E:/Dataset_Level1/Flares/EC_ecpreproc/FL_full_ec_diurnal_plot_data.csv"
out_root <- "E:/Dataset_Level1/FixedTower/EC/rotation_comparison_with_FL"
figure_dir <- file.path(out_root, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

tower_cols <- c(
  CVT = "#F8766D",
  FL = "#00BA38",
  MT = "#619CFF"
)

method_title_map <- c(
  no_rotation = "no rotation",
  dr = "dr",
  pf = "pf"
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

read_required <- function(path, ...) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path, ...)
}

build_fixed_tower_plan <- function() {
  manifest <- read_required(manifest_csv)
  pick <- c(
    MT_no_rotation = "no_rotation",
    MT_dr = "dr",
    MT_sector_pf = "pf",
    CVT_no_rotation = "no_rotation",
    CVT_dr = "dr",
    CVT_sector_pf = "pf"
  )
  out <- manifest[product %in% names(pick), .(product, input_file, output_file)]
  if (nrow(out) != length(pick)) {
    stop("Fixed-tower manifest is missing required products.", call. = FALSE)
  }
  out[, `:=`(
    tower = sub("_.*$", "", product),
    method_key = unname(pick[product])
  )]
  out[]
}

build_half_hour_stats <- function(dt, value_col, n_name = "n_windows") {
  value <- dt[[value_col]]
  dt[, .(
    n_windows = .N,
    n_dates = if ("date" %in% names(dt)) uniqueN(date) else NA_integer_,
    q25 = as.numeric(stats::quantile(value, probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_flux = stats::median(value, na.rm = TRUE),
    q75 = as.numeric(stats::quantile(value, probs = 0.75, na.rm = TRUE, names = FALSE)),
    mean_flux = mean(value, na.rm = TRUE)
  ), by = .(tower, method_key, hhmm, half_hour_bin)][
    ,
    (n_name) := n_windows
  ][]
}

read_fixed_tower_case <- function(path, tower, method_key) {
  tower_name <- tower
  method_name <- method_key
  dt <- read_required(
    path,
    select = c("timestamp", "date", "time", "co2_flux"),
    colClasses = list(character = c("timestamp", "date", "time"))
  )
  if (!"co2_flux" %in% names(dt)) stop("Missing co2_flux in ", path, call. = FALSE)
  dt[, timestamp := substr(timestamp, 1, 16)]
  dt[, `:=`(
    hhmm = substr(timestamp, 12, 16),
    tower = rep(tower_name, .N),
    method_key = rep(method_name, .N)
  )]
  dt[, `:=`(
    hour = as.integer(substr(hhmm, 1, 2)),
    minute = as.integer(substr(hhmm, 4, 5))
  )]
  dt[, half_hour_bin := hour + minute / 60]
  dt[is.finite(co2_flux), .(tower, method_key, date, hhmm, half_hour_bin, co2_flux)]
}

build_fixed_tower_stats <- function(plan_dt) {
  cases <- lapply(seq_len(nrow(plan_dt)), function(i) {
    read_fixed_tower_case(
      path = plan_dt$output_file[[i]],
      tower = plan_dt$tower[[i]],
      method_key = plan_dt$method_key[[i]]
    )
  })
  dt <- rbindlist(cases, use.names = TRUE, fill = TRUE)
  dt[, .(
    n_windows = .N,
    n_dates = uniqueN(date),
    q25 = as.numeric(stats::quantile(co2_flux, probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_flux = stats::median(co2_flux, na.rm = TRUE),
    q75 = as.numeric(stats::quantile(co2_flux, probs = 0.75, na.rm = TRUE, names = FALSE)),
    mean_flux = mean(co2_flux, na.rm = TRUE)
  ), by = .(tower, method_key, hhmm, half_hour_bin)]
}

build_fl_stats <- function() {
  dt <- read_required(fl_plot_data_csv)
  if (!all(c("rotation_method", "hhmm", "half_hour_bin", "n_windows", "n_dates", "q25", "median_flux", "q75", "mean_flux") %in% names(dt))) {
    stop("FL plot data is missing required columns.", call. = FALSE)
  }
  dt <- dt[rotation_method %in% c("no_rotation", "dr", "PF_8bin_2ensemble")]
  dt[, `:=`(
    tower = "FL",
    method_key = fifelse(rotation_method == "PF_8bin_2ensemble", "pf", rotation_method)
  )]
  dt[, .(tower, method_key, hhmm, half_hour_bin, n_windows, n_dates, q25, median_flux, q75, mean_flux)]
}

self_check <- function(plot_dt) {
  counts <- plot_dt[, .N, by = .(tower, method_key)]
  stopifnot(nrow(counts) == 9L)
  stopifnot(all(counts$N == 48L))
  stopifnot(all(plot_dt$q25 <= plot_dt$median_flux))
  stopifnot(all(plot_dt$median_flux <= plot_dt$q75))
}

fixed_plan <- build_fixed_tower_plan()
fixed_stats <- build_fixed_tower_stats(fixed_plan)
fl_stats <- build_fl_stats()

plot_dt <- rbindlist(list(fixed_stats, fl_stats), use.names = TRUE, fill = TRUE)
plot_dt[, `:=`(
  tower = factor(tower, levels = c("MT", "CVT", "FL")),
  method_key = factor(method_key, levels = c("no_rotation", "dr", "pf")),
  method_panel = factor(method_title_map[as.character(method_key)], levels = unname(method_title_map))
)]
setorder(plot_dt, method_key, tower, half_hour_bin)
self_check(plot_dt)

plot_csv <- file.path(out_root, "three_tower_rotation_diurnal_plot_data.csv")
plot_png <- file.path(figure_dir, "three_tower_rotation_diurnal_facets.png")
summary_txt <- file.path(out_root, "three_tower_rotation_diurnal_summary.txt")

p <- ggplot(
  plot_dt,
  aes(x = half_hour_bin, y = median_flux, colour = tower, fill = tower, group = tower)
) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
  geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.12, colour = NA) +
  geom_line(linewidth = 0.75) +
  facet_wrap(~ method_panel, nrow = 1) +
  scale_colour_manual(values = tower_cols, drop = FALSE) +
  scale_fill_manual(values = tower_cols, drop = FALSE) +
  scale_x_continuous(
    breaks = seq(0, 24, by = 3),
    limits = c(0, 23.5),
    labels = function(x) sprintf("%02d:00", as.integer(x))
  ) +
  scale_y_continuous(breaks = function(x) pretty(x, n = 8)) +
  labs(
    title = "MT / CVT / FL diurnal flux by rotation method",
    subtitle = "Line = median; ribbon = 25th-75th percentile. PF panel uses sector_pf for MT/CVT and PF_8bin_2ensemble for FL.",
    x = "Local half-hour bin",
    y = expression("30 min CO"[2] * " flux (" * mu * "mol m"^-2 * " s"^-1 * ")"),
    caption = "Fixed towers use standardized 30 min full-flux outputs; FL uses delivered full-data EC diurnal summary. Colours: MT blue, CVT red, FL green."
  ) +
  theme_regov(base_size = 13)

ggsave(plot_png, p, width = 14.5, height = 5.8, dpi = 300)

plot_out <- copy(plot_dt)
plot_out[, `:=`(
  tower = as.character(tower),
  method_key = as.character(method_key),
  method_panel = as.character(method_panel)
)]
fwrite(plot_out, plot_csv)

coverage <- plot_out[, .(
  n_half_hour_bins = .N,
  n_dates_min = min(n_dates, na.rm = TRUE),
  n_dates_max = max(n_dates, na.rm = TRUE),
  n_windows_min = min(n_windows, na.rm = TRUE),
  n_windows_max = max(n_windows, na.rm = TRUE)
), by = .(tower, method_key)]

writeLines(
  c(
    "Three-tower rotation diurnal summary",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    "",
    "Inputs:",
    paste0("- Fixed-tower manifest: ", manifest_csv),
    paste0("- FL diurnal plot data: ", fl_plot_data_csv),
    "",
    "Outputs:",
    paste0("- ", plot_csv),
    paste0("- ", plot_png),
    "",
    "Notes:",
    "- MT/CVT no_rotation and dr come from standardized full-flux 30 min tables.",
    "- MT/CVT pf comes from standardized sector_pf full-flux 30 min tables.",
    "- FL pf comes from PF_8bin_2ensemble in the delivered FL full EC diurnal product.",
    "- The three facet labels are no rotation, dr, and pf as requested.",
    "",
    "Coverage by tower x method:",
    apply(coverage, 1, function(x) {
      sprintf(
        "- %s / %s: bins=%s, n_dates range=%s-%s, n_windows range=%s-%s",
        x[["tower"]], x[["method_key"]], x[["n_half_hour_bins"]],
        x[["n_dates_min"]], x[["n_dates_max"]],
        x[["n_windows_min"]], x[["n_windows_max"]]
      )
    })
  ),
  summary_txt,
  useBytes = TRUE
)

message("Wrote three-tower rotation diurnal outputs to: ", out_root)
