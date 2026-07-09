suppressPackageStartupMessages({
  library(data.table)
})

rotation_project_dir <- "D:/00 博士阶段/博一/05 Project/com_rotation"
source(file.path(rotation_project_dir, "scripts", "00_config.R"), encoding = "UTF-8")
source(file.path(rotation_project_dir, "scripts", "lib_common_rotation.R"), encoding = "UTF-8")

out_dir <- "E:/Dataset_Level1/FixedTower/EC/rotation_sensitivity_standardized_2025/mechanism_diagnostics"
out_file <- file.path(out_dir, "rotation_sigma_co2_common_periods.csv")
paired_out_file <- file.path(out_dir, "rotation_sigma_co2_paired_common_periods.csv")

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

summarise_file_blocks <- function(file, site_name, period_row) {
  dat <- tryCatch(
    read_toa5(file, tz = cfg$tz, show_progress = FALSE),
    error = function(e) {
      warning(sprintf("read_toa5 failed for %s: %s", file, e$message), call. = FALSE)
      NULL
    }
  )
  if (is.null(dat) || nrow(dat) == 0L || !"time" %in% names(dat) || !"co2" %in% names(dat)) {
    return(data.table())
  }
  dt <- as.data.table(dat)[, .(time, co2)]
  dt <- dt[is.finite(time) & is.finite(co2)]
  if (nrow(dt) == 0L) {
    return(data.table())
  }

  dt[, timestamp := as.POSIXct(floor(as.numeric(time) / 1800) * 1800, origin = "1970-01-01", tz = cfg$tz)]
  dt <- dt[timestamp >= period_row$start & timestamp < period_row$end]
  if (nrow(dt) == 0L) {
    return(data.table())
  }

  out <- dt[, .(
    n_points_co2 = .N,
    co2_mean = safe_mean(co2),
    sigma_co2 = safe_sd(co2)
  ), by = .(timestamp)]
  out <- out[n_points_co2 >= 10L & is.finite(sigma_co2)]
  if (nrow(out) == 0L) {
    return(data.table())
  }

  out[, `:=`(
    site = site_name,
    period = period_row$period,
    source_file = file
  )]
  setcolorder(out, c("site", "period", "timestamp", "source_file", "n_points_co2", "co2_mean", "sigma_co2"))
  out
}

main <- function() {
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  load_ecpreproc(cfg)

  manifest_path <- file.path(cfg$project_dir, "results", "input_file_manifest.csv")
  if (!file.exists(manifest_path)) {
    stop("Missing manifest: ", manifest_path, call. = FALSE)
  }
  manifest <- fread(manifest_path)
  periods <- as.data.table(get_periods(cfg))

  rows <- list()
  k <- 0L

  for (site_name in unique(manifest$site)) {
    meta <- ec_read_metadata(cfg$sites[[site_name]]$metadata_path)
    ec_set_metadata(meta)

    site_manifest <- unique(manifest[site == site_name, .(period, file)])
    for (i in seq_len(nrow(site_manifest))) {
      period_name <- site_manifest$period[[i]]
      period_row <- periods[period == period_name]
      if (nrow(period_row) != 1L) {
        stop("Expected exactly one period row for ", period_name, call. = FALSE)
      }
      file <- site_manifest$file[[i]]
      message_ts("sigma_co2 %s %s | %s", site_name, period_name, basename(file))
      out <- summarise_file_blocks(file, site_name = site_name, period_row = period_row)
      if (nrow(out) == 0L) next
      k <- k + 1L
      rows[[k]] <- out
    }
  }

  sigma_dt <- rbindlist(rows, use.names = TRUE, fill = TRUE)
  if (nrow(sigma_dt) == 0L) {
    stop("No sigma_co2 rows were produced.", call. = FALSE)
  }

  sigma_dt <- unique(sigma_dt, by = c("site", "period", "timestamp"))
  setorder(sigma_dt, site, period, timestamp)
  sigma_dt[, `:=`(
    ts_key = format(timestamp, "%Y-%m-%d %H:%M:%S", tz = cfg$tz),
    date = format(timestamp, "%Y-%m-%d", tz = cfg$tz),
    hhmm = format(timestamp, "%H:%M", tz = cfg$tz),
    hour_decimal = as.integer(format(timestamp, "%H", tz = cfg$tz)) +
      as.integer(format(timestamp, "%M", tz = cfg$tz)) / 60
  )]
  sigma_dt[, timestamp := format(timestamp, "%Y-%m-%d %H:%M:%S", tz = cfg$tz)]
  setcolorder(
    sigma_dt,
    c("site", "period", "timestamp", "ts_key", "date", "hhmm", "hour_decimal",
      "n_points_co2", "co2_mean", "sigma_co2", "source_file")
  )

  stopifnot(
    nrow(sigma_dt) > 0L,
    sigma_dt[, max(.N), by = .(site, period, timestamp)]$V1 == 1L,
    all(is.finite(sigma_dt$sigma_co2)),
    all(sigma_dt$sigma_co2 >= 0),
    all(sigma_dt$n_points_co2 >= 10L)
  )

  fwrite(sigma_dt, out_file)
  message_ts("Wrote %s rows=%d", out_file, nrow(sigma_dt))

  paired_key_file <- file.path(cfg$project_dir, "results", "analysis", "tables", "13_w_sigma_flux_joined.csv")
  if (file.exists(paired_key_file)) {
    paired_keys <- unique(
      fread(paired_key_file, colClasses = list(character = "timestamp"))[
        , .(site, period, timestamp)
      ]
    )
    paired_dt <- merge(
      paired_keys,
      sigma_dt,
      by = c("site", "period", "timestamp"),
      all.x = TRUE,
      sort = TRUE
    )
    stopifnot(all(is.finite(paired_dt$sigma_co2)))
    fwrite(paired_dt, paired_out_file)
    message_ts("Wrote %s rows=%d", paired_out_file, nrow(paired_dt))
  }
}

if (sys.nframe() == 0L) {
  main()
}
