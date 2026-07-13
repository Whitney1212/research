#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

out_root <- "E:/Dataset_Level1/Flares/EC_ecpreproc"
figure_dir <- file.path(out_root, "figures_diurnal")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)

bundle_index_csv <- "E:/FL_MASSBALANCE/202308/downstream_multicaliber/bundle_index.csv"
compare_script <- "D:/00 博士阶段/博一/05 Project/com_FLafterPF/compare/run_fl_rotation_compare_co2_20250320_0323.R"
tz_local <- "Asia/Shanghai"
source_levels <- c("oldcode_0_245", "batch_b_complete", "main_complete")
method_levels <- c("no_rotation", "dr", "PF_8bin_2ensemble")
requested_groups <- trimws(strsplit(Sys.getenv("FL_SIGMA_SOURCE_GROUPS", paste(source_levels, collapse = ",")), ",", fixed = TRUE)[[1]])
requested_groups <- requested_groups[nzchar(requested_groups)]
source_levels <- intersect(source_levels, requested_groups)
if (length(source_levels) == 0L) {
  stop("FL_SIGMA_SOURCE_GROUPS did not match any known source_group.", call. = FALSE)
}
output_tag <- Sys.getenv("FL_SIGMA_OUTPUT_TAG", "")

tag_file <- function(path, tag = output_tag) {
  if (!nzchar(tag)) return(path)
  ext <- tools::file_ext(path)
  stem <- sub(paste0("\\.", ext, "$"), "", path)
  if (!nzchar(ext)) return(paste0(path, "_", tag))
  paste0(stem, "_", tag, ".", ext)
}

sigma_csv <- tag_file(file.path(out_root, "FL_sigma_co2_raw_common_periods.csv"))
plot_data_csv <- tag_file(file.path(out_root, "FL_sigma_co2_raw_common_periods_diurnal_plot_data.csv"))
plot_png <- tag_file(file.path(figure_dir, "FL_sigma_co2_raw_common_periods_diurnal.png"))
summary_txt <- tag_file(file.path(out_root, "FL_sigma_co2_raw_common_periods_summary.txt"))

theme_regov <- function(base_size = 13) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.major = element_line(colour = "grey88", linewidth = 0.25),
      panel.grid.minor = element_blank(),
      legend.position = "none",
      strip.background = element_rect(fill = "grey94", colour = "grey80"),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold"),
      axis.text = element_text(colour = "grey20"),
      plot.caption = element_text(colour = "grey35", size = rel(0.8), hjust = 0)
    )
}

source_until_pattern <- function(path, stop_pattern) {
  if (!file.exists(path)) stop("Missing compare script: ", path, call. = FALSE)
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  hit <- grep(stop_pattern, lines)
  if (length(hit) == 0L) stop("Could not find stop pattern in compare script.", call. = FALSE)
  code <- paste(lines[seq_len(hit[1] - 1L)], collapse = "\n")
  eval(parse(text = code), envir = .GlobalEnv)
}

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(
    path,
    showProgress = FALSE,
    colClasses = list(character = c("timestamp", "date", "time", "block_start", "block_end", "sample_start", "sample_end"))
  )
}

parse_ts <- function(x) {
  as.POSIXct(x, tz = tz_local, format = "%Y-%m-%d %H:%M:%OS")
}

fmt_ts <- function(x) {
  format(x, "%Y-%m-%d %H:%M:%OS3", tz = tz_local)
}

build_common_window_keys <- function() {
  rows <- lapply(source_levels, function(source_group) {
    ts_list <- lapply(method_levels, function(method) {
      file <- file.path(out_root, source_group, "results", sprintf("FL_flux_%s.csv", method))
      unique(read_required(file)$timestamp)
    })
    common_ts <- Reduce(intersect, ts_list)
    dt <- data.table(source_group = source_group, timestamp = common_ts)
    dt[, timestamp_posix := parse_ts(timestamp)]
    setorder(dt, timestamp_posix)
    dt[]
  })
  rbindlist(rows, use.names = TRUE)
}

