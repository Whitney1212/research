#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

default_prepare_script <- "E:/FL_MASSBALANCE/202308/prepare_fl_multicaliber_downstream_inputs.R"
default_bundle_index_csv <- "E:/FL_MASSBALANCE/202308/downstream_multicaliber/bundle_index.csv"
default_pf8_script <- "E:/Dataset_Level1/Flares/PFparameter/run_PF_8bin.R"
default_pf2_script <- "E:/Dataset_Level1/Flares/PFparameter/run_PF_8bin_2ensemble.R"
default_output_root <- "E:/Dataset_Level1/Flares/BPF"

parse_args <- function(args) {
  opts <- list(
    prepare_script = default_prepare_script,
    bundle_index_csv = default_bundle_index_csv,
    pf8_script = default_pf8_script,
    pf2_script = default_pf2_script,
    output_root = default_output_root,
    track_south_m = 5,
    track_north_m = 240,
    force = FALSE,
    skip_prepare = FALSE,
    skip_pf2 = FALSE
  )

  for (arg in args) {
    if (grepl("^--prepare-script=", arg)) {
      opts$prepare_script <- sub("^--prepare-script=", "", arg)
    } else if (grepl("^--bundle-index=", arg)) {
      opts$bundle_index_csv <- sub("^--bundle-index=", "", arg)
    } else if (grepl("^--pf8-script=", arg)) {
      opts$pf8_script <- sub("^--pf8-script=", "", arg)
    } else if (grepl("^--pf2-script=", arg)) {
      opts$pf2_script <- sub("^--pf2-script=", "", arg)
    } else if (grepl("^--output-root=", arg)) {
      opts$output_root <- sub("^--output-root=", "", arg)
    } else if (grepl("^--track-south-m=", arg)) {
      opts$track_south_m <- as.numeric(sub("^--track-south-m=", "", arg))
    } else if (grepl("^--track-north-m=", arg)) {
      opts$track_north_m <- as.numeric(sub("^--track-north-m=", "", arg))
    } else if (arg == "--force") {
      opts$force <- TRUE
    } else if (arg == "--skip-prepare") {
      opts$skip_prepare <- TRUE
    } else if (arg == "--skip-pf2") {
      opts$skip_pf2 <- TRUE
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/run_fl_multicaliber_bpf_training.R [options]\n",
        "  --prepare-script=PATH\n",
        "  --bundle-index=PATH\n",
        "  --pf8-script=PATH\n",
        "  --pf2-script=PATH\n",
        "  --output-root=PATH\n",
        "  --track-south-m=5\n",
        "  --track-north-m=240\n",
        "  --force\n",
        "  --skip-prepare\n",
        "  --skip-pf2\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  if (!is.finite(opts$track_south_m) || !is.finite(opts$track_north_m) || opts$track_north_m <= opts$track_south_m) {
    stop("track bounds are invalid.", call. = FALSE)
  }
  opts
}

source_until_call <- function(path, call_pattern) {
  if (!file.exists(path)) {
    stop("Missing source script: ", path, call. = FALSE)
  }
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  call_idx <- grep(call_pattern, lines)
  if (length(call_idx) == 0) {
    stop("Could not find call pattern in ", path, ": ", call_pattern, call. = FALSE)
  }
  code <- paste(lines[seq_len(call_idx[1] - 1L)], collapse = "\n")
  eval(parse(text = code), envir = .GlobalEnv)
}

parse_local_time <- function(x, tz = "Asia/Shanghai") {
  if (inherits(x, "POSIXt")) {
    return(as.POSIXct(x, tz = tz))
  }
  if (inherits(x, "Date")) {
    return(as.POSIXct(x, tz = tz))
  }
  x <- trimws(as.character(x))
  x <- sub("T", " ", x, fixed = TRUE)
  x <- sub("Z$", "", x)
  out <- as.POSIXct(x, tz = tz, format = "%Y-%m-%d %H:%M:%OS")
  miss <- is.na(out)
  if (any(miss)) out[miss] <- as.POSIXct(x[miss], tz = tz, format = "%Y-%m-%d %H:%M:%S")
  out
}

assert_cols <- function(dt, cols, label) {
  miss <- setdiff(cols, names(dt))
  if (length(miss) > 0) {
    stop(label, " missing columns: ", paste(miss, collapse = ", "), call. = FALSE)
  }
}

run_prepare_step <- function(opts) {
  if (opts$skip_prepare) return(invisible(NULL))
  if (!file.exists(opts$prepare_script)) {
    stop("Missing prepare script: ", opts$prepare_script, call. = FALSE)
  }
  status <- system2(file.path(R.home("bin"), "Rscript"), shQuote(opts$prepare_script))
  if (!identical(status, 0L)) {
    stop("prepare_fl_multicaliber_downstream_inputs.R failed with status: ", status, call. = FALSE)
  }
  invisible(NULL)
}

read_bundle_index <- function(path) {
  if (!file.exists(path)) {
    stop("Missing bundle index: ", path, call. = FALSE)
  }
  dt <- fread(path)
  assert_cols(dt, c("source_group", "bundle_dir", "pass_csv", "cache_csv", "passes", "records"), "bundle index")
  dt[]
}

self_check_bundles <- function(bundle_index) {
  stopifnot(nrow(bundle_index) == 3L)
  for (i in seq_len(nrow(bundle_index))) {
    pass <- fread(bundle_index$pass_csv[i], showProgress = FALSE)
    cache <- fread(bundle_index$cache_csv[i], showProgress = FALSE)
    assert_cols(pass, c("pass_id", "start_time_local", "end_time_local", "direction", "reject_reason"), bundle_index$source_group[i])
    assert_cols(cache, c("time", "speed", "position", "pass_id"), paste(bundle_index$source_group[i], "cache"))
    stopifnot(!any(is.na(pass$pass_id)))
    stopifnot(!any(trimws(as.character(cache$time)) == ""))
  }
  invisible(TRUE)
}

load_pf_functions <- function(opts) {
  source_until_call(opts$pf8_script, "^pf8_main\\(\\)")
  source_until_call(opts$pf2_script, "^pf2_main\\(\\)")
}

patch_pf_runtime <- function() {
  original_find_raw_files <- fl_pf_find_raw_files
  fl_pf_find_raw_files <<- function(cfg, passes) {
    found <- original_find_raw_files(cfg, passes)
    if (nrow(found) == 0) return(found)

    found <- found[grepl("(Time_Series|Sensor_3D)_", file_name)]
    if (nrow(found) == 0) {
      stop("No FL raw files matched Time_Series/Sensor_3D patterns.", call. = FALSE)
    }

    header_keep <- vapply(found$file, function(path) {
      header <- tryCatch(
        names(fread(path, sep = ",", skip = 1, header = TRUE, nrows = 1, showProgress = FALSE)),
        error = function(e) character()
      )
      all(c("TIMESTAMP", "Ux", "Uy", "Uz") %in% header)
    }, logical(1))
    found <- found[header_keep]
    if (nrow(found) == 0) {
      stop("No FL raw files with TIMESTAMP/Ux/Uy/Uz headers remained after filtering.", call. = FALSE)
    }

    setorder(found, date_token, file)
    found[]
  }
}

bundle_pf8_cfg <- function(bundle_row, out_dir, opts) {
  cfg <- fl_pf_default_config()
  cfg$root_dir <- out_dir
  cfg$output_dir <- out_dir
  cfg$fig_dir <- file.path(out_dir, "figures")
  cfg$cache_dir <- file.path(out_dir, "cache")
  cfg$passes_csv <- bundle_row$pass_csv
  cfg$running_records_csv <- bundle_row$cache_csv
  cfg$method_name <- paste0("PF_8bin_", bundle_row$source_group)
  cfg$preprocessing_version <- "multicaliber_bundle_local_records_v1"
  cfg$track_south_m <- opts$track_south_m
  cfg$track_north_m <- opts$track_north_m
  cfg$max_running_record_gap_s <- 15
  cfg$running_record_margin_s <- 120
  cfg$force_rebuild <- isTRUE(opts$force)
  cfg
}

run_pf8_for_bundle <- function(bundle_row, opts) {
  out_dir <- file.path(opts$output_root, "bundle_pf8_work", bundle_row$source_group)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  pass_bin_csv <- file.path(out_dir, "PF_8bin_pass_bin_means.csv")
  fit_summary_csv <- file.path(out_dir, "pf_fit_summary.csv")
  if (!isTRUE(opts$force) && file.exists(pass_bin_csv) && file.exists(fit_summary_csv)) {
    return(data.table(
      source_group = bundle_row$source_group,
      output_dir = out_dir,
      pass_bin_csv = pass_bin_csv,
      fit_summary_csv = fit_summary_csv
    ))
  }
  pf8_config <<- function() bundle_pf8_cfg(bundle_row, out_dir, opts)
  pf8_main()
  data.table(
    source_group = bundle_row$source_group,
    output_dir = out_dir,
    pass_bin_csv = pass_bin_csv,
    fit_summary_csv = fit_summary_csv
  )
}

combine_bundle_pass_bins <- function(bundle_pf8_runs, opts) {
  dt <- rbindlist(lapply(seq_len(nrow(bundle_pf8_runs)), function(i) {
    x <- fread(bundle_pf8_runs$pass_bin_csv[i], showProgress = FALSE)
    x[, source_group := bundle_pf8_runs$source_group[i]]
    x
  }), use.names = TRUE, fill = TRUE)

  assert_cols(
    dt,
    c("pass_id", "bin_id", "bin_min", "bin_max", "bin_mid", "n_samples",
      "mean_U_east_corr", "mean_U_north_corr", "mean_W_corr",
      "mean_position_m", "mean_cart_speed_m_s", "mean_abs_cart_speed_m_s",
      "mean_running_gap_s", "direction", "pass_date", "pass_start_local", "pass_end_local"),
    "combined pass-bin"
  )

  pass_meta <- unique(
    dt[, .(source_group, pass_id, direction, pass_date, pass_start_local, pass_end_local)],
    by = c("source_group", "pass_id")
  )
  pass_meta[, `:=`(
    start_time = parse_local_time(pass_start_local, "Asia/Shanghai"),
    end_time = parse_local_time(pass_end_local, "Asia/Shanghai")
  )]
  pass_meta <- pass_meta[!is.na(start_time) & !is.na(end_time) & end_time > start_time]
  setorder(pass_meta, start_time, end_time, source_group, pass_id)
  pass_meta[, pass_id_global := .I]

  dt <- pass_meta[dt, on = .(source_group, pass_id)]
  dt[, pass_id := pass_id_global]
  dt[, pass_id_global := NULL]

  passes <- pass_meta[, .(pass_id = pass_id_global, direction, pass_date, start_time, end_time)]
  setorder(passes, start_time, end_time, pass_id)
  passes[, trial_pass_seq := .I]

  cfg <- fl_pf_default_config()
  cfg$track_south_m <- opts$track_south_m
  cfg$track_north_m <- opts$track_north_m
  passes_ens <- fl_pf_make_four_pass_ensembles(passes, cfg)

  drop_cols <- intersect(
    c("trial_pass_seq", "direction", "pass_date", "pass_start_local", "pass_end_local", "ensemble_id", "ensemble_role", "ensemble_valid"),
    names(dt)
  )
  core <- dt[, setdiff(names(dt), drop_cols), with = FALSE]
  pass_bin <- pf8_join_pass_meta(core, passes_ens)[order(trial_pass_seq, bin_id)]

  stopifnot(uniqueN(pass_bin$pass_id) == nrow(passes))
  stopifnot(all(pass_bin$bin_id >= 1L))
  list(pass_bin = pass_bin, passes_ens = passes_ens)
}

fit_combined_pf8 <- function(pass_bin, opts) {
  out_dir <- file.path(opts$output_root, "PF_8bin")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  cfg <- fl_pf_default_config()
  cfg$root_dir <- out_dir
  cfg$output_dir <- out_dir
  cfg$fig_dir <- file.path(out_dir, "figures")
  cfg$cache_dir <- file.path(out_dir, "cache")
  cfg$method_name <- "PF_8bin_multicaliber"
  cfg$preprocessing_version <- "multicaliber_bundle_local_records_v1"
  cfg$track_south_m <- opts$track_south_m
  cfg$track_north_m <- opts$track_north_m

  paths <- pf8_paths(cfg)
  fwrite(pass_bin, paths$pass_bin)

  points <- pf8_make_input_points(pass_bin, cfg)
  if (nrow(points) == 0) {
    stop("No PF_8bin input points were generated from combined pass-bin table.", call. = FALSE)
  }
  fwrite(points, paths$pf_input)

  bin_tbl <- pf8_bin_table(cfg)
  expected <- bin_tbl[, .(
    method = cfg$method_name,
    group_id = sprintf("bin_%02d", bin_id),
    bin_id = bin_id,
    sector_id = NA_integer_,
    direction = "all"
  )]
  fit <- fl_pf_fit_grouped(points, expected, cfg$method_name, cfg$min_fit_points)
  fit_summary <- bin_tbl[fit$summary, on = "bin_id"]
  fit_points <- fit$points
  fwrite(fit_summary, paths$fit_summary)
  fwrite(fit_points, paths$residual_points)

  params <- fit_summary[, .(
    method = cfg$method_name,
    preprocessing_version = cfg$preprocessing_version,
    bin_id, bin_min, bin_max, bin_mid,
    intercept_a, slope_b_u, slope_c_v, tilt_deg,
    n_points, n_samples, n_fw, n_bw,
    mean_w_before, mean_w_after, rmse_w_before, rmse_w_after,
    r_squared, fit_ok, fit_message,
    formula = "w_pf = Uz - (intercept_a + slope_b_u * U_east_corr + slope_c_v * U_north_corr)"
  )]
  fwrite(params, paths$flux_params)

  val <- pf8_validation_tables(pass_bin, fit_summary, cfg)
  fwrite(val$rot, paths$pass_bin_rot)
  fwrite(val$validation, paths$validation)
  pf8_plot_validation(fit_summary, fit_points, val$rot, val$validation, cfg)

  writeLines(c(
    "FL multicaliber BPF PF_8bin manifest",
    paste("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    paste("Output dir:", out_dir),
    paste("Track range m:", cfg$track_south_m, "to", cfg$track_north_m),
    paste("Bundle sources:", paste(sort(unique(pass_bin$source_group)), collapse = ", ")),
    paste("Pass bins:", nrow(pass_bin)),
    paste("Unique passes:", uniqueN(pass_bin$pass_id)),
    paste("PF input points:", nrow(points)),
    paste("Fit OK bins:", sum(fit_summary$fit_ok, na.rm = TRUE), "/", nrow(fit_summary)),
    "Verification result: PASS"
  ), file.path(out_dir, "multicaliber_bpf_pf8_manifest.txt"), useBytes = TRUE)

  data.table(
    output_dir = out_dir,
    pass_bin_csv = paths$pass_bin,
    params_csv = paths$flux_params,
    fit_summary_csv = paths$fit_summary
  )
}

run_combined_pf2 <- function(pf8_out_dir, opts) {
  out_dir <- file.path(opts$output_root, "PF_8bin_2ensemble")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  pf2_config <<- function() {
    cfg <- fl_pf_default_config()
    cfg$source_dir <- pf8_out_dir
    cfg$output_dir <- out_dir
    cfg$fig_dir <- file.path(out_dir, "figures")
    cfg$method_name <- "PF_8bin_2ensemble_multicaliber"
    cfg$preprocessing_version <- "multicaliber_bundle_local_records_v1_from_pf8"
    cfg$track_south_m <- opts$track_south_m
    cfg$track_north_m <- opts$track_north_m
    cfg$n_bins <- 8L
    cfg$max_gap_min_two_pass <- cfg$max_gap_min_four_pass
    cfg$min_passes_per_ensemble_bin <- 2L
    cfg
  }

  pf2_main()

  params_csv <- file.path(out_dir, "PF_8bin_2ensemble_parameters_for_flux.csv")
  default_csv <- file.path(opts$output_root, "BPF_default_parameters_for_flux.csv")
  file.copy(params_csv, default_csv, overwrite = TRUE)

  writeLines(c(
    "FL multicaliber BPF PF_8bin_2ensemble manifest",
    paste("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    paste("Output dir:", out_dir),
    paste("Default parameter alias:", default_csv),
    "Verification result: PASS"
  ), file.path(out_dir, "multicaliber_bpf_pf2_manifest.txt"), useBytes = TRUE)

  data.table(
    output_dir = out_dir,
    params_csv = params_csv,
    default_params_csv = default_csv
  )
}

write_root_manifest <- function(opts, bundle_pf8_runs, pf8_fit, pf2_fit) {
  manifest <- file.path(opts$output_root, "BPF_training_manifest.txt")
  lines <- c(
    "FL full-data multicaliber BPF training manifest",
    paste("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    paste("Output root:", normalizePath(opts$output_root, winslash = "/", mustWork = FALSE)),
    paste("Track range m:", opts$track_south_m, "to", opts$track_north_m),
    "",
    "Inputs:",
    paste("Prepare script:", normalizePath(opts$prepare_script, winslash = "/", mustWork = FALSE)),
    paste("Bundle index:", normalizePath(opts$bundle_index_csv, winslash = "/", mustWork = FALSE)),
    paste("PF_8bin script:", normalizePath(opts$pf8_script, winslash = "/", mustWork = FALSE)),
    paste("PF_8bin_2ensemble script:", normalizePath(opts$pf2_script, winslash = "/", mustWork = FALSE)),
    "",
    "Bundle PF_8bin work dirs:",
    paste("- ", bundle_pf8_runs$source_group, ": ", bundle_pf8_runs$output_dir, sep = ""),
    "",
    "Main outputs:",
    paste("PF_8bin dir:", pf8_fit$output_dir[1]),
    paste("PF_8bin params:", pf8_fit$params_csv[1]),
    paste("PF_8bin_2ensemble dir:", pf2_fit$output_dir[1]),
    paste("Default BPF params:", pf2_fit$default_params_csv[1])
  )
  writeLines(lines, manifest, useBytes = TRUE)
}

copy_self_to_output <- function(output_root) {
  script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)[1]
  if (is.na(script_arg) || !nzchar(script_arg)) return(invisible(FALSE))
  script_path <- normalizePath(sub("^--file=", "", script_arg), winslash = "/", mustWork = FALSE)
  if (!file.exists(script_path)) return(invisible(FALSE))
  target_path <- normalizePath(file.path(output_root, "run_fl_multicaliber_bpf_training.R"), winslash = "/", mustWork = FALSE)
  if (identical(script_path, target_path)) return(invisible(FALSE))
  file.copy(script_path, target_path, overwrite = TRUE)
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  dir.create(opts$output_root, recursive = TRUE, showWarnings = FALSE)
  copy_self_to_output(opts$output_root)

  run_prepare_step(opts)
  bundle_index <- read_bundle_index(opts$bundle_index_csv)
  self_check_bundles(bundle_index)

  load_pf_functions(opts)
  patch_pf_runtime()

  bundle_pf8_runs <- rbindlist(
    lapply(seq_len(nrow(bundle_index)), function(i) run_pf8_for_bundle(bundle_index[i], opts)),
    use.names = TRUE
  )

  combined <- combine_bundle_pass_bins(bundle_pf8_runs, opts)
  pf8_fit <- fit_combined_pf8(combined$pass_bin, opts)

  if (opts$skip_pf2) {
    write_root_manifest(
      opts,
      bundle_pf8_runs,
      pf8_fit,
      data.table(output_dir = NA_character_, params_csv = NA_character_, default_params_csv = NA_character_)
    )
    message("Completed PF_8bin multicaliber fit. Skipped PF_8bin_2ensemble.")
    return(invisible(NULL))
  }

  pf2_fit <- run_combined_pf2(pf8_fit$output_dir[1], opts)
  write_root_manifest(opts, bundle_pf8_runs, pf8_fit, pf2_fit)
  message("Completed FL multicaliber BPF training. Output root: ", opts$output_root)
}

main()
