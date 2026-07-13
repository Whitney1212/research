# 2026-07-10 固定塔无 qc/flag9 口径下的 observed-only 与 gapfilled-only 诊断

## 来源

- 这份记录整理自用户在当前对话中的要求：去掉 `qc_co2 <= 1` 和 `flag9_co2 <= 3` 后，再计算一次两塔同一时间都有有效观测窗口情况下的 NEE，以及 `gapfilled-only` 塔间差异。[来源: 用户当前对话 2026-07-10]

## 口径

- 本轮没有重跑原始通量，也没有重算 gapfilling；直接复用已落盘的 `rotation_sensitivity_standardized_2025_no_qc_no_flag9` 结果。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\rotation_sensitivity_standardized_2025_no_qc_no_flag9_annual_summary_all_methods.csv]
- 无 `qc/flag9` 口径只关闭 `qc_co2 <= 1` 和 `flag9_co2 <= 3` 两道筛选，夜间 `u*` 过滤仍保留。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\rotation_sensitivity_standardized_2025_no_qc_no_flag9_annual_summary_all_methods.csv]
- 本轮给两个既有诊断脚本增加 `--scenario=no_qc_no_flag9` 参数；默认 strict 行为不变。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_observed_window_nee_2025.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_gapfilled_only_difference_2025.R]
- observed-only 诊断仍按 `MT/CVT` 同一半小时都 `valid_final == TRUE` 保留窗口；gapfilled-only 诊断仍按用户附件定义使用 `CVT - MT` 方向，并以 `fill_method != "observed_valid"` 判定 gapfilled。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee\fixed_tower_common_observed_window_nee_by_tower_method_2025.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]

## 输出

- observed-only 输出目录：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee]
- gapfilled-only 输出目录：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference]
- observed-only 每塔每方法表：`fixed_tower_common_observed_window_nee_by_tower_method_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee\fixed_tower_common_observed_window_nee_by_tower_method_2025.csv]
- observed-only 塔间差异对照表：`fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- gapfilled-only 组别汇总：`fixed_tower_gapfilled_only_difference_pair_group_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]
- gapfilled-only 填补类型分解：`fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv]

## observed-only 结果

- 关闭 `qc/flag9` 后，共同有效观测窗口大幅增加：`no_rotation = 10148` 个窗口，占全年 `57.92%`；`dr = 10122`，占 `57.77%`；`global_pf = 9952`，占 `56.80%`；`sector_pf = 9810`，占 `55.99%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- 共同窗口直接累计的 `MT - CVT` 差异为：`no_rotation = -220.45`、`dr = -462.62`、`global_pf = -312.46`、`sector_pf = -298.34 gC m^-2`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- 共同窗口均值外推到全年后的 `MT - CVT` 差异为：`no_rotation = -380.59`、`dr = -800.75`、`global_pf = -550.07`、`sector_pf = -532.82 gC m^-2`；对应 full gapfilled 年差异为 `-358.00`、`-722.56`、`-553.89`、`-437.46 gC m^-2`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]
- 共同窗口外推差异与 full gapfilled 年差异的绝对偏离比例为：`no_rotation = 6.31%`、`dr = 10.82%`、`global_pf = 0.69%`、`sector_pf = 21.80%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\common_observed_window_nee\fixed_tower_common_observed_window_mt_cvt_difference_vs_gapfilled_2025.csv]

## gapfilled-only 结果

- 无 `qc/flag9` 口径下，`any_gapfilled` 对全年 `CVT - MT` 差异的贡献下降为：`no_rotation = 137.55 gC m^-2`，占 `38.42%`；`dr = 259.94`，占 `35.97%`；`global_pf = 241.44`，占 `43.59%`；`sector_pf = 139.12`，占 `31.80%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]
- `both_observed` 成为主要贡献：`no_rotation = 220.45 gC m^-2`，占 `61.58%`；`dr = 462.62`，占 `64.03%`；`global_pf = 312.46`，占 `56.41%`；`sector_pf = 298.34`，占 `68.20%`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_pair_group_2025.csv]
- gapfilled-only 内主要贡献不再单一由双塔长缺口 climatology 主导；多个方法中 `MT_gapfilled_only` 且 `MT=other_tower_same_timestamp_regression|long_gap, CVT=observed` 是最大或接近最大的单项：`no_rotation = 49.71`、`dr = 95.36`、`global_pf = 72.34`、`sector_pf = 58.32 gC m^-2`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\gapfilled_only_difference\fixed_tower_gapfilled_only_difference_by_fill_type_2025.csv]

## 解释

- 与 strict 口径相比，关闭 `qc_co2/flag9_co2` 后，两塔共同 observed 覆盖从约 `10-14%` 提高到约 `56-58%`，塔间年差异更多由共同观测窗口解释，而不是由 gapfilled-only 窗口主导。[推断：基于本轮 no-QC 诊断与 2026-07-10 strict 诊断对比]
- 这说明 strict 口径下 gapfilled-only 贡献偏高，很大程度来自 QC/flag9 筛选导致的共同观测覆盖下降；无 `qc/flag9` 后，gapfill 仍有贡献，但不再是全年塔间差异的主要来源。[推断：基于 `any_gapfilled` 占比从 strict 的 `76.67-88.64%` 降至 no-QC 的 `31.80-43.59%`]

## 核验

- 已核验 no-QC observed-only 明细配对行数与汇总共同窗口数一致；gapfilled-only fill-type 分解按方法求和可精确回到 `any_gapfilled`；`all_windows` 求和可精确回到 no-QC annual `CVT - MT` 差异。[已核验: 本轮 R 自检]
