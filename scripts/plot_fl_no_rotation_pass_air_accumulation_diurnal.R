#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

default_root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"

parse_args <- function(args) {
  out <- list(root = default_root, self_check = FALSE)
  for (arg in args) {
    if (grepl("^--root=", arg)) out$root <- sub("^--root=", "", arg)
    else if (arg == "--self-check") out$self_check <- TRUE
    else if (arg %in% c("-h", "--help")) {
      cat("Usage: Rscript plot_fl_no_rotation_pass_air_accumulation_diurnal.R [--root=PATH] [--self-check]\n")
      quit(save = "no", status = 0)
    } else stop("Unknown argument: ", arg, call. = FALSE)
  }
  out
}

load_diurnal <- function(root) {
  path <- file.path(root, "tables", "no_rotation_pass_air_accumulation_all.csv")
  if (!file.exists(path)) stop("Missing pass input: ", path, call. = FALSE)
  x <- fread(path, colClasses = list(character = "pass_mid_time_local"), showProgress = FALSE)
  need <- c("track_scope", "qc_status", "pass_mid_time_local", "q_up_m_s", "q_down_m_s", "q_net_m_s", "imbalance_index")
  if (length(miss <- setdiff(need, names(x)))) stop("Pass input missing: ", paste(miss, collapse = ", "), call. = FALSE)
  x <- x[track_scope == "0_245_m" & qc_status == "ok"]
  x[, half_hour_local := sprintf("%02d:%02d", as.integer(substr(pass_mid_time_local, 12L, 13L)), 30L * (as.integer(substr(pass_mid_time_local, 15L, 16L)) %/% 30L))]
  melt(x, id.vars = c("half_hour_local", "pass_mid_time_local"), measure.vars = c("q_up_m_s", "q_down_m_s", "q_net_m_s", "imbalance_index"), variable.name = "metric", value.name = "value")[,
    .(median = median(value), q25 = quantile(value, 0.25), q75 = quantile(value, 0.75), n_passes = .N, n_dates = uniqueN(substr(pass_mid_time_local, 1L, 10L))),
    by = .(half_hour_local, metric)
  ][, hour_local := as.integer(substr(half_hour_local, 1L, 2L)) + as.integer(substr(half_hour_local, 4L, 5L)) / 60]
}

check_diurnal <- function(x) {
  required <- c("q_up_m_s", "q_down_m_s", "q_net_m_s", "imbalance_index")
  stopifnot(all(required %in% unique(x$metric)))
  stopifnot(all(x$hour_local >= 0 & x$hour_local <= 23.5))
}

copy_self <- function(root) {
  self <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)[1])
  if (!is.na(self) && file.exists(self)) {
    dir.create(file.path(root, "scripts"), recursive = TRUE, showWarnings = FALSE)
    file.copy(self, file.path(root, "scripts", "plot_fl_no_rotation_pass_air_accumulation_diurnal.R"), overwrite = TRUE)
  }
}

main <- function() {
  opt <- parse_args(commandArgs(trailingOnly = TRUE))
  x <- load_diurnal(opt$root)
  check_diurnal(x)
  if (opt$self_check) { message("Self-check passed."); return(invisible(NULL)) }
  fig_dir <- file.path(opt$root, "figures")
  dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
  copy_self(opt$root)

  comp <- x[metric %in% c("q_up_m_s", "q_down_m_s", "q_net_m_s")]
  comp[, component := fcase(metric == "q_up_m_s", "upward", metric == "q_down_m_s", "downward", default = "net")]
  comp[component == "downward", `:=`(median = -median, q25 = -q25, q75 = -q75)]
  net <- comp[component == "net"]
  p_motion <- ggplot() +
    geom_hline(yintercept = 0, linewidth = 0.35, colour = "grey55") +
    geom_ribbon(data = net, aes(hour_local, ymin = q25, ymax = q75), fill = "grey55", alpha = 0.25) +
    geom_line(data = comp, aes(hour_local, median, colour = component, linetype = component), linewidth = 0.8) +
    scale_colour_manual(values = c(upward = "#D55E00", downward = "#0072B2", net = "#222222"), labels = c(upward = "upward", downward = "downward (-q_down)", net = "net")) +
    scale_linetype_manual(values = c(upward = "solid", downward = "solid", net = "solid"), guide = "none") +
    scale_x_continuous("Local time (Asia/Shanghai)", breaks = seq(0, 24, by = 3), limits = c(0, 23.5)) +
    ylab(expression("Median vertical air motion "~(m~s^{-1}))) +
    labs(colour = NULL, title = "0-245 m, fw and bw combined", subtitle = "Lines: median; grey ribbon: q_net interquartile range") +
    theme_bw(base_size = 11) + theme(legend.position = "bottom", strip.background = element_rect(fill = "grey95"))
  ggsave(file.path(fig_dir, "no_rotation_diurnal_0_245m_fw_bw_combined_vertical_air_motion.png"), p_motion, width = 9, height = 5, dpi = 240)

  imbalance <- x[metric == "imbalance_index"]
  p_imbalance <- ggplot(imbalance, aes(hour_local, median)) +
    geom_hline(yintercept = 0, linewidth = 0.35, colour = "grey55") +
    geom_ribbon(aes(ymin = q25, ymax = q75), fill = "#009E73", alpha = 0.25) +
    geom_line(colour = "#009E73", linewidth = 0.85) +
    scale_x_continuous("Local time (Asia/Shanghai)", breaks = seq(0, 24, by = 3), limits = c(0, 23.5)) +
    scale_y_continuous("Imbalance index", limits = c(-1, 1)) +
    labs(title = "0-245 m, fw and bw combined", subtitle = "Line: median; ribbon: interquartile range") +
    theme_bw(base_size = 11)
  ggsave(file.path(fig_dir, "no_rotation_diurnal_0_245m_fw_bw_combined_imbalance_index.png"), p_imbalance, width = 9, height = 5, dpi = 240)
}

main()
