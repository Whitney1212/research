# 2026-07-10 固定塔 gapfilled-only 塔间差异分解

## 来源

- 这份记录整理自用户在当前对话中的要求：计算 `gapfilled-only 差异`，即只统计至少一个塔的最终 NEE 值来自 gapfilling 的时间窗对塔间累计差异的贡献，并按填补类型分解。[来源: 用户当前对话 2026-07-10]

## 口径

- 本轮没有重跑原始通量，也没有重算 full-year gapfilling；直接读取 `rotation_sensitivity_standardized_2025` 下已有严格口径 per-method `30min_gapfilled.csv`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_gapfilled_only_difference_2025.R]
- 只处理双塔公共四方法：`no_rotation / dr / global_pf / sector_pf`；未纳入 `MT season_sector_pf`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_gapfilled_only_difference_2025.R]
- 差异方向按用户附件定义为 `CVT - MT`，与部分此前诊断中的 `MT - CVT` 相反。[来源: 用户附件 pasted-text.txt] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_gapfilled_only_difference_2025.R]
- 每个半小时的差异贡献直接使用既有明细中的 `total_component_gC_m2_cvt - total_component_gC_m2_mt`；因此换算系数与当前 W3 年值脚本保持一致，即 `co2_flux * 1800 * 12e-6`，而不是另行改成 `12.011e-6`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\estimate_fixed_tower_nee_2025.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_gapfilled_only_difference_2025.R]
- gapfilled 判定为 `fill_method != "observed_valid"`；窗口组别包括 `both_observed`、`MT_gapfilled_only`、`CVT_gapfilled_only`、`both_gapfilled`、`any_gapfilled` 和 `all_windows`。填补类型用每塔 `fill_source_group|gap_scope` 组合表示。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv]

## 输出

- 新脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_gapfilled_only_difference_2025.R`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_gapfilled_only_difference_2025.R]
- 输出目录：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference]
- 窗口组别汇总：`fixed_tower_gapfilled_only_difference_pair_group_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]
- 填补类型分解：`fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv]
- 30 min 明细：`fixed_tower_gapfilled_only_difference_30min_detail_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_30min_detail_2025.csv]
- 摘要：`fixed_tower_gapfilled_only_difference_2025_summary.txt`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_2025_summary.txt]

## 主要结果

- `any_gapfilled` 对全年 `CVT - MT` 年差异的贡献很高：`no_rotation = 467.32 gC m^-2`，占 `88.64%`；`dr = 508.87`，占 `81.16%`；`global_pf = 604.20`，占 `87.13%`；`sector_pf = 296.22`，占 `76.67%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]
- `both_observed` 仍贡献正差异，但占比较小：`no_rotation = 59.89 gC m^-2`，占 `11.36%`；`dr = 118.14`，占 `18.84%`；`global_pf = 89.27`，占 `12.87%`；`sector_pf = 90.14`，占 `23.33%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]
- 在 gapfilled-only 内，最大单项通常来自 `both_gapfilled` 且两塔均为 `same_tower_multiyear_climatology|long_gap`：`no_rotation = 214.63 gC m^-2`，占全年差异 `40.7%`；`dr = 245.09`，占 `39.1%`；`global_pf = 346.71`，占 `50.0%`；`sector_pf = 129.33`，占 `33.5%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv]
- 单塔 gapfilled 也有贡献：`MT_gapfilled_only` 占全年差异约 `14.90% / 18.75% / 16.25% / 24.26%`，`CVT_gapfilled_only` 占约 `20.06% / 10.83% / 10.54% / 4.23%`，对应方法顺序为 `no_rotation / dr / global_pf / sector_pf`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]

## 解释

- 这份 gapfilled-only 分解说明，当前 full-year 塔间差异在四个 rotation 方法下都高度依赖 gapfilled 相关窗口，尤其是两塔都处于长缺口并由同塔多年份 climatology 填补的窗口。[推断：基于 `any_gapfilled` 占比和 fill-type 分解]
- 但这不等于 gapfilling 算法本身一定“制造”了全部差异：gapfilled-only 窗口覆盖了非共同观测时段、长缺口时段和填补模型共同作用；需要结合共同有效观测窗口诊断一起解释。[推断：基于 2026-07-10 common-observed-window 诊断与本表的差异]

## 核验

- 已核验 fill-type 分解按方法求和可精确回到 `any_gapfilled`；`all_windows` 求和可精确回到原 strict full gapfilled annual `CVT - MT` 差异。[已核验: 本轮 R 自检]
