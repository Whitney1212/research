#!/usr/bin/env Rscript

file_arg <- commandArgs(trailingOnly = FALSE)[grep("^--file=", commandArgs(trailingOnly = FALSE))][1]
test_file <- sub("^--file=", "", file_arg)
project_dir <- normalizePath(file.path(dirname(test_file), ".."), winslash = "/", mustWork = TRUE)
script_path <- file.path(project_dir, "scripts", "update_fl_complete_passes_incremental.R")

lines <- readLines(script_path, warn = FALSE, encoding = "UTF-8")
main_call <- grep("^main\\(\\)$", trimws(lines))
if (length(main_call) != 1L) stop("Could not isolate incremental complete-pass functions.", call. = FALSE)
env <- new.env(parent = globalenv())
eval(parse(text = paste(lines[seq_len(main_call - 1L)], collapse = "\n")), envir = env)

actual <- env$extract_date_token(c(
  "14894.Time_Series_999.dat",
  "TOA5_flux_2025_01_02_0000.dat"
))
expected <- c(NA_character_, "2025_01_02")
if (!identical(actual, expected)) {
  stop("Mixed filename date extraction failed: ", paste(actual, collapse = ", "), call. = FALSE)
}

cat("PASS: EC raw-index date extraction handles mixed filename formats.\n")
