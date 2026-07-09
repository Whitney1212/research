# 2026-07-08 固定塔 2025 rotation 敏感性总结图

## 来源

- 这份记录整理自用户在当前对话中提出的要求：用 project memory 里已经固定下来的科研制图方法，可视化总结不同 rotation 方法的差异。[来源: 用户当前对话 2026-07-08]

## 本次绘图口径

- 本轮直接复用 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025` 下已经生成的 standardized rerun 汇总表作图，没有重跑任何年值计算。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_annual_summary_all_methods.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_delta_vs_sector_pf.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_mt_cvt_method_difference_summary.csv]
- 新绘图脚本为 `D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_rotation_sensitivity_standardized_2025.R`。它沿用 project memory 已固定的 REgov 风格：`theme_bw()` 白底、去 `minor grid`、图例顶端、`CVT = #F8766D`、`MT = #619CFF`，并对年值差异图保留 `y = 0` 参考线。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_rotation_sensitivity_standardized_2025.R] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-02_regov_fixed_visual_style.md]

## 输出文件

- 本轮图件统一输出到 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_rotation_sensitivity_annual_nee_by_method.png] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_rotation_sensitivity_observed_fraction_by_method.png] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_rotation_sensitivity_annual_nee_delta_summary.png]
- 当前已生成三张总结图：`fixed_tower_rotation_sensitivity_annual_nee_by_method.png`、`fixed_tower_rotation_sensitivity_observed_fraction_by_method.png` 和 `fixed_tower_rotation_sensitivity_annual_nee_delta_summary.png`。同时也落盘了配套绘图数据 `fixed_tower_rotation_sensitivity_plot_data_absolute.csv`、`fixed_tower_rotation_sensitivity_plot_data_delta.csv` 和说明文件 `fixed_tower_rotation_sensitivity_figures_summary.txt`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_rotation_sensitivity_plot_data_absolute.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_rotation_sensitivity_plot_data_delta.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_rotation_sensitivity_figures_summary.txt]

## 图件内容

- 2026-07-08 同日后续按用户最新要求收窄正式图件范围：三张总结图现在都只保留双塔公共四方法 `no_rotation / dr / global_pf / sector_pf`，不再把 `MT season_sector_pf` 画进主图；`season_sector_pf` 仍保留在数值汇总表里，作为 `MT-only` 补充敏感性而非主比较矩阵成员。[来源: 用户当前对话 2026-07-08] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_rotation_sensitivity_standardized_2025.R] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_rotation_sensitivity_annual_nee_delta_summary.png]

- 年值图 `fixed_tower_rotation_sensitivity_annual_nee_by_method.png` 用双塔分面直接比较各 rotation 方法下的 `annual_nee_estimate_gC_m2`，并把 `MT season-sector PF` 单独标成 MT-only 补充敏感性，不混入双塔公共四方法主比较。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_rotation_sensitivity_annual_nee_by_method.png]
- 覆盖图 `fixed_tower_rotation_sensitivity_observed_fraction_by_method.png` 用整年灰柱表示 `17520` 个半小时窗口，用站点色覆盖 `observed_valid_windows` 的比例，剩余部分隐含为 `gapfilled_windows`，从而把 rotation 方法对“年值来源中多少是观测、多少靠填补”的差异压缩到一张图里。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_rotation_sensitivity_observed_fraction_by_method.png]
- 差异图 `fixed_tower_rotation_sensitivity_annual_nee_delta_summary.png` 上两幅分别给出 `MT` 和 `CVT` 相对 `sector_pf` 的年值偏移，下幅给出公共四方法下的 `MT - CVT` 年值差异，便于直接判断“某种 rotation 是让年值变得更负还是更不负”，以及它是否放大了塔间差异。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_rotation_sensitivity_annual_nee_delta_summary.png]

## 解释边界

- 这些图总结的是 standardized rerun 后的 `EC-only annual NEE estimate / proxy` 对 rotation 方法的敏感性，不应被直接写成最终碳收支或 `NECB` 图件。[来源: 用户当前对话 2026-07-05 至 2026-07-08] [推断：基于当前 W3 口径仍未并入 storage、advection 与更正式年度闭合整理]
