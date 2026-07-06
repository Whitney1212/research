#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(lubridate)
})

tz_local <- "Asia/Shanghai"
Sys.setenv(TZ = tz_local)

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || is.na(x) || x == "") y else x
}

parse_args <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  out <- list()
  for (arg in args) {
    if (!startsWith(arg, "--")) next
    parts <- strsplit(sub("^--", "", arg), "=", fixed = TRUE)[[1]]
    key <- parts[1]
    value <- if (length(parts) > 1) paste(parts[-1], collapse = "=") else "TRUE"
    out[[key]] <- value
  }
  out
}

as_flag <- function(x, default = FALSE) {
  if (is.null(x)) return(default)
  tolower(x) %in% c("1", "true", "t", "yes", "y")
}

fmt_time <- function(x) {
  format(with_tz(x, tzone = tz_local), "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

safe_time_range <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    return(list(start = NA_character_, end = NA_character_))
  }
  list(start = fmt_time(min(x)), end = fmt_time(max(x)))
}

safe_rbind <- function(lst) {
  if (length(lst) == 0) {
    return(data.table())
  }
  rbindlist(lst, use.names = TRUE, fill = TRUE)
}

empty_bad_files_table <- function() {
  data.table(
    file_index = integer(),
    source_file = character(),
    source_path = character(),
    error_message = character()
  )
}

normalize_timestamp_ap <- function(x) {
  x <- as.character(x)
  x <- gsub('^"|"$', "", x, perl = TRUE, useBytes = TRUE)
  x <- trimws(gsub("[^0-9:. -]", "", x, perl = TRUE, useBytes = TRUE))
  out <- x
  is_24h <- grepl("^\\d{4}-\\d{2}-\\d{2} 24:", out)
  if (any(is_24h)) {
    date_part <- as.Date(substr(out[is_24h], 1, 10))
    time_part <- sub("^24:", "00:", substr(out[is_24h], 12, nchar(out[is_24h])))
    out[is_24h] <- paste(date_part + 1, time_part)
  }
  ymd_hms(out, tz = tz_local, quiet = TRUE)
}

extract_file_dt <- function(path) {
  name <- basename(path)
  m <- regexec("(20\\d{2})_(\\d{2})_(\\d{2})(?:_(\\d{2})(\\d{2}))?", name)
  hits <- regmatches(name, m)[[1]]
  if (length(hits) == 0) return(as.POSIXct(NA_real_, origin = "1970-01-01", tz = tz_local))
  hh <- if (length(hits) >= 5 && nzchar(hits[5])) hits[5] else "00"
  mm <- if (length(hits) >= 6 && nzchar(hits[6])) hits[6] else "00"
  as.POSIXct(
    sprintf("%s-%s-%s %s:%s:00", hits[2], hits[3], hits[4], hh, mm),
    tz = tz_local
  )
}

calc_mt_delta_c <- function(dt, heights_m) {
  c_fun <- function(z, x, y) {
    if (z <= x[1]) {
      return(y[1] + (z - x[1]) * (y[2] - y[1]) / (x[2] - x[1]))
    }
    if (z >= x[length(x)]) {
      n <- length(x)
      return(y[n] + (z - x[n]) * (y[n] - y[n - 1]) / (x[n] - x[n - 1]))
    }
    approx(x, y, xout = z)$y
  }

  zr <- 30
  lower <- heights_m[1]
  value_cols <- names(heights_m)

  lee_conc <- t(apply(
    dt[, ..value_cols],
    1,
    function(y) {
      y <- as.numeric(y)
      x_use <- c(lower, heights_m[heights_m > lower & heights_m < zr], zr)
      y_use <- sapply(x_use, c_fun, x = heights_m, y = y)
      c_zr <- y_use[length(y_use)]
      c_ave <- sum(diff(x_use) * (head(y_use, -1) + tail(y_use, -1)) / 2) / (zr - lower)
      c(c_zr = c_zr, c_ave = c_ave, delta_c = c_zr - c_ave)
    }
  ))

  dt[, c("c_zr", "c_ave", "delta_c") := as.data.table(lee_conc)]
  dt
}

