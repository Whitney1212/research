# 构件索引

## 脚本

- `D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R` 是当前时间线机制可视化脚本。它读取 `EA_timeline_alignment` 下的事件窗口表、关键事件时间表和 FL 位置分箱表，生成机制相位叠加图、相对次高峰 lead-lag 图、机制证据矩阵、CO2 廓线结构图和 FL 位置-时间热图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\visualize_ea_timeline_alignment.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R` 是当前全天时间线对齐脚本。它读取 CO2 廓线诊断、raw-w 上升/下沉气团指标、raw-w 风场背景、标准 EC `w'c'` 和 FL 位置分箱结果，输出全天 30 min 对齐表和总览图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_all_day_timelines.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R` 是当前 `04:00-12:00` 事件窗口时间线对齐脚本。它读取全天对齐结果，固定 `06:30` 为日出参考线，并生成事件窗口表、事件关键时间表、标准化叠加图、关键时间对齐图和 FL 事件窗口位置热图。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\align_ea_event_timelines.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R` 是当前 EA 预处理与 30 min 通量计算脚本。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_preprocess.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_daily.R` 是逐日净 EA 通量绘图脚本。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_daily.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_up_down_daily.R` 是 EA 上升/下沉贡献拆分绘图脚本。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_up_down_daily.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_co2_airmasses.R` 是 CO2 上升/下沉气团浓度细化分析脚本。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_co2_airmasses.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R` 是只针对 CO2 的 raw `w` 总输送计算脚本，分别输出 5 min 和 30 min 窗口结果。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R` 是 raw `w` CO2 总输送可视化和汇总脚本。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_total_transport.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_tilt_corrected.R` 是 raw `w` CO2 总输送的经验倾斜/坐标偏差修正脚本。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\run_ea_raw_w_total_transport_tilt_corrected.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_tilt_corrected_transport.R` 是经验修正结果的修正前后对比绘图脚本。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_tilt_corrected_transport.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R` 是当前 raw `w` 局地环流诊断脚本。它生成窗口风场表、raw-w 与风场合并表、`w_mean ~ u_mean + v_mean` 回归、风向扇区统计，以及 FL 沿 `0-245 m` 轨道位置分箱结果。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\diagnose_ea_raw_w_local_circulation.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R` 是 raw-w 上升/下沉气团空气量与 CO2 浓度结构细分脚本。它读取 `EA_raw_w_CO2_total_transport_all_windows.csv`，生成 \(A^+\)、\(A^-\)、\(I_A\)、时间/速度不平衡、`c_up-c_down`、`F_air_amount` 和 `F_conc_anom` 等指标与图件。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\plot_ea_raw_w_up_down_airmass_details.R]
- `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\01_basic_highfreq_wind_qc_3sites.R` 是 `CVT/MT/FL` 四天原始高频水平风基础 QC 和 `1min/5min/30min` 聚合脚本。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\01_basic_highfreq_wind_qc_3sites.R]
- `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\02_apply_north_offset_coordinates.R` 是三站水平风 north_offset 坐标统一脚本；当前口径与 EddyPro 30 min 风向对照基本闭合。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\02_apply_north_offset_coordinates.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\north_offset_coordinates\validation_summary_30min.csv]
- `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\04_apply_fl_motion_correction.R` 是 `FL` 小车速度矢量修正脚本，采用 `U_true = U_measured + V_cart` 口径加回平台运动速度。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\04_apply_fl_motion_correction.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\fl_motion_correction\fl_motion_correction_summary.csv]
- `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\06_visualize_faceted_wind_direction_by_window.R` 和 `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\07_visualize_faceted_wind_speed_by_window.R` 分别生成 `1min/5min/30min` 四天风向和水平风速分面图。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\06_visualize_faceted_wind_direction_by_window.R] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\COMPUTE\07_visualize_faceted_wind_speed_by_window.R]

## 输出

- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism` 保存当前机制可视化图件，包括相位叠加图、lead-lag 图、机制证据矩阵、CO2 廓线结构图和 FL 位置-时间热图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment\figures_mechanism]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment` 保存当前时间线对齐输出，包括 `all_day_timeline_alignment_30min.csv`、`event_window_timeline_alignment_0400_1200_30min.csv`、`event_key_times_0400_1200_30min.csv`、FL 位置对齐表、QC 表和全天/事件窗口图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_timeline_alignment]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv` 是当前主通量结果。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_flux_results.csv]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_daily_figures` 保存逐日净通量图和每日汇总。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_daily_figures]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_up_down_figures` 保存上升/下沉贡献图和拆分表。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_up_down_figures]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_co2_airmass_figures` 保存 CO2 气团浓度细化图和时段统计表。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_co2_airmass_figures]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport` 保存 raw `w` CO2 总输送结果、lag 统计、despike 统计和运行日志。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures` 保存 raw `w` CO2 总输送图、分量对照图和汇总表。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport\EA_raw_w_CO2_figures]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected` 保存 raw `w` CO2 经验修正后的总输送结果、修正系数、拟合块、对比图和运行日志。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_total_transport_tilt_corrected]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics` 保存 raw `w` 局地环流诊断输出，包括窗口风场、FL 位置分箱、回归系数、风向扇区统计、轨道 metadata 和 9 张诊断图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_local_circulation_diagnostics]
- `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details` 保存 raw-w 上升/下沉气团细分输出，包括 5 min 与 30 min 指标表、时段汇总、站点差异表，以及空气量不平衡、CO2 浓度结构和 `F_air_amount`/`F_conc_anom` 分解图。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details]
- `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT` 保存三站水平风前置诊断输出，包括基础 QC、north_offset 坐标统一、`FL` 小车速度修正、风向分面图和水平风速分面图。 [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\basic_highfreq_wind_qc\qc_file_summary.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_direction_faceted_by_window\faceted_wind_direction_figure_manifest.csv] [已核验: D:\00 博士阶段\博一\05 Project\com_3sites_horizontal\OUTPUT\wind_speed_faceted_by_window\faceted_wind_speed_figure_manifest.csv]

## 2026-06-01 com_rotation 坐标旋转敏感性分支

- `D:\00 博士阶段\博一\05 Project\ecpreproc\R\io_dat.R` 当前包含 `CVT` 原始 TOA5 中 `CO2_mixratio/H2O_mixratio` 到 `co2/h2o` 的列名映射。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\io_dat.R]
- `D:\00 博士阶段\博一\05 Project\ecpreproc\R\phys_units.R` 当前包含空气物性计算前的水汽混合比到 `mmol/m3` 内部转换逻辑。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\phys_units.R]
- `D:\00 博士阶段\博一\05 Project\com_rotation\scripts\05_rerun_cvt_segments.R` 是本轮 CVT-only 补跑脚本。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\05_rerun_cvt_segments.R]
- `D:\00 博士阶段\博一\05 Project\com_rotation\scripts\06_initial_stats_visuals.R` 是四方法结果的初步统计和可视化脚本。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\scripts\06_initial_stats_visuals.R]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv` 是当前四方法全量合并主结果。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\rotation_flux_all_common_periods.csv]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis` 保存当前初步统计报告、表格和图件。 [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\analysis]

## 2026-06-03 FL moving-transect anomaly transport

- `D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_pass_anomaly_transport_feasibility.R` 是 FL moving-transect anomaly transport 第一阶段 pass-level 可行性诊断脚本。它复用移动位置匹配逻辑，按移动单程计算 `F_raw`、`F_mean`、`F_turb`、`F_anom_pass_ref`、`A_up/A_down/I_A/lambda` 和 QC 标记。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_pass_anomaly_transport_feasibility.R]
- `D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_position_time_core_plots.R` 是 FL position-time 核心图脚本。它把高频点重新插值到小车位置，按 `10 m` position bin 计算 `F_anom` 和 `w_mean`，并输出三张结构稳定性图。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\run_fl_position_time_core_plots.R]
- `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_anomaly_transport_feasibility.csv` 是 pass-level 主诊断表；`FL_pass_anomaly_transport_daily_summary.csv` 和 `FL_pass_anomaly_transport_flag_summary.csv` 分别保存日尺度汇总和质量标记汇总。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_pass_anomaly_transport_feasibility.csv]
- `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv`、`FL_position_profile_group_summary.csv` 和 `FL_position_profile_stability_summary.csv` 是 position-time 分箱诊断、三组 profile 汇总和结构稳定性汇总表。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv]
- `D:\00 博士阶段\博一\05 Project\com_mass_balance\figures\fig04_position_time_F_anom_heatmap.png`、`fig05_position_time_w_mean_heatmap.png` 和 `fig06_F_anom_position_group_comparison.png` 是本轮要求输出的三张核心图。 [已核验: D:\00 博士阶段\博一\05 Project\com_mass_balance\figures\fig04_position_time_F_anom_heatmap.png]
