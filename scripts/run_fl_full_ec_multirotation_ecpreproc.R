#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

default_compare_script <- "D:/00 博士阶段/博一/05 Project/com_FLafterPF/compare/run_fl_rotation_compare_co2_20250320_0323.R"
default_bundle_index_csv <- "E:/FL_MASSBALANCE/202308/downstream_multicaliber/bundle_index.csv"
default_output_root <- "E:/Dataset_Level1/Flares/EC_ecpreproc"
default_pf_params_csv <- "E:/Dataset_Level1/Flares/BPF/BPF_default_parameters_for_flux.csv"
default_raw_root <- "E:/Dataset_Level0/Flares/EC"
default_metadata_path <- "D:/00 博士阶段/博一/05 Project/com_260507/sh20240701.metadata"
default_tz <- "Asia/Shanghai"

has_text_value <- function(x) {
  !is.na(x) && nzchar(x)
}

parse_args <- function(args) {
  opts <- list(
    compare_script = default_compare_script,
    bundle_index_csv = default_bundle_index_csv,
    output_root = default_output_root,
    pf_params_csv = default_pf_params_csv,
    raw_root = default_raw_root,
    metadata_path = default_metadata_path,
    tz = default_tz,
    source_groups = character(),
    date_from = NA_character_,
    date_to = NA_character_,
    max_files_per_source = NA_integer_
  )

  for (arg in args) {
    if (grepl("^--compare-script=", arg)) {
      opts$compare_script <- sub("^--compare-script=", "", arg)
    } else if (grepl("^--bundle-index=", arg)) {
      opts$bundle_index_csv <- sub("^--bundle-index=", "", arg)
    } else if (grepl("^--output-root=", arg)) {
      opts$output_root <- sub("^--output-root=", "", arg)
    } else if (grepl("^--pf-params=", arg)) {
      opts$pf_params_csv <- sub("^--pf-params=", "", arg)
    } else if (grepl("^--raw-root=", arg)) {
      opts$raw_root <- sub("^--raw-root=", "", arg)
    } else if (grepl("^--metadata=", arg)) {
      opts$metadata_path <- sub("^--metadata=", "", arg)
    } else if (grepl("^--tz=", arg)) {
      opts$tz <- sub("^--tz=", "", arg)
    } else if (grepl("^--source-groups=", arg)) {
      parts <- trimws(strsplit(sub("^--source-groups=", "", arg), ",", fixed = TRUE)[[1]])
      opts$source_groups <- parts[nzchar(parts)]
    } else if (grepl("^--date-from=", arg)) {
      opts$date_from <- sub("^--date-from=", "", arg)
    } else if (grepl("^--date-to=", arg)) {
      opts$date_to <- sub("^--date-to=", "", arg)
    } else if (grepl("^--max-files-per-source=", arg)) {
      opts$max_files_per_source <- as.integer(sub("^--max-files-per-source=", "", arg))
    } else if (arg %in% c("-h", "--help")) {
      cat(
        "Usage: Rscript scripts/run_fl_full_ec_multirotation_ecpreproc.R [options]\n",
        "  --compare-script=PATH\n",
        "  --bundle-index=PATH\n",
        "  --output-root=PATH\n",
        "  --pf-params=PATH\n",
        "  --raw-root=PATH\n",
        "  --metadata=PATH\n",
        "  --tz=Asia/Shanghai\n",
        "  --source-groups=oldcode_0_245,batch_b_complete,main_complete\n",
        "  --date-from=YYYY-MM-DD\n",
        "  --date-to=YYYY-MM-DD\n",
        "  --max-files-per-source=N\n",
        sep = ""
      )
      quit(save = "no", status = 0)
    } else {
      stop("Unknown argument: ", arg, call. = FALSE)
    }
  }

  if (has_text_value(opts$date_from) && is.na(as.Date(opts$date_from))) {
    stop("Invalid --date-from value.", call. = FALSE)
  }
  if (has_text_value(opts$date_to) && is.na(as.Date(opts$date_to))) {
    stop("Invalid --date-to value.", call. = FALSE)
  }
  if (has_text_value(opts$date_from) && has_text_value(opts$date_to) && as.Date(opts$date_to) < as.Date(opts$date_from)) {
    stop("--date-to cannot be earlier than --date-from.", call. = FALSE)
  }
  if (!is.na(opts$max_files_per_source) && opts$max_files_per_source <= 0L) {
    stop("--max-files-per-source must be positive.", call. = FALSE)
  }

  opts
}

