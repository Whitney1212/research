#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

default_tz <- "Asia/Shanghai"
default_manifest <- "E:/Dataset_Level1/FixedTower/EC/fixed_tower_full_flux_standardized_30min_manifest.csv"
default_year <- 2025L
default_ustar_threshold <- 0.15
default_day_start_hour <- 6
default_day_end_hour <- 18
default_short_gap_max <- 2L

parse_cli_args <- function(args) {
  out <- list(
    manifest = default_manifest,
    year = default_year,
    tz = default_tz,
    ustar_threshold = default_ustar_threshold,
    day_start_hour = default_day_start_hour,
    day_end_hour = default_day_end_hour,
    short_gap_max = default_short_gap_max
  )

  i <- 1L
  while (i <= length(args)) {
    arg <- args[[i]]
    if (startsWith(arg, "--") && grepl("=", arg, fixed = TRUE)) {
      key <- sub("^--", "", sub("=.*$", "", arg))
      value <- sub("^[^=]+=", "", arg)
    } else if (startsWith(arg, "--")) {
      key <- sub("^--", "", arg)
      i <- i + 1L
      if (i > length(args)) stop("Missing value for --", key, call. = FALSE)
      value <- args[[i]]
    } else {
      stop("Unrecognized argument: ", arg, call. = FALSE)
    }

    if (!key %in% names(out)) stop("Unsupported argument --", key, call. = FALSE)
    out[[key]] <- value
    i <- i + 1L
  }

  out$year <- as.integer(out$year)
  out$ustar_threshold <- as.numeric(out$ustar_threshold)
  out$day_start_hour <- as.numeric(out$day_start_hour)
  out$day_end_hour <- as.numeric(out$day_end_hour)
  out$short_gap_max <- as.integer(out$short_gap_max)
  out
}

build_run_plan <- function() {
  rbindlist(list(
    data.table(
      tower = "MT",
      method = c("no_rotation", "dr", "global_pf", "sector_pf", "season_sector_pf"),
      product = c("MT_no_rotation", "MT_dr", "MT_global_pf", "MT_sector_pf", "MT_season_sector_pf"),
      donor_site = "CVT",
      donor_method = c("no_rotation", "dr", "global_pf", "sector_pf", "sector_pf"),
      donor_product = c("CVT_no_rotation", "CVT_dr", "CVT_global_pf", "CVT_sector_pf", "CVT_sector_pf"),
      common_method = c(TRUE, TRUE, TRUE, TRUE, FALSE)
    ),
    data.table(
      tower = "CVT",
      method = c("no_rotation", "dr", "global_pf", "sector_pf"),
      product = c("CVT_no_rotation", "CVT_dr", "CVT_global_pf", "CVT_sector_pf"),
      donor_site = "MT",
      donor_method = c("no_rotation", "dr", "global_pf", "sector_pf"),
      donor_product = c("MT_no_rotation", "MT_dr", "MT_global_pf", "MT_sector_pf"),
      common_method = TRUE
    )
  ), use.names = TRUE)
}

attach_manifest_paths <- function(run_plan, manifest_file) {
  manifest <- fread(manifest_file)
  manifest_lookup <- manifest[, .(product, standardized_input_file = output_file)]

  out <- merge(run_plan, manifest_lookup, by = "product", all.x = TRUE, sort = FALSE)
  setnames(out, "standardized_input_file", "input_file")
  out <- merge(
    out,
    manifest_lookup[, .(donor_product = product, donor_input_file = standardized_input_file)],
    by = "donor_product",
    all.x = TRUE,
    sort = FALSE
  )

  missing_products <- out[is.na(input_file), unique(product)]
  if (length(missing_products) > 0L) {
    stop("Missing standardized products in manifest: ", paste(missing_products, collapse = ", "), call. = FALSE)
  }
  missing_donors <- out[is.na(donor_input_file), unique(donor_product)]
  if (length(missing_donors) > 0L) {
    stop("Missing donor products in manifest: ", paste(missing_donors, collapse = ", "), call. = FALSE)
  }

  out
}

