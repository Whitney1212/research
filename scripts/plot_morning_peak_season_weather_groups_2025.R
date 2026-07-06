#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

defaults <- list(
  season_file = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/season_weather_groups/season_intensity_summary_2025_by_site.csv",
  weather_file = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/season_weather_groups/weather_group_intensity_summary_2025_by_site.csv",
  output_dir = "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/season_weather_groups/figures",
  year = 2025L
)

parse_args <- function(args) {
  opts <- defaults
  opts$self_test <- FALSE
  for (arg in args) {
    if (arg == "--self-test") {
      opts$self_test <- TRUE
    } else if (grepl("^--season-file=", arg)) {
      opts$season_file <- sub("^--season-file=", "", arg)
    } else if (grepl("^--weather-file=", arg)) {
      opts$weather_file <- sub("^--weather-file=", "", arg)
    } else if (grepl("^--output-dir=", arg)) {
      opts$output_dir <- sub("^--output-dir=", "", arg)
    } else if (grepl("^--year=", arg)) {
      opts$year <- as.integer(sub("^--year=", "", arg))
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/plot_morning_peak_season_weather_groups_2025.R [options]\n",
        "  --season-file=.../season_intensity_summary_2025_by_site.csv\n",
        "  --weather-file=.../weather_group_intensity_summary_2025_by_site.csv\n",
        "  --output-dir=.../season_weather_groups/figures\n",
        "  --year=2025\n",
        "  --self-test\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }
  opts
}

must_read <- function(path) {
  if (!file.exists(path)) stop("Missing required file: ", path, call. = FALSE)
  fread(path, encoding = "UTF-8")
}

pretty_group_type <- function(x) {
  map <- c(
    season = "Season",
    morning_ws_tercile = "Morning wind speed",
    peak_ws_tercile = "Peak-time wind speed",
    morning_temp_gradient_tercile = "Morning temperature gradient",
    peak_temp_gradient_tercile = "Peak-time temperature gradient"
  )
  unname(map[x])
}

report_theme <- function(base_size = 12) {
  theme_bw(base_size = base_size) +
    theme(
      legend.position = "top",
      legend.title = element_blank(),
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "grey92", color = "grey70"),
      plot.title = element_text(face = "bold")
    )
}

prep_composition_long <- function(dt) {
  long <- melt(
    dt,
    id.vars = intersect(
      c("group_type", "group_type_label", "site", "group", "event_days", "site_total_events", "share_of_site_events", "amp_median_ppm", "amp_p75_ppm"),
      names(dt)
    ),
    measure.vars = c("weak_days", "moderate_days", "strong_days"),
    variable.name = "intensity",
    value.name = "n_days",
    variable.factor = FALSE
  )
  long[, intensity := factor(sub("_days$", "", intensity), levels = c("weak", "moderate", "strong"))]
  long[, prop_in_group := fifelse(event_days > 0, n_days / event_days, NA_real_)]
  long
}

prep_group_order <- function(dt) {
  dt[, group := as.character(group)]
  dt[group_type == "season", group := factor(group, levels = c("winter", "spring", "summer", "autumn"))]
  dt[group_type != "season", group := factor(group, levels = c("low", "middle", "high"))]
  dt
}

run_self_test <- function() {
  stopifnot(identical(
    pretty_group_type(c("season", "peak_ws_tercile")),
    c("Season", "Peak-time wind speed")
  ))
  demo <- data.table(
    group_type = "season", site = "CVT", group = "winter",
    event_days = 10L, site_total_events = 10L, share_of_site_events = 1,
    weak_days = 2L, moderate_days = 3L, strong_days = 5L,
    amp_median_ppm = 4, amp_p75_ppm = 7
  )
  long <- prep_composition_long(demo)
  stopifnot(abs(sum(long$prop_in_group) - 1) < 1e-9)
  cat("self-test ok\n")
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  if (opts$self_test) {
    run_self_test()
    quit(save = "no", status = 0)
  }

  dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)

  season <- must_read(opts$season_file)
  weather <- must_read(opts$weather_file)

  num_cols <- c("event_days", "site_total_events", "share_of_site_events", "weak_days", "moderate_days", "strong_days", "amp_median_ppm", "amp_p75_ppm")
  for (col in intersect(num_cols, names(season))) season[, (col) := as.numeric(get(col))]
  for (col in intersect(num_cols, names(weather))) weather[, (col) := as.numeric(get(col))]

  season <- prep_group_order(season)
  weather <- prep_group_order(weather)
  weather[, group_type_label := pretty_group_type(group_type)]

  season_long <- prep_composition_long(season)
  weather_long <- prep_composition_long(weather)

  intensity_colors <- c(weak = "#8FB339", moderate = "#F2C14E", strong = "#D1495B")
  site_colors <- c(CVT = "#D55E00", MT = "#0072B2")

  p_season_comp <- ggplot(season_long, aes(x = group, y = prop_in_group, fill = intensity)) +
    geom_col(width = 0.72, color = "white", linewidth = 0.25) +
    facet_wrap(~site, ncol = 1) +
    scale_fill_manual(values = intensity_colors) +
    scale_y_continuous(labels = function(x) paste0(round(x * 100), "%"), limits = c(0, 1)) +
    labs(
      title = sprintf("Morning peak intensity composition by season, %s", opts$year),
      subtitle = "Intensity classes: weak 0-3 ppm, moderate 3-10 ppm, strong >=10 ppm",
      x = NULL,
      y = "Share within each season group"
    ) +
    report_theme()

  p_season_amp <- ggplot(season, aes(x = group, y = amp_median_ppm, color = site, group = site)) +
    geom_linerange(aes(ymin = amp_median_ppm, ymax = amp_p75_ppm), linewidth = 1.2, alpha = 0.8, position = position_dodge(width = 0.35)) +
    geom_point(size = 2.8, position = position_dodge(width = 0.35)) +
    facet_wrap(~site, ncol = 1) +
    scale_color_manual(values = site_colors) +
    labs(
      title = sprintf("Morning peak amplitude summary by season, %s", opts$year),
      subtitle = "Point = median amp; line top = 75th percentile",
      x = NULL,
      y = "Amplitude (ppm)"
    ) +
    report_theme()

  p_weather_comp <- ggplot(weather_long, aes(x = group, y = prop_in_group, fill = intensity)) +
    geom_col(width = 0.72, color = "white", linewidth = 0.25) +
    facet_grid(site ~ group_type_label) +
    scale_fill_manual(values = intensity_colors) +
    scale_y_continuous(labels = function(x) paste0(round(x * 100), "%"), limits = c(0, 1)) +
    labs(
      title = sprintf("Morning peak intensity composition by weather groups, %s", opts$year),
      subtitle = "Weather groups are site-specific terciles from current event-day MET context",
      x = NULL,
      y = "Share within each weather group"
    ) +
    report_theme(11) +
    theme(axis.text.x = element_text(angle = 0, hjust = 0.5))

  p_weather_amp <- ggplot(weather, aes(x = group, y = amp_median_ppm, color = site, group = site)) +
    geom_linerange(aes(ymin = amp_median_ppm, ymax = amp_p75_ppm), linewidth = 1.1, alpha = 0.8) +
    geom_point(size = 2.6) +
    facet_grid(site ~ group_type_label) +
    scale_color_manual(values = site_colors) +
    labs(
      title = sprintf("Morning peak amplitude summary by weather groups, %s", opts$year),
      subtitle = "Point = median amp; line top = 75th percentile",
      x = NULL,
      y = "Amplitude (ppm)"
    ) +
    report_theme(11)

  ggsave(file.path(opts$output_dir, sprintf("season_intensity_composition_%s.png", opts$year)), p_season_comp, width = 10, height = 8, dpi = 300)
  ggsave(file.path(opts$output_dir, sprintf("season_amplitude_summary_%s.png", opts$year)), p_season_amp, width = 10, height = 8, dpi = 300)
  ggsave(file.path(opts$output_dir, sprintf("weather_intensity_composition_%s.png", opts$year)), p_weather_comp, width = 14, height = 7, dpi = 300)
  ggsave(file.path(opts$output_dir, sprintf("weather_amplitude_summary_%s.png", opts$year)), p_weather_amp, width = 14, height = 7, dpi = 300)

  notes <- c(
    "Visualization of current morning peak season/weather grouped summaries.",
    sprintf("Season input: %s", opts$season_file),
    sprintf("Weather input: %s", opts$weather_file),
    sprintf("Output dir: %s", opts$output_dir),
    "Composition figures show weak/moderate/strong proportions within each grouped subset.",
    "Amplitude figures show median and 75th percentile amp_ppm for each grouped subset."
  )
  writeLines(notes, file.path(opts$output_dir, sprintf("season_weather_plot_notes_%s.txt", opts$year)))

  cat("Wrote figures to ", opts$output_dir, "\n", sep = "")
}

main()
