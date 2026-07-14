#!/usr/bin/env Rscript

suppressPackageStartupMessages(library(data.table))

defaults <- list(
  level0_root = "E:/Dataset_Level0",
  level1_root = "E:/Dataset_Level1",
  timezone = "Asia/Shanghai",
  max_interp_gap_windows = 4L
)

parse_args <- function(args) {
  opts <- defaults
  for (arg in args) {
    if (grepl("^--level0-root=", arg)) opts$level0_root <- sub("^--level0-root=", "", arg)
    else if (grepl("^--level1-root=", arg)) opts$level1_root <- sub("^--level1-root=", "", arg)
    else if (grepl("^--max-interp-gap-windows=", arg)) opts$max_interp_gap_windows <- as.integer(sub("^--max-interp-gap-windows=", "", arg))
    else if (arg == "--self-test") opts$self_test <- TRUE
    else stop("Unknown argument: ", arg, call. = FALSE)
  }
  opts
}

as_num <- function(x) suppressWarnings(as.numeric(x))
parse_time <- function(x, tz) as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = tz)
floor_30min <- function(x, tz) as.POSIXct(floor(as.numeric(x) / 1800) * 1800, origin = "1970-01-01", tz = tz)

field_candidates <- list(
  MT = list(
    rn = c("Rn_Avg", "Rn"), ta = c("TA_Avg(5)", "TA(5)", "TA_5"), rh = c("RH_Avg(5)", "RH(5)", "RH_5"),
    ws = c("WS_5_Avg", "WS_5"), wd = c("WD_5", "WD_5_Avg"), rain = c("rain_Tot")
  ),
  CVT = list(
    rn = c("Rn_Avg", "Rn"), ta = c("Ta_43m_Avg", "Ta_43m"), rh = c("RH_43m_Avg", "RH_43m"),
    ws = c("WS_43m_Avg", "WS_43m"), wd = c("WD_43m", "WD_43m_Avg")
  )
)

pick_field <- function(dt, candidates) {
  hit <- intersect(candidates, names(dt))
  if (length(hit)) hit[1] else NA_character_
}

read_toa5 <- function(path) {
  lines <- readLines(path, n = 2, warn = FALSE)
  if (length(lines) < 2 || !grepl("TIMESTAMP", lines[2], fixed = TRUE)) return(data.table())
  header <- as.character(fread(text = lines[2], header = FALSE))
  fread(path, skip = 4, header = FALSE, col.names = make.unique(header), colClasses = "character", fill = TRUE, showProgress = FALSE)
}

clean_continuous <- function(x, name) {
  x <- as_num(x)
  limits <- list(rn = c(-300, 1400), ta_ec = c(-50, 60), rh_ec = c(0, 100), ws_ec = c(0, 60), wd_ec = c(0, 360))
  lim <- limits[[name]]
  x[!is.finite(x) | x < lim[1] | x > lim[2]] <- NA_real_
  x
}

circ_mean <- function(deg) {
  deg <- deg[is.finite(deg)]
  if (!length(deg)) return(NA_real_)
  value <- atan2(mean(sin(deg * pi / 180)), mean(cos(deg * pi / 180))) * 180 / pi
  if (value < 0) value + 360 else value
}

vpd_from_ta_rh <- function(ta, rh) {
  es <- 0.6108 * exp(17.27 * ta / (ta + 237.3))
  pmax(0, es * (1 - rh / 100))
}

interpolate_short_gaps <- function(x, max_gap) {
  missing <- is.na(x)
  runs <- rle(missing)
  ends <- cumsum(runs$lengths)
  starts <- ends - runs$lengths + 1L
  for (i in which(runs$values & runs$lengths <= max_gap)) {
    left <- starts[i] - 1L; right <- ends[i] + 1L
    if (left >= 1L && right <= length(x) && is.finite(x[left]) && is.finite(x[right])) {
      x[starts[i]:ends[i]] <- seq(x[left], x[right], length.out = runs$lengths[i] + 2L)[-c(1L, runs$lengths[i] + 2L)]
    }
  }
  list(value = x, interpolated = missing & !is.na(x))
}

