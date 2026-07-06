#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

input_csv <- "E:/FL_MASSBALANCE/results/FL_mass_balance_PF8bin_2ensemble_1min.csv"
output_dir <- "E:/FL_MASSBALANCE/figures/fl_pf8bin2ensemble_wmean_rotation"

position_bin_width_m <- 10
position_breaks <- seq(0, 250, by = position_bin_width_m)

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

summary_csv <- file.path(output_dir, "FL_pf8bin2ensemble_wmean_rotation_summary.csv")
diurnal_csv <- file.path(output_dir, "FL_pf8bin2ensemble_wmean_rotation_position_time_diurnal.csv")
plot_png <- file.path(output_dir, "FL_pf8bin2ensemble_wmean_rotation_position_time_diurnal.png")
diff_csv <- file.path(output_dir, "FL_pf8bin2ensemble_wmean_rotation_difference_position_time_diurnal.csv")
diff_png <- file.path(output_dir, "FL_pf8bin2ensemble_wmean_rotation_difference_position_time_diurnal.png")
summary_txt <- file.path(output_dir, "FL_pf8bin2ensemble_wmean_rotation_summary.txt")

as_num <- function(x) suppressWarnings(as.numeric(x))

as_bool <- function(x) {
  if (is.logical(x)) return(x)
  x_chr <- trimws(tolower(as.character(x)))
  x_chr %in% c("true", "t", "1", "yes", "y")
}

parse_local_time <- function(x) {
  out <- as.POSIXct(x, format = "%Y-%m-%d %H:%M:%S", tz = "Asia/Shanghai")
  bad <- is.na(out)
  if (any(bad)) {
    out[bad] <- as.POSIXct(x[bad], format = "%Y-%m-%d %H:%M", tz = "Asia/Shanghai")
  }
  out
}

robust_abs_limit <- function(x, p = 0.98) {
  val <- unname(quantile(abs(x[is.finite(x)]), probs = p, na.rm = TRUE))
  if (!is.finite(val) || val <= 0) {
    val <- max(abs(x[is.finite(x)]), na.rm = TRUE)
  }
  if (!is.finite(val) || val <= 0) {
    val <- 1
  }
  val
}

diverging_fill_scale <- function(limit, colours, name) {
  scale_fill_gradientn(
    colours = colours,
    values = scales::rescale(c(-limit, -limit / 2, 0, limit / 2, limit)),
    limits = c(-limit, limit),
    oob = scales::squish,
    name = name
  )
}

theme_core <- function() {
  theme_bw(base_size = 13) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "grey90", linewidth = 0.2),
      legend.position = "top",
      strip.background = element_rect(fill = "grey92", colour = "grey70"),
      plot.title = element_text(face = "bold")
    )
}

self_check <- function(summary_dt, diurnal_dt, diff_dt) {
  stopifnot(nrow(summary_dt) == 2L)
  stopifnot(all(summary_dt$n_minutes > 0))
  stopifnot(all(diurnal_dt$half_hour_bin >= 0 & diurnal_dt$half_hour_bin <= 23.5))
  stopifnot(all(diurnal_dt$position_bin_mid >= 5 & diurnal_dt$position_bin_mid <= 245))
  stopifnot(nrow(diff_dt) > 0)
  stopifnot(all(diff_dt$half_hour_bin >= 0 & diff_dt$half_hour_bin <= 23.5))
  stopifnot(all(diff_dt$position_bin_mid >= 5 & diff_dt$position_bin_mid <= 245))
}

if (!file.exists(input_csv)) {
  stop("Missing input file: ", input_csv, call. = FALSE)
}

dt <- fread(input_csv, colClasses = list(character = "minute_time_local"))

required_cols <- c(
  "pass_id", "minute_time_local", "w_pf_1min", "w_raw_1min",
  "sum_position_m", "n_position", "minute_use"
)
missing_cols <- setdiff(required_cols, names(dt))
if (length(missing_cols)) {
  stop("Missing required columns: ", paste(missing_cols, collapse = ", "), call. = FALSE)
}

dt[, `:=`(
  w_pf_1min = as_num(w_pf_1min),
  w_raw_1min = as_num(w_raw_1min),
  sum_position_m = as_num(sum_position_m),
  n_position = as_num(n_position),
  minute_use = as_bool(minute_use),
  timestamp_local = parse_local_time(minute_time_local)
)]

