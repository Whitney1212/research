#!/usr/bin/env Rscript

input_file <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv"
output_dir <- "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF"
figure_dir <- file.path(output_dir, "figures_flux_means")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

theme_regov <- function(base_size = 14) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      legend.position = "top",
      legend.title = element_blank(),
      strip.background = element_rect(fill = "grey92", colour = "grey70"),
      plot.title = element_text(face = "bold"),
      axis.text.x = element_text(colour = "grey20"),
      axis.text.y = element_text(colour = "grey20")
    )
}

read_flux <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  dt <- fread(path, colClasses = list(character = c("timestamp", "date", "time")))
  dt[, timestamp_local := as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%OS", tz = "Asia/Shanghai")]
  bad_time <- is.na(dt$timestamp_local)
  if (any(bad_time)) {
    dt[bad_time, timestamp_local := as.POSIXct(paste(date, time), format = "%Y-%m-%d %H:%M", tz = "Asia/Shanghai")]
  }
  if (anyNA(dt$timestamp_local)) stop("Could not parse some timestamps.", call. = FALSE)
  dt[, hour := as.integer(format(timestamp_local, "%H", tz = "Asia/Shanghai"))]
  dt[, year_month := format(timestamp_local, "%Y-%m", tz = "Asia/Shanghai")]
  dt[]
}

mean_se <- function(x) {
  x <- x[is.finite(x)]
  n <- length(x)
  m <- if (n > 0) mean(x) else NA_real_
  s <- if (n > 1) stats::sd(x) else NA_real_
  data.table(n = n, mean = m, sd = s, se = if (n > 1) s / sqrt(n) else NA_real_)
}

dt <- read_flux(input_file)

vars <- c("co2_flux", "h2o_flux", "H", "LE", "Tau", "u_star")
missing <- setdiff(vars, names(dt))
if (length(missing) > 0) stop("Missing expected columns: ", paste(missing, collapse = ", "), call. = FALSE)

var_labels <- c(
  co2_flux = "CO2 flux",
  h2o_flux = "H2O flux",
  H = "H",
  LE = "LE",
  Tau = "Tau",
  u_star = "u*"
)

long <- melt(
  dt,
  measure.vars = vars,
  variable.name = "variable",
  value.name = "value",
  variable.factor = FALSE
)
long <- long[is.finite(value)]
long[, variable_label := factor(var_labels[variable], levels = unname(var_labels))]

overall <- long[, mean_se(value), by = .(variable, variable_label)]
overall[, ci95 := 1.96 * se]
fwrite(overall, file.path(output_dir, "MT_sector_pf_flux_mean_overall.csv"))

hourly <- long[, mean_se(value), by = .(variable, variable_label, hour)]
hourly[, ci95 := 1.96 * se]
fwrite(hourly, file.path(output_dir, "MT_sector_pf_flux_mean_by_hour.csv"))

month_hour <- long[, mean_se(value), by = .(variable, variable_label, year_month, hour)]
fwrite(month_hour, file.path(output_dir, "MT_sector_pf_flux_mean_by_month_hour.csv"))

p_overall <- ggplot(overall, aes(x = variable_label, y = mean)) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
  geom_col(fill = "#619CFF", width = 0.68) +
  geom_errorbar(aes(ymin = mean - ci95, ymax = mean + ci95), width = 0.22, linewidth = 0.35, na.rm = TRUE) +
  facet_wrap(~variable_label, scales = "free_y", ncol = 3) +
  labs(
    title = "MT sector PF full-period mean fluxes",
    x = NULL,
    y = "Mean value",
    caption = "All available rows in MT_flux_sector_pf.csv; error bars are +/- 1.96 SE."
  ) +
  theme_regov() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
ggsave(file.path(figure_dir, "MT_sector_pf_flux_overall_means.png"), p_overall, width = 12, height = 8, dpi = 300)

p_hour <- ggplot(hourly, aes(x = hour, y = mean)) +
  geom_hline(yintercept = 0, colour = "grey60", linewidth = 0.3) +
  geom_ribbon(aes(ymin = mean - ci95, ymax = mean + ci95), fill = "#619CFF", alpha = 0.18, colour = NA) +
  geom_line(colour = "#619CFF", linewidth = 0.75) +
  geom_point(colour = "#619CFF", size = 1.4) +
  facet_wrap(~variable_label, scales = "free_y", ncol = 2) +
  scale_x_continuous(breaks = seq(0, 23, by = 3), limits = c(0, 23)) +
  labs(
    title = "MT sector PF mean diurnal flux pattern",
    x = "Hour of day (Asia/Shanghai)",
    y = "Mean value",
    caption = "All available rows; ribbon is +/- 1.96 SE by hour."
  ) +
  theme_regov()
ggsave(file.path(figure_dir, "MT_sector_pf_flux_mean_diurnal.png"), p_hour, width = 12, height = 10, dpi = 300)

heatmap_vars <- c("co2_flux", "H", "LE", "u_star")
for (v in heatmap_vars) {
  sub <- month_hour[variable == v]
  p <- ggplot(sub, aes(x = year_month, y = hour, fill = mean)) +
    geom_tile() +
    scale_y_continuous(breaks = seq(0, 23, by = 3), expand = c(0, 0)) +
    scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B", midpoint = 0, na.value = "grey90") +
    labs(
      title = paste0("MT sector PF mean ", var_labels[[v]], " by month and hour"),
      x = "Year-month",
      y = "Hour of day (Asia/Shanghai)",
      fill = "Mean",
      caption = "All available rows in each year-month x hour bin."
    ) +
    theme_regov(base_size = 12) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 7))
  ggsave(file.path(figure_dir, paste0("MT_sector_pf_flux_mean_month_hour_", v, ".png")),
         p, width = 15, height = 7.5, dpi = 300)
}

summary_txt <- file.path(output_dir, "MT_sector_pf_flux_mean_visualization_summary.txt")
writeLines(c(
  "MT sector_pf full-period flux mean visualization",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  paste0("Input: ", input_file),
  paste0("Rows: ", nrow(dt)),
  paste0("Timestamp range: ", min(dt$timestamp_local), " to ", max(dt$timestamp_local)),
  "",
  "CSV outputs:",
  "- MT_sector_pf_flux_mean_overall.csv",
  "- MT_sector_pf_flux_mean_by_hour.csv",
  "- MT_sector_pf_flux_mean_by_month_hour.csv",
  "",
  "Figure outputs:",
  "- figures_flux_means/MT_sector_pf_flux_overall_means.png",
  "- figures_flux_means/MT_sector_pf_flux_mean_diurnal.png",
  "- figures_flux_means/MT_sector_pf_flux_mean_month_hour_co2_flux.png",
  "- figures_flux_means/MT_sector_pf_flux_mean_month_hour_H.png",
  "- figures_flux_means/MT_sector_pf_flux_mean_month_hour_LE.png",
  "- figures_flux_means/MT_sector_pf_flux_mean_month_hour_u_star.png",
  "",
  "Notes:",
  "- Full data means no QC filtering was applied before aggregation.",
  "- Facets use free y scales where variables have different units."
), summary_txt, useBytes = TRUE)

message("Wrote MT sector_pf flux mean visualizations to: ", figure_dir)
