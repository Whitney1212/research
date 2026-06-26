#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

file_arg <- commandArgs(trailingOnly = FALSE)[grep("^--file=", commandArgs(trailingOnly = FALSE))][1]
test_file <- sub("^--file=", "", file_arg)
project_dir <- normalizePath(file.path(dirname(test_file), ".."), winslash = "/", mustWork = TRUE)
plot_script <- file.path(project_dir, "scripts", "plot_fl_running_gantt.R")

lines <- readLines(plot_script, warn = FALSE, encoding = "UTF-8")
main_call <- grep("^main\\(\\)$", trimws(lines))
if (length(main_call) != 1L) stop("Could not isolate plot script functions.", call. = FALSE)
env <- new.env(parent = globalenv())
eval(parse(text = paste(lines[seq_len(main_call - 1L)], collapse = "\n")), envir = env)

tmp <- tempfile("fl_gantt_labels_test_")
dir.create(tmp)
on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)
writeLines("time,speed,position", file.path(tmp, "a.csv"))
writeLines("time,speed,position", file.path(tmp, "b.csv"))

summary_dt <- data.table(
  source_file = c("registered_second.csv", "registered_first.csv"),
  source_mode = c("fbox_csv", "standard_csv"),
  rows_valid = c(10L, 20L),
  time_min = c("2025-01-02 00:00:00.000", "2025-01-01 00:00:00.000"),
  time_max = c("2025-01-02 01:00:00.000", "2025-01-01 01:00:00.000")
)

result <- env$recover_source_labels(copy(summary_dt), tmp)
if (!identical(result$source_file, summary_dt$source_file)) {
  stop("Existing source_file labels were overwritten by directory order.", call. = FALSE)
}

cat("PASS: running-record Gantt preserves registered source labels.\n")
