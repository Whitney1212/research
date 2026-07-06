# 构件索引

## 2026-07-06 FL raw/PF F_adv 分组日变化色带图

- `E:\FL_MASSBALANCE\202308\plot_raw_pf_fadv_grouped_with_bands.R` 是 202308 几何放宽批次的 raw/PF `F_adv` 分组日变化重绘脚本；它输出 raw、raw detrended、PF、PF detrended 四张图和对应 CSV/summary，色带为日期层面的 `25-75%` 范围。 [已核验: project_memory/evidence/verifications/2026-07-06_fl_fadv_diurnal_ribbons_raw_pf.md]
- `E:\FL_MASSBALANCE\plot_full_raw_pf_fadv_grouped_with_bands.R` 是全量 raw/PF `F_adv` 分组日变化重绘脚本；raw 输出到 `E:\FL_MASSBALANCE\raw_w_mass_balance_from_1min\figures\diurnal`，PF 输出到 `E:\FL_MASSBALANCE\results\figures\diurnal`。 [已核验: project_memory/evidence/verifications/2026-07-06_fl_fadv_diurnal_ribbons_raw_pf.md]
- `E:\FL_MASSBALANCE\202308\raw_pf_fadv_grouped_with_bands_manifest.csv` 和 `E:\FL_MASSBALANCE\full_raw_pf_fadv_grouped_with_bands_manifest.csv` 分别记录 202308 批次和全量批次四张输出图、CSV 与 summary 的实际路径。 [已核验: project_memory/evidence/verifications/2026-07-06_fl_fadv_diurnal_ribbons_raw_pf.md]

## 2026-07-03 FL 202308 geometry-relaxed raw/PF F_adv

- `E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R` 是当前 FL 质量守恒主脚本；本轮已支持用环境变量覆盖 pass 表、PF 参数表、raw 文件索引、运行记录缓存和轨道端点，并修复 raw 风分支的分钟聚合列生成顺序。 [已核验: project_memory/evidence/verifications/2026-07-03_fl_202308_geometry_relaxed_raw_pf_fadv.md]
- `E:\FL_MASSBALANCE\202308\prepare_geometry_relaxed_passes_for_raw_fadv.R` 将几何放宽完整单程表整理为主脚本可读的 pass 表，输出 `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\fl_complete_passes_geometry_relaxed_track15_255_for_raw_fadv.csv`。 [已核验: project_memory/evidence/verifications/2026-07-03_fl_202308_geometry_relaxed_raw_pf_fadv.md]
- `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255` 保存 raw 风版本 `F_adv` 计算结果；主表为 `results\FL_raw_F_adv_geometry_relaxed_track15_255_by_pass.csv`，1 min 表为 `results\FL_mass_balance_raw_w_1min.csv`，运行摘要为 `FL_raw_F_adv_geometry_relaxed_track15_255_summary.txt`。 [已核验: project_memory/evidence/verifications/2026-07-03_fl_202308_geometry_relaxed_raw_pf_fadv.md]
- `E:\FL_MASSBALANCE\202308\raw_fadv_geometry_relaxed_track15_255\figures\FL_raw_mixed_sign_F_adv_diurnal_mean.png` 是 raw mixed-sign `F_adv` 半小时长期均值图；同目录保存 CSV、summary 和早晨贡献诊断表。 [已核验: project_memory/evidence/verifications/2026-07-03_fl_202308_geometry_relaxed_raw_pf_fadv.md]
- `E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255` 保存 PF 风版本 `F_adv` 计算结果；主表为 `results\FL_pf_F_adv_geometry_relaxed_track15_255_by_pass.csv`，1 min 表为 `results\FL_mass_balance_PF8bin_2ensemble_1min.csv`，运行摘要为 `FL_pf_F_adv_geometry_relaxed_track15_255_summary.txt`。 [已核验: project_memory/evidence/verifications/2026-07-03_fl_202308_geometry_relaxed_raw_pf_fadv.md]
- `E:\FL_MASSBALANCE\202308\pf_fadv_geometry_relaxed_track15_255\figures\FL_pf_mixed_sign_F_adv_diurnal_mean.png` 是 PF mixed-sign `F_adv` 半小时长期均值图；同目录保存 CSV 和 summary。 [已核验: project_memory/evidence/verifications/2026-07-03_fl_202308_geometry_relaxed_raw_pf_fadv.md]

## 2026-07-02 MT/CVT full sector-PF 与 FL 质量守恒 30 min 对比