read_site <- function(site, opts) {
  files <- list.files(file.path(opts$level0_root, site, "MET"), pattern = "\\.dat$", full.names = TRUE, recursive = TRUE)
  cfg <- field_candidates[[site]]
  chunks <- vector("list", length(files)); maps <- vector("list", length(files))
  for (i in seq_along(files)) {
    if (i %% 50L == 0L || i == length(files)) message(site, ": reading ", i, "/", length(files), " files")
    dt <- tryCatch(read_toa5(files[i]), error = function(e) data.table())
    if (!("TIMESTAMP" %in% names(dt))) next
    fields <- vapply(cfg, pick_field, character(1), dt = dt)
    timestamp <- parse_time(dt$TIMESTAMP, opts$timezone)
    if (!any(!is.na(timestamp))) next
    maps[[i]] <- data.table(site = site, source_file = files[i], n_rows = nrow(dt), n_timestamp = sum(!is.na(timestamp)),
      rn_field = fields["rn"], ta_field = fields["ta"], rh_field = fields["rh"], ws_field = fields["ws"], wd_field = fields["wd"],
      rain_field = if ("rain" %in% names(fields)) fields["rain"] else NA_character_)
    get_value <- function(field) if (is.na(field)) rep(NA_real_, nrow(dt)) else as_num(dt[[field]])
    chunks[[i]] <- data.table(site = site, timestamp = timestamp, source_file = files[i],
      rn = clean_continuous(get_value(fields["rn"]), "rn"), ta_ec = clean_continuous(get_value(fields["ta"]), "ta_ec"),
      rh_ec = clean_continuous(get_value(fields["rh"]), "rh_ec"), ws_ec = clean_continuous(get_value(fields["ws"]), "ws_ec"),
      wd_ec = clean_continuous(get_value(fields["wd"]), "wd_ec"),
      rain_raw = if ("rain" %in% names(fields) && !is.na(fields["rain"])) as_num(dt[[fields["rain"]]]) else NA_real_)
  }
  raw <- rbindlist(chunks, fill = TRUE); mapping <- rbindlist(maps, fill = TRUE)
  raw <- raw[!is.na(timestamp)]
  raw[, completeness := rowSums(!is.na(.SD)), .SDcols = c("rn", "ta_ec", "rh_ec", "ws_ec", "wd_ec", "rain_raw")]
  setorder(raw, timestamp, -completeness, source_file)
  duplicate_timestamp_rows <- raw[, .N - 1L, by = timestamp][V1 > 0L, sum(V1)]
  raw <- raw[, .SD[1L], by = timestamp]
  raw[, window_start := floor_30min(timestamp, opts$timezone)]
  out <- raw[, .(
    rn = if (all(is.na(rn))) NA_real_ else mean(rn, na.rm = TRUE),
    ta_ec = if (all(is.na(ta_ec))) NA_real_ else mean(ta_ec, na.rm = TRUE),
    rh_ec = if (all(is.na(rh_ec))) NA_real_ else mean(rh_ec, na.rm = TRUE),
    ws_ec = if (all(is.na(ws_ec))) NA_real_ else mean(ws_ec, na.rm = TRUE),
    wd_ec = circ_mean(wd_ec),
    rain_observed = if (all(is.na(rain_raw))) NA else any(rain_raw > 0, na.rm = TRUE),
    n_records = .N
  ), by = window_start]
  list(data = out, mapping = mapping, duplicate_timestamp_rows = ifelse(is.na(duplicate_timestamp_rows), 0L, duplicate_timestamp_rows), n_files = length(files))
}

build_full_grid <- function(dt, opts) {
  grid <- data.table(window_start = seq(min(dt$window_start), max(dt$window_start), by = "30 min"))
  merge(grid, dt, by = "window_start", all.x = TRUE)
}

