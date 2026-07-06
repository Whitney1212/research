#!/usr/bin/env Rscript

out_root <- "E:/Dataset_Level1/FixedTower/EC/no rotation_ecpreproc"
figure_dir <- file.path(out_root, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

inputs <- data.frame(
  site = c("MT", "MT", "CVT", "CVT"),
  method = c("No rotation", "Sector PF (SPF)", "No rotation", "Sector PF (SPF)"),
  path = c(
    "E:/Dataset_Level1/MT/EC/no rotation_ecpreproc/results/MT_flux_no_rotation.csv",
    "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv",
    "E:/Dataset_Level1/CVT/EC/no rotation_ecpreproc/results/CVT_flux_no_rotation.csv",
    "E:/Dataset_Level1/CVT/EC/PF/CVT_flux_sector_pf.csv"
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

parse_ts <- function(dt) {
  out <- as.POSIXct(dt$timestamp, format = "%Y-%m-%d %H:%M:%OS", tz = "Asia/Shanghai")
  bad <- is.na(out)
  if (any(bad)) {
    out[bad] <- as.POSIXct(dt$timestamp[bad], format = "%Y-%m-%d %H:%M", tz = "Asia/Shanghai")
  }
  bad <- is.na(out)
  if (any(bad) && all(c("date", "time") %in% names(dt))) {
    out[bad] <- as.POSIXct(paste(dt$date[bad], dt$time[bad]), format = "%Y-%m-%d %H:%M:%OS", tz = "Asia/Shanghai")
  }
  bad <- is.na(out)
  if (any(bad) && all(c("date", "time") %in% names(dt))) {
    out[bad] <- as.POSIXct(paste(dt$date[bad], dt$time[bad]), format = "%Y-%m-%d %H:%M", tz = "Asia/Shanghai")
  }
  out
}

read_input <- function(site, method, path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  dt <- fread(path, colClasses = list(character = c("timestamp", "date", "time")))
  if (!"co2_flux" %in% names(dt)) stop("Missing co2_flux column: ", path, call. = FALSE)
  dt[, timestamp_local := parse_ts(.SD)]
  if (anyNA(dt$timestamp_local)) stop("Could not parse timestamps: ", path, call. = FALSE)
  dt[, `:=`(site = site, method = method)]
  dt[, .(site, method, timestamp_local, co2_flux)]
}

mean_se <- function(x) {
  x <- x[is.finite(x)]
  n <- length(x)
  m <- if (n) mean(x) else NA_real_
  s <- if (n > 1) sd(x) else NA_real_
  data.table(n = n, mean = m, sd = s, se = if (n > 1) s / sqrt(n) else NA_real_)
}

dt <- rbindlist(
  Map(read_input, inputs$site, inputs$method, inputs$path),
  use.names = TRUE,
  fill = TRUE
)

input_summary <- dt[, .(
  raw_rows = .N,
  unique_timestamps = uniqueN(timestamp_local),
  duplicate_timestamp_rows = .N - uniqueN(timestamp_local),
  first_timestamp = min(timestamp_local),
  last_timestamp = max(timestamp_local)
), by = .(site, method)]
fwrite(input_summary, file.path(out_root, "fixed_tower_rotation_comparison_co2flux_input_summary.csv"))

by_timestamp <- dt[is.finite(co2_flux), .(co2_flux = mean(co2_flux)), by = .(site, method, timestamp_local)]
by_timestamp[, hour := as.integer(format(timestamp_local, "%H", tz = "Asia/Shanghai"))]
hourly <- by_timestamp[, mean_se(co2_flux), by = .(site, method, hour)]
hourly[, ci95 := 1.96 * se]
hourly[, method := factor(method, levels = c("No rotation", "Sector PF (SPF)"))]
setorder(hourly, site, method, hour)
fwrite(hourly, file.path(out_root, "fixed_tower_rotation_comparison_co2flux_mean_by_hour.csv"))

p <- ggplot(hourly, aes(x = hour, y = mean, colour = site, linetype = method, shape = method)) +
  geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.4) +
  geom_line(linewidth = 0.95) +
  geom_point(size = 1.7) +
  scale_x_continuous(breaks = seq(0, 23, by = 3), limits = c(0, 23)) +
  scale_colour_manual(values = c(CVT = "#F8766D", MT = "#619CFF")) +
  scale_linetype_manual(values = c("No rotation" = "solid", "Sector PF (SPF)" = "longdash")) +
  scale_shape_manual(values = c("No rotation" = 16, "Sector PF (SPF)" = 17)) +
  labs(
    title = expression("CO"[2] * " flux mean diurnal pattern before and after rotation"),
    x = "Hour of day (Asia/Shanghai)",
    y = expression("Mean CO"[2] * " flux (" * mu * "mol m"^-2 * " s"^-1 * ")"),
    caption = "Duplicate timestamps are averaged within each site x method before hourly means. Sector PF (SPF) uses current after-PF full results."
  ) +
  theme_regov(base_size = 15)

ggsave(
  file.path(figure_dir, "fixed_tower_rotation_comparison_co2flux_mean_diurnal.png"),
  p,
  width = 10.5,
  height = 6.4,
  dpi = 300
)

writeLines(c(
  "Fixed tower CO2 flux rotation comparison",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  "",
  "Inputs:",
  paste0("- ", inputs$site, " / ", inputs$method, ": ", inputs$path),
  "",
  "Outputs:",
  "- fixed_tower_rotation_comparison_co2flux_mean_by_hour.csv",
  "- fixed_tower_rotation_comparison_co2flux_input_summary.csv",
  "- figures/fixed_tower_rotation_comparison_co2flux_mean_diurnal.png",
  "",
  "Notes:",
  "- Timestamp columns are read as character before explicit Asia/Shanghai parsing.",
  "- Duplicate timestamps are first averaged within each site x method to avoid double counting.",
  "- Station colours follow project memory: CVT = #F8766D, MT = #619CFF."
), file.path(out_root, "fixed_tower_rotation_comparison_co2flux_diurnal_summary.txt"), useBytes = TRUE)

message("Wrote rotation comparison CO2 flux diurnal outputs to: ", out_root)
