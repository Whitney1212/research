suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

in_dir <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/mechanism_diagnostics"
figure_dir <- file.path(in_dir, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

comparison_map <- data.table(
  method_label = c("Double rotation", "Global PF", "Sector PF"),
  comparison_label = c("DR vs No rotation", "Global PF vs No rotation", "Sector PF vs No rotation")
)

line_cols <- c(
  "No rotation" = "#4D4D4D",
  "Double rotation" = "#F28E2B",
  "Global PF" = "#59A14F",
  "Sector PF" = "#E15759"
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

main <- function() {
  dt <- fread(file.path(in_dir, "rotation_sigma_w_diurnal_plot_data.csv"))[
    variable == "w' / sigma_w (m s^-1)"
  ]
  stopifnot(nrow(dt) > 0L)

  no_rot <- copy(dt[method_label == "No rotation"])
  no_rot[, join_key := 1L]
  comparison_keys <- copy(comparison_map[, .(comparison_label)])
  comparison_keys[, join_key := 1L]
  no_rot <- merge(no_rot, comparison_keys, by = "join_key", allow.cartesian = TRUE)[, join_key := NULL]

  others <- merge(
    dt[method_label %in% comparison_map$method_label],
    comparison_map,
    by = "method_label",
    all.x = TRUE,
    sort = FALSE
  )

  plot_dt <- rbindlist(list(no_rot, others), use.names = TRUE, fill = TRUE)
  plot_dt[, comparison_label := factor(
    comparison_label,
    levels = comparison_map$comparison_label
  )]
  plot_dt[, method_label := factor(
    method_label,
    levels = c("No rotation", "Double rotation", "Global PF", "Sector PF")
  )]

  p <- ggplot(plot_dt, aes(
    x = hour_decimal,
    y = median_value,
    colour = method_label,
    fill = method_label,
    group = method_label
  )) +
    geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.12, colour = NA) +
    geom_line(linewidth = 0.55) +
    facet_grid(site ~ comparison_label, scales = "free_y") +
    scale_colour_manual(values = line_cols, drop = FALSE) +
    scale_fill_manual(values = line_cols, drop = FALSE) +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(v) sprintf("%02d:00", as.integer(v))
    ) +
    scale_y_continuous(breaks = function(v) pretty(v, n = 10)) +
    labs(
      title = "Fixed-tower sigma_w diurnal comparison against no rotation",
      subtitle = "Rows = towers; columns = each rotation method against no rotation; median with 25-75% ribbon.",
      x = "Local half-hour bin",
      y = expression(sigma[w]~"(m s"^-1*")"),
      caption = "Source = existing four-method rotation diagnostics for common periods."
    ) +
    theme_regov(base_size = 13)

  out_png <- file.path(figure_dir, "rotation_sigma_w_vs_no_rotation_diurnal_facets_16x9.png")
  out_csv <- file.path(in_dir, "rotation_sigma_w_vs_no_rotation_diurnal_facets_plot_data.csv")
  ggsave(out_png, p, width = 16, height = 9, dpi = 300)
  fwrite(plot_dt, out_csv)
  message("Wrote: ", out_png)
  message("Wrote: ", out_csv)
}

if (sys.nframe() == 0L) {
  main()
}
