# 2026-05-24 MT 2025-03-21 廓线结构切换复核

## 复核目的

本次按用户要求检查 `04 Lee` 项目记忆，并核对当前 `com_260507` 输出，确认 `MT 2025-03-21` 的廓线结构切换时间是否真的缺失。结论是：切换并非不存在，而是发生在 `06:00`，早于当前脚本使用的 `06:30` 日出参考线，因此没有进入 `switch_time_0630_1100` 字段。 [来源: 用户当前对话 2026-05-24]

## 核验证据

- `04 Lee` 项目记忆明确记录了这个边界情况：`MT 2025-03-21` 在 `05:30` 的 `top_bottom_delta = -0.54567`，到 `06:00` 已经变为 `0.109645`，而同日短波日出 proxy 为 `06:30`；因此在“日出后首次负转非负”的旧判据下被记为 `switch_found = FALSE`。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\04_open_questions.md] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\evidence\threads\2026-04-28-gradient-switch.md]
- 旧四天窗口原始表也支持同一判断：`gradient_switch_window_sunrise_sunset.csv` 中 `MT 2025-03-21` 从 `05:30` 的负值 `-0.545670000000001` 转为 `06:00` 的正值 `0.109644999999998`，并在 `06:30` 达到 `1.067105`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260401\com_0401\diagnostics_0320_0323\gradient_switch_window_sunrise_sunset.csv]
- 当前多日诊断表 `diagnostic_30min_with_ec.csv` 复现了这个序列：`05:30` 为 `-0.545670000000001`，`06:00` 为 `0.109644999999998`，`06:30` 为 `1.067105`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\OUTPUT\tables\diagnostic_30min_with_ec.csv]
- 当前 `process_contrast.csv` 中 `MT 2025-03-21` 的 `switch_time_0630_1100` 为空，但 `delta_at_0630 = 1.067105`、`delta_at_pre_peak_min = 0.608534999999995`、`delta_at_secondary_peak = 0.274234999999996`，说明从 `06:30` 到次高峰期间廓线结构已处于非负状态。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\OUTPUT\tables\process_contrast.csv]
- 当前事件关键时间表 `event_key_times_0400_1200_30min.csv` 中 `MT 2025-03-21` 的 `profile_switch_time` 为空，是由 `switch_time_0630_1100` 继承而来，不代表图上没有结构切换。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\event_key_times_0400_1200_30min.csv] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R]

## 当前解释

`MT 2025-03-21` 应解释为一个“日出前后边界切换”事件：按严格 `06:30-11:00` 判据，它没有日出后首次负转非负；但按图形判读或 `05:30-11:00`/跨日出判据，它的廓线结构切换时间是 `2025-03-21 06:00:00`。该时刻早于 `08:00` 的 CO2 前期低点，也早于 `09:30` 的 CO2 次高峰约 `210 min`。 [推断: 基于本次本地核验和现有事件时间表整理]

因此，后续机制排序中不应再写成“`2025-03-21 MT` 结构切换时间缺失”。更稳妥的表述是：当前生成表因判据窗口从 `06:30` 开始而漏记该切换；若采用跨日出判据，`MT 2025-03-21` 也支持“廓线结构切换早于次高峰”的链条。 [推断: 基于 `04 Lee` 项目记忆、旧四天窗口和当前多日输出综合整理]
