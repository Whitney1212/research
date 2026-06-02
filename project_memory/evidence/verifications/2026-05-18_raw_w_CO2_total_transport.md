# 2026-05-18 raw-w CO2 总输送计算核验

## 来源

这份记录整理自当前对话中对“更聚焦总输送、先忽略其他因素用原始 `w` 计算”的方法校准，以及本回合直接新增并运行的本地脚本和输出文件。 [来源: 用户当前对话 2026-05-18] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R]

## 本次新增信息

- 已新增 `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R`，该脚本只计算 CO2，并沿用既有读取、诊断码过滤、合理范围过滤、despike、coverage 过滤和 metadata 约束 lag 校正。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R]
- 新脚本不使用 `w - mean(w)` 来分组，而是直接用原始 `w` 的符号划分上升与下沉，并计算 `F_total_raw_window = sum(w * co2 * dt) / window_sec`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R]
- 新脚本同时输出 `5min` 和 `30min` 两个窗口，分母分别为 300 s 和 1800 s；脚本也保留 `valid_seconds`、`coverage_frac` 和以有效时长为分母的校验列。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R]

## 输出文件

- 新输出目录是 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport]
- 主输出包括 `EA_raw_w_CO2_total_transport_all_windows.csv`、`EA_raw_w_CO2_total_transport_5min.csv` 和 `EA_raw_w_CO2_total_transport_30min.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv]
- 运行同时输出 `EA_raw_w_CO2_lag_stats.csv`、`EA_raw_w_CO2_lag_config.csv`、`EA_raw_w_CO2_despike_stats.csv` 和 `EA_raw_w_CO2_run_log.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_run_log.csv]

## 核验结果

- 使用 `D:\softwares\R-4.3.3\bin\Rscript.exe` 运行后，raw-w CO2 总输送共生成 4032 行，其中 5 min 为每站 1152 行，30 min 为每站 192 行。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_all_windows.csv]
- 运行日志中 12 个输入文件全部为 `ok`，没有文件级错误。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_run_log.csv]
- 脚本内公式闭合检查显示，`F_total_raw_window` 与 `F_up_raw_window + F_down_raw_window` 的最大误差约为 `5.68434e-14`，`F_total_raw_window` 与 `F_mean_window + F_turb_window` 的最大误差约为 `1.13687e-13`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R]
- 30 min 新结果中的 `F_turb_valid` 与旧 `EA_flux_results.csv` 中 CO2 的 `F_EC_cov` 完全一致，合并核验行数为 576，最大差异为 0。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_total_transport_30min.csv]

## 和现有记忆的关系

- 这次新增的 raw-w 分支没有覆盖原来的 `w'` 协方差型 EA/EC 结果，而是把“原始仪器坐标下的 CO2 总输送”作为独立输出保留下来。 [推断：基于本次脚本新增、输出目录和旧主结果仍保留整理]
- 后续解释时，需要同时区分 `F_total_raw_window`、`F_mean_window` 和 `F_turb_window`；其中 `F_turb_valid` 可与旧协方差通量对照，而 `F_total_raw_window` 才是这次新增的 raw `w` 总输送口径。 [推断：基于本次公式校准和输出列整理]
