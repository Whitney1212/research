# 2026-05-20 raw `w` 局地环流诊断计算

## 来源

- 用户要求在 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com` 下新建目录开展 raw `w` 局地环流相关诊断计算；若没有位置不明的必要数据，则直接写 R 脚本并运行。 [来源: 用户当前对话 2026-05-20]
- 本回合确认必要数据位置均已明确：三站 EC 高频数据来自既有 `sites` 配置，raw-w 总输送表来自 `EA_raw_w_total_transport`，FL 运行状态来自 `E:\260402计算\Flares_EC\20250313_20250419.xlsx`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]

## 新增脚本与输出

- 新增脚本 `D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R`。该脚本 source 既有 EA 预处理函数但设置 `EA_SKIP_RUN=1`，因此不会重跑或覆盖旧 `EA_flux_results.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- 新输出目录为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics`。主要输出包括 `window_wind_context_all_windows.csv`、`raw_w_transport_with_wind_context_all_windows.csv`、`w_mean_uv_regression_coefficients.csv`、`wind_sector_summary.csv`、`site_period_wind_transport_summary.csv`、`FL_position_binned_raw_w_all_windows.csv`、`FL_position_binned_raw_w_30min.csv`、`FL_track_metadata.csv` 和 `figures/`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics]
- 运行日志显示 24 个站点-文件-窗口任务全部为 `ok`。窗口风场表共有 `4032` 行，FL 位置分箱表共有 `4750` 行，生成图件 `9` 张。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\run_log.csv]

## 关键核查

- 首次运行后发现 `data.table::fread()` 会把 raw 表中的 `block_start` 自动读为 UTC 时间，造成 raw-w 通量和重新计算的风场相差 `8 h`。脚本已修正为强制把 `block_start` 和 `block_end` 按字符读取，再按 `Asia/Shanghai` 解析。修正后新诊断表中的 `09:00-15:00` 站点汇总与旧 raw-w 汇总一致。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\site_period_wind_transport_summary.csv]
- 30 min、`09:00-15:00` 的站点均值为：`CVT` 的 `mean_w_wind ≈ -0.1774`、`mean_F_total ≈ -77.51`；`FL` 的 `mean_w_wind ≈ +0.3371`、`mean_F_total ≈ +145.10`；`MT` 的 `mean_w_wind ≈ +0.4268`、`mean_F_total ≈ +183.50`。这复现了旧 raw-w 白天强站点反差。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\site_period_wind_transport_summary.csv]
- 30 min 回归 `w_mean ~ u_mean + v_mean` 的全日 `R²` 为：`CVT ≈ 0.296`、`FL ≈ 0.890`、`MT ≈ 0.750`。这说明 `FL` 和 `MT` 的 raw `w_mean` 很大部分可由声学坐标水平风分量解释，`CVT` 解释度较低。该结果是诊断线索，不等于正式坐标旋转。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\w_mean_uv_regression_coefficients.csv]
- 扣除线性 `u/v` 解释后，30 min、`09:00-15:00` 的 `mean_w_resid_uv` 仍表现为 `CVT ≈ -0.0577`、`FL ≈ +0.0183`、`MT ≈ +0.0733`。白天 `CVT` 负、`FL/MT` 正的符号结构仍存在，但强度明显降低。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\site_period_wind_transport_summary.csv]
- FL 30 min 位置分箱显示，`09:00-15:00` 时 `MT_start_side` 的 `mean_w ≈ +0.416`，`CVT_overhead_mid` 的 `mean_w ≈ +0.201`，`track_end_side` 的 `mean_w ≈ +0.436`。按 25 m 分箱看，轨道中部 `112.5-162.5 m` 的上升较弱，两端更强；但 FL 在 CVT 上方中段并未表现为负 `w`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\FL_position_binned_raw_w_30min.csv]

## 阶段性解释

- 当前结果支持两个并行判断。第一，站点尺度白天 raw `w` 符号反差仍然成立，且在扣除线性 `u/v` 解释后仍保留弱化后的 `CVT` 负、`FL/MT` 正结构。第二，FL 沿轨道分箱更像“两端上升强、中部上升弱”，而不是“中部明确下沉”。 [推断：基于本次站点汇总、回归残差和 FL 位置分箱整理]
- 因为 `u/v` 回归解释度在 `FL` 和 `MT` 很高，后续不能直接把 raw `w_mean` 全部写成真实地理垂直运动；但残差符号结构和 FL 空间分箱仍提供了值得继续追的局地环流线索。 [推断：基于当前未做坐标旋转的处理边界和本次回归结果整理]
