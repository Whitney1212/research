#!/usr/bin/env Rscript

# No-rotation pass air accumulation.  Bundle timestamps ending in Z are legacy
# local wall-clock labels, not UTC; TOA5 and bundle data are both Asia/Shanghai.
suppressPackageStartupMessages(library(data.table))
if (!requireNamespace("digest", quietly = TRUE)) stop("Package 'digest' is required.", call. = FALSE)

tz_local <- "Asia/Shanghai"
default_bundle <- "E:/FL_MASSBALANCE/202308/downstream_multicaliber/bundle_index.csv"
default_raw_root <- "E:/Dataset_Level0/Flares/EC"
default_metadata <- "D:/00 博士阶段/博一/05 Project/com_260507/sh20240701.metadata"
default_output_root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"

required_month_cols <- c(
  "pass_uid", "source_group", "source_pass_id", "start_time_local", "end_time_local", "pass_mid_time_local",
  "direction", "track_scope", "track_south_m", "track_north_m", "n_raw", "n_diag_valid", "n_valid", "fs_hz",
  "pass_duration_seconds", "valid_seconds", "coverage_fraction", "Q_up_m", "Q_down_m", "Q_net_m", "Q_gross_m",
  "q_up_m_s", "q_down_m_s", "q_net_m_s", "q_gross_m_s", "up_time_fraction", "down_time_fraction",
  "mean_w_when_up_m_s", "mean_abs_w_when_down_m_s", "imbalance_index", "closure_net_error", "closure_gross_error",
  "qc_status", "qc_reason"
)

parse_args <- function(args) {
  o <- list(bundle = default_bundle, raw_root = default_raw_root, metadata = default_metadata,
            output_root = default_output_root, month = NA_character_, self_check = FALSE)
  for (a in args) {
    if (grepl("^--bundle=", a)) o$bundle <- sub("^--bundle=", "", a)
    else if (grepl("^--raw-root=", a)) o$raw_root <- sub("^--raw-root=", "", a)
    else if (grepl("^--metadata=", a)) o$metadata <- sub("^--metadata=", "", a)
    else if (grepl("^--output-root=", a)) o$output_root <- sub("^--output-root=", "", a)
    else if (grepl("^--month=", a)) o$month <- sub("^--month=", "", a)
    else if (a == "--self-check") o$self_check <- TRUE
    else if (a %in% c("-h", "--help")) {
      cat("Usage: Rscript run_fl_no_rotation_pass_air_accumulation.R [--month=YYYY_MM] [--self-check]\n")
      quit(save = "no", status = 0)
    } else stop("Unknown argument: ", a, call. = FALSE)
  }
  if (!is.na(o$month) && !grepl("^[0-9]{4}_[0-9]{2}$", o$month)) stop("--month must be YYYY_MM.", call. = FALSE)
  o
}

parse_bundle_time <- function(x) {
  # The literal Z in this bundle was historically appended to local times.
  x <- sub("Z$", "", trimws(as.character(x)))
  x <- sub("T", " ", x, fixed = TRUE)
  as.POSIXct(x, format = "%Y-%m-%d %H:%M:%OS", tz = tz_local)
}

parse_toa5_time <- function(x) {
  x <- trimws(gsub('"', "", as.character(x), fixed = TRUE))
  p <- tstrsplit(x, " ", fixed = TRUE)
  if (length(p) < 2L) return(as.POSIXct(rep(NA_real_, length(x)), origin = "1970-01-01", tz = tz_local))
  day <- p[[1L]]; clock <- p[[2L]]
  is_24 <- grepl("^24:", clock)
  if (any(is_24, na.rm = TRUE)) {
    day[is_24] <- as.character(as.Date(day[is_24]) + 1L)
    clock[is_24] <- sub("^24:", "00:", clock[is_24])
  }
  as.POSIXct(paste(day, clock), format = "%Y-%m-%d %H:%M:%OS", tz = tz_local)
}

fmt_time <- function(x) format(x, "%Y-%m-%d %H:%M:%OS3", tz = tz_local)
to_num <- function(x) {
  z <- suppressWarnings(as.numeric(x))
  z[z <= -9990 | z >= 999999] <- NA_real_
  z
}
sha256 <- function(path) digest::digest(file = path, algo = "sha256", serialize = FALSE)
finite_or_na <- function(x) all(is.finite(x) | is.na(x))

atomic_replace <- function(tmp, path) {
  if (!file.exists(tmp)) stop("Missing temporary output: ", tmp, call. = FALSE)
  if (!file.exists(path)) {
    if (!file.rename(tmp, path)) stop("Could not rename ", tmp, " to ", path, call. = FALSE)
    return(invisible(path))
  }
  bak <- paste0(path, ".bak.", Sys.getpid())
  if (!file.rename(path, bak)) stop("Could not stage existing output for replacement: ", path, call. = FALSE)
  if (!file.rename(tmp, path)) {
    file.rename(bak, path)
    stop("Could not replace output: ", path, call. = FALSE)
  }
  unlink(bak)
  invisible(path)
}

