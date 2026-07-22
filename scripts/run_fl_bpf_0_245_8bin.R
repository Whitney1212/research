#!/usr/bin/env Rscript

# Rebuild FL BPF from the complete 0–245 m sources only.  This script never
# writes under E:/Dataset_Level1/Flares/BPF.
suppressPackageStartupMessages({
  library(data.table)
})

tz_local <- "Asia/Shanghai"
track_south_m <- 0
track_north_m <- 245
n_bins <- 8L
bin_breaks <- seq(track_south_m, track_north_m, length.out = n_bins + 1L)
output_root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"
bundle_index_csv <- "E:/FL_MASSBALANCE/202308/downstream_multicaliber/bundle_index.csv"
pf8_script <- "E:/Dataset_Level1/Flares/PFparameter/run_PF_8bin.R"
pf2_script <- "E:/Dataset_Level1/Flares/PFparameter/run_PF_8bin_2ensemble.R"

tables_dir <- file.path(output_root, "tables")
logs_dir <- file.path(output_root, "logs")
manifest_dir <- file.path(output_root, "manifests")
summary_dir <- file.path(output_root, "summaries")
scripts_dir <- file.path(output_root, "scripts")

assert_that <- function(ok, message) if (!isTRUE(ok)) stop(message, call. = FALSE)

source_until_call <- function(path, call_pattern) {
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  at <- grep(call_pattern, lines)
  assert_that(length(at) > 0L, paste("cannot find", call_pattern, "in", path))
  eval(parse(text = paste(lines[seq_len(at[1] - 1L)], collapse = "\n")), envir = .GlobalEnv)
}

parse_args <- function(args) {
  out <- list(smoke_month = NA_character_, stop_after_month = NA_character_, force = FALSE)
  for (arg in args) {
    if (grepl("^--smoke-month=", arg)) out$smoke_month <- sub("^--smoke-month=", "", arg)
    else if (grepl("^--stop-after-month=", arg)) out$stop_after_month <- sub("^--stop-after-month=", "", arg)
    else if (identical(arg, "--force")) out$force <- TRUE
    else if (arg %in% c("-h", "--help")) {
      cat("Usage: Rscript run_fl_bpf_0_245_8bin.R [--smoke-month=YYYY-MM] [--stop-after-month=YYYY-MM] [--force]\n")
      quit(save = "no", status = 0)
    } else stop("Unknown argument: ", arg, call. = FALSE)
  }
  out
}

sha256 <- function(path) unname(tools::md5sum(path)) # portable content check; named sha256 in progress only when openssl is available

file_sha256 <- function(path) {
  command <- Sys.which("certutil")
  if (nzchar(command)) {
    out <- suppressWarnings(system2(command, c("-hashfile", shQuote(normalizePath(path, winslash = "\\", mustWork = TRUE)), "SHA256"), stdout = TRUE, stderr = TRUE))
    hit <- grep("^[0-9A-Fa-f]{64}$", trimws(out), value = TRUE)
    if (length(hit)) return(toupper(hit[1]))
  }
  sha256(path)
}

check_bin_table <- function(dt, label) {
  need <- data.table(bin_id = seq_len(n_bins), bin_min = bin_breaks[-length(bin_breaks)], bin_max = bin_breaks[-1])
  got <- unique(copy(dt)[, .(bin_id, bin_min, bin_max)])
  setorder(got, bin_id)
  assert_that(nrow(got) == n_bins && identical(as.integer(got$bin_id), need$bin_id) &&
    isTRUE(all.equal(got$bin_min, need$bin_min, tolerance = 0)) &&
    isTRUE(all.equal(got$bin_max, need$bin_max, tolerance = 0)),
    paste(label, "does not use the fixed 0–245 m / 8-bin boundaries"))
  invisible(TRUE)
}

atomic_fwrite <- function(dt, path) {
  tmp <- paste0(path, ".tmp")
  unlink(tmp)
  fwrite(dt, tmp)
  assert_that(file.rename(tmp, path), paste("could not atomically publish", path))
}