dt[, position_mean_m := fifelse(
  is.finite(sum_position_m) & is.finite(n_position) & n_position > 0,
  sum_position_m / n_position,
  NA_real_
)]

dt <- dt[
  minute_use == TRUE &
    is.finite(timestamp_local) &
    is.finite(position_mean_m) &
    is.finite(w_pf_1min) &
    is.finite(w_raw_1min)
]

dt <- dt[position_mean_m >= 0 & position_mean_m <= 250]
dt[, position_bin_id := findInterval(position_mean_m, position_breaks, rightmost.closed = TRUE)]
dt <- dt[position_bin_id >= 1 & position_bin_id < length(position_breaks)]
dt[, `:=`(
  position_bin_min = position_breaks[position_bin_id],
  position_bin_max = position_breaks[position_bin_id + 1L],
  position_bin_mid = (position_breaks[position_bin_id] + position_breaks[position_bin_id + 1L]) / 2,
  date = as.Date(timestamp_local, tz = "Asia/Shanghai"),
  hour_local = as.integer(format(timestamp_local, "%H", tz = "Asia/Shanghai")),
  minute_local = as.integer(format(timestamp_local, "%M", tz = "Asia/Shanghai"))
)]
dt[, half_hour_bin := hour_local + fifelse(minute_local < 30, 0, 0.5)]

long_dt <- rbindlist(list(
  dt[, .(
    pass_id,
    date,
    half_hour_bin,
    position_bin_mid,
    method = "Before rotation",
    w_mean = w_raw_1min
  )],
  dt[, .(
    pass_id,
    date,
    half_hour_bin,
    position_bin_mid,
    method = "After PF_8bin_2ensemble",
    w_mean = w_pf_1min
  )]
), use.names = TRUE)

summary_dt <- long_dt[, .(
  n_minutes = .N,
  n_pass = uniqueN(pass_id),
  n_dates = uniqueN(date),
  mean_signed_w = mean(w_mean, na.rm = TRUE),
  mean_abs_w = mean(abs(w_mean), na.rm = TRUE),
  median_signed_w = median(w_mean, na.rm = TRUE),
  median_abs_w = median(abs(w_mean), na.rm = TRUE),
  sd_w = sd(w_mean, na.rm = TRUE),
  p05_w = quantile(w_mean, 0.05, na.rm = TRUE),
  p95_w = quantile(w_mean, 0.95, na.rm = TRUE)
) , by = method]

summary_dt[, method_order := match(method, c("Before rotation", "After PF_8bin_2ensemble"))]
setorder(summary_dt, method_order)
summary_dt[, method_order := NULL]

diurnal_dt <- long_dt[, .(
  n_minutes = .N,
  n_pass = uniqueN(pass_id),
  n_dates = uniqueN(date),
  w_mean = mean(w_mean, na.rm = TRUE),
  mean_abs_w = mean(abs(w_mean), na.rm = TRUE)
), by = .(method, half_hour_bin, position_bin_mid)]

diurnal_dt[, method := factor(method, levels = c("Before rotation", "After PF_8bin_2ensemble"))]
setorder(diurnal_dt, method, half_hour_bin, position_bin_mid)

diff_dt <- merge(
  diurnal_dt[method == "Before rotation", .(
    half_hour_bin, position_bin_mid,
    n_minutes_before = n_minutes,
    n_pass_before = n_pass,
    n_dates_before = n_dates,
    w_mean_before = w_mean,
    mean_abs_w_before = mean_abs_w
  )],
  diurnal_dt[method == "After PF_8bin_2ensemble", .(
    half_hour_bin, position_bin_mid,
    n_minutes_after = n_minutes,
    n_pass_after = n_pass,
    n_dates_after = n_dates,
    w_mean_after = w_mean,
    mean_abs_w_after = mean_abs_w
  )],
  by = c("half_hour_bin", "position_bin_mid"),
  all = FALSE,
  sort = TRUE
)
diff_dt[, `:=`(
  w_mean_diff = w_mean_after - w_mean_before,
  mean_abs_w_diff = mean_abs_w_after - mean_abs_w_before
)]

self_check(summary_dt, diurnal_dt, diff_dt)

fwrite(summary_dt, summary_csv)
fwrite(diurnal_dt, diurnal_csv)
fwrite(diff_dt, diff_csv)

w_limit <- robust_abs_limit(diurnal_dt$w_mean)

