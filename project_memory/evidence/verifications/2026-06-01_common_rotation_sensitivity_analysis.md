# 2026-06-01 common_rotation 坐标旋转敏感性初步统计

## 本次记录对象

本记录对应 `D:\00 博士阶段\博一\05 Project\com_rotation` 分支：在暂不纳入 FL 移动平台的前提下，针对 `CVT` 与 `MT` 两个固定站点、两个公共时段，输出并比较 `no rotation`、`double rotation`、`planar fit` 与 `sector-wise planar fit` 四种坐标处理后的 EC 结果。 [来源: 用户当前对话 2026-06-01]

两个公共时段从当前 segment 文件名可追溯为：`A = 2025-01-22_2025-02-24`，`B = 2025-03-05_2025-04-01`。当前判断只服务于固定站点坐标旋转敏感性检验，不把 FL 移动平台纳入本轮四方法对比。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\segments] [推断：基于当前 segment 文件名和用户排除 FL 的处理边界整理]

## 代码修复与重跑

本轮首先修复 `CVT` 全量结果中 `co2_flux`、`H`、`LE`、`Tau` 全为 `NA` 的问题。原因是 `CVT` 原始 TOA5 气体列名为 `CO2_mixratio` 和 `H2O_mixratio`，而原读取映射只处理 `CO2` 和 `H2O`，导致 `co2/h2o` 缺失，进而影响空气物性和通量计算。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\io_dat.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\phys_units.R]

已在 `read_toa5()` 映射中补充 `CO2_mixratio -> co2` 与 `H2O_mixratio -> h2o`；同时在空气物性计算前新增内部水汽单位准备逻辑，把水汽混合比转换为用于热力学计算的 `mmol/m3` 辅助列。该处理没有覆盖原始 `h2o`，因为最终 `h2o_flux/LE` 的协方差计算仍沿用原混合比口径。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\io_dat.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\phys_units.R]

已新增并运行 `D:\00 博士阶段\博一\05 Project\com_rotation\scripts\05_rerun_cvt_segments.R`，只重跑 `CVT` 两个公共时段与四种旋转方法，再调用恢复脚本合并最终结果。运行日志为 `D:\00 博士阶段\博一\05 Project\com_rotation\logs\rerun_cvt_segments_20260601_100115.log`，日志尾部显示 `Recovery complete` 与 `CVT-only rerun complete`。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\05_rerun_cvt_segments.R] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\logs\rerun_cvt_segments_20260601_100115.log]

## 当前最终结果位置

合并后的主结果文件为 `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv`，当前共有 `20528` 行，最后写入时间为 `2026-06-01 11:58:34`。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv]

其他同步刷新的汇总结果包括：

- `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_paired_sites.csv`，`19520` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_paired_sites.csv]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_paired_methods_by_site.csv`，`20528` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_paired_methods_by_site.csv]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_paired_sites_methods.csv`，`19520` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_paired_sites_methods.csv]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\site_period_method_summary.csv`，`16` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\site_period_method_summary.csv]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_stability_by_site_period.csv`，`24` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_stability_by_site_period.csv]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\method_range_by_site_timestamp.csv`，`5132` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\method_range_by_site_timestamp.csv]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\site_differences_paired_by_method.csv`，`9760` 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\site_differences_paired_by_method.csv]

## 初步统计和可视化位置

已新增并运行 `D:\00 博士阶段\博一\05 Project\com_rotation\scripts\06_initial_stats_visuals.R`。该脚本读取刷新后的主结果和汇总表，输出有限值统计、四方法相对 `double rotation` 的敏感性、方法间范围、站点差异、日变化汇总、稳定性标签和图件。时间解析已改为复用 `lib_common_rotation.R` 中的 `parse_flux_timestamp()`，避免 CSV 时间列自动解析造成连接异常。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\06_initial_stats_visuals.R]

分析输出根目录为 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis`。HTML 报告为 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\initial_rotation_analysis_report.html`。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\initial_rotation_analysis_report.html]

表格输出在 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables`，包括：

- `01_finite_counts_by_site_period_method.csv`
- `02_site_period_method_summary_long.csv`
- `03_method_sensitivity_vs_dr_long.csv`
- `04_method_sensitivity_vs_dr_summary.csv`
- `05_method_range_long.csv`
- `06_method_range_summary.csv`
- `07_site_difference_long.csv`
- `08_site_difference_summary.csv`
- `09_diurnal_summary_by_halfhour.csv`
- `10_rotation_stability_labels.csv`

[已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables]

图件输出在 `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\figures`，包括：

- `fig01_method_sensitivity_vs_dr_boxplot.png`
- `fig02_method_range_relative_heatmap.png`
- `fig03_site_difference_boxplot.png`
- `fig04_dr_diurnal_median_by_site.png`
- `fig05_site_period_method_medians.png`

[已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\figures]

## 核验结果

刷新后的 `rotation_flux_all_common_periods.csv` 中，`CVT` 与 `MT` 在四种方法下的 `co2_flux`、`H`、`LE`、`Tau` 与 `rho_air` 均已有有限值，不再出现 `CVT` 标量通量全为 `NA` 的问题。当前有限值计数为：`CVT` 每种方法 `2678` 条，`MT` 每种方法 `2454` 条；上述关键字段在对应站点和方法内均为全有限值。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv]

初步统计显示，坐标旋转方法对 `Tau` 最敏感，多个站点-时段组合的四方法中位相对范围超过 `200%`；`co2_flux`、`H`、`LE` 也表现出明显方法敏感性，中位相对范围通常约为 `30%` 到 `50%`；`u_star` 相对更稳定，但仍不是完全不变，典型中位相对范围约为 `19%` 到 `31%`。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\06_method_range_summary.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\10_rotation_stability_labels.csv]

以 `double rotation` 作为当前初步参照，配对站点差异 `CVT - MT` 显示：A 时段 `co2_flux` 中位差约 `+0.3945`，B 时段约 `+0.8488`；A 时段 `H` 中位差约 `-3.4571`，B 时段约 `-9.4506`；A 时段 `LE` 中位差约 `-9.6658`，B 时段约 `-2.5927`；`Tau` 中位差在两个时段均约 `+0.055`。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis\tables\08_site_difference_summary.csv]

## 解释边界

本轮四方法对比的首要意义是量化 `F_EC` 对坐标处理的敏感性，并帮助判断后续复杂地形通量计量中哪些结论对旋转方法稳健、哪些只是旋转口径下的表观结果。它还不能直接证明某一种旋转方法就是复杂地形下的真实通量，也不能单独解决水平/垂直平流和储存项问题。 [推断：基于当前四方法输出目标和复杂地形 EC 方法边界整理]

相对范围在通量接近零时会被放大，因此 `method_range_relative` 和热图应作为敏感性诊断，而不是直接解释为误差百分比。后续更稳妥的推进方式是同时报告绝对差值、相对差值、符号一致性、日变化相位一致性和站点差异一致性。 [推断：基于当前统计指标定义整理]