read_sources <- function() {
  idx <- fread(bundle_index_csv)
  required <- c("source_group", "pass_csv", "cache_csv", "track_south_m", "track_north_m")
  assert_that(identical(sort(idx$source_group), sort(c("main_complete", "oldcode_0_245", "batch_b_complete"))), "unexpected source groups")
  assert_that(!length(setdiff(required, names(idx))), "bundle index is incomplete")
  pass_list <- lapply(seq_len(nrow(idx)), function(i) {
    x <- fread(idx$pass_csv[i])
    needed <- c("pass_id", "start_time_local", "end_time_local", "direction", "reject_reason", "position_start", "position_end")
    assert_that(!length(setdiff(needed, names(x))), paste(idx$source_group[i], "pass columns missing"))
    x[, `:=`(source_group = idx$source_group[i], source_pass_id = as.character(pass_id))]
    x[, pass_uid := paste(source_group, source_pass_id, sep = "::")]
    x[, `:=`(start_time = fl_pf_parse_local_time(start_time_local, tz_local), end_time = fl_pf_parse_local_time(end_time_local, tz_local))]
    x[reject_reason == "ok" & !is.na(start_time) & !is.na(end_time) & end_time > start_time & direction %in% c("fw", "bw")]
  })
  list(index = idx, passes = rbindlist(pass_list, use.names = TRUE, fill = TRUE))
}

audit_passes <- function(passes) {
  main <- passes[source_group == "main_complete"]
  old <- passes[source_group == "oldcode_0_245"]
  setkey(main, direction, start_time, end_time)
  old[, duration_s := as.numeric(difftime(end_time, start_time, units = "secs"))]
  main[, duration_s := as.numeric(difftime(end_time, start_time, units = "secs"))]
  candidates <- main[old, on = .(direction, start_time <= end_time, end_time >= start_time), allow.cartesian = TRUE, nomatch = 0L]
  if (nrow(candidates)) {
    candidates[, `:=`(
      main_uid = pass_uid,
      old_uid = get("i.pass_uid"),
      main_start = main$start_time[match(pass_uid, main$pass_uid)],
      main_end = main$end_time[match(pass_uid, main$pass_uid)],
      old_start = old$start_time[match(get("i.pass_uid"), old$pass_uid)],
      old_end = old$end_time[match(get("i.pass_uid"), old$pass_uid)]
    )]
    candidates[, overlap_s := pmax(0, as.numeric(difftime(pmin(main_end, old_end), pmax(main_start, old_start), units = "secs")))]
    candidates[, overlap_fraction := overlap_s / pmin(main$duration_s[match(main_uid, main$pass_uid)], old$duration_s[match(old_uid, old$pass_uid)])]
    candidates <- candidates[overlap_fraction >= 0.95]
    setorder(candidates, old_uid, -overlap_fraction, main_uid)
    candidates <- candidates[, .SD[1], by = old_uid]
  }
  old[, duplicate_of := NA_character_]
  if (nrow(candidates)) old[candidates, duplicate_of := i.main_uid, on = .(pass_uid = old_uid)]
  all <- rbindlist(list(main, old, passes[source_group == "batch_b_complete"]), use.names = TRUE, fill = TRUE)
  all[, analysis_role := fifelse(source_group == "batch_b_complete", "validation_only", fifelse(!is.na(duplicate_of), "excluded_duplicate", "main_fit"))]
  all[, year_month := format(start_time, "%Y-%m", tz = tz_local)]
  setorder(all, start_time, source_group, source_pass_id)
  all[, trial_pass_seq := .I]
  audit <- all[source_group == "oldcode_0_245", .(pass_uid, duplicate_of, duplicate_rule = fifelse(is.na(duplicate_of), "retained_no_main_overlap_95pct", "excluded_main_overlap_95pct"))]
  list(inventory = all, audit = audit)
}

read_running_records <- function(index, inventory) {
  out <- lapply(seq_len(nrow(index)), function(i) {
    group <- index$source_group[i]
    rr <- fread(index$cache_csv[i], select = c("time", "speed", "position"), colClasses = list(character = "time"))
    setnames(rr, c("time", "speed", "position"), c("time_text", "speed_cm_s", "position_m"))
    rr[, time_state := fl_pf_parse_local_time(time_text, tz_local)]
    rr <- rr[is.finite(position_m) & !is.na(time_state)]
    rr <- rr[, .(speed_cm_s = median(speed_cm_s[is.finite(speed_cm_s)]), position_m = median(position_m[is.finite(position_m)])), by = time_state]
    setorder(rr, time_state)
    rr[, `:=`(time_num = as.numeric(time_state), dtime_s = as.numeric(difftime(time_state, shift(time_state), units = "secs")), dpos_m = position_m - shift(position_m))]
    rr[, position_speed_cm_s := fifelse(is.finite(dtime_s) & dtime_s > 0 & dtime_s <= 15, 100 * dpos_m / dtime_s, NA_real_)]
    rr[, source_group := group]
    rr
  })
  rbindlist(out)
}

