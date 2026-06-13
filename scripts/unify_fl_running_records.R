#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(readxl)
})

default_input_dir <- file.path("E:/Dataset_RAW/Flares", "\u8fd0\u884c\u8bb0\u5f55")
default_output_dir <- file.path(default_input_dir, "unified_output")
default_output_file <- file.path(default_output_dir, "fl_running_records_unified.csv")
default_summary_file <- file.path(default_output_dir, "fl_running_records_file_summary.csv")
default_timezone <- "Asia/Shanghai"

parse_args <- function(args) {
  opts <- list(
    input_dir = default_input_dir,
    output_file = default_output_file,
    summary_file = default_summary_file,
    timezone = default_timezone,
    dedupe_by = "full_row"
  )

  for (arg in args) {
    if (grepl("^--input-dir=", arg)) {
      opts$input_dir <- sub("^--input-dir=", "", arg)
    } else if (grepl("^--output-file=", arg)) {
      opts$output_file <- sub("^--output-file=", "", arg)
    } else if (grepl("^--summary-file=", arg)) {
      opts$summary_file <- sub("^--summary-file=", "", arg)
    } else if (grepl("^--timezone=", arg)) {
      opts$timezone <- sub("^--timezone=", "", arg)
    } else if (grepl("^--dedupe-by=", arg)) {
      opts$dedupe_by <- sub("^--dedupe-by=", "", arg)
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/unify_fl_running_records.R [options]\n",
        "  --input-dir=PATH\n",
        "  --output-file=PATH\n",
        "  --summary-file=PATH\n",
        "  --timezone=Asia/Shanghai\n",
        "  --dedupe-by=full_row|time\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  if (!opts$dedupe_by %in% c("full_row", "time")) {
    stop("--dedupe-by must be 'full_row' or 'time'.", call. = FALSE)
  }

  opts
}

coerce_time <- function(x, timezone) {
  if (inherits(x, "POSIXt")) {
    local_clock <- format(x, "%Y-%m-%d %H:%M:%OS6")
    return(as.POSIXct(local_clock, format = "%Y-%m-%d %H:%M:%OS", tz = timezone))
  }

  if (inherits(x, "Date")) {
    local_clock <- format(x, "%Y-%m-%d")
    return(as.POSIXct(local_clock, format = "%Y-%m-%d", tz = timezone))
  }

  if (is.numeric(x)) {
    return(as.POSIXct(x * 86400, origin = "1899-12-30", tz = timezone))
  }

  chr <- trimws(as.character(x))
  chr[chr == ""] <- NA_character_

  out <- as.POSIXct(rep(NA_real_, length(chr)), origin = "1970-01-01", tz = timezone)
  formats <- c(
    "%Y-%m-%d %H:%M:%OS",
    "%Y-%m-%dT%H:%M:%OS",
    "%Y/%m/%d %H:%M:%OS",
    "%Y-%m-%d %H:%M:%S",
    "%Y-%m-%dT%H:%M:%S",
    "%Y/%m/%d %H:%M:%S",
    "%Y-%m-%d"
  )

  for (fmt in formats) {
    idx <- is.na(out) & !is.na(chr)
    if (!any(idx)) {
      break
    }
    parsed <- as.POSIXct(strptime(chr[idx], format = fmt, tz = timezone))
    out[idx] <- parsed
  }

  out
}

format_time <- function(x, timezone) {
  format(x, "%Y-%m-%d %H:%M:%OS3", tz = timezone)
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

read_fbox_csv <- function(path, timezone) {
  dt <- fread(path, skip = 1, na.strings = c("", "NA"))
  required_cols <- c("\u5c0f\u8f66\u4f4d\u7f6e(m)", "\u5c0f\u8f66\u8fd0\u884c\u901f\u5ea6(cm/s)")

  missing_cols <- setdiff(required_cols, names(dt))
  if (length(missing_cols) > 0) {
    stop("Missing required fbox columns in ", basename(path), ": ", paste(missing_cols, collapse = ", "))
  }

  time_col <- names(dt)[1]
  out <- dt[, .(
    time = coerce_time(get(time_col), timezone),
    speed = as.numeric(get("\u5c0f\u8f66\u8fd0\u884c\u901f\u5ea6(cm/s)")),
    position = as.numeric(get("\u5c0f\u8f66\u4f4d\u7f6e(m)"))
  )]

  out
}

read_export_xlsx <- function(path, timezone) {
  tb <- read_excel(
    path,
    sheet = 1,
    skip = 2,
    col_names = c("time", "speed", "position")
  )

  dt <- as.data.table(tb)
  dt[, time := coerce_time(time, timezone)]
  dt[, speed := as.numeric(speed)]
  dt[, position := as.numeric(position)]
  dt[, .(time, speed, position)]
}

read_standard_csv <- function(path, timezone) {
  dt <- fread(path, na.strings = c("", "NA"))
  if (ncol(dt) < 3) {
    stop("Expected at least 3 columns in ", basename(path))
  }

  lower_names <- tolower(names(dt))
  time_idx <- match("time", lower_names)
  speed_idx <- match("speed", lower_names)
  position_idx <- match("position", lower_names)

  if (is.na(position_idx)) {
    position_idx <- match("location", lower_names)
  }

  if (is.na(time_idx)) {
    time_idx <- 1L
  }
  if (is.na(speed_idx)) {
    speed_idx <- 2L
  }
  if (is.na(position_idx)) {
    position_idx <- 3L
  }

  out <- dt[, .(
    time = coerce_time(.SD[[1]], timezone),
    speed = as.numeric(.SD[[2]]),
    position = as.numeric(.SD[[3]])
  ), .SDcols = c(time_idx, speed_idx, position_idx)]

  out
}

read_one_file <- function(path, timezone) {
  mode <- detect_mode(basename(path))

  if (is.na(mode)) {
    return(NULL)
  }

  if (mode == "fbox_csv") {
    dt <- read_fbox_csv(path, timezone)
  } else if (mode == "export_xlsx") {
    dt <- read_export_xlsx(path, timezone)
  } else if (mode == "standard_csv") {
    dt <- read_standard_csv(path, timezone)
  } else {
    stop("Unsupported mode for ", basename(path))
  }

  dt[, source_file := basename(path)]
  dt[, source_mode := mode]
  dt
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))

  if (!dir.exists(opts$input_dir)) {
    stop("Input directory does not exist: ", opts$input_dir)
  }

  dir.create(dirname(opts$output_file), recursive = TRUE, showWarnings = FALSE)
  dir.create(dirname(opts$summary_file), recursive = TRUE, showWarnings = FALSE)

  paths <- list.files(opts$input_dir, full.names = TRUE)
  paths <- paths[file.info(paths)$isdir %in% FALSE]
  paths <- sort(paths)

  data_list <- vector("list", length(paths))
  summary_list <- vector("list", length(paths))
  kept <- 0L

  for (path in paths) {
    filename <- basename(path)
    mode <- detect_mode(filename)
    if (is.na(mode)) {
      next
    }

    kept <- kept + 1L
    dt <- read_one_file(path, opts$timezone)
    valid_rows <- dt[!is.na(time) & !is.na(speed) & !is.na(position)]

    summary_list[[kept]] <- data.table(
      source_file = filename,
      source_mode = mode,
      rows_read = nrow(dt),
      rows_valid = nrow(valid_rows),
      time_min = if (nrow(valid_rows) > 0) format_time(min(valid_rows$time), opts$timezone) else NA_character_,
      time_max = if (nrow(valid_rows) > 0) format_time(max(valid_rows$time), opts$timezone) else NA_character_
    )

    data_list[[kept]] <- valid_rows
  }

  data_list <- data_list[seq_len(kept)]
  summary_list <- summary_list[seq_len(kept)]

  if (length(data_list) == 0) {
    stop("No supported files found in ", opts$input_dir)
  }

  combined <- rbindlist(data_list, use.names = TRUE, fill = FALSE)
  summary_dt <- rbindlist(summary_list, use.names = TRUE, fill = FALSE)

  total_rows_before <- nrow(combined)

  if (opts$dedupe_by == "time") {
    setorder(combined, time, source_file, source_mode)
    unique_dt <- unique(combined, by = "time")
  } else {
    setorder(combined, time, speed, position, source_file, source_mode)
    unique_dt <- unique(combined, by = c("time", "speed", "position"))
  }

  total_rows_after <- nrow(unique_dt)
  total_duplicates_removed <- total_rows_before - total_rows_after

  setorder(unique_dt, time, speed, position)
  output_dt <- unique_dt[, .(
    time = format_time(time, opts$timezone),
    speed,
    position
  )]

  fwrite(output_dt, opts$output_file)
  fwrite(summary_dt, opts$summary_file)

  cat("Input directory: ", opts$input_dir, "\n", sep = "")
  cat("Files processed: ", nrow(summary_dt), "\n", sep = "")
  cat("Rows before dedupe: ", total_rows_before, "\n", sep = "")
  cat("Rows after dedupe: ", total_rows_after, "\n", sep = "")
  cat("Duplicates removed: ", total_duplicates_removed, "\n", sep = "")
  cat("Dedupe rule: ", opts$dedupe_by, "\n", sep = "")
  cat("Output file: ", opts$output_file, "\n", sep = "")
  cat("Summary file: ", opts$summary_file, "\n", sep = "")
  cat("Time range: ", output_dt$time[1], " -> ", output_dt$time[nrow(output_dt)], "\n", sep = "")
}

main()