site_configs <- list(
  MT = list(
    site = "MT",
    file_pattern = "(SiteAvg|main_tower_co2_data).*\\.dat$",
    input_dirs = c(
      "E:/Dataset_Level0/MT/AP/20240704-20260131",
      "E:/Dataset_Level0/MT/AP/202601011920-202604141057",
      "E:/Dataset_Level0/MT/AP/202604221000-202605101700",
      "E:/Dataset_Level0/MT/AP/202605101700-202606221300"
    ),
    output_root = "E:/Dataset_Level1/MT/AP/20240704-20260622",
    keep_valves = 1:5,
    valve_map = c(`1` = "c8", `2` = "c13", `3` = "c17", `4` = "c20", `5` = "c29p5"),
    level_order = c("c8", "c13", "c17", "c20", "c29p5"),
    height_map = c(c8 = 8, c13 = 13, c17 = 17, c20 = 20, c29p5 = 29.5),
    start_valve = 1L,
    analysis_start = as.Date("2024-07-04"),
    analysis_end = as.Date("2026-06-22"),
    full_tag = "20240704_20260622",
    qc_cfg = list(
      raw = list(
        co2_range = c(250, 1000),
        step_warn = 20,
        step_fail = 40,
        rate_warn = 15,
        rate_fail = 30,
        persist_n = 8L,
        persist_sd_suspect = 0.05,
        persist_sd_warning = 0.02,
        persist_rng_suspect = 0.15,
        persist_rng_warning = 0.08
      ),
      cycle = list(
        min_obs_per_level = 3L,
        spread_warn = 15,
        spread_fail = 30,
        adj_warn = 10,
        adj_fail = 20
      )
    )
  ),
  CVT = list(
    site = "CVT",
    file_pattern = "SiteAvg.*\\.dat$",
    input_dirs = c(
      "E:/Dataset_Level0/CVT/AP/202411121700-202602020930",
      "E:/Dataset_Level0/CVT/AP/202602020930-202605101500",
      "E:/Dataset_Level0/CVT/AP/202605101500-202606221600"
    ),
    output_root = "E:/Dataset_Level1/CVT/AP/20240704-20260622",
    keep_valves = 6:8,
    valve_map = c(`6` = "c24", `7` = "c32", `8` = "c43"),
    level_order = c("c24", "c32", "c43"),
    height_map = c(c24 = 24, c32 = 32, c43 = 43),
    start_valve = 6L,
    analysis_start = as.Date("2024-11-12"),
    analysis_end = as.Date("2026-06-22"),
    full_tag = "20241112_20260622",
    qc_cfg = list(
      raw = list(
        co2_range = c(250, 1000),
        step_warn = 20,
        step_fail = 40,
        rate_warn = 15,
        rate_fail = 30,
        persist_n = 8L,
        persist_sd_suspect = 0.05,
        persist_sd_warning = 0.02,
        persist_rng_suspect = 0.15,
        persist_rng_warning = 0.08
      ),
      cycle = list(
        min_obs_per_level = 1L,
        spread_warn = 15,
        spread_fail = 30,
        adj_warn = 10,
        adj_fail = 20
      )
    )
  )
)

build_file_table <- function(cfg) {
  rows <- lapply(cfg$input_dirs, function(dir_path) {
    files <- list.files(dir_path, pattern = cfg$file_pattern, full.names = TRUE)
    if (length(files) == 0) return(NULL)
    data.table(
      source_path = files,
      source_dir = dir_path,
      source_file = basename(files),
      file_ts = as.POSIXct(
        vapply(files, function(p) as.numeric(extract_file_dt(p)), numeric(1)),
        origin = "1970-01-01",
        tz = tz_local
      )
    )
  })
  file_dt <- safe_rbind(rows)
  if (nrow(file_dt) == 0) {
    stop(sprintf("%s: no input files matched %s", cfg$site, cfg$file_pattern))
  }
  setorder(file_dt, file_ts, source_file)
  file_dt[, source_date := as.Date(file_ts, tz = tz_local)]
  file_dt[, file_index_global := .I]
  file_dt
}

read_one_file <- function(cfg, f, header, file_index) {
  dt <- fread(
    f,
    sep = ",",
    header = FALSE,
    skip = 4,
    col.names = header,
    colClasses = list(character = 1L),
    na.strings = c("NAN", "NA", ""),
    fill = TRUE,
    blank.lines.skip = TRUE,
    showProgress = FALSE
  )

  if (nrow(dt) == 0) {
    dt <- data.table(TIMESTAMP = character(), valve_number = integer(), CO2_Avg = numeric())
  }

  stopifnot(all(c("TIMESTAMP", "valve_number", "CO2_Avg") %in% names(dt)))

  dt[, source_file := basename(f)]
  dt[, source_path := f]
  dt[, file_index := file_index]

  dt[, TIMESTAMP := normalize_timestamp_ap(TIMESTAMP)]
  dt[, valve_number := suppressWarnings(as.integer(valve_number))]
  dt[, CO2_Avg := suppressWarnings(as.numeric(CO2_Avg))]

  if (cfg$site == "CVT") {
    bad_cut <- as.POSIXct("2025-03-23 17:53:30", tz = tz_local)
    dt[
      !is.na(TIMESTAMP) &
        as.Date(TIMESTAMP, tz = tz_local) == as.Date(bad_cut, tz = tz_local) &
        TIMESTAMP > bad_cut &
        valve_number == 7L,
      CO2_Avg := NA_real_
    ]
  }

  dt
}

