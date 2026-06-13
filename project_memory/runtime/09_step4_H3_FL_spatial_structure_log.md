# Step4 H3 FL 空间结构与横谷向局地再分配判断

记录日期：2026-06-08

## 执行范围

本轮按 `next_step/2026-06-04_CO2_event_competing_hypotheses_execution_plan.md` 的 Step 4 口径，检查 H3：`FL 空间结构与横谷向局地再分配` 是否已有足够基础形成结论。检查对象为本地 project memory、Step0-3 事件对齐输出、FL moving-transect anomaly transport 结果和 Step3D 风源轴线诊断。未新增或改写原始计算表，未执行最终机制排序。

## 已有证据

- Step4A 的基础已经具备：`FL_position_time_pass_bin_diagnostics.csv` 覆盖 `193` 个 pass、`25` 个 10 m 位置 bin 和 `4751` 行 pass-position-bin 诊断；`low_n`、`low_updown` 和 `single_sign` 均为 `0`，说明 FL 数据量、位置覆盖和正负 `w` 基础样本条件足以进入空间结构诊断。 [已核验: `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv`] [已核验: `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_anomaly_transport_flag_summary.csv`]
- Step4B 只部分具备：当前 FL pass-bin `F_anom` 主要采用 `c_ref = pass_mean` 的异常参考，已有 `F_anom`、`F_raw`、`w_mean` 和 `co2_mean` 等字段；但尚未按计划同时完成 `event_background` 与 `tower_mean` 两种参考浓度敏感性。 [已核验: `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv`] [推断：基于 Step4B 计划字段与现有表字段对照]
- 空间结构存在但稳定性有限：`all_pass` 与 `non_lambda_extreme` 的 median `F_anom(x)` profile 相关系数为 `0.8209436`，说明剔除极端 lambda 后主要剖面形态仍大体保留；`all_pass` 与 `non_air_imbalance` 的相关系数为 `0.2275509`，说明空气量不平衡筛选会显著改变形态，不能忽略为方法细节。 [已核验: `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_profile_stability_summary.csv`]
- Step3 已把 FL 作为事件窗空间上下文接入。8 个 CVT/MT 事件中，`fl_spatial_signal` 均为 `TRUE`；03-20 和 03-21 更像 `dipole_or_gradient_along_track`，03-22 和 03-23 更像 `sync_all_track` 叠加局地热点。该结果支持“固定塔事件对应的 FL 切面存在空间异质性”，但它仍是 Step3 H1/H2 辅助字段，不是独立的 Step4C 标签表。 [已核验: `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2\outputs\03C_H1_H2_source_diagnostics.csv`] [推断：基于本轮对 `pre_min -> peak2` 窗口的只读汇总]
- Step3D 显示 03-22 和 03-23 的峰前风向为强横谷切面来源，来源侧为 `FL_245m_remote_side`；但 FL `F_anom` 绝对热点与风向来源侧并不总一致，例如 03-22 热点在 `MT_0m_side`，03-23 热点在 `CVT_mid_track`。因此 FL 色带更适合作为空间结构约束，而不能直接当作来源侧或闭合环流判据。 [已核验: `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2\outputs\03D_wind_source_sector_diagnostics.csv`] [已核验: `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2\outputs\wind_source_sector_diagnostics_report.md`]

## 主要缺口

- 尚未生成计划中的 `04A_FL_pass_index.csv`、`04A_FL_position_bin_QC.csv`、`04B_FL_anomaly_transport_by_bin.csv`、`04B_FL_anomaly_transport_by_pass.csv` 和 `04C_FL_spatial_pattern_labels.csv` 这套正式 Step4 交付表；已有表可映射到 04A/04B 的一部分，但不是最终命名和完整字段集。 [推断：基于本轮文件检索与 Step4 计划对照]
- 尚未完成事件级 `FL_shape_class` 的正式规则化标签，例如 `sync_all_track`、`cvt_above_enhanced`、`mt_side_enhanced`、`far_side_enhanced`、`two_ends_strong_middle_weak`、`dipole_structure`、`gradient_along_track` 和 `unclear`。 [推断：基于本轮文件检索与 Step4C 计划对照]
- 尚未完成 `c_ref` 敏感性：当前可用主证据偏向 `pass_mean` 参考，尚不能证明空间形态对 `event_background` 和 `tower_mean` 不敏感。 [推断：基于现有 FL 表字段和 Step4B 判据对照]
- 尚未完成移动方向、风向扇区、`lambda` 与 air-balance 筛选的系统交叉检验。已有结果已经提示 `air_imbalance = 174/193`，该风险足以限制 H3 结论强度。 [已核验: `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_anomaly_transport_flag_summary.csv`]
- `FL` 四个日期在事件主表中没有独立 `t_profile_switch`、`t_pre_min`、`t_peak2` 和 `t_decline_end`，当前 FL 只能作为 CVT/MT 事件窗口的移动切面约束，不能单独证明 FL 自身事件相位。 [已核验: `D:\00 博士阶段\博一\05 Project\com_assemble\outputs\tables\01_event_master_table.csv`]

## 判断

当前已有基础足以形成一个谨慎结论：`FL` 移动切面已经能证明固定塔 CO2 事件并非纯时间序列问题，而是伴随可观测的横向空间异质性；03-22 和 03-23 的风向几何尤其支持把横谷向再分配作为强候选机制或参与机制。

但当前证据还不足以形成强结论：不能写成“已经证明横谷向闭合次级环流导致 CO2 次高峰”。更合适的表述是：`H3` 获得中等支持，当前可作为空间结构约束和候选机制纳入机制排序；若要升级为结论，需要先完成正式 `04C_FL_spatial_pattern_labels.csv`、`c_ref` 敏感性、移动方向/风向扇区稳定性和 air-balance/lambda 风险分组。

## 下一最小步

下一步不应重算全部 FL 高频处理，而应复用现有 `FL_position_time_pass_bin_diagnostics.csv`、`01_event_master_table.csv`、`03C_H1_H2_source_diagnostics.csv` 和 `03D_wind_source_sector_diagnostics.csv`，新增一个窄脚本生成正式 `04C_FL_spatial_pattern_labels.csv`。该表至少应包含 `date`、`site`、`event_window`、`FL_shape_class`、`quality_group`、`n_fl_records`、`n_position_bins`、`hotspot_position_m`、`hotspot_side`、`sync_all_track`、`dipole_or_gradient`、`wind_axis_class`、`wind_source_side`、`shape_wind_consistency`、`method_risk_flag` 和 `H3_support_level`。
