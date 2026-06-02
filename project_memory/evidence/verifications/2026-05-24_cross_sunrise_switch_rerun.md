# 2026-05-24 跨日出廓线切换判据重跑

## 本次目的

本次按用户要求，将廓线结构切换判据从严格 `06:30-11:00` 改为跨日出规则，允许在 `05:30-11:00` 内寻找首次 `top_bottom_delta` 负转非负，并重跑时间线对齐和机制可视化。 [来源: 用户当前对话 2026-05-24]

## 脚本改动

- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\diagnose_secondary_peak_0306_0325.R` 已新增 `profile_switch_start <- 5.5` 和 `profile_switch_end <- 11.0`，并在 `process_contrast.csv` 中输出新的 `switch_time_0530_1100`。旧的 `switch_time_0630_1100` 仍保留，用于追溯严格日出后判据。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\diagnose_secondary_peak_0306_0325.R]
- 同一脚本中 `minutes_switch_to_peak` 已改为基于 `switch_time_0530_1100` 计算。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\diagnose_secondary_peak_0306_0325.R]
- 同一脚本的 MT EddyPro 输入文件名已从缺失的 `eddypro_2_full_output_2026-05-08T105431_adv.csv` 改为当前实际存在的 `eddypro_1_full_output_2026-05-09T170627_adv.csv`，否则上游诊断脚本无法完整重跑。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\DATA\MT_EC\eddypro_1_full_output_2026-05-09T170627_adv.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\diagnose_secondary_peak_0306_0325.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R` 已改为优先读取 `switch_time_0530_1100`，如果旧输出没有该列才回退到 `switch_time_0630_1100`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R]

## 已重跑脚本

已用 `D:\softwares\R-4.3.3\bin\Rscript.exe` 依次重跑以下脚本：

- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\diagnose_secondary_peak_0306_0325.R`，重新生成 `D:\00 博士阶段\博一\05 Project\com_260507\OUTPUT\tables\process_contrast.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\OUTPUT\tables\process_contrast.csv]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R`，重新生成全天 30 min 对齐表和全天图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\all_day_timeline_alignment_30min.csv]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R`，重新生成 `04:00-12:00` 事件窗口对齐表、事件关键时间表和事件图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\event_key_times_0400_1200_30min.csv]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R`，重新生成机制图和 `mechanism_evidence_summary_0400_1200_30min.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\mechanism_evidence_summary_0400_1200_30min.csv]

## 重跑后的关键结果

- `process_contrast.csv` 中 `MT 2025-03-21` 的 `switch_time_0530_1100 = 2025-03-21 06:00:00`，而旧严格字段 `switch_time_0630_1100` 仍为空；`minutes_switch_to_peak = 210`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\OUTPUT\tables\process_contrast.csv]
- `event_key_times_0400_1200_30min.csv` 中 `MT 2025-03-21` 的 `profile_switch_time = 2025-03-21 06:00:00`，`secondary_peak_time = 2025-03-21 09:30:00`，`profile_switch_time_to_peak_min = 210`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\event_key_times_0400_1200_30min.csv]
- 重跑后的机制证据矩阵中，`profile switch` 已从 7 个已识别事件更新为 `8` 个事件，并且全部为 `before_peak`。`pre-min` 仍为 `8/8 before_peak`；`wind max` 仍为 `4 before_peak / 4 after_peak`；`raw w max` 和 `F_air max` 均为 `1 before_peak / 3 near_peak / 4 after_peak`；`F_conc max` 为 `2 before_peak / 5 near_peak / 1 after_peak`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\mechanism_evidence_summary_0400_1200_30min.csv]

## 当前解释更新

这次重跑把 `MT 2025-03-21` 从“严格日出后判据未识别”更新为“跨日出判据识别到 `06:00` 切换”。因此当前机制链条更强：`CVT/MT` 的 8 个事件都支持“廓线结构切换早于 CO2 次高峰”，而 raw `w` 极值、`F_air` 极值和风速最大值仍不能作为稳定峰前触发因子。 [推断: 基于本次重跑输出和机制证据矩阵整理]