qc_raw_profile <- function(dt, keep_valves, qc_cfg_raw) {
  dt <- copy(dt)

  if (nrow(dt) == 0) {
    dt[, `:=`(
      qc_missing = integer(),
      qc_valve = integer(),
      qc_dup = integer(),
      qc_range = integer(),
      qc_step = integer(),
      qc_persist = integer(),
      qc_gap = integer(),
      qc_hits_raw = integer(),
      qc_flag_raw = integer(),
      qc_keep_raw = logical()
    )]
    return(dt)
  }

  dt[, qc_missing := fifelse(
    is.na(TIMESTAMP) | is.na(valve_number) | is.na(CO2_Avg), 3L, 0L
  )]

  dt[, qc_valve := fifelse(
    !is.na(valve_number) & !(valve_number %in% keep_valves), 3L, 0L
  )]

  dt[, dup_n := .N, by = .(TIMESTAMP, valve_number)]
  dt[, qc_dup := fifelse(!is.na(TIMESTAMP) & !is.na(valve_number) & dup_n > 1, 2L, 0L)]

  dt[, qc_range := fifelse(
    !is.na(CO2_Avg) &
      (CO2_Avg < qc_cfg_raw$co2_range[1] | CO2_Avg > qc_cfg_raw$co2_range[2]),
    3L, 0L
  )]

  setorder(dt, valve_number, TIMESTAMP)
  dt[, dt_min := as.numeric(difftime(TIMESTAMP, shift(TIMESTAMP), units = "mins")), by = valve_number]
  dt[, dco2 := abs(CO2_Avg - shift(CO2_Avg)), by = valve_number]
  dt[, step_rate := fifelse(!is.na(dt_min) & dt_min > 0, dco2 / dt_min, NA_real_)]

  dt[, qc_step := fifelse(
    (!is.na(dco2) & dco2 > qc_cfg_raw$step_fail) |
      (!is.na(step_rate) & step_rate > qc_cfg_raw$rate_fail),
    2L,
    fifelse(
      (!is.na(dco2) & dco2 > qc_cfg_raw$step_warn) |
        (!is.na(step_rate) & step_rate > qc_cfg_raw$rate_warn),
      1L,
      0L
    )
  )]

  dt[, roll_sd := frollapply(
    CO2_Avg,
    n = qc_cfg_raw$persist_n,
    FUN = function(x) {
      if (all(is.na(x))) return(NA_real_)
      sd(x, na.rm = TRUE)
    },
    align = "right"
  ), by = valve_number]

  dt[, roll_rng := frollapply(
    CO2_Avg,
    n = qc_cfg_raw$persist_n,
    FUN = function(x) {
      if (all(is.na(x))) return(NA_real_)
      diff(range(x, na.rm = TRUE))
    },
    align = "right"
  ), by = valve_number]

  dt[, qc_persist := fifelse(
    !is.na(roll_sd) & !is.na(roll_rng) &
      roll_sd <= qc_cfg_raw$persist_sd_warning &
      roll_rng <= qc_cfg_raw$persist_rng_warning,
    2L,
    fifelse(
      !is.na(roll_sd) & !is.na(roll_rng) &
        roll_sd <= qc_cfg_raw$persist_sd_suspect &
        roll_rng <= qc_cfg_raw$persist_rng_suspect,
      1L,
      0L
    )
  )]

  dt[, med_gap_min := {
    x <- dt_min[is.finite(dt_min) & dt_min > 0]
    if (length(x) == 0) NA_real_ else median(x, na.rm = TRUE)
  }, by = valve_number]

  dt[, qc_gap := fifelse(
    !is.na(dt_min) & !is.na(med_gap_min) & dt_min > 3 * med_gap_min,
    1L,
    0L
  )]

  raw_flag_cols <- c("qc_missing", "qc_valve", "qc_dup", "qc_range", "qc_step", "qc_persist", "qc_gap")
  dt[, qc_hits_raw := rowSums(.SD > 0, na.rm = TRUE), .SDcols = raw_flag_cols]
  dt[, qc_flag_raw := pmax(
    qc_missing, qc_valve, qc_dup,
    qc_range, qc_step, qc_persist, qc_gap,
    na.rm = TRUE
  )]

  dt[qc_hits_raw >= 2 & qc_flag_raw > 0 & qc_flag_raw < 3L, qc_flag_raw := qc_flag_raw + 1L]
  dt[, qc_keep_raw := qc_flag_raw < 3L & valve_number %in% keep_valves]

  setorder(dt, TIMESTAMP)
  dt[]
}

summarise_raw_file_qc <- function(dt, f, file_index) {
  tr <- safe_time_range(dt$TIMESTAMP)
  data.table(
    file_index = file_index,
    source_file = basename(f),
    n_total = nrow(dt),
    n_keep_raw = sum(dt$qc_keep_raw, na.rm = TRUE),
    n_flag0_good = sum(dt$qc_flag_raw == 0L, na.rm = TRUE),
    n_flag1_suspect = sum(dt$qc_flag_raw == 1L, na.rm = TRUE),
    n_flag2_warning = sum(dt$qc_flag_raw == 2L, na.rm = TRUE),
    n_flag3_failure = sum(dt$qc_flag_raw == 3L, na.rm = TRUE),
    n_qc_missing = sum(dt$qc_missing > 0, na.rm = TRUE),
    n_qc_valve = sum(dt$qc_valve > 0, na.rm = TRUE),
    n_qc_dup = sum(dt$qc_dup > 0, na.rm = TRUE),
    n_qc_range = sum(dt$qc_range > 0, na.rm = TRUE),
    n_qc_step = sum(dt$qc_step > 0, na.rm = TRUE),
    n_qc_persist = sum(dt$qc_persist > 0, na.rm = TRUE),
    n_qc_gap = sum(dt$qc_gap > 0, na.rm = TRUE),
    time_start = tr$start,
    time_end = tr$end
  )
}