add_output_dirs <- function(run_plan, year) {
  tower_root <- sprintf("E:/Dataset_Level1/%s/EC/whole year computation/rotation_sensitivity_standardized_%d", run_plan$tower, year)
  run_plan[, tower_output_root := tower_root]
  run_plan[, method_output_dir := file.path(tower_output_root, method)]
  run_plan[, combined_output_root := sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d", year)]
  run_plan
}

prepare_script_env <- function(script_path) {
  env <- new.env(parent = globalenv())
  sys.source(script_path, envir = env)
  env
}

run_one_case <- function(case_row, audit_env, nee_env, year, tz_local, ustar_threshold, day_start_hour, day_end_hour, short_gap_max) {
  dir.create(case_row$method_output_dir, recursive = TRUE, showWarnings = FALSE)

  audit_summary <- audit_env$run_fixed_tower_ec_year_audit(
    site = case_row$tower,
    input_file = case_row$input_file,
    output_dir = case_row$method_output_dir,
    year = year,
    tz_local = tz_local,
    ustar_threshold = ustar_threshold,
    day_start_hour = day_start_hour,
    day_end_hour = day_end_hour
  )

  annual_summary <- nee_env$estimate_fixed_tower_nee(
    site = case_row$tower,
    input_file = case_row$input_file,
    output_dir = case_row$method_output_dir,
    year = year,
    tz_local = tz_local,
    ustar_threshold = ustar_threshold,
    day_start_hour = day_start_hour,
    day_end_hour = day_end_hour,
    short_gap_max = short_gap_max,
    donor_input = case_row$donor_input_file,
    donor_site = case_row$donor_site,
    apply_qc_filter = TRUE,
    apply_flag9_filter = TRUE,
    output_tag = NULL
  )

  meta_cols <- case_row[, .(
    tower,
    method,
    product,
    input_file,
    donor_site,
    donor_method,
    donor_product,
    donor_input_file,
    common_method,
    method_output_dir,
    combined_output_root
  )]

  list(
    audit_summary = cbind(meta_cols, audit_summary),
    annual_summary = cbind(meta_cols, annual_summary)
  )
}

build_common_summary <- function(annual_all) {
  annual_all[common_method == TRUE, .(
    tower,
    method,
    observed_valid_windows,
    gapfilled_windows,
    short_gapfilled_windows,
    long_gapfilled_windows,
    annual_nee_estimate_gC_m2
  )][order(factor(tower, levels = c("MT", "CVT")), factor(method, levels = c("no_rotation", "dr", "global_pf", "sector_pf")))]
}

build_mt_cvt_diff_summary <- function(common_summary) {
  mt <- common_summary[tower == "MT"]
  cvt <- common_summary[tower == "CVT"]
  out <- merge(mt, cvt, by = "method", suffixes = c("_mt", "_cvt"))
  out[, `:=`(
    mt_minus_cvt_observed_valid_windows = observed_valid_windows_mt - observed_valid_windows_cvt,
    mt_minus_cvt_gapfilled_windows = gapfilled_windows_mt - gapfilled_windows_cvt,
    mt_minus_cvt_short_gapfilled_windows = short_gapfilled_windows_mt - short_gapfilled_windows_cvt,
    mt_minus_cvt_long_gapfilled_windows = long_gapfilled_windows_mt - long_gapfilled_windows_cvt,
    mt_minus_cvt_annual_nee_estimate_gC_m2 = annual_nee_estimate_gC_m2_mt - annual_nee_estimate_gC_m2_cvt
  )]
  out[]
}

build_delta_vs_sector_pf <- function(annual_all) {
  baseline <- annual_all[method == "sector_pf", .(
    tower,
    sector_pf_observed_valid_windows = observed_valid_windows,
    sector_pf_gapfilled_windows = gapfilled_windows,
    sector_pf_annual_nee_estimate_gC_m2 = annual_nee_estimate_gC_m2
  )]

  out <- merge(annual_all, baseline, by = "tower", all.x = TRUE, sort = FALSE)
  out[, `:=`(
    observed_valid_windows_delta_vs_sector_pf = observed_valid_windows - sector_pf_observed_valid_windows,
    gapfilled_windows_delta_vs_sector_pf = gapfilled_windows - sector_pf_gapfilled_windows,
    annual_nee_delta_vs_sector_pf_gC_m2 = annual_nee_estimate_gC_m2 - sector_pf_annual_nee_estimate_gC_m2
  )]
  out[, .(
    tower,
    method,
    common_method,
    observed_valid_windows,
    gapfilled_windows,
    annual_nee_estimate_gC_m2,
    observed_valid_windows_delta_vs_sector_pf,
    gapfilled_windows_delta_vs_sector_pf,
    annual_nee_delta_vs_sector_pf_gC_m2
  )]
}

main <- function() {
  args <- parse_cli_args(commandArgs(trailingOnly = TRUE))
  run_plan <- build_run_plan()
  stopifnot(nrow(run_plan[common_method == TRUE]) == 8L)

  run_plan <- attach_manifest_paths(run_plan, args$manifest)
  run_plan <- add_output_dirs(run_plan, args$year)

  unique_combined_root <- unique(run_plan$combined_output_root)
  stopifnot(length(unique_combined_root) == 1L)
  dir.create(unique_combined_root, recursive = TRUE, showWarnings = FALSE)

  audit_env <- prepare_script_env("D:/00 博士阶段/99 Project/06 EA/scripts/build_fixed_tower_ec_year_audit.R")
  nee_env <- prepare_script_env("D:/00 博士阶段/99 Project/06 EA/scripts/estimate_fixed_tower_nee_2025.R")

  audit_list <- vector("list", nrow(run_plan))
  annual_list <- vector("list", nrow(run_plan))

  for (i in seq_len(nrow(run_plan))) {
    case_row <- run_plan[i]
    message(sprintf("[%d/%d] %s %s", i, nrow(run_plan), case_row$tower, case_row$method))
    result <- run_one_case(
      case_row = case_row,
      audit_env = audit_env,
      nee_env = nee_env,
      year = args$year,
      tz_local = args$tz,
      ustar_threshold = args$ustar_threshold,
      day_start_hour = args$day_start_hour,
      day_end_hour = args$day_end_hour,
      short_gap_max = args$short_gap_max
    )
    audit_list[[i]] <- result$audit_summary
    annual_list[[i]] <- result$annual_summary
  }

  audit_all <- rbindlist(audit_list, use.names = TRUE, fill = TRUE)
  annual_all <- rbindlist(annual_list, use.names = TRUE, fill = TRUE)
  common_summary <- build_common_summary(annual_all)
  mt_cvt_diff_summary <- build_mt_cvt_diff_summary(common_summary)
  delta_vs_sector_pf <- build_delta_vs_sector_pf(annual_all)

  combined_root <- unique_combined_root[[1L]]
  fwrite(run_plan, file.path(combined_root, sprintf("rotation_sensitivity_standardized_%d_run_plan.csv", args$year)))
  fwrite(audit_all, file.path(combined_root, sprintf("rotation_sensitivity_standardized_%d_year_audit_summary_all_methods.csv", args$year)))
  fwrite(annual_all, file.path(combined_root, sprintf("rotation_sensitivity_standardized_%d_annual_summary_all_methods.csv", args$year)))
  fwrite(common_summary, file.path(combined_root, sprintf("rotation_sensitivity_standardized_%d_common_four_methods_summary.csv", args$year)))
  fwrite(mt_cvt_diff_summary, file.path(combined_root, sprintf("rotation_sensitivity_standardized_%d_mt_cvt_method_difference_summary.csv", args$year)))
  fwrite(delta_vs_sector_pf, file.path(combined_root, sprintf("rotation_sensitivity_standardized_%d_delta_vs_sector_pf.csv", args$year)))

  message("Completed rotation sensitivity rerun.")
}

if (sys.nframe() == 0L) {
  main()
}