find_target_raw_files_full <- function(passes) {
  fl_cfg_local <- fl_pf_default_config()
  fl_cfg_local$raw_roots <- config$raw_root
  fl_cfg_local$tz_local <- config$tz
  inventory <- fl_pf_find_raw_files(fl_cfg_local, passes)
  if (nrow(inventory) == 0L) stop("No FL raw files found for pass dates.", call. = FALSE)

  inventory <- inventory[grepl("Time_Series_", file_name)]
  if (nrow(inventory) == 0L) stop("No Time_Series raw files remained after filename filtering.", call. = FALSE)

  header_keep <- vapply(inventory$file, function(path) {
    header <- tryCatch(
      {
        hdr <- fread(path, skip = 1, nrows = 1, header = FALSE, sep = ",", quote = "\"", showProgress = FALSE)
        as.character(unlist(hdr, use.names = FALSE))
      },
      error = function(e) character()
    )
    all(c("TIMESTAMP", "CO2") %in% header)
  }, logical(1))
  inventory <- inventory[header_keep]
  if (nrow(inventory) == 0L) stop("No Time_Series files with TIMESTAMP/CO2 headers remained.", call. = FALSE)
  setorder(inventory, date_token, file)
  inventory$file
}

read_fl_co2_toa5 <- function(path) {
  header <- fread(
    path,
    skip = 1,
    nrows = 1,
    header = FALSE,
    sep = ",",
    quote = "\"",
    showProgress = FALSE
  )
  header <- as.character(unlist(header, use.names = FALSE))
  required_cols <- c("TIMESTAMP", "CO2")
  missing_required <- setdiff(required_cols, header)
  if (length(missing_required) > 0L) {
    stop("Missing required TOA5 columns in ", basename(path), ": ", paste(missing_required, collapse = ", "), call. = FALSE)
  }

  keep_idx <- match(required_cols, header)
  raw <- fread(
    path,
    skip = 4,
    header = FALSE,
    sep = ",",
    quote = "\"",
    fill = TRUE,
    showProgress = FALSE,
    select = keep_idx,
    colClasses = list(character = 1),
    na.strings = c("", "NA", "NaN", "NAN", "-9999")
  )
  setnames(raw, required_cols)
  raw[, CO2 := fl_pf_to_num(CO2)]
  raw[, time := fl_pf_parse_toa5_time(TIMESTAMP, tz_local = config$tz)]
  raw[, source_file := normalizePath(path, winslash = "/", mustWork = FALSE)]
  raw[!is.na(time)]
}

subset_to_passes <- function(dt, passes, path) {
  if (nrow(dt) == 0L) return(dt)
  dt[, record_date := as.Date(time, tz = config$tz)]
  if ("source_file" %in% names(passes)) {
    pass_subset <- passes[source_file == basename(path)]
  } else {
    pass_subset <- passes[0]
  }
  if (nrow(pass_subset) == 0L && "date" %in% names(passes)) {
    pass_subset <- passes[date %in% unique(dt$record_date)]
  }
  if (nrow(pass_subset) == 0L && all(c("pass_start", "pass_end") %in% names(passes))) {
    pass_subset <- passes[as.Date(pass_start, tz = config$tz) %in% unique(dt$record_date)]
  }
  if (nrow(pass_subset) == 0L || !all(c("pass_start", "pass_end") %in% names(pass_subset))) {
    return(dt[0])
  }

  points <- dt[!is.na(time), .(row_id = .I, time, time_end = time)]
  intervals <- unique(pass_subset[, .(pass_start, pass_end)])[!is.na(pass_start) & !is.na(pass_end)]
  if (nrow(points) == 0L || nrow(intervals) == 0L) {
    return(dt[0])
  }
  setkey(intervals, pass_start, pass_end)
  overlaps <- foverlaps(points, intervals, by.x = c("time", "time_end"), by.y = c("pass_start", "pass_end"), type = "within", nomatch = 0L)
  if (nrow(overlaps) == 0L) {
    return(dt[0])
  }
  dt[sort(unique(overlaps$row_id))]
}

