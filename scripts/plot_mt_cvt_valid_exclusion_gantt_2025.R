#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

default_tz <- "Asia/Shanghai"
step_seconds <- 1800

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

reason_levels <- c(
  "observed_valid",
  "missing_no_record",
  "qc_co2_fail",
  "flag9_co2_fail",
  "present_no_flux",
  "night_no_u_star",
  "night_u_star_below_threshold",
  "duplicate_exact_record",
  "other"
)

reason_labels <- c(
  observed_valid = "Valid",
  missing_no_record = "No record",
  qc_co2_fail = "qc_co2 fail",
  flag9_co2_fail = "flag9_co2 fail",
  present_no_flux = "No flux",
  night_no_u_star = "Night no u*",
  night_u_star_below_threshold = "Night u* below threshold",
  duplicate_exact_record = "Duplicate timestamp",
  other = "Other"
)

reason_colors <- c(
  observed_valid = "#2E8B57",
  missing_no_record = "#BDBDBD",
  qc_co2_fail = "#D55E00",
  flag9_co2_fail = "#E69F00",
  present_no_flux = "#CC79A7",
  night_no_u_star = "#56B4E9",
  night_u_star_below_threshold = "#0072B2",
  duplicate_exact_record = "#8C564B",
  other = "#7F7F7F"
)

parse_time <- function(x, tz_local = default_tz) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

normalize_reason <- function(valid_final, gap_reason_final) {
  out <- ifelse(as.logical(valid_final), "observed_valid", as.character(gap_reason_final))
  out[is.na(out) | out == ""] <- "other"
  out[!out %in% reason_levels] <- "other"
  out
}

build_blocks <- function(site, input_file, tz_local = default_tz) {
  dt <- fread(input_file, encoding = "UTF-8")
  required <- c("timestamp_local", "site", "valid_final", "gap_reason_final")
  missing_cols <- setdiff(required, names(dt))
  if (length(missing_cols) > 0) {
    stop("Missing required columns in ", input_file, ": ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  dt[, timestamp_local := parse_time(timestamp_local, tz_local = tz_local)]
  dt <- dt[!is.na(timestamp_local)]
  setorder(dt, timestamp_local)
  dt[, valid_final := as.logical(valid_final)]
  dt[, reason_code := normalize_reason(valid_final, gap_reason_final)]

  dt[, new_block := fifelse(
    rowid(site) == 1L,
    TRUE,
    reason_code != shift(reason_code) |
      as.numeric(timestamp_local) - as.numeric(shift(timestamp_local)) != step_seconds
  )]
  dt[, block_id := cumsum(new_block)]

  blocks <- dt[, .(
    site = first(site),
    reason_code = first(reason_code),
    start_time = first(timestamp_local),
    end_time = last(timestamp_local) + step_seconds,
    n_halfhours = .N,
    duration_hours = .N * 0.5
  ), by = block_id]

  blocks[, reason_label := factor(reason_labels[reason_code], levels = unname(reason_labels[reason_levels]))]
  blocks[, reason_code := factor(reason_code, levels = reason_levels)]
  blocks
}

plot_site_gantt <- function(blocks, site, output_png) {
  p <- ggplot(blocks) +
    geom_rect(
      aes(
        xmin = start_time,
        xmax = end_time,
        ymin = 0.2,
        ymax = 0.8,
        fill = reason_code
      ),
      color = NA
    ) +
    scale_fill_manual(
      values = reason_colors,
      breaks = reason_levels,
      labels = reason_labels[reason_levels],
      drop = FALSE
    ) +
    scale_x_datetime(
      date_breaks = "1 month",
      date_labels = "%b",
      expand = c(0, 0)
    ) +
    coord_cartesian(ylim = c(0, 1)) +
    labs(
      title = sprintf("%s 2025 Valid / Excluded EC Windows", site),
      subtitle = "Valid windows and exclusion reasons before gapfilling",
      x = NULL,
      y = NULL,
      fill = NULL
    ) +
    theme_minimal(base_size = 12) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(face = "bold")
    )

  ggsave(output_png, p, width = 14, height = 2.8, dpi = 220)
}

plot_combined_gantt <- function(blocks, output_png) {
  p <- ggplot(blocks) +
    geom_rect(
      aes(
        xmin = start_time,
        xmax = end_time,
        ymin = 0.2,
        ymax = 0.8,
        fill = reason_code
      ),
      color = NA
    ) +
    facet_grid(site ~ ., scales = "free_y", space = "free_y") +
    scale_fill_manual(
      values = reason_colors,
      breaks = reason_levels,
      labels = reason_labels[reason_levels],
      drop = FALSE
    ) +
    scale_x_datetime(
      date_breaks = "1 month",
      date_labels = "%b",
      expand = c(0, 0)
    ) +
    coord_cartesian(ylim = c(0, 1)) +
    labs(
      title = "MT / CVT 2025 Valid / Excluded EC Windows",
      subtitle = "Valid windows and exclusion reasons before gapfilling",
      x = NULL,
      y = NULL,
      fill = NULL
    ) +
    theme_minimal(base_size = 12) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "bottom",
      strip.text.y = element_text(face = "bold"),
      plot.title = element_text(face = "bold")
    )

  ggsave(output_png, p, width = 14, height = 4.8, dpi = 220)
}

main <- function() {
  all_blocks <- rbindlist(lapply(seq_len(nrow(site_configs)), function(i) {
    cfg <- site_configs[i]
    blocks <- build_blocks(cfg$site, cfg$input)

    dir.create(cfg$output_dir, recursive = TRUE, showWarnings = FALSE)
    fwrite(
      blocks[, .(
        site,
        reason_code = as.character(reason_code),
        reason_label = as.character(reason_label),
        start_time = format(start_time, "%Y-%m-%d %H:%M:%S", tz = default_tz),
        end_time = format(end_time, "%Y-%m-%d %H:%M:%S", tz = default_tz),
        n_halfhours,
        duration_hours
      )],
      file.path(cfg$output_dir, sprintf("%s_nee_2025_valid_exclusion_gantt_blocks.csv", cfg$site))
    )
    plot_site_gantt(
      blocks = blocks,
      site = cfg$site,
      output_png = file.path(cfg$output_dir, sprintf("%s_nee_2025_valid_exclusion_gantt.png", cfg$site))
    )
    blocks
  }), use.names = TRUE)

  combined_png <- "MT_CVT_nee_2025_valid_exclusion_gantt.png"
  plot_combined_gantt(all_blocks, file.path(site_configs$output_dir[[1]], combined_png))
  file.copy(
    from = file.path(site_configs$output_dir[[1]], combined_png),
    to = file.path(site_configs$output_dir[[2]], combined_png),
    overwrite = TRUE
  )
}

block_demo <- data.table(
  site = "DEMO",
  timestamp_local = as.POSIXct(c("2025-01-01 00:00:00", "2025-01-01 00:30:00", "2025-01-01 01:00:00"), tz = default_tz),
  valid_final = c(TRUE, FALSE, FALSE),
  gap_reason_final = c("observed_valid", "qc_co2_fail", "qc_co2_fail")
)
block_demo[, reason_code := normalize_reason(valid_final, gap_reason_final)]
block_demo[, new_block := fifelse(
  rowid(site) == 1L,
  TRUE,
  reason_code != shift(reason_code) |
    as.numeric(timestamp_local) - as.numeric(shift(timestamp_local)) != step_seconds
)]
stopifnot(identical(cumsum(block_demo$new_block), c(1L, 2L, 2L)))

if (sys.nframe() == 0L) {
  main()
}