extract_complete_cycles <- function(dt_all, start_valve) {
  if (nrow(dt_all) == 0) {
    return(list(done = data.table(), buffer = data.table()))
  }

  setorder(dt_all, TIMESTAMP)
  start_idx <- which(dt_all$valve_number == start_valve)
  if (length(start_idx) == 0) {
    return(list(done = data.table(), buffer = dt_all))
  }

  dt_all <- dt_all[start_idx[1]:.N]
  start_idx <- which(dt_all$valve_number == start_valve)
  if (length(start_idx) < 2) {
    return(list(done = data.table(), buffer = dt_all))
  }

  last_start <- tail(start_idx, 1)
  list(
    done = dt_all[1:(last_start - 1)],
    buffer = dt_all[last_start:.N]
  )
}

build_cycle_summary <- function(dt_done, cfg, cycle_offset) {
  if (nrow(dt_done) == 0) {
    return(list(cycle_dt = data.table(), cycle_offset = cycle_offset))
  }

  dt <- copy(dt_done)
  dt[, level := cfg$valve_map[as.character(valve_number)]]
  dt <- dt[!is.na(level)]
  if (nrow(dt) == 0) {
    return(list(cycle_dt = data.table(), cycle_offset = cycle_offset))
  }

  setorder(dt, TIMESTAMP)
  dt[, cycle_id := cycle_offset + cumsum(valve_number == cfg$start_valve)]

  prof_time <- dt[, .(
    cycle_time = min(TIMESTAMP) + (max(TIMESTAMP) - min(TIMESTAMP)) / 2,
    cycle_span_sec = as.numeric(difftime(max(TIMESTAMP), min(TIMESTAMP), units = "secs")),
    cycle_n_raw = .N,
    cycle_file_start = first(source_file),
    cycle_file_end = last(source_file)
  ), by = cycle_id]

  prof_level <- dt[, .(
    CO2_Avg = mean(CO2_Avg, na.rm = TRUE),
    n_obs = .N,
    raw_flag_max = max(qc_flag_raw, na.rm = TRUE)
  ), by = .(cycle_id, level)]

  prof_value <- dcast(prof_level, cycle_id ~ level, value.var = "CO2_Avg")
  prof_n <- dcast(prof_level, cycle_id ~ level, value.var = "n_obs")
  setnames(prof_n, old = intersect(cfg$level_order, names(prof_n)), new = paste0(intersect(cfg$level_order, names(prof_n)), "_n"))
  prof_rawflag <- dcast(prof_level, cycle_id ~ level, value.var = "raw_flag_max")
  setnames(prof_rawflag, old = intersect(cfg$level_order, names(prof_rawflag)), new = paste0(intersect(cfg$level_order, names(prof_rawflag)), "_rawflag"))

  prof_cycle <- merge(prof_time, prof_value, by = "cycle_id", all = TRUE)
  prof_cycle <- merge(prof_cycle, prof_n, by = "cycle_id", all = TRUE)
  prof_cycle <- merge(prof_cycle, prof_rawflag, by = "cycle_id", all = TRUE)

  for (nm in cfg$level_order) {
    if (!nm %in% names(prof_cycle)) prof_cycle[, (nm) := NA_real_]
    if (!paste0(nm, "_n") %in% names(prof_cycle)) prof_cycle[, (paste0(nm, "_n")) := NA_real_]
    if (!paste0(nm, "_rawflag") %in% names(prof_cycle)) prof_cycle[, (paste0(nm, "_rawflag")) := NA_real_]
  }

  prof_cycle[, qc_cycle_complete := fifelse(!complete.cases(.SD), 3L, 0L), .SDcols = cfg$level_order]
  n_cols <- paste0(cfg$level_order, "_n")
  prof_cycle[, min_level_n := apply(.SD, 1, function(x) {
    x <- as.numeric(x)
    if (all(is.na(x))) return(NA_real_)
    min(x, na.rm = TRUE)
  }), .SDcols = n_cols]

  prof_cycle[, profile_spread := apply(.SD, 1, function(x) {
    x <- as.numeric(x)
    if (anyNA(x)) return(NA_real_)
    max(x) - min(x)
  }), .SDcols = cfg$level_order]

  prof_cycle[, max_adj_diff := apply(.SD, 1, function(x) {
    x <- as.numeric(x)
    if (anyNA(x)) return(NA_real_)
    max(abs(diff(x)))
  }), .SDcols = cfg$level_order]

  rawflag_cols <- paste0(cfg$level_order, "_rawflag")
  prof_cycle[, raw_flag_cycle_max := apply(.SD, 1, function(x) {
    x <- as.numeric(x)
    if (all(is.na(x))) return(NA_real_)
    max(x, na.rm = TRUE)
  }), .SDcols = rawflag_cols]

  prof_cycle[, qc_level_n := fifelse(
    !is.na(min_level_n) & min_level_n < cfg$qc_cfg$cycle$min_obs_per_level,
    2L,
    0L
  )]

  prof_cycle[, qc_profile_spread := fifelse(
    !is.na(profile_spread) & profile_spread > cfg$qc_cfg$cycle$spread_fail,
    2L,
    fifelse(
      !is.na(profile_spread) & profile_spread > cfg$qc_cfg$cycle$spread_warn,
      1L,
      0L
    )
  )]

  prof_cycle[, qc_adjacent := fifelse(
    !is.na(max_adj_diff) & max_adj_diff > cfg$qc_cfg$cycle$adj_fail,
    2L,
    fifelse(
      !is.na(max_adj_diff) & max_adj_diff > cfg$qc_cfg$cycle$adj_warn,
      1L,
      0L
    )
  )]

  prof_cycle[, qc_raw_inherited := fifelse(
    !is.na(raw_flag_cycle_max) & raw_flag_cycle_max >= 2L,
    1L,
    fifelse(!is.na(raw_flag_cycle_max) & raw_flag_cycle_max == 1L, 1L, 0L)
  )]

  cycle_flag_cols <- c("qc_cycle_complete", "qc_level_n", "qc_profile_spread", "qc_adjacent", "qc_raw_inherited")
  prof_cycle[, qc_hits_cycle := rowSums(.SD > 0, na.rm = TRUE), .SDcols = cycle_flag_cols]
  prof_cycle[, qc_flag_cycle := pmax(
    qc_cycle_complete, qc_level_n, qc_profile_spread, qc_adjacent, qc_raw_inherited,
    na.rm = TRUE
  )]
  prof_cycle[qc_hits_cycle >= 2 & qc_flag_cycle > 0 & qc_flag_cycle < 3L, qc_flag_cycle := qc_flag_cycle + 1L]
  prof_cycle[, qc_keep_cycle := qc_flag_cycle < 3L]

  setorder(prof_cycle, cycle_time)
  list(cycle_dt = prof_cycle, cycle_offset = max(dt$cycle_id))
}

