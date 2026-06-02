# 2026-05-18 EA 计算、可视化与 CO2 气团分析核验

## 来源

这份记录整理自 2026-05-18 当前对话中的 EA/EC 计算讨论，以及本回合直接核验过的本地脚本和输出文件。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]

## 计算内容

- 当前计算使用 EC 高频数据作为输入，按 30 min block 进行 EA 条件积分，输出站点、标量和半小时级别的 `F_EA_general`、`F_EA_simple` 和 `F_EC_cov`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]
- 当前计算不做坐标旋转、WPL、频率修正和密度换算，因此结果是当前方法边界下的运动学通量。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- 当前 lag 使用 metadata 约束的协方差法，`MT`/`FL` 为 10 Hz 下 ±2 samples，`CVT` 为 20 Hz 下 ±4 samples，均约等于 ±0.2 s。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_lag_config.csv]

## 输出结果

- 主结果文件 `EA_flux_results.csv` 有 1152 行，覆盖 `2025-03-20` 到 `2025-03-23` 的 `MT`、`CVT`、`FL` 三站和 `co2`、`h2o` 两个标量。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]
- 逐日净通量图保存在 `EA_daily_figures`，其中包含 `EA_daily_facets_co2.png`、`EA_daily_facets_h2o.png` 和每天一张的 `EA_daily_flux_*.png`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_daily_figures]
- 上升/下沉贡献图保存在 `EA_up_down_figures`，其中 `centered` 版本用于解释净通量贡献，`raw` 版本用于查看原始 EA 输送项的大数抵消。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_up_down_figures]
- CO2 气团浓度图保存在 `EA_co2_airmass_figures`，其中包含 `EA_CO2_airmass_concentration_facets.png`、`EA_CO2_airmass_anomaly_facets.png` 和 `EA_CO2_up_minus_down_facets.png`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_co2_airmass_figures]

## 结果表现

- 当前 EA 和 EC 协方差几乎相等，这是因为当前 EA 实现使用 \(w'\) 进行条件积分，净通量代数上回到 \(\overline{w'c'}\)。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv] [推断：基于脚本公式与当前对话推导整理]
- CO2 在 09:00-15:00 的全站平均表现为 `c_up < c_mean < c_down`，说明上升气团 CO2 偏低、下沉气团 CO2 偏高；这与白天生态系统吸收 CO2 的物理图像一致。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_co2_airmass_figures\EA_CO2_airmass_period_summary.csv] [推断：基于 CO2 时段统计整理]
- CO2 在夜间 `00:00-06:00` 平均表现为 `c_up > c_mean > c_down`，说明上升气团相对富 CO2、下沉气团相对贫 CO2；这与夜间呼吸释放 CO2 的物理图像一致。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_co2_airmass_figures\EA_CO2_airmass_period_summary.csv] [推断：基于 CO2 时段统计整理]
