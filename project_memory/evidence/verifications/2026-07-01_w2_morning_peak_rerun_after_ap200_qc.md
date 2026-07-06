# W2 晨间 peak：AP200 QC 后固定塔事件重跑记录（2026-07-01）

## 来源

- 用户要求：根据 AP200 QC 后的数据位置，重跑并覆盖 W2 2025 晨间 peak 事件数据和幅度出图。 [来源: 用户当前对话 2026-07-01]
- AP200 QC 输出入口沿用月批脚本结果：`D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R]

## 本轮输入

- `MT` AP200 QC 后 cycle 文件：`E:\Dataset_Level1\MT\AP\20240704-20260622\MT_AP_profile_cycle_after_qc_20240704_20260622.csv`
- `CVT` AP200 QC 后 cycle 文件：`E:\Dataset_Level1\CVT\AP\20240704-20260622\CVT_AP_profile_cycle_after_qc_20241112_20260622.csv`
- 事件日出仍沿用既有短波口径：`CVT_MET` 的 `SW_in_Avg` 聚合为 30 min `SW_in`，首个 `SW_in >= 20 W m^-2` 作为 `sunrise_ref_sw`。 [已核验: project_memory/evidence/verifications/2026-06-17_cvt_sw_in_sunrise_reference.md]

## 脚本与覆盖输出

- 新增 AP200 QC 基础表脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\build_morning_peak_foundation_from_ap_qc_2025.R`
- 更新事件分类脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\build_morning_peak_event_types_2025.R`，优先读取 `fixed_tower_ap_profile_2025_30min.csv` 生成 AP 廓线代理量；若该文件不存在才回退到 Level0 廓线读取。
- 事件检测脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R`
- 幅度出图脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\plot_morning_peak_amplitude_2025.R`

本轮覆盖输出：

- `E:\Dataset_Level1\MorningPeak\W2_2025_foundation\fixed_tower_ap_2025_30min.csv`
- `E:\Dataset_Level1\MorningPeak\W2_2025_foundation\fixed_tower_ap_2025_daily_qc.csv`
- `E:\Dataset_Level1\MorningPeak\W2_2025_foundation\fixed_tower_ap_profile_2025_30min.csv`
- `E:\Dataset_Level1\MorningPeak\W2_2025_foundation\fixed_tower_ap_2025_qc_foundation_summary.csv`
- `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025`
- `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\figures\amplitude`

## 时间写出问题与修正

首次把 AP200 QC 基础表写出时，`data.table::fwrite()` 将 `POSIXct` 时间写为 UTC ISO 格式，导致事件检测阶段把窗口时间错读，并把事件判为 `missing_pre_window`。已在 `build_morning_peak_foundation_from_ap_qc_2025.R` 中把 `window_start` 显式写为本地时间字符串 `YYYY-MM-DD HH:MM:SS`，随后重新覆盖基础表、事件表和幅度图。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\build_morning_peak_foundation_from_ap_qc_2025.R]

## AP200 QC 后基础覆盖

- `CVT`：`full_day = 338`，`partial_day = 10`，`no_data = 17`
- `MT`：`full_day = 347`，`partial_day = 3`，`no_data = 15`

推断：6 月 29/30 日基于较早 Level0 解析口径记录的站点日数和候选数量应保留为历史初筛结果；后续 W2 2025 事件数据和图件应优先引用本条 AP200 QC 后基线。

## AP200 QC 后事件检测结果

按 `amp_ppm = peak_window max CO2 - pre_min_window min CO2`：

- `CVT`：`usable_days = 336`，`peak_by_diff_days = 204`，`event_5ppm_days = 86`，`event_10ppm_days = 42`，`mean_amp = 3.058517`，`median_amp = 1.008392`
- `MT`：`usable_days = 338`，`peak_by_diff_days = 213`，`event_5ppm_days = 91`，`event_10ppm_days = 47`，`mean_amp = 3.332162`，`median_amp = 1.363345`
- 双塔全年汇总：`total_days = 365`，`peak_by_diff_any = 240`，`peak_by_diff_both = 177`，`event_5ppm_any = 105`，`event_5ppm_both = 72`，`event_10ppm_any = 55`，`event_10ppm_both = 34`

## AP200 QC 后事件分类结果

`10 ppm` 长表分类：

- `CVT_only = 7`
- `MT_only = 11`
- `both = 34`
- `none = 266`
- `CVT_observed_MT_unknown = 1`
- `MT_observed_CVT_unknown = 2`
- `insufficient_data = 44`

`10 ppm both` lead-lag：`near_sync = 29`，`unclear = 5`。

`5 ppm` 长表分类：

- `CVT_only = 12`
- `MT_only = 15`
- `both = 72`
- `none = 219`
- `CVT_observed_MT_unknown = 2`
- `MT_observed_CVT_unknown = 4`
- `insufficient_data = 41`

`5 ppm both` lead-lag：`near_sync = 58`，`unclear = 14`。

`5 ppm -> 10 ppm` 交叉升级矩阵只纳入双塔均可判定日，`n_paired = 318`。主要格点为：

- `none -> none = 219`
- `CVT_only -> none = 12`
- `MT_only -> none = 11`
- `MT_only -> MT_only = 4`
- `both -> none = 24`
- `both -> CVT_only = 7`
- `both -> MT_only = 7`
- `both -> both = 34`

## 验证

- `build_morning_peak_event_types_2025.R --self-test` 通过。
- `git diff --check` 对本轮新增/修改脚本通过。
- 事件重跑完成后，`event_class_5to10_upgrade_matrix_2025.csv` 的 `sum_days = 318` 与双塔可判定日 `n_paired = 318` 一致。
- 幅度分布图和超越曲线已按 AP200 QC 后基础表覆盖更新到 `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\figures\amplitude`。

