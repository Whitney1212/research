#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

default_tz <- "Asia/Shanghai"
default_snap_tolerance_sec <- 120

products <- list(
  MT_no_rotation = list(
    input = "E:/Dataset_Level1/MT/EC/no rotation_ecpreproc/results/MT_flux_no_rotation.csv"
  ),
  MT_dr = list(
    input = "E:/Dataset_Level1/MT/EC/dr_ecpreproc/results/MT_flux_dr.csv"
  ),
  MT_global_pf = list(
    input = "E:/Dataset_Level1/MT/EC/PF/WINDOW/flux_runs/global_pf/MT_flux_global_pf.csv"
  ),
  MT_sector_pf = list(
    input = "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf.csv"
  ),
  MT_season_sector_pf = list(
    input = "E:/Dataset_Level1/MT/EC/PF/WINDOW/flux_runs/season_sector_pf/MT_flux_season_sector_pf.csv"
  ),
  CVT_no_rotation = list(
    input = "E:/Dataset_Level1/CVT/EC/no rotation_ecpreproc/results/CVT_flux_no_rotation.csv"
  ),
  CVT_dr = list(
    input = "E:/Dataset_Level1/CVT/EC/dr_ecpreproc/results/CVT_flux_dr.csv"
  ),
  CVT_global_pf = list(
    input = "E:/Dataset_Level1/CVT/EC/PF/flux_runs/global_pf/CVT_flux_global_pf.csv"
  ),
  CVT_sector_pf = list(
    input = "E:/Dataset_Level1/CVT/EC/PF/CVT_flux_sector_pf.csv"
  )
)

parse_cli_args <- function(args) {
  out <- list(
    products = names(products),
    tz = default_tz,
    snap_tolerance_sec = default_snap_tolerance_sec
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

    if (identical(key, "products")) {
      chosen <- trimws(strsplit(value, ",", fixed = TRUE)[[1L]])
      chosen <- chosen[nzchar(chosen)]
      bad <- setdiff(chosen, names(products))
      if (length(bad) > 0L) stop("Unknown products: ", paste(bad, collapse = ", "), call. = FALSE)
      out$products <- chosen
    } else if (identical(key, "tz")) {
      out$tz <- value
    } else if (identical(key, "snap_tolerance_sec")) {
      out$snap_tolerance_sec <- as.numeric(value)
    } else {
      stop("Unsupported argument --", key, call. = FALSE)
    }
    i <- i + 1L
  }

  if (!is.finite(out$snap_tolerance_sec) || out$snap_tolerance_sec < 0) {
    stop("Invalid --snap_tolerance_sec value.", call. = FALSE)
  }

  out
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
      parsed[bad] <- as.POSIXct(fallback_chr[bad], format = "%Y-%m-%d %H:%M:%OS", tz = tz_local)
      still_bad <- is.na(parsed) & !is.na(fallback_chr)
      if (any(still_bad)) {
        parsed[still_bad] <- as.POSIXct(fallback_chr[still_bad], format = "%Y-%m-%d %H:%M", tz = tz_local)
      }
    }
  }

  parsed
}

timestamp_key <- function(x, tz_local = default_tz) {
  format(x, "%Y-%m-%d %H:%M:%S", tz = tz_local)
}

date_key <- function(x, tz_local = default_tz) {
  format(x, "%Y-%m-%d", tz = tz_local)
}

time_key <- function(x, tz_local = default_tz) {
  format(x, "%H:%M:%S", tz = tz_local)
}

snap_to_halfhour <- function(x, tz_local = default_tz, tolerance_sec = default_snap_tolerance_sec) {
  out <- rep(as.POSIXct(NA, tz = tz_local), length(x))
  delta <- rep(NA_real_, length(x))
  status <- rep(NA_character_, length(x))

  ok <- !is.na(x)
  if (any(ok)) {
    raw_num <- as.numeric(x[ok])
    snapped_num <- round(raw_num / 1800) * 1800
    snapped <- as.POSIXct(snapped_num, origin = "1970-01-01", tz = tz_local)
    dsec <- raw_num - snapped_num
    out[ok] <- snapped
    delta[ok] <- dsec
    status[ok] <- fifelse(
      abs(dsec) < 1e-9, "exact",
      fifelse(abs(dsec) <= tolerance_sec, "snapped", "offgrid_drop")
    )
  }

  data.table(
    timestamp_30min = out,
    snap_delta_sec = delta,
    snap_status = status
  )
}

