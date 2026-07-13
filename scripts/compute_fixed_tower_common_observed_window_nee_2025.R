#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

year <- 2025L
windows_per_year <- 17520L
common_methods <- c("no_rotation", "dr", "global_pf", "sector_pf")
args <- commandArgs(trailingOnly = TRUE)
scenario <- "strict"
for (arg in args) {
  if (startsWith(arg, "--scenario=")) scenario <- sub("^--scenario=", "", arg)
}

if (scenario == "strict") {
  root <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d", year)
  run_plan_file <- file.path(root, sprintf("rotation_sensitivity_standardized_%d_run_plan.csv", year))
  annual_file <- file.path(root, sprintf("rotation_sensitivity_standardized_%d_common_four_methods_summary.csv", year))
  output_tag <- ""
} else if (scenario == "no_qc_no_flag9") {
  root <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d_no_qc_no_flag9", year)
  run_plan_file <- file.path(root, sprintf("rotation_sensitivity_standardized_%d_no_qc_no_flag9_run_plan.csv", year))
  annual_file <- file.path(root, sprintf("rotation_sensitivity_standardized_%d_no_qc_no_flag9_annual_summary_all_methods.csv", year))
  output_tag <- "no_qc_no_flag9"
} else {
  stop("Unsupported --scenario: ", scenario, call. = FALSE)
}

out_dir <- file.path(root, "common_observed_window_nee")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path)
}

gapfilled_file <- function(tower, method_output_dir) {
  tag <- if (identical(output_tag, "")) "" else paste0("_", output_tag)
  file.path(method_output_dir, sprintf("%s_nee_%d_estimate%s_30min_gapfilled.csv", tower, year, tag))
}

read_case <- function(case_row) {
  path <- gapfilled_file(case_row$tower[[1]], case_row$method_output_dir[[1]])
  dt <- read_required(path)
  keep <- c("ts_key", "tower", "method", "valid_final", "co2_flux", "observed_component_gC_m2")
  if (!all(c("ts_key", "valid_final", "co2_flux", "observed_component_gC_m2") %in% names(dt))) {
    stop("Missing required columns in ", path, call. = FALSE)
  }
  out <- dt[, .(
    ts_key,
    tower = case_row$tower[[1]],
    method = case_row$method[[1]],
    valid_final = as.logical(valid_final),
    co2_flux = as.numeric(co2_flux),
    observed_component_gC_m2 = as.numeric(observed_component_gC_m2)
  )]
  out
}

run_plan <- read_required(run_plan_file)
run_plan <- run_plan[common_method == TRUE & method %in% common_methods]
annual <- read_required(annual_file)
if ("common_method" %in% names(annual)) {
  annual <- annual[common_method == TRUE & method %in% common_methods]
}

case_dt <- rbindlist(lapply(seq_len(nrow(run_plan)), function(i) read_case(run_plan[i])), use.names = TRUE)

paired <- merge(
  case_dt[tower == "MT"],
  case_dt[tower == "CVT"],
  by = c("method", "ts_key"),
  suffixes = c("_mt", "_cvt")
)
paired[, common_valid_observed := valid_final_mt & valid_final_cvt]
common_pairs <- paired[common_valid_observed == TRUE]

stopifnot(uniqueN(common_pairs$method) == length(common_methods))
stopifnot(all(common_pairs[, .N, by = method]$N > 0L))

common_tower_summary <- rbindlist(list(
  common_pairs[, .(
    common_observed_windows = .N,
    common_observed_percent_of_year = .N / windows_per_year * 100,
    common_observed_flux_mean_umol_m2_s = mean(co2_flux_mt),
    common_observed_nee_sum_gC_m2 = sum(observed_component_gC_m2_mt),
    common_observed_nee_annualized_gC_m2 = mean(observed_component_gC_m2_mt) * windows_per_year
  ), by = method][, tower := "MT"],
  common_pairs[, .(
    common_observed_windows = .N,
    common_observed_percent_of_year = .N / windows_per_year * 100,
    common_observed_flux_mean_umol_m2_s = mean(co2_flux_cvt),
    common_observed_nee_sum_gC_m2 = sum(observed_component_gC_m2_cvt),
    common_observed_nee_annualized_gC_m2 = mean(observed_component_gC_m2_cvt) * windows_per_year
  ), by = method][, tower := "CVT"]
), use.names = TRUE)
setcolorder(common_tower_summary, c("tower", "method"))
common_tower_summary <- common_tower_summary[
  order(match(tower, c("MT", "CVT")), match(method, common_methods))
]