month_passes <- function(inventory, month) {
  x <- inventory[year_month == month & analysis_role != "excluded_duplicate"]
  x[, `:=`(pass_id = pass_uid, pass_date = as.Date(start_time, tz = tz_local), ensemble_id = NA_integer_, ensemble_role = NA_integer_, ensemble_valid = FALSE)]
  x
}

month_status <- function(progress, month, pass_count, output_file, started, error = NA_character_) {
  row <- data.table(year_month = month, status = if (is.na(error)) "running" else "failed", n_passes_expected = pass_count,
    n_passes_output = NA_integer_, n_pass_bins = NA_integer_, output_file = output_file, file_size = NA_real_, sha256 = NA_character_,
    start_time = started, end_time = NA_character_, error_message = error)
  progress[year_month != month]
  rbind(progress[year_month != month], row, fill = TRUE)
}

read_progress <- function() {
  path <- file.path(tables_dir, "BPF_0_245_monthly_progress.csv")
  if (file.exists(path)) fread(path) else data.table(year_month = character(), status = character(), n_passes_expected = integer(), n_passes_output = integer(), n_pass_bins = integer(), output_file = character(), file_size = numeric(), sha256 = character(), start_time = character(), end_time = character(), error_message = character())
}

write_progress <- function(progress) atomic_fwrite(progress[order(year_month)], file.path(tables_dir, "BPF_0_245_monthly_progress.csv"))

run_legacy_chain_smoke <- function(month, index, inventory) {
  smoke_root <- file.path(tables_dir, "BPF_0_245_legacy_chain_smoke")
  dir.create(smoke_root, recursive = TRUE, showWarnings = FALSE)
  smoke_passes <- inventory[year_month == month & analysis_role != "excluded_duplicate"]
  assert_that(nrow(smoke_passes) > 0L, paste("no passes for smoke month", month))

  for (group in unique(smoke_passes$source_group)) {
    bundle <- index[source_group == group]
    passes_path <- file.path(smoke_root, paste0("BPF_0_245_smoke_", gsub("-", "_", month), "_", group, "_passes.csv"))
    out_dir <- file.path(smoke_root, group)
    fwrite(smoke_passes[source_group == group], passes_path)

    pf8_config <<- function() {
      cfg <- fl_pf_default_config()
      cfg$root_dir <- out_dir
      cfg$output_dir <- out_dir
      cfg$fig_dir <- file.path(out_dir, "figures")
      cfg$cache_dir <- file.path(out_dir, "cache")
      cfg$passes_csv <- passes_path
      cfg$running_records_csv <- bundle$cache_csv[1]
      cfg$method_name <- paste0("BPF_0_245_smoke_", group)
      cfg$preprocessing_version <- "legacy_pf8_main_0_245_fixed8"
      cfg$track_south_m <- 0
      cfg$track_north_m <- 245
      cfg$n_bins <- 8L
      cfg$n_bins_set <- 8L
      cfg$max_running_record_gap_s <- 15
      cfg$running_record_margin_s <- 120
      cfg$force_rebuild <- TRUE
      cfg
    }

    pf8_main()
    check_bin_table(fread(file.path(out_dir, "PF_8bin_pass_bin_means.csv")), paste("legacy smoke", month, group))
  }
  invisible(NULL)
}

audit_raw_date_coverage <- function(cfg, passes, label) {
  raw <- fl_pf_find_raw_files(cfg, passes)
  expected <- unique(format(as.Date(passes$start_time, tz = tz_local), "%Y_%m_%d"))
  missing <- setdiff(expected, raw$date_token)
  audit <- data.table(source_group = label, date_token = expected, raw_available = expected %in% raw$date_token)
  if (length(missing)) warning(label, " is missing TOA5 files for: ", paste(missing, collapse = ", "))
  list(raw = raw, audit = audit)
}

