# 最新窗口内 raw `w` 诊断快照

## 当前结论

- 当前窗口内诊断已经明确：30 min raw CO2 `F_total` 几乎完全由 `F_mean` 控制，而 `F_mean` 又几乎完全由 `w_mean` 控制。因此这些图和表首先是在诊断 raw 坐标下的平均垂直风，而不是常规 EC 生态系统 CO2 通量。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\raw_w_transport_with_wind_context_all_windows.csv] [推断: 基于当前本地核算整理]
- 30 min、`09:00-15:00` 的 raw 站点格局为 `CVT` 负、`FL/MT` 正：`CVT mean_w_wind = -0.1774`，`FL = +0.3371`，`MT = +0.4268`。这支持一个局地环流候选图像，但仍是 raw 坐标结果。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\site_period_wind_transport_summary.csv]
- 30 min `w_mean ~ u_mean + v_mean` 回归显示 `FL R2 ≈ 0.890`、`MT R2 ≈ 0.750`、`CVT R2 ≈ 0.296`。因此 `FL` 和 `MT` 的 raw `w_mean` 很大部分可能来自水平风相关的坐标/流线倾斜或投影效应。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\w_mean_uv_regression_coefficients.csv]
- 扣除线性 `u/v` 拟合后，白天残差仍为 `CVT` 负、`FL/MT` 正，但强度明显降低：`CVT = -0.0577`，`FL = +0.0183`，`MT = +0.0733`。这说明局地环流候选残差信号存在，但不能把 raw 结构全部归因为真实环流。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\site_period_wind_transport_summary.csv]
- FL 轨道位置分箱显示，白天在 FL 高度整体偏上升，但呈“两端强、中部弱”：`MT_start_side mean_w ≈ +0.416`，`CVT_overhead_mid ≈ +0.201`，`track_end_side ≈ +0.436`。因此当前更支持“谷地上方弱上升/两端强上升”的结构，而不是“CVT 正上方明显下沉”。[已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics\FL_position_binned_raw_w_30min.csv]

## 方法边界

- `w_resid_uv` 是经验线性残差：`w_mean_window.wind - predict(lm(w_mean_window.wind ~ u_mean_valid + v_mean_valid))`。它不是双旋转、planar fit 或正式地理坐标旋转结果。[已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- 当前还不能直接证明热力驱动。白天增强只提供时间相位上的支持；后续需要接入短波或净辐射、温度、湿度、气压、降雨、稳定度或 `u*`，再检验 `w_mean`、`w_resid_uv` 和站点差值是否随热力条件增强。[推断: 基于当前诊断结果和缺少气象驱动变量的状态整理]

## 结果位置

- 脚本：`D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R`。
- 输出目录：`D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics`。
- 详细证据记录：`project_memory/evidence/verifications/2026-05-21_window_level_raw_w_local_circulation_diagnostics.md`。
- 稳定方法定义：`project_memory/anchors/05_window_level_raw_w_diagnostic_definitions.md`。
