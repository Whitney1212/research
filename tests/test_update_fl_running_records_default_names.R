#!/usr/bin/env Rscript

file_arg <- commandArgs(trailingOnly = FALSE)[grep("^--file=", commandArgs(trailingOnly = FALSE))][1]
test_file <- sub("^--file=", "", file_arg)
project_dir <- normalizePath(file.path(dirname(test_file), ".."), winslash = "/", mustWork = TRUE)
script_path <- file.path(project_dir, "scripts", "update_fl_running_records_incremental.R")

lines <- readLines(script_path, warn = FALSE, encoding = "UTF-8")
main_call <- grep("^main\\(\\)$", trimws(lines))
if (length(main_call) != 1L) stop("Could not isolate incremental script functions.", call. = FALSE)
env <- new.env(parent = globalenv())
eval(parse(text = paste(lines[seq_len(main_call - 1L)], collapse = "\n")), envir = env)

opts <- env$parse_args("--new-file=dummy.csv")
date_token <- format(Sys.Date(), "%Y%m%d")
expected <- c(
  paste0("all_data_", date_token, ".csv"),
  paste0("all_data_", date_token, "_file_summary.csv")
)
actual <- basename(c(opts$output_unified, opts$output_summary))

if (!identical(actual, expected)) {
  stop(
    "Default output names are not based on all_data_YYYYMMDD: ",
    paste(actual, collapse = ", "),
    call. = FALSE
  )
}

expected_dir <- normalizePath(
  "E:/Dataset_Level0/Flares/running_time",
  winslash = "/",
  mustWork = FALSE
)
actual_dirs <- normalizePath(
  dirname(c(opts$output_unified, opts$output_summary)),
  winslash = "/",
  mustWork = FALSE
)
if (!all(tolower(actual_dirs) == tolower(expected_dir))) {
  stop("Default outputs are not under E:/Dataset_Level0/Flares/running_time.", call. = FALSE)
}
if (!is.na(opts$output_gantt)) {
  stop("Default execution still enables a Gantt output.", call. = FALSE)
}

expected_existing <- normalizePath(
  c(
    "E:/Dataset_RAW/Flares/运行记录/unified_output/fl_running_records_unified.csv",
    "E:/Dataset_RAW/Flares/运行记录/unified_output/fl_running_records_file_summary.csv"
  ),
  winslash = "/",
  mustWork = FALSE
)
actual_existing <- normalizePath(
  c(opts$existing_unified, opts$existing_summary),
  winslash = "/",
  mustWork = FALSE
)
if (!all(tolower(actual_existing) == tolower(expected_existing))) {
  stop("Default historical inputs no longer point to RAW/unified_output.", call. = FALSE)
}

cat("PASS: incremental running-record defaults use all_data_YYYYMMDD names.\n")
