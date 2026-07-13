# 2026-07-10 固定塔 QC 前后 annual NEE 柱状图重可视化

## 目的

在不改动任何 `2025` 年 `NEE` 计算口径与结果表的前提下，重画一张更直接的年度结果图：

- 仅展示 `MT` 与 `CVT` 的 `annual NEE`
- 一个 rotation 方法一个分面
- 同一分面内用颜色区分 `Strict QC` 与 `No QC/flag9`
- 不再同时叠加数据量占比
- 不纳入 `MT season_sector_pf`

## 输入

- 汇总表：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_strict_vs_no_qc_compact_table.csv`

## 脚本

- `D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_qc_nee_bars_by_method.R`

## 输出

- 图：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures\fixed_tower_qc_annual_nee_bars_by_method_16x9.png`
- 作图表：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\fixed_tower_qc_annual_nee_bars_by_method_plot_data.csv`

## 口径

- 数据来源仍是已经完成的两套年值汇总结果：
  - `Strict QC`：`qc_co2 <= 1`、`flag9_co2 <= 3`、夜间 `u*`、随后沿用既有 `W3` gapfilling 链
  - `No QC/flag9`：仅关闭 `qc_co2 <= 1` 与 `flag9_co2 <= 3`，夜间 `u*` 与 gapfilling 链保持不变
- 本图不重算 `NEE`，只重表达现有结果

## 验证

- `Rscript D:\00 博士阶段\99 Project\06 EA\scripts\plot_fixed_tower_qc_nee_bars_by_method.R` 已成功执行
- 输出作图表共 `16` 行，正好对应：
  - `2 towers`
  - `4 common methods`
  - `2 QC states`
- 图件已落盘到既定 `figures` 目录