order_cycle_cols <- function(dt, cfg) {
  cols <- c(
    "cycle_id", "cycle_time", "cycle_span_sec", "cycle_n_raw",
    "cycle_file_start", "cycle_file_end",
    cfg$level_order,
    paste0(cfg$level_order, "_n"),
    "profile_spread", "max_adj_diff", "raw_flag_cycle_max",
    "qc_cycle_complete", "qc_level_n", "qc_profile_spread",
    "qc_adjacent", "qc_raw_inherited", "qc_hits_cycle",
    "qc_flag_cycle", "qc_keep_cycle"
  )
  cols <- cols[cols %in% names(dt)]
  if (length(cols) > 0) {
    setcolorder(dt, c(cols, setdiff(names(dt), cols)))
  }
  dt
}

summarise_day_qc <- function(cycle_dt, level_order, start_date, end_date) {
  if (nrow(cycle_dt) == 0) {
    all_dates <- data.table(date = seq(as.Date(start_date), as.Date(end_date), by = "day"))
    return(list(day_summary = data.table(), missing_dates = all_dates))
  }

  dt <- copy(cycle_dt)
  dt[, date := as.Date(cycle_time, tz = tz_local)]

  day_base <- dt[, .(
    n_cycle = .N,
    n_keep_cycle = sum(qc_keep_cycle, na.rm = TRUE),
    n_flag0_good = sum(qc_flag_cycle == 0L, na.rm = TRUE),
    n_flag1_suspect = sum(qc_flag_cycle == 1L, na.rm = TRUE),
    n_flag2_warning = sum(qc_flag_cycle == 2L, na.rm = TRUE),
    n_flag3_failure = sum(qc_flag_cycle == 3L, na.rm = TRUE),
    qc_cycle_ratio = round(sum(qc_flag_cycle > 0, na.rm = TRUE) / .N, 4),
    qc_failure_ratio = round(sum(qc_flag_cycle == 3L, na.rm = TRUE) / .N, 4),
    time_start = fmt_time(min(cycle_time)),
    time_end = fmt_time(max(cycle_time)),
    cover_hours = round(as.numeric(difftime(max(cycle_time), min(cycle_time), units = "hours")), 2),
    profile_spread_mean = round(mean(profile_spread, na.rm = TRUE), 3),
    profile_spread_p95 = round(as.numeric(quantile(profile_spread, 0.95, na.rm = TRUE)), 3),
    profile_spread_max = round(max(profile_spread, na.rm = TRUE), 3),
    max_adj_diff_mean = round(mean(max_adj_diff, na.rm = TRUE), 3),
    max_adj_diff_p95 = round(as.numeric(quantile(max_adj_diff, 0.95, na.rm = TRUE)), 3),
    max_adj_diff_max = round(max(max_adj_diff, na.rm = TRUE), 3)
  ), by = date]

  day_means <- dt[, lapply(.SD, function(x) round(mean(x, na.rm = TRUE), 3)), by = date, .SDcols = level_order]
  setnames(day_means, old = level_order, new = paste0(level_order, "_mean"))

  day_summary <- merge(day_base, day_means, by = "date", all = TRUE)
  day_summary[, top_bottom_diff := round(
    get(paste0(level_order[1], "_mean")) - get(paste0(level_order[length(level_order)], "_mean")),
    3
  )]
  setorder(day_summary, date)

  all_dates <- data.table(date = seq(as.Date(start_date), as.Date(end_date), by = "day"))
  missing_dates <- all_dates[!day_summary, on = "date"]
  list(day_summary = day_summary, missing_dates = missing_dates)
}