atomic_fwrite <- function(x, path, validator = NULL) {
  tmp <- paste0(path, ".tmp.", Sys.getpid())
  if (file.exists(tmp)) unlink(tmp)
  fwrite(x, tmp, na = "")
  if (!is.null(validator)) validator(tmp)
  atomic_replace(tmp, path)
}

read_fs <- function(path) {
  if (!file.exists(path)) stop("Missing metadata: ", path, call. = FALSE)
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  hit <- grep("^acquisition_frequency\\s*=", trimws(lines), value = TRUE, ignore.case = TRUE)
  if (!length(hit)) stop("Metadata does not define acquisition_frequency: ", path, call. = FALSE)
  fs <- suppressWarnings(as.numeric(sub("^[^=]*=", "", hit[[1L]])))
  if (!is.finite(fs) || fs <= 0) stop("Invalid acquisition_frequency in metadata: ", path, call. = FALSE)
  fs
}

source_rank <- function(x) match(x, c("main_complete", "oldcode_0_245", "batch_b_complete"))
track_scope <- function(x) fifelse(x == "batch_b_complete", "0_230_m", "0_245_m")

build_inventory <- function(bundle_path) {
  b <- fread(bundle_path, showProgress = FALSE)
  need <- c("source_group", "pass_csv", "cache_csv", "track_south_m", "track_north_m")
  if (length(miss <- setdiff(need, names(b)))) stop("Bundle index missing: ", paste(miss, collapse = ", "), call. = FALSE)
  expected <- c("oldcode_0_245", "main_complete", "batch_b_complete")
  if (!setequal(b$source_group, expected)) stop("Unexpected bundle source groups.", call. = FALSE)
  raw <- rbindlist(lapply(seq_len(nrow(b)), function(i) {
    x <- fread(b$pass_csv[[i]], colClasses = list(character = c("pass_id", "start_time_local", "end_time_local", "source_segment_id")), showProgress = FALSE)
    req <- c("pass_id", "start_time_local", "end_time_local", "direction", "source_segment_id", "source_group")
    if (length(m <- setdiff(req, names(x)))) stop("Pass file missing ", paste(m, collapse = ", "), ": ", b$pass_csv[[i]], call. = FALSE)
    x[, `:=`(
      source_group = b$source_group[[i]], source_pass_id = as.character(pass_id),
      start_time = parse_bundle_time(start_time_local), end_time = parse_bundle_time(end_time_local),
      track_south_m = as.numeric(b$track_south_m[[i]]), track_north_m = as.numeric(b$track_north_m[[i]])
    )]
    x[, .(source_group, source_pass_id, source_segment_id, start_time, end_time, direction,
           track_south_m, track_north_m, nominal_track_rule, local_track_phase)]
  }), use.names = TRUE, fill = TRUE)
  raw[, `:=`(source_priority = source_rank(source_group), track_scope = track_scope(source_group))]
  if (anyNA(raw$source_priority) || anyNA(raw$start_time) || anyNA(raw$end_time) || any(raw$end_time <= raw$start_time)) stop("Invalid bundle pass interval.", call. = FALSE)
  raw[, pass_uid := paste(source_group, source_pass_id, sep = ":")]
  if (anyDuplicated(raw$pass_uid)) stop("Duplicate source pass UID in bundle.", call. = FALSE)

  main <- raw[source_group == "main_complete"]
  old <- raw[source_group == "oldcode_0_245"]
  setkey(main, start_time, end_time); setkey(old, start_time, end_time)
  overlap <- foverlaps(old, main, by.x = c("start_time", "end_time"), by.y = c("start_time", "end_time"), type = "any", nomatch = 0L)
  audit <- rbindlist(list(
    main[, .(candidate_pass_uid = pass_uid, matched_pass_uid = NA_character_, candidate_source_group = source_group,
             matched_source_group = NA_character_, candidate_start_local = fmt_time(start_time), matched_start_local = NA_character_,
             overlap_seconds = NA_real_, action = "retained", rationale = "main_complete_priority")],
    old[!pass_uid %in% overlap$i.pass_uid, .(candidate_pass_uid = pass_uid, matched_pass_uid = NA_character_, candidate_source_group = source_group,
             matched_source_group = NA_character_, candidate_start_local = fmt_time(start_time), matched_start_local = NA_character_,
             overlap_seconds = NA_real_, action = "retained", rationale = "oldcode_fills_main_absence")],
    overlap[, .(candidate_pass_uid = i.pass_uid, matched_pass_uid = pass_uid, candidate_source_group = i.source_group,
                matched_source_group = source_group, candidate_start_local = fmt_time(i.start_time), matched_start_local = fmt_time(start_time),
                overlap_seconds = pmax(0, as.numeric(pmin(i.end_time, end_time) - pmax(i.start_time, start_time))),
                action = "excluded", rationale = "main_complete_priority_physical_overlap")],
    raw[source_group == "batch_b_complete", .(candidate_pass_uid = pass_uid, matched_pass_uid = NA_character_, candidate_source_group = source_group,
             matched_source_group = NA_character_, candidate_start_local = fmt_time(start_time), matched_start_local = NA_character_,
             overlap_seconds = NA_real_, action = "retained", rationale = "batch_b_special_0_230_track")]
  ), use.names = TRUE, fill = TRUE)
  keep <- c(main$pass_uid, old[!pass_uid %in% overlap$i.pass_uid, pass_uid], raw[source_group == "batch_b_complete", pass_uid])
  inv <- raw[pass_uid %in% keep]
  inv[, `:=`(
    start_time_local = fmt_time(start_time), end_time_local = fmt_time(end_time),
    pass_mid_time_local = fmt_time(start_time + as.numeric(difftime(end_time, start_time, units = "secs")) / 2),
    year_month = format(start_time, "%Y_%m", tz = tz_local)
  )]
  setorder(inv, start_time, source_priority, pass_uid)
  if (anyDuplicated(inv$pass_uid)) stop("Inventory pass_uid is not unique.", call. = FALSE)
  list(inventory = inv[], audit = audit[])
}