collapse_character <- function(x) {
  x <- trimws(as.character(x))
  x <- x[!is.na(x) & nzchar(x)]
  if (length(x) == 0L) return(NA_character_)
  u <- unique(x)
  if (length(u) == 1L) return(u[[1L]])
  paste(u, collapse = "|")
}

is_flag_like_numeric <- function(name) {
  grepl("^(qc_|flag|ss9_|itc9_)", name)
}

aggregate_numeric <- function(x, name) {
  x <- suppressWarnings(as.numeric(x))
  finite <- x[is.finite(x)]
  if (length(finite) == 0L) return(NA_real_)
  if (is_flag_like_numeric(name)) return(max(finite))
  mean(finite)
}

build_output_paths <- function(input_file) {
  dir_name <- dirname(input_file)
  stem <- tools::file_path_sans_ext(basename(input_file))
  list(
    main = file.path(dir_name, paste0(stem, "_standardized_30min.csv")),
    summary = file.path(dir_name, paste0(stem, "_standardized_30min_summary.csv")),
    duplicates = file.path(dir_name, paste0(stem, "_standardized_30min_duplicate_details.csv")),
    offgrid = file.path(dir_name, paste0(stem, "_standardized_30min_offgrid_dropped.csv"))
  )
}

aggregate_kept_rows <- function(dt, tz_local = default_tz) {
  helper_cols <- c("timestamp_parsed_local", "timestamp_30min_local", "snap_delta_sec", "snap_status")
  by_cols <- c("timestamp", "date", "time")
  value_cols <- setdiff(names(dt), c(by_cols, helper_cols))

  agg <- dt[, {
    out <- list(
      n_merged_rows = .N,
      timestamp_normalization_status = if (all(snap_status == "exact")) {
        "exact"
      } else if (all(snap_status == "snapped")) {
        "snapped"
      } else {
        "mixed"
      },
      max_abs_snap_delta_sec = suppressWarnings(max(abs(snap_delta_sec), na.rm = TRUE))
    )

    for (nm in value_cols) {
      x <- .SD[[nm]]
      if (is.character(x) || is.factor(x)) {
        out[[nm]] <- collapse_character(x)
      } else if (is.logical(x)) {
        vals <- x[!is.na(x)]
        out[[nm]] <- if (length(vals) == 0L) NA else any(vals)
      } else {
        out[[nm]] <- aggregate_numeric(x, nm)
      }
    }
    out
  }, by = by_cols, .SDcols = value_cols]

  if (!"rotation_method" %in% names(agg)) {
    agg[, rotation_method := NA_character_]
  }

  agg[, timestamp_local := as.POSIXct(timestamp, format = "%Y-%m-%d %H:%M:%S", tz = tz_local)]
  setorder(agg, timestamp_local)
  agg[, timestamp_local := NULL]
  agg
}