- `E:\FL_MASSBALANCE\calc_mt_pf_fl_30min_diurnal_mean.R` 是当前 30 min 日变化对比脚本。它读取 `MT/CVT` 全量 `sector_pf` 通量主表，按 `site × halfhour` 计算固定塔均值，并复用 `FL` half-hour closure mean 表合并出 `MT`、`CVT`、`FL_broad` 和 `FL_closed` 四类曲线。 [已核验: project_memory/evidence/verifications/2026-07-02_mt_cvt_fl_30min_diurnal_comparison.md]
- `E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_mean.png` 是当前主对比图；同目录下 `MT_pf_vs_FL_mass_balance_30min_diurnal_mean.csv` 是合并数据，`MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt` 是运行汇总和核验摘要。 [已核验: project_memory/evidence/verifications/2026-07-02_mt_cvt_fl_30min_diurnal_comparison.md]
- `E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_co2_flux_30min_diurnal_mean.csv`、`CVT_pf_co2_flux_30min_diurnal_mean.csv`、`MT_CVT_pf_co2_flux_30min_diurnal_mean.csv` 和 `FL_mass_balance_closure_flux_30min_diurnal_mean.csv` 分别保存 MT、CVT、固定塔合并和 FL closure-class 的 30 min 均值表。 [已核验: project_memory/evidence/verifications/2026-07-02_mt_cvt_fl_30min_diurnal_comparison.md]
- `D:\00 博士阶段\博一\05 Project\com_rotation\results\mt_pf_fl_30min_diurnal` 保存同版脚本、图件、合并表和分项均值表，供 `com_rotation` 分支下继续引用。 [已核验: project_memory/evidence/verifications/2026-07-02_mt_cvt_fl_30min_diurnal_comparison.md]

## 2026-07-01 固定塔全量 sector PF 后通量与可视化

- `E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf.csv` 是当前 MT after-PF 全量通量主表；`figures_flux_means` 保存对应均值可视化图表，绘图脚本为 `D:\00 博士阶段\99 Project\06 EA\scripts\plot_mt_sector_pf_flux_means.R`。 [已核验: project_memory/evidence/verifications/2026-07-01_full_pf_flux_progress_locations.md]
- `D:\00 博士阶段\99 Project\06 EA\scripts\run_cvt_full_sector_pf_flux.R` 是 CVT 全量 `sector_pf` 通量计算脚本；主结果、运行汇总、扇区 PF 汇总和旋转细节输出到 `E:\Dataset_Level1\CVT\EC\PF`。 [已核验: project_memory/evidence/verifications/2026-07-01_full_pf_flux_progress_locations.md]
- `E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf.csv` 是 CVT 当前主通量表；`CVT_flux_sector_pf_validation_summary.csv` 记录 `21447` 行、时间范围 `2024-11-01 00:30` 至 `2026-05-10 15:00`、无重复 timestamp、`pf_schemes=sector_pf`。 [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf_validation_summary.csv]
- `D:\00 博士阶段\99 Project\06 EA\scripts\plot_cvt_sector_pf_flux_means.R` 是 CVT after-PF 通量均值可视化脚本；图表输出在 `E:\Dataset_Level1\CVT\EC\PF\figures_flux_means`，均值表为 `CVT_sector_pf_flux_mean_overall.csv`、`CVT_sector_pf_flux_mean_by_hour.csv` 和 `CVT_sector_pf_flux_mean_by_month_hour.csv`。 [已核验: project_memory/evidence/verifications/2026-07-01_full_pf_flux_progress_locations.md]

## 2026-06-30 MT 固定塔 PF 方案筛选与三组完整通量

- `E:\Dataset_Level1\MT\EC\PF\WINDOW\run_pf_window_screening_weighted.R` 是 MT 固定塔 PF 窗口和分组方案的加权筛选脚本，使用已有全量 30 min block-mean，权重为 `min(n_points / 18000, 1)`。 [已核验: project_memory/evidence/verifications/2026-06-30_mt_pf_sector_selection.md]
- `E:\Dataset_Level1\MT\EC\PF\WINDOW\results\MT_pf_weighted_scheme_metrics.csv`、`MT_pf_weighted_fit_parameters.csv` 和 `MT_pf_weighted_screening_report.md` 是本轮筛选的核心结果，当前支持默认采用 `sector_pf`，把 `season_sector_pf` 作为敏感性实验。 [已核验: project_memory/evidence/verifications/2026-06-30_mt_pf_sector_selection.md]
- `E:\Dataset_Level1\MT\EC\PF\WINDOW\run_mt_three_pf_flux.R` 是 `global_pf`、`sector_pf` 和 `season_sector_pf` 三组完整通量重跑脚本；对应输出位于 `E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs`，全量运行汇总为 `MT_three_pf_flux_run_summary.csv`。 [已核验: project_memory/evidence/verifications/2026-06-30_mt_pf_sector_selection.md]
- `E:\Dataset_Level1\MT\EC\PF\WINDOW\analyze_three_pf_flux_differences.R` 是三组完整通量配对差异分析脚本；配对结果位于 `E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis`，其中 `MT_pf_flux_diff_overall.csv` 和 `MT_pf_flux_paired_analysis_report.md` 是判断默认口径的关键文件。 [已核验: project_memory/evidence/verifications/2026-06-30_mt_pf_sector_selection.md]

