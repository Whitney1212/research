#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

fail <- function(...) stop(..., call. = FALSE)

expect_true <- function(value, message) {
  if (!isTRUE(value)) fail(message)
}

file_arg <- commandArgs(trailingOnly = FALSE)[grep("^--file=", commandArgs(trailingOnly = FALSE))][1]
test_file <- sub("^--file=", "", file_arg)
script_dir <- normalizePath(
  file.path(dirname(test_file), ".."),
  winslash = "/",
  mustWork = TRUE
)
incremental_script <- file.path(script_dir, "scripts", "update_fl_complete_passes_incremental.R")
strict_script <- "E:/Dataset_RAW/Flares/运行记录/unified_output/02_mark_complete_passes_strict.R"
plot_script <- file.path(script_dir, "scripts", "plot_fl_complete_pass_coverage_gantt.R")

tmp <- tempfile("fl_incremental_test_")
dir.create(tmp, recursive = TRUE)
on.exit({
  if (Sys.getenv("KEEP_TEST_TMP", unset = "0") == "1") {
    cat("Kept test directory: ", tmp, "\n", sep = "")
  } else {
    unlink(tmp, recursive = TRUE, force = TRUE)
  }
}, add = TRUE)

master_dir <- file.path(tmp, "master")
raw_root <- file.path(tmp, "raw")
dir.create(master_dir, recursive = TRUE)
dir.create(raw_root, recursive = TRUE)

make_pass <- function(start_time, direction) {
  seconds <- 0:1800
  start <- as.POSIXct(start_time, tz = "Asia/Shanghai")
  position <- if (direction == "fw") {
    5 + 235 * seconds / max(seconds)
  } else {
    240 - 235 * seconds / max(seconds)
  }
  data.table(
    time = format(start + seconds, "%Y-%m-%d %H:%M:%OS3", tz = "Asia/Shanghai"),
    speed = if (direction == "fw") 13.7 else -13.7,
    position = position
  )
}

running <- rbindlist(list(
  make_pass("2025-01-02 00:00:00", "fw"),
  make_pass("2025-01-02 00:31:00", "bw")
))
running <- unique(running, by = "time")
unified_csv <- file.path(tmp, "fl_running_records_unified.csv")
fwrite(running, unified_csv)

old_strict <- data.table(
  pass_id = 1L,
  start_time_local = "2025-01-01 00:00:15",
  end_time_local = "2025-01-01 00:29:45",
  time = "2025-01-01 00:00:15 to 2025-01-01 00:29:45",
  direction = "fw",
  moving_direction = "south_to_north",
  strict_complete = TRUE,
  geometry_complete = TRUE,
  ec_data_available = TRUE,
  reject_reason = "ok"
)
fwrite(old_strict, file.path(master_dir, "fl_complete_passes_strict.csv"))

old_candidates <- copy(old_strict)
setnames(old_candidates, "pass_id", "candidate_id")
fwrite(old_candidates, file.path(master_dir, "fl_complete_pass_candidates_all.csv"))

ec_start <- as.POSIXct("2025-01-02 00:10:00", tz = "Asia/Shanghai")
ec_times <- ec_start + seq(0, 59.9, by = 0.1)
toa5_path <- file.path(raw_root, "14894.Time_Series_999.dat")
toa5_header <- c(
  '"TOA5","test"',
  '"TIMESTAMP","Ux","Uy","Uz","CO2","TA_1_1_1","PA","diag_sonic","diag_irga"',
  '"TS","m/s","m/s","m/s","umol/mol","degC","kPa","",""',
  '"","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp"'
)
toa5_rows <- sprintf(
  '"%s",1,1,0.1,450,20,95,0,0',
  format(ec_times, "%Y-%m-%d %H:%M:%OS3", tz = "Asia/Shanghai")
)
writeLines(c(toa5_header, toa5_rows), toa5_path, useBytes = TRUE)
writeLines(
  c(
    '"TOA5","test"',
    '"TIMESTAMP","flux"',
    '"TS","unit"',
    '"","Smp"',
    '"2025-01-02 00:10:00.000",1'
  ),
  file.path(raw_root, "TOA5_flux_2025_01_02_0000.dat"),
  useBytes = TRUE
)

rscript <- file.path(R.home("bin"), "Rscript.exe")
args <- c(
  shQuote(incremental_script),
  shQuote(paste0("--unified-csv=", unified_csv)),
  shQuote(paste0("--strict-script=", strict_script)),
  shQuote(paste0("--plot-script=", plot_script)),
  shQuote(paste0("--master-dir=", master_dir)),
  shQuote(paste0("--raw-root=", raw_root)),
  shQuote("--start=2025-01-02 00:00:00"),
  shQuote("--lookback-hours=2")
)
output <- system2(rscript, args, stdout = TRUE, stderr = TRUE)
status <- attr(output, "status")
if (is.null(status)) status <- 0L
if (status != 0L) {
  fail("Incremental command failed:\n", paste(output, collapse = "\n"))
}

time_classes <- list(character = c("start_time_local", "end_time_local", "time"))
strict <- fread(
  file.path(master_dir, "fl_complete_passes_strict.csv"),
  colClasses = time_classes
)
candidates <- fread(
  file.path(master_dir, "fl_complete_pass_candidates_all.csv"),
  colClasses = time_classes
)

expect_true(nrow(strict) == 2L, "Expected one historical and one new EC-valid strict pass.")
expect_true(
  any(strict$start_time_local == "2025-01-01 00:00:15"),
  "Historical strict pass was not preserved."
)
new_strict <- strict[substr(start_time_local, 1, 10) == "2025-01-02"]
expect_true(nrow(new_strict) == 1L, "Expected exactly one new EC-valid strict pass.")
expect_true(new_strict$n_ec_valid_minutes[1] >= 1L, "New strict pass lacks a valid EC minute.")

new_candidates <- candidates[substr(start_time_local, 1, 10) == "2025-01-02"]
expect_true(nrow(new_candidates) == 2L, "Expected both new geometric candidates in the merged candidate table.")
expect_true(
  sum(new_candidates$strict_complete == TRUE) == 1L,
  "A candidate without a valid EC minute was incorrectly retained."
)
expect_true(
  any(new_candidates$ec_reject_reason == "no_key_complete_ec_row_in_pass"),
  "Missing-EC candidate did not retain its rejection reason."
)

timeline <- file.path(master_dir, "fl_complete_pass_coverage_timeline.png")
expect_true(file.exists(timeline), "Coverage timeline was not redrawn.")
expect_true(file.info(timeline)$size > 1000, "Coverage timeline output is unexpectedly small.")

manifest <- file.path(master_dir, "fl_complete_passes_incremental_manifest.txt")
expect_true(file.exists(manifest), "Incremental manifest was not written.")
manifest_lines <- readLines(manifest, warn = FALSE)
manifest_text <- paste(manifest_lines, collapse = "\n")
expect_true(grepl("mode: incremental", manifest_text, fixed = TRUE), "Manifest does not record incremental mode.")
expect_true(
  identical(grep("^raw_files_indexed:", manifest_lines, value = TRUE), "raw_files_indexed: 1"),
  "EC raw index included a dated file without the required high-frequency columns."
)

cat("PASS: incremental strict-pass update preserves history, enforces EC-minute QC, and redraws coverage.\n")
