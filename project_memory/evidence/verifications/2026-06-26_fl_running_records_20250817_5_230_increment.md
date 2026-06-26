# 2026-06-26 FL 运行记录 2025 特殊轨道 5-230 m 增量补入

## 本次目标

按用户最新要求，只针对 `2025-08-17` 至 `2025-10-01` 这一段位置编码约 `0-230 m` 的 FL 运行记录，使用增量脚本临时将完整单程轨道端点改为 `5-230 m`，补入当前 `230417_260622` 基础交付。正式保留增量后的 `records` 和 `passes` 文件，不保留中间批处理目录。

## 输入与口径

- 统一运行记录基础文件：`E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv`。
- 该基础文件已经包含用户列出的三份原始运行记录：`fbox_hdata_20250817-20250901.csv`、`fbox_hdata_20250901-20250917.csv`、`fbox_hdata_20250917-20251001.csv`；因此本次不再重建 records，只更新 pass 层。
- 增量窗口：`2025-08-17 00:00:00` 至 `2025-10-01 00:00:00`，脚本内部使用 `2 h` lookback/lookahead 抽取边界。
- 特殊轨道端点：`track_south_m = 5`，`track_north_m = 230`。该口径只用于这一时间段的完整单程覆盖修复，不自动推广为全局 FL 轨道定义，也不直接替代 `PF_8bin` 的 `5-240 m` 参数口径。
- EC 可用性仍使用 key-complete 筛选：候选单程内 `Ux/Uy/Uz/CO2/TA_1_1_1/PA` 六列存在且有限，并且至少一个时钟分钟有 `>=300` 行完整 10 Hz 数据；风速、诊断码和标量物理范围 QC 留给后续 EC/PF/质量守恒计算。

## 执行命令

```powershell
Rscript 'E:\FL_pre\scripts\fl_update_records_02_complete_passes_and_ec_availability.R' `
  --unified-csv='E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv' `
  --master-dir='E:\Dataset_Level0\Flares\running_time\passes' `
  --raw-root='E:\Dataset_Level0\Flares\EC' `
  --raw-index-csv='E:\Dataset_Level0\Flares\running_time\passes\ec_raw_files_full_index.csv' `
  --start='2025-08-17 00:00:00' `
  --end='2025-10-01 00:00:00' `
  --track-south-m=5 `
  --track-north-m=230 `
  --plot-title='FL Complete Pass Coverage' `
  --plot-subtitle='Full base plus 2025-08-17 to 2025-10-01 increment using 5-230 m track bounds' `
  --plot-caption='EC availability = key-complete rows; wind-speed, diagnostic-code, and scalar physical-range QC deferred.'
```

## 结果

- 增量候选完整单程：`1074`。
- 增量严格完整且 EC key-complete 可用单程：`1065`，其中 `fw = 537`、`bw = 528`。
- 增量严格单程时间范围：`2025-08-23 10:50:16` 至 `2025-09-30 15:53:28`。
- 合并后严格完整且 EC key-complete 可用单程总数：`2933`，其中 `fw = 1481`、`bw = 1452`。
- 合并后严格单程时间范围：`2023-06-22 11:56:56` 至 `2026-06-04 16:58:07`。
- 重复单程键检查：按 `start_time_local/end_time_local/direction` 检查为 `0`。

## 当前保留交付

- `records`：`E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv` 和 `fl_records_230417_260622_source_summary.csv`。
- `passes`：`fl_complete_passes_strict.csv`、`fl_complete_pass_candidates_all.csv`、`fl_complete_pass_coverage_daily.csv`、`fl_complete_pass_coverage_timeline.png`、`fl_complete_passes_incremental_manifest.txt`、`ec_raw_files_full_index.csv`。
- `passes\incremental_batches` 中间目录已清理；当前 `passes` 目录只保留发布文件和下次增量所需基础文件。

## 解释边界

这次只更新 FL 运行记录完整单程覆盖集合与覆盖图，不重算 `PF_8bin`、FL 高频通量或质量守恒结果。如果后续要把这段 `5-230 m` 特殊轨道单程纳入 PF、通量或质量守恒，应显式记录分时段轨道口径，并检查是否需要重建对应 PF 参数。
