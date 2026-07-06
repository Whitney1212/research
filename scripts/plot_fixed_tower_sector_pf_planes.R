library(data.table)
library(ggplot2)

sites <- list(
  MT = list(
    root = "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF",
    rds = "E:/Dataset_Level1/MT/EC/Flux_ecprecproc_afterPF/MT_flux_sector_pf_rotation_details.rds"
  ),
  CVT = list(
    root = "E:/Dataset_Level1/CVT/EC/PF",
    rds = "E:/Dataset_Level1/CVT/EC/PF/CVT_flux_sector_pf_rotation_details.rds"
  )
)

fit_table <- function(path) {
  fits <- readRDS(path)$sector_fits
  rbindlist(lapply(fits, function(x) {
    b1 <- x$b1
    b2 <- x$b2
    data.table(
      sector = x$sector,
      sector_start_deg = x$sector_start_deg,
      sector_end_deg = x$sector_end_deg,
      sector_center_deg = x$sector_center_deg,
      n_blocks = x$n_blocks,
      fallback_global = isTRUE(x$fallback_global),
      intercept_a = x$b0,
      slope_b_u = b1,
      slope_c_v = b2,
      tilt_deg = atan(sqrt(b1^2 + b2^2)) * 180 / pi,
      slope_vector_uv_to_deg = (atan2(b2, b1) * 180 / pi + 360) %% 360
    )
  }))
}

plot_site <- function(site, cfg) {
  out_dir <- file.path(cfg$root, "figures_sector_pf_planes")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  params <- fit_table(cfg$rds)
  params[, sector_label := sprintf(
    "S%02d  %03.0f-%03.0f deg\nn=%d, tilt=%.1f deg",
    sector, sector_start_deg, sector_end_deg, n_blocks, tilt_deg
  )]
  fwrite(params, file.path(cfg$root, sprintf("%s_sector_pf_plane_parameters.csv", site)))

  grid <- CJ(u = seq(-4, 4, length.out = 70), v = seq(-4, 4, length.out = 70))
  plane <- params[, {
    g <- copy(grid)
    g[, `:=`(
      w_plane = intercept_a + slope_b_u * u + slope_c_v * v,
      sector_label = sector_label
    )]
    g
  }, by = sector]

  lim <- max(abs(plane$w_plane), na.rm = TRUE)
  p_plane <- ggplot(plane, aes(u, v, fill = w_plane)) +
    geom_raster() +
    geom_contour(data = plane, aes(u, v, z = w_plane),
                 inherit.aes = FALSE, breaks = 0, color = "black", linewidth = 0.25) +
    facet_wrap(~ sector_label, ncol = 4) +
    scale_fill_gradient2(low = "#2166AC", mid = "white", high = "#B2182B",
                         midpoint = 0, limits = c(-lim, lim), name = "w plane") +
    coord_equal(expand = FALSE) +
    labs(
      title = sprintf("%s sector planar-fit wind-direction planes", site),
      subtitle = "w_plane = a + b*u + c*v; black contour marks w_plane = 0",
      x = "u block mean",
      y = "v block mean"
    ) +
    theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank(), legend.position = "bottom")
  ggsave(file.path(out_dir, sprintf("%s_sector_pf_plane_facets.png", site)),
         p_plane, width = 13, height = 10, dpi = 300)

  p_tilt <- ggplot(params, aes(sector_center_deg, tilt_deg)) +
    geom_line(color = "grey45") +
    geom_point(aes(size = n_blocks, fill = fallback_global), shape = 21, color = "black") +
    scale_x_continuous(breaks = seq(15, 345, 30), limits = c(0, 360)) +
    scale_fill_manual(values = c(`FALSE` = "white", `TRUE` = "#D95F02"), name = "fallback") +
    scale_size_continuous(name = "n blocks", range = c(2, 7)) +
    labs(
      title = sprintf("%s sector PF tilt by wind direction", site),
      x = "sector center wind direction (deg)",
      y = "tilt angle (deg)"
    ) +
    theme_bw(base_size = 11) +
    theme(panel.grid.minor = element_blank(), legend.position = "bottom")
  ggsave(file.path(out_dir, sprintf("%s_sector_pf_tilt_by_wind_sector.png", site)),
         p_tilt, width = 11, height = 6, dpi = 300)

  writeLines(c(
    sprintf("%s sector PF plane visualization", site),
    sprintf("Generated: %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
    sprintf("Input RDS: %s", cfg$rds),
    sprintf("Output directory: %s", out_dir),
    sprintf("Sector count: %d", nrow(params)),
    sprintf("Fallback sectors: %d", sum(params$fallback_global)),
    "Files:",
    sprintf("- %s_sector_pf_plane_parameters.csv", site),
    sprintf("- figures_sector_pf_planes/%s_sector_pf_plane_facets.png", site),
    sprintf("- figures_sector_pf_planes/%s_sector_pf_tilt_by_wind_sector.png", site)
  ), file.path(cfg$root, sprintf("%s_sector_pf_plane_visualization_summary.txt", site)))
}

invisible(mapply(plot_site, names(sites), sites))