p <- ggplot(diurnal_dt, aes(x = position_bin_mid, y = half_hour_bin, fill = w_mean)) +
  geom_tile(width = position_bin_width_m, height = 0.5) +
  facet_wrap(~ method, ncol = 2) +
  diverging_fill_scale(
    w_limit,
    colours = c("#214C5F", "#7FCDBB", "#F7F7F7", "#FDB863", "#B35806"),
    name = "Mean w"
  ) +
  scale_x_continuous(breaks = seq(0, 245, 40), limits = c(0, 250), expand = c(0, 0)) +
  scale_y_continuous(breaks = seq(0, 24, 3), limits = c(-0.25, 23.75), expand = c(0, 0)) +
  theme_core() +
  labs(
    title = "FL full-data position x time w_mean diurnal pattern",
    subtitle = "10 m position bins; 30 min time bins; shared color clipping at 98% |w_mean|",
    x = "FL track position (m, 0 = MT/south, 245 = north)",
    y = "Hour of day"
  )

ggsave(plot_png, p, width = 12, height = 6.8, dpi = 300)

diff_limit <- robust_abs_limit(diff_dt$w_mean_diff)

p_diff <- ggplot(diff_dt, aes(x = position_bin_mid, y = half_hour_bin, fill = w_mean_diff)) +
  geom_tile(width = position_bin_width_m, height = 0.5) +
  diverging_fill_scale(
    diff_limit,
    colours = c("#214C5F", "#7FCDBB", "#F7F7F7", "#FDB863", "#B35806"),
    name = expression(Delta * " mean w")
  ) +
  scale_x_continuous(breaks = seq(0, 245, 40), limits = c(0, 250), expand = c(0, 0)) +
  scale_y_continuous(breaks = seq(0, 24, 3), limits = c(-0.25, 23.75), expand = c(0, 0)) +
  theme_core() +
  labs(
    title = "FL position x time Wmean change after PF_8bin_2ensemble",
    subtitle = "After rotation minus before rotation; 10 m position bins; 30 min time bins; color clipped at 98% |delta Wmean|",
    x = "FL track position (m, 0 = MT/south, 245 = north)",
    y = "Hour of day"
  )

ggsave(diff_png, p_diff, width = 6.4, height = 6.8, dpi = 300)

diff_summary <- diff_dt[, .(
  mean_diff = mean(w_mean_diff, na.rm = TRUE),
  median_diff = median(w_mean_diff, na.rm = TRUE),
  mean_abs_diff = mean(abs(w_mean_diff), na.rm = TRUE),
  min_diff = min(w_mean_diff, na.rm = TRUE),
  max_diff = max(w_mean_diff, na.rm = TRUE)
)]

summary_lines <- c(
  "FL PF_8bin_2ensemble rotation w_mean comparison",
  paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
  paste0("Input: ", input_csv),
  paste0("Summary CSV: ", summary_csv),
  paste0("Diurnal CSV: ", diurnal_csv),
  paste0("Plot: ", plot_png),
  paste0("Difference CSV: ", diff_csv),
  paste0("Difference plot: ", diff_png),
  "",
  "Overall comparison (m s-1):",
  summary_dt[, sprintf(
    "- %s: signed mean = %.6f, mean(|w|) = %.6f, median = %.6f, n_minutes = %d, n_dates = %d",
    method,
    mean_signed_w,
    mean_abs_w,
    median_signed_w,
    n_minutes,
    n_dates
  )],
  "",
  sprintf(
    "After - Before on position x time cells (m s-1): mean = %.6f, median = %.6f, mean(|diff|) = %.6f, min = %.6f, max = %.6f",
    diff_summary$mean_diff,
    diff_summary$median_diff,
    diff_summary$mean_abs_diff,
    diff_summary$min_diff,
    diff_summary$max_diff
  ),
  "",
  "Notes:",
  "- Uses the existing 1 min PF_8bin_2ensemble result table and keeps minute_use == TRUE rows only.",
  "- Position is computed as sum_position_m / n_position, then grouped into 10 m bins.",
  "- The plot follows the existing FL position x time heatmap style and uses a shared symmetric color scale.",
  "- Difference is computed on the aggregated 30 min x 10 m diurnal cells, not on raw 10 Hz samples."
)
writeLines(summary_lines, summary_txt, useBytes = TRUE)

message("Wrote outputs to: ", output_dir)