source_until_pattern <- function(path, stop_pattern) {
  if (!file.exists(path)) stop("Missing compare script: ", path, call. = FALSE)
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  hit <- grep(stop_pattern, lines)
  if (length(hit) == 0L) stop("Could not find stop pattern in compare script.", call. = FALSE)
  code <- paste(lines[seq_len(hit[1] - 1L)], collapse = "\n")
  eval(parse(text = code), envir = .GlobalEnv)
}

read_bundle_index <- function(path) {
  if (!file.exists(path)) stop("Missing bundle index: ", path, call. = FALSE)
  dt <- fread(path, showProgress = FALSE)
  need <- c("source_group", "bundle_dir", "pass_csv", "cache_csv")
  miss <- setdiff(need, names(dt))
  if (length(miss) > 0L) stop("Bundle index missing columns: ", paste(miss, collapse = ", "), call. = FALSE)
  dt[]
}

copy_self_to_output <- function(output_root) {
  script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)[1]
  if (is.na(script_arg) || !nzchar(script_arg)) return(invisible(FALSE))
  script_path <- normalizePath(sub("^--file=", "", script_arg), winslash = "/", mustWork = FALSE)
  if (!file.exists(script_path)) return(invisible(FALSE))
  target_path <- normalizePath(file.path(output_root, "run_fl_full_ec_multirotation_ecpreproc.R"), winslash = "/", mustWork = FALSE)
  if (identical(script_path, target_path)) return(invisible(FALSE))
  file.copy(script_path, target_path, overwrite = TRUE)
}

patch_compare_runtime <- function() {
  split_into_aligned_blocks <- function(dt, period_sec, tz) {
    dt <- copy(as.data.table(dt))
    dt <- dt[!is.na(time)]
    if (nrow(dt) == 0L) return(list())
    dt[, window_start := as.POSIXct(floor(as.numeric(time) / period_sec) * period_sec, origin = "1970-01-01", tz = tz)]
    setorder(dt, window_start, time)
    window_keys <- format(dt$window_start, "%Y-%m-%d %H:%M:%S", tz = tz)
    idx_list <- split(seq_len(nrow(dt)), window_keys)
    blocks <- lapply(idx_list, function(idx) {
      copy(dt[idx][, !"window_start"])
    })
    blocks
  }

  process_compare_file <<- function(pf_dt, source_file, site_meta) {
    if (is.null(pf_dt) || nrow(pf_dt) == 0) return(NULL)
    setorder(pf_dt, time)
    pf_dt <- unique(pf_dt, by = c("time", "record"))
    pf_dt[, w_none := w_raw]

    fs_hz <- metadata_fs(site_meta)
    lag_cfg <- make_lag_config(site_meta, fs_hz)

    blocks <- split_into_aligned_blocks(pf_dt, config$avg_period_sec, config$tz)
    blocks <- filter_by_diag(
      blocks,
      diag_col = "diag_irga",
      good_val = 0,
      vars_to_clear = c("co2"),
      verbose = FALSE
    )
    blocks <- plausibility_check(
      blocks,
      limits = list(
        co2_min = config$co2_min,
        co2_max = config$co2_max,
        w_min = -config$w_abs_limit,
        w_max = config$w_abs_limit
      ),
      verbose = FALSE
    )
    if (!length(blocks)) return(NULL)
    blocks <- lapply(blocks, function(df) {
      df <- as.data.table(df)
      df[, w_none := w_raw]
      add_double_rotation_w(df)
    })
    blocks <- despike_selected_blocks(blocks, c("w_none", "w_dr", "w_pf", "co2"))

    method_defs <- data.table(
      rotation_method = c("no_rotation", "dr", "PF_8bin_2ensemble"),
      rotation_label = c("No rotation", "Double rotation", "PF_8bin_2ensemble"),
      w_col = c("w_none", "w_dr", "w_pf")
    )

    rows <- vector("list", nrow(method_defs))
    for (m in seq_len(nrow(method_defs))) {
      method <- method_defs[m]
      method_blocks <- lapply(blocks, function(df) {
        df <- as.data.frame(df)
        df$w <- df[[method$w_col]]
        df
      })
      method_blocks <- compensate_timelag(
        method_blocks,
        w_var = "w",
        lag_params = lag_cfg$params,
        max_missing_pct = config$max_missing_frac,
        min_corr = config$lag_min_corr,
        verbose = FALSE
      )

      block_rows <- vector("list", length(method_blocks))
      for (i in seq_along(method_blocks)) {
        df <- as.data.table(method_blocks[[i]])
        bounds <- derive_window_bounds(df, config$avg_period_sec)
        bin_qc <- prepare_ec_bin_qc_df(df, "co2", "w", fs_hz, config)
        res <- calculate_ec_block_variant(
          bin_qc$data,
          scalar = "co2",
          method_id = method$rotation_method,
          method_label = method$rotation_label,
          source_file = source_file,
          avg_period_sec = config$avg_period_sec,
          fs_hz = fs_hz,
          bin_qc = bin_qc
        )
        res[, block_id := block_name_at(method_blocks, i)]
        res[, `:=`(block_start = bounds$start, block_end = bounds$end)]
        block_rows[[i]] <- res
      }
      rows[[m]] <- rbindlist(block_rows, fill = TRUE)
    }

    out <- rbindlist(rows, fill = TRUE)
    out[qc_pass == TRUE]
  }
}

