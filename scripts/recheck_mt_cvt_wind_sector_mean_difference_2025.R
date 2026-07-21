#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

input_file <- "E:/Dataset_Level1/Comparison/MT_CVT/MT_CVT_hard_qc_paired_flux_difference_2025.csv"
output_dir <- "E:/Dataset_Level1/Comparison/MT_CVT/wind_direction_mean_recheck_2025"
B <- 2000L
block_days <- 3L
seed <- 20260721L
target_sectors <- c("180-210", "210-240", "240-270")

stopifnot(file.exists(input_file), B >= 50L, block_days >= 1L)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

dt <- fread(input_file)[method == "sector_pf"]
dates <- sort(unique(dt$date))

make_weights <- function() {
  set.seed(seed)
  weights <- matrix(0, nrow = B, ncol = length(dates))
  for (i in seq_len(B)) {
    starts <- sample.int(length(dates), ceiling(length(dates) / block_days), replace = TRUE)
    sampled <- unlist(lapply(starts, function(x) ((x - 1L + 0:(block_days - 1L)) %% length(dates)) + 1L), use.names = FALSE)
    weights[i, ] <- tabulate(sampled[seq_along(dates)], nbins = length(dates))
  }
  weights
}

weights <- make_weights()
ci <- function(x) as.numeric(quantile(x, c(0.025, 0.975), na.rm = TRUE, names = FALSE))

summarize_groups <- function(x, group_col) {
  x <- x[!is.na(get(group_col))]
  x[, group_value := as.character(get(group_col))]
  daily <- x[, .(
    sum_D = sum(D_cvt_minus_mt_umol_m2_s),
    sum_C = sum(C_cvt_minus_mt_gC_m2),
    n = .N
  ), by = .(date, group_value)]
  point <- daily[, .(
    n_windows = sum(n),
    mean_D_umol_m2_s = sum(sum_D) / sum(n),
    cumulative_C_gC_m2 = sum(sum_C)
  ), by = group_value]

  groups <- sort(unique(daily$group_value))
  d_mat <- c_mat <- n_mat <- matrix(0, nrow = length(dates), ncol = length(groups))
  idx <- cbind(match(daily$date, dates), match(daily$group_value, groups))
  d_mat[idx] <- daily$sum_D
  c_mat[idx] <- daily$sum_C
  n_mat[idx] <- daily$n
  mean_rep <- (weights %*% d_mat) / (weights %*% n_mat)
  c_rep <- weights %*% c_mat

  intervals <- rbindlist(lapply(seq_along(groups), function(i) {
    mean_ci <- ci(mean_rep[, i])
    cumulative_ci <- ci(c_rep[, i])
    data.table(
      group_value = groups[[i]],
      mean_D_ci_low = mean_ci[[1L]],
      mean_D_ci_high = mean_ci[[2L]],
      cumulative_C_ci_low = cumulative_ci[[1L]],
      cumulative_C_ci_high = cumulative_ci[[2L]]
    )
  }))
  merge(point, intervals, by = "group_value")
}

scopes <- list(
  all_common_windows = dt,
  daytime_mt_unstable = dt[day_night_clock == "clock_day_06_18" & stability_class_mt == "unstable"]
)

sector_results <- rbindlist(lapply(names(scopes), function(scope_name) {
  x <- scopes[[scope_name]]
  rbindlist(lapply(c(MT = "wind_sector_30deg_mt", CVT = "wind_sector_30deg_cvt"), function(col) {
    out <- summarize_groups(x, col)
    out[, `:=`(analysis_scope = scope_name, wind_reference = sub("wind_sector_30deg_", "", col))]
    out
  }), use.names = TRUE)
}), use.names = TRUE)
setcolorder(sector_results, c("analysis_scope", "wind_reference", "group_value", "n_windows", "mean_D_umol_m2_s", "mean_D_ci_low", "mean_D_ci_high", "cumulative_C_gC_m2", "cumulative_C_ci_low", "cumulative_C_ci_high"))
sector_results[, mean_rank := frank(-mean_D_umol_m2_s, ties.method = "min"), by = .(analysis_scope, wind_reference)]

joint_results <- rbindlist(lapply(names(scopes), function(scope_name) {
  x <- copy(scopes[[scope_name]])[!is.na(wind_sector_30deg_mt) & !is.na(wind_sector_30deg_cvt)]
  x[, joint_target_group := fcase(
    wind_sector_30deg_mt %chin% target_sectors & wind_sector_30deg_cvt %chin% target_sectors, "both_180_270",
    wind_sector_30deg_mt %chin% target_sectors, "MT_only_180_270",
    wind_sector_30deg_cvt %chin% target_sectors, "CVT_only_180_270",
    default = "neither_180_270"
  )]
  out <- summarize_groups(x, "joint_target_group")
  out[, analysis_scope := scope_name]
  out
}), use.names = TRUE)
setcolorder(joint_results, c("analysis_scope", "group_value", "n_windows", "mean_D_umol_m2_s", "mean_D_ci_low", "mean_D_ci_high", "cumulative_C_gC_m2", "cumulative_C_ci_low", "cumulative_C_ci_high"))

