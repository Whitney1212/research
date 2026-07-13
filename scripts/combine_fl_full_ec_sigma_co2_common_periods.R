#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
})

source("D:/00 博士阶段/99 Project/06 EA/scripts/build_fl_full_ec_sigma_co2_common_periods.R", local = .GlobalEnv, encoding = "UTF-8")

tagged_csvs <- c(
  "E:/Dataset_Level1/Flares/EC_ecpreproc/FL_sigma_co2_raw_common_periods_oldcode_0_245.csv",
  "E:/Dataset_Level1/Flares/EC_ecpreproc/FL_sigma_co2_raw_common_periods_batch_b_complete.csv",
  "E:/Dataset_Level1/Flares/EC_ecpreproc/FL_sigma_co2_raw_common_periods_main_complete.csv"
)

main <- function() {
  dt <- rbindlist(lapply(tagged_csvs, fread), use.names = TRUE, fill = TRUE)
  setorder(dt, source_group, timestamp)

  plot_dt <- build_diurnal_plot_data(dt)
  stopifnot(nrow(dt) > 0L, nrow(plot_dt) > 0L)

  fwrite(dt, sigma_csv)
  fwrite(plot_dt, plot_data_csv)
  plot_diurnal(plot_dt)

  source_summary <- dt[, .(
    sigma_rows = .N,
    first_timestamp = first(timestamp),
    last_timestamp = last(timestamp),
    n_dates = uniqueN(date),
    n_hhmm = uniqueN(hhmm),
    sigma_median = stats::median(sigma_co2, na.rm = TRUE)
  ), by = source_group][order(match(source_group, source_levels))]

  writeLines(
    c(
      "FL raw sigma_co2 common-period summary",
      paste0("Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
      paste0("Output root: ", out_root),
      "",
      "Outputs:",
      paste0("- ", sigma_csv),
      paste0("- ", plot_data_csv),
      paste0("- ", plot_png),
      "",
      "Notes:",
      "- Combined from the three source_group-specific raw sigma_co2 tables.",
      "- Common windows within each source_group are the timestamp intersection of no_rotation, dr, and PF_8bin_2ensemble.",
      "- Pooled diurnal plot merges all source_groups and uses median + 25th-75th percentile ribbon.",
      "",
      "Produced sigma rows by source_group:",
      apply(source_summary, 1, function(x) {
        sprintf(
          "- %s: rows=%s, first=%s, last=%s, n_dates=%s, n_hhmm=%s, median_sigma_co2=%.4f",
          x[["source_group"]], x[["sigma_rows"]], x[["first_timestamp"]], x[["last_timestamp"]],
          x[["n_dates"]], x[["n_hhmm"]], as.numeric(x[["sigma_median"]])
        )
      })
    ),
    summary_txt,
    useBytes = TRUE
  )

  message("Wrote: ", sigma_csv)
  message("Wrote: ", plot_data_csv)
  message("Wrote: ", plot_png)
}

if (sys.nframe() == 0L) {
  main()
}
