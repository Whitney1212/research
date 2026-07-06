# 2026-07-06 FL F_adv raw/PF 分组日变化图补充覆盖范围色带

## 来源

本记录整理自当前回合对本地文件的核验与脚本输出，涉及 `E:\FL_MASSBALANCE\202308` 几何放宽批次和 `E:\FL_MASSBALANCE` 全量批次两套 raw/PF `F_adv` 分组日变化图。 [已核验: E:\FL_MASSBALANCE\202308\raw_pf_fadv_grouped_with_bands_manifest.csv] [已核验: E:\FL_MASSBALANCE\full_raw_pf_fadv_grouped_with_bands_manifest.csv]

## 202308 几何放宽批次

新增脚本 `E:\FL_MASSBALANCE\202308\plot_raw_pf_fadv_grouped_with_bands.R`，一次性重绘 raw、raw detrended、PF、PF detrended 四张 `F_adv` 按 `lambda_closure_class` 分组的半小时日变化图。该脚本使用 mixed-sign 中的 `broad_closed` 与 `numerically_closed`，先按单程与半小时 bin 的重叠时长加权，再按日期等权平均；色带为每个半小时、每个 closure 组在日期层面的 `25-75%` 范围。 [已核验: E:\FL_MASSBALANCE\202308\plot_raw_pf_fadv_grouped_with_bands.R]

本批次四张图均已输出到 raw/PF 各自目录：raw 图为 `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_F_adv_geometry_relaxed_track15_255_diurnal_half_hour.png`，raw detrended 图为同目录 `FL_raw_F_adv_geometry_relaxed_track15_255_detrended_diurnal_half_hour.png`；PF 图为 `E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\figures\FL_pf_F_adv_geometry_relaxed_track15_255_diurnal_half_hour.png`，PF detrended 图为同目录 `FL_pf_F_adv_geometry_relaxed_track15_255_detrended_diurnal_half_hour.png`。 [已核验: E:\FL_MASSBALANCE\202308\raw_pf_fadv_grouped_with_bands_manifest.csv]

202308 几何放宽批次的 summary 均显示 `Ribbon: 25-75% date-level range` 和 `Verification result: PASS`。raw / raw detrended 两张图使用 `1288` 个 pass、`74` 个观测日期；PF / PF detrended 两张图使用 `1637` 个 pass、`74` 个观测日期。 [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_F_adv_geometry_relaxed_track15_255_diurnal_half_hour_summary.txt] [已核验: E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_F_adv_geometry_relaxed_track15_255_detrended_diurnal_half_hour_summary.txt] [已核验: E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\figures\FL_pf_F_adv_geometry_relaxed_track15_255_diurnal_half_hour_summary.txt] [已核验: E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\figures\FL_pf_F_adv_geometry_relaxed_track15_255_detrended_diurnal_half_hour_summary.txt]

## 全量批次

新增脚本 `E:\FL_MASSBALANCE\plot_full_raw_pf_fadv_grouped_with_bands.R`，用同一口径重绘全量 raw、raw detrended、PF、PF detrended 四张 `F_adv` 分组日变化图。raw 输入为 `E:\FL_MASSBALANCE\raw_w_mass_balance_from_1min\results\FL_mass_balance_raw_w_from_1min_by_pass.csv`，PF 输入为 `E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_by_pass.csv`。 [已核验: E:\FL_MASSBALANCE\plot_full_raw_pf_fadv_grouped_with_bands.R]

全量 raw 两张图输出到 `E:\FL_MASSBALANCE\raw_w_mass_balance_from_1min\figures\diurnal`，文件名分别为 `FL_raw_w_mass_balance_diurnal_half_hour.png` 和 `FL_raw_w_mass_balance_detrended_diurnal_half_hour.png`；全量 PF 两张图输出到 `E:\FL_MASSBALANCE\results\figures\diurnal`，文件名分别为 `FL_PF8bin_2ensemble_F_adv_diurnal_half_hour.png` 和 `FL_PF8bin_2ensemble_F_adv_detrended_diurnal_half_hour.png`。 [已核验: E:\FL_MASSBALANCE\full_raw_pf_fadv_grouped_with_bands_manifest.csv]

全量批次的 summary 均显示 `Ribbon: 25-75% date-level range` 和 `Verification result: PASS`。raw / raw detrended 两张图使用 `2275` 个 pass、`122` 个观测日期；PF / PF detrended 两张图使用 `2589` 个 pass、`123` 个观测日期。 [已核验: E:\FL_MASSBALANCE\raw_w_mass_balance_from_1min\figures\diurnal\FL_raw_w_mass_balance_diurnal_half_hour_summary.txt] [已核验: E:\FL_MASSBALANCE\raw_w_mass_balance_from_1min\figures\diurnal\FL_raw_w_mass_balance_detrended_diurnal_half_hour_summary.txt] [已核验: E:\FL_MASSBALANCE\results\figures\diurnal\FL_PF8bin_2ensemble_F_adv_diurnal_half_hour_summary.txt] [已核验: E:\FL_MASSBALANCE\results\figures\diurnal\FL_PF8bin_2ensemble_F_adv_detrended_diurnal_half_hour_summary.txt]

## 解释边界

本次只改变可视化表达，没有重算质量守恒 `F_adv`，也没有改变 raw/PF pass 表、闭合分类、去趋势算法或日期等权平均口径。色带当前表示的是日期层面的四分位范围，而不是 min-max 全范围；这样可以展示主要覆盖范围，同时避免少数极端日期把纵轴压扁。 [推断：基于两个新增绘图脚本和 summary 输出整理] [已核验: E:\FL_MASSBALANCE\202308\plot_raw_pf_fadv_grouped_with_bands.R] [已核验: E:\FL_MASSBALANCE\plot_full_raw_pf_fadv_grouped_with_bands.R]