summarise_raw_sigma_file <- function(path, passes, key_dt, source_group) {
  dt <- read_fl_co2_toa5(path)
  if (nrow(dt) == 0L) return(data.table())
  dt <- dt[is.finite(time) & is.finite(CO2)]
  if (nrow(dt) == 0L) return(data.table())
  dt[, timestamp_posix := floor_time_interval(time, config$avg_period_sec)]
  dt[, timestamp := fmt_ts(timestamp_posix)]
  dt <- dt[timestamp %in% key_dt$timestamp]
  if (nrow(dt) == 0L) return(data.table())
  dt <- subset_to_passes(dt, passes, path)
  if (nrow(dt) == 0L) return(data.table())

  out <- dt[, .(
    n_points_co2 = .N,
    co2_mean = safe_mean(CO2),
    sigma_co2 = safe_sd(CO2)
  ), by = .(timestamp, timestamp_posix)]
  out <- out[n_points_co2 >= 10L & is.finite(sigma_co2)]
  if (nrow(out) == 0L) return(data.table())

  out[, `:=`(
    source_group = source_group,
    source_file = normalizePath(path, winslash = "/", mustWork = FALSE)
  )]
  out[]
}

build_source_group_sigma <- function(bundle_row, key_dt) {
  source_group <- bundle_row$source_group[[1]]
  if (nrow(key_dt) == 0L) return(data.table())

  fl_cfg$passes_csv <<- bundle_row$pass_csv[[1]]
  fl_cfg$tz_local <<- config$tz
  passes <- fl_pf_read_passes(fl_cfg)
  key_dates <- unique(as.Date(key_dt$timestamp_posix, tz = config$tz))
  passes <- passes[as.Date(start_time, tz = config$tz) %in% key_dates]
  if (nrow(passes) == 0L) return(data.table())
  passes[, `:=`(pass_start = start_time, pass_end = end_time)]
  raw_files <- find_target_raw_files_full(passes)

  rows <- lapply(seq_along(raw_files), function(i) {
    path <- raw_files[[i]]
    message(sprintf("[%s %d/%d] %s", source_group, i, length(raw_files), basename(path)))
    summarise_raw_sigma_file(path, passes, key_dt, source_group)
  })

  out <- rbindlist(rows, use.names = TRUE, fill = TRUE)
  if (nrow(out) == 0L) return(out)
  out <- unique(out, by = c("source_group", "timestamp"))
  setorder(out, timestamp_posix)
  out[, `:=`(
    date = format(timestamp_posix, "%Y-%m-%d", tz = config$tz),
    hhmm = format(timestamp_posix, "%H:%M", tz = config$tz),
    hour_decimal = as.integer(format(timestamp_posix, "%H", tz = config$tz)) +
      as.integer(format(timestamp_posix, "%M", tz = config$tz)) / 60
  )]
  out[]
}

build_diurnal_plot_data <- function(sigma_dt) {
  sigma_dt[, .(
    n_windows = .N,
    n_dates = uniqueN(date),
    n_source_groups = uniqueN(source_group),
    q25 = as.numeric(stats::quantile(sigma_co2, probs = 0.25, na.rm = TRUE, names = FALSE)),
    median_value = stats::median(sigma_co2, na.rm = TRUE),
    q75 = as.numeric(stats::quantile(sigma_co2, probs = 0.75, na.rm = TRUE, names = FALSE))
  ), by = .(hhmm, hour_decimal)][order(hour_decimal)]
}

plot_diurnal <- function(plot_dt) {
  p <- ggplot(plot_dt, aes(x = hour_decimal, y = median_value)) +
    geom_ribbon(aes(ymin = q25, ymax = q75), fill = "#59A14F", alpha = 0.16, colour = NA) +
    geom_line(linewidth = 0.55, colour = "#2F7D32") +
    scale_x_continuous(
      breaks = seq(0, 24, by = 3),
      limits = c(0, 23.5),
      labels = function(v) sprintf("%02d:00", as.integer(v))
    ) +
    scale_y_continuous(breaks = function(v) pretty(v, n = 10)) +
    labs(
      title = "FL common-period raw sigma_co2 diurnal pattern",
      subtitle = "Three-method common half-hours only. Line = median; ribbon = 25th-75th percentile across windows.",
      x = "Local half-hour bin",
      y = expression(sigma[CO[2]]~"(umol mol"^-1*")"),
      caption = "Source = raw FL CO2 series summarized to 30 min after pass-window clipping. Common windows are the timestamp intersection of no_rotation, dr, and PF_8bin_2ensemble outputs."
    ) +
    theme_regov(base_size = 13)
  ggsave(plot_png, p, width = 11.2, height = 6.8, dpi = 300)
}

