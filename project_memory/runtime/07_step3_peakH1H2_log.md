# Step3 peak H1/H2 progress log

记录日期：2026-06-08

## 执行范围

本轮执行 `2026-06-04_CO2_event_competing_hypotheses_execution_plan.md` 中 Step3 的 H1/H2 证据整理，只围绕次高峰事件的储存/廓线转换先导与外来风输入先导建立透明诊断表和有效图件。未执行 H3-H6、FL 空间形态机制分类、rotation 风险评分或最终机制排序。

## 本地输出根目录

`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2`

脚本：
- `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2\scripts\build_peakH1H2_step3.R`

主要输出：
- `outputs\03A_storage_profile_transition.csv`
- `outputs\03B_wind_advection_event_table.csv`
- `outputs\03C_H1_H2_source_diagnostics.csv`
- `outputs\fig01_H1_profile_storage_timing.png`
- `outputs\fig02_H2_wind_shift_vs_co2_rise.png`
- `outputs\fig03_FL_Fanom_event_window_context.png`
- `outputs\fig04_H1_H2_evidence_matrix.png`
- `outputs\run_log.md`
- `outputs\missing_or_partial_inputs.md`

## 关键输入和复用来源

- Step0-2 事件主表：`D:\00 博士阶段\博一\05 Project\com_assemble\outputs\tables\01_event_master_table.csv`
- 事件对齐 30 min 表：`D:\00 博士阶段\博一\05 Project\com_assemble\outputs\tables\02_event_aligned_30min.csv`
- 全日 30 min 时间线：`D:\00 博士阶段\博一\05 Project\com_assemble\outputs\intermediate\all_day_timeline_alignment_30min.csv`
- 既有 profile 结构摘要：`D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\profile_structure_summary.csv`
- 可复用脚本逻辑：`D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnose_secondary_peak_events_0320_0323.R`

## 已修正口径

- Step3 中 `column_co2_proxy` 已改名为 `profile_mean_co2`。
- 廓线 CO2 不再引入 `ec_c_mean` 代理；以廓线源数据计算 profile mean。
- 廓线顶底差保留为 `top_bottom_delta`，用于表示 profile 上下层差异。
- `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R` 已修正时间键标准化：对 `time_start` 四舍五入到整秒，解决 raw-w 亚秒时间戳导致 profile 合并断裂的问题。
- 修正后 `all_day_timeline_alignment_30min.csv` 在 2025-03-20 至 2025-03-23、CVT/MT、05:00-13:00 的 `profile_mean_co2` 和 `top_bottom_delta` 均为 17/17 个 30 min 点。

## Step3 透明规则

H1 储存/廓线转换证据：
- `profile_switch_before_peak`：profile switch 早于 peak2。
- `pre_min_before_peak`：pre-min 早于 peak2。
- `profile_structure_change_signal`：peak 前后 profile 顶底差变化达到阈值。
- `profile_mean_co2_change_signal`：peak 前后 profile mean CO2 变化达到阈值。

H2 外来风输入证据：
- `wind_shift_before_peak`：peak 前已有风向/风区变化。
- `wind_speed_ramp_before_peak`：peak 前风速增强。
- `sector_change_before_peak`：peak 前 corrected wind sector 改变。
- `fl_spatial_signal`：事件窗内 FL `F_anom` 有可见时空异常信号。

当前解释口径：
- H1 为强证据：所有 8 个 CVT/MT 事件均表现为廓线转换先于 peak2，并伴随 profile 结构或均值变化。
- H2 为伴随/前置输入证据：多数事件在 peak 前存在风速增强、风区变化或 FL 异常，但不能单独解释为最终来源。
- 目前最稳妥表述是：次高峰事件均有廓线转换/储存释放先导，同时常伴随外来风输入或风场调整。

## 当前事件标记

- 2025-03-20 CVT：`profile_transition_led_with_early_wind_ramp`
- 2025-03-20 MT：`profile_transition_led_with_strong_prepeak_advection_context`
- 2025-03-21 CVT：`profile_transition_led_with_early_wind_ramp`
- 2025-03-21 MT：`profile_transition_led_with_strong_prepeak_advection_context`
- 2025-03-22 CVT：`profile_transition_led_with_strong_prepeak_advection_context`
- 2025-03-22 MT：`profile_transition_led_with_strong_prepeak_advection_context`
- 2025-03-23 CVT：`profile_transition_led_with_strong_prepeak_advection_context`
- 2025-03-23 MT：`profile_transition_led_with_weak_FL_context`

## Wind direction 图解释

`fig02_H2_wind_shift_vs_co2_rise.png` 中 wind direction 面板的纵坐标不是风速，也不是空间坐标，而是人为设置的显示层：
- CVT：`y = 0.70`
- MT：`y = 0.30`

箭头方向表示 transport/flow-to 方向，计算方式为：
- `flow_to_deg = (wind_dir + 180) %% 360`
- 横向偏移按 `sin(flow_to_deg)` 映射到时间轴附近。
- 纵向偏移按 `cos(flow_to_deg)` 映射到显示层附近。

因此该图只能看同一时间段 CVT/MT 风向箭头是否旋转、是否转向谷轴或横谷方向，不能把纵坐标解读为风速大小。风速大小需看 wind speed 面板或 `03B_wind_advection_event_table.csv`。

结合用户补充地形信息：
- 45°/225° 可近似看作谷轴方向。
- 135°/315° 可近似看作横谷切面方向。
- 当前 CVT 夜间/峰前风向更像沿谷轴或斜交谷轴调整，暂不能仅凭风向箭头判定为某一侧坡面来源。

## 下一步最小补充

若继续判定“这个风从哪里来”，建议新增 Step3D：
- 将 wind-from 方向换算为相对谷轴角、相对横谷角。
- 对每个事件比较 CVT 与 MT 的峰前响应先后、风区变化和 FL `F_anom` 异常位置。
- 输出 `03D_wind_source_sector_diagnostics.csv`，但仍不做最终机制排序。
