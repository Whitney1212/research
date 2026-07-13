# 2026-07-10 固定塔 10:00-18:00 年累计塔间差异贡献

## 来源

- 这份记录整理自用户在当前对话中的要求：计算 `10-18点` 的年累计贡献，判断该时段解释全年塔间差异的比例。[来源: 用户当前对话 2026-07-10]

## 口径

- 本轮没有重跑原始通量，也没有重算 gapfilling；直接复用已经落盘的 strict 与无 `qc/flag9` 两套 per-method `30min_gapfilled.csv`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_10_18_difference_contribution_2025.R]
- 时间窗定义为 `10:00 <= local half-hour < 18:00`，即每天 `16` 个半小时窗口，全年 `5840` 个窗口。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_all_scenarios_2025.csv]
- 差异方向沿用最近 gapfilled-only 诊断和用户附件定义，为 `CVT - MT`；每半小时贡献直接使用 `total_component_gC_m2_cvt - total_component_gC_m2_mt`，与当前 W3 年值积分口径一致。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\estimate_fixed_tower_nee_2025.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_10_18_difference_contribution_2025.R]
- 同时输出总贡献表和 `both_observed / MT_gapfilled_only / CVT_gapfilled_only / both_gapfilled` 的时段内分解表。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_by_pair_group_all_scenarios_2025.csv]

## 输出

- 新脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_10_18_difference_contribution_2025.R`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_10_18_difference_contribution_2025.R]
- strict 输出目录：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\time_window_difference`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\time_window_difference]
- 无 `qc/flag9` 输出目录：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\time_window_difference`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\time_window_difference]
- 双口径合并总表：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_all_scenarios_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_all_scenarios_2025.csv]
- 双口径合并 pair-group 分解表：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_by_pair_group_all_scenarios_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_by_pair_group_all_scenarios_2025.csv]

## 主要结果

- strict 口径下，`10:00-18:00` 对全年 `CVT - MT` 差异的解释比例为：`no_rotation = 65.90%`、`dr = 66.91%`、`global_pf = 44.59%`、`sector_pf = 86.36%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_all_scenarios_2025.csv]
- 无 `qc/flag9` 口径下，`10:00-18:00` 对全年 `CVT - MT` 差异的解释比例为：`no_rotation = 85.95%`、`dr = 70.66%`、`global_pf = 62.85%`、`sector_pf = 94.77%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_all_scenarios_2025.csv]
- strict 口径中，`10:00-18:00` 的贡献仍混合了 observed 和 gapfilled 窗口；例如 `sector_pf` 的时段贡献 `333.66 gC m^-2` 中，`both_observed = 94.00`、`MT_gapfilled_only = 37.18`、`CVT_gapfilled_only = 70.72`、`both_gapfilled = 131.76 gC m^-2`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_by_pair_group_all_scenarios_2025.csv]
- 无 `qc/flag9` 口径中，`10:00-18:00` 的贡献主要由 `both_observed` 主导；例如 `sector_pf` 的时段贡献 `414.58 gC m^-2` 中，`both_observed = 326.25 gC m^-2`，已占全年差异 `74.6%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_10_18_annual_difference_contribution_by_pair_group_all_scenarios_2025.csv]

## 解释

- `10:00-18:00` 是解释全年塔间差异的核心时段，但解释强度依赖 rotation 方法和 QC 口径；`global_pf` 在 strict 口径下最低，只解释 `44.59%`，说明非 10-18 时段仍贡献过半。[推断：基于总贡献表直接对比]
- 去掉 `qc/flag9` 后，`10:00-18:00` 的解释比例整体上升，尤其 `no_rotation` 和 `sector_pf` 接近或超过 `85%`，说明白天共同观测窗口本身已经解释大部分全年塔间差异。[推断：基于 no-QC 总贡献表和 pair-group 分解]

## 核验

- 已核验 `10:00-18:00` 与非该时段贡献加总可精确回到全年 `CVT - MT` 差异；pair-group 分解加总可精确回到该时段总贡献。[已核验: 本轮 R 自检]
