#!/usr/bin/env Rscript

out_root <- "E:/Dataset_Level1/FixedTower/EC/no rotation_ecpreproc"
figure_dir <- file.path(out_root, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

inputs <- data.frame(
  site = c("MT", "CVT"),
  path = c(
    "E:/Dataset_Level1/MT/EC/no rotation_ecpreproc/results/MT_flux_no_rotation.csv",
    "E:/Dataset_Level1/CVT/EC/no rotation_ecpreproc/results/CVT_flux_no_rotation.csv"
  ),
  stringsAsFactors = FALSE
)

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

theme_regov <- function(base_size = 14) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.major = element_line(colour = "grey88", linewidth = 0.25),
      panel.grid.minor = element_blank(),
      legend.position = "top",
      legend.title = element_blank(),
      legend.key = element_blank(),
      plot.title = element_text(face = "bold"),
      axis.text.x = element_text(colour = "grey20"),
      axis.text.y = element_text(colour = "grey20"),
      plot.caption = element_text(colour = "grey35", size = rel(0.78), hjust = 0)
    )
}

read_site <- function(site, path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  dt <- fread(path, colClasses = list(character = c("timestamp", "date", "time")))
  if (!"co2_flux" %in% names(dt)) stop("Missing co2_flux column: ", path, call. = FALSE)
  dt[, timestamp_local := as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%OS", tz = "Asia/Shanghai")]
  bad <- is.na(dt$timestamp_local)
  if (any(bad)) {
    dt[bad, timestamp_local := as.POSIXct(paste(date, time), format = "%Y-%m-%d %H:%M", tz = "Asia/Shanghai")]
  }
  if (anyNA(dt$timestamp_local)) stop("Could not parse timestamps for ", site, call. = FALSE)
  dt[, site := site]
  dt[, .(site, timestamp_local, co2_flux)]
}

mean_se <- function(x) {
  x <- x[is.finite(x)]
  n <- length(x)
  m <- if (n) mean(x) else NA_real_
  s <- if (n > 1) sd(x) else NA_real_
  data.table(n = n, mean = m, sd = s, se = if (n > 1) s / sqrt(n) else NA_real_)
}

dt <- rbindlist(Map(read_site, inputs$site, inputs$path), use.names = TRUE, fill = TRUE)
raw_summary <- dt[, .(
  raw_rows = .N,
  unique_timestamps = uniqueN(timestamp_local),
  duplicate_timestamp_rows = .N - uniqueN(timestamp_local),
  first_timestamp = min(timestamp_local),
  last_timestamp = max(timestamp_local)
), by = site]

by_timestamp <- dt[is.finite(co2_flux), .(co2_flux = mean(co2_flux)), by = .(site, timestamp_local)]
by_timestamp[, hour := as.integer(format(timestamp_local, "%H", tz = "Asia/Shanghai"))]

hourly <- by_timestamp[, mean_se(co2_flux), by = .(site, hour)]
hourly[, ci95 := 1.96 * se]
setorder(hourly, site, hour)
fwrite(hourly, file.path(out_root, "fixed_tower_no_rotation_co2flux_mean_by_hour.csv"))
fwrite(raw_summary, file.path(out_root, "fixed_tower_no_rotation_co2flux_input_summary.csv"))

p <- ggplot(hourly, aes(x = hour, y = mean, colour = site, fill = site)) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_ribbon(aes(ymin = mean - ci95, ymax = mean + ci95), alpha = 0.16, colour = NA) +
  geom_line(linewidth = 1.0) +
  geom_point(size = 1.8) +
  scale_x_continuous(breaks = seq(0, 23, by = 3), limits = c(0, 23)) +
  scale_colour_manual(values = c(CVT = "#F8766D", MT = "#619CFF")) +
  scale_fill_manual(values = c(CVT = "#F8766D", MT = "#619CFF")) +
  labs(
    title = expression("No-rotation CO"[2] * " flux mean diurnal pattern"),
    x = "Hour of day (Asia/Shanghai)",
    y = expression("Mean CO"[2] * " flux (" * mu * "mol m"^-2 * " s"^-1 * ")"),
    caption = "Duplicate timestamps are averaged within site before hourly means; ribbon is +/- 1.96 SE."
  ) +
  theme_regov(base_size = 15)

ggsave(
  file.path(figure_dir, "fixed_tower_no_rotation_co2flux_mean_diurnal.png"),
  p,
  width = 10,
  height = 6.2,
  dpi = 300
)

writeLines(c(
  "Fixed tower no-rotation CO2 flux diurnal mean",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  "",
  "Inputs:",
  paste0("- MT: ", inputs$path[inputs$site == "MT"]),
  paste0("- CVT: ", inputs$path[inputs$site == "CVT"]),
  "",
  "Outputs:",
  "- fixed_tower_no_rotation_co2flux_mean_by_hour.csv",
  "- fixed_tower_no_rotation_co2flux_input_summary.csv",
  "- figures/fixed_tower_no_rotation_co2flux_mean_diurnal.png",
  "",
  "Notes:",
  "- Timestamp columns are read as character before explicit Asia/Shanghai parsing.",
  "- Duplicate timestamps are first averaged within each site to avoid double counting."
), file.path(out_root, "fixed_tower_no_rotation_co2flux_diurnal_summary.txt"), useBytes = TRUE)

message("Wrote no-rotation CO2 flux diurnal outputs to: ", out_root)