## 2026-06-25 FL 运行记录增量与完整单程更新程序

- `E:\FL_pre\scripts\fl_full_records_01_running_records_prepare.R`、`fl_full_records_02_complete_passes_and_ec_availability.R` 和 `fl_full_records_03_plot_complete_pass_coverage.R` 是当前 FL 运行记录全量重建流程。流程先统一 `time/speed/position` 并压缩长静止段，再筛选几何完整单程和 EC key-complete 可用性，最后绘制完整单程覆盖图；运行记录基础文件输出到 `E:\Dataset_Level0\Flares\running_time\records`。 [已核验: E:\FL_pre\scripts\README_FL_records_pipeline.md]
- `E:\FL_pre\scripts\fl_update_records_01_running_records_incremental.R`、`fl_update_records_02_complete_passes_and_ec_availability.R` 和 `fl_update_records_03_plot_complete_pass_coverage.R` 是当前 FL 运行记录增量更新流程。流程默认读取 `records` 下最新 `fl_records_*.csv`，只替换受影响时间窗内的运行记录和完整单程，并支持 `--track-south-m`、`--track-north-m`、`--raw-index-csv` 和覆盖图说明参数。 [已核验: E:\FL_pre\scripts\README_FL_records_pipeline.md]
- 当前完整单程覆盖交付目录为 `E:\Dataset_Level0\Flares\running_time\passes`，固定保留 `fl_complete_pass_coverage_daily.csv`、`fl_complete_pass_coverage_timeline.png`、`fl_complete_passes_incremental_manifest.txt` 三件交付，以及下次增量必须的 `fl_complete_passes_strict.csv` 和 `fl_complete_pass_candidates_all.csv`。旧 `unified_output`、`260611_clasified` 和 `running_time\20260626` 已作为过程目录清理，历史依据保留在 evidence note 中。 [已核验: project_memory/evidence/verifications/2026-06-25_fl_running_records_repair_reasoning_and_cleanup.md] [已核验: E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_incremental_manifest.txt]

## 2026-06-12 FL PF_8bin 参数构件

- `E:\Dataset_Level1\Flares\PFparameter\run_PF_8bin.R` 是当前 FL 移动平台正式 `PF_8bin` 参数生成脚本。它读取完整单程表、FL 高频 EC 数据和统一运行记录，执行逐点运行记录位置插值、实际速度矢量水平风修正、8-bin four-pass ensemble PF 拟合，并生成参数表、A/B 对比图、验证图和方法说明文档。 [已核验: project_memory/evidence/verifications/2026-06-12_fl_pf8bin_record_position_actual_speed.md]
- `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv` 是后续 FL 高频通量计算应调用的正式 PF 参数表。它包含每个 bin 的 `intercept_a`、`slope_b_u`、`slope_c_v`、`tilt_deg`、样本量和 `fit_ok` 信息。 [已核验: project_memory/evidence/verifications/2026-06-12_fl_pf8bin_record_position_actual_speed.md]
- `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md` 是完整但简明的 `PF_8bin` 方法说明文档，记录计算思路、参数设置、关键公式、A/B 对比、拟合结果、验证图和后续使用建议。 [已核验: project_memory/evidence/verifications/2026-06-12_fl_pf8bin_record_position_actual_speed.md]
- `E:\Dataset_Level1\Flares\PFparameter\figures` 保存本次 A/B 预处理对比和 PF 验证图，包括 `fig_ab_*`、`fig_pf8bin_tilt_by_bin.png`、`fig_pf8bin_w_before_after_by_bin.png`、`fig_pf8bin_passbin_w_after_by_direction.png` 等。 [已核验: project_memory/evidence/verifications/2026-06-12_fl_pf8bin_record_position_actual_speed.md]

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
## 2026-06-14 FL PF_8bin 后 EC 与 EA 机制诊断构件

