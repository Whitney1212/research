#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

year <- 2025L
common_methods <- c("no_rotation", "dr", "global_pf", "sector_pf")
scenarios <- c("strict", "no_qc_no_flag9")
window_start_hour <- 10
window_end_hour <- 18

scenario_paths <- function(scenario) {
  if (scenario == "strict") {
    root <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d", year)
    list(
      root = root,
      run_plan = file.path(root, sprintf("rotation_sensitivity_standardized_%d_run_plan.csv", year)),
      annual = file.path(root, sprintf("rotation_sensitivity_standardized_%d_common_four_methods_summary.csv", year)),
      output_tag = ""
    )
  } else if (scenario == "no_qc_no_flag9") {
    root <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d_no_qc_no_flag9", year)
    list(
      root = root,
      run_plan = file.path(root, sprintf("rotation_sensitivity_standardized_%d_no_qc_no_flag9_run_plan.csv", year)),
      annual = file.path(root, sprintf("rotation_sensitivity_standardized_%d_no_qc_no_flag9_annual_summary_all_methods.csv", year)),
      output_tag = "no_qc_no_flag9"
    )
  } else {
    stop("Unsupported scenario: ", scenario, call. = FALSE)
  }
}

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path)
}

gapfilled_file <- function(tower, method_output_dir, output_tag) {
  tag <- if (identical(output_tag, "")) "" else paste0("_", output_tag)
  file.path(method_output_dir, sprintf("%s_nee_%d_estimate%s_30min_gapfilled.csv", tower, year, tag))
}

read_case <- function(case_row, output_tag) {
  path <- gapfilled_file(case_row$tower[[1]], case_row$method_output_dir[[1]], output_tag)
  dt <- read_required(path)
  required <- c("ts_key", "hour", "minute", "fill_method", "total_component_gC_m2")
  if (!all(required %in% names(dt))) stop("Missing required columns in ", path, call. = FALSE)
  dt[, .(
    ts_key,
    tower = case_row$tower[[1]],
    method = case_row$method[[1]],
    hour = as.integer(hour),
    minute = as.integer(minute),
    is_gapfilled = fill_method != "observed_valid",
    total_component_gC_m2 = as.numeric(total_component_gC_m2)
  )]
}

classify_pair_group <- function(mt_gapfilled, cvt_gapfilled) {
  fcase(
    !mt_gapfilled & !cvt_gapfilled, "both_observed",
    mt_gapfilled & !cvt_gapfilled, "MT_gapfilled_only",
    !mt_gapfilled & cvt_gapfilled, "CVT_gapfilled_only",
    mt_gapfilled & cvt_gapfilled, "both_gapfilled"
  )
}