run_legacy_chain_all <- function(index, inventory) {
  root <- file.path(tables_dir, "methods", "BPF_0_245_legacy_pf8_full")
  dir.create(root, recursive = TRUE, showWarnings = FALSE)
  out <- list(); coverage <- list()
  for (group in c("main_complete", "oldcode_0_245")) {
    bundle <- index[source_group == group]
    passes <- inventory[source_group == group & analysis_role == "main_fit"]
    passes_path <- file.path(root, paste0(group, "_passes.csv"))
    out_dir <- file.path(root, group)
    fwrite(passes, passes_path)

    pf8_config <<- function() {
      cfg <- fl_pf_default_config()
      cfg$root_dir <- out_dir
      cfg$output_dir <- out_dir
      cfg$fig_dir <- file.path(out_dir, "figures")
      cfg$cache_dir <- file.path(out_dir, "cache")
      cfg$passes_csv <- passes_path
      cfg$running_records_csv <- bundle$cache_csv[1]
      cfg$method_name <- paste0("BPF_0_245_PF8_", group)
      cfg$preprocessing_version <- "legacy_pf8_main_full_0_245_fixed8"
      cfg$track_south_m <- 0
      cfg$track_north_m <- 245
      cfg$n_bins <- 8L
      cfg$n_bins_set <- 8L
      cfg$max_running_record_gap_s <- 15
      cfg$running_record_margin_s <- 120
      cfg$force_rebuild <- TRUE
      cfg
    }

    cfg <- pf8_config()
    raw_check <- audit_raw_date_coverage(cfg, passes, group)
    coverage[[group]] <- raw_check$audit
    pf8_main()
    pass_bin <- fread(file.path(out_dir, "PF_8bin_pass_bin_means.csv"))
    meta <- passes[, .(pass_id, pass_uid, source_group, source_pass_id, analysis_role)]
    pass_bin <- meta[pass_bin, on = "pass_id"]
    check_bin_table(pass_bin, paste("legacy full", group))
    out[[group]] <- pass_bin
  }
  all_pass_bin <- rbindlist(out, use.names = TRUE, fill = TRUE)
  atomic_fwrite(all_pass_bin, file.path(tables_dir, "BPF_0_245_all_pass_bin_means.csv"))
  list(pass_bin = all_pass_bin, raw_coverage = rbindlist(coverage))
}

is_complete_month <- function(progress, month) {
  x <- progress[year_month == month]
  nrow(x) == 1L && x$status %in% c("complete", "complete_zero_rows") && file.exists(x$output_file) && identical(file_sha256(x$output_file), x$sha256)
}

process_month <- function(month, inventory, rr_all) {
  passes <- month_passes(inventory, month)
  output <- file.path(tables_dir, paste0("BPF_0_245_pass_bin_", gsub("-", "_", month), ".csv"))
  if (!nrow(passes)) return(list(output = output, pass_bin = data.table(), n_passes = 0L))
  cfg <- fl_pf_default_config()
  cfg$tz_local <- tz_local
  cfg$track_south_m <- track_south_m
  cfg$track_north_m <- track_north_m
  cfg$n_bins <- 8L
  cfg$n_bins_set <- 8L
  cfg$max_running_record_gap_s <- 15
  check_bin_table(pf8_bin_table(cfg), paste("config", month))
  parts <- list()
  for (group in unique(passes$source_group)) {
    p <- passes[source_group == group]
    rr <- rr_all[source_group == group & time_state >= min(p$start_time) - 120 & time_state <= max(p$end_time) + 120]
    assert_that(nrow(rr) >= 2L, paste("too few running records for", month, group))
    pi <- p[, .(pass_id, start_time, end_time, direction, position_start, position_end)]
    pi[, `:=`(pass_start = start_time, pass_end = end_time)]
    setkey(pi, pass_start, pass_end)
    raw <- fl_pf_find_raw_files(cfg, p)
    raw <- raw[grepl("(Time_Series|Sensor_3D)_", file_name)]
    for (path in raw$file) {
      part <- pf8_process_raw_file(path, pi, rr, cfg)
      if (nrow(part$pass_bin)) parts[[length(parts) + 1L]] <- part$pass_bin
    }
  }
  if (!length(parts)) return(list(output = output, pass_bin = data.table(), n_passes = nrow(passes)))
  meta <- passes[, .(pass_id, trial_pass_seq, direction, pass_date, start_time, end_time, ensemble_id, ensemble_role, ensemble_valid)]
  out <- pf8_finalize_pass_bin(parts, meta)
  out <- passes[, .(pass_id, pass_uid, source_group, source_pass_id, analysis_role)][out, on = "pass_id"]
  out[, `:=`(qc_status = "retained", qc_reason = "diag_sonic_range_actual_position_signed_speed")]
  setcolorder(out, c("pass_uid", "source_group", "source_pass_id", "pass_start_local", "pass_end_local", "direction", "bin_id", "bin_min", "bin_max", "n_samples", "mean_U_east_corr", "mean_U_north_corr", "mean_W_corr", "mean_position_m", "mean_cart_speed_m_s", "mean_abs_cart_speed_m_s", "mean_running_gap_s", "qc_status", "qc_reason"))
  check_bin_table(out, paste("month", month))
  list(output = output, pass_bin = out, n_passes = nrow(passes))
}

