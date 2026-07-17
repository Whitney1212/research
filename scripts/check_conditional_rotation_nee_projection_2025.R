#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

args <- commandArgs(trailingOnly = TRUE)
arg_value <- function(prefix, default = NULL) {
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) return(default)
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

year <- as.integer(arg_value("--year=", "2025"))
output_root <- arg_value(
  "--output-root=",
  sprintf("E:/Dataset_Level1/Rotation/nee_aligned_projection_%d_rebuild/conditional_projection_analysis", year)
)
methods <- c("no_rotation", "dr", "global_pf", "sector_pf")
half_hour_gC <- 1800 * 12e-6

stop_check <- function(condition, message) {
  if (!isTRUE(condition)) stop(message, call. = FALSE)
}

window_file <- file.path(output_root, sprintf("projection_by_window_with_conditions_%d.csv", year))
summary_file <- file.path(output_root, sprintf("conditional_projection_summary_%d.csv", year))
cumulative_file <- file.path(output_root, sprintf("annual_cumulative_projection_%d.csv", year))
for (path in c(window_file, summary_file, cumulative_file)) {
  stop_check(file.exists(path), paste("Missing check input:", path))
}

x <- fread(window_file, colClasses = list(character = "timestamp"), showProgress = FALSE)
summary <- fread(summary_file, showProgress = FALSE)
cumulative <- fread(cumulative_file, colClasses = list(character = "timestamp"), showProgress = FALSE)

stop_check(setequal(unique(x$method), methods), "Window method set is not exactly the four declared methods.")
stop_check(setequal(unique(summary$method), methods), "Summary method set is not exactly the four declared methods.")
stop_check(setequal(unique(cumulative$method), setdiff(methods, "no_rotation")), "Cumulative method set is not exactly the three rotated methods.")

duplicate_windows <- x[, .N, by = .(tower, method, timestamp)][N > 1L]
stop_check(!nrow(duplicate_windows), "Duplicate tower/method/timestamp rows found in window output.")

per_method_counts <- x[, .(n_windows = uniqueN(timestamp)), by = .(tower, method)]
expected_counts <- data.table(tower = c("MT", "CVT"), expected = c(14469L, 14431L))
count_check <- merge(per_method_counts, expected_counts, by = "tower", all.x = TRUE)
stop_check(all(count_check$n_windows == count_check$expected), "Common window counts do not match MT=14469 and CVT=14431.")

per_timestamp_methods <- x[, .(n_methods = uniqueN(method)), by = .(tower, timestamp)]
stop_check(all(per_timestamp_methods$n_methods == length(methods)), "Not every retained timestamp contains all four methods.")

x[, window_closure_residual := delta_projection_u + delta_projection_v + delta_projection_w - delta_co2_flux]
max_window_residual <- max(abs(x$window_closure_residual), na.rm = TRUE)
stop_check(is.finite(max_window_residual) && max_window_residual <= 1e-8, "Per-window u+v+w=DeltaF closure failed.")

annual_check <- x[, .(
  delta_u = sum(delta_projection_u, na.rm = TRUE) * half_hour_gC,
  delta_v = sum(delta_projection_v, na.rm = TRUE) * half_hour_gC,
  delta_w = sum(delta_projection_w, na.rm = TRUE) * half_hour_gC,
  delta_f = sum(delta_co2_flux, na.rm = TRUE) * half_hour_gC
), by = .(tower, method)]
annual_check[, annual_closure_residual := delta_u + delta_v + delta_w - delta_f]
max_annual_residual <- max(abs(annual_check$annual_closure_residual), na.rm = TRUE)
stop_check(is.finite(max_annual_residual) && max_annual_residual <= 1e-8, "Annual cumulative closure failed.")

summary[, summary_closure_residual := delta_u_net_gC_m2 + delta_v_net_gC_m2 + delta_w_net_gC_m2 - delta_total_net_gC_m2]
max_summary_residual <- max(abs(summary$summary_closure_residual), na.rm = TRUE)
stop_check(is.finite(max_summary_residual) && max_summary_residual <= 1e-8, "Conditional summary closure failed.")

cumulative[, cumulative_closure_residual := cumulative_delta_gC_m2 - cumulative_delta_u_gC_m2 - cumulative_delta_v_gC_m2 - cumulative_delta_w_gC_m2]
max_cumulative_residual <- max(abs(cumulative$cumulative_closure_residual), na.rm = TRUE)
stop_check(is.finite(max_cumulative_residual) && max_cumulative_residual <= 1e-8, "Annual cumulative curve closure failed.")

cat("CHECK PASSED\n")
cat(sprintf("method_set=%s\n", paste(methods, collapse = ",")))
cat(sprintf("common_windows=MT:%d,CVT:%d\n", expected_counts[tower == "MT", expected], expected_counts[tower == "CVT", expected]))
cat(sprintf("max_abs_window_closure_residual=%.3e\n", max_window_residual))
cat(sprintf("max_abs_annual_closure_residual=%.3e\n", max_annual_residual))
cat(sprintf("max_abs_summary_closure_residual=%.3e\n", max_summary_residual))
cat(sprintf("max_abs_cumulative_curve_residual=%.3e\n", max_cumulative_residual))