common_diff <- merge(
  common_tower_summary[tower == "MT"],
  common_tower_summary[tower == "CVT"],
  by = "method",
  suffixes = c("_mt", "_cvt")
)
common_diff[, `:=`(
  mt_minus_cvt_common_observed_nee_sum_gC_m2 = common_observed_nee_sum_gC_m2_mt - common_observed_nee_sum_gC_m2_cvt,
  mt_minus_cvt_common_observed_nee_annualized_gC_m2 = common_observed_nee_annualized_gC_m2_mt - common_observed_nee_annualized_gC_m2_cvt
)]

annual_diff <- merge(
  annual[tower == "MT", .(method, annual_nee_estimate_gC_m2_mt = annual_nee_estimate_gC_m2)],
  annual[tower == "CVT", .(method, annual_nee_estimate_gC_m2_cvt = annual_nee_estimate_gC_m2)],
  by = "method"
)
annual_diff[, mt_minus_cvt_gapfilled_annual_nee_gC_m2 := annual_nee_estimate_gC_m2_mt - annual_nee_estimate_gC_m2_cvt]

diff_summary <- merge(
  common_diff[, .(
    method,
    common_observed_windows = common_observed_windows_mt,
    common_observed_percent_of_year = common_observed_percent_of_year_mt,
    mt_minus_cvt_common_observed_nee_sum_gC_m2,
    mt_minus_cvt_common_observed_nee_annualized_gC_m2
  )],
  annual_diff[, .(method, mt_minus_cvt_gapfilled_annual_nee_gC_m2)],
  by = "method"
)
diff_summary[, `:=`(
  gapfilled_minus_common_annualized_difference_gC_m2 =
    mt_minus_cvt_gapfilled_annual_nee_gC_m2 - mt_minus_cvt_common_observed_nee_annualized_gC_m2,
  abs_gapfilled_minus_common_annualized_difference_gC_m2 =
    abs(mt_minus_cvt_gapfilled_annual_nee_gC_m2 - mt_minus_cvt_common_observed_nee_annualized_gC_m2)
)]
diff_summary[, abs_difference_percent_of_gapfilled_difference :=
  abs_gapfilled_minus_common_annualized_difference_gC_m2 / abs(mt_minus_cvt_gapfilled_annual_nee_gC_m2) * 100
]
diff_summary <- diff_summary[order(match(method, common_methods))]

paired_out <- common_pairs[, .(
  method,
  ts_key,
  co2_flux_mt,
  co2_flux_cvt,
  observed_component_gC_m2_mt,
  observed_component_gC_m2_cvt,
  mt_minus_cvt_observed_component_gC_m2 = observed_component_gC_m2_mt - observed_component_gC_m2_cvt
)]
paired_out <- paired_out[order(match(method, common_methods), ts_key)]

fwrite(common_tower_summary, file.path(out_dir, "fixed_tower_common_observed_window_nee_by_tower_method_2025.csv"))
fwrite(diff_summary, file.path(out_dir, "fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv"))
fwrite(paired_out, file.path(out_dir, "fixed_tower_common_observed_window_30min_pairs_2025.csv"))

writeLines(c(
  "Fixed-tower common-observed-window NEE check",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  paste0("Scenario: ", scenario),
  "",
  "Definition:",
  "- Uses existing per-method 30 min gapfilled outputs.",
  "- Keeps only timestamps where MT and CVT are both valid_final == TRUE for the same rotation method.",
  "- common_observed_nee_sum_gC_m2 is the direct sum over those shared observed windows only.",
  "- common_observed_nee_annualized_gC_m2 scales the mean shared-window half-hour component to 17520 windows; this is a diagnostic, not a replacement annual NEE.",
  "",
  "Outputs:",
  "- fixed_tower_common_observed_window_nee_by_tower_method_2025.csv",
  "- fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv",
  "- fixed_tower_common_observed_window_30min_pairs_2025.csv"
), file.path(out_dir, "fixed_tower_common_observed_window_nee_2025_summary.txt"), useBytes = TRUE)

print(common_tower_summary)
print(diff_summary)