process_site <- function(site_result, site, opts, mt_rain = NULL) {
  dt <- build_full_grid(site_result$data, opts)
  continuous <- c("rn", "ta_ec", "rh_ec", "ws_ec", "wd_ec")
  for (col in continuous) {
    result <- interpolate_short_gaps(dt[[col]], opts$max_interp_gap_windows)
    dt[[paste0(col, "_interpolated")]] <- result$interpolated
    dt[[col]] <- result$value
  }
  dt[, vpd := vpd_from_ta_rh(ta_ec, rh_ec)]
  dt[is.na(ta_ec) | is.na(rh_ec), vpd := NA_real_]
  dt[, vpd_interpolated := !is.na(vpd) & (ta_ec_interpolated | rh_ec_interpolated)]
  if (site == "MT") {
    dt[, rain_flag := rain_observed]
  } else {
    rain_lookup <- mt_rain$rain_flag[match(dt$window_start, mt_rain$window_start)]
    dt[, rain_flag := rain_lookup]
  }
  dt[, `:=`(site = site, timestamp = format(window_start, "%Y-%m-%d %H:%M:%S", tz = opts$timezone),
    rn_interpolated = rn_interpolated, ta_ec_interpolated = ta_ec_interpolated, rh_ec_interpolated = rh_ec_interpolated,
    ws_ec_interpolated = ws_ec_interpolated, wd_ec_interpolated = wd_ec_interpolated)]
  setcolorder(dt, c("site", "timestamp", "window_start", "rn", "ta_ec", "rh_ec", "vpd", "ws_ec", "wd_ec", "rain_flag", "n_records",
    "rn_interpolated", "ta_ec_interpolated", "rh_ec_interpolated", "vpd_interpolated", "ws_ec_interpolated", "wd_ec_interpolated", "rain_observed"))
  dt
}

self_test <- function() {
  z <- interpolate_short_gaps(c(1, NA, NA, 4, NA, NA, NA, NA, NA, 10), 4L)
  stopifnot(identical(round(z$value[2:3], 6), c(2, 3)), all(is.na(z$value[5:9])), sum(z$interpolated) == 2L)
  stopifnot(abs(vpd_from_ta_rh(20, 50) - 1.169) < 0.01)
  message("Self-test passed")
}

main <- function() {
  opts <- parse_args(commandArgs(trailingOnly = TRUE))
  self_test()
  if (isTRUE(opts$self_test)) return(invisible())
  message("Reading MT and CVT MET files...")
  mt <- read_site("MT", opts); cvt <- read_site("CVT", opts)
  message("Aggregating and applying short-gap interpolation...")
  mt_data <- process_site(mt, "MT", opts)
  cvt_data <- process_site(cvt, "CVT", opts, mt_data[, .(window_start, rain_flag)])
  for (site in c("MT", "CVT")) {
    out_dir <- file.path(opts$level1_root, site, "MET"); dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
    x <- if (site == "MT") mt_data else cvt_data; result <- if (site == "MT") mt else cvt
    output_cols <- c("site", "timestamp", "rn", "ta_ec", "rh_ec", "vpd", "ws_ec", "wd_ec", "rain_flag", "n_records",
      "rn_interpolated", "ta_ec_interpolated", "rh_ec_interpolated", "vpd_interpolated", "ws_ec_interpolated", "wd_ec_interpolated")
    fwrite(x[, ..output_cols], file.path(out_dir, paste0(site, "_MET_30min_full.csv")), na = "")
    fwrite(result$mapping, file.path(out_dir, paste0(site, "_MET_field_mapping.csv")), na = "")
    audit <- data.table(site = site, source_dat_files = result$n_files, duplicate_raw_timestamp_rows_removed = result$duplicate_timestamp_rows,
      output_30min_rows = nrow(x), start = min(x$timestamp), end = max(x$timestamp),
      variable = c("rn", "ta_ec", "rh_ec", "vpd", "ws_ec", "wd_ec", "rain_flag"),
      missing_30min_rows = c(sum(is.na(x$rn)), sum(is.na(x$ta_ec)), sum(is.na(x$rh_ec)), sum(is.na(x$vpd)), sum(is.na(x$ws_ec)), sum(is.na(x$wd_ec)), sum(is.na(x$rain_flag))),
      interpolated_30min_rows = c(sum(x$rn_interpolated), sum(x$ta_ec_interpolated), sum(x$rh_ec_interpolated), sum(x$vpd_interpolated), sum(x$ws_ec_interpolated), sum(x$wd_ec_interpolated), NA_integer_))
    fwrite(audit, file.path(out_dir, paste0(site, "_MET_30min_audit.csv")), na = "")
  }
  message("Done. Outputs written under ", opts$level1_root)
}

main()
