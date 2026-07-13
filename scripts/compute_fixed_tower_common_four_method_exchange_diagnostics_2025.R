#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

args <- commandArgs(trailingOnly = TRUE)

arg_value <- function(prefix, default = NULL) {
  hit <- args[startsWith(args, prefix)]
  if (length(hit) == 0L) return(default)
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

scenario <- arg_value("--scenario=", "strict")
tower_filter <- toupper(arg_value("--tower=", "ALL"))
year <- as.integer(arg_value("--year=", "2025"))
default_tz <- "Asia/Shanghai"

common_methods <- c("no_rotation", "dr", "global_pf", "sector_pf")
file_pattern <- "^TOA5_.*\\.Time_Series_.*\\.dat$"
com_rotation_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
ecpreproc_dir <- "D:/00 博士阶段/博一/05 Project/ecpreproc"

tower_specs <- list(
  MT = list(
    tower = "MT",
    level0_root = "E:/Dataset_Level0/MT/EC",
    meta_path = "D:/00EDDYPRO/sh_MT.metadata"
  ),
  CVT = list(
    tower = "CVT",
    level0_root = "E:/Dataset_Level0/CVT/EC",
    meta_path = "D:/00EDDYPRO/CVT_EC_for_EddyPro.metadata"
  )
)

if (!tower_filter %in% c("ALL", names(tower_specs))) {
  stop("Unsupported --tower: ", tower_filter, call. = FALSE)
}

if (scenario == "strict") {
  root <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d", year)
  run_plan_file <- file.path(root, sprintf("rotation_sensitivity_standardized_%d_run_plan.csv", year))
  output_tag <- ""
} else if (scenario == "no_qc_no_flag9") {
  root <- sprintf("E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_%d_no_qc_no_flag9", year)
  run_plan_file <- file.path(root, sprintf("rotation_sensitivity_standardized_%d_no_qc_no_flag9_run_plan.csv", year))
  output_tag <- "no_qc_no_flag9"
} else {
  stop("Unsupported --scenario: ", scenario, call. = FALSE)
}

source(file.path(com_rotation_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")
cfg <- list(project_dir = root, package_dir = ecpreproc_dir, tz = default_tz)
load_ecpreproc(cfg)

read_required <- function(path) {
  if (!file.exists(path)) stop("Missing input file: ", path, call. = FALSE)
  fread(path)
}

read_toa5_fast_subset <- function(path, tz_local = default_tz) {
  if (!file.exists(path)) stop("Missing TOA5 file: ", path, call. = FALSE)

  header_lines <- readLines(path, n = 2L, warn = FALSE, encoding = "UTF-8")
  if (length(header_lines) < 2L) return(NULL)
  raw_names <- trimws(gsub('^"|"$', "", strsplit(header_lines[[2L]], ",", fixed = TRUE)[[1L]]))

  time_idx <- match("TIMESTAMP", raw_names)
  u_idx <- match("Ux", raw_names)
  v_idx <- match("Uy", raw_names)
  w_idx <- match("Uz", raw_names)
  co2_idx <- match("CO2", raw_names)
  if (is.na(co2_idx)) co2_idx <- match("CO2_mixratio", raw_names)

  idx <- c(time_idx, u_idx, v_idx, w_idx, co2_idx)
  if (anyNA(idx)) return(NULL)

  dt <- tryCatch(
    fread(
      path,
      skip = 4L,
      header = FALSE,
      select = idx,
      col.names = c("time_chr", "u", "v", "w", "co2"),
      na.strings = c("NA", "", "-9999", "-9999.0", "-99999", "-99999.0", "NaN", "NAN", "INF", "-INF"),
      showProgress = FALSE
    ),
    error = function(e) NULL
  )
  if (is.null(dt) || nrow(dt) == 0L) return(NULL)

  dt[, time := parse_timestamp_local(time_chr, tz_local = tz_local)]
  dt <- dt[!is.na(time)]
  if (nrow(dt) == 0L) return(NULL)

  dt[, `:=`(
    u = suppressWarnings(as.numeric(u)),
    v = suppressWarnings(as.numeric(v)),
    w = suppressWarnings(as.numeric(w)),
    co2 = suppressWarnings(as.numeric(co2))
  )]
  dt <- dt[is.finite(u) & is.finite(v) & is.finite(w) & is.finite(co2), .(time, u, v, w, co2)]
  if (nrow(dt) == 0L) return(NULL)

  dt
}

safe_sd <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) < 2L) return(NA_real_)
  stats::sd(x)
}

