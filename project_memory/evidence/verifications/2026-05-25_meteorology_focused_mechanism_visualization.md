# 2026-05-25 机制可视化改为气象过程主线

## 来源

- 用户在当前对话中确认：不需要继续分解通量，按优先建议保留气象要素、廓线结构和标准 EC 通量参照进行制图。[来源: 用户当前对话 2026-05-25]
- 本轮直接修改并运行本地脚本：
  - `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R`
  - `D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R`

## 脚本变更

- `align_ea_event_timelines.R` 的事件关键时刻表不再输出 `F_air`、`F_conc`、`F_total`、`F_turb` 等通量分解判据；新增 `u_abs_max_time`、`v_abs_max_time`、`F_EC_abs_max_time`、`sigma_w_max_time`、`ustar_max_time` 和 `H_abs_max_time` 及其相对 CO2 次高峰的分钟差。[已核验: `event_key_times_0400_1200_30min.csv` 表头]
- `visualize_ea_timeline_alignment.R` 的机制主图变量改为 `co2_mean_profile`、`top_bottom_delta`、`wind_speed_mean`、`u_mean_valid`、`v_mean_valid`、`w_mean_window`、`F_EC_cov`、`sigma_w`、`ustar` 和 `H`；另外新增全天和事件窗口的 `sonic_flow_from_deg` 风向图。[已核验: `figures_mechanism\all_day_wind_direction_30min.png`; `figures_mechanism\wind_direction_event_window_0400_1200_30min.png`]
- FL 位置热图保留 `w_mean` 与 `F_mean_anom_bin_valid`，不再生成 `F_total` 位置热图；输出目录中上一轮遗留的两个 `F_total` PNG 已删除，以避免误读。[已核验: `figures_mechanism` 下无 `*F_total*.png`]

## 重跑与输出

- 使用 `D:\softwares\R-4.3.3\bin\Rscript.exe` 重跑：
  - `align_ea_event_timelines.R "D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment" "30min"`
  - `visualize_ea_timeline_alignment.R "D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment" "30min"`
- 新机制图输出在 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism`，包括全天机制堆叠图、全天相位叠加图、事件窗口相位叠加图、全天/事件风向图、lead-lag 图、机制证据矩阵、CO2 廓线结构图、FL `w_mean` 和 `F_mean_anom` 的事件/全天位置热图。[已核验: 本轮脚本运行日志与 PNG 文件时间戳]

## 结果核验

- `event_key_times_0400_1200_30min.csv` 的表头核验结果为 `decomposition_cols=none`，即不再包含 `F_air`、`F_conc`、`F_total` 或 `F_turb` 列。[已核验: PowerShell 表头检查]
- `MT 2025-03-21` 的结构切换仍为 `2025-03-21 06:00:00`，CO2 次高峰为 `2025-03-21 09:30:00`，`profile_switch_time_to_peak_min = 210`，说明本轮制图变量调整没有改变上一轮跨日出判据结果。[已核验: `event_key_times_0400_1200_30min.csv`]
- 新证据汇总 `mechanism_evidence_summary_0400_1200_30min.csv` 的指标为：`profile switch`、`pre-min`、`wind max`、`u abs max`、`v abs max`、`raw w max`、`EC flux max`、`sigma_w max`、`u* max`、`H abs max`。[已核验: PowerShell 分组统计]

## 当前解释边界

- 稳定峰前链条仍是 `profile switch` 与 `pre-min`：二者均为 `8/8 before_peak`。[已核验: `mechanism_evidence_summary_0400_1200_30min.csv`]
- 气象极值不应直接写成稳定峰前触发因子：`wind max` 为 `4 before / 4 after`，`raw w max` 为 `1 before / 3 near / 4 after`，`sigma_w max` 多为峰后，`u* max` 和 `H abs max` 也更多出现在峰后或近峰。[已核验: `mechanism_evidence_summary_0400_1200_30min.csv`]
- `F_EC_cov` 现在只作为标准 EC CO2 通量参照保留，不再与 `F_air/F_conc` 分解项并列解释；其绝对峰值在 8 个 CVT/MT 事件中表现为 `2 before / 5 near / 1 after`。[已核验: `mechanism_evidence_summary_0400_1200_30min.csv`]

## 2026-05-25 追加：风场图改用修正后地理风

- 按用户要求，机制可视化中的风向/风场图已改用 `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\fl_motion_correction\wind_geo_fl_motion_corrected_30min.csv`，即已经完成 `north_offset` 地理坐标统一并对 FL 小车速度做矢量修正的三站水平风结果。[来源: 用户当前对话 2026-05-25] [已核验: `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R`]
- `all_day_timeline_alignment_30min.csv` 现在新增并保留 corrected wind 字段：`wind_from_geo_motion_corrected_deg`、`wind_speed_geo_motion_corrected`、`U_east_motion_corrected`、`U_north_motion_corrected` 等；同时保留原声学坐标风字段备份，如 `wind_speed_mean_sonic`、`u_mean_valid_sonic`、`v_mean_valid_sonic` 和 `sonic_flow_from_deg_sonic`。[已核验: `all_day_timeline_alignment_30min.csv` 三站 corrected wind 字段均为 192 个有限值]
- 机制图新增 `all_day_wind_direction_sector_30min.png`、`wind_direction_sector_event_window_0400_1200_30min.png` 和 `wind_vector_event_window_0400_1200_30min.png`；风向色带用 corrected geographic wind-from sector，箭头图用 corrected `U_east/U_north`。[已核验: `figures_mechanism` 输出图件]
