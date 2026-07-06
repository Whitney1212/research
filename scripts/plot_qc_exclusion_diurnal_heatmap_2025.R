#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

default_tz <- "Asia/Shanghai"

site_configs <- data.table(
  site = c("MT", "CVT"),
  input = c(
    "E:/Dataset_Level1/MT/EC/whole year computation/MT_nee_2025_estimate_30min_gapfilled.csv",
    "E:/Dataset_Level1/CVT/EC/whole year computation/CVT_nee_2025_estimate_30min_gapfilled.csv"
  ),
  output_dir = c(
    "E:/Dataset_Level1/MT/EC/whole year computation",
    "E:/Dataset_Level1/CVT/EC/whole year computation"
  )
)

parse_time <- function(x, tz_local = default_tz) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

build_site_heatmap_table <- function(site, input_file) {
  dt <- fread(input_file, encoding = "UTF-8")
  required <- c("timestamp_local", "site", "has_record", "has_flux", "qc_co2_pass", "flag9_co2_pass", "hhmm", "month")
  missing_cols <- setdiff(required, names(dt))
  if (length(missing_cols) > 0L) {
    stop("Missing required columns in ", input_file, ": ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  dt[, timestamp_local := parse_time(timestamp_local)]
  dt[, month := as.integer(month)]
  dt[, hhmm := as.character(hhmm)]
  hhmm_levels <- format(seq(
    from = as.POSIXct("2025-01-01 00:00:00", tz = default_tz),
    by = "30 min",
    length.out = 48
  ), "%H:%M", tz = default_tz)

  dt[, eligible_qc := has_record & has_flux & is.finite(qc_co2)]
  dt[, eligible_flag9 := has_record & has_flux & is.finite(flag9_co2)]

  qc_tbl <- dt[, .(
    available_windows = sum(eligible_qc),
    excluded_windows = sum(eligible_qc & !qc_co2_pass)
  ), by = .(month, hhmm)]
  qc_tbl[, `:=`(
    qc_test = "qc_co2 <= 1",
    exclusion_rate = fifelse(available_windows > 0, excluded_windows / available_windows, NA_real_)
  )]

  flag9_tbl <- dt[, .(
    available_windows = sum(eligible_flag9),
    excluded_windows = sum(eligible_flag9 & !flag9_co2_pass)
  ), by = .(month, hhmm)]
  flag9_tbl[, `:=`(
    qc_test = "flag9_co2 <= 3",
    exclusion_rate = fifelse(available_windows > 0, excluded_windows / available_windows, NA_real_)
  )]

  out <- rbindlist(list(qc_tbl, flag9_tbl), use.names = TRUE)
  out[, `:=`(
    site = site,
    hhmm = factor(hhmm, levels = hhmm_levels),
    month_label = factor(sprintf("%02d", month), levels = rev(sprintf("%02d", 1:12))),
    qc_test = factor(qc_test, levels = c("qc_co2 <= 1", "flag9_co2 <= 3"))
  )]
  out[]
}

plot_site_heatmap <- function(plot_dt, site, output_png) {
  x_breaks <- levels(plot_dt$hhmm)[seq(1, 48, by = 4)]
  p <- ggplot(plot_dt, aes(x = hhmm, y = month_label, fill = exclusion_rate)) +
    geom_tile(color = NA) +
    facet_grid(qc_test ~ ., scales = "free_y", space = "free_y") +
    scale_fill_gradient(
      low = "#F7FBFF",
      high = "#D55E00",
      limits = c(0, 1),
      na.value = "#F0F0F0",
      labels = function(x) sprintf("%.0f%%", x * 100)
    ) +
    scale_x_discrete(breaks = x_breaks) +
    labs(
      title = sprintf("%s 2025 QC Exclusion Diurnal Heatmap", site),
      subtitle = "Denominator = windows with record and finite co2_flux; missing_no_record excluded",
      x = NULL,
      y = "Month",
      fill = "Exclusion rate"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
      strip.text.y = element_text(face = "bold"),
      plot.title = element_text(face = "bold")
    )

  ggsave(output_png, p, width = 12, height = 5.8, dpi = 220)
}

plot_combined_heatmap <- function(plot_dt, output_png) {
  x_breaks <- levels(plot_dt$hhmm)[seq(1, 48, by = 4)]
  p <- ggplot(plot_dt, aes(x = hhmm, y = month_label, fill = exclusion_rate)) +
    geom_tile(color = NA) +
    facet_grid(site ~ qc_test) +
    scale_fill_gradient(
      low = "#F7FBFF",
      high = "#D55E00",
      limits = c(0, 1),
      na.value = "#F0F0F0",
      labels = function(x) sprintf("%.0f%%", x * 100)
    ) +
    scale_x_discrete(breaks = x_breaks) +
    labs(
      title = "MT / CVT 2025 QC Exclusion Diurnal Heatmap",
      subtitle = "Denominator = windows with record and finite co2_flux; missing_no_record excluded",
      x = NULL,
      y = "Month",
      fill = "Exclusion rate"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold")
    )

  ggsave(output_png, p, width = 14, height = 7.2, dpi = 220)
}

demo <- data.table(
  month = c(1L, 1L, 1L),
  hhmm = c("00:00", "00:00", "00:30"),
  has_record = c(TRUE, FALSE, TRUE),
  has_flux = c(TRUE, FALSE, TRUE),
  qc_co2 = c(2, NA, 0),
  qc_co2_pass = c(FALSE, FALSE, TRUE),
  flag9_co2 = c(5, NA, 2),
  flag9_co2_pass = c(FALSE, FALSE, TRUE)
)
demo[, eligible_qc := has_record & has_flux & is.finite(qc_co2)]
demo_check <- demo[, .(
  available_windows = sum(eligible_qc),
  excluded_windows = sum(eligible_qc & !qc_co2_pass)
), by = hhmm][order(hhmm)]
stopifnot(demo_check[hhmm == "00:00", available_windows] == 1L, demo_check[hhmm == "00:00", excluded_windows] == 1L)

main <- function() {
  all_dt <- rbindlist(lapply(seq_len(nrow(site_configs)), function(i) {
    cfg <- site_configs[i]
    dir.create(cfg$output_dir, recursive = TRUE, showWarnings = FALSE)
    plot_dt <- build_site_heatmap_table(cfg$site, cfg$input)
    fwrite(
      plot_dt[, .(
        site,
        qc_test = as.character(qc_test),
        month,
        hhmm = as.character(hhmm),
        available_windows,
        excluded_windows,
        exclusion_rate
      )],
      file.path(cfg$output_dir, sprintf("%s_2025_qc_exclusion_diurnal_heatmap.csv", cfg$site))
    )
    plot_site_heatmap(
      plot_dt = plot_dt,
      site = cfg$site,
      output_png = file.path(cfg$output_dir, sprintf("%s_2025_qc_exclusion_diurnal_heatmap.png", cfg$site))
    )
    plot_dt
  }), use.names = TRUE)

  combined_png <- file.path(site_configs$output_dir[[1]], "MT_CVT_2025_qc_exclusion_diurnal_heatmap.png")
  plot_combined_heatmap(all_dt, combined_png)
  file.copy(
    from = combined_png,
    to = file.path(site_configs$output_dir[[2]], "MT_CVT_2025_qc_exclusion_diurnal_heatmap.png"),
    overwrite = TRUE
  )
}

if (sys.nframe() == 0L) {
  main()
}