safe_mean <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0L) return(NA_real_)
  mean(x)
}

safe_cor <- function(x, y) {
  ok <- is.finite(x) & is.finite(y)
  if (sum(ok) < 2L) return(NA_real_)
  if (safe_sd(x[ok]) == 0 || safe_sd(y[ok]) == 0) return(NA_real_)
  suppressWarnings(stats::cor(x[ok], y[ok]))
}

parse_timestamp_local <- function(timestamp_chr, date_chr = NULL, time_chr = NULL, tz_local = default_tz) {
  timestamp_chr <- trimws(as.character(timestamp_chr))
  timestamp_chr[timestamp_chr == ""] <- NA_character_
  parsed <- as.POSIXct(timestamp_chr, format = "%Y-%m-%d %H:%M:%OS", tz = tz_local)
  if (!is.null(date_chr) && !is.null(time_chr)) {
    fallback_chr <- ifelse(
      is.na(date_chr) | is.na(time_chr),
      NA_character_,
      paste(trimws(as.character(date_chr)), trimws(as.character(time_chr)))
    )
    bad <- is.na(parsed) & !is.na(fallback_chr)
    if (any(bad)) {
      parsed[bad] <- as.POSIXct(fallback_chr[bad], format = "%Y-%m-%d %H:%M", tz = tz_local)
    }
  }
  parsed
}

