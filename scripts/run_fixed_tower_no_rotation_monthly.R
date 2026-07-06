#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
full_args <- commandArgs(trailingOnly = FALSE)
script_file <- sub("^--file=", "", grep("^--file=", full_args, value = TRUE)[1])
default_site <- if (!is.na(script_file) && grepl("cvt", basename(script_file), ignore.case = TRUE)) "CVT" else "MT"
arg_value <- function(key, default = NULL) {
  hit <- grep(paste0("^--", key, "="), args, value = TRUE)
  if (length(hit) == 0) return(default)
  sub(paste0("^--", key, "="), "", hit[1])
}

site <- toupper(arg_value("site", default_site))
force <- "--force" %in% args
tz <- "Asia/Shanghai"
file_pattern <- "^TOA5_.*\\.Time_Series_.*\\.dat$"
com_rotation_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
ecpreproc_dir <- "D:/00 博士阶段/博一/05 Project/ecpreproc"

sites <- list(
  MT = list(
    level0_root = "E:/Dataset_Level0/MT/EC",
    meta_path = "D:/00EDDYPRO/sh_MT.metadata",
    out_root = "E:/Dataset_Level1/MT/EC/no rotation_ecpreproc"
  ),
  CVT = list(
    level0_root = "E:/Dataset_Level0/CVT/EC",
    meta_path = "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata",
    out_root = "E:/Dataset_Level1/CVT/EC/no rotation_ecpreproc"
  )
)
if (!site %in% names(sites)) stop("Unknown site: ", site)
spec <- sites[[site]]

source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")
cfg <- list(project_dir = spec$out_root, package_dir = ecpreproc_dir, tz = tz)
load_ecpreproc(cfg)

script_dir <- file.path(spec$out_root, "scripts")
segment_dir <- file.path(spec$out_root, "segments")
result_dir <- file.path(spec$out_root, "results")
log_dir <- file.path(spec$out_root, "logs")
invisible(lapply(c(script_dir, segment_dir, result_dir, log_dir), dir.create, recursive = TRUE, showWarnings = FALSE))

parse_file_start <- function(path) {
  hits <- regmatches(basename(path), gregexpr("[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{4}", basename(path)))[[1]]
  if (length(hits) == 0 || identical(hits, character(0))) return(as.POSIXct(NA, tz = tz))
  hit <- tail(hits, 1)
  as.POSIXct(hit, format = "%Y_%m_%d_%H%M", tz = tz)
}

round_ts_text <- function(x) {
  x <- sub("\\.$", "", x)
  m <- regexec("^(.*:)([0-9]{2})(?:\\.([0-9]+))?$", x)
  parts <- regmatches(x, m)
  vapply(parts, function(p) {
    if (length(p) < 3) stop("Cannot parse timestamp text: ", p[1])
    frac <- if (length(p) >= 4 && nzchar(p[4])) as.numeric(paste0("0.", p[4])) else 0
    sec <- round(as.numeric(p[3]) + frac, 1)
    if (sec >= 60) stop("Rounded seconds reached 60; handle carry explicitly for: ", p[1])
    paste0(p[2], sprintf("%04.1f", sec))
  }, character(1))
}

format_flux_timestamp <- function(ts) {
  if (!inherits(ts, "POSIXct")) ts <- as.POSIXct(ts, tz = tz)
  round_ts_text(format(ts, "%Y-%m-%d %H:%M:%OS3", tz = tz))
}

self_check <- function() {
  x <- as.POSIXct("2024-01-03 00:00:00.1", format = "%Y-%m-%d %H:%M:%OS", tz = tz)
  stopifnot(identical(format_flux_timestamp(x), "2024-01-03 00:00:00.1"))
}
self_check()

files <- sort(list.files(spec$level0_root, pattern = file_pattern, full.names = TRUE, recursive = TRUE))
if (length(files) == 0) stop("No TOA5 Time_Series files found: ", spec$level0_root)

file_info <- data.frame(
  file = files,
  source_dir = dirname(files),
  file_start = as.POSIXct(vapply(files, function(x) as.numeric(parse_file_start(x)), numeric(1)), origin = "1970-01-01", tz = tz),
  stringsAsFactors = FALSE
)
file_info <- file_info[!is.na(file_info$file_start), , drop = FALSE]
file_info <- file_info[file_info$file_start >= as.POSIXct("2020-01-01 00:00:00", tz = tz), , drop = FALSE]
file_info$month <- format(file_info$file_start, "%Y-%m", tz = tz)
months <- sort(unique(file_info$month))
meta <- ec_read_metadata(spec$meta_path)

