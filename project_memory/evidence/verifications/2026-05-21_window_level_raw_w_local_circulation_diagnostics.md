# 2026-05-21 窗口内 raw `w` 局地环流诊断计算记录

## 来源与目标

- 本记录整理当前对 `EA_raw_w_local_circulation_diagnostics` 中窗口内计算的解释：计算目标、思路、关键结果、结果储存位置和阶段性推测。[来源: 用户当前对话 2026-05-21]
- 该诊断的目标不是重新计算常规 EC 生态系统通量，而是在 5 min 和 30 min 窗口内检查 raw 坐标下的平均垂直风 `w_mean` 是否主导 CO2 总输送，并进一步排查 `w_mean` 是真实局地环流信号，还是坐标倾斜、地形流线倾斜或水平风投影造成的 apparent vertical motion。[已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R] [推断: 基于当前未做坐标旋转的处理边界整理]
- 当前主解释尺度仍为 30 min；5 min 输出主要用于检查日出、日落和短时事件细节。[来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics]

## 窗口内计算思路

- 每个站点、每个原始 TOA5 文件先读取高频数据，并保留 `time`、`u`、`v`、`w`、`ts`、`co2` 和诊断字段。数据经过时间排序、重复时间去除、sonic/IRGA 诊断码过滤、物理范围检查、可选 despike 和 lag 补偿后，再切成 5 min 或 30 min 窗口。[已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- 窗口内 `u_mean_valid` 和 `v_mean_valid` 使用同时具有有限 `u`、`v` 的样本计算：`u_mean = mean(u[valid_uv])`，`v_mean = mean(v[valid_uv])`。`w_mean_valid` 使用有限 `w` 样本计算，`w_mean_window = sum(w * dt_sec) / window_sec`，因此在覆盖率接近 100% 时与普通 `mean(w)` 几乎一致；有缺测时则保持完整窗口长度作为分母。[已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- 窗口内还计算 `wind_speed_from_mean = sqrt(u_mean^2 + v_mean^2)`、`wind_speed_mean = mean(sqrt(u^2+v^2))`、`sigma_w`、`co2_mean_valid`、sonic 坐标下的风向扇区等字段。这些字段保存于 `window_wind_context_all_windows.csv`。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\window_wind_context_all_windows.csv]
- raw CO2 总输送来自既有 raw-w 输出表，关键关系为 `F_total_raw_window = F_mean_window + F_turb_window`，其中 `F_mean_window` 近似为 `w_mean_window * c_mean`，`F_turb_window` 为窗口内脉动协方差项。局地环流诊断脚本把 raw 输送表与新计算的窗口风场表按 `site`、`source_file`、`window_label`、`window_sec` 和 `block_key` 合并。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\raw_w_transport_with_wind_context_all_windows.csv]
- 对每个 `site + window_label` 分组单独拟合 `w_mean_window.wind ~ u_mean_valid + v_mean_valid`。拟合值 `w_fitted_uv` 表示 raw `w_mean` 中可由水平风线性解释的部分，残差 `w_resid_uv = w_mean_window.wind - w_fitted_uv` 表示扣除线性 `u/v` 关系后的剩余平均垂直风异常。[已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\w_mean_uv_regression_coefficients.csv]
- FL 位置分箱在每个窗口内进一步按轨道位置分成 25 m 左右的 bin。`0 m` 是 MT 所在轨道起点，轨道中点约 `122.5 m` 穿过 CVT 正上方，`245 m` 是终点。每个位置 bin 内计算 `u_mean`、`v_mean`、`w_mean`、`c_mean`、`F_total_bin_valid = mean(w * co2)`、`F_mean_bin_valid = mean(w) * mean(co2)` 和 `F_turb_bin_valid`。[来源: 用户当前对话 2026-05-20] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\FL_position_binned_raw_w_30min.csv]

## 关键计算结果

