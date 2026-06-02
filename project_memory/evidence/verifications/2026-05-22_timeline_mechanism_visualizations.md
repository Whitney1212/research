# 2026-05-22 时间线机制可视化核验

## 本次目标

本次在已经生成的时间线对齐表基础上，新增机制判断用途的可视化脚本和图件。目标不是重新计算 EC 或 raw-w 结果，而是把 `04:00-12:00` 事件窗口中的 CO2 次高峰、廓线结构、水平风、raw-w 空气量项、浓度异常项和 FL 切面空间结构用统一风格展示出来。 [来源: 用户当前对话 2026-05-22]

## 新增脚本

- 新增 `D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R`。该脚本读取 `EA_timeline_alignment` 下的事件窗口对齐表、事件关键时间表和 FL 位置分箱表，输出机制相位叠加图、相对次高峰 lead-lag 图、机制证据矩阵、CO2 廓线结构图，以及 FL 位置-时间热图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R]

## 输出图件

输出目录为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism`。本次已生成：

- `all_day_mechanism_timeline_stack_30min.png`
- `all_day_mechanism_phase_overlay_30min.png`
- `all_day_FL_position_w_mean_heatmap_30min.png`
- `all_day_FL_position_F_total_heatmap_30min.png`
- `all_day_FL_position_F_mean_anom_heatmap_30min.png`
- `mechanism_phase_overlay_0400_1200_30min.png`
- `event_lead_lag_relative_to_peak_0400_1200_30min.png`
- `mechanism_evidence_lead_lag_heatmap_0400_1200_30min.png`
- `co2_profile_structure_event_window_0400_1200_30min.png`
- `FL_position_w_mean_heatmap_0400_1200_30min.png`
- `FL_position_F_total_heatmap_0400_1200_30min.png`
- `FL_position_F_mean_anom_heatmap_0400_1200_30min.png`

并生成机制摘要表 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\mechanism_evidence_summary_0400_1200_30min.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism]

## 方法边界

- 可视化延续当前项目风格：`theme_bw` 白底、灰色分面条、顶部图例、固定站点颜色 `CVT=#F8766D`、`FL=#00BA38`、`MT=#619CFF`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R]
- 全天可视化已补入同一脚本，与事件窗口图共用同一套风格和时间解析函数。全天图用于先检查全日背景，事件窗口图用于机制排序。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism\all_day_mechanism_timeline_stack_30min.png]
- lead-lag 图中 `0 min` 是各站点自己的 CO2 次高峰，负值表示发生在次高峰之前。FL 没有 CO2 廓线次高峰，因此不进入该图。 [推断: 基于 FL 无廓线事件和脚本处理整理]
- 机制证据矩阵使用 `*_to_peak_min` 的原始口径，正值表示该诊断发生在次高峰之前，红色为峰前，蓝色为峰后；脚本已修正该颜色语义。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R]
- FL 图仍作为切面空间形态证据使用，不作为第三个平均 CO2 廓线或 AP 站点解释。 [来源: 用户当前对话 2026-05-21] [推断: 基于当前脚本输出整理]
