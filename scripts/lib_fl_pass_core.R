#!/usr/bin/env Rscript

# Required entry point for FL pass-derived products: preserve local wall-clock
# strings, then reuse the verified core parser rather than reimplementing time.
suppressPackageStartupMessages(library(data.table))

fl_core_runner <- "D:/00 博士阶段/99 Project/06 EA/scripts/run_fl_no_rotation_pass_air_accumulation.R"
Sys.setenv(NO_ROTATION_SOURCE_ONLY = "1")
source(fl_core_runner, local = .GlobalEnv)

read_fl_pass_table_local <- function(path, time_columns = "pass_mid_time_local") {
  x <- fread(path, colClasses = list(character = time_columns), showProgress = FALSE)
  if (!all(vapply(time_columns, function(col) is.character(x[[col]]), logical(1)))) stop("FL pass time columns must remain character: ", path, call. = FALSE)
  x
}

fl_pass_core_self_check <- function() {
  t <- parse_bundle_time("2023-04-17 12:52:28.500")
  stopifnot(format(t, "%H:%M", tz = tz_local) == "12:52")
  invisible(TRUE)
}
