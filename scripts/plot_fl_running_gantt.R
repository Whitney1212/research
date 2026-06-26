#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(scales)
})

default_input_dir <- file.path("E:/Dataset_RAW/Flares", "\u8fd0\u884c\u8bb0\u5f55")
default_summary_file <- file.path(default_input_dir, "unified_output", "fl_running_records_file_summary.csv")
default_output_file <- file.path(default_input_dir, "unified_output", "fl_running_records_gantt.png")
default_timezone <- "Asia/Shanghai"

parse_args <- function(args) {
  opts <- list(
    input_dir = default_input_dir,
    summary_file = default_summary_file,
    output_file = default_output_file,
    timezone = default_timezone
  )

  for (arg in args) {
    if (grepl("^--input-dir=", arg)) {
      opts$input_dir <- sub("^--input-dir=", "", arg)
    } else if (grepl("^--summary-file=", arg)) {
      opts$summary_file <- sub("^--summary-file=", "", arg)
    } else if (grepl("^--output-file=", arg)) {
      opts$output_file <- sub("^--output-file=", "", arg)
    } else if (grepl("^--timezone=", arg)) {
      opts$timezone <- sub("^--timezone=", "", arg)
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/plot_fl_running_gantt.R [options]\n",
        "  --input-dir=PATH\n",
        "  --summary-file=PATH\n",
        "  --output-file=PATH\n",
        "  --timezone=Asia/Shanghai\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  opts
}

detect_mode <- function(filename) {
  lower_name <- tolower(filename)

  if (grepl("^fbox_hdata_.*\\.csv$", filename, perl = TRUE)) {
    return("fbox_csv")
  }

  if (grepl("\\.xlsx$", lower_name, perl = TRUE)) {
    return("export_xlsx")
  }

  if (grepl("\\.csv$", lower_name, perl = TRUE)) {
    return("standard_csv")
  }

  NA_character_
}

recover_source_labels <- function(summary_dt, input_dir) {
  if ("source_file" %in% names(summary_dt)) {
    registered <- !is.na(summary_dt$source_file) & nzchar(trimws(summary_dt$source_file))
    if (any(registered)) return(summary_dt)
  }

  paths <- list.files(input_dir, full.names = TRUE)
  paths <- paths[file.info(paths)$isdir %in% FALSE]
  paths <- sort(paths)
  labels <- basename(paths[!is.na(vapply(basename(paths), detect_mode, character(1)))])

  if (length(labels) == nrow(summary_dt)) {
    summary_dt[, source_file := labels]
  }

  summary_dt
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))

  if (!file.exists(opts$summary_file)) {
    stop("Summary file does not exist: ", opts$summary_file)
  }

  dir.create(dirname(opts$output_file), recursive = TRUE, showWarnings = FALSE)

  summary_dt <- fread(
    opts$summary_file,
    encoding = "UTF-8",
    colClasses = list(
      character = c("source_file", "source_mode", "time_min", "time_max")
    )
  )
  summary_dt <- recover_source_labels(summary_dt, opts$input_dir)

  summary_dt[, start_time := as.POSIXct(time_min, format = "%Y-%m-%d %H:%M:%OS", tz = opts$timezone)]
  summary_dt[, end_time := as.POSIXct(time_max, format = "%Y-%m-%d %H:%M:%OS", tz = opts$timezone)]
  summary_dt <- summary_dt[!is.na(start_time) & !is.na(end_time)]

  setorder(summary_dt, start_time, end_time, source_file)

  summary_dt[, label := sprintf("%s  (%s)", source_file, rows_valid)]
  summary_dt[, label := factor(label, levels = rev(label))]

  source_palette <- c(
    standard_csv = "#2C7FB8",
    export_xlsx = "#D95F0E",
    fbox_csv = "#238B45"
  )

  month_span <- as.numeric(difftime(max(summary_dt$end_time), min(summary_dt$start_time), units = "days"))
  date_break_unit <- if (month_span > 240) "1 month" else "2 weeks"

  p <- ggplot(summary_dt, aes(x = start_time, xend = end_time, y = label, yend = label, color = source_mode)) +
    geom_segment(linewidth = 5, lineend = "round") +
    geom_point(aes(x = start_time), size = 1.8) +
    geom_point(aes(x = end_time), size = 1.8) +
    scale_color_manual(
      values = source_palette,
      labels = c(
        standard_csv = "standard csv",
        export_xlsx = "export xlsx",
        fbox_csv = "fbox csv"
      )
    ) +
    scale_x_datetime(
      breaks = date_breaks(date_break_unit),
      labels = label_date("%Y-%m-%d", tz = opts$timezone),
      expand = expansion(mult = c(0.01, 0.02))
    ) +
    labs(
      title = "FL Running Record Coverage Gantt",
      subtitle = sprintf("One row per source file; label suffix shows valid row count; timezone = %s", opts$timezone),
      x = "Coverage time",
      y = NULL,
      color = "Source mode"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 10),
      axis.text.y = element_text(size = 8),
      axis.text.x = element_text(angle = 35, hjust = 1),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_blank(),
      legend.position = "top"
    )

  plot_height <- max(7, 0.42 * nrow(summary_dt) + 1.5)
  ggsave(
    filename = opts$output_file,
    plot = p,
    width = 15,
    height = plot_height,
    dpi = 200,
    bg = "white"
  )

  cat("Summary file: ", opts$summary_file, "\n", sep = "")
  cat("Output file: ", opts$output_file, "\n", sep = "")
  cat("Rows plotted: ", nrow(summary_dt), "\n", sep = "")
  cat("Time range: ", format(min(summary_dt$start_time), "%Y-%m-%d %H:%M:%OS3"), " -> ", format(max(summary_dt$end_time), "%Y-%m-%d %H:%M:%OS3"), "\n", sep = "")
}

main()
