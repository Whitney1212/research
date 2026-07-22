#!/usr/bin/env Rscript

# CO2 concentration only: BPF common-mask samples, no wind-method grouping.
suppressPackageStartupMessages({ library(data.table); library(ggplot2) })

source("D:/00 博士阶段/99 Project/06 EA/scripts/lib_fl_pass_core.R", local = .GlobalEnv)

root <- "E:/Dataset_Level1/Flares/Eddy Accumulation"
input_name <- "BPF_0_245_PF8_2ensemble_no_rotation_common_pass_pair_0_245m.csv"
output_name <- "BPF_0_245_common_mask_co2_diurnal_30min_daily_median.csv"

atomic_fwrite <- function(x, path) { tmp <- paste0(path, ".tmp.", Sys.getpid()); on.exit(unlink(tmp), add = TRUE); fwrite(x, tmp, na = ""); if (file.exists(path)) unlink(path); if (!file.rename(tmp, path)) stop("Could not publish ", path, call. = FALSE) }

main <- function() {
  if (identical(commandArgs(trailingOnly = TRUE), "--self-check")) { fl_pass_core_self_check(); stopifnot(median(c(1, 3, 9)) == 3); message("Self-check passed."); return() }
  x <- read_fl_pass_table_local(file.path(root, "tables", input_name))
  need <- c("pass_uid", "pass_mid_time_local", "track_scope", "is_common_valid", "n_co2_common_valid", "co2_mean_ppm")
  if (length(miss <- setdiff(need, names(x)))) stop("Input missing: ", paste(miss, collapse = ", "), call. = FALSE)
  x <- x[track_scope == "0_245_m" & is_common_valid == TRUE & is.finite(co2_mean_ppm) & n_co2_common_valid > 0]
  if (!nrow(x) || anyDuplicated(x$pass_uid)) stop("No valid paired CO2 passes.", call. = FALSE)
  tt <- parse_bundle_time(x$pass_mid_time_local)
  if (anyNA(tt)) stop("Invalid pass timestamps.", call. = FALSE)
  x[, `:=`(date_local = format(tt, "%Y-%m-%d", tz = "Asia/Shanghai"), half_hour_bin = as.integer(format(tt, "%H", tz = "Asia/Shanghai")) + 0.5 * (as.integer(format(tt, "%M", tz = "Asia/Shanghai")) >= 30))]
  x[, half_hour_local := sprintf("%02d:%02d", floor(half_hour_bin), ifelse(half_hour_bin %% 1 == 0, 0, 30))]
  daily <- x[, .(pass_median_ppm = median(co2_mean_ppm), n_passes_day = .N, n_co2_samples_day = sum(n_co2_common_valid)), by = .(date_local, half_hour_bin, half_hour_local)]
  out <- daily[, .(n_dates = .N, n_passes = sum(n_passes_day), n_co2_samples = sum(n_co2_samples_day), median_ppm = median(pass_median_ppm), q25_ppm = as.numeric(quantile(pass_median_ppm, .25, names = FALSE)), q75_ppm = as.numeric(quantile(pass_median_ppm, .75, names = FALSE))), by = .(half_hour_bin, half_hour_local)]
  setorder(out, half_hour_bin)
  stopifnot(nrow(out) > 0L, all(out$n_dates > 0L), all(out$n_passes >= out$n_dates), all(out$n_co2_samples > 0L), all(out$q25_ppm <= out$median_ppm), all(out$median_ppm <= out$q75_ppm))
  tables <- file.path(root, "tables"); figures <- file.path(root, "figures")
  atomic_fwrite(out, file.path(tables, output_name))
  p <- ggplot(out, aes(half_hour_bin, median_ppm)) + geom_ribbon(aes(ymin = q25_ppm, ymax = q75_ppm), fill = "#4E79A7", alpha = .22) + geom_line(colour = "#4E79A7", linewidth = .8) + scale_x_continuous("Local time (Asia/Shanghai)", breaks = seq(0, 24, 3), limits = c(0, 23.5), labels = function(v) sprintf("%02d:00", as.integer(v))) + ylab("CO2 concentration (ppm)") + labs(title = "FL CO2 diurnal concentration under the paired common mask", subtitle = "Same date/half-hour pass median, then median and 25th-75th percentile across dates", caption = "0-245 m only; CO2 finite and diag_irga = 0 within BPF-common valid samples. Concentration diagnostic, not CO2 flux.") + theme_bw(base_size = 11) + theme(panel.grid.minor = element_blank(), plot.title = element_text(face = "bold"))
  ggsave(file.path(figures, "BPF_0_245_common_mask_co2_diurnal.png"), p, width = 9, height = 5, dpi = 300)
  message("Wrote paired-common-mask CO2 daily cycle to: ", root)
}
main()