raw_index <- function(root) {
  files <- list.files(root, pattern = "[.]dat$", recursive = TRUE, full.names = TRUE)
  z <- data.table(file = normalizePath(files, winslash = "/", mustWork = FALSE), file_name = basename(files))
  z <- z[grepl("Time_Series_", file_name, fixed = TRUE)]
  z[, date_token := regmatches(file_name, regexpr("[0-9]{4}_[0-9]{2}_[0-9]{2}", file_name))]
  z <- z[nzchar(date_token)]
  setorder(z, date_token, file)
  z
}

read_toa5_wind <- function(path) {
  header <- tryCatch(names(fread(path, sep = ",", skip = 1L, header = TRUE, nrows = 0L, showProgress = FALSE)), error = function(e) character())
  need <- c("TIMESTAMP", "RECORD", "Ux", "Uy", "Uz", "diag_sonic")
  if (length(miss <- setdiff(need, header))) return(list(data = data.table(), reason = paste0("missing_raw_columns:", paste(miss, collapse = "+"))))
  idx <- match(need, header)
  x <- tryCatch(fread(path, sep = ",", skip = 4L, header = FALSE, select = idx, col.names = need,
                      colClasses = "character", na.strings = c("", "NA", "NaN", "NAN", "-9999", "-9999.0"), showProgress = FALSE),
                error = function(e) NULL)
  if (is.null(x)) return(list(data = data.table(), reason = "raw_read_error"))
  x[, `:=`(TIMESTAMP = parse_toa5_time(TIMESTAMP), RECORD = to_num(RECORD), Ux = to_num(Ux), Uy = to_num(Uy), Uz = to_num(Uz), diag_sonic = to_num(diag_sonic), source_file = basename(path))]
  x <- x[!is.na(TIMESTAMP)]
  setorder(x, TIMESTAMP, RECORD, source_file)
  x <- unique(x, by = c("TIMESTAMP", "RECORD"))
  list(data = x[], reason = NA_character_)
}

vm_despike_w <- function(x) {
  # Formal Vickers-Mahrt core settings for w: 5 sigma, 3-point run ceiling,
  # linear replacement, 20 iterations, pass-length/6 moving window.
  n <- length(x)
  if (n < 10L || all(is.na(x))) return(x)
  window_size <- max(5L, floor(n / 6))
  step_size <- max(1L, floor(window_size / 2L))
  cleaned <- x; flagged <- rep(FALSE, n)
  limit_groups <- function(mask, max_len = 3L) {
    rr <- rle(mask); ends <- cumsum(rr$lengths); starts <- ends - rr$lengths + 1L
    out <- rep(FALSE, length(mask)); keep <- rr$values & rr$lengths <= max_len
    for (j in which(keep)) out[starts[j]:ends[j]] <- TRUE
    out
  }
  interpolate <- function(original, mask) {
    good <- which(!mask & is.finite(original)); bad <- which(mask)
    if (!length(bad) || length(good) < 2L) { original[mask] <- NA_real_; return(original) }
    original[bad] <- approx(good, original[good], xout = bad, rule = 1, ties = "ordered")$y
    original
  }
  for (iter in seq_len(20L)) {
    candidate <- rep(FALSE, n)
    for (start in seq.int(1L, n, by = step_size)) {
      end <- min(n, start + window_size - 1L); idx <- start:end; v <- cleaned[idx]; valid <- v[is.finite(v)]
      if (length(valid) < 3L) next
      s <- stats::sd(valid); if (!is.finite(s) || s == 0) next
      bad <- which(v < mean(valid) - 5 * s | v > mean(valid) + 5 * s)
      if (length(bad)) candidate[idx[bad]] <- TRUE
    }
    candidate <- candidate & !flagged
    if (!any(candidate)) break
    next_flags <- limit_groups(flagged | candidate, 3L) & !flagged
    if (!any(next_flags)) break
    flagged <- flagged | next_flags
    cleaned <- interpolate(x, flagged)
  }
  cleaned
}