joint_matrix <- rbindlist(lapply(names(scopes), function(scope_name) {
  x <- scopes[[scope_name]][!is.na(wind_sector_30deg_mt) & !is.na(wind_sector_30deg_cvt)]
  x[, joint_sector := paste(wind_sector_30deg_mt, wind_sector_30deg_cvt, sep = "|")]
  out <- summarize_groups(x, "joint_sector")
  out[, c("mt_wind_sector", "cvt_wind_sector") := tstrsplit(group_value, "|", fixed = TRUE)]
  out[, `:=`(analysis_scope = scope_name, group_value = NULL)]
  out
}), use.names = TRUE)
joint_matrix[, mean_rank := frank(-mean_D_umol_m2_s, ties.method = "min"), by = analysis_scope]
setcolorder(joint_matrix, c("analysis_scope", "mt_wind_sector", "cvt_wind_sector", "n_windows", "mean_D_umol_m2_s", "mean_D_ci_low", "mean_D_ci_high", "mean_rank", "cumulative_C_gC_m2", "cumulative_C_ci_low", "cumulative_C_ci_high"))

agreement <- dt[is.finite(geo_wind_from_deg_mt) & is.finite(geo_wind_from_deg_cvt), .(
  circular_difference_deg = pmin(abs(geo_wind_from_deg_mt - geo_wind_from_deg_cvt), 360 - abs(geo_wind_from_deg_mt - geo_wind_from_deg_cvt)),
  same_sector = wind_sector_30deg_mt == wind_sector_30deg_cvt
)]
agreement_summary <- agreement[, .(
  n_windows = .N,
  mean_absolute_difference_deg = mean(circular_difference_deg),
  median_absolute_difference_deg = median(circular_difference_deg),
  same_30deg_sector_fraction = mean(same_sector),
  within_30deg_fraction = mean(circular_difference_deg <= 30),
  within_60deg_fraction = mean(circular_difference_deg <= 60)
)]

checks <- rbindlist(lapply(names(scopes), function(scope_name) {
  x <- scopes[[scope_name]]
  joint <- joint_results[analysis_scope == scope_name]
  full_joint <- joint_matrix[analysis_scope == scope_name]
  both_wind <- x[!is.na(wind_sector_30deg_mt) & !is.na(wind_sector_30deg_cvt)]
  data.table(
    analysis_scope = scope_name,
    check = c(
      "target_joint_n_reconstructs_complete_wind_rows",
      "target_joint_mean_reconstructs_complete_wind_mean",
      "target_joint_cumulative_reconstructs_complete_wind_sum",
      "full_joint_n_reconstructs_complete_wind_rows",
      "full_joint_mean_reconstructs_complete_wind_mean",
      "full_joint_cumulative_reconstructs_complete_wind_sum"
    ),
    passed = c(
      sum(joint$n_windows) == nrow(both_wind),
      abs(weighted.mean(joint$mean_D_umol_m2_s, joint$n_windows) - mean(both_wind$D_cvt_minus_mt_umol_m2_s)) < 1e-12,
      abs(sum(joint$cumulative_C_gC_m2) - sum(both_wind$C_cvt_minus_mt_gC_m2)) < 1e-10,
      sum(full_joint$n_windows) == nrow(both_wind),
      abs(weighted.mean(full_joint$mean_D_umol_m2_s, full_joint$n_windows) - mean(both_wind$D_cvt_minus_mt_umol_m2_s)) < 1e-12,
      abs(sum(full_joint$cumulative_C_gC_m2) - sum(both_wind$C_cvt_minus_mt_gC_m2)) < 1e-10
    )
  )
}))
stopifnot(all(checks$passed), all(is.finite(sector_results$mean_D_ci_low)), all(is.finite(joint_results$mean_D_ci_low)), all(is.finite(joint_matrix$mean_D_ci_low)))

fwrite(sector_results, file.path(output_dir, "sector_pf_mean_difference_by_mt_cvt_wind_sector_2025.csv"))
fwrite(joint_results, file.path(output_dir, "sector_pf_joint_180_270_mean_difference_2025.csv"))
fwrite(joint_matrix, file.path(output_dir, "sector_pf_joint_mt_cvt_wind_sector_matrix_2025.csv"))
fwrite(agreement_summary, file.path(output_dir, "mt_cvt_wind_direction_agreement_2025.csv"))
fwrite(checks, file.path(output_dir, "wind_direction_mean_recheck_verification_2025.csv"))