- `D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R` 是当前 FL `PF_8bin` 后四天高频 EC covariance 主计算脚本。它使用 `PF_8bin_parameters_for_flux.csv` 逐点旋转 `w_pf`，并按 `valid_samples_by_bin` 规则输出 30 min EC 结果。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]
- `D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\plot_fl_pf8bin_ec_covariance_20250320_0323.R` 是当前 FL after-PF EC 结果的拆分可视化脚本。它使用 `F_EC_cov_valid_umol_m2_s` 作为主 CO2 通量图口径，并将通量、`wmean`、`sigma_w`、coverage 和 position 拆成不同图件。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]
- `D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\output_fl_pf8bin_ea_mechanism_diagnostics_20250320_0323.R` 是当前 EA/up-down 机制诊断输出脚本。它从 30 min EC 结果派生上下输送贡献、条件浓度差、输送强度和绝对贡献占比等指标。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]
- `D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\flux_30min\FL_PF8bin_EC_covariance_30min.csv` 是当前 FL after-PF 30 min EC 主结果表，共 `378` 行，CO2/H2O 各 `189` 行。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]
- `D:\00 博士阶段\博一\05 Project\com_FLafterPF\results\ea_mechanism` 保存当前 EA 机制诊断表、summary、long-format plot 数据和图件目录；其中 summary 显示上下贡献闭合误差为浮点误差量级。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-14_fl_pf8bin_ec_ea_mechanism_after_pf.md]
- `E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R` 是全量严格完整单程的R质量守恒主脚本；`verify_fl_mass_balance_8bin_2ensemble.R` 是结果完整性和数值平衡核验脚本。主结果、1 min明细、逐日/方向汇总位于 `E:\FL_MASSBALANCE\results`，数据可用性、文件QC和验证摘要位于 `E:\FL_MASSBALANCE\qc`。 [已核验: E:\FL_MASSBALANCE\qc\verification_summary.txt]
- `E:\FL_MASSBALANCE\plot_fl_mass_balance_monthly_transport_heatbands.R` 是质量守恒后垂直输送月度热力色带绘图脚本；`E:\FL_MASSBALANCE\figures\monthly_transport_heatbands` 当前保存15张月份PNG、作图segment表、图件manifest和验证摘要。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_verification.txt]
- `E:\FL_MASSBALANCE\plot_fl_mass_balance_combined_transport_heatband.R` 是质量守恒后垂直输送合并热力色带绘图脚本；输出PNG和manifest为 `FL_mass_balance_transport_heatband_all_valid_dates.*`，横轴只排列125个有效日期且不标注 `low_minute_coverage`。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest.txt]
- `E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_strict.csv` 是当前FL质量守恒重算使用的严格完整单程输入；`ec_raw_files_full_index.csv` 是同目录下的全量EC索引，`records\fl_records_230417_260622.csv` 是当前实际速度与位置插值来源。 [已核验: project_memory/evidence/verifications/2026-06-26_fl_mass_balance_updated_passes_level0.md]
- `E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R` 当前按新严格表起止日期从全量EC索引筛选文件，并直接从统一运行记录派生位置速度；`verify_fl_mass_balance_8bin_2ensemble.R` 已同步改用新pass表和EC索引。 [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R] [已核验: E:\FL_MASSBALANCE\verify_fl_mass_balance_8bin_2ensemble.R]
## 2026-07-01 AP200 剖面 QC 与 QC 后时序

- `E:\Dataset_Level1\MT\AP\QC.R` 是 `MT` AP200 初步 QC 主脚本。它从 `E:\Dataset_RAW\MT\MT_AP\20240704-20260131` 读取 `.dat`，并把原始样本级、轮次级、日级和总体汇总写到 `E:\Dataset_Level0\MT\AP\qc_summary\20240704-20260131`。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-01_ap200_qc_pipeline_mt_cvt.md]
- `E:\Dataset_Level1\MT\AP\Timeseries_afterQC.R` 是 `MT` 的 QC 后时序与 `delta_c` 出图脚本。它依赖已生成的 `cycle_qc_mt`，图件和 `MT_AP_profile_cycle_after_qc_20240704_20260131.csv` 输出到 `E:\Compute_Fcorr\MT_AP_Level1\时序_afterQC`。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-01_ap200_qc_pipeline_mt_cvt.md]
- `E:\Dataset_Level1\CVT\AP\CVT_QC.R` 是 `CVT` AP200 初步 QC 主脚本。它从 `E:\Dataset_Level0\CVT\AP\202411121700-202602020930` 读取 `.dat`，并把汇总结果写到 `E:\Dataset_Level0\CVT\AP\qc_summary\202411121700-202602020930`。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-01_ap200_qc_pipeline_mt_cvt.md]
- `E:\Dataset_Level1\CVT\AP\CVT_timeseries.R` 是 `CVT` 的 QC 后时序出图脚本。它依赖 `cycle_qc_cvt`，图件和 `CVT_AP_profile_cycle_after_qc_20241112_20260202.csv` 输出到 `E:\Compute_Fcorr\CVT_AP_Level1\plot_after_qc`。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-01_ap200_qc_pipeline_mt_cvt.md]
- `D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R` 是当前 `MT/CVT` AP200 全量剖面 QC 的月批执行脚本。它按月写出 raw-file、cycle、after-qc、day、missing-dates、overall、bad-files 和 month-summary，并在不指定月份时自动汇总站点级总表到 `E:\Dataset_Level1\MT\AP\20240704-20260622` 与 `E:\Dataset_Level1\CVT\AP\20240704-20260622`。[已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-01_ap200_monthly_qc_full_run.md]
