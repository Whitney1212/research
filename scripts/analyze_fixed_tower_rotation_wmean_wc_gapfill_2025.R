#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

out_root <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/mechanism_diagnostics"
figure_dir <- file.path(out_root, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

legacy_flux_file <- "D:/00 博士阶段/博一/05 Project/com_rotation/results/analysis/tables/13_w_sigma_flux_joined.csv"
legacy_state_file <- "D:/00 博士阶段/博一/05 Project/com_rotation/results/analysis/tables/19_state_reference_wind_stability_sunrise.csv"
legacy_range_file <- "D:/00 博士阶段/博一/05 Project/com_rotation/results/analysis/tables/20_method_range_by_timestamp_with_state.csv"
strict_run_plan_file <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/rotation_sensitivity_standardized_2025_run_plan.csv"

method_levels <- c("no_rotation", "dr", "global_pf", "sector_pf")
method_labels <- c(
  no_rotation = "No rotation",
  dr = "Double rotation",
  global_pf = "Global PF",
  sector_pf = "Sector PF"
)
method_cols <- c(
  "No rotation" = "#4E79A7",
  "Double rotation" = "#F28E2B",
  "Global PF" = "#59A14F",
  "Sector PF" = "#E15759"
)
legacy_method_map <- c(
  none = "no_rotation",
  dr = "dr",
  pf = "global_pf",
  spf = "sector_pf"
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

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path)
}

parse_timestamp_local <- function(timestamp_chr, date_chr = NULL, time_chr = NULL, tz_local = "Asia/Shanghai") {
  timestamp_chr <- trimws(as.character(timestamp_chr))
  timestamp_chr[timestamp_chr == ""] <- NA_character_
  parsed <- as.POSIXct(timestamp_chr, format = "%Y-%m-%d %H:%M:%OS", tz = tz_local)
  if (!is.null(date_chr) && !is.null(time_chr)) {
    fallback_chr <- ifelse(
      is.na(date_chr) | is.na(time_chr),
      NA_character_,
      paste(trimws(as.character(date_chr)), trimws(as.character(time_chr)))
    )
    bad <- is.na(parsed) & !is.na(fallback_chr)
    if (any(bad)) parsed[bad] <- as.POSIXct(fallback_chr[bad], format = "%Y-%m-%d %H:%M", tz = tz_local)
  }
  parsed
}