read_running_records <- function(bundle_row) {
  rr <- fread(bundle_row$cache_csv, select = c("time", "speed", "position", "pass_id"),
              colClasses = list(character = c("time", "pass_id")), showProgress = FALSE)
  rr[, `:=`(time = parse_bundle_time(time), cart_speed = to_num(speed) / 100, position = to_num(position),
            source_pass_id = as.character(pass_id), source_group = bundle_row$source_group)]
  rr <- rr[!is.na(time)]
  setorder(rr, source_pass_id, time)
  unique(rr[, .(source_group, source_pass_id, time, position, cart_speed)], by = c("source_pass_id", "time"))
}

add_running_fields <- function(x, rr) {
  x[, `:=`(position = NA_real_, cart_speed = NA_real_)]
  if (!nrow(rr) || !nrow(x)) return(x)
  keys <- unique(x[, .(pass_uid, source_group, source_pass_id)])
  for (i in seq_len(nrow(keys))) {
    k <- keys[i]; idx <- which(x$pass_uid == k$pass_uid)
    r <- rr[source_group == k$source_group & source_pass_id == k$source_pass_id]
    if (nrow(r) < 2L) next
    setorder(r, time)
    xt <- as.numeric(x$TIMESTAMP[idx]); rt <- as.numeric(r$time)
    x$position[idx] <- approx(rt, r$position, xout = xt, rule = 1, ties = "ordered")$y
    x$cart_speed[idx] <- approx(rt, r$cart_speed, xout = xt, rule = 1, ties = "ordered")$y
  }
  x
}

pass_result <- function(pass, samples, fs_hz, has_raw_candidate) {
  empty <- list(n_raw = 0L, n_diag_valid = 0L, n_valid = 0L, valid_seconds = NA_real_, coverage_fraction = NA_real_,
                Q_up_m = NA_real_, Q_down_m = NA_real_, Q_net_m = NA_real_, Q_gross_m = NA_real_, q_up_m_s = NA_real_,
                q_down_m_s = NA_real_, q_net_m_s = NA_real_, q_gross_m_s = NA_real_, up_time_fraction = NA_real_, down_time_fraction = NA_real_,
                mean_w_when_up_m_s = NA_real_, mean_abs_w_when_down_m_s = NA_real_, imbalance_index = NA_real_,
                closure_net_error = NA_real_, closure_gross_error = NA_real_, raw_net_m = NA_real_, raw_gross_m = NA_real_,
                q_net_error = NA_real_, q_gross_error = NA_real_, qc_status = "failed", qc_reason = if (has_raw_candidate) "no_samples_in_pass" else "no_raw_file")
  if (is.null(samples) || !nrow(samples)) return(as.data.table(empty))
  setorder(samples, TIMESTAMP, RECORD, source_file)
  samples <- unique(samples, by = c("TIMESTAMP", "RECORD"))
  n_raw <- nrow(samples)
  diag_ok <- is.finite(samples$diag_sonic) & samples$diag_sonic == 0
  n_diag <- sum(diag_ok)
  range_ok <- is.finite(samples$Ux) & is.finite(samples$Uy) & is.finite(samples$Uz) &
    abs(samples$Ux) <= 30 & abs(samples$Uy) <= 30 & sqrt(samples$Ux^2 + samples$Uy^2) <= 45 & abs(samples$Uz) <= 10
  w_input <- ifelse(diag_ok & range_ok, samples$Uz, NA_real_)
  w_clean <- vm_despike_w(w_input)
  valid <- is.finite(w_clean)
  n_valid <- sum(valid)
  if (!n_valid) {
    reason <- if (!n_diag) "no_diag_sonic_zero" else if (!any(diag_ok & range_ok)) "no_samples_after_range" else "no_samples_after_despike"
    out <- as.data.table(empty); out[, `:=`(n_raw = n_raw, n_diag_valid = n_diag, n_valid = 0L, qc_reason = reason)]
    return(out)
  }
  dt <- 1 / fs_hz; w <- w_clean[valid]; up <- pmax(w, 0); down <- pmax(-w, 0)
  q_up <- sum(up * dt); q_down <- sum(down * dt); q_net <- q_up - q_down; q_gross <- q_up + q_down; t_valid <- n_valid / fs_hz
  raw_net <- sum(w * dt); raw_gross <- sum(abs(w) * dt)
  dur <- as.numeric(difftime(pass$end_time, pass$start_time, units = "secs"))
  result <- list(
    n_raw = n_raw, n_diag_valid = n_diag, n_valid = n_valid, valid_seconds = t_valid, coverage_fraction = t_valid / dur,
    Q_up_m = q_up, Q_down_m = q_down, Q_net_m = q_net, Q_gross_m = q_gross,
    q_up_m_s = q_up / t_valid, q_down_m_s = q_down / t_valid, q_net_m_s = q_net / t_valid, q_gross_m_s = q_gross / t_valid,
    up_time_fraction = sum(w > 0) / n_valid, down_time_fraction = sum(w < 0) / n_valid,
    mean_w_when_up_m_s = if (any(w > 0)) mean(w[w > 0]) else NA_real_,
    mean_abs_w_when_down_m_s = if (any(w < 0)) mean(abs(w[w < 0])) else NA_real_,
    imbalance_index = if (q_gross > 0) q_net / q_gross else NA_real_,
    closure_net_error = q_net - raw_net, closure_gross_error = q_gross - raw_gross,
    raw_net_m = raw_net, raw_gross_m = raw_gross, q_net_error = q_net / t_valid - q_net / t_valid,
    q_gross_error = q_gross / t_valid - q_gross / t_valid, qc_status = "ok", qc_reason = "ok"
  )
  as.data.table(result)
}

