# 2026-07-09 固定塔 no_rotation 日变化 QC 前后对比图

## 来源

- 这份记录整理自用户在当前对话中的明确要求：只保留两塔 `no_rotation`，把 `QC` 前后日变化画到同一张图中；颜色沿用 project memory 中固定站点色，`QC` 前后用线型区分。[来源: 用户当前对话 2026-07-09]

## 口径

- 本轮没有重跑原始通量，也没有重算 NEE；直接复用已经落盘的 per-tower `no_rotation` 30 min gapfilled 明细表。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_no_rotation_qc_contrast_diurnal_2025_plot_data.csv]
- 严格版来自 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025`，口径为 `qc_co2 <= 1 + flag9_co2 <= 3 + 夜间 u*`；无 `qc/flag9` 版来自 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025_no_qc_no_flag9`，只关闭 `qc_co2` 和 `flag9_co2` 排除，夜间 `u*` 保留。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_no_rotation_qc_contrast_diurnal_2025_summary.txt]
- 中心折线为每个半小时 bin 上 `gapfilled_co2_flux` 在 2025 全年日期间的中位数；输出 CSV 同时保留 `q25 / median / q75 / mean`，但主图只画折线以避免同色多色带叠加。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_no_rotation_qc_contrast_diurnal_2025.R]
- 站点颜色沿用 project memory 固定色：`CVT = #F8766D`，`MT = #619CFF`；线型为 `Strict QC = solid`，`No qc_co2 / flag9 = longdash`。[已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-02_regov_fixed_visual_style.md]

## 输出

- 新脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_no_rotation_qc_contrast_diurnal_2025.R`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_no_rotation_qc_contrast_diurnal_2025.R]
- 图件：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures_diurnal\fixed_tower_no_rotation_qc_contrast_diurnal_2025.png`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures_diurnal\fixed_tower_no_rotation_qc_contrast_diurnal_2025.png]
- 作图数据：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_no_rotation_qc_contrast_diurnal_2025_plot_data.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_no_rotation_qc_contrast_diurnal_2025_plot_data.csv]
- 摘要：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_no_rotation_qc_contrast_diurnal_2025_summary.txt`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_no_rotation_qc_contrast_diurnal_2025_summary.txt]

## 核验

- 作图数据共 `2 塔 x 2 QC 场景 x 48 半小时 = 192` 行；每个 `tower x qc_scenario` 都有完整 48 个半小时点。[已核验: 本轮 R 检查]
- 图件已本地打开目视检查，颜色、线型、纵轴密刻度和细线均正常。[已核验: 本轮本地图片查看]

## 解释边界

- 这张图总结的是当前 `W3` 口径下的 `EC-only NEE proxy / gapfilled co2_flux diurnal pattern`，用于比较 `no_rotation` 在严格 QC 与关闭 `qc_co2/flag9` 后的典型日变化差异；不能表述为已经并入 storage、advection 或年度闭合修正后的最终碳收支日变化。