standardize_one_product <- function(product_name, input_file, tz_local = default_tz, tolerance_sec = default_snap_tolerance_sec) {
  if (!file.exists(input_file)) stop("Missing input file: ", input_file, call. = FALSE)

  out_paths <- build_output_paths(input_file)
  dir.create(dirname(out_paths$main), recursive = TRUE, showWarnings = FALSE)

  dt <- fread(
    input_file,
    encoding = "UTF-8",
    colClasses = list(character = c("timestamp", "date", "time"))
  )

  if (!"timestamp" %in% names(dt) && all(c("date", "time") %in% names(dt))) {
    dt[, timestamp := paste(date, time)]
  }
  if (!"timestamp" %in% names(dt)) stop("Input is missing timestamp columns: ", input_file, call. = FALSE)

  dt[, row_id := .I]
  parsed <- parse_timestamp_local(dt$timestamp, dt$date, dt$time, tz_local = tz_local)
  snap <- snap_to_halfhour(parsed, tz_local = tz_local, tolerance_sec = tolerance_sec)
  dt[, `:=`(
    timestamp_parsed_local = parsed,
    timestamp_30min_local = snap$timestamp_30min,
    snap_delta_sec = snap$snap_delta_sec,
    snap_status = snap$snap_status
  )]

  offgrid <- dt[is.na(timestamp_parsed_local) | snap_status == "offgrid_drop"]
  if (nrow(offgrid) > 0L) {
    offgrid[, nearest_halfhour := timestamp_key(timestamp_30min_local, tz_local = tz_local)]
    fwrite(offgrid, out_paths$offgrid)
  } else {
    fwrite(data.table(), out_paths$offgrid)
  }

  kept <- dt[!is.na(timestamp_parsed_local) & snap_status %in% c("exact", "snapped")]
  kept[, `:=`(
    timestamp = timestamp_key(timestamp_30min_local, tz_local = tz_local),
    date = date_key(timestamp_30min_local, tz_local = tz_local),
    time = time_key(timestamp_30min_local, tz_local = tz_local)
  )]

  duplicate_details <- kept[duplicated(timestamp) | duplicated(timestamp, fromLast = TRUE)]
  if (nrow(duplicate_details) > 0L) {
    fwrite(duplicate_details, out_paths$duplicates)
  } else {
    fwrite(data.table(), out_paths$duplicates)
  }

  clean <- aggregate_kept_rows(kept, tz_local = tz_local)
  fwrite(clean, out_paths$main)

  dup_group_count <- if (nrow(duplicate_details) == 0L) 0L else uniqueN(duplicate_details$timestamp)
  summary_dt <- data.table(
    product = product_name,
    input_file = input_file,
    output_file = out_paths$main,
    rows_in = nrow(dt),
    rows_parsed = sum(!is.na(dt$timestamp_parsed_local)),
    rows_exact = sum(dt$snap_status == "exact", na.rm = TRUE),
    rows_snapped = sum(dt$snap_status == "snapped", na.rm = TRUE),
    rows_dropped_offgrid = nrow(offgrid),
    rows_kept_before_dedup = nrow(kept),
    duplicate_group_count = dup_group_count,
    duplicate_rows_before_dedup = nrow(duplicate_details),
    rows_out = nrow(clean),
    rows_merged_away = nrow(kept) - nrow(clean),
    first_timestamp = if (nrow(clean) > 0L) clean$timestamp[[1L]] else NA_character_,
    last_timestamp = if (nrow(clean) > 0L) clean$timestamp[[nrow(clean)]] else NA_character_,
    remaining_duplicate_timestamps = nrow(clean) - uniqueN(clean$timestamp)
  )
  fwrite(summary_dt, out_paths$summary)

  summary_dt
}

self_check <- function() {
  demo <- data.table(
    timestamp = c("2024-01-01 00:00:00.1", "2024-01-01 00:00:50", "2024-01-01 00:13:00"),
    date = c("2024-01-01", "2024-01-01", "2024-01-01"),
    time = c("00:00:00.1", "00:00:50", "00:13:00"),
    co2_flux = c(-1, -3, -5),
    qc_co2 = c(0, 1, 0),
    rotation_method = c("dr", "dr", "dr")
  )
  parsed <- parse_timestamp_local(demo$timestamp, demo$date, demo$time)
  snap <- snap_to_halfhour(parsed, tolerance_sec = 120)
  stopifnot(
    identical(snap$snap_status[[1L]], "snapped"),
    identical(snap$snap_status[[2L]], "snapped"),
    identical(snap$snap_status[[3L]], "offgrid_drop")
  )
  kept <- cbind(demo[1:2], snap[1:2])
  kept[, `:=`(
    timestamp = timestamp_key(timestamp_30min),
    date = date_key(timestamp_30min),
    time = time_key(timestamp_30min)
  )]
  agg <- aggregate_kept_rows(kept)
  stopifnot(
    nrow(agg) == 1L,
    abs(agg$co2_flux[[1L]] - (-2)) < 1e-9,
    identical(agg$qc_co2[[1L]], 1)
  )
}

self_check()

args <- parse_cli_args(commandArgs(trailingOnly = TRUE))

manifest <- rbindlist(lapply(args$products, function(product_name) {
  standardize_one_product(
    product_name = product_name,
    input_file = products[[product_name]]$input,
    tz_local = args$tz,
    tolerance_sec = args$snap_tolerance_sec
  )
}))

manifest_dir <- "E:/Dataset_Level1/FixedTower/EC"
dir.create(manifest_dir, recursive = TRUE, showWarnings = FALSE)
manifest_file <- file.path(manifest_dir, "fixed_tower_full_flux_standardized_30min_manifest.csv")
fwrite(manifest, manifest_file)

print(manifest)
