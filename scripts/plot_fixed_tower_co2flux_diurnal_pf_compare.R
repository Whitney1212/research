library(data.table)
library(ggplot2)

sites <- list(
  MT = list(
    root = "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF",
    after = "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv",
    before = "E:/Dataset_Level1/MT/EC/PF/WINDOW/flux_runs/global_pf/MT_flux_global_pf.csv",
    before_label = "global_pf_baseline",
    after_label = "sector_pf"
  ),
  CVT = list(
    root = "E:/Dataset_Level1/CVT/EC/PF",
    after = "E:/Dataset_Level1/CVT/EC/PF/CVT_flux_sector_pf.csv",
    before = NA_character_,
    before_label = NA_character_,
    after_label = "sector_pf"
  )
)

read_co2 <- function(path, label) {
  x <- fread(path, select = c("timestamp", "co2_flux"))
  x[, `:=`(
    timestamp = as.POSIXct(timestamp, tz = "Asia/Shanghai"),
    method = label
  )]
  x[!is.na(timestamp) & is.finite(co2_flux)]
}

plot_site <- function(site, cfg) {
  out_dir <- file.path(cfg$root, "figures_pf_co2flux_diurnal")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  after <- read_co2(cfg$after, cfg$after_label)
  sources <- list(after)
  note <- "Only sector_pf full-period result was available."

  if (!is.na(cfg$before) && file.exists(cfg$before)) {
    before <- read_co2(cfg$before, cfg$before_label)
    common <- intersect(before$timestamp, after$timestamp)
    sources <- list(before[timestamp %in% common], after[timestamp %in% common])
    note <- sprintf("Compared on %d common timestamps.", length(common))
  }

  x <- rbindlist(sources, use.names = TRUE)
  x[, hour := as.integer(format(timestamp, "%H")) + as.integer(format(timestamp, "%M")) / 60]
  hourly <- x[, .(
    n = .N,
    mean_co2_flux = mean(co2_flux),
    se = sd(co2_flux) / sqrt(.N)
  ), by = .(method, hour)]
  hourly[is.na(se), se := 0]
  hourly[, `:=`(ymin = mean_co2_flux - 1.96 * se, ymax = mean_co2_flux + 1.96 * se)]
  fwrite(hourly, file.path(cfg$root, sprintf("%s_pf_co2flux_diurnal_compare.csv", site)))

  p <- ggplot(hourly, aes(hour, mean_co2_flux, color = method, fill = method)) +
    geom_hline(yintercept = 0, color = "grey55", linewidth = 0.25) +
    geom_ribbon(aes(ymin = ymin, ymax = ymax), alpha = 0.18, color = NA) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 1.4) +
    scale_x_continuous(breaks = seq(0, 24, 3), limits = c(0, 24)) +
    labs(
      title = sprintf("%s CO2 flux diurnal cycle before/after sector PF", site),
      subtitle = note,
      x = "hour of day",
      y = "mean CO2 flux +/- 1.96 SE"
    ) +
    theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank(), legend.position = "bottom")
  ggsave(file.path(out_dir, sprintf("%s_pf_co2flux_diurnal_compare.png", site)),
         p, width = 10, height = 6, dpi = 300)

  writeLines(c(
    sprintf("%s CO2 flux diurnal PF comparison", site),
    sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    sprintf("After PF: %s", cfg$after),
    sprintf("Before/baseline: %s", ifelse(is.na(cfg$before), "not available", cfg$before)),
    note,
    "Files:",
    sprintf("- %s_pf_co2flux_diurnal_compare.csv", site),
    sprintf("- figures_pf_co2flux_diurnal/%s_pf_co2flux_diurnal_compare.png", site)
  ), file.path(cfg$root, sprintf("%s_pf_co2flux_diurnal_compare_summary.txt", site)))
}

for (site in names(sites)) plot_site(site, sites[[site]])