prepare_after_qc <- function(cycle_dt, cfg) {
  if (nrow(cycle_dt) == 0) return(data.table())
  dt <- copy(cycle_dt[qc_keep_cycle == TRUE])
  dt <- dt[dt[, complete.cases(.SD), .SDcols = cfg$level_order]]
  if (nrow(dt) == 0) return(dt)
  if (cfg$site == "MT") {
    dt <- calc_mt_delta_c(dt, cfg$height_map)
  }
  dt
}

calc_overall_qc <- function(raw_file_qc, cycle_qc, day_qc, bad_files) {
  data.table(
    n_files = nrow(raw_file_qc),
    n_bad_files = nrow(bad_files),
    n_raw_file_summary = nrow(raw_file_qc),
    n_cycles_total = nrow(cycle_qc),
    n_cycles_keep = sum(cycle_qc$qc_keep_cycle, na.rm = TRUE),
    n_cycles_flagged = sum(cycle_qc$qc_flag_cycle > 0, na.rm = TRUE),
    cycle_flag_ratio = if (nrow(cycle_qc) > 0) round(mean(cycle_qc$qc_flag_cycle > 0, na.rm = TRUE), 4) else NA_real_,
    cycle_failure_ratio = if (nrow(cycle_qc) > 0) round(mean(cycle_qc$qc_flag_cycle == 3L, na.rm = TRUE), 4) else NA_real_,
    n_days_with_cycles = nrow(day_qc),
    n_missing_dates = NA_integer_,
    mean_daily_qc_ratio = if (nrow(day_qc) > 0) round(mean(day_qc$qc_cycle_ratio, na.rm = TRUE), 4) else NA_real_,
    mean_cover_hours = if (nrow(day_qc) > 0) round(mean(day_qc$cover_hours, na.rm = TRUE), 2) else NA_real_
  )
}