validate_month <- function(path, expected) {
  x <- fread(path, showProgress = FALSE)
  if (!identical(names(x), required_month_cols)) stop("Month output schema mismatch: ", path, call. = FALSE)
  if (nrow(x) != nrow(expected) || anyDuplicated(x$pass_uid) || !setequal(x$pass_uid, expected$pass_uid)) stop("Month pass inventory mismatch: ", path, call. = FALSE)
  if (any(format(parse_bundle_time(x$start_time_local), "%Y_%m", tz = tz_local) != unique(expected$year_month))) stop("Month membership mismatch: ", path, call. = FALSE)
  expected_duration <- as.numeric(difftime(expected$end_time, expected$start_time, units = "secs"))
  actual_duration <- x$pass_duration_seconds[match(expected$pass_uid, x$pass_uid)]
  if (any(!is.finite(actual_duration) | abs(actual_duration - expected_duration) > 1e-8)) stop("Pass duration mismatch: ", path, call. = FALSE)
  numeric <- names(x)[vapply(x, is.numeric, logical(1))]
  if (!all(vapply(x[, ..numeric], finite_or_na, logical(1)))) stop("Unexpected Inf/NaN: ", path, call. = FALSE)
  ok <- x[qc_status == "ok"]
  if (nrow(ok)) {
    if (any(ok$Q_up_m < 0 | ok$Q_down_m < 0 | ok$q_up_m_s < 0 | ok$q_down_m_s < 0, na.rm = TRUE)) stop("Negative magnitude in ", path, call. = FALSE)
    if (any(abs(ok$imbalance_index) > 1 + 1e-12, na.rm = TRUE)) stop("Imbalance outside [-1,1]: ", path, call. = FALSE)
    tol_net <- 1e-10 * pmax(1, abs(ok$Q_net_m)); tol_gross <- 1e-10 * pmax(1, abs(ok$Q_gross_m))
    if (any(abs(ok$closure_net_error) > tol_net | abs(ok$closure_gross_error) > tol_gross, na.rm = TRUE)) stop("Closure failure: ", path, call. = FALSE)
  }
  invisible(x)
}

progress_columns <- c("year_month", "status", "n_inventory", "n_output", "n_success", "n_failed", "file_path", "file_size_bytes", "sha256", "max_abs_closure_error", "validated_at_local", "run_id")
read_progress <- function(path) {
  if (!file.exists(path)) return(data.table(year_month = character(), status = character(), n_inventory = integer(), n_output = integer(), n_success = integer(), n_failed = integer(), file_path = character(), file_size_bytes = numeric(), sha256 = character(), max_abs_closure_error = numeric(), validated_at_local = character(), run_id = character()))
  x <- fread(path, showProgress = FALSE); if (!identical(names(x), progress_columns)) stop("Unexpected progress schema.", call. = FALSE); x
}
write_progress <- function(progress, path) atomic_fwrite(progress[, ..progress_columns], path)

month_complete <- function(progress, ym, path, expected) {
  p <- progress[year_month == ym & status == "complete"]
  if (nrow(p) != 1L || !file.exists(path)) return(FALSE)
  if (!identical(unname(file.info(path)$size), as.numeric(p$file_size_bytes)) || !identical(sha256(path), p$sha256)) return(FALSE)
  tryCatch({ validate_month(path, expected); TRUE }, error = function(e) FALSE)
}