timestamp_key <- function(x, tz_local = default_tz) {
  format(x, "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

aligned_block_bounds_local <- function(time_vec, step_sec = 1800, fallback_tz = default_tz) {
  tt <- time_vec[!is.na(time_vec)]
  if (length(tt) == 0L) return(list(start = NULL, end = NULL))
  tz_use <- attr(tt, "tzone")
  if (is.null(tz_use) || length(tz_use) == 0L || is.na(tz_use[[1L]])) tz_use <- fallback_tz
  t0 <- min(tt, na.rm = TRUE)
  t1 <- max(tt, na.rm = TRUE)
  start <- as.POSIXct(floor(as.numeric(t0) / step_sec) * step_sec, origin = "1970-01-01", tz = tz_use[[1L]])
  end <- as.POSIXct(ceiling(as.numeric(t1) / step_sec) * step_sec, origin = "1970-01-01", tz = tz_use[[1L]])
  if (end <= t1) end <- end + step_sec
  list(start = start, end = end)
}

gapfilled_file <- function(method_output_dir, tower) {
  tag <- if (identical(output_tag, "")) "" else paste0("_", output_tag)
  file.path(method_output_dir, sprintf("%s_nee_%d_estimate%s_30min_gapfilled.csv", tower, year, tag))
}

original_flux_file <- function(input_file) {
  sub("_standardized_30min\\.csv$", ".csv", input_file)
}

rotation_rds_file <- function(input_file) {
  flux_file <- original_flux_file(input_file)
  sub("\\.csv$", "_rotation_details.rds", flux_file)
}

make_flux_blocks <- function(df, meta) {
  attr(df, "metadata") <- meta
  structure(
    list(
      blocks = list(df),
      meta = list(
        mapping = meta$mapping,
        instruments = meta$instruments,
        station = meta$station,
        site = meta$site,
        status = list()
      )
    ),
    class = "flux_blocks"
  )
}

collect_common_keys <- function(run_plan_one_tower) {
  key_list <- lapply(seq_len(nrow(run_plan_one_tower)), function(i) {
    row <- run_plan_one_tower[i]
    dt <- read_required(gapfilled_file(row$method_output_dir[[1]], row$tower[[1]]))
    dt[as.logical(valid_final) == TRUE, unique(as.character(ts_key))]
  })
  common_keys <- Reduce(intersect, key_list)
  sort(unique(common_keys))
}

select_candidate_files <- function(level0_root, common_keys) {
  all_files <- sort(list.files(level0_root, pattern = file_pattern, full.names = TRUE, recursive = TRUE))
  if (length(all_files) == 0L) stop("No Level0 TOA5 files found in: ", level0_root, call. = FALSE)

  parse_file_start <- function(path) {
    hit <- regmatches(basename(path), regexpr("[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{4}", basename(path)))
    if (length(hit) == 0L || identical(hit, character(0))) return(as.POSIXct(NA_real_, origin = "1970-01-01", tz = default_tz))
    as.POSIXct(hit, format = "%Y_%m_%d_%H%M", tz = default_tz)
  }

  file_dt <- data.table(file = all_files, file_start = as.POSIXct(vapply(all_files, function(x) as.numeric(parse_file_start(x)), numeric(1)), origin = "1970-01-01", tz = default_tz))
  file_dt <- file_dt[!is.na(file_start)][order(file_start)]
  if (nrow(file_dt) == 0L) return(all_files)

  key_time <- as.POSIXct(common_keys, format = "%Y-%m-%d %H:%M:%S", tz = default_tz)
  file_dt[, file_end := shift(file_start, type = "lead")]
  file_dt[is.na(file_end), file_end := as.POSIXct("2100-01-01 00:00:00", tz = default_tz)]
  idx_raw <- findInterval(as.numeric(key_time), as.numeric(file_dt$file_start))
  ok_raw <- idx_raw > 0L
  idx_keep <- idx_raw[ok_raw]
  ts_keep <- key_time[ok_raw]
  ok_span <- as.numeric(ts_keep) < as.numeric(file_dt$file_end[idx_keep])
  keep_idx <- unique(idx_keep[ok_span])
  out <- file_dt$file[keep_idx]
  if (length(out) == 0L) {
    # ponytail: keep the date-token fallback when file-start inference misses an edge case.
    key_dates <- as.Date(key_time, tz = default_tz)
    keep_dates <- sort(unique(c(key_dates, key_dates - 1L)))
    keep_tokens <- format(keep_dates, "%Y_%m_%d")
    keep_pattern <- paste(keep_tokens, collapse = "|")
    out <- all_files[grepl(keep_pattern, basename(all_files))]
  }
  out <- unique(out[!is.na(out) & nzchar(out)])
  if (length(out) == 0L) return(all_files)
  out
}

prepare_method_context <- function(method_row) {
  method <- method_row$method[[1]]
  fit_results <- NULL
  if (method %in% c("global_pf", "sector_pf")) {
    fit_path <- rotation_rds_file(method_row$input_file[[1]])
    if (!file.exists(fit_path)) stop("Missing rotation details: ", fit_path, call. = FALSE)
    fit_results <- readRDS(fit_path)
  }

  flux_dt <- read_required(original_flux_file(method_row$input_file[[1]]))
  flux_dt[, timestamp_local := parse_timestamp_local(timestamp, date, time, tz_local = default_tz)]
  flux_dt <- flux_dt[!is.na(timestamp_local)]
  flux_dt[, ts_key := timestamp_key(timestamp_local, tz_local = default_tz)]
  if (!"source_dir" %in% names(flux_dt)) flux_dt[, source_dir := NA_character_]
  flux_dt <- unique(
    flux_dt[, .(
      ts_key,
      source_timestamp = timestamp,
      source_date = date,
      source_time = time,
      co2_flux = suppressWarnings(as.numeric(co2_flux)),
      qc_co2 = suppressWarnings(as.numeric(qc_co2)),
      flag9_co2 = suppressWarnings(as.numeric(flag9_co2)),
      u_star = suppressWarnings(as.numeric(u_star)),
      source_dir = as.character(source_dir)
    )],
    by = "ts_key"
  )

  gap_dt <- read_required(gapfilled_file(method_row$method_output_dir[[1]], method_row$tower[[1]]))
  gap_dt <- unique(
    gap_dt[, .(
      ts_key = as.character(ts_key),
      valid_final = as.logical(valid_final),
      filled_by_gapfill = as.logical(filled_by_gapfill),
      fill_method = as.character(fill_method),
      observed_component_gC_m2 = suppressWarnings(as.numeric(observed_component_gC_m2)),
      total_component_gC_m2 = suppressWarnings(as.numeric(total_component_gC_m2))
    )],
    by = "ts_key"
  )

  list(
    tower = method_row$tower[[1]],
    method = method,
    method_output_dir = method_row$method_output_dir[[1]],
    fit_results = fit_results,
    flux_dt = flux_dt,
    gap_dt = gap_dt
  )
}

finalize_method_result <- function(method_ctx, out_rows) {
  out <- rbindlist(out_rows, use.names = TRUE, fill = TRUE)
  if (nrow(out) == 0L) stop("No diagnostics rows were computed for ", method_ctx$tower, " / ", method_ctx$method, call. = FALSE)
  setorder(out, ts_key, -n_points)
  out <- out[, .SD[1L], by = ts_key]
  out <- merge(out, method_ctx$flux_dt, by = "ts_key", all.x = TRUE, sort = FALSE)
  out <- merge(out, method_ctx$gap_dt, by = "ts_key", all.x = TRUE, sort = FALSE)
  out[, `:=`(
    common_method_window = TRUE,
    scenario = scenario,
    year = year
  )]

  setcolorder(out, c(
    "tower", "method", "scenario", "year", "ts_key", "block_timestamp",
    "common_method_window", "valid_final", "filled_by_gapfill", "fill_method",
    "co2_flux", "observed_component_gC_m2", "total_component_gC_m2",
    "w_mean", "c_mean", "sigma_w", "sigma_c", "rwc", "Fc", "Fneg", "Fpos",
    "n_points", "n_neg", "n_pos", "qc_co2", "flag9_co2", "u_star",
    "source_date", "source_time", "source_timestamp", "source_dir", "source_file"
  ))
  out
}

restrict_to_complete_common_diagnostics <- function(results, tower, expected_keys) {
  diagnostic_columns <- c("sigma_w", "sigma_c", "rwc", "Fc", "Fneg", "Fpos")
  complete_keys <- lapply(results, function(dt) {
    dt[complete.cases(dt[, ..diagnostic_columns]), unique(ts_key)]
  })
  shared_keys <- sort(Reduce(intersect, complete_keys))
  excluded <- setdiff(expected_keys, shared_keys)
  if (length(shared_keys) == 0L) {
    stop("No complete common diagnostics remain for tower: ", tower, call. = FALSE)
  }

  results <- lapply(results, function(dt) {
    out <- dt[ts_key %chin% shared_keys][order(ts_key)]
    if (nrow(out) != length(shared_keys) || any(!complete.cases(out[, ..diagnostic_columns]))) {
      stop("Incomplete diagnostics after common-window restriction for tower: ", tower, call. = FALSE)
    }
    out
  })
  message(sprintf("[%s] retained %d/%d NEE-common windows with complete diagnostics", tower, length(shared_keys), length(expected_keys)))
  if (length(excluded) > 0L) {
    message(sprintf("[%s] excluded %d NEE-common windows without complete raw diagnostics", tower, length(excluded)))
  }
  results
}

build_tower_results <- function(tower_spec, tower_run_plan, common_keys) {
  meta <- ec_read_metadata(tower_spec$meta_path)
  ec_set_metadata(meta)
  method_ctxs <- lapply(seq_len(nrow(tower_run_plan)), function(i) prepare_method_context(tower_run_plan[i]))
  names(method_ctxs) <- vapply(method_ctxs, `[[`, character(1), "method")
  out_rows <- setNames(vector("list", length(method_ctxs)), names(method_ctxs))
  out_n <- setNames(integer(length(method_ctxs)), names(method_ctxs))

  files <- select_candidate_files(tower_spec$level0_root, common_keys)
  common_key_lookup <- unique(common_keys)
  for (file_idx in seq_along(files)) {
    file <- files[[file_idx]]
    if (file_idx %% 25L == 0L || file_idx == 1L || file_idx == length(files)) {
      message(sprintf("[%s] reading file %d/%d: %s", tower_spec$tower, file_idx, length(files), basename(file)))
    }
    dat <- read_toa5_fast_subset(file, tz_local = default_tz)
    if (is.null(dat) || nrow(dat) == 0L) next

    bounds <- aligned_block_bounds_local(dat$time, fallback_tz = default_tz)
    blocks <- tryCatch(
      split_data_into_blocks(
        dat,
        interval = "30 min",
        start_time = bounds$start,
        end_time = bounds$end,
        return = "list",
        drop_empty = TRUE
      ),
      error = function(e) NULL
    )
    if (is.null(blocks) || length(blocks) == 0L) next

    for (blk in blocks) {
      if (!is.data.frame(blk) || nrow(blk) == 0L || !"time" %in% names(blk)) next
      ts <- suppressWarnings(min(blk$time, na.rm = TRUE))
      ts_key <- timestamp_key(ts, tz_local = default_tz)
      if (!ts_key %chin% common_key_lookup) next
      if (!all(c("u", "v", "w", "co2") %in% names(blk))) next

      for (method_name in names(method_ctxs)) {
        method_ctx <- method_ctxs[[method_name]]
        fb <- make_flux_blocks(blk, meta)
        fb <- rotate_coordinates(
          fb,
          method = c(
            no_rotation = "none",
            dr = "dr",
            global_pf = "pf",
            sector_pf = "spf"
          )[[method_name]],
          fit_results = method_ctx$fit_results,
          verbose = FALSE
        )
        fb <- calculate_fluctuations(fb, vars = c("w_rot", "co2"), method = "block", verbose = FALSE)
        dfp <- fb$blocks[[1L]]

        valid <- is.finite(dfp$w_rot_prime) & is.finite(dfp$co2_prime)
        if (sum(valid) < 2L) next
        q <- dfp$w_rot_prime[valid] * dfp$co2_prime[valid]
        q_neg <- q[q < 0]
        q_pos <- q[q > 0]

        out_n[[method_name]] <- out_n[[method_name]] + 1L
        out_rows[[method_name]][[out_n[[method_name]]]] <- data.table(
          tower = tower_spec$tower,
          method = method_name,
          ts_key = ts_key,
          block_timestamp = timestamp_key(ts, tz_local = default_tz),
          source_file = file,
          n_points = sum(valid),
          w_mean = safe_mean(dfp$w_rot[valid]),
          c_mean = safe_mean(dfp$co2[valid]),
          sigma_w = safe_sd(dfp$w_rot[valid]),
          sigma_c = safe_sd(dfp$co2[valid]),
          rwc = safe_cor(dfp$w_rot_prime[valid], dfp$co2_prime[valid]),
          Fc = safe_mean(q),
          Fneg = if (length(q_neg) > 0L) mean(q_neg) else NA_real_,
          Fpos = if (length(q_pos) > 0L) mean(q_pos) else NA_real_,
          n_neg = length(q_neg),
          n_pos = length(q_pos)
        )
      }
    }
  }

  results <- vector("list", length(method_ctxs))
  names(results) <- names(method_ctxs)
  for (method_name in names(method_ctxs)) {
    results[[method_name]] <- finalize_method_result(
      method_ctxs[[method_name]],
      out_rows[[method_name]][seq_len(out_n[[method_name]])]
    )
  }
  restrict_to_complete_common_diagnostics(results, tower_spec$tower, common_keys)
}

write_method_outputs <- function(method_row, result_dt) {
  method_dir <- method_row$method_output_dir[[1]]
  scenario_tag <- if (scenario == "strict") "" else paste0("_", scenario)
  tower <- method_row$tower[[1]]
  method <- method_row$method[[1]]
  out_csv <- file.path(
    method_dir,
    sprintf("%s_common_four_method_valid_window_exchange_diagnostics_%d%s.csv", tower, year, scenario_tag)
  )
  out_summary <- file.path(
    method_dir,
    sprintf("%s_common_four_method_valid_window_exchange_diagnostics_%d%s_summary.txt", tower, year, scenario_tag)
  )
  fwrite(result_dt, out_csv)
  writeLines(c(
    "Fixed-tower common four-method valid-window exchange diagnostics",
    paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    paste0("Tower: ", tower),
    paste0("Method: ", method),
    paste0("Scenario: ", scenario),
    paste0("Rows: ", nrow(result_dt)),
    "",
    "Definitions:",
    "- Window set = timestamps where this tower has valid_final == TRUE in all four common methods and all six raw diagnostics are finite for every method.",
    "- sigma_w = sd(w_rot) within the 30 min block.",
    "- sigma_c = sd(co2) within the 30 min block.",
    "- rwc = cor(w', c') after block-mean fluctuation calculation.",
    "- Fc = mean(w' * c') within the 30 min block.",
    "- Fneg = mean(q_i | q_i < 0), Fpos = mean(q_i | q_i > 0), q_i = w'_i * c'_i.",
    "",
    paste0("Output CSV: ", out_csv)
  ), out_summary, useBytes = TRUE)
}

run_plan <- read_required(run_plan_file)
run_plan <- run_plan[common_method == TRUE & method %in% common_methods]
if (tower_filter != "ALL") {
  run_plan <- run_plan[tower == tower_filter]
}
if (nrow(run_plan) == 0L) stop("No run-plan rows matched the requested scope.", call. = FALSE)

towers_to_run <- unique(run_plan$tower)
for (tower_name in towers_to_run) {
  tower_run_plan <- run_plan[tower == tower_name][order(match(method, common_methods))]
  stopifnot(nrow(tower_run_plan) == length(common_methods))
  common_keys <- collect_common_keys(tower_run_plan)
  if (length(common_keys) == 0L) stop("No common valid windows found for tower: ", tower_name, call. = FALSE)

  tower_spec <- tower_specs[[tower_name]]
  method_results <- build_tower_results(tower_spec, tower_run_plan, common_keys)
  for (i in seq_len(nrow(tower_run_plan))) {
    method_name <- tower_run_plan$method[[i]]
    write_method_outputs(tower_run_plan[i], method_results[[method_name]])
  }
}

message("Completed common four-method exchange diagnostics for scenario: ", scenario)