run_month <- function(cfg, files_dt, month_start, overwrite = FALSE) {
  month_start <- as.Date(month_start, origin = "1970-01-01")
  next_month_start <- seq.Date(month_start, by = "month", length.out = 2)[2]
  month_end <- next_month_start - 1
  month_tag <- format(month_start, "%Y-%m")
  month_dir <- file.path(cfg$output_root, "monthly", month_tag)
  dir.create(month_dir, recursive = TRUE, showWarnings = FALSE)

  cycle_path <- file.path(month_dir, sprintf("%s_AP_profile_cycle_qc_summary_%s.csv", cfg$site, month_tag))
  if (file.exists(cycle_path) && !overwrite) {
    cat(sprintf("[%s] skip %s (already exists)\n", cfg$site, month_tag))
    return(invisible(NULL))
  }

  target_idx <- which(files_dt$source_date >= month_start & files_dt$source_date <= month_end)
  if (length(target_idx) == 0) {
    cat(sprintf("[%s] skip %s (no files)\n", cfg$site, month_tag))
    return(invisible(NULL))
  }

  support_idx <- sort(unique(c(
    if (min(target_idx) > 1) min(target_idx) - 1 else integer(),
    target_idx,
    if (max(target_idx) < nrow(files_dt)) max(target_idx) + 1 else integer()
  )))
  month_files <- files_dt[support_idx]
  month_files[, is_target_file := file_index_global %in% files_dt$file_index_global[target_idx]]

  header <- names(fread(month_files$source_path[1], sep = ",", header = TRUE, skip = 1, nrows = 1, fill = TRUE, showProgress = FALSE))
  stopifnot(all(c("TIMESTAMP", "valve_number", "CO2_Avg") %in% header))

  raw_file_qc_list <- list()
  cycle_qc_list <- list()
  bad_files <- list()
  buffer_dt <- data.table()
  cycle_offset <- 0L

  for (i in seq_len(nrow(month_files))) {
    file_path <- month_files$source_path[i]
    dt_now <- tryCatch(
      read_one_file(cfg, file_path, header, i),
      error = function(e) {
        bad_files[[length(bad_files) + 1]] <<- data.table(
          file_index = i,
          source_file = basename(file_path),
          source_path = file_path,
          error_message = conditionMessage(e)
        )
        NULL
      }
    )

    if (is.null(dt_now)) next

    dt_now <- qc_raw_profile(dt_now, cfg$keep_valves, cfg$qc_cfg$raw)
    raw_file_qc_list[[length(raw_file_qc_list) + 1]] <- summarise_raw_file_qc(dt_now, file_path, i)

    dt_keep <- dt_now[qc_keep_raw == TRUE & valve_number %in% cfg$keep_valves]
    dt_all <- rbindlist(list(buffer_dt, dt_keep), use.names = TRUE, fill = TRUE)
    if (nrow(dt_all) == 0) {
      buffer_dt <- data.table()
      next
    }

    cycle_cut <- extract_complete_cycles(dt_all, cfg$start_valve)
    dt_done <- cycle_cut$done
    buffer_dt <- cycle_cut$buffer
    if (nrow(dt_done) == 0) next

    cycle_res <- build_cycle_summary(dt_done, cfg, cycle_offset)
    if (nrow(cycle_res$cycle_dt) > 0) {
      cycle_qc_list[[length(cycle_qc_list) + 1]] <- cycle_res$cycle_dt
      cycle_offset <- cycle_res$cycle_offset
    }
  }

  raw_file_qc <- safe_rbind(raw_file_qc_list)
  if (nrow(raw_file_qc) > 0) {
    raw_file_qc[, source_path := month_files$source_path[file_index]]
    raw_file_qc[, is_target_file := source_path %in% month_files[is_target_file == TRUE, source_path]]
    raw_file_qc <- raw_file_qc[is_target_file == TRUE]
    raw_file_qc[, is_target_file := NULL]
  }

  cycle_qc <- safe_rbind(cycle_qc_list)
  if (nrow(cycle_qc) > 0) {
    cycle_qc <- cycle_qc[
      as.Date(cycle_time, tz = tz_local) >= month_start &
        as.Date(cycle_time, tz = tz_local) <= month_end
    ]
    cycle_qc <- order_cycle_cols(cycle_qc, cfg)
  }

  bad_files_dt <- safe_rbind(bad_files)
  if (ncol(bad_files_dt) == 0) {
    bad_files_dt <- empty_bad_files_table()
  }
  if (nrow(bad_files_dt) > 0) {
    bad_files_dt[, is_target_file := source_path %in% month_files[is_target_file == TRUE, source_path]]
    bad_files_dt <- bad_files_dt[is_target_file == TRUE]
    bad_files_dt[, is_target_file := NULL]
  }

  day_res <- summarise_day_qc(cycle_qc, cfg$level_order, month_start, month_end)
  day_qc <- day_res$day_summary
  missing_dates <- day_res$missing_dates
  overall_qc <- calc_overall_qc(raw_file_qc, cycle_qc, day_qc, bad_files_dt)
  overall_qc[, n_missing_dates := nrow(missing_dates)]
  after_qc <- prepare_after_qc(cycle_qc, cfg)

  cycle_qc_out <- copy(cycle_qc)
  if (nrow(cycle_qc_out) > 0) cycle_qc_out[, cycle_time := fmt_time(cycle_time)]
  after_qc_out <- copy(after_qc)
  if (nrow(after_qc_out) > 0) after_qc_out[, cycle_time := fmt_time(cycle_time)]

  fwrite(raw_file_qc, file.path(month_dir, sprintf("%s_AP_raw_file_qc_summary_%s.csv", cfg$site, month_tag)))
  fwrite(cycle_qc_out, cycle_path)
  fwrite(after_qc_out, file.path(month_dir, sprintf("%s_AP_profile_cycle_after_qc_%s.csv", cfg$site, month_tag)))
  fwrite(day_qc, file.path(month_dir, sprintf("%s_AP_profile_day_qc_summary_%s.csv", cfg$site, month_tag)))
  fwrite(missing_dates, file.path(month_dir, sprintf("%s_AP_profile_missing_dates_%s.csv", cfg$site, month_tag)))
  fwrite(overall_qc, file.path(month_dir, sprintf("%s_AP_profile_overall_qc_summary_%s.csv", cfg$site, month_tag)))
  fwrite(bad_files_dt, file.path(month_dir, sprintf("%s_AP_bad_files_%s.csv", cfg$site, month_tag)))

  month_summary <- data.table(
    month = month_tag,
    month_start = as.character(month_start),
    month_end = as.character(month_end),
    n_target_files = length(target_idx),
    n_support_files = nrow(month_files),
    first_target_file = month_files[is_target_file == TRUE, source_file][1],
    last_target_file = tail(month_files[is_target_file == TRUE, source_file], 1),
    prev_support_file = if (min(target_idx) > 1) month_files[1, source_file] else NA_character_,
    next_support_file = if (max(target_idx) < nrow(files_dt)) month_files[.N, source_file] else NA_character_,
    n_cycles_total = nrow(cycle_qc),
    n_cycles_keep = sum(cycle_qc$qc_keep_cycle, na.rm = TRUE)
  )
  fwrite(month_summary, file.path(month_dir, sprintf("%s_AP_month_run_summary_%s.csv", cfg$site, month_tag)))
  cat(sprintf("[%s] done %s: files=%d cycles=%d keep=%d\n", cfg$site, month_tag, length(target_idx), nrow(cycle_qc), sum(cycle_qc$qc_keep_cycle, na.rm = TRUE)))
}

