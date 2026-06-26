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
project_dir <- normalizePath(file.path(dirname(test_file), ".."), winslash = "/", mustWork = TRUE)
incremental_script <- file.path(project_dir, "scripts", "update_fl_running_records_incremental.R")

tmp <- tempfile("fl_running_stationary_test_")
dir.create(tmp, recursive = TRUE)
on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)

existing_unified <- file.path(tmp, "fl_running_records_unified.csv")
existing_summary <- file.path(tmp, "fl_running_records_file_summary.csv")
pending_unified <- file.path(tmp, "fl_running_records_unified.pending.csv")
pending_summary <- file.path(tmp, "fl_running_records_file_summary.pending.csv")

existing <- data.table(
  time = "2025-01-01 23:59:00.000",
  speed = 13.7,
  position = 5
)
fwrite(existing, existing_unified)

summary_old <- data.table(
  source_file = "old_running.csv",
  source_mode = "standard_csv",
  rows_read = 1L,
  rows_valid = 1L,
  time_min = "2025-01-01 23:59:00.000",
  time_max = "2025-01-01 23:59:00.000"
)
fwrite(summary_old, existing_summary)

static_times <- seq(
  as.POSIXct("2025-01-02 00:00:00", tz = "Asia/Shanghai"),
  as.POSIXct("2025-01-02 00:16:00", tz = "Asia/Shanghai"),
  length.out = 300
)
new_dt <- rbindlist(list(
  data.table(
    time = format(static_times, "%Y-%m-%d %H:%M:%OS3", tz = "Asia/Shanghai"),
    speed = 0,
    position = 10
  ),
  data.table(
    time = c("2025-01-02 00:16:30.000", "2025-01-02 00:17:00.000"),
    speed = c(13.7, 13.7),
    position = c(11, 12)
  )
))
new_path <- file.path(tmp, "new_standard.csv")
fwrite(new_dt, new_path)

rscript <- file.path(R.home("bin"), "Rscript.exe")
args <- c(
  shQuote(incremental_script),
  shQuote(paste0("--existing-unified=", existing_unified)),
  shQuote(paste0("--existing-summary=", existing_summary)),
  shQuote(paste0("--new-file=", new_path)),
  shQuote(paste0("--output-unified=", pending_unified)),
  shQuote(paste0("--output-summary=", pending_summary)),
  shQuote("--output-gantt="),
  shQuote("--stationary-position-tolerance-m=0.001"),
  shQuote("--min-stationary-duration-min=15"),
  shQuote("--min-stationary-points=300")
)
output <- system2(rscript, args, stdout = TRUE, stderr = TRUE)
status <- attr(output, "status")
if (is.null(status)) status <- 0L
if (status != 0L) {
  fail("Incremental running-record command failed:\n", paste(output, collapse = "\n"))
}

pending <- fread(pending_unified, colClasses = list(character = "time"))
summary_pending <- fread(
  pending_summary,
  colClasses = list(character = c("source_file", "source_mode", "time_min", "time_max"))
)
new_summary <- summary_pending[source_file == basename(new_path)]

expect_true(nrow(pending) == 5L, "Pending table should contain one old row plus four compressed new rows.")
expect_true(new_summary$rows_valid == 302L, "New source valid row count changed unexpectedly.")
expect_true(
  new_summary$rows_after_stationary_compression == 4L,
  "Stationary compression did not retain only stop boundaries and moving rows."
)
expect_true(new_summary$stationary_rows_removed == 298L, "Unexpected stationary row removal count.")
expect_true(new_summary$stationary_stop_segments == 1L, "Expected exactly one long stationary segment.")
expect_true(
  all(c("2025-01-02 00:00:00.000", "2025-01-02 00:16:00.000") %in% pending$time),
  "Stationary segment boundary points were not preserved."
)
expect_true(
  all(c("2025-01-02 00:16:30.000", "2025-01-02 00:17:00.000") %in% pending$time),
  "Moving rows after stationary compression were not preserved."
)

cat("PASS: long stationary running-record segments are compressed to first/last points.\n")
