# 2026-07-01 全量 PF 后通量计算进度与数据位置

## 结论

固定塔全量 PF 后通量当前形成两套可追溯产品：`MT` 采用已筛定的 `sector_pf` 默认口径，并在原全量结果上覆盖了已确认时间读取相位问题的重跑时段；`CVT` 已按同样方法在 `E:\Dataset_Level1\CVT\EC\PF` 完成全量 `sector_pf` 通量计算和均值可视化。 [已核验: project_memory/evidence/verifications/2026-06-30_mt_pf_sector_selection.md] [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf_validation_summary.csv]

## MT 当前产品位置

- 主结果：`E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf.csv`。这是当前 MT after-PF 全量通量主表，默认 PF 口径为 `sector_pf`。 [已核验: E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf.csv]
- 2023-07 至 2023-12 时间读取修复重跑结果：`E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\rerun_202307_202312_after_timefix\MT_flux_sector_pf_202307_202312_after_timefix.csv`；该时段已覆盖回主结果，覆盖前备份为 `E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf_before_202307_202312_timefix.csv`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\overwrite_mt_sector_pf_202307_202312_timefix.R]
- 2024-01 与 2024-03 时间读取修复重跑结果：`E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\rerun_202401_202403_after_timefix\MT_flux_sector_pf_202401_202403_after_timefix.csv`；该时段已覆盖回主结果，覆盖前备份为 `E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf_before_202401_202403_timefix.csv`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\overwrite_mt_sector_pf_202401_202403_timefix.R]
- MT 均值可视化脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\plot_mt_sector_pf_flux_means.R`；图表输出目录：`E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\figures_flux_means`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_mt_sector_pf_flux_means.R]

## MT 时间相位修复边界

2023-07 至 2023-12 的 +8 小时读取相位问题已经确认并修复，修复依据是先把 timestamp 字段字符化再解析，避免 `fread/read_csv` 自动 POSIX 推断造成时区偏移。对应 `ecpreproc` 时间读取修复位于 `D:\00 博士阶段\博一\05 Project\ecpreproc\R\io_dat.R`，并配套调整了 `process_rep_flux.R` 与 `io_output.R` 中的时区保持逻辑。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\diagnose_mt_202307_202312_time_reading.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\io_dat.R]

2024-01 的疑似 +8 小时事件已清除；2024-03 已重跑并修正明显的 +8 小时窗口，但诊断中仍保留 2 个来自连续重叠文件段首边界启发式的 `suspect_plus8_shift` 提醒。当前不应继续盲目平移 2024-03 的剩余 08:00 行，应在后续按原始文件边界和实际窗口覆盖复核后再决定。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\diagnose_mt_202401_202403_phase.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\fix_mt_202403_remaining_shift_windows.R]

## CVT 当前产品位置

- 全量 sector PF 运行脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\run_cvt_full_sector_pf_flux.R`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\run_cvt_full_sector_pf_flux.R]
- 主结果：`E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf.csv`。验证摘要显示 `21447` 行，时间范围为 `2024-11-01 00:30` 至 `2026-05-10 15:00`，`duplicate_timestamp_count=0`，`pf_schemes=sector_pf`。 [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf_validation_summary.csv]
- 运行汇总：`E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf_run_summary.csv`；本轮使用 `534` 个 CVT Time_Series 原始文件，运行时段记录为 2026-06-30 17:31:32 至 2026-07-01 00:24:57。 [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf_run_summary.csv]
- 扇区 PF 汇总：`E:\Dataset_Level1\CVT\EC\PF\CVT_sector_pf_sector_summary.csv`；12 个风向扇区均完成拟合，未触发 global fallback。 [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_sector_pf_sector_summary.csv]
- 其他配套输出：`CVT_flux_sector_pf_config.rds`、`CVT_flux_sector_pf_rotation_details.rds`、`EC_Output_stream_UnknownSite_20241101_20260510.csv`。 [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf_run_summary.csv]

## CVT 可视化位置

- 可视化脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\plot_cvt_sector_pf_flux_means.R`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_cvt_sector_pf_flux_means.R]
- 图表目录：`E:\Dataset_Level1\CVT\EC\PF\figures_flux_means`，包含 overall means、日变化均值和 `co2_flux/H/LE/u_star` 的 month-hour 热图。 [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_sector_pf_flux_mean_visualization_summary.txt]
- 均值表：`CVT_sector_pf_flux_mean_overall.csv`、`CVT_sector_pf_flux_mean_by_hour.csv`、`CVT_sector_pf_flux_mean_by_month_hour.csv`。整体均值为 `co2_flux=-1.623643`、`h2o_flux=0.847745`、`H=19.627368`、`LE=37.211826`、`Tau=-0.052047`、`u_star=0.253825`。 [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_sector_pf_flux_mean_overall.csv]

## 当前解释边界

`sector_pf` 是当前固定塔全量 after-PF 通量的默认交付口径；`season_sector_pf` 对 MT 可作为敏感性实验保留，但不是默认处理。CVT 本轮只完成 `sector_pf` 全量计算与均值可视化，尚未做与 `global_pf/season_sector_pf` 的三组配对差异分析。 [已核验: project_memory/evidence/verifications/2026-06-30_mt_pf_sector_selection.md] [推断: 基于 CVT 本轮运行内容与 MT 方案选择边界整理]
