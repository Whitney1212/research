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
plot_script <- file.path(project_dir, "scripts", "plot_fl_running_gantt.R")

tmp <- tempfile("fl_running_incremental_test_")
dir.create(tmp, recursive = TRUE)
on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)

new_input_dir <- file.path(tmp, "new_batch")
dir.create(new_input_dir)

existing_unified <- file.path(tmp, "fl_running_records_unified.csv")
existing_summary <- file.path(tmp, "fl_running_records_file_summary.csv")
pending_unified <- file.path(tmp, "fl_running_records_unified.pending.csv")
pending_summary <- file.path(tmp, "fl_running_records_file_summary.pending.csv")
pending_gantt <- file.path(tmp, "fl_running_records_gantt.pending.png")

existing <- data.table(
  time = c(
    "2025-01-01 00:00:00.727",
    "2025-01-01 00:00:01.000",
    "2025-01-01 00:00:02.000"
  ),
  speed = c(13.7, 13.7, 13.7),
  position = c(5, 6, 7)
)
fwrite(existing, existing_unified)

summary_old <- data.table(
  source_file = "old_running.csv",
  source_mode = "standard_csv",
  rows_read = 3L,
  rows_valid = 3L,
  time_min = "2025-01-01 00:00:00.727",
  time_max = "2025-01-01 00:00:02.000"
)
fwrite(summary_old, existing_summary)

fbox_path <- file.path(new_input_dir, "fbox_hdata_20250101-20250101.csv")
writeLines(
  c(
    "FBOX export",
    "time,小车位置(m),小车运行速度(cm/s)",
    "2025-01-01 00:00:02.000,7,13.7",
    "2025-01-01 00:00:03.000,8,13.7",
    "2025-01-01 00:00:04.000,9,13.7"
  ),
  fbox_path,
  useBytes = TRUE
)

before <- fread(existing_unified, colClasses = list(character = "time"))
rscript <- file.path(R.home("bin"), "Rscript.exe")
args <- c(
  shQuote(incremental_script),
  shQuote(paste0("--existing-unified=", existing_unified)),
  shQuote(paste0("--existing-summary=", existing_summary)),
  shQuote(paste0("--new-file=", fbox_path)),
  shQuote(paste0("--output-unified=", pending_unified)),
  shQuote(paste0("--output-summary=", pending_summary)),
  shQuote("--output-gantt="),
  shQuote("--dedupe-by=full_row")
)
output <- system2(rscript, args, stdout = TRUE, stderr = TRUE)
status <- attr(output, "status")
if (is.null(status)) status <- 0L
if (status != 0L) {
  fail("Incremental running-record command failed:\n", paste(output, collapse = "\n"))
}

after <- fread(existing_unified, colClasses = list(character = "time"))
pending <- fread(pending_unified, colClasses = list(character = "time"))
summary_pending <- fread(
  pending_summary,
  colClasses = list(character = c("source_file", "source_mode", "time_min", "time_max"))
)

expect_true(identical(before, after), "Existing unified table was modified.")
expect_true(nrow(pending) == 5L, "Pending table should contain three historical and two new rows.")
expect_true(uniqueN(pending[, .(time, speed, position)]) == 5L, "Exact boundary duplicate was not removed.")
expect_true(
  identical(
    pending$time,
    c(
      "2025-01-01 00:00:00.727",
      "2025-01-01 00:00:01.000",
      "2025-01-01 00:00:02.000",
      "2025-01-01 00:00:03.000",
      "2025-01-01 00:00:04.000"
    )
  ),
  "Pending rows are not complete and time ordered."
)
expect_true(nrow(summary_pending) == 2L, "Pending summary should contain one historical and one new source.")
expect_true(
  any(summary_pending$source_file == basename(fbox_path) & summary_pending$rows_valid == 3L),
  "New FBOX source was not registered correctly."
)
manifest <- paste0(pending_unified, ".manifest.txt")
expect_true(!file.exists(pending_gantt), "Default-like execution generated an unwanted Gantt file.")
expect_true(!file.exists(manifest), "Execution generated an unwanted manifest file.")

cat("PASS: incremental running-record update preserves history and writes only data plus summary.\n")
