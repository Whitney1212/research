#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(scales)
})

default_input_file <- "E:/Dataset_Level0/Flares/260611_clasified/30min/fl_complete_passes_strict.csv"
default_output_file <- "E:/Dataset_Level1/Flares/PFparameter/figures/fig_fl_complete_pass_coverage_gantt.png"
default_timezone <- "Asia/Shanghai"

parse_args <- function(args) {
  opts <- list(
    input_file = default_input_file,
    output_file = default_output_file,
    timezone = default_timezone,
    title = "FL Complete Pass Coverage",
    subtitle = "",
    caption = ""
  )

  for (arg in args) {
    if (grepl("^--input-file=", arg)) {
      opts$input_file <- sub("^--input-file=", "", arg)
    } else if (grepl("^--output-file=", arg)) {
      opts$output_file <- sub("^--output-file=", "", arg)
    } else if (grepl("^--timezone=", arg)) {
      opts$timezone <- sub("^--timezone=", "", arg)
    } else if (grepl("^--title=", arg)) {
      opts$title <- sub("^--title=", "", arg)
    } else if (grepl("^--subtitle=", arg)) {
      opts$subtitle <- sub("^--subtitle=", "", arg)
    } else if (grepl("^--caption=", arg)) {
      opts$caption <- sub("^--caption=", "", arg)
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/plot_fl_complete_pass_coverage_gantt.R [options]\n",
        "  --input-file=PATH\n",
        "  --output-file=PATH\n",
        "  --timezone=Asia/Shanghai\n",
        "  --title=TEXT\n",
        "  --subtitle=TEXT\n",
        "  --caption=TEXT\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  opts
}

parse_local_time <- function(x, timezone) {
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%OS", tz = timezone)
}

hour_of_day <- function(x) {
  as.numeric(format(x, "%H")) +
    as.numeric(format(x, "%M")) / 60 +
    as.numeric(format(x, "%OS")) / 3600
}

split_passes_by_day <- function(dt, timezone) {
  pieces <- vector("list", nrow(dt))

  for (i in seq_len(nrow(dt))) {
    start_time <- dt$start_time[i]
    end_time <- dt$end_time[i]
    if (is.na(start_time) || is.na(end_time) || end_time <= start_time) {
      next
    }

    start_date <- as.Date(start_time, tz = timezone)
    end_date <- as.Date(end_time, tz = timezone)
    dates <- seq(start_date, end_date, by = "1 day")

    pieces[[i]] <- rbindlist(lapply(dates, function(day) {
      day_start <- as.POSIXct(paste(day, "00:00:00"), tz = timezone)
      day_end <- day_start + 24 * 3600
      segment_start <- max(start_time, day_start)
      segment_end <- min(end_time, day_end)

      data.table(
        pass_id = dt$pass_id[i],
        date = day,
        y_start = hour_of_day(segment_start),
        y_end = if (segment_end >= day_end) 24 else hour_of_day(segment_end),
        direction = dt$direction[i],
        moving_direction = dt$moving_direction[i]
      )
    }), fill = TRUE)
  }

  rbindlist(pieces, fill = TRUE)
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))

  if (!file.exists(opts$input_file)) {
    stop("Input file does not exist: ", opts$input_file, call. = FALSE)
  }

  dir.create(dirname(opts$output_file), recursive = TRUE, showWarnings = FALSE)

  passes <- fread(
    opts$input_file,
    encoding = "UTF-8",
    colClasses = list(
      character = c("pass_id", "start_time_local", "end_time_local", "direction", "moving_direction")
    )
  )

  required_cols <- c("pass_id", "start_time_local", "end_time_local", "direction", "moving_direction")
  missing_cols <- setdiff(required_cols, names(passes))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  passes[, start_time := parse_local_time(start_time_local, opts$timezone)]
  passes[, end_time := parse_local_time(end_time_local, opts$timezone)]
  passes <- passes[!is.na(start_time) & !is.na(end_time) & end_time > start_time]
  setorder(passes, start_time, end_time)

  plot_dt <- split_passes_by_day(passes, opts$timezone)
  plot_dt <- plot_dt[!is.na(y_start) & !is.na(y_end) & y_end > y_start]
  plot_dt[, direction_label := fifelse(direction == "fw", "fw", fifelse(direction == "bw", "bw", "other"))]

  n_days <- uniqueN(plot_dt$date)
  date_break_unit <- if (n_days > 120) "1 month" else if (n_days > 60) "2 weeks" else "1 week"

  p <- ggplot(plot_dt, aes(x = date, xend = date, y = y_start, yend = y_end, color = direction_label)) +
    geom_segment(linewidth = 3.2, lineend = "butt", alpha = 0.86) +
    scale_color_manual(
      values = c(fw = "#2C7FB8", bw = "#F28E2B", other = "#7A7A7A"),
      breaks = c("fw", "bw", "other"),
      drop = TRUE
    ) +
    scale_x_date(
      breaks = date_breaks(date_break_unit),
      labels = date_format("%Y-%m-%d"),
      expand = expansion(mult = c(0.01, 0.01))
    ) +
    scale_y_continuous(
      limits = c(0, 24),
      breaks = seq(0, 24, by = 2),
      minor_breaks = seq(0, 24, by = 1),
      labels = function(x) sprintf("%02d:00", as.integer(x)),
      expand = expansion(mult = c(0, 0))
    ) +
    labs(
      title = opts$title,
      subtitle = if (nzchar(opts$subtitle)) opts$subtitle else NULL,
      x = "Date",
      y = "Time of day",
      color = "Direction",
      caption = if (nzchar(opts$caption)) opts$caption else NULL
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 10.5, color = "#333333"),
      plot.caption = element_text(size = 9, color = "#555555", hjust = 0),
      axis.text.x = element_text(angle = 35, hjust = 1),
      panel.grid.major.x = element_line(linewidth = 0.25, color = "#D9D9D9"),
      panel.grid.major.y = element_line(linewidth = 0.25, color = "#D9D9D9"),
      panel.grid.minor.y = element_line(linewidth = 0.15, color = "#EFEFEF"),
      panel.grid.minor.x = element_blank(),
      legend.position = "top"
    )

  ggsave(
    filename = opts$output_file,
    plot = p,
    width = 16,
    height = 8,
    dpi = 220,
    bg = "white"
  )

  cat("Input rows: ", nrow(passes), "\n", sep = "")
  cat("Plotted segments: ", nrow(plot_dt), "\n", sep = "")
  cat("Date range: ", as.character(min(plot_dt$date)), " -> ", as.character(max(plot_dt$date)), "\n", sep = "")
  cat("Output file: ", opts$output_file, "\n", sep = "")
}

main()