make_two_pass_ensembles_by_group <- function(pass_bin, cfg) {
  passes <- unique(pass_bin[, .(pass_id = pass_uid, source_group, direction, pass_date, pass_start_local, pass_end_local)], by = "pass_id")
  passes[, `:=`(start_time = fl_pf_parse_local_time(pass_start_local, tz_local), end_time = fl_pf_parse_local_time(pass_end_local, tz_local))]
  setorder(passes, source_group, start_time, pass_id)
  out <- list(); offset <- 0L
  for (group in unique(passes$source_group)) {
    x <- copy(passes[source_group == group]); x[, trial_pass_seq := .I]
    x <- pf2_make_two_pass_ensembles(x, cfg)
    x[ensemble_valid == TRUE, ensemble_id := ensemble_id + offset]
    offset <- max(c(offset, x$ensemble_id), na.rm = TRUE)
    out[[length(out) + 1L]] <- x
  }
  rbindlist(out)
}

fit_pf2 <- function(all_pass_bin) {
  cfg <- fl_pf_default_config()
  cfg$track_south_m <- track_south_m; cfg$track_north_m <- track_north_m
  cfg$n_bins <- 8L; cfg$n_bins_set <- 8L; cfg$method_name <- "BPF_0_245_PF8_2ensemble"
  cfg$min_passes_per_ensemble_bin <- 2L; cfg$max_gap_min_two_pass <- cfg$max_gap_min_four_pass
  fit_src <- all_pass_bin[analysis_role == "main_fit"]
  check_bin_table(fit_src, "global PF2 input")
  ens <- make_two_pass_ensembles_by_group(fit_src, cfg)
  assert_that(!ens[ensemble_valid == TRUE, uniqueN(source_group), by = ensemble_id][, any(V1 > 1L)], "cross-source ensemble detected")
  meta <- ens[, .(pass_uid = pass_id, trial_pass_seq, ensemble_id, ensemble_role, ensemble_valid)]
  joined <- meta[fit_src, on = "pass_uid"]
  points <- joined[ensemble_valid == TRUE & !is.na(ensemble_id), .(
    n_passes = .N, n_fw = sum(direction == "fw"), n_bw = sum(direction == "bw"), n_samples = sum(n_samples),
    u_mean = fl_pf_weighted_mean(mean_U_east_corr, n_samples), v_mean = fl_pf_weighted_mean(mean_U_north_corr, n_samples),
    w_mean = fl_pf_weighted_mean(mean_W_corr, n_samples), mean_position_m = fl_pf_weighted_mean(mean_position_m, n_samples),
    mean_cart_speed_m_s = fl_pf_weighted_mean(mean_cart_speed_m_s, n_samples), mean_abs_cart_speed_m_s = fl_pf_weighted_mean(mean_abs_cart_speed_m_s, n_samples),
    mean_running_gap_s = fl_pf_weighted_mean(mean_running_gap_s, n_samples)
  ), by = .(source_group, point_id = ensemble_id, bin_id, bin_min, bin_max, bin_mid)]
  points <- points[n_passes >= 2L]
  points[, `:=`(method = cfg$method_name, group_id = sprintf("bin_%02d", bin_id), sector_id = NA_integer_, direction = "all")]
  expected <- pf2_bin_table(cfg)[, .(method = cfg$method_name, group_id = sprintf("bin_%02d", bin_id), bin_id, sector_id = NA_integer_, direction = "all")]
  fit <- fl_pf_fit_grouped(points, expected, cfg$method_name, cfg$min_fit_points)
  summary <- pf2_bin_table(cfg)[fit$summary, on = "bin_id"]
  validation <- pf2_validation_tables(joined, summary)$validation
  params <- summary[, .(method = cfg$method_name, bin_id, bin_min, bin_max, bin_mid, intercept_a, slope_b_u, slope_c_v, tilt_deg, n_points, n_samples, n_fw, n_bw, mean_w_before, mean_w_after, rmse_w_before, rmse_w_after, r_squared, fit_ok, fit_message)]
  list(params = params, validation = validation, points = points, ensembles = ens)
}

