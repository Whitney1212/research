suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

in_file <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/rotation_sensitivity_standardized_2025_strict_vs_no_qc_compact_table.csv"
out_dir <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/figures"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

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

method_map <- c(
  no_rotation = "No rotation",
  dr = "Double rotation",
  global_pf = "Global PF",
  sector_pf = "Sector PF"
)

qc_fill <- c(
  "Strict QC" = "#A6CEE3",
  "No QC/flag9" = "#1F78B4"
)

qc_line <- c(
  "Strict QC" = "solid",
  "No QC/flag9" = "22"
)

main <- function() {
  dt <- fread(in_file)
  stopifnot(nrow(dt) > 0L)

  dt <- dt[!grepl("^season_sector_pf", method)]
  dt[, qc_state := fifelse(grepl("\\[strict_qc_flag9\\]$", method), "Strict QC", "No QC/flag9")]
  dt[, method_key := sub(" \\[.*\\]$", "", method)]
  dt <- dt[method_key %in% names(method_map)]
  dt[, method_label := factor(method_map[method_key], levels = unname(method_map))]
  dt[, qc_state := factor(qc_state, levels = c("Strict QC", "No QC/flag9"))]
  dt[, tower := factor(tower, levels = c("MT", "CVT"))]
  setnames(dt, c("percentage of observed valid windows", "annual nee estimate"), c("observed_pct", "annual_nee"))

  stopifnot(nrow(dt) == 16L)

  nee_min <- floor(min(dt$annual_nee, na.rm = TRUE) / 50) * 50
  nee_max <- ceiling(max(dt$annual_nee, na.rm = TRUE) / 50) * 50
  if (nee_max == nee_min) nee_max <- nee_min + 1

  to_pct_axis <- function(x) (x - nee_min) / (nee_max - nee_min) * 100
  from_pct_axis <- function(x) x / 100 * (nee_max - nee_min) + nee_min
  dt[, nee_scaled := to_pct_axis(annual_nee)]

  posn <- position_dodge(width = 0.72)

  p <- ggplot(dt, aes(x = method_label)) +
    geom_col(
      aes(y = observed_pct, fill = qc_state),
      position = posn,
      width = 0.64,
      alpha = 0.88,
      colour = "grey35",
      linewidth = 0.25
    ) +
    geom_line(
      aes(y = nee_scaled, linetype = qc_state, group = qc_state),
      position = posn,
      linewidth = 0.55,
      colour = "grey10"
    ) +
    geom_point(
      aes(y = nee_scaled),
      position = posn,
      size = 1.5,
      shape = 21,
      stroke = 0.25,
      fill = "white",
      colour = "grey10"
    ) +
    facet_wrap(~ tower, nrow = 1) +
    scale_fill_manual(values = qc_fill, drop = FALSE) +
    scale_linetype_manual(values = qc_line, drop = FALSE) +
    scale_y_continuous(
      name = "Observed valid windows (%)",
      breaks = seq(0, 100, by = 10),
      limits = c(0, 100),
      sec.axis = sec_axis(~ from_pct_axis(.), name = expression("Annual NEE (gC m"^-2*")"))
    ) +
    labs(
      title = "QC contrast of observed-window share and annual NEE across rotation methods",
      subtitle = "Bars show observed valid-window share; lines show annual NEE. Common four methods only.",
      x = NULL,
      caption = "Source = strict vs no_qc compact summary. MT/CVT are faceted left to right; QC state is encoded by bar fill and line type."
    ) +
    theme_regov(base_size = 13)

  out_png <- file.path(out_dir, "fixed_tower_qc_contrast_bar_line_nee_16x9.png")
  out_csv <- file.path(dirname(in_file), "fixed_tower_qc_contrast_bar_line_nee_plot_data.csv")
  ggsave(out_png, p, width = 16, height = 9, dpi = 300)
  fwrite(dt, out_csv)
  message("Wrote: ", out_png)
  message("Wrote: ", out_csv)
}

if (sys.nframe() == 0L) {
  main()
}