process_scenario <- function(scenario) {
  cfg <- scenario_paths(scenario)
  out_dir <- file.path(cfg$root, "time_window_difference")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  run_plan <- read_required(cfg$run_plan)
  run_plan <- run_plan[common_method == TRUE & method %in% common_methods]
  annual <- read_required(cfg$annual)
  if ("common_method" %in% names(annual)) {
    annual <- annual[common_method == TRUE & method %in% common_methods]
  }

  case_dt <- rbindlist(lapply(seq_len(nrow(run_plan)), function(i) read_case(run_plan[i], cfg$output_tag)), use.names = TRUE)
  paired <- merge(
    case_dt[tower == "MT"],
    case_dt[tower == "CVT"],
    by = c("method", "ts_key"),
    suffixes = c("_mt", "_cvt")
  )
  paired[, `:=`(
    in_10_18 = hour_mt >= window_start_hour & hour_mt < window_end_hour,
    pair_group = classify_pair_group(is_gapfilled_mt, is_gapfilled_cvt),
    delta_gC_m2_cvt_minus_mt = total_component_gC_m2_cvt - total_component_gC_m2_mt
  )]

  annual_diff <- merge(
    annual[tower == "CVT", .(method, annual_nee_estimate_gC_m2_cvt = annual_nee_estimate_gC_m2)],
    annual[tower == "MT", .(method, annual_nee_estimate_gC_m2_mt = annual_nee_estimate_gC_m2)],
    by = "method"
  )
  annual_diff[, annual_delta_gC_m2_cvt_minus_mt := annual_nee_estimate_gC_m2_cvt - annual_nee_estimate_gC_m2_mt]

  summary <- merge(
    paired[, .(
      windows_10_18 = sum(in_10_18),
      delta_10_18_gC_m2_cvt_minus_mt = sum(delta_gC_m2_cvt_minus_mt[in_10_18]),
      windows_outside_10_18 = sum(!in_10_18),
      delta_outside_10_18_gC_m2_cvt_minus_mt = sum(delta_gC_m2_cvt_minus_mt[!in_10_18])
    ), by = method],
    annual_diff[, .(method, annual_delta_gC_m2_cvt_minus_mt)],
    by = "method"
  )
  summary[, `:=`(
    scenario = scenario,
    time_window = "10:00-18:00",
    percent_of_annual_delta_10_18 = delta_10_18_gC_m2_cvt_minus_mt / annual_delta_gC_m2_cvt_minus_mt * 100,
    percent_of_annual_delta_outside_10_18 = delta_outside_10_18_gC_m2_cvt_minus_mt / annual_delta_gC_m2_cvt_minus_mt * 100
  )]
  setcolorder(summary, c("scenario", "method", "time_window"))
  summary <- summary[order(match(method, common_methods))]

  by_pair_group <- merge(
    paired[in_10_18 == TRUE, .(
      windows_10_18 = .N,
      delta_10_18_gC_m2_cvt_minus_mt = sum(delta_gC_m2_cvt_minus_mt)
    ), by = .(method, pair_group)],
    annual_diff[, .(method, annual_delta_gC_m2_cvt_minus_mt)],
    by = "method"
  )
  by_pair_group[, `:=`(
    scenario = scenario,
    time_window = "10:00-18:00",
    percent_of_annual_delta_10_18 = delta_10_18_gC_m2_cvt_minus_mt / annual_delta_gC_m2_cvt_minus_mt * 100
  )]
  setcolorder(by_pair_group, c("scenario", "method", "time_window", "pair_group"))
  by_pair_group[, group_order := match(pair_group, c("both_observed", "MT_gapfilled_only", "CVT_gapfilled_only", "both_gapfilled"))]
  by_pair_group <- by_pair_group[order(match(method, common_methods), group_order)]
  by_pair_group[, group_order := NULL]

  detail <- paired[, .(
    scenario = scenario,
    method,
    ts_key,
    hour = hour_mt,
    minute = minute_mt,
    in_10_18,
    pair_group,
    total_component_gC_m2_mt,
    total_component_gC_m2_cvt,
    delta_gC_m2_cvt_minus_mt
  )]
  detail <- detail[order(match(method, common_methods), ts_key)]

  fwrite(summary, file.path(out_dir, "fixed_tower_10_18_annual_difference_contribution_2025.csv"))
  fwrite(by_pair_group, file.path(out_dir, "fixed_tower_10_18_annual_difference_contribution_by_pair_group_2025.csv"))
  fwrite(detail, file.path(out_dir, "fixed_tower_10_18_annual_difference_30min_detail_2025.csv"))
  writeLines(c(
    "Fixed-tower 10:00-18:00 annual difference contribution",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    paste0("Scenario: ", scenario),
    "Difference direction: CVT - MT.",
    "Time window definition: 10:00 <= local half-hour < 18:00.",
    "",
    "Outputs:",
    "- fixed_tower_10_18_annual_difference_contribution_2025.csv",
    "- fixed_tower_10_18_annual_difference_contribution_by_pair_group_2025.csv",
    "- fixed_tower_10_18_annual_difference_30min_detail_2025.csv"
  ), file.path(out_dir, "fixed_tower_10_18_annual_difference_contribution_2025_summary.txt"), useBytes = TRUE)

  list(summary = summary, by_pair_group = by_pair_group)
}

results <- lapply(scenarios, process_scenario)
combined_summary <- rbindlist(lapply(results, `[[`, "summary"), use.names = TRUE)
combined_pair_group <- rbindlist(lapply(results, `[[`, "by_pair_group"), use.names = TRUE)
combined_root <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d", year)
fwrite(combined_summary, file.path(combined_root, "fixed_tower_10_18_annual_difference_contribution_all_scenarios_2025.csv"))
fwrite(combined_pair_group, file.path(combined_root, "fixed_tower_10_18_annual_difference_contribution_by_pair_group_all_scenarios_2025.csv"))

print(combined_summary)