process_month <- function(inv, raw_files, rr_cache, fs_hz) {
  parts <- setNames(vector("list", nrow(inv)), inv$pass_uid)
  has_raw_candidate <- inv[, vapply(seq_len(.N), function(i) {
    tokens <- unique(format(as.Date(c(start_time[i], end_time[i]), tz = tz_local), "%Y_%m_%d")); any(raw_files$date_token %in% tokens)
  }, logical(1))]
  pi <- inv[, .(pass_uid, source_group, source_pass_id, source_priority, pass_start = start_time, pass_end = end_time)]
  setkey(pi, pass_start, pass_end)
  used_files <- raw_files[file %in% unique(raw_files$file)]
  for (f in used_files$file) {
    got <- read_toa5_wind(f); x <- got$data
    if (!nrow(x)) next
    x[, `:=`(t0 = TIMESTAMP, t1 = TIMESTAMP)]; setkey(x, t0, t1)
    m <- foverlaps(x, pi, by.x = c("t0", "t1"), by.y = c("pass_start", "pass_end"), type = "within", nomatch = 0L)
    if (!nrow(m)) next
    setorder(m, TIMESTAMP, RECORD, source_priority, pass_start, pass_uid)
    m <- unique(m, by = c("TIMESTAMP", "RECORD"))
    for (g in unique(m$source_group)) {
      if (is.null(rr_cache[[g]])) rr_cache[[g]] <- read_running_records(attr(inv, "bundle")[source_group == g][1])
    }
    rr <- rbindlist(rr_cache[unique(m$source_group)], use.names = TRUE, fill = TRUE)
    m <- add_running_fields(m, rr)
    for (uid in unique(m$pass_uid)) parts[[uid]][[length(parts[[uid]]) + 1L]] <- m[pass_uid == uid]
  }
  rows <- rbindlist(lapply(seq_len(nrow(inv)), function(i) {
    p <- inv[i]; s <- if (length(parts[[p$pass_uid]])) rbindlist(parts[[p$pass_uid]], use.names = TRUE, fill = TRUE) else NULL
    cbind(p[, .(pass_uid)], pass_result(p, s, fs_hz, has_raw_candidate[[i]]))
  }), fill = TRUE)
  out <- merge(inv, rows, by = "pass_uid", all.x = TRUE, sort = FALSE)
  out[, pass_duration_seconds := as.numeric(difftime(end_time, start_time, units = "secs"))]
  out[, fs_hz := fs_hz]
  out <- out[, ..required_month_cols]
  closure <- out[, .(pass_uid, year_month = format(parse_bundle_time(start_time_local), "%Y_%m", tz = tz_local), Q_net_m, raw_net_m = rows$raw_net_m[match(pass_uid, rows$pass_uid)], closure_net_error,
                     Q_gross_m, raw_gross_m = rows$raw_gross_m[match(pass_uid, rows$pass_uid)], closure_gross_error,
                     q_net_m_s, q_net_from_Q_m_s = q_net_m_s - rows$q_net_error[match(pass_uid, rows$pass_uid)], q_net_error = rows$q_net_error[match(pass_uid, rows$pass_uid)],
                     q_gross_m_s, q_gross_from_Q_m_s = q_gross_m_s - rows$q_gross_error[match(pass_uid, rows$pass_uid)], q_gross_error = rows$q_gross_error[match(pass_uid, rows$pass_uid)],
                     tolerance_net = 1e-10 * pmax(1, abs(Q_net_m)), tolerance_gross = 1e-10 * pmax(1, abs(Q_gross_m)), pass_validation_status = qc_status)]
  list(month = out[], closure = closure[], rr_cache = rr_cache)
}

write_month_outputs <- function(result, expected, month_path, closure_path) {
  atomic_fwrite(result$month, month_path, function(tmp) validate_month(tmp, expected))
  atomic_fwrite(result$closure, closure_path)
  invisible(TRUE)
}

write_derived_outputs <- function(tables_dir, progress, inventory) {
  complete <- progress[status == "complete", year_month]
  month_files <- file.path(tables_dir, paste0("no_rotation_pass_air_accumulation_", complete, ".csv"))
  # Keep local timestamp strings as characters: fread's automatic POSIXct parsing
  # can attach UTC and shift the diurnal bin by eight hours on reread.
  time_cols <- c("start_time_local", "end_time_local", "pass_mid_time_local")
  all_dt <- rbindlist(lapply(month_files, function(path) {
    fread(path, colClasses = list(character = time_cols), showProgress = FALSE)
  }), use.names = TRUE, fill = TRUE)
  if (nrow(all_dt) != nrow(inventory) || anyDuplicated(all_dt$pass_uid) || !setequal(all_dt$pass_uid, inventory$pass_uid)) stop("All-file inventory validation failed.", call. = FALSE)
  setorder(all_dt, start_time_local, source_group, source_pass_id)
  atomic_fwrite(all_dt, file.path(tables_dir, "no_rotation_pass_air_accumulation_all.csv"))
  metrics <- c("Q_up_m", "Q_down_m", "Q_net_m", "Q_gross_m", "q_up_m_s", "q_down_m_s", "q_net_m_s", "q_gross_m_s", "imbalance_index")
  z <- copy(all_dt); z[, mid_time := parse_bundle_time(pass_mid_time_local)]
  z[, `:=`(date_local = format(mid_time, "%Y-%m-%d", tz = tz_local), half_hour_local = format(as.POSIXct(floor(as.numeric(mid_time) / 1800) * 1800, origin = "1970-01-01", tz = tz_local), "%H:%M", tz = tz_local))]
  long <- melt(z, id.vars = c("track_scope", "direction", "date_local", "half_hour_local", "pass_uid"), measure.vars = metrics, variable.name = "metric", value.name = "value")
  diurnal <- long[is.finite(value), .(median = median(value), q25 = as.numeric(quantile(value, .25)), q75 = as.numeric(quantile(value, .75)), n_passes = .N, n_dates = uniqueN(date_local)), by = .(track_scope, direction, half_hour_local, metric)]
  setorder(diurnal, track_scope, direction, metric, half_hour_local)
  atomic_fwrite(diurnal, file.path(tables_dir, "no_rotation_diurnal_30min_preliminary.csv"))
  all_dt
}

