# 2026-07-09 固定塔 rotation 敏感性日变化图（严格 QC vs 无 qc/flag9）

## 来源

- 这份记录整理自用户在当前对话中的明确要求：把两塔各旋转方法的 `2025` 日变化画在同一张图上，`QC` 前后各一张；每张图中 `MT/CVT` 上下分面，用颜色区分 rotation 方法，用色带表示通量分布的四分位范围。[来源: 用户当前对话 2026-07-09]

## 本次图件口径

- 本轮没有重跑任何原始通量，而是直接复用已经落盘的 `2025` per-method `30min gapfilled` 明细表作图。严格版来自 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025`，无 `qc_co2/flag9_co2` 版来自 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_run_plan.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\rotation_sensitivity_standardized_2025_no_qc_no_flag9_run_plan.csv]
- 新绘图脚本为 `D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_rotation_sensitivity_diurnal_2025.R`。它逐个读取各方法目录下的 `*_nee_2025_estimate*_30min_gapfilled.csv`，用 `gapfilled_co2_flux` 直接汇总 `2025` 全年的半小时日变化，因此图线与当前年值口径保持一致，而不是回退到原始 full-flux 表或只画 observed 子集。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_rotation_sensitivity_diurnal_2025.R]
- 中心折线定义为每个半小时 bin 上 `gapfilled_co2_flux` 的中位数；色带定义为同一 bin across all 2025 dates 的 `25th-75th percentile`。这套表达对应“典型日变化形状 + 同一时段跨日期波动范围”，不是标准误或置信区间。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_rotation_sensitivity_diurnal_2025.R]
- 严格版图中继续沿用 `qc_co2 <= 1 + flag9_co2 <= 3 + 夜间 u*` 的 downstream 口径；无 `qc/flag9` 版只关闭这两道筛选，夜间 `u*` 过滤仍保留，因此两张图之间的差异主要反映 `QC` 筛选对半小时日变化分布的影响。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_annual_summary_all_methods.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\rotation_sensitivity_standardized_2025_no_qc_no_flag9_annual_summary_all_methods.csv]

## 输出文件

- 严格版图件输出到 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures_diurnal\fixed_tower_rotation_sensitivity_diurnal_strict.png`，配套统计表为 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_rotation_sensitivity_diurnal_strict_plot_data.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures_diurnal\fixed_tower_rotation_sensitivity_diurnal_strict.png] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_rotation_sensitivity_diurnal_strict_plot_data.csv]
- 无 `qc/flag9` 版图件输出到 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\figures_diurnal\fixed_tower_rotation_sensitivity_diurnal_no_qc_no_flag9.png`，配套统计表为 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\fixed_tower_rotation_sensitivity_diurnal_no_qc_no_flag9_plot_data.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\figures_diurnal\fixed_tower_rotation_sensitivity_diurnal_no_qc_no_flag9.png] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9\fixed_tower_rotation_sensitivity_diurnal_no_qc_no_flag9_plot_data.csv]

## 解释边界

- 这两张图总结的仍然是当前 `W3` 口径下的 `EC-only NEE proxy / gapfilled co2_flux diurnal pattern`，不应被表述为已经并入 storage、advection 或年度闭合修正后的最终碳收支日变化图。[来源: 用户当前对话 2026-07-05 至 2026-07-09] [推断: 基于现有估算脚本和 W3 边界定义]
