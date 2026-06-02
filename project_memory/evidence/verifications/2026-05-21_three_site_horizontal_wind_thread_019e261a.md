# 2026-05-21 三站水平风 thread 与计算核验

## 来源

- 这份记录整理自 Codex thread `019e261a-fe4c-7602-b59e-5d4f48e5ddbf`，主题为 `水平风`，thread 更新时间为 `2026-05-14T10:50:32.2974361Z`。该 thread 讨论并推进了 `CVT`、`MT` 和移动平台 `FL` 三处水平风比较、north_offset 坐标统一、`FL` 小车速度矢量修正、风向/风速图件和时间相位解释。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf]
- 该 thread 的结果曾被整理到 `D:\00 博士阶段\99 Project\06 EA\project_memory`，但此前没有写入当前工作目录下的 `project_memory`。本次只补入当前 EA/raw-w 解释会反复用到的最小必要信息。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-05-21-three-site-horizontal-wind-calculation.md] [推断：基于当前 `project_memory` 未检索到该 thread ID 整理]

## 计算目录与输入口径

- 三站水平风比较相关脚本和输出固定在 `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal`，其中脚本位于 `COMPUTE`，结果位于 `OUTPUT`。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\01_basic_highfreq_wind_qc_3sites.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\basic_highfreq_wind_qc\qc_file_summary.csv]
- 当前窗口覆盖 `2025-03-20` 到 `2025-03-23`，站点为 `CVT`、`MT` 和移动平台 `FL`；计算使用三处原始高频 `Ux/Uy/Uz`，并对三种聚合尺度输出 `1min`、`5min` 和 `30min` 水平风结果。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\basic_highfreq_wind_qc\qc_file_summary.csv]
- 基础高频风 QC 后，`CVT` 和 `FL` 四天全部记录通过；`MT` 只出现极少量非数值剔除。该结果说明当前水平风图件不是由大量 QC 缺口支撑的弱证据。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\basic_highfreq_wind_qc\qc_file_summary.csv]

## north_offset 与 FL 小车运动修正

- 当前三站水平风不能直接比较原始 `Ux/Uy`，因为三个 sonic 朝向不同。thread 中记录的 north_offset 为 `FL = 210°`、`MT = 300°`、`CVT = 125°`；当前坐标统一脚本采用 `effective_wind_from_offset_deg = (recorded_north_offset_deg + 90) %% 360`，对应 `CVT 125° -> 215°`、`FL 210° -> 300°`、`MT 300° -> 030°`。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\north_offset_coordinates\validation_summary_30min.csv]
- 坐标统一后与 EddyPro 30 min 风向对照，风向差异中位绝对值为 `CVT = 1.786°`、`FL = 0.820°`、`MT = 0.837°`，说明当前水平 yaw 统一口径与 EddyPro 风向基本闭合。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\north_offset_coordinates\validation_summary_30min.csv]
- `FL` 小车运动修正不是从风速标量中直接减去 `13.7 cm/s`，而是在地理坐标统一后按轨道方向做矢量修正。当前口径使用 `U_measured = U_true - V_cart`，因此以 `U_true = U_measured + V_cart` 加回小车速度矢量；轨道南到北方向方位角使用 `129.551°`，名义小车速度使用 `0.137 m s^-1`。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\fl_motion_correction\run_notes.txt]
- 30 min 窗口中，`FL` 平均绝对小车速度约 `0.1281 m s^-1`，运动修正造成的风向中位绝对变化约 `1.495°`。这说明修正是必要的坐标口径处理，但它通常不足以单独制造大幅风向转变。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\fl_motion_correction\fl_motion_correction_summary.csv] [推断：基于当前修正量级整理]

## 图件与时间口径

- 四天风向分面图由 `06_visualize_faceted_wind_direction_by_window.R` 生成，变量为 `wind_from_geo_motion_corrected_deg`；四天水平风速分面图由 `07_visualize_faceted_wind_speed_by_window.R` 生成，变量为 `vector_mean_Uh_motion_corrected`。两类图均包含 `1min`、`5min` 和 `30min` 三个窗口，并用虚线标出本地时间 `06:30`。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\06_visualize_faceted_wind_direction_by_window.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\07_visualize_faceted_wind_speed_by_window.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_direction_faceted_by_window\faceted_wind_direction_figure_manifest.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_speed_faceted_by_window\faceted_wind_speed_figure_manifest.csv]
- 当前所有 `1min`、`5min` 和 `30min` 聚合时间戳使用窗口起点，即 `window_time = floor_date(TIMESTAMP, unit)`。因此 `30min` 图上 `06:30` 的点代表 `06:30-07:00`，若按窗口中心解释应接近 `06:45`。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\01_basic_highfreq_wind_qc_3sites.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_speed_faceted_by_window\run_notes.txt]

## 与当前 raw-w / EA 解释的关系

- 推断：这个 thread 已经算了水平风，而且不是只列需求；它完成了三处高频水平风 QC、north_offset 坐标统一、`FL` 小车速度矢量修正、风向图和风速图。它可以作为当前 raw-w 总输送解释中的风场背景证据。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal]
- 推断：这组结果适合用于判断 `CVT`、`MT` 和 `FL` 水平风是否在某些时段升高、风向是否同步转变，以及谷底 `CVT` 与南侧高地/移动平台 `MT/FL` 是否存在耦合或解耦。它不能单独替代正式 EA/TEA、垂直平流或水平平流计算。 [来源: thread 019e261a-fe4c-7602-b59e-5d4f48e5ddbf] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-05-21-three-site-horizontal-wind-calculation.md]
