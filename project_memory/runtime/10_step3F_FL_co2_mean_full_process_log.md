# Step3F FL co2_mean full-process visualization log

记录日期：2026-06-08

## 执行范围

本轮按用户要求，将完整 CO2 事件过程时段内的 FL `co2_mean(position,time)` 像既有 `F_anom` 图一样可视化出来。该输出只用于观察 FL 切面真实 CO2 浓度在完整事件过程中的时空结构，不做 footprint 反演或最终机制排序。

## 本地输出

输出根目录：
`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2`

新增脚本：
- `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2\scripts\plot_FL_co2_mean_full_event_process.R`

新增输出：
- `outputs\03F_FL_co2_mean_full_event_process_profile.csv`
- `outputs\03F_FL_co2_mean_full_event_process_windows.csv`
- `outputs\fig07_FL_co2_mean_full_event_process.png`
- `outputs\FL_co2_mean_full_event_process_report.md`

## 计算口径

- 输入事件节点来自 `outputs\03C_H1_H2_source_diagnostics.csv`。
- 输入 FL 数据来自 `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv`。
- 完整过程窗口按日期定义为 CVT/MT 中最早 `t_sunrise` 到最晚 `t_decline_end`。
- 本次四天窗口均为北京时间 `06:30-12:00`。
- 色带使用真实 position-bin median `co2_mean`，不是 anomaly。
- 图中竖线标注 `t_sunrise`、`t_profile_switch`、`t_pre_min`、`t_peak2`、`t_decline_end`，并用 CVT/MT 颜色区分站点节点。

## 核验结果

- `03F_FL_co2_mean_full_event_process_windows.csv` 共 `4` 行。
- `03F_FL_co2_mean_full_event_process_profile.csv` 共 `1100` 行，即四天各 `11` 个时间 bin、`25` 个位置 bin。
- FL `co2_mean` 范围约为 `427.822-442.447 ppm`。
- 图件 `fig07_FL_co2_mean_full_event_process.png` 已打开检查，渲染正常。

## 当前解释边界

该图适合观察完整事件过程中 FL 切面 CO2 是否在偏南 MT 侧、中段 CVT 上方或偏北 245 m 侧出现高值，以及这些高值相对 profile switch、pre-min、peak2 和 decline end 的时间位置。它仍不能单独确定具体 CO2 源区；需要与风来源侧、CVT/MT 响应先后和 FL `F_anom` 共同解释。