figure_dir <- file.path(output_dir, "figures")
dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
sector_levels <- sprintf("%03d-%03d", seq(0, 330, 30), c(seq(30, 330, 30), 360))
site_colours <- c(mt = "#619CFF", cvt = "#F8766D")
theme_project <- function() {
  theme_bw(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "grey92", colour = "grey70"),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold"),
      plot.title.position = "plot"
    )
}
write_plot <- function(plot, stem, width, height) {
  ggsave(file.path(figure_dir, paste0(stem, ".png")), plot, width = width, height = height, units = "in", dpi = 300, bg = "white")
  ggsave(file.path(figure_dir, paste0(stem, ".pdf")), plot, width = width, height = height, units = "in", device = cairo_pdf)
}

sector_plot <- copy(sector_results)
sector_plot[, `:=`(
  group_value = factor(group_value, levels = sector_levels),
  wind_reference = factor(wind_reference, levels = c("mt", "cvt"), labels = c("MT wind reference", "CVT wind reference")),
  analysis_scope = factor(analysis_scope, levels = c("all_common_windows", "daytime_mt_unstable"), labels = c("All common windows", "06:00-18:00, MT unstable"))
)]
p_sector <- ggplot(sector_plot, aes(group_value, mean_D_umol_m2_s, colour = wind_reference, group = wind_reference)) +
  geom_hline(yintercept = 0, colour = "grey45", linewidth = 0.35) +
  geom_line(linewidth = 0.65) +
  geom_errorbar(aes(ymin = mean_D_ci_low, ymax = mean_D_ci_high), width = 0.18, linewidth = 0.4) +
  geom_point(aes(size = n_windows), alpha = 0.9) +
  facet_grid(analysis_scope ~ wind_reference) +
  scale_colour_manual(values = setNames(site_colours, c("MT wind reference", "CVT wind reference"))) +
  scale_size_area(max_size = 5, breaks = c(100, 500, 1000, 2000), name = "Paired windows") +
  labs(
    x = "Tower-specific wind-from sector", y = expression("Mean " * F[CVT] - F[MT] ~ "(" * mu * mol ~ m^{-2} ~ s^{-1} * ")"),
    title = "Paired tower difference across all wind sectors",
    subtitle = "Sector PF; whiskers = 3-day block-bootstrap 95% CI; point size = paired-window count"
  ) +
  theme_project() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "top", legend.title = element_text(face = "bold")) +
  guides(colour = "none")
write_plot(p_sector, "sector_pf_mean_difference_all_wind_sectors_mt_cvt", 13, 7.5)

joint_plot <- merge(
  CJ(analysis_scope = names(scopes), mt_wind_sector = sector_levels, cvt_wind_sector = sector_levels, unique = TRUE),
  joint_matrix,
  by = c("analysis_scope", "mt_wind_sector", "cvt_wind_sector"), all.x = TRUE
)
joint_plot[, `:=`(
  mt_wind_sector = factor(mt_wind_sector, levels = sector_levels),
  cvt_wind_sector = factor(cvt_wind_sector, levels = sector_levels),
  analysis_scope = factor(analysis_scope, levels = c("all_common_windows", "daytime_mt_unstable"), labels = c("All common windows", "06:00-18:00, MT unstable")),
  reliable = !is.na(n_windows) & n_windows >= 30L
)]
joint_plot[, label := fifelse(reliable, sprintf("%.1f\nn=%d", mean_D_umol_m2_s, n_windows), fifelse(is.na(n_windows), "", sprintf("n=%d", n_windows)))]
fill_limit <- max(abs(joint_plot[reliable == TRUE, mean_D_umol_m2_s]))
p_joint <- ggplot(joint_plot, aes(mt_wind_sector, cvt_wind_sector)) +
  geom_tile(fill = "grey92", colour = "white", linewidth = 0.35) +
  geom_tile(data = joint_plot[reliable == TRUE], aes(fill = mean_D_umol_m2_s), colour = "white", linewidth = 0.35) +
  geom_text(aes(label = label, colour = reliable), size = 2.25, lineheight = 0.9) +
  facet_wrap(~ analysis_scope, nrow = 1) +
  scale_fill_gradient2(low = "#3B7EA1", mid = "white", high = "#C95A49", midpoint = 0, limits = c(-fill_limit, fill_limit), name = expression("Mean " * F[CVT] - F[MT])) +
  scale_colour_manual(values = c(`TRUE` = "black", `FALSE` = "grey55"), guide = "none") +
  labs(
    x = "MT wind-from sector", y = "CVT wind-from sector",
    title = "Joint local wind sectors and the paired tower difference",
    subtitle = "Cell text = mean difference and n; grey cells have n < 30 and are not colour-mapped"
  ) +
  theme_project() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), legend.position = "right")
write_plot(p_joint, "sector_pf_joint_mt_cvt_wind_sector_mean_heatmap", 14, 7.8)

message("Wrote wind-direction mean recheck to: ", output_dir)
