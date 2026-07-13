#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

year <- 2025L
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

out_dir <- file.path(root, "gapfilled_only_difference")
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
  required <- c(
    "ts_key", "valid_final", "fill_method", "fill_source_group", "gap_scope",
    "gap_block_class", "gap_reason_final", "gapfilled_co2_flux", "total_component_gC_m2"
  )
  if (!all(required %in% names(dt))) stop("Missing required columns in ", path, call. = FALSE)
  dt[, .(
    ts_key,
    tower = case_row$tower[[1]],
    method = case_row$method[[1]],
    valid_final = as.logical(valid_final),
    is_gapfilled = fill_method != "observed_valid",
    fill_method,
    fill_source_group,
    gap_scope,
    gap_block_class,
    gap_reason_final,
    gapfilled_co2_flux = as.numeric(gapfilled_co2_flux),
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

source_label <- function(is_gapfilled, fill_source_group, gap_scope) {
  fifelse(is_gapfilled, paste(fill_source_group, gap_scope, sep = "|"), "observed")
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

paired[, `:=`(
  pair_group = classify_pair_group(is_gapfilled_mt, is_gapfilled_cvt),
  mt_fill_type = source_label(is_gapfilled_mt, fill_source_group_mt, gap_scope_mt),
  cvt_fill_type = source_label(is_gapfilled_cvt, fill_source_group_cvt, gap_scope_cvt),
  delta_flux_cvt_minus_mt = gapfilled_co2_flux_cvt - gapfilled_co2_flux_mt,
  delta_gC_m2_cvt_minus_mt = total_component_gC_m2_cvt - total_component_gC_m2_mt
)]
paired[, fill_type_pair := paste0("MT=", mt_fill_type, "; CVT=", cvt_fill_type)]

annual_diff <- merge(
  annual[tower == "CVT", .(method, annual_nee_estimate_gC_m2_cvt = annual_nee_estimate_gC_m2)],
  annual[tower == "MT", .(method, annual_nee_estimate_gC_m2_mt = annual_nee_estimate_gC_m2)],
  by = "method"
)
annual_diff[, annual_delta_gC_m2_cvt_minus_mt := annual_nee_estimate_gC_m2_cvt - annual_nee_estimate_gC_m2_mt]

summarise_windows <- function(dt, by_cols) {
  out <- dt[, .(
    n_window = .N,
    delta_gC_m2_cvt_minus_mt = sum(delta_gC_m2_cvt_minus_mt),
    mean_delta_flux_cvt_minus_mt = mean(delta_flux_cvt_minus_mt),
    mt_gapfilled_windows = sum(is_gapfilled_mt),
    cvt_gapfilled_windows = sum(is_gapfilled_cvt)
  ), by = by_cols]
  merge(out, annual_diff[, .(method, annual_delta_gC_m2_cvt_minus_mt)], by = "method", all.x = TRUE)
}

pair_group_summary <- summarise_windows(paired, c("method", "pair_group"))
any_gap <- summarise_windows(paired[is_gapfilled_mt | is_gapfilled_cvt], "method")
any_gap[, pair_group := "any_gapfilled"]
all_windows <- summarise_windows(paired, "method")
all_windows[, pair_group := "all_windows"]
pair_group_summary <- rbindlist(list(pair_group_summary, any_gap, all_windows), use.names = TRUE, fill = TRUE)
pair_group_summary[, fraction_of_annual_delta := delta_gC_m2_cvt_minus_mt / annual_delta_gC_m2_cvt_minus_mt]
pair_group_summary[, percent_of_annual_delta := fraction_of_annual_delta * 100]
pair_group_summary[, group_order := match(pair_group, c(
  "both_observed", "MT_gapfilled_only", "CVT_gapfilled_only", "both_gapfilled", "any_gapfilled", "all_windows"
))]
pair_group_summary <- pair_group_summary[order(match(method, common_methods), group_order)]
pair_group_summary[, group_order := NULL]

fill_type_summary <- summarise_windows(
  paired[is_gapfilled_mt | is_gapfilled_cvt],
  c("method", "pair_group", "mt_fill_type", "cvt_fill_type", "fill_type_pair")
)
fill_type_summary[, fraction_of_annual_delta := delta_gC_m2_cvt_minus_mt / annual_delta_gC_m2_cvt_minus_mt]
fill_type_summary[, percent_of_annual_delta := fraction_of_annual_delta * 100]
fill_type_summary <- fill_type_summary[
  order(match(method, common_methods), pair_group, -abs(delta_gC_m2_cvt_minus_mt))
]

detail <- paired[, .(
  method,
  ts_key,
  pair_group,
  mt_fill_type,
  cvt_fill_type,
  fill_method_mt,
  fill_method_cvt,
  gap_reason_final_mt,
  gap_reason_final_cvt,
  gapfilled_co2_flux_mt,
  gapfilled_co2_flux_cvt,
  delta_flux_cvt_minus_mt,
  total_component_gC_m2_mt,
  total_component_gC_m2_cvt,
  delta_gC_m2_cvt_minus_mt
)]
detail <- detail[order(match(method, common_methods), ts_key)]

fwrite(pair_group_summary, file.path(out_dir, "fixed_tower_gapfilled_only_difference_pair_group_2025.csv"))
fwrite(fill_type_summary, file.path(out_dir, "fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv"))
fwrite(detail, file.path(out_dir, "fixed_tower_gapfilled_only_difference_30min_detail_2025.csv"))

writeLines(c(
  "Fixed-tower gapfilled-only difference decomposition",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  paste0("Scenario: ", scenario),
  "",
  "Definition:",
  "- Difference direction is CVT - MT, following the user's attached definition.",
  "- Uses existing per-method 30 min gapfilled outputs.",
  "- gapfilled-only means at least one tower has fill_method != observed_valid.",
  "- fill type is fill_source_group|gap_scope for each tower.",
  "",
  "Outputs:",
  "- fixed_tower_gapfilled_only_difference_pair_group_2025.csv",
  "- fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv",
  "- fixed_tower_gapfilled_only_difference_30min_detail_2025.csv"
), file.path(out_dir, "fixed_tower_gapfilled_only_difference_2025_summary.txt"), useBytes = TRUE)

print(pair_group_summary)
