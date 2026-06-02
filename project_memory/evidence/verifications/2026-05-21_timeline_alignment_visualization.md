# 2026-05-21 时间线对齐与可视化核验

## 本次目标

本次按照用户要求，将现有 30 min 主口径结果先做全天对齐，再做 `04:00-12:00` 事件窗口对齐。事件窗口固定 `06:30` 为日出参考线；不引入 H2O 相关分析；FL 不要求 AP 数据，因为 FL 当前没有 AP 输入。 [来源: 用户当前对话 2026-05-21]

## 新增脚本

- 新增 `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R`。该脚本读取既有 CO2 廓线诊断、raw-w 气团指标、raw-w 风场背景、标准 EC `w'c'` 和 FL 位置分箱结果，输出全天 30 min 对齐总表、长表、FL 位置表和三张总览图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R]
- 新增 `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R`。该脚本读取全天对齐结果，筛选 `04:00-12:00`，生成事件窗口对齐表、事件关键时间表、FL 事件窗口位置表，以及事件窗口 stack 图、标准化叠加图、关键时间对齐图和 FL 事件热图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R]

## 输出与验证

- 输出目录为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment]
- 全天对齐表 `all_day_timeline_alignment_30min.csv` 共有 `576` 行，即 `2025-03-20` 到 `2025-03-23` 四天、三个站点、每天 48 个 30 min 窗口。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\all_day_alignment_qc_30min.csv]
- FL 全天位置分箱表 `fl_position_alignment_all_day_30min.csv` 共有 `1889` 行。各日分别为 `2025-03-20:458`、`2025-03-21:471`、`2025-03-22:480`、`2025-03-23:480`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\all_day_alignment_qc_30min.csv]
- 事件窗口对齐表 `event_window_timeline_alignment_0400_1200_30min.csv` 共有 `202` 行，其中 `CVT:67`、`FL:68`、`MT:67`。少量不足满格的窗口来自既有 QC/覆盖率结果，不是新脚本合并错误。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\event_alignment_qc_0400_1200_30min.csv]
- 事件关键时间表 `event_key_times_0400_1200_30min.csv` 已生成。`CVT/MT` 含日出、廓线切换、前期低点、次高峰、峰后低点和诊断极值时间；`FL` 只保留日出和 raw-w/风场极值时间，不伪造廓线或 AP 事件。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\event_key_times_0400_1200_30min.csv]

## 方法边界

- 本轮默认使用 `30min` 主口径，因为 CO2 廓线诊断、标准 EC 和次高峰事件表均是 30 min 时间标签。脚本保留 `window_label` 参数，后续如只检查 raw-w 短时结构，可再以 `5min` 运行，但 CO2 廓线事件仍需按 30 min 解释。 [推断: 基于当前输入表时间分辨率整理]
- 本轮不做 H2O 相关分析，也不把 FL 缺失 AP 作为待补缺口。 [来源: 用户当前对话 2026-05-21]
- FL 位置分箱表中的 ISO `Z` 时间戳已在新脚本中按 UTC 解析并转换到 `Asia/Shanghai`，避免 FL 切面热图发生 8 小时时间错位。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R]

## 下一步含义

现在“建立时间线对齐表”这一步已经完成。下一步应基于 `event_key_times_0400_1200_30min.csv` 和事件窗口图，逐日比较风场增强或转向、廓线结构切换、CO2 前期低点、次高峰、raw-w 空气量项和 FL 切面形态之间的先后顺序。 [推断: 基于本次输出和既定机制归因目标整理]
