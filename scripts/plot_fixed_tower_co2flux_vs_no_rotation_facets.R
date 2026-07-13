suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

diag_file <- "D:/00 博士阶段/博一/05 Project/com_rotation/results/analysis/tables/13_w_sigma_flux_joined.csv"
out_dir <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/mechanism_diagnostics"
figure_dir <- file.path(out_dir, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

site_cols <- c(CVT = "#F8766D", MT = "#619CFF")
comparison_map <- data.table(
  rotation_requested_driver = c("dr", "pf", "spf"),
  comparison_label = c("DR vs No rotation", "Global PF vs No rotation", "Sector PF vs No rotation"),
  method_label = c("Double rotation", "Global PF", "Sector PF")
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

parse_local_timestamp <- function(x, tz_local = "Asia/Shanghai") {
  raw <- trimws(as.character(x))
  parsed <- as.POSIXct(raw, format = "%Y-%m-%d %H:%M:%S", tz = tz_local)
  bad <- is.na(parsed)
  if (any(bad)) {
    parsed[bad] <- as.POSIXct(raw[bad], format = "%Y-%m-%d %H:%M", tz = tz_local)
  }
  parsed
}

main <- function() {
  dt <- fread(diag_file, colClasses = list(character = "timestamp"))
  stopifnot(nrow(dt) > 0L, all(c("site", "rotation_requested_driver", "co2_flux", "timestamp") %in% names(dt)))

  dt <- dt[
    rotation_requested_driver %in% c("none", "dr", "pf", "spf") & is.finite(co2_flux)
  ]
  dt[, timestamp_local := parse_local_timestamp(timestamp, tz_local = "Asia/Shanghai")]
  stopifnot(all(!is.na(dt$timestamp_local)))
  dt[, hour_decimal := as.integer(format(timestamp_local, "%H", tz = "Asia/Shanghai")) +
    as.integer(format(timestamp_local, "%M", tz = "Asia/Shanghai")) / 60]

  summary_dt <- dt[, .(
    n_windows = .N,
    median_flux = stats::median(co2_flux, na.rm = TRUE)
  ), by = .(site, rotation_requested_driver, hour_decimal)]

  no_rot <- copy(summary_dt[rotation_requested_driver == "none"])
  no_rot[, join_key := 1L]
  no_rot <- merge(
    no_rot,
    comparison_map[, .(comparison_label)][, join_key := 1L],
    by = "join_key",
    allow.cartesian = TRUE
  )[, join_key := NULL]
  no_rot[, curve_label := "No rotation"]

  others <- merge(
    summary_dt[rotation_requested_driver %in% comparison_map$rotation_requested_driver],
    comparison_map[, .(rotation_requested_driver, comparison_label, method_label)],
    by = "rotation_requested_driver",
    all.x = TRUE,
    sort = FALSE
  )
  others[, curve_label := method_label]

  plot_dt <- rbindlist(list(no_rot, others), use.names = TRUE, fill = TRUE)
  plot_dt[, comparison_label := factor(comparison_label, levels = comparison_map$comparison_label)]
  plot_dt[, curve_label := factor(
    curve_label,
    levels = c("No rotation", "Double rotation", "Global PF", "Sector PF")
  )]

  p <- ggplot(
    plot_dt,
    aes(
      x = hour_decimal,
      y = median_flux,
      colour = site,
      linetype = curve_label,
      group = interaction(site, curve_label)
    )
  ) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
    geom_line(linewidth = 0.55) +
    facet_wrap(~ comparison_label, nrow = 1, scales = "free_y") +
    scale_colour_manual(values = site_cols, drop = FALSE) +
    scale_linetype_manual(values = c(
      "No rotation" = "solid",
      "Double rotation" = "22",
      "Global PF" = "42",
      "Sector PF" = "F2"
    ), drop = FALSE) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(v) sprintf("%02d:00", as.integer(v))
    ) +
    scale_y_continuous(breaks = function(v) pretty(v, n = 10)) +
    labs(
      title = "Fixed-tower CO2 flux diurnal comparison against no rotation",
      subtitle = "Three common rotation methods are compared against no rotation; lines show common-period half-hour medians.",
      x = "Local half-hour bin",
      y = expression("CO"[2] * " flux (" * mu * "mol m"^-2 * " s"^-1 * ")"),
      caption = "Colours follow project memory: CVT = #F8766D, MT = #619CFF. Source = common-period four-method rotation diagnostics."
    ) +
    theme_regov(base_size = 13)

  out_png <- file.path(figure_dir, "rotation_co2flux_vs_no_rotation_diurnal_facets_16x9.png")
  out_csv <- file.path(out_dir, "rotation_co2flux_vs_no_rotation_diurnal_facets_plot_data.csv")
  ggsave(out_png, p, width = 16, height = 9, dpi = 300)
  fwrite(plot_dt, out_csv)
  message("Wrote: ", out_png)
  message("Wrote: ", out_csv)
}

if (sys.nframe() == 0L) {
  main()
}
