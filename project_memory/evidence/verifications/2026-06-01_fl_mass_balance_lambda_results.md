# 2026-06-01 FL 四天质量守恒 lambda 修正结果

## 本次运行

- 新增并运行脚本 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\run_fl_mass_balance_lambda.R`，对 `D:\00EDDYPRO\com_260401\Flares` 下 `2025-03-20` 到 `2025-03-23` 四天 TOA5 高频数据计算移动单程质量守恒修正系数。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\run_fl_mass_balance_lambda.R`]
- 运行段来自 `D:\00 博士阶段\博一\05 Project\com_260326\小车运行.csv`，位置源记录为 `D:\00 博士阶段\博一\05 Project\com_260326\20250313_20250419.xlsx`；本次共有 `188` 个移动单程进入计算。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260326\小车运行.csv`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260326\20250313_20250419.xlsx`]
- 输出目录为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda`，主要输出包括 `FL_mass_balance_lambda_by_run.csv`、`FL_mass_balance_lambda_daily_summary.csv`、`FL_mass_balance_lambda_direction_summary.csv` 和 `FL_mass_balance_run_segments_used.csv`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda`]

## 核心结果

- 四天进入计算的单程数分别为：`2025-03-20 = 44`、`2025-03-21 = 48`、`2025-03-22 = 48`、`2025-03-23 = 48`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda\FL_mass_balance_lambda_daily_summary.csv`]
- 所有单程均同时存在正负 `w` 样本，没有 `single_sign_w` 段；共有 `3` 个 `extreme_lambda` 段，按本地时间分别是 `2025-03-21 18:59:44-19:29:14`、`2025-03-22 17:59:43-18:29:13` 和 `2025-03-22 18:29:13-18:59:43`。这些段的负 `w` 样本数较少，导致 `lambda` 分别约为 `376.35`、`204.06` 和 `1842.12`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda\FL_mass_balance_lambda_by_run.csv` 中 `run_start_local`/`run_end_local`]
- 修正后每段 `corrected_sum_w` 最大绝对残差约为 `2.77e-12`，说明按 `lambda = -sum(w[w > 0]) / sum(w[w < 0])` 并对 `w < 0` 乘以 `lambda` 后，数值上已经完成正负垂直风量平衡。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda\FL_mass_balance_lambda_by_run.csv`]
- 按日汇总的 `lambda` 中位数分别约为：`2025-03-20 = 0.877`、`2025-03-21 = 4.130`、`2025-03-22 = 1.847`、`2025-03-23 = 0.494`。平均覆盖率均接近 `1.0`，没有低覆盖率段。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda\FL_mass_balance_lambda_daily_summary.csv`]

## 可视化输出

- 新增并运行绘图脚本 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fl_mass_balance_lambda.R`，读取 `FL_mass_balance_lambda` 结果目录下的 CSV 表，输出图件到 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda\figures`。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fl_mass_balance_lambda.R`] [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda\figures\FL_mass_balance_visualization_manifest.csv`]
- 当前图件包括 `lambda_time_series_by_run.png`、`lambda_daily_distribution.png`、`w_balance_before_after.png`、`co2_transport_before_after.png`、`lambda_direction_summary.png` 和 `lambda_heatmap_day_time.png`。主图检查显示：极端 `lambda` 段在时序图和热图中被标红；修正后 `sum(w)` 图贴近数值零，符合质量守恒修正预期。 [已核验: `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\FL_mass_balance_lambda\figures`]

## 解释边界

- 本次输出中的 `co2_transport_raw` 和 `co2_transport_lambda` 是沿用原 `Fc_adv` 思路的参考量，用当前 `CO2`、`PA` 和 `TA_1_1_1` 做理想气体换算后比较修正前后输送，不等同于已经完成全部 EddyPro/WPL/坐标旋转处理的最终生态系统 CO2 通量。 [推断: 基于本次脚本公式和当前项目方法边界整理]
- 极端 `lambda` 段不应直接作为稳定修正后的可靠通量段使用；它们更适合先作为质量控制异常段保留，后续若进入机制解释或论文图，应单独标记或剔除。 [推断: 基于 `extreme_lambda` 判据和正负样本数结构整理]