run_month <- function(month) {
  segment_csv <- file.path(segment_dir, paste0(site, "_flux_no_rotation_", month, ".csv"))
  summary_csv <- file.path(segment_dir, paste0(site, "_flux_no_rotation_", month, "_summary.csv"))
  if (!force && file.exists(segment_csv) && file.exists(summary_csv)) {
    message("skip existing month: ", month)
    return(utils::read.csv(summary_csv, stringsAsFactors = FALSE))
  }

  start <- as.POSIXct(paste0(month, "-01 00:00:00"), tz = tz)
  end <- seq(start, by = "month", length.out = 2)[2]
  month_files <- file_info[file_info$file_start >= start - 86400 & file_info$file_start < end + 86400, , drop = FALSE]
  if (nrow(month_files) == 0) return(NULL)

  started <- Sys.time()
  rows <- list()
  i <- 0L
  for (source_dir in sort(unique(month_files$source_dir))) {
    sub_files <- month_files$file[month_files$source_dir == source_dir]
    res <- process_rep_flux(
      data_dir = source_dir,
      meta_data = meta,
      file_pattern = basename_pattern(sub_files),
      recursive = FALSE,
      tz = tz,
      rotation_method = "none",
      detrend_method = "block_average",
      qc_params = list(),
      lag_params = list(),
      fit_results = NULL,
      output_dir = NULL,
      show_progress = TRUE,
      keep_block_details = FALSE
    )
    if (!is.null(res$results) && nrow(res$results) > 0) {
      out <- res$results
      if (!inherits(out$timestamp, "POSIXct")) out$timestamp <- as.POSIXct(out$timestamp, tz = tz)
      out <- out[!is.na(out$timestamp) & out$timestamp >= start & out$timestamp < end, , drop = FALSE]
      if (nrow(out) > 0) {
        out$source_dir <- source_dir
        i <- i + 1L
        rows[[i]] <- out
      }
    }
  }
  flux <- bind_rows_fill(rows)
  if (nrow(flux) > 0) {
    flux <- flux[order(flux$timestamp), , drop = FALSE]
    ts_text <- format_flux_timestamp(flux$timestamp)
    flux$timestamp <- ts_text
    if ("date" %in% names(flux)) flux$date <- substr(ts_text, 1, 10)
    if ("time" %in% names(flux)) flux$time <- substr(ts_text, 12, 23)
    flux$rotation_method <- "none"
    flux$flux_scheme <- "no_rotation_monthly"
  }
  if (nrow(flux) > 0) {
    utils::write.csv(flux, segment_csv, row.names = FALSE, fileEncoding = "UTF-8")
  } else if (file.exists(segment_csv)) {
    unlink(segment_csv)
  }

  finished <- Sys.time()
  summary <- data.frame(
    site = site,
    month = month,
    output_csv = if (nrow(flux) > 0) segment_csv else NA_character_,
    n_input_files = length(unique(month_files$file)),
    n_flux_rows = nrow(flux),
    first_timestamp = if (nrow(flux)) flux$timestamp[1] else NA_character_,
    last_timestamp = if (nrow(flux)) flux$timestamp[nrow(flux)] else NA_character_,
    n_duplicate_timestamp = if (nrow(flux)) nrow(flux) - length(unique(flux$timestamp)) else 0L,
    rotation_requested = "none",
    timestamp_read_rule = "TOA5 timestamp column is read as character in ecpreproc::read_toa5(), then parsed with Asia/Shanghai.",
    started = as.character(started),
    finished = as.character(finished),
    elapsed_min = as.numeric(difftime(finished, started, units = "mins")),
    stringsAsFactors = FALSE
  )
  utils::write.csv(summary, summary_csv, row.names = FALSE, fileEncoding = "UTF-8")
  summary
}

summaries <- Filter(Negate(is.null), lapply(months, run_month))
summary_all <- bind_rows_fill(summaries)
utils::write.csv(
  summary_all,
  file.path(result_dir, paste0(site, "_flux_no_rotation_monthly_summary.csv")),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

segment_files <- sort(list.files(segment_dir, pattern = paste0("^", site, "_flux_no_rotation_[0-9]{4}-[0-9]{2}\\.csv$"), full.names = TRUE))
segment_files <- segment_files[file.info(segment_files)$size > 4]
parts <- lapply(segment_files, utils::read.csv, stringsAsFactors = FALSE)
full <- bind_rows_fill(parts)
if (nrow(full) > 0 && "timestamp" %in% names(full)) full <- full[order(full$timestamp), , drop = FALSE]
utils::write.csv(
  full,
  file.path(result_dir, paste0(site, "_flux_no_rotation.csv")),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

message(sprintf("Done %s | months=%d | rows=%d | output=%s", site, length(segment_files), nrow(full), file.path(result_dir, paste0(site, "_flux_no_rotation.csv"))))