self_check <- function(common_keys, sigma_dt, plot_dt) {
  stopifnot(nrow(common_keys) > 0L)
  stopifnot(nrow(sigma_dt) > 0L)
  stopifnot(sigma_dt[, max(.N), by = .(source_group, timestamp)]$V1 == 1L)
  stopifnot(all(is.finite(sigma_dt$sigma_co2)))
  stopifnot(all(sigma_dt$sigma_co2 >= 0))
  stopifnot(all(sigma_dt$n_points_co2 >= 10L))
  stopifnot(all(plot_dt$q25 <= plot_dt$median_value))
  stopifnot(all(plot_dt$median_value <= plot_dt$q75))
}

main <- function() {
  source_until_pattern(compare_script, "^site_meta <-")
  config$tz <<- tz_local
  config$raw_root <<- "E:/Dataset_Level0/Flares/EC"

  bundle_index <- fread(bundle_index_csv, showProgress = FALSE)[source_group %in% source_levels]
  common_keys <- build_common_window_keys()
  key_counts <- common_keys[, .(common_windows = .N), by = source_group][order(match(source_group, source_levels))]

  sigma_rows <- lapply(seq_len(nrow(bundle_index)), function(i) {
    group_id <- bundle_index$source_group[[i]]
    key_dt <- common_keys[source_group == group_id]
    build_source_group_sigma(bundle_index[i], key_dt)
  })
  sigma_dt <- rbindlist(sigma_rows, use.names = TRUE, fill = TRUE)
  setorder(sigma_dt, source_group, timestamp_posix)
  setcolorder(
    sigma_dt,
    c("source_group", "timestamp", "date", "hhmm", "hour_decimal", "n_points_co2", "co2_mean", "sigma_co2", "source_file", "timestamp_posix")
  )

  plot_dt <- build_diurnal_plot_data(sigma_dt)
  self_check(common_keys, sigma_dt, plot_dt)

  sigma_out <- copy(sigma_dt)
  sigma_out[, timestamp_posix := NULL]
  fwrite(sigma_out, sigma_csv)
  fwrite(plot_dt, plot_data_csv)
  plot_diurnal(plot_dt)

  source_summary <- sigma_out[, .(
    sigma_rows = .N,
    first_timestamp = first(timestamp),
    last_timestamp = last(timestamp),
    n_dates = uniqueN(date),
    n_hhmm = uniqueN(hhmm),
    sigma_median = stats::median(sigma_co2, na.rm = TRUE)
  ), by = source_group][order(match(source_group, source_levels))]

  writeLines(
    c(
      "FL raw sigma_co2 common-period summary",
      paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      paste0("Output root: ", out_root),
      "",
      "Outputs:",
      paste0("- ", sigma_csv),
      paste0("- ", plot_data_csv),
      paste0("- ", plot_png),
      "",
      "Notes:",
      "- Uses raw FL CO2 series only; does not recompute flux.",
      "- Common windows are the timestamp intersection of no_rotation, dr, and PF_8bin_2ensemble within each source_group.",
      "- Pass-window clipping follows the delivered FL EC runner logic.",
      "- sigma_co2 is calculated directly from raw CO2 points inside each 30 min window.",
      "",
      "Common-window counts by source_group:",
      apply(key_counts, 1, function(x) sprintf("- %s: %s", x[["source_group"]], x[["common_windows"]])),
      "",
      "Produced sigma rows by source_group:",
      apply(source_summary, 1, function(x) {
        sprintf(
          "- %s: rows=%s, first=%s, last=%s, n_dates=%s, n_hhmm=%s, median_sigma_co2=%.4f",
          x[["source_group"]], x[["sigma_rows"]], x[["first_timestamp"]], x[["last_timestamp"]],
          x[["n_dates"]], x[["n_hhmm"]], as.numeric(x[["sigma_median"]])
        )
      })
    ),
    summary_txt,
    useBytes = TRUE
  )

  message("Wrote: ", sigma_csv)
  message("Wrote: ", plot_data_csv)
  message("Wrote: ", plot_png)
}

if (sys.nframe() == 0L) {
  main()
}
