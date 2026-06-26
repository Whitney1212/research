#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(readxl)
})

get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 0L) return(normalizePath(getwd(), winslash = "/", mustWork = TRUE))
  dirname(normalizePath(sub("^--file=", "", hit[1]), winslash = "/", mustWork = TRUE))
}

parse_args <- function(args) {
  script_dir <- get_script_dir()
  input_dir <- "E:/Dataset_RAW/Flares/运行记录/unified_output"
  output_dir <- "E:/Dataset_Level0/Flares/running_time"
  date_token <- format(Sys.Date(), "%Y%m%d")
  output_base <- paste0("all_data_", date_token)
  opts <- list(
    existing_unified = file.path(input_dir, "fl_running_records_unified.csv"),
    existing_summary = file.path(input_dir, "fl_running_records_file_summary.csv"),
    new_input_dir = NA_character_,
    new_files = character(),
    output_unified = file.path(output_dir, paste0(output_base, ".csv")),
    output_summary = file.path(output_dir, paste0(output_base, "_file_summary.csv")),
    output_gantt = NA_character_,
    plot_script = file.path(script_dir, "plot_fl_running_gantt.R"),
    timezone = "Asia/Shanghai",
    dedupe_by = "full_row",
    compress_stationary_stops = TRUE,
    stationary_position_tolerance_m = 0.001,
    min_stationary_duration_min = 15,
    min_stationary_points = 300
  )

  for (arg in args) {
    if (grepl("^--existing-unified=", arg)) {
      opts$existing_unified <- sub("^--existing-unified=", "", arg)
    } else if (grepl("^--existing-summary=", arg)) {
      opts$existing_summary <- sub("^--existing-summary=", "", arg)
    } else if (grepl("^--new-input-dir=", arg)) {
      opts$new_input_dir <- sub("^--new-input-dir=", "", arg)
    } else if (grepl("^--new-file=", arg)) {
      opts$new_files <- c(opts$new_files, sub("^--new-file=", "", arg))
    } else if (grepl("^--output-unified=", arg)) {
      opts$output_unified <- sub("^--output-unified=", "", arg)
    } else if (grepl("^--output-summary=", arg)) {
      opts$output_summary <- sub("^--output-summary=", "", arg)
    } else if (grepl("^--output-gantt=", arg)) {
      opts$output_gantt <- sub("^--output-gantt=", "", arg)
      if (!nzchar(opts$output_gantt)) opts$output_gantt <- NA_character_
    } else if (grepl("^--plot-script=", arg)) {
      opts$plot_script <- sub("^--plot-script=", "", arg)
    } else if (grepl("^--timezone=", arg)) {
      opts$timezone <- sub("^--timezone=", "", arg)
    } else if (grepl("^--dedupe-by=", arg)) {
      opts$dedupe_by <- sub("^--dedupe-by=", "", arg)
    } else if (arg == "--compress-stationary-stops") {
      opts$compress_stationary_stops <- TRUE
    } else if (arg == "--no-compress-stationary-stops") {
      opts$compress_stationary_stops <- FALSE
    } else if (grepl("^--stationary-position-tolerance-m=", arg)) {
      opts$stationary_position_tolerance_m <- as.numeric(sub("^--stationary-position-tolerance-m=", "", arg))
    } else if (grepl("^--min-stationary-duration-min=", arg)) {
      opts$min_stationary_duration_min <- as.numeric(sub("^--min-stationary-duration-min=", "", arg))
    } else if (grepl("^--min-stationary-points=", arg)) {
      opts$min_stationary_points <- as.integer(sub("^--min-stationary-points=", "", arg))
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/update_fl_running_records_incremental.R --new-input-dir=PATH [options]\n",
        "  --existing-unified=PATH\n",
        "  --existing-summary=PATH\n",
        "  --new-input-dir=PATH       directory containing only the new source files\n",
        "  --new-file=PATH            one new source file; repeat for multiple files\n",
        "  --output-unified=PATH      pending unified CSV; never defaults to the formal file\n",
        "  --output-summary=PATH      pending source registry CSV\n",
        "  --output-gantt=PATH        optional; omitted by default\n",
        "  --plot-script=PATH\n",
        "  --timezone=Asia/Shanghai\n",
        "  --dedupe-by=full_row|time\n",
        "  --compress-stationary-stops      default; compress long unchanged-position stops in new files\n",
        "  --no-compress-stationary-stops   disable stationary-stop compression\n",
        "  --stationary-position-tolerance-m=0.001\n",
        "  --min-stationary-duration-min=15\n",
        "  --min-stationary-points=300\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  has_dir <- !is.na(opts$new_input_dir) && nzchar(opts$new_input_dir)
  if (!has_dir && length(opts$new_files) == 0L) {
    stop("Provide --new-input-dir or at least one --new-file.", call. = FALSE)
  }
  if (!opts$dedupe_by %in% c("full_row", "time")) {
    stop("--dedupe-by must be 'full_row' or 'time'.", call. = FALSE)
  }
  if (!is.finite(opts$stationary_position_tolerance_m) || opts$stationary_position_tolerance_m < 0) {
    stop("--stationary-position-tolerance-m must be a non-negative number.", call. = FALSE)
  }
  if (!is.finite(opts$min_stationary_duration_min) || opts$min_stationary_duration_min <= 0) {
    stop("--min-stationary-duration-min must be positive.", call. = FALSE)
  }
  if (is.na(opts$min_stationary_points) || opts$min_stationary_points <= 0L) {
    stop("--min-stationary-points must be a positive integer.", call. = FALSE)
  }
  formal <- normalizePath(opts$existing_unified, winslash = "/", mustWork = FALSE)
  pending <- normalizePath(opts$output_unified, winslash = "/", mustWork = FALSE)
  if (identical(tolower(formal), tolower(pending))) {
    stop("Pending output must not overwrite --existing-unified.", call. = FALSE)
  }
  opts
}

coerce_time <- function(x, timezone) {
  if (inherits(x, "POSIXt")) {
    local_clock <- format(x, "%Y-%m-%d %H:%M:%OS6")
    return(as.POSIXct(local_clock, format = "%Y-%m-%d %H:%M:%OS", tz = timezone))
  }
  if (inherits(x, "Date")) {
    return(as.POSIXct(format(x, "%Y-%m-%d"), format = "%Y-%m-%d", tz = timezone))
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
    if (!any(idx)) break
    out[idx] <- as.POSIXct(strptime(chr[idx], format = fmt, tz = timezone))
  }
  out
}

format_time <- function(x, timezone) {
  format(x, "%Y-%m-%d %H:%M:%OS3", tz = timezone)
}

detect_mode <- function(filename) {
  lower_name <- tolower(filename)
  if (grepl("^fbox_hdata_.*[.]csv$", lower_name, perl = TRUE)) return("fbox_csv")
  if (grepl("[.]xlsx$", lower_name, perl = TRUE)) return("export_xlsx")
  if (grepl("[.]csv$", lower_name, perl = TRUE)) return("standard_csv")
  NA_character_
}

read_fbox_csv <- function(path, timezone) {
  dt <- fread(path, skip = 1, na.strings = c("", "NA"), showProgress = FALSE)
  position_col <- "小车位置(m)"
  speed_col <- "小车运行速度(cm/s)"
  missing <- setdiff(c(position_col, speed_col), names(dt))
  if (length(missing) > 0L) {
    stop("Missing required FBOX columns in ", basename(path), ": ", paste(missing, collapse = ", "), call. = FALSE)
  }
  time_col <- names(dt)[1]
  dt[, .(
    time = coerce_time(get(time_col), timezone),
    speed = suppressWarnings(as.numeric(get(speed_col))),
    position = suppressWarnings(as.numeric(get(position_col)))
  )]
}

read_export_xlsx <- function(path, timezone) {
  tb <- read_excel(path, sheet = 1, skip = 2, col_names = c("time", "speed", "position"))
  dt <- as.data.table(tb)
  dt[, .(
    time = coerce_time(time, timezone),
    speed = suppressWarnings(as.numeric(speed)),
    position = suppressWarnings(as.numeric(position))
  )]
}

read_standard_csv <- function(path, timezone) {
  dt <- fread(path, na.strings = c("", "NA"), showProgress = FALSE)
  if (ncol(dt) < 2L) stop("Expected at least 2 columns in ", basename(path), call. = FALSE)
  safe_names <- iconv(names(dt), from = "", to = "UTF-8", sub = "byte")
  lower_names <- tolower(safe_names)
  if (ncol(dt) == 2L && lower_names[1] == "mcgs_time") {
    time_value <- coerce_time(dt[[1]], timezone)
    position_value <- suppressWarnings(as.numeric(dt[[2]]))
    position_delta <- c(NA_real_, diff(position_value))
    direction_sign <- sign(position_delta)
    direction_sign[!is.finite(direction_sign)] <- 0
    return(data.table(
      time = time_value,
      speed = 13.7 * direction_sign,
      position = position_value
    ))
  }
  if (ncol(dt) < 3L) stop("Expected at least 3 columns in ", basename(path), call. = FALSE)
  time_idx <- match("time", lower_names)
  speed_idx <- match("speed", lower_names)
  position_idx <- match("position", lower_names)
  if (is.na(position_idx)) position_idx <- match("location", lower_names)
  if (is.na(time_idx)) time_idx <- 1L
  if (is.na(speed_idx)) speed_idx <- 2L
  if (is.na(position_idx)) position_idx <- 3L
  dt[, .(
    time = coerce_time(.SD[[1]], timezone),
    speed = suppressWarnings(as.numeric(.SD[[2]])),
    position = suppressWarnings(as.numeric(.SD[[3]]))
  ), .SDcols = c(time_idx, speed_idx, position_idx)]
}

read_one_file <- function(path, timezone) {
  mode <- detect_mode(basename(path))
  if (is.na(mode)) return(NULL)
  dt <- switch(
    mode,
    fbox_csv = read_fbox_csv(path, timezone),
    export_xlsx = read_export_xlsx(path, timezone),
    standard_csv = read_standard_csv(path, timezone)
  )
  dt[, `:=`(source_file = basename(path), source_mode = mode)]
  dt
}

read_existing_unified <- function(path, timezone) {
  dt <- fread(
    path,
    select = c("time", "speed", "position"),
    colClasses = list(character = "time"),
    showProgress = TRUE
  )
  dt[, `:=`(
    time_text = time,
    time = coerce_time(time, timezone),
    speed = suppressWarnings(as.numeric(speed)),
    position = suppressWarnings(as.numeric(position))
  )]
  dt[!is.na(time) & is.finite(speed) & is.finite(position)]
}

compress_stationary_stops <- function(dt, opts) {
  empty_summary <- data.table(
    rows_after_stationary_compression = nrow(dt),
    stationary_rows_removed = 0L,
    stationary_stop_segments = 0L,
    stationary_stop_duration_min = 0
  )
  if (!isTRUE(opts$compress_stationary_stops) || nrow(dt) < 2L) {
    return(list(data = dt, summary = empty_summary))
  }

  setorder(dt, time)
  pos_delta <- c(Inf, abs(diff(dt$position)))
  run_id <- cumsum(!is.finite(pos_delta) | pos_delta > opts$stationary_position_tolerance_m)
  dt[, stationary_run_id := run_id]
  run_summary <- dt[, .(
    run_start = min(time),
    run_end = max(time),
    n_points = .N,
    position_range = max(position, na.rm = TRUE) - min(position, na.rm = TRUE)
  ), by = stationary_run_id]
  run_summary[, duration_min := as.numeric(difftime(run_end, run_start, units = "mins"))]
  run_summary[, long_stop :=
    duration_min >= opts$min_stationary_duration_min &
      n_points >= opts$min_stationary_points &
      position_range <= opts$stationary_position_tolerance_m]

  long_ids <- run_summary[long_stop == TRUE, stationary_run_id]
  if (length(long_ids) == 0L) {
    dt[, stationary_run_id := NULL]
    return(list(data = dt, summary = empty_summary))
  }

  dt[, row_in_stationary_run := seq_len(.N), by = stationary_run_id]
  dt[, rows_in_stationary_run := .N, by = stationary_run_id]
  keep <- !dt$stationary_run_id %in% long_ids |
    dt$row_in_stationary_run == 1L |
    dt$row_in_stationary_run == dt$rows_in_stationary_run
  out <- dt[keep]
  out[, c("stationary_run_id", "row_in_stationary_run", "rows_in_stationary_run") := NULL]

  removed <- nrow(dt) - nrow(out)
  summary <- data.table(
    rows_after_stationary_compression = nrow(out),
    stationary_rows_removed = removed,
    stationary_stop_segments = length(long_ids),
    stationary_stop_duration_min = sum(run_summary[long_stop == TRUE, duration_min], na.rm = TRUE)
  )
  list(data = out, summary = summary)
}

collect_new_paths <- function(opts) {
  paths <- opts$new_files
  if (!is.na(opts$new_input_dir) && nzchar(opts$new_input_dir)) {
    if (!dir.exists(opts$new_input_dir)) stop("Missing new input directory: ", opts$new_input_dir, call. = FALSE)
    dir_paths <- list.files(opts$new_input_dir, full.names = TRUE)
    paths <- c(paths, dir_paths[file.info(dir_paths)$isdir %in% FALSE])
  }
  missing <- paths[!file.exists(paths)]
  if (length(missing) > 0L) stop("Missing new source file: ", paste(missing, collapse = "; "), call. = FALSE)
  paths <- sort(unique(normalizePath(paths, winslash = "/", mustWork = TRUE)))
  modes <- vapply(basename(paths), detect_mode, character(1))
  paths <- paths[!is.na(modes)]
  if (length(paths) == 0L) stop("No supported new running-record files were provided.", call. = FALSE)
  paths
}

read_new_batch <- function(paths, opts) {

  data_parts <- vector("list", length(paths))
  summaries <- vector("list", length(paths))
  for (i in seq_along(paths)) {
    dt <- read_one_file(paths[i], opts$timezone)
    valid <- dt[!is.na(time) & is.finite(speed) & is.finite(position)]
    compressed <- compress_stationary_stops(valid, opts)
    valid_compressed <- compressed$data
    summaries[[i]] <- data.table(
      source_file = basename(paths[i]),
      source_mode = unique(dt$source_mode)[1],
      rows_read = nrow(dt),
      rows_valid = nrow(valid),
      compressed$summary,
      stationary_compression_enabled = isTRUE(opts$compress_stationary_stops),
      stationary_position_tolerance_m = opts$stationary_position_tolerance_m,
      min_stationary_duration_min = opts$min_stationary_duration_min,
      min_stationary_points = opts$min_stationary_points,
      stationary_note = "Early 2023 test-period files can be about 3 s per point; later files are expected to be higher frequency, so min_stationary_points is auxiliary to duration.",
      time_min = if (nrow(valid) > 0L) format_time(min(valid$time), opts$timezone) else NA_character_,
      time_max = if (nrow(valid) > 0L) format_time(max(valid$time), opts$timezone) else NA_character_
    )
    valid_compressed[, time_text := format_time(time, opts$timezone)]
    data_parts[[i]] <- valid_compressed[, .(time, time_text, speed, position, source_file, source_mode)]
  }
  list(
    data = rbindlist(data_parts, use.names = TRUE, fill = FALSE),
    summary = rbindlist(summaries, use.names = TRUE, fill = FALSE)
  )
}

merge_records <- function(existing, new_data, dedupe_by) {
  key_cols <- if (dedupe_by == "time") "time" else c("time", "speed", "position")
  new_unique <- unique(copy(new_data), by = key_cols)
  existing_keys <- unique(existing[, ..key_cols], by = key_cols)
  new_add <- new_unique[!existing_keys, on = key_cols]
  merged <- rbindlist(
    list(
      existing[, .(time, time_text, speed, position)],
      new_add[, .(time, time_text, speed, position)]
    ),
    use.names = TRUE
  )
  setorder(merged, time, speed, position)
  list(data = merged, new_unique = nrow(new_unique), new_added = nrow(new_add))
}

merge_summaries <- function(existing_path, new_summary) {
  existing <- fread(
    existing_path,
    colClasses = list(character = c("source_file", "source_mode", "time_min", "time_max")),
    showProgress = FALSE
  )
  existing[, source_rank := 1L]
  incoming <- copy(new_summary)
  incoming[, source_rank := 2L]
  merged <- rbindlist(list(existing, incoming), use.names = TRUE, fill = TRUE)
  setorder(merged, source_file, source_mode, source_rank)
  merged <- unique(merged, by = c("source_file", "source_mode"), fromLast = TRUE)
  merged[, source_rank := NULL]
  setorder(merged, time_min, source_file)
  merged
}

run_plot <- function(opts) {
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  plot_input_dir <- if (!is.na(opts$new_input_dir) && nzchar(opts$new_input_dir)) {
    opts$new_input_dir
  } else {
    dirname(opts$new_files[1])
  }
  args <- c(
    shQuote(opts$plot_script),
    shQuote(paste0("--input-dir=", plot_input_dir)),
    shQuote(paste0("--summary-file=", opts$output_summary)),
    shQuote(paste0("--output-file=", opts$output_gantt)),
    shQuote(paste0("--timezone=", opts$timezone))
  )
  output <- system2(rscript, args, stdout = TRUE, stderr = TRUE)
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  if (status != 0L) {
    stop("Pending Gantt command failed:\n", paste(output, collapse = "\n"), call. = FALSE)
  }
  output
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  gantt_enabled <- !is.na(opts$output_gantt) && nzchar(opts$output_gantt)
  required_files <- c(opts$existing_unified, opts$existing_summary)
  if (gantt_enabled) required_files <- c(required_files, opts$plot_script)
  missing <- required_files[!file.exists(required_files)]
  if (length(missing) > 0L) stop("Missing input: ", paste(missing, collapse = "; "), call. = FALSE)
  new_paths <- collect_new_paths(opts)

  output_paths <- c(opts$output_unified, opts$output_summary)
  if (gantt_enabled) output_paths <- c(output_paths, opts$output_gantt)
  for (path in output_paths) {
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  }

  message("Reading existing unified running records")
  existing <- read_existing_unified(opts$existing_unified, opts$timezone)
  message("Reading only the new running-record source files")
  incoming <- read_new_batch(new_paths, opts)
  merged <- merge_records(existing, incoming$data, opts$dedupe_by)
  summary_pending <- merge_summaries(opts$existing_summary, incoming$summary)

  output <- merged$data[, .(
    time = time_text,
    speed,
    position
  )]
  fwrite(output, opts$output_unified)
  fwrite(summary_pending, opts$output_summary)
  if (gantt_enabled) {
    run_plot(opts)
    if (!file.exists(opts$output_gantt) || file.info(opts$output_gantt)$size <= 1000) {
      stop("Pending running-record Gantt validation failed.", call. = FALSE)
    }
  }

  cat("Incremental running-record pending build complete.\n")
  cat("Existing rows: ", nrow(existing), "\n", sep = "")
  cat("New valid rows: ", nrow(incoming$data), "\n", sep = "")
  cat("New rows added: ", merged$new_added, "\n", sep = "")
  cat("Pending rows: ", nrow(output), "\n", sep = "")
  cat("Pending unified: ", opts$output_unified, "\n", sep = "")
  if (gantt_enabled) cat("Pending Gantt: ", opts$output_gantt, "\n", sep = "")
}

main()
