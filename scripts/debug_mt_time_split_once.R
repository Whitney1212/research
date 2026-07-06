source("D:/00 博士阶段/博一/05 Project/com_rotation/scripts/lib_common_rotation.R", encoding = "UTF-8")
cfg <- list(project_dir = tempdir(), package_dir = "D:/00 博士阶段/博一/05 Project/ecpreproc", tz = "Asia/Shanghai")
load_ecpreproc(cfg)
f <- "E:/Dataset_Level0/MT/EC/202307172100-202403300930/TOA5_14893.Time_Series_151_2024_03_15_0000.dat"
x <- read_toa5(f, tz = cfg$tz)
cat("read head:", format(head(x$time, 1), "%Y-%m-%d %H:%M:%OS", tz = cfg$tz), "\n")
cat("read tzone:", attr(x$time, "tzone"), "\n")
attr(x$time, "tzone") <- cfg$tz
bounds <- local({
  tt <- x$time[!is.na(x$time)]
  start <- as.POSIXct(floor(as.numeric(min(tt)) / 1800) * 1800, origin = "1970-01-01", tz = cfg$tz)
  end <- as.POSIXct(ceiling(as.numeric(max(tt)) / 1800) * 1800, origin = "1970-01-01", tz = cfg$tz)
  list(start = start, end = end)
})
cat("bounds:", format(bounds$start, "%Y-%m-%d %H:%M:%OS", tz = cfg$tz), format(bounds$end, "%Y-%m-%d %H:%M:%OS", tz = cfg$tz), "\n")
blocks <- split_data_into_blocks(x, interval = "30 min", start_time = bounds$start, end_time = bounds$end, return = "list", drop_empty = TRUE)
cat("first block first:", format(blocks[[1]]$time[1], "%Y-%m-%d %H:%M:%OS", tz = cfg$tz), "\n")
cat("first block attr:", attr(blocks[[1]]$time, "tzone"), "\n")
