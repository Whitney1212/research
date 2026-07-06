library(data.table)
library(ggplot2)

flux_vars <- c("co2_flux", "h2o_flux", "H", "LE", "Tau", "u_star")

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

read_flux <- function(path, label) {
  x <- fread(path, select = c("timestamp", "geo_wind_from_deg", flux_vars))
  x[, method := label]
  x
}

plot_wind_rose <- function(site, cfg) {
  x <- read_flux(cfg$after, cfg$after_label)
  out_dir <- file.path(cfg$root, "figures_wind_rose")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  rose <- x[is.finite(geo_wind_from_deg), .(
    sector = floor((geo_wind_from_deg %% 360) / 30) * 30
  )][, .N, by = sector][order(sector)]
  rose[, `:=`(
    sector_mid = sector + 15,
    sector_label = sprintf("%03d-%03d", sector, sector + 30),
    percent = 100 * N / sum(N)
  )]
  fwrite(rose, file.path(cfg$root, sprintf("%s_wind_rose_30deg_counts.csv", site)))

  p <- ggplot(rose, aes(x = sector_mid, y = percent)) +
    geom_col(width = 28, fill = "#4C78A8", color = "white", linewidth = 0.25) +
    coord_polar(start = -pi / 12) +
    scale_x_continuous(breaks = seq(0, 330, 30), limits = c(0, 360)) +
    labs(
      title = sprintf("%s wind rose after sector PF", site),
      subtitle = "30 deg bins from geo_wind_from_deg",
      x = "wind from direction (deg)",
      y = "percent of records"
    ) +
    theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank())
  ggsave(file.path(out_dir, sprintf("%s_wind_rose_after_sector_pf.png", site)),
         p, width = 8, height = 8, dpi = 300)
}

mean_table <- function(x) {
  melt(x, id.vars = "method", measure.vars = flux_vars, variable.name = "flux_var",
       value.name = "value")[is.finite(value), .(
         n = .N,
         mean = mean(value),
         se = sd(value) / sqrt(.N)
       ), by = .(method, flux_var)]
}

plot_flux_means <- function(site, cfg) {
  out_dir <- file.path(cfg$root, "figures_pf_flux_mean_compare")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  after <- read_flux(cfg$after, cfg$after_label)
  sources <- list(after)
  note <- "Only sector_pf full-period result was available."

  if (!is.na(cfg$before) && file.exists(cfg$before)) {
    before <- read_flux(cfg$before, cfg$before_label)
    common <- intersect(before$timestamp, after$timestamp)
    before <- before[timestamp %in% common]
    after <- after[timestamp %in% common]
    sources <- list(before, after)
    note <- sprintf("Compared on %d common timestamps.", length(common))
  }

  means <- mean_table(rbindlist(sources, use.names = TRUE, fill = TRUE))
  fwrite(means, file.path(cfg$root, sprintf("%s_pf_flux_mean_compare.csv", site)))

  means[, ymin := mean - 1.96 * se]
  means[, ymax := mean + 1.96 * se]
  p <- ggplot(means, aes(method, mean, fill = method)) +
    geom_hline(yintercept = 0, color = "grey55", linewidth = 0.25) +
    geom_col(width = 0.65, color = "grey25", linewidth = 0.2) +
    geom_errorbar(aes(ymin = ymin, ymax = ymax), width = 0.15, linewidth = 0.25) +
    facet_wrap(~ flux_var, scales = "free_y", ncol = 3) +
    labs(
      title = sprintf("%s PF flux mean comparison", site),
      subtitle = note,
      x = NULL,
      y = "mean +/- 1.96 SE"
    ) +
    theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank(), legend.position = "none",
          axis.text.x = element_text(angle = 30, hjust = 1))
  ggsave(file.path(out_dir, sprintf("%s_pf_flux_mean_compare.png", site)),
         p, width = 12, height = 7, dpi = 300)

  writeLines(c(
    sprintf("%s wind rose and PF flux mean plots", site),
    sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    sprintf("After PF: %s", cfg$after),
    sprintf("Before/baseline: %s", ifelse(is.na(cfg$before), "not available", cfg$before)),
    note,
    "Files:",
    sprintf("- %s_wind_rose_30deg_counts.csv", site),
    sprintf("- figures_wind_rose/%s_wind_rose_after_sector_pf.png", site),
    sprintf("- %s_pf_flux_mean_compare.csv", site),
    sprintf("- figures_pf_flux_mean_compare/%s_pf_flux_mean_compare.png", site)
  ), file.path(cfg$root, sprintf("%s_wind_rose_pf_flux_mean_summary.txt", site)))
}

for (site in names(sites)) {
  plot_wind_rose(site, sites[[site]])
  plot_flux_means(site, sites[[site]])
}
