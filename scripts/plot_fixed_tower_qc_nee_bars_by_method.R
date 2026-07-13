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
      axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 1),
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

main <- function() {
  dt <- fread(in_file)
  stopifnot(nrow(dt) > 0L)

  dt <- dt[!grepl("^season_sector_pf", method)]
  dt[, qc_state := fifelse(grepl("\\[strict_qc_flag9\\]$", method), "Strict QC", "No QC/flag9")]
  dt[, method_key := sub(" \\[.*\\]$", "", method)]
  dt <- dt[method_key %in% names(method_map)]
  setnames(dt, "annual nee estimate", "annual_nee")

  dt[, method_label := factor(method_map[method_key], levels = unname(method_map))]
  dt[, qc_state := factor(qc_state, levels = c("Strict QC", "No QC/flag9"))]
  dt[, tower := factor(tower, levels = c("MT", "CVT"))]

  stopifnot(nrow(dt) == 16L)

  p <- ggplot(dt, aes(x = tower, y = annual_nee, fill = qc_state)) +
    geom_hline(yintercept = 0, colour = "grey55", linewidth = 0.35) +
    geom_col(
      position = position_dodge(width = 0.72),
      width = 0.64,
      alpha = 0.9,
      colour = "grey35",
      linewidth = 0.25
    ) +
    facet_wrap(~ method_label, nrow = 1, scales = "free_y") +
    scale_fill_manual(values = qc_fill, drop = FALSE) +
    scale_y_continuous(breaks = function(v) pretty(v, n = 10)) +
    labs(
      title = "Annual NEE by rotation method under strict vs no-QC settings",
      subtitle = "Bars show annual NEE only; common four methods only.",
      x = NULL,
      y = expression("Annual NEE (gC m"^-2*")"),
      caption = "Source = strict vs no_qc compact summary. season_sector_pf is excluded."
    ) +
    theme_regov(base_size = 13)

  out_png <- file.path(out_dir, "fixed_tower_qc_annual_nee_bars_by_method_16x9.png")
  out_csv <- file.path(dirname(in_file), "fixed_tower_qc_annual_nee_bars_by_method_plot_data.csv")
  ggsave(out_png, p, width = 16, height = 9, dpi = 300)
  fwrite(dt, out_csv)
  message("Wrote: ", out_png)
  message("Wrote: ", out_csv)
}

if (sys.nframe() == 0L) {
  main()
}
