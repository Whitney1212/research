#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

default_output_dir <- "E:/Dataset_Level1/Flares/PFparameter_expanded_training"
default_two_output_dir <- "E:/Dataset_Level1/Flares/PFparameter_expanded_training_2ensemble"
default_early_no_speed <- file.path(
  "E:/Dataset_RAW/Flares",
  "\u8fd0\u884c\u8bb0\u5f55",
  "no speed",
  "20230315_20231226.csv"
)
default_modern_unified <- file.path(
  "E:/Dataset_RAW/Flares",
  "\u8fd0\u884c\u8bb0\u5f55",
  "unified_output",
  "fl_running_records_unified.csv"
)
default_strict_marker <- file.path(
  "E:/Dataset_RAW/Flares",
  "\u8fd0\u884c\u8bb0\u5f55",
  "unified_output",
  "02_mark_complete_passes_strict.R"
)
default_pf8_script <- "E:/Dataset_Level1/Flares/PFparameter/run_PF_8bin.R"
default_pf2_script <- "E:/Dataset_Level1/Flares/PFparameter/run_PF_8bin_2ensemble.R"

parse_args <- function(args) {
  opts <- list(
    output_dir = default_output_dir,
    two_output_dir = default_two_output_dir,
    early_no_speed = default_early_no_speed,
    modern_unified = default_modern_unified,
    strict_marker = default_strict_marker,
    pf8_script = default_pf8_script,
    pf2_script = default_pf2_script,
    tz = "Asia/Shanghai",
    track_south_m = 5,
    track_north_m = 240,
    nominal_speed_cm_s = 13.7,
    moving_threshold_cm_s = 3,
    max_running_record_gap_s = 15,
    force = FALSE,
    stop_after_strict = FALSE,
    skip_pf = FALSE,
    skip_2ensemble = FALSE
  )

  for (arg in args) {
    if (grepl("^--output-dir=", arg)) {
      opts$output_dir <- sub("^--output-dir=", "", arg)
    } else if (grepl("^--two-output-dir=", arg)) {
      opts$two_output_dir <- sub("^--two-output-dir=", "", arg)
    } else if (grepl("^--early-no-speed=", arg)) {
      opts$early_no_speed <- sub("^--early-no-speed=", "", arg)
    } else if (grepl("^--modern-unified=", arg)) {
      opts$modern_unified <- sub("^--modern-unified=", "", arg)
    } else if (grepl("^--strict-marker=", arg)) {
      opts$strict_marker <- sub("^--strict-marker=", "", arg)
    } else if (grepl("^--pf8-script=", arg)) {
      opts$pf8_script <- sub("^--pf8-script=", "", arg)
    } else if (grepl("^--pf2-script=", arg)) {
      opts$pf2_script <- sub("^--pf2-script=", "", arg)
    } else if (grepl("^--nominal-speed-cm-s=", arg)) {
      opts$nominal_speed_cm_s <- as.numeric(sub("^--nominal-speed-cm-s=", "", arg))
    } else if (arg == "--force") {
      opts$force <- TRUE
    } else if (arg == "--stop-after-strict") {
      opts$stop_after_strict <- TRUE
    } else if (arg == "--skip-pf") {
      opts$skip_pf <- TRUE
    } else if (arg == "--skip-2ensemble") {
      opts$skip_2ensemble <- TRUE
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/build_expanded_pf_training.R [options]\n",
        "  --output-dir=PATH\n",
        "  --two-output-dir=PATH\n",
        "  --early-no-speed=PATH\n",
        "  --modern-unified=PATH\n",
        "  --nominal-speed-cm-s=13.7\n",
        "  --force\n",
        "  --stop-after-strict\n",
        "  --skip-pf\n",
        "  --skip-2ensemble\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  if (!is.finite(opts$nominal_speed_cm_s) || opts$nominal_speed_cm_s <= 0) {
    stop("--nominal-speed-cm-s must be positive.", call. = FALSE)
  }
  opts
}

parse_local_time <- function(x, tz) {
  x <- trimws(as.character(x))
  x <- sub("T", " ", x, fixed = TRUE)
  out <- as.POSIXct(x, tz = tz, format = "%Y-%m-%d %H:%M:%OS")
  miss <- is.na(out)
  if (any(miss)) out[miss] <- as.POSIXct(x[miss], tz = tz, format = "%Y-%m-%d %H:%M:%S")
  miss <- is.na(out)
  if (any(miss)) out[miss] <- as.POSIXct(x[miss], tz = tz, format = "%Y/%m/%d %H:%M:%OS")
  miss <- is.na(out)
  if (any(miss)) out[miss] <- as.POSIXct(x[miss], tz = tz, format = "%Y/%m/%d %H:%M:%S")
  out
}

format_local <- function(x, tz) {
  format(x, "%Y-%m-%d %H:%M:%OS3", tz = tz)
}

finite_or_na <- function(x, fn) {
  x <- x[is.finite(x)]
  if (length(x) == 0) NA_real_ else fn(x)
}

collapse_time_rows <- function(dt) {
  dt[, .(
    speed = {
      v <- speed[is.finite(speed)]
      if (length(v) == 0) NA_real_ else median(v)
    },
    position = {
      v <- position[is.finite(position)]
      if (length(v) == 0) NA_real_ else median(v)
    },
    n_records_at_time = .N
  ), by = time]
}

read_early_no_speed <- function(path, opts) {
  if (!file.exists(path)) {
    stop("Missing early no-speed running record: ", path, call. = FALSE)
  }

  message("Reading early no-speed running records: ", path)
  dt <- fread(path, na.strings = c("", "NA"), showProgress = TRUE)
  if (ncol(dt) < 2) {
    stop("Early no-speed file needs at least time and position columns.", call. = FALSE)
  }

  dt <- dt[, .(
    time = parse_local_time(.SD[[1]], opts$tz),
    position = suppressWarnings(as.numeric(.SD[[2]]))
  ), .SDcols = 1:2]
  dt <- dt[
    !is.na(time) & is.finite(position) &
      position >= opts$track_south_m - 50 &
      position <= opts$track_north_m + 50
  ]
  setorder(dt, time)
  dt <- dt[, .(
    position = {
      v <- position[is.finite(position)]
      if (length(v) == 0) NA_real_ else median(v)
    },
    n_records_at_time = .N
  ), by = time]
  setorder(dt, time)

  dt[, `:=`(
    dtime_s = as.numeric(difftime(time, shift(time), units = "secs")),
    dpos_m = position - shift(position)
  )]
  dt[, position_speed_cm_s := fifelse(
    is.finite(dtime_s) & dtime_s > 0 & dtime_s <= opts$max_running_record_gap_s,
    100 * dpos_m / dtime_s,
    NA_real_
  )]
  dt[, speed := fifelse(
    is.finite(position_speed_cm_s) &
      abs(position_speed_cm_s) >= opts$moving_threshold_cm_s,
    sign(position_speed_cm_s) * opts$nominal_speed_cm_s,
    0
  )]
  dt[, source_group := "early_no_speed_nominal_13.7cms"]
  dt[, .(time, speed, position, source_group)]
}

read_modern_unified <- function(path, opts) {
  if (!file.exists(path)) {
    stop("Missing modern unified running record: ", path, call. = FALSE)
  }

  message("Reading modern unified running records: ", path)
  dt <- fread(
    path,
    select = c("time", "speed", "position"),
    colClasses = list(character = "time", numeric = c("speed", "position")),
    showProgress = TRUE
  )
  dt[, time := parse_local_time(time, opts$tz)]
  dt <- dt[
    !is.na(time) & is.finite(position) &
      position >= opts$track_south_m - 50 &
      position <= opts$track_north_m + 50
  ]
  dt[, source_group := "modern_unified_actual_speed"]
  dt[, .(time, speed, position, source_group)]
}

summarise_running_records <- function(dt, opts) {
  dt[, .(
    rows = .N,
    time_min = format_local(min(time), opts$tz),
    time_max = format_local(max(time), opts$tz),
    position_min = finite_or_na(position, min),
    position_max = finite_or_na(position, max),
    median_abs_speed_cm_s = finite_or_na(abs(speed), median),
    moving_rows = sum(is.finite(speed) & abs(speed) >= opts$moving_threshold_cm_s)
  ), by = source_group][order(source_group)]
}

build_expanded_running_records <- function(opts, records_csv, summary_csv) {
  early <- read_early_no_speed(opts$early_no_speed, opts)
  modern <- read_modern_unified(opts$modern_unified, opts)

  combined <- rbindlist(list(early, modern), use.names = TRUE, fill = TRUE)
  setorder(combined, time, source_group)
  total_rows_before <- nrow(combined)

  # Time de-duplication keeps actual-speed modern rows if there is ever overlap.
  combined[, source_rank := fifelse(source_group == "modern_unified_actual_speed", 1L, 2L)]
  setorder(combined, time, source_rank)
  collapsed <- combined[, .(
    speed = {
      v <- speed[is.finite(speed)]
      if (length(v) == 0) NA_real_ else v[1]
    },
    position = {
      v <- position[is.finite(position)]
      if (length(v) == 0) NA_real_ else median(v)
    },
    source_group = paste(unique(source_group), collapse = ";"),
    n_records_at_time = .N
  ), by = time]
  setorder(collapsed, time)

  out <- collapsed[, .(
    time = format_local(time, opts$tz),
    speed,
    position
  )]
  fwrite(out, records_csv)

  summary <- rbindlist(list(
    summarise_running_records(early, opts),
    summarise_running_records(modern, opts),
    data.table(
      source_group = "expanded_deduped_output",
      rows = nrow(collapsed),
      time_min = out$time[1],
      time_max = out$time[nrow(out)],
      position_min = finite_or_na(collapsed$position, min),
      position_max = finite_or_na(collapsed$position, max),
      median_abs_speed_cm_s = finite_or_na(abs(collapsed$speed), median),
      moving_rows = sum(is.finite(collapsed$speed) & abs(collapsed$speed) >= opts$moving_threshold_cm_s)
    )
  ), use.names = TRUE, fill = TRUE)
  summary[, rows_before_time_dedupe := fifelse(
    source_group == "expanded_deduped_output",
    total_rows_before,
    NA_integer_
  )]
  summary[, rows_removed_by_time_dedupe := fifelse(
    source_group == "expanded_deduped_output",
    total_rows_before - nrow(collapsed),
    NA_integer_
  )]
  fwrite(summary, summary_csv)

  message("Expanded running records written: ", records_csv)
  message("Expanded running rows: ", nrow(collapsed))
  invisible(summary)
}

run_strict_pass_marker <- function(opts, records_csv, strict_csv) {
  if (!file.exists(opts$strict_marker)) {
    stop("Missing strict marker script: ", opts$strict_marker, call. = FALSE)
  }

  marker_copy <- file.path(opts$output_dir, "02_mark_complete_passes_strict.R")
  wrapper <- file.path(opts$output_dir, "run_strict_complete_passes_expanded.R")
  file.copy(opts$strict_marker, marker_copy, overwrite = TRUE)

  wrapper_lines <- c(
    "Sys.setenv(",
    sprintf("  FL_TRACK_SOUTH_M = '%s',", opts$track_south_m),
    sprintf("  FL_TRACK_NORTH_M = '%s'", opts$track_north_m),
    ")",
    sprintf("source(%s)", deparse(normalizePath(marker_copy, winslash = "/", mustWork = FALSE)))
  )
  writeLines(wrapper_lines, wrapper, useBytes = TRUE)

  # The strict marker expects this exact input filename in its script directory.
  expected_csv <- file.path(opts$output_dir, "fl_running_records_unified.csv")
  if (!identical(normalizePath(records_csv, winslash = "/", mustWork = FALSE),
                 normalizePath(expected_csv, winslash = "/", mustWork = FALSE))) {
    file.copy(records_csv, expected_csv, overwrite = TRUE)
  }

  message("Running strict complete-pass marker")
  status <- system2(file.path(R.home("bin"), "Rscript"), shQuote(wrapper))
  if (!identical(status, 0L)) {
    stop("Strict complete-pass marker failed with status: ", status, call. = FALSE)
  }
  if (!file.exists(strict_csv)) {
    stop("Strict pass output missing: ", strict_csv, call. = FALSE)
  }
  message("Strict pass table written: ", strict_csv)
}

source_until_call <- function(path, call_pattern) {
  if (!file.exists(path)) {
    stop("Missing source script: ", path, call. = FALSE)
  }
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  call_idx <- grep(call_pattern, lines)
  if (length(call_idx) == 0) {
    stop("Could not find call pattern in ", path, ": ", call_pattern, call. = FALSE)
  }
  code <- paste(lines[seq_len(call_idx[1] - 1L)], collapse = "\n")
  eval(parse(text = code), envir = .GlobalEnv)
}

run_pf8_expanded <- function(opts, strict_csv, records_csv) {
  message("Loading PF_8bin functions: ", opts$pf8_script)
  source_until_call(opts$pf8_script, "^pf8_main\\(\\)")

  pf8_config <<- function() {
    cfg <- fl_pf_default_config()
    cfg$root_dir <- opts$output_dir
    cfg$output_dir <- opts$output_dir
    cfg$fig_dir <- file.path(cfg$output_dir, "figures")
    cfg$cache_dir <- file.path(cfg$output_dir, "cache")
    cfg$passes_csv <- strict_csv
    cfg$running_records_csv <- records_csv
    cfg$method_name <- "PF_8bin_expanded_training"
    cfg$preprocessing_version <- "record_position_actual_or_nominal_speed_v2_expanded_from_2023"
    cfg$n_bins <- 8L
    cfg$n_bins_set <- 8L
    cfg$max_running_record_gap_s <- opts$max_running_record_gap_s
    cfg$running_record_margin_s <- 120
    cfg$force_rebuild <- TRUE
    cfg
  }

  message("Running expanded PF_8bin preprocessing and fit")
  pf8_main()
}

run_pf2_expanded <- function(opts) {
  message("Loading PF_8bin_2ensemble functions: ", opts$pf2_script)
  source_until_call(opts$pf2_script, "^pf2_main\\(\\)")

  pf2_config <<- function() {
    cfg <- fl_pf_default_config()
    cfg$source_dir <- opts$output_dir
    cfg$output_dir <- opts$two_output_dir
    cfg$fig_dir <- file.path(cfg$output_dir, "figures")
    cfg$method_name <- "PF_8bin_2ensemble_expanded_training"
    cfg$preprocessing_version <- "record_position_actual_or_nominal_speed_v2_expanded_from_2023_pass_bin_means"
    cfg$n_bins <- 8L
    cfg$max_gap_min_two_pass <- cfg$max_gap_min_four_pass
    cfg$min_passes_per_ensemble_bin <- 2L
    cfg
  }

  message("Running expanded PF_8bin 2-ensemble fit")
  pf2_main()
}

write_expanded_manifest <- function(opts, records_csv, summary_csv, strict_csv) {
  manifest <- file.path(opts$output_dir, "expanded_training_manifest.txt")
  lines <- c(
    "FL expanded PF training manifest",
    paste("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    paste("Output dir:", normalizePath(opts$output_dir, winslash = "/", mustWork = FALSE)),
    paste("2-ensemble output dir:", normalizePath(opts$two_output_dir, winslash = "/", mustWork = FALSE)),
    "",
    "Inputs:",
    paste("Early no-speed running record:", normalizePath(opts$early_no_speed, winslash = "/", mustWork = FALSE)),
    paste("Modern unified running record:", normalizePath(opts$modern_unified, winslash = "/", mustWork = FALSE)),
    paste("Strict marker:", normalizePath(opts$strict_marker, winslash = "/", mustWork = FALSE)),
    paste("PF_8bin script:", normalizePath(opts$pf8_script, winslash = "/", mustWork = FALSE)),
    paste("PF_8bin_2ensemble script:", normalizePath(opts$pf2_script, winslash = "/", mustWork = FALSE)),
    "",
    "Nominal speed rule:",
    paste("No-speed records use signed", opts$nominal_speed_cm_s, "cm/s when position-derived speed exceeds", opts$moving_threshold_cm_s, "cm/s."),
    "Direction sign is inferred from adjacent position changes; non-moving rows are set to 0 cm/s.",
    "",
    "Generated intermediate files:",
    normalizePath(records_csv, winslash = "/", mustWork = FALSE),
    normalizePath(summary_csv, winslash = "/", mustWork = FALSE),
    normalizePath(strict_csv, winslash = "/", mustWork = FALSE)
  )
  writeLines(lines, manifest, useBytes = TRUE)
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  dir.create(opts$output_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(opts$two_output_dir, recursive = TRUE, showWarnings = FALSE)

  records_csv <- file.path(opts$output_dir, "fl_running_records_unified.csv")
  summary_csv <- file.path(opts$output_dir, "fl_running_records_expanded_source_summary.csv")
  strict_csv <- file.path(opts$output_dir, "fl_complete_passes_strict.csv")

  if (opts$force || !file.exists(records_csv) || !file.exists(summary_csv)) {
    build_expanded_running_records(opts, records_csv, summary_csv)
  } else {
    message("Using existing expanded running records: ", records_csv)
  }

  if (opts$force || !file.exists(strict_csv)) {
    run_strict_pass_marker(opts, records_csv, strict_csv)
  } else {
    message("Using existing strict pass table: ", strict_csv)
  }

  write_expanded_manifest(opts, records_csv, summary_csv, strict_csv)

  if (opts$stop_after_strict || opts$skip_pf) {
    message("Stopped after strict complete-pass generation.")
    return(invisible(NULL))
  }

  run_pf8_expanded(opts, strict_csv, records_csv)

  if (!opts$skip_2ensemble) {
    run_pf2_expanded(opts)
  }

  message("Expanded PF training build complete.")
}

main()