- 当前重跑后的 `run_log.csv` 显示 24 个站点-文件-窗口任务全部为 `ok`。输出包括 `4032` 行窗口风场表、`4750` 行 FL 位置分箱表和 9 张诊断图。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\run_log.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics]
- 30 min 全窗口检查显示 `F_total` 几乎完全由 `F_mean` 决定，也几乎完全随 `w_mean` 变化：`cor(F_total, F_mean) ≈ 1.000`，`cor(F_total, w_mean) ≈ 0.9999-1.000`；`median |F_turb| / |F_total|` 约为 `CVT 0.0017`、`FL 0.0004`、`MT 0.0006`。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\raw_w_transport_with_wind_context_all_windows.csv] [推断: 基于当前本地核算整理]
- 30 min、`09:00-15:00` 的站点均值为：`CVT mean_w_wind = -0.1774`、`mean_F_total = -77.51`；`FL mean_w_wind = +0.3371`、`mean_F_total = +145.10`；`MT mean_w_wind = +0.4268`、`mean_F_total = +183.50`。同期 `mean_F_turb` 约为 `-0.16` 到 `-0.18`，相对总输送很小。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\site_period_wind_transport_summary.csv]
- 30 min 全日 `w_mean ~ u_mean + v_mean` 回归的 `R2` 为：`CVT ≈ 0.296`、`FL ≈ 0.890`、`MT ≈ 0.750`。这说明 `FL` 和 `MT` 的 raw `w_mean` 很大比例可由 sonic 坐标下的水平风线性解释，`CVT` 的解释度较低。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\w_mean_uv_regression_coefficients.csv]
- 扣除线性 `u/v` 解释后，30 min、`09:00-15:00` 的 `mean_w_resid_uv` 为：`CVT = -0.0577`、`FL = +0.0183`、`MT = +0.0733`。这说明 raw 的 `CVT` 负、`FL/MT` 正结构被明显削弱，但没有完全消失。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\site_period_wind_transport_summary.csv]
- 30 min 白天窗口中，raw `MT > CVT` 的比例为 `100%`，raw `FL > CVT` 的比例约 `97.9%`，同时满足 `MT/FL` 为正且 `CVT` 为负的比例约 `87.5%`。扣除线性 `u/v` 后，`MT > CVT` 约 `77.1%`，`FL > CVT` 约 `72.9%`，同时满足 `MT/FL` 为正且 `CVT` 为负的比例约 `31.2%`。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\raw_w_transport_with_wind_context_all_windows.csv] [推断: 基于当前本地核算整理]
- FL 30 min、`09:00-15:00` 位置分箱显示：`MT_start_side mean_w ≈ +0.416`、`CVT_overhead_mid mean_w ≈ +0.201`、`track_end_side mean_w ≈ +0.436`。因此 FL 轨道高度上白天整体偏上升，两端更强，中部 CVT 正上方较弱，但没有转为负 `w`。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\FL_position_binned_raw_w_30min.csv]
- `site_w_mean_diurnal_30min.png` 已按用户要求改成三列四行分面图，站点为列、日期为行，16:9 输出，像素为 `3520 x 1980`。[来源: 用户当前对话 2026-05-21] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\figures\site_w_mean_diurnal_30min.png]

## 结果储存位置

- 脚本位置：`D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R`。[已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- 诊断总目录：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics`。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics]
- 主要表格包括：`window_wind_context_all_windows.csv`、`raw_w_transport_with_wind_context_all_windows.csv`、`w_mean_uv_regression_coefficients.csv`、`wind_sector_summary.csv`、`site_period_wind_transport_summary.csv`、`FL_position_binned_raw_w_all_windows.csv`、`FL_position_binned_raw_w_30min.csv`、`FL_position_binned_raw_w_5min.csv` 和 `FL_track_metadata.csv`。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics]
- 图件目录：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\figures`。当前包括站点日变化、站点热图、`u/v` 残差热图、sonic 风向扇区图、FL 位置 `w_mean`、`F_total`、`c_mean`、异常平均输送热图和 FL 午间轨道剖面图。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\figures]

## 初步推测与解释边界

- 当前 raw CO2 总输送诊断的主控变量是 `w_mean`，不是 `c_mean` 或湍流协方差项。因此这些图首先应解释为 raw 坐标下平均垂直风携带背景 CO2 的诊断结果，而不能直接解释为生态系统 CO2 源汇强度。[推断: 基于 `F_total`、`F_mean`、`F_turb` 的数量级和相关性整理]
- raw 站点图支持一个稳定的横向反差：白天 `MT/FL` 偏正、`CVT` 偏负。这与谷缘高地、谷底和谷地上方切面组成的局地环流候选图像相符。[推断: 基于站点均值、热图和用户确认的站点地形背景整理]
- 但 `FL` 和 `MT` 的 `R2` 很高，说明 raw `w_mean` 中有显著部分可由水平风解释。因此当前不能把 raw `w_mean` 全部写成真实地理垂直运动；更稳妥的表述是“raw 坐标下存在稳定平均垂直风反差，并保留一个扣除线性水平风影响后仍存在但明显弱化的局地环流候选残差信号”。[推断: 基于 `w_mean ~ u_mean + v_mean` 回归和 `w_resid_uv` 结果整理]
- FL 沿轨道图支持“谷地上方在 FL 高度存在平均向上运动信号”，但不支持“CVT 正上方是最强上升或明显下沉”的简单图像。当前更像“两端上升强、中部上升弱”的横向结构。[推断: 基于 `FL_position_binned_raw_w_30min.csv` 和 FL 位置图整理]
- 热力驱动目前只有时间相位上的间接支持：信号主要在白天增强，符合坡面受热、谷风/上坡流和混合增强的物理预期。但由于 `u/v` 与风向依赖很强，仍需要接入短波或净辐射、气温、湿度、气压、降雨、稳定度或 `u*` 等数据，才能把该结构进一步归因于热力过程。[推断: 基于当前结果和缺少气象驱动变量的状态整理]