filter_passes_by_date <- function(passes, opts) {
  if (has_text_value(opts$date_from)) {
    passes <- passes[start_time >= as.POSIXct(paste0(opts$date_from, " 00:00:00"), tz = opts$tz)]
  }
  if (has_text_value(opts$date_to)) {
    passes <- passes[start_time < as.POSIXct(paste0(as.Date(opts$date_to) + 1, " 00:00:00"), tz = opts$tz)]
  }
  passes[]
}

find_target_raw_files_full <- function(passes, cfg, max_files_per_source = NA_integer_) {
  fl_cfg_local <- fl_pf_default_config()
  fl_cfg_local$raw_roots <- cfg$raw_root
  fl_cfg_local$tz_local <- cfg$tz
  inventory <- fl_pf_find_raw_files(fl_cfg_local, passes)
  if (nrow(inventory) == 0L) stop("No FL raw files found for pass dates.", call. = FALSE)

  inventory <- inventory[grepl("Time_Series_", file_name)]
  if (nrow(inventory) == 0L) stop("No Time_Series raw files remained after filename filtering.", call. = FALSE)

  header_keep <- vapply(inventory$file, function(path) {
    header <- tryCatch(
      {
        hdr <- fread(path, skip = 1, nrows = 1, header = FALSE, sep = ",", quote = "\"", showProgress = FALSE)
        as.character(unlist(hdr, use.names = FALSE))
      },
      error = function(e) character()
    )
    all(c("TIMESTAMP", "Ux", "Uy", "Uz", "CO2") %in% header)
  }, logical(1))
  inventory <- inventory[header_keep]
  if (nrow(inventory) == 0L) stop("No Time_Series files with TIMESTAMP/Ux/Uy/Uz/CO2 headers remained.", call. = FALSE)

  setorder(inventory, date_token, file)
  if (!is.na(max_files_per_source)) inventory <- inventory[seq_len(min(nrow(inventory), max_files_per_source))]
  inventory$file
}

fmt_time_local <- function(x, tz = default_tz) {
  format(x, "%Y-%m-%d %H:%M:%OS3", tz = tz)
}