write_text <- function(lines, path) {
  tmp <- paste0(path, ".tmp.", Sys.getpid()); writeLines(lines, tmp, useBytes = TRUE); atomic_replace(tmp, path)
}

archive_superseded <- function(path, reason) {
  if (!file.exists(path)) return(invisible(NULL))
  target <- paste0(path, ".superseded_", reason, "_", format(Sys.time(), "%Y%m%dT%H%M%S", tz = tz_local))
  if (!file.rename(path, target)) stop("Could not preserve invalid output before recomputation: ", path, call. = FALSE)
  message("Preserved invalid output as: ", target)
  invisible(target)
}

run_self_check <- function() {
  stopifnot(abs(as.numeric(parse_toa5_time("2023-11-23 24:00:00.1")) - as.numeric(as.POSIXct("2023-11-24 00:00:00.1", tz = tz_local))) < 1e-7)
  x <- c(rep(0, 300), 100, rep(0, 300)); y <- vm_despike_w(x)
  stopifnot(is.finite(y[301]), abs(y[301]) < 1e-12)
  message("Self-check passed.")
}

main <- function() {
  opt <- parse_args(commandArgs(trailingOnly = TRUE)); if (opt$self_check) { run_self_check(); return(invisible(NULL)) }
  dir.create(opt$output_root, recursive = TRUE, showWarnings = FALSE)
  tables_dir <- file.path(opt$output_root, "tables"); scripts_dir <- file.path(opt$output_root, "scripts")
  dir.create(tables_dir, recursive = TRUE, showWarnings = FALSE); dir.create(scripts_dir, recursive = TRUE, showWarnings = FALSE)
  log_path <- file.path(opt$output_root, "no_rotation_run.log"); log_con <- file(log_path, open = "at", encoding = "UTF-8"); sink(log_con, type = "output", split = TRUE); sink(log_con, type = "message"); on.exit({ sink(type = "message"); sink(type = "output"); close(log_con) }, add = TRUE)
  message("Run started: ", fmt_time(Sys.time()))
  self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1]); if (!is.na(self) && file.exists(self)) file.copy(self, file.path(scripts_dir, "run_fl_no_rotation_pass_air_accumulation.R"), overwrite = TRUE)
  fs_hz <- read_fs(opt$metadata); built <- build_inventory(opt$bundle); inv <- built$inventory
  attr(inv, "bundle") <- fread(opt$bundle, showProgress = FALSE)
  atomic_fwrite(inv[, .(pass_uid, source_group, source_pass_id, source_segment_id, start_time_local, end_time_local, pass_mid_time_local, direction, track_scope, track_south_m, track_north_m, nominal_track_rule, local_track_phase, year_month)], file.path(tables_dir, "no_rotation_pass_inventory.csv"))
  atomic_fwrite(built$audit, file.path(tables_dir, "no_rotation_duplicate_pass_audit.csv"))
  months <- sort(unique(inv$year_month)); if (!is.na(opt$month)) months <- intersect(months, opt$month)
  raw <- raw_index(opt$raw_root); progress_path <- file.path(tables_dir, "no_rotation_monthly_progress.csv"); progress <- read_progress(progress_path); rr_cache <- list(); run_id <- paste0(format(Sys.time(), "%Y%m%dT%H%M%S", tz = tz_local), "_", Sys.getpid())
  for (ym in months) {
    expected <- inv[year_month == ym]; attr(expected, "bundle") <- attr(inv, "bundle"); month_path <- file.path(tables_dir, paste0("no_rotation_pass_air_accumulation_", ym, ".csv")); closure_path <- file.path(tables_dir, paste0("no_rotation_closure_audit_", ym, ".csv"))
    if (month_complete(progress, ym, month_path, expected)) { message("Skipping verified month: ", ym); next }
    if (file.exists(month_path)) {
      # A valid final month without a complete progress entry is recoverable; never overwrite it.
      recovered <- tryCatch({ validate_month(month_path, expected); TRUE }, error = function(e) FALSE)
      if (recovered) {
        x <- fread(month_path); row <- data.table(year_month = ym, status = "complete", n_inventory = nrow(expected), n_output = nrow(x), n_success = sum(x$qc_status == "ok"), n_failed = sum(x$qc_status != "ok"), file_path = month_path, file_size_bytes = file.info(month_path)$size, sha256 = sha256(month_path), max_abs_closure_error = max(abs(c(x$closure_net_error, x$closure_gross_error)), na.rm = TRUE), validated_at_local = fmt_time(Sys.time()), run_id = paste0("recovered_", run_id))
        if (!is.finite(row$max_abs_closure_error)) row[, max_abs_closure_error := NA_real_]
        progress <- rbind(progress[year_month != ym], row, fill = TRUE); setorder(progress, year_month); write_progress(progress, progress_path); message("Recovered verified month: ", ym); next
      }
      archive_superseded(month_path, "invalid_validation")
      archive_superseded(closure_path, "paired_invalid_month")
    }
    message("Processing month: ", ym, " (", nrow(expected), " passes)")
    dates <- unique(unlist(lapply(seq_len(nrow(expected)), function(i) format(as.Date(c(expected$start_time[i], expected$end_time[i]), tz = tz_local), "%Y_%m_%d"))))
    month_raw <- raw[date_token %in% dates]
    result <- process_month(expected, month_raw, rr_cache, fs_hz); rr_cache <- result$rr_cache
    write_month_outputs(result, expected, month_path, closure_path)
    x <- result$month; err <- max(abs(c(x$closure_net_error, x$closure_gross_error)), na.rm = TRUE); if (!is.finite(err)) err <- NA_real_
    row <- data.table(year_month = ym, status = "complete", n_inventory = nrow(expected), n_output = nrow(x), n_success = sum(x$qc_status == "ok"), n_failed = sum(x$qc_status != "ok"), file_path = month_path, file_size_bytes = file.info(month_path)$size, sha256 = sha256(month_path), max_abs_closure_error = err, validated_at_local = fmt_time(Sys.time()), run_id = run_id)
    progress <- rbind(progress[year_month != ym], row, fill = TRUE); setorder(progress, year_month); write_progress(progress, progress_path)
  }
  if (!all(months %in% progress[status == "complete", year_month])) stop("Not all requested months completed.", call. = FALSE)
  # Only create full summaries when every inventory month has a verified monthly result.
  if (setequal(sort(unique(inv$year_month)), sort(progress[status == "complete", year_month]))) {
    all_dt <- write_derived_outputs(tables_dir, progress, inv)
    closure_all <- rbindlist(lapply(file.path(tables_dir, paste0("no_rotation_closure_audit_", sort(unique(inv$year_month)), ".csv")), fread), use.names = TRUE, fill = TRUE)
    atomic_fwrite(closure_all, file.path(tables_dir, "no_rotation_closure_audit.csv"))
    reasons <- all_dt[qc_status != "ok", .N, by = qc_reason][order(-N)]
    output_files <- list.files(opt$output_root, recursive = TRUE, full.names = TRUE); output_files <- output_files[!grepl("[.]tmp[.]|[.]bak[.]", output_files)]
    manifest <- c("no_rotation_pass_air_accumulation", paste("run_id:", run_id), paste("bundle_index:", normalizePath(opt$bundle, winslash = "/")), "dedup_rule: main_complete priority; oldcode fills only main-absent physical intervals; batch_b remains 0-230 m", "track_scope: 0_245_m for main/oldcode; 0_230_m for batch_b", "time_rule: TOA5 and bundle Z-labelled fields parsed as Asia/Shanghai local wall clock; 24:00 advances one date", "sample_qc: diag_sonic==0; finite Ux/Uy/Uz; abs(Ux)<=30; abs(Uy)<=30; horizontal<=45; abs(Uz)<=10; Vickers-Mahrt per full pass (5 sigma, run<=3, interpolate, max_iter=20, window=1/6)", paste("fs_hz:", fs_hz), paste("passes_inventory:", nrow(inv)), paste("passes_success:", sum(all_dt$qc_status == "ok")), paste("passes_failed:", sum(all_dt$qc_status != "ok")), paste("max_abs_closure_error:", max(abs(c(all_dt$closure_net_error, all_dt$closure_gross_error)), na.rm = TRUE)), paste("R:", R.version.string), paste("data.table:", as.character(packageVersion("data.table"))), paste("digest:", as.character(packageVersion("digest"))), "monthly_progress:", capture.output(print(progress)), "output_sha256:", vapply(output_files, function(f) paste(normalizePath(f, winslash = "/"), sha256(f), sep = " | "), character(1)))
    write_text(manifest, file.path(opt$output_root, "no_rotation_manifest.txt"))
    summary <- c("No-rotation pass air accumulation completed.", paste("inventory_passes:", nrow(all_dt)), paste("success_passes:", sum(all_dt$qc_status == "ok")), paste("failed_passes:", sum(all_dt$qc_status != "ok")), paste("max_abs_closure_error:", max(abs(c(all_dt$closure_net_error, all_dt$closure_gross_error)), na.rm = TRUE)), "failure_reason_distribution:", capture.output(print(reasons)))
    write_text(summary, file.path(opt$output_root, "no_rotation_summary.txt"))
  }
  message("Run completed: ", fmt_time(Sys.time()))
}

if (!identical(Sys.getenv("NO_ROTATION_SOURCE_ONLY", unset = "0"), "1")) main()
