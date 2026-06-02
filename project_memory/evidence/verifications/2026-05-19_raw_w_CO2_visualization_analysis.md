# 2026-05-19 raw-w CO2 总输送可视化与初步分析

## 来源

这份记录整理自当前对话中对 raw `w` CO2 总输送结果的可视化请求，以及本回合直接新增并运行的绘图脚本、图片和汇总表。 [来源: 用户当前对话 2026-05-19] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]

## 本次新增信息

- 已新增 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R`，用于读取 `EA_raw_w_CO2_total_transport_all_windows.csv` 并生成 raw-w CO2 总输送图、总输送与平均流项对照图、湍流项图、上升/下沉输送项图和分量数量级对比图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- 新图和汇总表保存在 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures]
- 汇总表包括 `EA_raw_w_CO2_site_window_summary.csv` 和 `EA_raw_w_CO2_period_summary.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_site_window_summary.csv]

## 初步结果

- raw `w` CO2 总输送几乎完全由 `F_mean_window` 控制。按站点和窗口统计，平均流项在 `abs(F_mean_window) + abs(F_turb_window)` 中的占比约为 `0.9980` 到 `0.9995`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_site_window_summary.csv]
- 30 min 结果中，`F_total_raw_window` 和 `F_mean_window` 的符号在三个站点均 100% 一致，而 `F_total_raw_window` 和 `F_turb_window` 的符号一致率只在约 `0.318` 到 `0.599` 之间。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_site_window_summary.csv]
- 站点平均上，30 min `F_total_raw_window` 为：`CVT ≈ -24.34`、`FL ≈ +31.91`、`MT ≈ +74.11`；对应的 `mean_w_window` 分别约为 `-0.0559`、`+0.0751` 和 `+0.1729`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_site_window_summary.csv]
- 分时段看，30 min 结果中 `CVT` 在 midday_09_15 平均为 `-77.51`，而 `FL` 和 `MT` 在 midday_09_15 分别平均为 `+145.10` 和 `+183.50`；这些差异主要反映各站 raw `w` 平均项的方向和大小。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_period_summary.csv]
- 湍流项 `F_turb_window` 保留了旧 \(w'c'\) 协方差型 CO2 信号，午间多为负值，夜间接近零或略为正值，但它在 raw 总输送中被平均流项的数量级压过。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures\EA_raw_w_CO2_period_summary.csv] [推断：基于分量数量级和时段汇总整理]

## 解释边界

- 当前 raw-w 总输送可以用于查看原始仪器坐标下 `w` 携带 CO2 的总输送结构，但不应直接解释为生态系统 CO2 交换强度，因为它主要受未旋转 raw `w` 的平均项控制。 [推断：基于当前公式分解、可视化和未做坐标旋转的处理边界整理]
- 如果后续要把 raw 总输送用于物理解释，下一步应优先检查 `w_mean_window` 的来源，包括仪器坐标、塔位地形流、安装倾斜或真实平均垂直运动的可能贡献。 [推断：基于当前 raw-w 结果由平均流项主导的事实整理]