write_method_outputs <- function(flux_dt, raw_files, source_group, out_dir, started, finished, opts) {
  results_dir <- file.path(out_dir, "results")
  dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)

  method_map <- list(
    no_rotation = "no_rotation",
    dr = "dr",
    PF_8bin_2ensemble = "PF_8bin_2ensemble"
  )

  registry_rows <- list()
  for (method in names(method_map)) {
    suffix <- method_map[[method]]
    dt <- copy(flux_dt[rotation_method == method])
    if (nrow(dt) == 0L) next

    setorder(dt, block_start, source_file)
    dt[, `:=`(
      source_group = source_group,
      flux_scheme = suffix,
      timestamp = fmt_time_local(block_start, opts$tz),
      date = format(block_start, "%Y-%m-%d", tz = opts$tz),
      time = format(block_start, "%H:%M:%OS3", tz = opts$tz)
    )]

    export_dt <- copy(dt)
    for (col in c("block_start", "block_end", "sample_start", "sample_end")) {
      export_dt[, (col) := fmt_time_local(get(col), opts$tz)]
    }

    main_csv <- file.path(results_dir, sprintf("FL_flux_%s.csv", suffix))
    fwrite(export_dt, main_csv)

    validation <- data.table(
      source_group = source_group,
      rotation_method = method,
      file = main_csv,
      n_input_files = length(raw_files),
      n_flux_rows = nrow(export_dt),
      first_timestamp = export_dt$timestamp[1],
      last_timestamp = export_dt$timestamp[nrow(export_dt)],
      duplicate_timestamp_count = nrow(export_dt) - uniqueN(export_dt$timestamp),
      timestamp_read_rule = "Timestamp-like fields are read as character first, then parsed explicitly with Asia/Shanghai.",
      started = format(started, "%Y-%m-%d %H:%M:%S", tz = opts$tz),
      finished = format(finished, "%Y-%m-%d %H:%M:%S", tz = opts$tz),
      elapsed_min = as.numeric(difftime(finished, started, units = "mins"))
    )
    fwrite(validation, file.path(results_dir, sprintf("FL_flux_%s_validation_summary.csv", suffix)))

    run_summary <- data.table(
      source_group = source_group,
      rotation_method = method,
      n_input_files = length(raw_files),
      n_flux_rows = nrow(export_dt),
      n_unique_timestamps = uniqueN(export_dt$timestamp),
      n_unique_dates = uniqueN(export_dt$date),
      qc_pass_rows = sum(export_dt$qc_pass, na.rm = TRUE),
      mean_coverage_frac = mean(export_dt$coverage_frac, na.rm = TRUE),
      mean_valid_seconds_window = mean(export_dt$valid_seconds_window, na.rm = TRUE),
      mean_n_bins_used = mean(export_dt$n_bins_used, na.rm = TRUE),
      mean_flux_umol_m2_s = mean(export_dt$F_EC_cov_valid_umol_m2_s, na.rm = TRUE),
      sd_flux_umol_m2_s = sd(export_dt$F_EC_cov_valid_umol_m2_s, na.rm = TRUE),
      started = format(started, "%Y-%m-%d %H:%M:%S", tz = opts$tz),
      finished = format(finished, "%Y-%m-%d %H:%M:%S", tz = opts$tz),
      elapsed_min = as.numeric(difftime(finished, started, units = "mins"))
    )
    fwrite(run_summary, file.path(results_dir, sprintf("FL_flux_%s_run_summary.csv", suffix)))

    registry_rows[[length(registry_rows) + 1L]] <- validation[, .(
      source_group, rotation_method, file, n_input_files, n_flux_rows,
      first_timestamp, last_timestamp, duplicate_timestamp_count, elapsed_min
    )]
  }

  fwrite(
    flux_dt[, .(
      source_group = source_group,
      rotation_method,
      rotation_label,
      source_file,
      block_id,
      block_start = fmt_time_local(block_start, opts$tz),
      block_end = fmt_time_local(block_end, opts$tz),
      qc_pass,
      qc_reason,
      n_valid,
      expected_n,
      coverage_frac,
      valid_seconds_window,
      n_bins_used
    )],
    file.path(results_dir, "FL_flux_multirotation_run_log.csv")
  )

  rbindlist(registry_rows, fill = TRUE)
}

