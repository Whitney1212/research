#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(grid)
})

input_file <- "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/season_weather_groups/season_intensity_summary_2025_by_site.csv"
output_dir <- "E:/Dataset_Level1/MorningPeak/W2_2025_candidates/auto_peak_r_2025/season_weather_groups/figures"

dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

season_levels <- c("spring", "summer", "autumn", "winter")
season_labels <- c(spring = "Spring", summer = "Summer", autumn = "Autumn", winter = "Winter")
site_colors <- c(CVT = "#F8766D", MT = "#619CFF")
intensity_colors <- c(weak = "#9E9E9E", moderate = "#F0A202", strong = "#D1495B")

theme_report <- function(base_size = 12) {
  theme_bw(base_size = base_size) +
    theme(
      legend.position = "top",
      legend.title = element_blank(),
      panel.grid.minor = element_blank(),
      strip.background = element_rect(fill = "grey92", color = "grey70"),
      plot.title = element_text(face = "bold"),
      axis.text.x = element_text(angle = 0, vjust = 0.5)
    )
}

season_dt <- fread(input_file, encoding = "UTF-8")
season_dt <- season_dt[group_type == "season"]
season_dt[, `:=`(
  site = factor(site, levels = c("CVT", "MT")),
  season = factor(group, levels = season_levels, labels = season_labels[season_levels]),
  event_days = as.numeric(event_days),
  weak_days = as.numeric(weak_days),
  moderate_days = as.numeric(moderate_days),
  strong_days = as.numeric(strong_days)
)]

count_plot <- ggplot(season_dt, aes(x = season, y = event_days, fill = site)) +
  geom_col(width = 0.72, color = "grey30", linewidth = 0.25) +
  geom_text(aes(label = event_days), vjust = -0.35, size = 3.6) +
  facet_wrap(~site, ncol = 1) +
  scale_fill_manual(values = site_colors) +
  expand_limits(y = max(season_dt$event_days) * 1.12) +
  labs(
    title = "Morning peak event frequency by season, 2025",
    subtitle = "Season order fixed as Spring, Summer, Autumn, Winter",
    x = NULL,
    y = "Event days"
  ) +
  theme_report() +
  theme(legend.position = "none")

prop_dt <- melt(
  season_dt,
  id.vars = c("site", "season", "event_days"),
  measure.vars = c("weak_days", "moderate_days", "strong_days"),
  variable.name = "intensity",
  value.name = "days"
)
prop_dt[, intensity := factor(
  fifelse(intensity == "weak_days", "weak",
    fifelse(intensity == "moderate_days", "moderate", "strong")
  ),
  levels = c("weak", "moderate", "strong")
)]
prop_dt[, proportion := fifelse(event_days > 0, days / event_days, NA_real_)]

prop_plot <- ggplot(prop_dt, aes(x = season, y = proportion, fill = intensity)) +
  geom_col(width = 0.72, color = "white", linewidth = 0.35) +
  facet_wrap(~site, ncol = 1) +
  scale_fill_manual(values = intensity_colors, labels = c(weak = "Weak", moderate = "Moderate", strong = "Strong")) +
  scale_y_continuous(labels = function(x) paste0(round(x * 100), "%"), limits = c(0, 1)) +
  labs(
    title = "Intensity composition within each season",
    subtitle = "Stacked bars show weak, moderate, and strong shares inside each season",
    x = NULL,
    y = "Share within season"
  ) +
  theme_report()

out_file <- file.path(output_dir, "morning_peak_season_frequency_and_composition_2025.png")
png(out_file, width = 3200, height = 3600, res = 300)
grid.newpage()
pushViewport(viewport(layout = grid.layout(nrow = 2, ncol = 1, heights = unit(c(0.46, 0.54), "npc"))))
print(count_plot, vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
print(prop_plot, vp = viewport(layout.pos.row = 2, layout.pos.col = 1))
dev.off()

summary_out <- season_dt[, .(
  season = as.character(season),
  event_days,
  weak_days,
  moderate_days,
  strong_days
), by = site]
fwrite(summary_out, file.path(output_dir, "morning_peak_season_plot_summary_2025.csv"))

message("Wrote season figures to: ", output_dir)
