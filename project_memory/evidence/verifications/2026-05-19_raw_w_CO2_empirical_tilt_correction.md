# 2026-05-19 raw-w CO2 总输送经验倾斜修正尝试

## 来源

这份记录整理自当前对话中“不要覆盖之前结果，尝试进行修正”的请求，以及本回合直接新增并运行的修正脚本、输出文件和对比图。 [来源: 用户当前对话 2026-05-19] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_tilt_corrected.R]

## 本次新增信息

- 已新增 `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_tilt_corrected.R`，该脚本不会覆盖旧 raw-w 结果，而是输出到 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected`。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_tilt_corrected.R] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected]
- 因为 metadata 中没有 sonic pitch/roll 或安装倾角，本次修正采用经验模型 `w_bias = intercept + slope_u * u + slope_v * v`。每个站点用 30 min 风场块的 `w_mean ~ u_mean + v_mean` 拟合一个固定偏差模型，再对高频 `w` 扣除该偏差。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_tilt_corrected.R]
- 已新增 `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_tilt_corrected_transport.R`，用于生成修正前后总输送、修正前后 `w_mean` 和数量级对比图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_tilt_corrected_transport.R]

## 修正系数

- `CVT` 的经验模型等效斜率为 `0.0653`，等效角度约 `3.74°`，拟合 `R²≈0.296`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected\EA_raw_w_CO2_tilt_correction_coefficients.csv]
- `FL` 的经验模型等效斜率为 `0.1953`，等效角度约 `11.05°`，拟合 `R²≈0.890`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected\EA_raw_w_CO2_tilt_correction_coefficients.csv]
- `MT` 的经验模型等效斜率为 `0.1520`，等效角度约 `8.64°`，拟合 `R²≈0.750`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected\EA_raw_w_CO2_tilt_correction_coefficients.csv]

## 结果变化

- 修正后各站平均 `w_corrected_mean_window` 接近 0，例如 30 min 下 `CVT≈1.6e-06`、`FL≈-3.2e-06`、`MT≈1.5e-06`，说明站点尺度的线性偏移被去掉。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected\EA_raw_w_CO2_tilt_corrected_site_window_summary.csv]
- 30 min 平均总输送从 `CVT=-24.34`、`FL=+31.91`、`MT=+74.11` 变为修正后的 `CVT≈+0.005`、`FL≈-0.053`、`MT≈+0.017`，说明长期平均偏移被显著压低。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected\EA_raw_w_CO2_tilt_corrected_site_window_summary.csv]
- 但是修正后单个窗口的平均绝对总输送仍明显大于湍流项。例如 30 min 下 `mean_abs_corrected_total` 为 `CVT≈29.46`、`FL≈29.23`、`MT≈38.22`，而 `mean_abs_corrected_turb_component` 只有约 `0.069` 到 `0.078`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected\EA_raw_w_CO2_tilt_corrected_site_window_summary.csv]

## 解释边界

- 本次修正是经验诊断修正，不是基于实测安装 pitch/roll 的固定几何修正。它可以减少长期线性坐标偏差，但可能同时移除真实的、与水平风相关的地形平均垂直运动。 [推断：基于 metadata 缺少倾角字段与当前经验模型结构整理]
- 修正后结果仍不应直接解释为生态 CO2 交换强度，因为残余窗口尺度平均流项仍比湍流项大几个数量级。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected\EA_raw_w_CO2_tilt_corrected_site_window_summary.csv] [推断：基于分量数量级整理]
