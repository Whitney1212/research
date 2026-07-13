# 2026-07-10 固定塔共同有效观测窗口 NEE 诊断

## 来源

- 这份记录整理自用户在当前对话中的要求：计算一份两固定塔只保留两塔同一时间都有有效观测窗口情况下的 NEE，用来验证塔间差异是否由 gapfill 主导。[来源: 用户当前对话 2026-07-10]

## 口径

- 本轮没有重跑原始通量，也没有重算 full-year gapfilling；直接读取 `rotation_sensitivity_standardized_2025` 下已经生成的严格口径 per-method `30min_gapfilled.csv`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_observed_window_nee_2025.R]
- 只处理双塔公共四方法：`no_rotation / dr / global_pf / sector_pf`；未纳入 `MT season_sector_pf`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_observed_window_nee_2025.R]
- 对每个 rotation 方法，先按 `method + ts_key` 配对 MT 与 CVT，再只保留 `MT valid_final == TRUE` 且 `CVT valid_final == TRUE` 的同一半小时窗口。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_30min_pairs_2025.csv]
- 半小时碳通量积分沿用现有 W3 年值脚本：`co2_flux * 1800 * 12e-6`，单位为 `gC m^-2`；`common_observed_nee_sum_gC_m2` 是共同有效窗口直接累计量，`common_observed_nee_annualized_gC_m2` 是把共同窗口平均半小时积分线性外推到 `17520` 个窗口的诊断量，不替代正式 annual NEE。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\estimate_fixed_tower_nee_2025.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_observed_window_nee_2025.R]

## 输出

- 新脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_observed_window_nee_2025.R`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_observed_window_nee_2025.R]
- 输出目录：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee]
- 每塔每方法共同窗口汇总：`fixed_tower_common_observed_window_nee_by_tower_method_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_nee_by_tower_method_2025.csv]
- 塔间差异与 full gapfilled 年差异对照：`fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- 共同有效半小时配对明细：`fixed_tower_common_observed_window_30min_pairs_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_30min_pairs_2025.csv]
- 摘要：`fixed_tower_common_observed_window_nee_2025_summary.txt`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_nee_2025_summary.txt]

## 主要结果

- 共同有效观测窗口很少：`no_rotation = 1804` 个窗口，占全年 `10.30%`；`dr = 2362`，占 `13.48%`；`global_pf = 2373`，占 `13.54%`；`sector_pf = 2296`，占 `13.11%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- 共同有效窗口直接累计的 `MT - CVT` 差异分别为：`no_rotation = -59.89`、`dr = -118.14`、`global_pf = -89.27`、`sector_pf = -90.14 gC m^-2`；这些值只覆盖共同有效窗口本身，不是全年值。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- 共同窗口均值外推到全年后的 `MT - CVT` 差异分别为：`no_rotation = -581.64`、`dr = -876.31`、`global_pf = -659.10`、`sector_pf = -687.86 gC m^-2`；原 full gapfilled 年差异分别为 `-527.21`、`-627.01`、`-693.47`、`-386.37 gC m^-2`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- 共同窗口外推差异与 full gapfilled 年差异的绝对偏离占 full gapfilled 差异的比例为：`no_rotation = 10.32%`、`dr = 39.76%`、`global_pf = 4.96%`、`sector_pf = 78.03%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]

## 解释

- 这个诊断不支持“所有塔间差异主要由 gapfill 主导”的简单判断：`no_rotation` 和 `global_pf` 中，共同有效观测窗口外推后的塔间差异已经接近 full gapfilled 年差异，说明观测到的同窗通量差异本身足以解释大部分塔间差异。[推断：基于共同窗口外推差异与 full gapfilled 年差异的直接对比]
- `dr` 和尤其 `sector_pf` 中，full gapfilled 年差异与共同窗口外推差异偏离较大，说明 gapfill、非共同观测时段组成或共同窗口样本偏置会明显改变塔间差异。[推断：基于 `39.76%` 与 `78.03%` 的偏离比例]
- 因共同有效窗口只覆盖全年约 `10-14%`，共同窗口外推量只能作为 gapfill 主导性诊断，不应替代 W3 当前正式的 full-year gapfilled annual NEE。
