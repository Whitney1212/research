#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

in_csv <- "E:/Dataset_Level1/Flares/EC_ecpreproc/FL_full_ec_sigma_diurnal_plot_data.csv"
out_root <- "E:/Dataset_Level1/Flares/EC_ecpreproc"
figure_dir <- file.path(out_root, "figures_diurnal")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

method_levels <- c("No rotation", "Double rotation", "PF_8bin_2ensemble")
method_cols <- c(
  "No rotation" = "#4E79A7",
  "Double rotation" = "#F28E2B",
  "PF_8bin_2ensemble" = "#59A14F"
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
      plot.caption = element_text(colour = "grey35", size = rel(0.8), hjust = 0)
    )
}

dt <- fread(in_csv, showProgress = FALSE)[variable == "Wind fluctuation"]
stopifnot(nrow(dt) > 0L)
dt[, method_label := factor(method_label, levels = method_levels)]
setorder(dt, method_label, half_hour_bin)

plot_csv <- file.path(out_root, "FL_full_ec_sigma_w_diurnal_plot_data.csv")
plot_png <- file.path(figure_dir, "FL_full_ec_sigma_w_diurnal.png")
summary_txt <- file.path(out_root, "FL_full_ec_sigma_w_diurnal_summary.txt")

p <- ggplot(
  dt,
  aes(x = half_hour_bin, y = median_value, colour = method_label, fill = method_label, group = method_label)
) +
  geom_ribbon(aes(ymin = q25, ymax = q75), alpha = 0.13, colour = NA) +
  geom_line(linewidth = 0.6) +
  scale_colour_manual(values = method_cols, drop = FALSE) +
  scale_fill_manual(values = method_cols, drop = FALSE) +
  scale_x_continuous(
    breaks = seq(0, 24, by = 3),
    limits = c(0, 23.5),
    labels = function(x) sprintf("%02d:00", as.integer(x))
  ) +
  scale_y_continuous(breaks = function(x) pretty(x, n = 10)) +
  labs(
    title = "FL full-data sigma_w by rotation method",
    subtitle = "All source_groups pooled. Line = median by half-hour; ribbon = 25th-75th percentile across windows.",
    x = "Local half-hour bin",
    y = expression(sigma[w]~"(m s"^-1*")"),
    caption = "Source = FL_full_ec_sigma_diurnal_plot_data.csv. sigma_w uses delivered FL full EC 30 min w_sd."
  ) +
  theme_regov(base_size = 13)

ggsave(plot_png, p, width = 12, height = 7.2, dpi = 300)
out <- copy(dt)
out[, `:=`(method_label = as.character(method_label), variable = NULL)]
fwrite(out, plot_csv)

coverage <- out[, .(
  n_half_hour_bins = uniqueN(half_hour_bin),
  n_dates_min = min(n_dates),
  n_dates_max = max(n_dates),
  n_windows_min = min(n_windows),
  n_windows_max = max(n_windows),
  n_source_groups = max(n_source_groups)
), by = method_label]

writeLines(
  c(
    "FL full EC sigma_w diurnal summary",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    paste0("Input plot data: ", in_csv),
    "",
    "Outputs:",
    paste0("- ", plot_csv),
    paste0("- ", plot_png),
    "",
    "Notes:",
    "- Reuses existing FL sigma diurnal plot data; does not reread raw EC results.",
    "- sigma_w = delivered 30 min w_sd.",
    "- All source_groups are pooled into one full-data diurnal plot.",
    "",
    "Coverage by method:",
    apply(coverage, 1, function(x) {
      sprintf(
        "- %s: bins=%s, n_dates range=%s-%s, n_windows range=%s-%s, pooled source_groups=%s",
        x[["method_label"]], x[["n_half_hour_bins"]],
        x[["n_dates_min"]], x[["n_dates_max"]],
        x[["n_windows_min"]], x[["n_windows_max"]],
        x[["n_source_groups"]]
      )
    })
  ),
  summary_txt,
  useBytes = TRUE
)

message("Wrote: ", plot_png)