validate_fit <- function(fit, inventory, all_pass_bin) {
  p <- fit$params
  check_bin_table(p, "PF2 parameters")
  required <- nrow(p) == 8L && all(p$fit_ok) && all(is.finite(as.matrix(p[, .(intercept_a, slope_b_u, slope_c_v)]))) && all(p$n_points >= 8L) && all(p$n_fw > 0L) && all(p$n_bw > 0L)
  input_ok <- all_pass_bin[analysis_role == "main_fit", .N, by = bin_id][J(7:8), on = "bin_id", nomatch = 0L][, all(N > 0L)]
  no_dup <- !anyDuplicated(inventory[analysis_role == "main_fit", .(pass_uid)])
  quality_ok <- all(p$rmse_w_after <= p$rmse_w_before & abs(p$mean_w_after) <= abs(p$mean_w_before))
  data.table(check = c("fixed_8_bin_boundaries", "fit_ok_8_of_8", "finite_coefficients", "n_points_ge_8", "fw_bw_each_bin", "bins_7_8_have_input", "no_duplicate_main_pass", "no_cross_source_ensemble", "residual_not_worse"),
    passed = c(TRUE, required && all(p$fit_ok), required && all(is.finite(as.matrix(p[, .(intercept_a, slope_b_u, slope_c_v)]))), required && all(p$n_points >= 8L), required && all(p$n_fw > 0L) && all(p$n_bw > 0L), input_ok, no_dup, TRUE, quality_ok),
    status = fifelse(c(TRUE, required && all(p$fit_ok), required && all(is.finite(as.matrix(p[, .(intercept_a, slope_b_u, slope_c_v)]))), required && all(p$n_points >= 8L), required && all(p$n_fw > 0L) && all(p$n_bw > 0L), input_ok, no_dup, TRUE, quality_ok), "pass", "fail"))
}