combine_months <- function(cfg) {
  monthly_root <- file.path(cfg$output_root, "monthly")
  month_dirs <- sort(list.dirs(monthly_root, recursive = FALSE, full.names = TRUE))
  if (length(month_dirs) == 0) {
    stop(sprintf("%s: no monthly outputs found under %s", cfg$site, monthly_root))
  }

  read_many <- function(pattern) {
    files <- unlist(lapply(month_dirs, function(d) Sys.glob(file.path(d, pattern))))
    if (length(files) == 0) return(data.table())
    rbindlist(lapply(files, fread), use.names = TRUE, fill = TRUE)
  }

  raw_file_qc <- read_many(sprintf("%s_AP_raw_file_qc_summary_*.csv", cfg$site))
  cycle_qc <- read_many(sprintf("%s_AP_profile_cycle_qc_summary_*.csv", cfg$site))
  bad_files <- read_many(sprintf("%s_AP_bad_files_*.csv", cfg$site))
  month_summary <- read_many(sprintf("%s_AP_month_run_summary_*.csv", cfg$site))

  if (nrow(cycle_qc) > 0) {
    cycle_qc[, cycle_time := normalize_timestamp_ap(cycle_time)]
    setorder(cycle_qc, cycle_time, cycle_file_start, cycle_file_end)
    cycle_qc[, cycle_id := .I]
    cycle_qc <- order_cycle_cols(cycle_qc, cfg)
  }

  day_res <- summarise_day_qc(cycle_qc, cfg$level_order, cfg$analysis_start, cfg$analysis_end)
  day_qc <- day_res$day_summary
  missing_dates <- day_res$missing_dates
  overall_qc <- calc_overall_qc(raw_file_qc, cycle_qc, day_qc, bad_files)
  overall_qc[, n_missing_dates := nrow(missing_dates)]
  after_qc <- prepare_after_qc(cycle_qc, cfg)

  cycle_qc_out <- copy(cycle_qc)
  if (nrow(cycle_qc_out) > 0) cycle_qc_out[, cycle_time := fmt_time(cycle_time)]
  after_qc_out <- copy(after_qc)
  if (nrow(after_qc_out) > 0) after_qc_out[, cycle_time := fmt_time(cycle_time)]

  fwrite(raw_file_qc, file.path(cfg$output_root, sprintf("%s_AP_raw_file_qc_summary_%s.csv", cfg$site, cfg$full_tag)))
  fwrite(cycle_qc_out, file.path(cfg$output_root, sprintf("%s_AP_profile_cycle_qc_summary_%s.csv", cfg$site, cfg$full_tag)))
  fwrite(after_qc_out, file.path(cfg$output_root, sprintf("%s_AP_profile_cycle_after_qc_%s.csv", cfg$site, cfg$full_tag)))
  fwrite(day_qc, file.path(cfg$output_root, sprintf("%s_AP_profile_day_qc_summary_%s.csv", cfg$site, cfg$full_tag)))
  fwrite(missing_dates, file.path(cfg$output_root, sprintf("%s_AP_profile_missing_dates_%s.csv", cfg$site, cfg$full_tag)))
  fwrite(overall_qc, file.path(cfg$output_root, sprintf("%s_AP_profile_overall_qc_summary_%s.csv", cfg$site, cfg$full_tag)))
  fwrite(bad_files, file.path(cfg$output_root, sprintf("%s_AP_bad_files_%s.csv", cfg$site, cfg$full_tag)))
  fwrite(month_summary, file.path(cfg$output_root, sprintf("%s_AP_month_run_summary_%s.csv", cfg$site, cfg$full_tag)))
}

run_site <- function(cfg, month = NULL, overwrite = FALSE) {
  dir.create(cfg$output_root, recursive = TRUE, showWarnings = FALSE)
  files_dt <- build_file_table(cfg)

  month_seq <- seq.Date(
    as.Date(format(cfg$analysis_start, "%Y-%m-01")),
    as.Date(format(cfg$analysis_end, "%Y-%m-01")),
    by = "month"
  )
  if (!is.null(month) && nzchar(month)) {
    month_seq <- as.Date(paste0(month, "-01"))
  }

  for (month_start in month_seq) {
    run_month(cfg, files_dt, month_start, overwrite = overwrite)
  }

  if (is.null(month) || !nzchar(month)) {
    combine_months(cfg)
  }
}

main <- function() {
  args <- parse_args()
  requested_site <- toupper(args$site %||% "ALL")
  month <- args$month %||% NULL
  overwrite <- as_flag(args$overwrite, default = FALSE)

  sites <- if (requested_site == "ALL") names(site_configs) else requested_site
  for (site_name in sites) {
    stopifnot(site_name %in% names(site_configs))
    run_site(site_configs[[site_name]], month = month, overwrite = overwrite)
  }
}

main()
