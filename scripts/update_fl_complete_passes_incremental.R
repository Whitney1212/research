#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

get_script_dir <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  hit <- grep("^--file=", args, value = TRUE)
  if (length(hit) == 0L) return(normalizePath(getwd(), winslash = "/", mustWork = TRUE))
  dirname(normalizePath(sub("^--file=", "", hit[1]), winslash = "/", mustWork = TRUE))
}

parse_args <- function(args) {
  script_dir <- get_script_dir()
  opts <- list(
    unified_csv = "E:/Dataset_RAW/Flares/运行记录/unified_output/fl_running_records_unified.csv",
    strict_script = "E:/Dataset_RAW/Flares/运行记录/unified_output/02_mark_complete_passes_strict.R",
    plot_script = file.path(script_dir, "plot_fl_complete_pass_coverage_gantt.R"),
    master_dir = "E:/Dataset_Level0/Flares/260611_clasified/30min",
    raw_root = "E:/Dataset_Level0/Flares/EC",
    raw_index_csv = "",
    start = NA_character_,
    end = NA_character_,
    lookback_hours = 2,
    track_south_m = 5,
    track_north_m = 240,
    timezone = "Asia/Shanghai",
    plot_title = "FL Complete Pass Coverage",
    plot_subtitle = "",
    plot_caption = "",
    keep_running_subset = FALSE
  )

  for (arg in args) {
    if (grepl("^--unified-csv=", arg)) {
      opts$unified_csv <- sub("^--unified-csv=", "", arg)
    } else if (grepl("^--strict-script=", arg)) {
      opts$strict_script <- sub("^--strict-script=", "", arg)
    } else if (grepl("^--plot-script=", arg)) {
      opts$plot_script <- sub("^--plot-script=", "", arg)
    } else if (grepl("^--master-dir=", arg)) {
      opts$master_dir <- sub("^--master-dir=", "", arg)
    } else if (grepl("^--raw-root=", arg)) {
      opts$raw_root <- sub("^--raw-root=", "", arg)
    } else if (grepl("^--raw-index-csv=", arg)) {
      opts$raw_index_csv <- sub("^--raw-index-csv=", "", arg)
    } else if (grepl("^--start=", arg)) {
      opts$start <- sub("^--start=", "", arg)
    } else if (grepl("^--end=", arg)) {
      opts$end <- sub("^--end=", "", arg)
    } else if (grepl("^--lookback-hours=", arg)) {
      opts$lookback_hours <- as.numeric(sub("^--lookback-hours=", "", arg))
    } else if (grepl("^--track-south-m=", arg)) {
      opts$track_south_m <- as.numeric(sub("^--track-south-m=", "", arg))
    } else if (grepl("^--track-north-m=", arg)) {
      opts$track_north_m <- as.numeric(sub("^--track-north-m=", "", arg))
    } else if (grepl("^--timezone=", arg)) {
      opts$timezone <- sub("^--timezone=", "", arg)
    } else if (grepl("^--plot-title=", arg)) {
      opts$plot_title <- sub("^--plot-title=", "", arg)
    } else if (grepl("^--plot-subtitle=", arg)) {
      opts$plot_subtitle <- sub("^--plot-subtitle=", "", arg)
    } else if (grepl("^--plot-caption=", arg)) {
      opts$plot_caption <- sub("^--plot-caption=", "", arg)
    } else if (arg == "--keep-running-subset") {
      opts$keep_running_subset <- TRUE
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/update_fl_complete_passes_incremental.R --start=TIME [options]\n",
        "  --start='YYYY-MM-DD HH:MM:SS'   first time that may contain new or changed data\n",
        "  --end='YYYY-MM-DD HH:MM:SS'     optional last affected time\n",
        "  --lookback-hours=2              boundary overlap used for pass reconstruction\n",
        "  --unified-csv=PATH\n",
        "  --strict-script=PATH\n",
        "  --plot-script=PATH\n",
        "  --master-dir=PATH\n",
        "  --raw-root=PATH\n",
        "  --raw-index-csv=PATH        optional prebuilt EC file index\n",
        "  --track-south-m=5\n",
        "  --track-north-m=240\n",
        "  --plot-title=TEXT\n",
        "  --plot-subtitle=TEXT\n",
        "  --plot-caption=TEXT\n",
        "  --keep-running-subset\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  if (is.na(opts$start) || !nzchar(opts$start)) {
    stop("--start is required.", call. = FALSE)
  }
  if (!is.finite(opts$lookback_hours) || opts$lookback_hours <= 0) {
    stop("--lookback-hours must be positive.", call. = FALSE)
  }
  if (!is.finite(opts$track_south_m) || !is.finite(opts$track_north_m) ||
      opts$track_north_m <= opts$track_south_m) {
    stop("Track bounds are invalid.", call. = FALSE)
  }
  opts
}

read_raw_index <- function(path) {
  if (!file.exists(path)) stop("Missing raw index CSV: ", path, call. = FALSE)
  index <- fread(path, colClasses = list(character = c("raw_root", "file", "file_name", "date_token")), showProgress = FALSE)
  required <- c("raw_root", "file", "file_name", "date_token")
  missing <- setdiff(required, names(index))
  if (length(missing) > 0L) {
    stop("Raw index CSV missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  unique(index[, ..required])
}

parse_local <- function(x, tz) {
  x <- trimws(as.character(x))
  x <- sub("T", " ", x, fixed = TRUE)
  out <- as.POSIXct(x, format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  miss <- is.na(out)
  if (any(miss)) out[miss] <- as.POSIXct(x[miss], format = "%Y/%m/%d %H:%M:%OS", tz = tz)
  out
}

format_local <- function(x, tz) {
  format(x, "%Y-%m-%d %H:%M:%OS3", tz = tz)
}

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing required file: ", path, call. = FALSE)
  header <- names(fread(path, nrows = 0L, showProgress = FALSE))
  char_cols <- intersect(c("start_time_local", "end_time_local", "time"), header)
  classes <- if (length(char_cols) == 0L) NULL else list(character = char_cols)
  fread(path, colClasses = classes, showProgress = FALSE)
}

extract_date_token <- function(path) {
  name <- basename(path)
  match <- regexpr("[0-9]{4}_[0-9]{2}_[0-9]{2}", name, perl = TRUE)
  out <- rep(NA_character_, length(name))
  found <- match > 0L
  out[found] <- regmatches(name, match)
  out
}

read_last_nonempty_line <- function(path, tail_bytes = 65536L) {
  size <- file.info(path)$size
  if (!is.finite(size) || size <= 0) return(NA_character_)
  start <- max(0, size - tail_bytes)
  con <- file(path, open = "rb")
  on.exit(close(con), add = TRUE)
  seek(con, where = start, origin = "start")
  raw <- readBin(con, what = "raw", n = size - start)
  lines <- strsplit(rawToChar(raw), "\\r?\\n", perl = TRUE)[[1]]
  if (start > 0 && length(lines) > 1L) lines <- lines[-1L]
  lines <- lines[nzchar(trimws(lines))]
  if (length(lines) == 0L) NA_character_ else tail(lines, 1L)
}

csv_first_field <- function(line) {
  if (is.na(line) || !nzchar(line)) return(NA_character_)
  trimws(gsub('^"|"$', "", strsplit(line, ",", fixed = TRUE)[[1]][1]))
}

toa5_has_key_columns <- function(path) {
  header <- tryCatch(
    names(fread(path, sep = ",", skip = 1, header = TRUE, nrows = 0L, showProgress = FALSE)),
    error = function(e) character()
  )
  required <- c("TIMESTAMP", "Ux", "Uy", "Uz", "CO2", "TA_1_1_1", "PA")
  all(required %in% header)
}

toa5_content_date_index <- function(path, raw_root, tz) {
  if (!toa5_has_key_columns(path)) return(data.table())

  first_lines <- readLines(path, n = 5L, warn = FALSE)
  if (length(first_lines) < 5L) return(data.table())
  first_time <- parse_local(csv_first_field(first_lines[5L]), tz)
  last_time <- parse_local(csv_first_field(read_last_nonempty_line(path)), tz)
  if (is.na(first_time) || is.na(last_time) || last_time < first_time) return(data.table())

  dates <- seq(as.Date(first_time, tz = tz), as.Date(last_time, tz = tz), by = "day")
  data.table(
    raw_root = raw_root,
    file = path,
    file_name = basename(path),
    date_token = format(dates, "%Y_%m_%d")
  )
}

build_raw_index <- function(raw_root, start_time, end_time, tz, output_path) {
  files <- list.files(raw_root, pattern = "[.]dat$", recursive = TRUE, full.names = TRUE)
  files <- normalizePath(files, winslash = "/", mustWork = FALSE)
  date_token <- extract_date_token(files)
  normalized_root <- normalizePath(raw_root, winslash = "/", mustWork = TRUE)
  named_files <- files[!is.na(date_token)]
  named_tokens <- date_token[!is.na(date_token)]
  start_date <- as.Date(start_time, tz = tz)
  end_date <- as.Date(end_time, tz = tz)
  named_dates <- as.Date(gsub("_", "-", named_tokens))
  named_in_window <- !is.na(named_dates) & named_dates >= start_date & named_dates <= end_date
  named_files <- named_files[named_in_window]
  named_tokens <- named_tokens[named_in_window]
  named_valid <- vapply(named_files, toa5_has_key_columns, logical(1))
  named_index <- data.table(
    raw_root = normalized_root,
    file = named_files[named_valid],
    file_name = basename(named_files[named_valid]),
    date_token = named_tokens[named_valid]
  )
  content_index <- rbindlist(
    lapply(files[is.na(date_token)], toa5_content_date_index, raw_root = normalized_root, tz = tz),
    use.names = TRUE,
    fill = TRUE
  )
  index <- unique(rbindlist(list(named_index, content_index), use.names = TRUE, fill = TRUE))
  index[, file_date := as.Date(gsub("_", "-", date_token))]
  index <- index[!is.na(file_date) & file_date >= start_date & file_date <= end_date]
  index[, file_date := NULL]
  setorder(index, date_token, file)
  fwrite(index, output_path)
  index
}

run_command <- function(executable, args, env = character()) {
  if (length(env) > 0L) {
    env_names <- sub("=.*$", "", env)
    env_values <- sub("^[^=]*=", "", env)
    old_values <- Sys.getenv(env_names, unset = NA_character_)
    on.exit({
      present <- !is.na(old_values)
      if (any(present)) {
        restore <- as.list(old_values[present])
        names(restore) <- env_names[present]
        do.call(Sys.setenv, restore)
      }
      if (any(!present)) Sys.unsetenv(env_names[!present])
    }, add = TRUE)
    new_values <- as.list(env_values)
    names(new_values) <- env_names
    do.call(Sys.setenv, new_values)
  }
  output <- system2(executable, args, stdout = TRUE, stderr = TRUE)
  status <- attr(output, "status")
  if (is.null(status)) status <- 0L
  if (status != 0L) {
    stop(
      "Command failed with status ", status, ":\n",
      paste(output, collapse = "\n"),
      call. = FALSE
    )
  }
  output
}

with_interval <- function(dt, tz) {
  if (nrow(dt) == 0L) {
    dt[, `:=`(start_time_merge = as.POSIXct(character()), end_time_merge = as.POSIXct(character()))]
    return(dt)
  }
  missing <- setdiff(c("start_time_local", "end_time_local"), names(dt))
  if (length(missing) > 0L) {
    stop("Pass table missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  dt[, `:=`(
    start_time_merge = parse_local(start_time_local, tz),
    end_time_merge = parse_local(end_time_local, tz)
  )]
  if (any(is.na(dt$start_time_merge) | is.na(dt$end_time_merge))) {
    stop("Pass table contains unparseable local times.", call. = FALSE)
  }
  dt
}

merge_affected <- function(existing, incremental, replace_start, replace_end, id_col, tz) {
  existing <- with_interval(copy(existing), tz)
  incremental <- with_interval(copy(incremental), tz)

  old_keep <- existing[end_time_merge < replace_start | start_time_merge > replace_end]
  new_keep <- incremental[end_time_merge >= replace_start & start_time_merge <= replace_end]
  merged <- rbindlist(list(old_keep, new_keep), use.names = TRUE, fill = TRUE)
  merged <- unique(merged, by = c("start_time_local", "end_time_local", "direction"))
  setorder(merged, start_time_merge, end_time_merge, direction)
  merged[, c("start_time_merge", "end_time_merge") := NULL]
  merged[, (id_col) := seq_len(.N)]
  setcolorder(merged, c(id_col, setdiff(names(merged), id_col)))
  merged[]
}

safe_median <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0L) NA_real_ else median(x)
}

build_summary_outputs <- function(strict, candidates, tz, output_dir) {
  strict_time <- with_interval(copy(strict), tz)
  setorder(strict_time, start_time_merge, end_time_merge)
  strict_time[, pass_date := as.Date(start_time_merge, tz = tz)]

  duration_values <- if ("duration_min" %in% names(strict_time)) strict_time$duration_min else rep(NA_real_, nrow(strict_time))
  speed_values <- if ("median_abs_speed_cm_s" %in% names(strict_time)) strict_time$median_abs_speed_cm_s else rep(NA_real_, nrow(strict_time))
  pos_speed_values <- if ("median_position_speed_cm_s" %in% names(strict_time)) strict_time$median_position_speed_cm_s else rep(NA_real_, nrow(strict_time))
  coverage_values <- if ("position_coverage" %in% names(strict_time)) strict_time$position_coverage else rep(NA_real_, nrow(strict_time))
  strict_time[, `:=`(
    duration_value = duration_values,
    speed_value = speed_values,
    pos_speed_value = pos_speed_values,
    coverage_value = coverage_values
  )]

  daily <- strict_time[, .(
    first_pass_start_local = format(min(start_time_merge), "%Y-%m-%d %H:%M:%S", tz = tz),
    last_pass_end_local = format(max(end_time_merge), "%Y-%m-%d %H:%M:%S", tz = tz),
    n_passes = .N,
    n_fw = sum(direction == "fw", na.rm = TRUE),
    n_bw = sum(direction == "bw", na.rm = TRUE),
    total_pass_hours = sum(as.numeric(difftime(end_time_merge, start_time_merge, units = "hours"))),
    span_hours = as.numeric(difftime(max(end_time_merge), min(start_time_merge), units = "hours")),
    median_duration_min = safe_median(duration_value),
    median_abs_speed_cm_s = safe_median(speed_value),
    median_position_speed_cm_s = safe_median(pos_speed_value),
    median_position_coverage = safe_median(coverage_value)
  ), by = pass_date]

  strict_time[, gap_hours_from_previous := as.numeric(difftime(start_time_merge, shift(end_time_merge), units = "hours"))]
  strict_time[, coverage_block_id := cumsum(is.na(gap_hours_from_previous) | gap_hours_from_previous > 2)]
  blocks <- strict_time[, .(
    block_start_local = format(min(start_time_merge), "%Y-%m-%d %H:%M:%S", tz = tz),
    block_end_local = format(max(end_time_merge), "%Y-%m-%d %H:%M:%S", tz = tz),
    start_date = as.character(as.Date(min(start_time_merge), tz = tz)),
    end_date = as.character(as.Date(max(end_time_merge), tz = tz)),
    n_passes = .N,
    n_fw = sum(direction == "fw", na.rm = TRUE),
    n_bw = sum(direction == "bw", na.rm = TRUE),
    span_hours = as.numeric(difftime(max(end_time_merge), min(start_time_merge), units = "hours")),
    total_pass_hours = sum(as.numeric(difftime(end_time_merge, start_time_merge, units = "hours"))),
    max_gap_hours_inside_block = {
      gaps <- gap_hours_from_previous[is.finite(gap_hours_from_previous)]
      if (length(gaps) == 0L) 0 else max(gaps)
    }
  ), by = coverage_block_id]

  direction_summary <- strict[, .N, by = direction][order(direction)]
  reject_summary <- candidates[, .N, by = reject_reason][order(-N, reject_reason)]
  moving <- strict[, .(time, direction)]

  fwrite(strict, file.path(output_dir, "fl_complete_passes_strict.csv"))
  fwrite(candidates, file.path(output_dir, "fl_complete_pass_candidates_all.csv"))
  fwrite(moving, file.path(output_dir, "fl_complete_passes_strict_moving_table.csv"))
  fwrite(daily, file.path(output_dir, "fl_complete_pass_coverage_daily.csv"))
  fwrite(blocks, file.path(output_dir, "fl_complete_pass_coverage_blocks.csv"))
  fwrite(direction_summary, file.path(output_dir, "fl_complete_pass_direction_summary.csv"))
  fwrite(reject_summary, file.path(output_dir, "fl_complete_pass_reject_summary.csv"))
}

publish_outputs <- function(publish_dir, master_dir, names) {
  for (name in names) {
    source <- file.path(publish_dir, name)
    target <- file.path(master_dir, name)
    if (!file.exists(source)) stop("Publish source missing: ", source, call. = FALSE)
    if (!file.copy(source, target, overwrite = TRUE)) {
      stop("Failed to publish: ", target, call. = FALSE)
    }
  }
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  required_paths <- c(opts$unified_csv, opts$strict_script, opts$plot_script)
  missing <- required_paths[!file.exists(required_paths)]
  if (length(missing) > 0L) stop("Missing input: ", paste(missing, collapse = "; "), call. = FALSE)
  use_prebuilt_raw_index <- nzchar(opts$raw_index_csv)
  if (!use_prebuilt_raw_index && !dir.exists(opts$raw_root)) {
    stop("Missing raw EC root: ", opts$raw_root, call. = FALSE)
  }
  dir.create(opts$master_dir, recursive = TRUE, showWarnings = FALSE)

  replace_start <- parse_local(opts$start, opts$timezone)
  replace_end <- if (is.na(opts$end) || !nzchar(opts$end)) {
    as.POSIXct("2100-01-01 00:00:00", tz = opts$timezone)
  } else {
    parse_local(opts$end, opts$timezone)
  }
  if (is.na(replace_start) || is.na(replace_end) || replace_end < replace_start) {
    stop("Invalid --start/--end interval.", call. = FALSE)
  }

  extract_start <- replace_start - opts$lookback_hours * 3600
  extract_end <- if (as.integer(format(replace_end, "%Y", tz = opts$timezone)) >= 2100L) {
    replace_end
  } else {
    replace_end + opts$lookback_hours * 3600
  }
  batch_id <- format(Sys.time(), "%Y%m%d_%H%M%S")
  batch_dir <- file.path(opts$master_dir, "incremental_batches", batch_id)
  publish_dir <- file.path(batch_dir, "publish")
  dir.create(publish_dir, recursive = TRUE, showWarnings = FALSE)

  message("Reading unified running records and selecting incremental window")
  running <- fread(
    opts$unified_csv,
    select = c("time", "speed", "position"),
    colClasses = list(character = "time"),
    showProgress = TRUE
  )
  running[, time_parsed := parse_local(time, opts$timezone)]
  running <- running[!is.na(time_parsed) & time_parsed >= extract_start & time_parsed <= extract_end]
  setorder(running, time_parsed)
  running[, time_parsed := NULL]
  if (nrow(running) < 2L) stop("No usable running records in the incremental window.", call. = FALSE)
  staged_running <- file.path(batch_dir, "fl_running_records_unified.csv")
  fwrite(running, staged_running)

  raw_index_path <- file.path(batch_dir, "ec_raw_files_incremental.csv")
  raw_index <- if (use_prebuilt_raw_index) {
    read_raw_index(opts$raw_index_csv)
  } else {
    build_raw_index(opts$raw_root, extract_start, extract_end, opts$timezone, raw_index_path)
  }
  if (use_prebuilt_raw_index) fwrite(raw_index, raw_index_path)
  if (nrow(raw_index) == 0L) {
    message("No EC raw files indexed for the incremental window; geometric candidates will fail EC availability.")
  }

  staged_strict_script <- file.path(batch_dir, "02_mark_complete_passes_strict.R")
  if (!file.copy(opts$strict_script, staged_strict_script, overwrite = TRUE)) {
    stop("Failed to stage strict-pass script.", call. = FALSE)
  }
  Sys.unsetenv("FL_STRICT_TEST_ROWS")
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  strict_log <- run_command(
    rscript,
    shQuote(staged_strict_script),
    env = c(
      paste0("FL_STRICT_OUTPUT_DIR=", normalizePath(batch_dir, winslash = "/", mustWork = TRUE)),
      paste0("FL_TRACK_SOUTH_M=", opts$track_south_m),
      paste0("FL_TRACK_NORTH_M=", opts$track_north_m),
      paste0("FL_STRICT_EC_RAW_FILES_CSV=", normalizePath(raw_index_path, winslash = "/", mustWork = TRUE))
    )
  )
  writeLines(strict_log, file.path(batch_dir, "strict_run.log"), useBytes = TRUE)

  existing_strict <- read_required(file.path(opts$master_dir, "fl_complete_passes_strict.csv"))
  existing_candidates <- read_required(file.path(opts$master_dir, "fl_complete_pass_candidates_all.csv"))
  incremental_strict <- read_required(file.path(batch_dir, "fl_complete_passes_strict.csv"))
  incremental_candidates <- read_required(file.path(batch_dir, "fl_complete_pass_candidates_all.csv"))

  merged_strict <- merge_affected(
    existing_strict, incremental_strict, replace_start, replace_end, "pass_id", opts$timezone
  )
  merged_candidates <- merge_affected(
    existing_candidates, incremental_candidates, replace_start, replace_end, "candidate_id", opts$timezone
  )
  if (nrow(merged_strict) == 0L) stop("Merged strict-pass table is empty.", call. = FALSE)
  if (anyDuplicated(merged_strict[, .(start_time_local, end_time_local, direction)])) {
    stop("Merged strict-pass table contains duplicate pass keys.", call. = FALSE)
  }

  build_summary_outputs(merged_strict, merged_candidates, opts$timezone, publish_dir)
  timeline_path <- file.path(publish_dir, "fl_complete_pass_coverage_timeline.png")
  plot_args <- c(
    shQuote(opts$plot_script),
    shQuote(paste0("--input-file=", file.path(publish_dir, "fl_complete_passes_strict.csv"))),
    shQuote(paste0("--output-file=", timeline_path)),
    shQuote(paste0("--timezone=", opts$timezone)),
    shQuote(paste0("--title=", opts$plot_title))
  )
  if (nzchar(opts$plot_subtitle)) {
    plot_args <- c(plot_args, shQuote(paste0("--subtitle=", opts$plot_subtitle)))
  }
  if (nzchar(opts$plot_caption)) {
    plot_args <- c(plot_args, shQuote(paste0("--caption=", opts$plot_caption)))
  }
  plot_log <- run_command(
    rscript,
    plot_args
  )
  writeLines(plot_log, file.path(batch_dir, "plot_run.log"), useBytes = TRUE)
  if (!file.exists(timeline_path) || file.info(timeline_path)$size <= 1000) {
    stop("Coverage timeline validation failed.", call. = FALSE)
  }

  output_names <- c(
    "fl_complete_passes_strict.csv",
    "fl_complete_pass_candidates_all.csv",
    "fl_complete_passes_strict_moving_table.csv",
    "fl_complete_pass_coverage_daily.csv",
    "fl_complete_pass_coverage_blocks.csv",
    "fl_complete_pass_direction_summary.csv",
    "fl_complete_pass_reject_summary.csv",
    "fl_complete_pass_coverage_timeline.png"
  )
  publish_outputs(publish_dir, opts$master_dir, output_names)

  manifest_lines <- c(
    "FL complete-pass incremental update",
    "mode: incremental",
    paste("batch_id:", batch_id),
    paste("run_time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    paste("replace_start:", format_local(replace_start, opts$timezone)),
    paste("replace_end:", format_local(replace_end, opts$timezone)),
    paste("extract_start:", format_local(extract_start, opts$timezone)),
    paste("extract_end:", format_local(extract_end, opts$timezone)),
    paste("lookback_hours:", opts$lookback_hours),
    paste("track_range_m:", opts$track_south_m, "to", opts$track_north_m),
    paste("plot_title:", opts$plot_title),
    paste("plot_subtitle:", opts$plot_subtitle),
    paste("plot_caption:", opts$plot_caption),
    "EC availability rule: at least one minute with >=300 key-complete 10 Hz rows within the candidate pass",
    "EC key variables: Ux, Uy, Uz, CO2, TA_1_1_1, PA; wind-speed, diagnostic-code, and scalar physical-range QC are deferred to downstream EC calculations",
    paste("running_rows_selected:", nrow(running)),
    paste("raw_files_indexed:", nrow(raw_index)),
    paste("incremental_candidates:", nrow(incremental_candidates)),
    paste("incremental_strict_passes:", nrow(incremental_strict)),
    paste("merged_candidates:", nrow(merged_candidates)),
    paste("merged_strict_passes:", nrow(merged_strict)),
    paste("unified_csv:", normalizePath(opts$unified_csv, winslash = "/", mustWork = TRUE)),
    paste("strict_script:", normalizePath(opts$strict_script, winslash = "/", mustWork = TRUE)),
    paste("raw_root:", if (dir.exists(opts$raw_root)) normalizePath(opts$raw_root, winslash = "/", mustWork = TRUE) else opts$raw_root),
    paste("raw_index_source:", if (use_prebuilt_raw_index) normalizePath(opts$raw_index_csv, winslash = "/", mustWork = TRUE) else "built_from_raw_root"),
    paste("batch_dir:", normalizePath(batch_dir, winslash = "/", mustWork = TRUE))
  )
  writeLines(manifest_lines, file.path(batch_dir, "fl_complete_passes_incremental_manifest.txt"), useBytes = TRUE)
  writeLines(manifest_lines, file.path(opts$master_dir, "fl_complete_passes_incremental_manifest.txt"), useBytes = TRUE)

  if (!opts$keep_running_subset) unlink(staged_running)

  cat("Incremental update complete.\n")
  cat("Incremental strict passes: ", nrow(incremental_strict), "\n", sep = "")
  cat("Merged strict passes: ", nrow(merged_strict), "\n", sep = "")
  cat("Timeline: ", file.path(opts$master_dir, "fl_complete_pass_coverage_timeline.png"), "\n", sep = "")
  cat("Batch directory: ", batch_dir, "\n", sep = "")
}

main()