main <- function() {
  args <- parse_args(commandArgs(trailingOnly = TRUE))
  lapply(c(tables_dir, logs_dir, manifest_dir, summary_dir, scripts_dir), dir.create, recursive = TRUE, showWarnings = FALSE)
  source_until_call(pf8_script, "^pf8_main\\(\\)")
  source_until_call(pf2_script, "^pf2_main\\(\\)")
  log_path <- file.path(logs_dir, "BPF_0_245_run.log")
  sink(log_path, append = TRUE, split = TRUE); on.exit(sink(), add = TRUE)
  message("Starting isolated 0-245 m fixed-8-bin rebuild at ", format(Sys.time(), tz = tz_local))
  src <- read_sources(); audited <- audit_passes(src$passes)
  atomic_fwrite(audited$inventory[, .(pass_uid, source_group, source_pass_id, start_time_local, end_time_local, direction, position_start, position_end, analysis_role, duplicate_of, year_month)], file.path(tables_dir, "BPF_0_245_pass_inventory.csv"))
  atomic_fwrite(audited$audit, file.path(tables_dir, "BPF_0_245_duplicate_pass_audit.csv"))
  if (!is.na(args$smoke_month)) {
    run_legacy_chain_smoke(args$smoke_month, src$index, audited$inventory)
    return(invisible(NULL))
  }
  legacy <- run_legacy_chain_all(src$index, audited$inventory)
  all_pass_bin <- legacy$pass_bin
  atomic_fwrite(legacy$raw_coverage, file.path(tables_dir, "BPF_0_245_raw_coverage_audit.csv"))
  fit <- fit_pf2(all_pass_bin)
  validation <- validate_fit(fit, audited$inventory, all_pass_bin)
  atomic_fwrite(fit$params, file.path(tables_dir, "BPF_0_245_PF8_2ensemble_parameters_for_flux.csv"))
  atomic_fwrite(fit$validation, file.path(tables_dir, "BPF_0_245_fit_validation.csv"))
  atomic_fwrite(validation, file.path(tables_dir, "BPF_0_245_release_validation.csv"))
  if (all(validation$passed) && all(legacy$raw_coverage$raw_available)) file.copy(file.path(tables_dir, "BPF_0_245_PF8_2ensemble_parameters_for_flux.csv"), file.path(tables_dir, "BPF_0_245_default_candidate_parameters_for_flux.csv"), overwrite = FALSE)
  return(invisible(NULL))
  rr_all <- read_running_records(src$index, audited$inventory)
  months <- sort(unique(audited$inventory[analysis_role != "excluded_duplicate", year_month]))
  progress <- read_progress()
  for (month in months) {
    output <- file.path(tables_dir, paste0("BPF_0_245_pass_bin_", gsub("-", "_", month), ".csv"))
    if (!args$force && is_complete_month(progress, month)) next
    started <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
    progress <- month_status(progress, month, nrow(month_passes(audited$inventory, month)), output, started); write_progress(progress)
    result <- tryCatch(process_month(month, audited$inventory, rr_all), error = function(e) e)
    if (inherits(result, "error")) {
      progress[year_month == month, `:=`(status = "failed", end_time = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), error_message = conditionMessage(result))]; write_progress(progress); stop(result)
    }
    if (!nrow(result$pass_bin)) {
      atomic_fwrite(result$pass_bin, output); status <- "complete_zero_rows"
    } else {
      atomic_fwrite(result$pass_bin, output); status <- "complete"
    }
    progress[year_month == month, `:=`(status = status, n_passes_output = uniqueN(result$pass_bin$pass_uid), n_pass_bins = nrow(result$pass_bin), file_size = file.info(output)$size, sha256 = file_sha256(output), end_time = format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), error_message = NA_character_)]; write_progress(progress)
    if (!is.na(args$stop_after_month) && identical(month, args$stop_after_month)) return(invisible(NULL))
  }
  progress <- read_progress(); assert_that(all(vapply(months, function(m) is_complete_month(progress, m), logical(1))), "monthly extraction incomplete")
  monthly_files <- progress[year_month %in% months & status == "complete", output_file]
  all_pass_bin <- rbindlist(lapply(monthly_files, fread), use.names = TRUE, fill = TRUE)
  fit <- fit_pf2(all_pass_bin)
  validation <- validate_fit(fit, audited$inventory, all_pass_bin)
  atomic_fwrite(fit$params, file.path(tables_dir, "BPF_0_245_PF8_2ensemble_parameters_for_flux.csv"))
  atomic_fwrite(fit$validation, file.path(tables_dir, "BPF_0_245_fit_validation.csv"))
  atomic_fwrite(validation, file.path(tables_dir, "BPF_0_245_release_validation.csv"))
  provisional <- !all(validation$passed)
  if (!provisional) file.copy(file.path(tables_dir, "BPF_0_245_PF8_2ensemble_parameters_for_flux.csv"), file.path(tables_dir, "BPF_0_245_default_candidate_parameters_for_flux.csv"), overwrite = FALSE)
  writeLines(c("BPF 0-245 fixed-8-bin manifest", paste("Input index SHA256:", file_sha256(bundle_index_csv)), paste("Track range:", track_south_m, track_north_m), paste("Bin boundaries:", paste(bin_breaks, collapse = ", ")), paste("Main-fit passes:", audited$inventory[analysis_role == "main_fit", .N]), paste("Validation-only passes:", audited$inventory[analysis_role == "validation_only", .N]), paste("PF2 valid bins:", sum(fit$params$fit_ok)), paste("Formal-use conditions met:", !provisional), paste("R version:", R.version.string)), file.path(manifest_dir, "BPF_0_245_manifest.txt"))
  writeLines(c(paste("8/8 success:", !provisional), paste("Release status:", if (provisional) "provisional" else "candidate_default"), paste("Parameters:", file.path(tables_dir, "BPF_0_245_PF8_2ensemble_parameters_for_flux.csv")), paste("Validation:", file.path(tables_dir, "BPF_0_245_fit_validation.csv"))), file.path(summary_dir, "BPF_0_245_summary.txt"))
  file.copy(normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]), winslash = "/"), file.path(scripts_dir, "run_fl_bpf_0_245_8bin.R"), overwrite = TRUE)
}

if (!identical(Sys.getenv("BPF_SOURCE_ONLY"), "1")) main()