timestamp_key <- function(x, tz_local = "Asia/Shanghai") {
  format(x, "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

sector_30 <- function(deg) {
  deg_num <- suppressWarnings(as.numeric(deg)) %% 360
  idx <- floor(deg_num / 30)
  idx[!is.finite(idx)] <- NA_real_
  start <- idx * 30
  end <- ((idx + 1) * 30) %% 360
  out <- ifelse(
    is.na(start),
    NA_character_,
    sprintf("%03d-%03d", as.integer(start), as.integer(ifelse(end == 0, 360, end)))
  )
  factor(out, levels = sprintf("%03d-%03d", seq(0, 330, by = 30), c(seq(30, 330, by = 30), 360)))
}

prepare_legacy_flux <- function() {
  flux <- read_required(legacy_flux_file)
  state <- read_required(legacy_state_file)
  range_dt <- read_required(legacy_range_file)

  flux <- flux[rotation_requested_driver %in% names(legacy_method_map)]
  flux[, method := legacy_method_map[rotation_requested_driver]]
  flux[, timestamp := as.POSIXct(timestamp, tz = "Asia/Shanghai")]
  state[, timestamp := as.POSIXct(timestamp, tz = "Asia/Shanghai")]

  keep_state <- state[, .(site, period, timestamp, wind_from_deg, wind_sector_30, hour_decimal)]
  joined <- merge(flux, keep_state, by = c("site", "period", "timestamp"), all.x = TRUE, sort = FALSE)
  joined <- joined[site %in% c("MT", "CVT") & method %in% method_levels]
  joined[, method_label := factor(method_labels[method], levels = method_labels[method_levels])]

  range_dt <- range_dt[variable %in% c("w_mean", "co2_flux")]
  range_dt[, variable_label := fifelse(variable == "w_mean", "w_mean", "w'c' (co2_flux)")]
  list(flux = joined, range = range_dt)
}

build_legacy_summary <- function(flux_dt, value_col, value_label) {
  value_expr <- as.name(value_col)
  dt <- flux_dt[is.finite(get(value_col)) & is.finite(hour_decimal)]
  out <- dt[, .(
    n_windows = .N,
    q25 = as.numeric(stats::quantile(get(value_col), probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_value = stats::median(get(value_col), na.rm = TRUE),
    q75 = as.numeric(stats::quantile(get(value_col), probs = 0.75, na.rm = TRUE, names = FALSE))
  ), by = .(site, method, method_label, hour_decimal)]
  out[, variable := value_label]
  setorder(out, site, method, hour_decimal)
  out
}

build_legacy_sector_summary <- function(flux_dt, value_col, value_label) {
  dt <- flux_dt[is.finite(get(value_col)) & !is.na(wind_sector_30)]
  out <- dt[, .(
    n_windows = .N,
    q25 = as.numeric(stats::quantile(get(value_col), probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_value = stats::median(get(value_col), na.rm = TRUE),
    q75 = as.numeric(stats::quantile(get(value_col), probs = 0.75, na.rm = TRUE, names = FALSE))
  ), by = .(site, method, method_label, wind_sector_30)]
  out[, variable := value_label]
  setorder(out, site, method, wind_sector_30)
  out
}

plot_legacy_diurnal <- function(summary_dt, value_label, file_stub, subtitle) {
  x <- summary_dt[variable == value_label]
  p <- ggplot(x, aes(x = hour_decimal, y = median_value, colour = method_label, fill = method_label, group = method_label)) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
    geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.13, colour = NA) +
    geom_line(linewidth = 0.55) +
    facet_wrap(~ site, ncol = 1, scales = "free_y") +
    scale_colour_manual(values = method_cols, drop = FALSE) +
    scale_fill_manual(values = method_cols, drop = FALSE) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(x) sprintf("%02d:00", as.integer(x))
    ) +
    scale_y_continuous(breaks = function(x) pretty(x, n = 10)) +
    labs(
      title = sprintf("Fixed-tower 2025 %s diurnal comparison across rotation methods", value_label),
      subtitle = subtitle,
      x = "Local half-hour bin",
      y = value_label,
      caption = "Source is the existing four-method rotation-diagnostics table, not the full-year standardized rerun table."
    ) +
    theme_regov(base_size = 13)
  ggsave(file.path(figure_dir, sprintf("%s.png", file_stub)), p, width = 11.2, height = 8.8, dpi = 300)
}

plot_legacy_sector <- function(summary_dt, value_label, file_stub, subtitle) {
  x <- summary_dt[variable == value_label]
  p <- ggplot(x, aes(x = wind_sector_30, y = median_value, colour = method_label, group = method_label)) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
    geom_line(linewidth = 0.65) +
    geom_point(size = 1.6) +
    facet_wrap(~ site, ncol = 1, scales = "free_y") +
    scale_colour_manual(values = method_cols, drop = FALSE) +
    scale_y_continuous(breaks = function(x) pretty(x, n = 8)) +
    labs(
      title = sprintf("Fixed-tower 2025 %s wind-sector comparison across rotation methods", value_label),
      subtitle = subtitle,
      x = "30-degree wind-from sector (double-rotation reference)",
      y = value_label,
      caption = "Points/lines show sector-wise medians from the existing four-method rotation-diagnostics table."
    ) +
    theme_regov(base_size = 13)
  ggsave(file.path(figure_dir, sprintf("%s.png", file_stub)), p, width = 11.6, height = 8.8, dpi = 300)
}

prepare_gapfill_joined <- function() {
  run_plan <- read_required(strict_run_plan_file)[common_method == TRUE]
  out_list <- vector("list", nrow(run_plan))

  for (i in seq_len(nrow(run_plan))) {
    row <- run_plan[i]
    gap_path <- file.path(row$method_output_dir[[1]], sprintf("%s_nee_2025_estimate_30min_gapfilled.csv", row$tower[[1]]))
    gap_dt <- read_required(gap_path)[, .(ts_key, fill_method, gap_scope, gap_reason_final, valid_final, filled_by_gapfill, day_night)]
    gap_dt[, ts_key := timestamp_key(as.POSIXct(ts_key, tz = "Asia/Shanghai"), tz_local = "Asia/Shanghai")]

    src <- fread(
      row$input_file[[1]],
      encoding = "UTF-8",
      colClasses = list(character = c("timestamp", "date", "time"))
    )
    src[, timestamp_local := parse_timestamp_local(timestamp, date, time, tz_local = "Asia/Shanghai")]
    src <- src[!is.na(timestamp_local)]
    src[, ts_key := timestamp_key(timestamp_local, tz_local = "Asia/Shanghai")]
    src <- src[, .(
      ts_key,
      geo_wind_from_deg = suppressWarnings(as.numeric(geo_wind_from_deg)),
      sonic_flow_from_deg = suppressWarnings(as.numeric(sonic_flow_from_deg))
    )]
    src <- unique(src, by = "ts_key")
    src[, wind_from_deg := fifelse(is.finite(geo_wind_from_deg), geo_wind_from_deg, sonic_flow_from_deg)]
    src[, wind_sector_30 := sector_30(wind_from_deg)]

    x <- merge(gap_dt, src[, .(ts_key, wind_from_deg, wind_sector_30)], by = "ts_key", all.x = TRUE, sort = FALSE)
    x[, `:=`(
      tower = row$tower[[1]],
      method = row$method[[1]],
      method_label = factor(method_labels[row$method[[1]]], levels = method_labels[method_levels]),
      hour_decimal = as.integer(substr(ts_key, 12, 13)) + as.integer(substr(ts_key, 15, 16)) / 60
    )]
    out_list[[i]] <- x
  }

  rbindlist(out_list, use.names = TRUE, fill = TRUE)
}

build_gapfill_hour_summary <- function(dt) {
  dt[, .(
    total_windows = .N,
    gapfilled_windows = sum(filled_by_gapfill),
    gapfill_fraction = mean(filled_by_gapfill)
  ), by = .(tower, method, method_label, hour_decimal)]
}

build_gapfill_sector_summary <- function(dt) {
  dt[!is.na(wind_sector_30), .(
    total_windows = .N,
    gapfilled_windows = sum(filled_by_gapfill),
    gapfill_fraction = mean(filled_by_gapfill)
  ), by = .(tower, method, method_label, wind_sector_30)]
}

build_gapfill_heatmap <- function(dt) {
  dt[!is.na(wind_sector_30), .(
    total_windows = .N,
    gapfilled_windows = sum(filled_by_gapfill),
    gapfill_fraction = mean(filled_by_gapfill)
  ), by = .(tower, method, method_label, hour_decimal, wind_sector_30)]
}

plot_gapfill_hour <- function(summary_dt) {
  p <- ggplot(summary_dt, aes(x = hour_decimal, y = gapfill_fraction, colour = method_label, group = method_label)) +
    geom_line(linewidth = 0.65) +
    facet_wrap(~ tower, ncol = 1) +
    scale_colour_manual(values = method_cols, drop = FALSE) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(x) sprintf("%02d:00", as.integer(x))
    ) +
    scale_y_continuous(
      breaks = seq(0, 1, by = 0.1),
      labels = function(x) sprintf("%.0f%%", x * 100)
    ) +
    labs(
      title = "Fixed-tower 2025 strict-gapfill fraction by half-hour and rotation method",
      subtitle = "Common four methods only; fraction = gapfilled windows / all 2025 windows in that half-hour bin.",
      x = "Local half-hour bin",
      y = "Gapfill fraction",
      caption = "Gapfill is defined by the strict downstream run: qc_co2 <= 1 + flag9_co2 <= 3 + night u*."
    ) +
    theme_regov(base_size = 13)
  ggsave(file.path(figure_dir, "rotation_gapfill_fraction_by_hour_strict.png"), p, width = 11.2, height = 8.8, dpi = 300)
}

plot_gapfill_sector <- function(summary_dt) {
  p <- ggplot(summary_dt, aes(x = wind_sector_30, y = gapfill_fraction, colour = method_label, group = method_label)) +
    geom_line(linewidth = 0.65) +
    geom_point(size = 1.6) +
    facet_wrap(~ tower, ncol = 1) +
    scale_colour_manual(values = method_cols, drop = FALSE) +
    scale_y_continuous(
      breaks = seq(0, 1, by = 0.1),
      labels = function(x) sprintf("%.0f%%", x * 100)
    ) +
    labs(
      title = "Fixed-tower 2025 strict-gapfill fraction by wind sector and rotation method",
      subtitle = "Common four methods only; wind sector uses the standardized input table's geographic wind-from angle when available.",
      x = "30-degree wind-from sector",
      y = "Gapfill fraction",
      caption = "Rows without finite wind direction are excluded from this sector summary."
    ) +
    theme_regov(base_size = 13)
  ggsave(file.path(figure_dir, "rotation_gapfill_fraction_by_wind_sector_strict.png"), p, width = 11.6, height = 8.8, dpi = 300)
}

plot_gapfill_heatmap <- function(summary_dt) {
  p <- ggplot(summary_dt, aes(x = hour_decimal, y = wind_sector_30, fill = gapfill_fraction)) +
    geom_tile() +
    facet_grid(tower ~ method_label) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(x) sprintf("%02d:00", as.integer(x))
    ) +
    scale_fill_gradient(
      low = "white",
      high = "#D55E00",
      breaks = seq(0, 1, by = 0.2),
      labels = function(x) sprintf("%.0f%%", x * 100)
    ) +
    labs(
      title = "Fixed-tower 2025 strict-gapfill fraction by half-hour and wind sector",
      subtitle = "Common four methods only; darker cells mean that the tower-method combination more often required gapfilling in that time-sector cell.",
      x = "Local half-hour bin",
      y = "30-degree wind-from sector",
      fill = "Gapfill",
      caption = "Rows without finite wind direction are excluded from the heatmap denominator."
    ) +
    theme_regov(base_size = 12)
  ggsave(file.path(figure_dir, "rotation_gapfill_fraction_time_wind_sector_strict.png"), p, width = 14.8, height = 8.8, dpi = 300)
}

main <- function() {
  legacy <- prepare_legacy_flux()
  flux_dt <- legacy$flux
  range_dt <- legacy$range

  stopifnot(setequal(unique(flux_dt$method), method_levels))

  wmean_diurnal <- build_legacy_summary(flux_dt, "w_mean", "w_mean (m s^-1)")
  wprime_diurnal <- build_legacy_summary(flux_dt, "sigma_w", "w' / sigma_w (m s^-1)")
  wc_diurnal <- build_legacy_summary(flux_dt, "co2_flux", "w'c' / co2_flux (umol m^-2 s^-1)")
  diurnal_all <- rbindlist(list(wmean_diurnal, wprime_diurnal, wc_diurnal), use.names = TRUE)

  wmean_sector <- build_legacy_sector_summary(flux_dt, "w_mean", "w_mean (m s^-1)")
  wc_sector <- build_legacy_sector_summary(flux_dt, "co2_flux", "w'c' / co2_flux (umol m^-2 s^-1)")
  sector_all <- rbindlist(list(wmean_sector, wc_sector), use.names = TRUE)

  range_summary <- range_dt[, .(
    n_windows = .N,
    median_method_rel_range = stats::median(method_rel_range, na.rm = TRUE),
    p75_method_rel_range = as.numeric(stats::quantile(method_rel_range, probs = 0.75, na.rm = TRUE, names = FALSE)),
    median_method_range = stats::median(method_range, na.rm = TRUE)
  ), by = .(site, variable_label, wind_sector_30)][order(site, variable_label, wind_sector_30)]

  fwrite(diurnal_all, file.path(out_root, "rotation_wmean_wc_diurnal_summary.csv"))
  fwrite(sector_all, file.path(out_root, "rotation_wmean_wc_wind_sector_summary.csv"))
  fwrite(range_summary, file.path(out_root, "rotation_wmean_wc_method_range_by_sector.csv"))

  plot_legacy_diurnal(
    diurnal_all,
    "w_mean (m s^-1)",
    "rotation_wmean_diurnal_comparison_2025",
    "Source = existing four-method rotation diagnostics (2025 windows already analyzed in com_rotation)."
  )
  plot_legacy_diurnal(
    diurnal_all,
    "w' / sigma_w (m s^-1)",
    "rotation_wprime_diurnal_comparison_2025",
    "Source = existing four-method rotation diagnostics (2025 windows already analyzed in com_rotation)."
  )
  plot_legacy_diurnal(
    diurnal_all,
    "w'c' / co2_flux (umol m^-2 s^-1)",
    "rotation_wc_diurnal_comparison_2025",
    "Source = existing four-method rotation diagnostics (2025 windows already analyzed in com_rotation)."
  )
  plot_legacy_sector(
    sector_all,
    "w_mean (m s^-1)",
    "rotation_wmean_wind_sector_comparison_2025",
    "Sector medians use the double-rotation reference wind direction from the existing rotation diagnostics."
  )
  plot_legacy_sector(
    sector_all,
    "w'c' / co2_flux (umol m^-2 s^-1)",
    "rotation_wc_wind_sector_comparison_2025",
    "Sector medians use the double-rotation reference wind direction from the existing rotation diagnostics."
  )

  gapfill_dt <- prepare_gapfill_joined()
  stopifnot(setequal(unique(gapfill_dt$method), method_levels))

  gapfill_hour <- build_gapfill_hour_summary(gapfill_dt)
  gapfill_sector <- build_gapfill_sector_summary(gapfill_dt)
  gapfill_heat <- build_gapfill_heatmap(gapfill_dt)
  gapfill_missing_wind <- gapfill_dt[, .(
    total_windows = .N,
    gapfilled_windows = sum(filled_by_gapfill),
    windows_without_wind = sum(!is.finite(wind_from_deg)),
    gapfilled_without_wind = sum(filled_by_gapfill & !is.finite(wind_from_deg))
  ), by = .(tower, method)]

  fwrite(gapfill_hour, file.path(out_root, "rotation_gapfill_fraction_by_hour_strict.csv"))
  fwrite(gapfill_sector, file.path(out_root, "rotation_gapfill_fraction_by_wind_sector_strict.csv"))
  fwrite(gapfill_heat, file.path(out_root, "rotation_gapfill_fraction_time_wind_sector_strict.csv"))
  fwrite(gapfill_missing_wind, file.path(out_root, "rotation_gapfill_missing_wind_summary_strict.csv"))

  plot_gapfill_hour(gapfill_hour)
  plot_gapfill_sector(gapfill_sector)
  plot_gapfill_heatmap(gapfill_heat)

  writeLines(c(
    "Fixed-tower 2025 rotation mechanism diagnostics",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    "",
    "w_mean / w'c' inputs:",
    paste0("- ", legacy_flux_file),
    paste0("- ", legacy_state_file),
    paste0("- ", legacy_range_file),
    "",
    "Gapfill inputs:",
    paste0("- ", strict_run_plan_file),
    "- per-method strict 30min gapfilled outputs under rotation_sensitivity_standardized_2025/*",
    "",
    "Outputs:",
    "- rotation_wmean_wc_diurnal_summary.csv",
    "- rotation_wmean_wc_wind_sector_summary.csv",
    "- rotation_wmean_wc_method_range_by_sector.csv",
    "- rotation_gapfill_fraction_by_hour_strict.csv",
    "- rotation_gapfill_fraction_by_wind_sector_strict.csv",
    "- rotation_gapfill_fraction_time_wind_sector_strict.csv",
    "- rotation_gapfill_missing_wind_summary_strict.csv",
    "- figures/rotation_wmean_diurnal_comparison_2025.png",
    "- figures/rotation_wprime_diurnal_comparison_2025.png",
    "- figures/rotation_wc_diurnal_comparison_2025.png",
    "- figures/rotation_wmean_wind_sector_comparison_2025.png",
    "- figures/rotation_wc_wind_sector_comparison_2025.png",
    "- figures/rotation_gapfill_fraction_by_hour_strict.png",
    "- figures/rotation_gapfill_fraction_by_wind_sector_strict.png",
    "- figures/rotation_gapfill_fraction_time_wind_sector_strict.png",
    "",
    "Notes:",
    "- w_mean / w'c' comparisons reuse the existing four-method rotation-diagnostics table because the standardized rerun inputs do not themselves carry w_mean.",
    "- sigma_w is used here as the observable scale proxy for w' in 30 min statistics.",
    "- c' cannot be plotted yet because neither the standardized rerun inputs nor the existing rotation diagnostics currently carry a reusable sigma_co2 / scalar-variance field.",
    "- gapfill timing/sector comparisons are based on the strict 2025 rerun only."
  ), file.path(out_root, "rotation_mechanism_diagnostics_summary.txt"), useBytes = TRUE)

  message("Wrote mechanism diagnostics to: ", out_root)
}

if (sys.nframe() == 0L) {
  main()
}