run_source_group <- function(bundle_row, opts, site_meta) {
  source_group <- bundle_row$source_group[[1]]
  out_dir <- file.path(opts$output_root, source_group)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  results_dir <<- file.path(out_dir, "results")
  figures_dir <<- file.path(out_dir, "figures")
  dir.create(results_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(figures_dir, recursive = TRUE, showWarnings = FALSE)

  config$tz <<- opts$tz
  config$raw_root <<- opts$raw_root
  config$pass_csv <<- bundle_row$pass_csv[[1]]
  config$pf_params_csv <<- opts$pf_params_csv
  config$pf_running_records_cache <<- bundle_row$cache_csv[[1]]
  config$running_records_unified <<- bundle_row$cache_csv[[1]]

  fl_cfg$passes_csv <<- config$pass_csv
  fl_cfg$tz_local <<- opts$tz

  passes <- fl_pf_read_passes(fl_cfg)
  passes <- filter_passes_by_date(passes, opts)
  if (nrow(passes) == 0L) {
    return(data.table(
      source_group = source_group,
      rotation_method = NA_character_,
      file = NA_character_,
      n_input_files = 0L,
      n_flux_rows = 0L,
      first_timestamp = NA_character_,
      last_timestamp = NA_character_,
      duplicate_timestamp_count = NA_integer_,
      elapsed_min = NA_real_
    ))
  }
  config$dates <<- sort(unique(as.Date(passes$start_time, tz = opts$tz)))
  passes[, `:=`(pass_start = start_time, pass_end = end_time)]

  pf_params <- fread(config$pf_params_csv, showProgress = FALSE)
  pf_bins <- pf8_bin_table(pf_params)
  running_records <- pf8_read_running_records()
  raw_files <- find_target_raw_files_full(passes, config, opts$max_files_per_source)
  if (!length(raw_files)) stop("No target raw files found for ", source_group, call. = FALSE)

  started <- Sys.time()
  rows <- vector("list", length(raw_files))
  for (i in seq_along(raw_files)) {
    path <- raw_files[[i]]
    message(sprintf("[%s %d/%d] %s", source_group, i, length(raw_files), basename(path)))
    pf_dt <- apply_pf8bin_to_file(path, passes, pf_bins, running_records)
    if (is.null(pf_dt) || nrow(pf_dt) == 0L) next
    rows[[i]] <- process_compare_file(pf_dt, normalizePath(path, winslash = "/", mustWork = FALSE), site_meta)
  }
  flux_dt <- rbindlist(rows, fill = TRUE)
  finished <- Sys.time()
  if (nrow(flux_dt) == 0L) stop("No flux rows were generated for ", source_group, call. = FALSE)

  writeLines(
    c(
      paste("source_group:", source_group),
      paste("pass_csv:", normalizePath(config$pass_csv, winslash = "/", mustWork = FALSE)),
      paste("running_records_csv:", normalizePath(config$pf_running_records_cache, winslash = "/", mustWork = FALSE)),
      paste("pf_params_csv:", normalizePath(config$pf_params_csv, winslash = "/", mustWork = FALSE)),
      paste("n_passes:", nrow(passes)),
      paste("n_raw_files:", length(raw_files)),
      paste("started:", format(started, "%Y-%m-%d %H:%M:%S", tz = opts$tz)),
      paste("finished:", format(finished, "%Y-%m-%d %H:%M:%S", tz = opts$tz)),
      paste("elapsed_min:", as.numeric(difftime(finished, started, units = "mins"))),
      "timestamp_rule: character-first parsing with explicit Asia/Shanghai timezone",
      "qc_rule: valid_samples_by_bin"
    ),
    file.path(out_dir, "run_manifest.txt"),
    useBytes = TRUE
  )

  write_method_outputs(flux_dt, raw_files, source_group, out_dir, started, finished, opts)
}

run_self_check <- function() {
  local_chr <- "2025-09-14 00:00:00"
  toa5_chr <- "2025-09-14 00:00:00"
  parsed_local <- fl_pf_parse_local_time(local_chr, tz_local = default_tz)
  parsed_toa5 <- fl_pf_parse_toa5_time(toa5_chr, tz_local = default_tz)
  stopifnot(identical(format(parsed_local, "%Y-%m-%d %H:%M:%S", tz = default_tz), local_chr))
  stopifnot(identical(format(parsed_toa5, "%Y-%m-%d %H:%M:%S", tz = default_tz), toa5_chr))
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  dir.create(opts$output_root, recursive = TRUE, showWarnings = FALSE)
  copy_self_to_output(opts$output_root)

  source_until_pattern(opts$compare_script, "^site_meta <-")
  patch_compare_runtime()
  run_self_check()

  bundle_index <- read_bundle_index(opts$bundle_index_csv)
  if (length(opts$source_groups) > 0L) {
    bundle_index <- bundle_index[source_group %in% opts$source_groups]
    if (nrow(bundle_index) == 0L) stop("No bundle rows matched --source-groups.", call. = FALSE)
  }

  site_meta <- load_site_metadata(opts$metadata_path)
  registry <- rbindlist(lapply(seq_len(nrow(bundle_index)), function(i) run_source_group(bundle_index[i], opts, site_meta)), fill = TRUE)

  fwrite(registry, file.path(opts$output_root, "FL_ec_multirotation_registry.csv"))
  writeLines(
    c(
      "FL full EC ecpreproc manifest",
      paste("Run time:", format(Sys.time(), "%Y-%m-%d %H:%M:%S", tz = opts$tz)),
      paste("Output root:", normalizePath(opts$output_root, winslash = "/", mustWork = FALSE)),
      paste("PF params:", normalizePath(opts$pf_params_csv, winslash = "/", mustWork = FALSE)),
      paste("Bundle index:", normalizePath(opts$bundle_index_csv, winslash = "/", mustWork = FALSE)),
      paste("Raw root:", normalizePath(opts$raw_root, winslash = "/", mustWork = FALSE)),
      paste("TZ:", opts$tz),
      paste("Source groups:", paste(bundle_index$source_group, collapse = ", ")),
      paste("Date from:", if (has_text_value(opts$date_from)) opts$date_from else "ALL"),
      paste("Date to:", if (has_text_value(opts$date_to)) opts$date_to else "ALL"),
      paste("Max files per source:", if (is.na(opts$max_files_per_source)) "ALL" else opts$max_files_per_source),
      "Timestamp rule: character-first parsing with explicit Asia/Shanghai timezone.",
      "QC rule: valid_samples_by_bin."
    ),
    file.path(opts$output_root, "FL_ec_multirotation_manifest.txt"),
    useBytes = TRUE
  )
}

main()
