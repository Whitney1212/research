# Step4 H3 正式 FL 空间形态标签表执行记录

记录日期：2026-06-08

## 执行范围

本轮按用户要求，将 Step4 H3：`FL 空间结构与横谷向局地再分配` 的整理计算输出到 `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH3`。本轮只复用既有 Step0-3 事件节点、Step3/Step3D 诊断和 FL moving-transect pass-bin 结果，不回到原始 FL 高频数据重算。 [来源: 用户当前对话 2026-06-08]

## 新增脚本与输出

- 新增脚本：`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH3\scripts\build_peakH3_step4_labels.R`。 [已核验: 本轮运行成功]
- 核心标签表：`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH3\outputs\04C_FL_spatial_pattern_labels.csv`，共 `300` 行。 [已核验: 本轮运行输出]
- 主判据标签表：`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH3\outputs\04C_FL_spatial_pattern_labels_primary.csv`，共 `8` 行；主判据行为 `event_window = pre_min_to_peak2`、`c_ref_type = event_background`、`quality_group = ok_non_lambda_extreme`。 [已核验: 本轮运行输出]
- bin 级底表：`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH3\outputs\04B_FL_anomaly_transport_by_bin_event_windows.csv`，共 `7500` 行。 [已核验: 本轮运行输出]
- 汇总表与报告：`04C_FL_spatial_pattern_summary.csv`、`step4_H3_report.md`、`run_log.md`。 [已核验: 本轮运行输出]
- 图件：`fig01_FL_H3_shape_label_heatmap.png` 和 `fig02_FL_H3_primary_event_profiles.png`。 [已核验: 本轮视觉检查]

## 主判据结果

- `2025-03-20 CVT/MT`：主标签均为 `two_ends_strong_middle_weak`；H3 支持为弱到中等，其中 `MT` 行存在 `c_ref_sensitive`，方法风险为高。 [已核验: `04C_FL_spatial_pattern_labels_primary.csv`]
- `2025-03-21 CVT/MT`：主标签均为 `two_ends_strong_middle_weak`；H3 支持为弱到中等，`c_ref` 形态稳定，但空气量不平衡风险仍为高。 [已核验: `04C_FL_spatial_pattern_labels_primary.csv`]
- `2025-03-22 CVT/MT`：主标签均为 `dipole_structure`；H3 支持为 `moderate_support_method_limited`，风向为 `cross_transect_axis`，热点与风向来源侧不一致，更像横向再分配候选而非简单来源侧输入。 [已核验: `04C_FL_spatial_pattern_labels_primary.csv`]
- `2025-03-23 CVT`：主标签为 `dipole_structure`；H3 支持为 `moderate_support_method_limited`。 [已核验: `04C_FL_spatial_pattern_labels_primary.csv`]
- `2025-03-23 MT`：主标签为 `sync_all_track`；H3 支持为弱到中等，更偏整轨道同步结构，不宜单独作为闭合横谷环流证据。 [已核验: `04C_FL_spatial_pattern_labels_primary.csv`]

## 当前判断

正式标签表支持将 H3 写入机制排序表，但应表述为：`FL` 提供了事件级横向空间结构约束，03-22 和 03-23 尤其支持横谷向再分配作为候选/参与机制。由于 `air_imbalance_high` 普遍存在，且部分事件存在 `moving_direction_sensitive` 或 `c_ref_sensitive`，当前仍不应升级为“已证明闭合次级环流主导次高峰”的强结论。 [推断：基于本轮标签表、Step3D 风源轴线诊断和既有 FL 方法风险整理]
