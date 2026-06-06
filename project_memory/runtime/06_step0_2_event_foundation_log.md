# Step0-2 CO2 事件前置数据基础执行记录

执行日期：2026-06-04  
本地输出根目录：`D:\00 博士阶段\博一\05 Project\com_assemble`

## 完成状态

本轮已用 `R 4.3.3` 执行 `Step0`、`Step1`、`Step2`，只建立假设验证前的数据基础。2026-06-04 19:18 后已根据远端 `origin/main:next_step/2026-06-04_CO2_event_competing_hypotheses_execution_plan.md` 重新执行，并把该 plan 保存为本地 provenance 快照。新增脚本、表格、图件、日志、报告和 provenance 均写入本地 `com_assemble` 目录；research 仓库只保留本条简短 project memory 记录。未执行 H1/H2/H3/H4/H5/H6 机制判断、评分或结论，未做 FL 空间形态分类，未做 rotation/方法风险评分或最终机制排序。  
[已核验: D:\00 博士阶段\博一\05 Project\com_assemble\outputs\logs\step0_2_run_log.md] [已核验: D:\00 博士阶段\博一\05 Project\com_assemble\outputs\provenance\step0_2_provenance.json]

## 生成表格清单

- `outputs\tables\00_data_inventory.csv`
- `outputs\tables\00_time_axis_check.csv`
- `outputs\tables\00_variable_dictionary.csv`
- `outputs\tables\01_event_master_table.csv`
- `outputs\tables\02_event_aligned_5min.csv`，本次按 plan 的 Step2 聚合 `pre_bg`、`profile_transition`、`pre_min`、`rise_to_peak`、`post_decline`、`peak2`、`midday`、`night` 共 8 个窗口。
- `outputs\tables\02_event_aligned_30min.csv`，本次按 plan 的 Step2 聚合 `pre_bg`、`profile_transition`、`pre_min`、`rise_to_peak`、`post_decline`、`peak2`、`midday`、`night` 共 8 个窗口。
- `outputs\tables\02_event_phase_summary.csv`

## 生成图件清单

- `outputs\figures\fig00_data_coverage_gantt.png`
- `outputs\figures\fig00_timestamp_interval_hist.png`
- `outputs\figures\fig00_missingness_heatmap.png`
- `outputs\figures\fig01_event_timeline_by_day.png`
- `outputs\figures\fig02_event_phase_lag_matrix.png`
- `outputs\figures\fig03_station_co2_phase_alignment.png`
- `outputs\figures\fig04_multivariable_event_panel.png`
- `outputs\figures\fig05_variable_lag_to_peak2.png`
- `outputs\figures\fig06_phase_boxplot_by_variable.png`

## 关键输入与脚本来源

本轮复用的核心输入包括远端 execution plan 快照、`event_key_times_0400_1200_30min.csv`、`event_window_timeline_alignment_0400_1200_30min.csv`、`all_day_timeline_alignment_30min.csv`、`EA_flux_results.csv`、`EA_raw_w_up_down_airmass_metrics_all_windows.csv`、三站 motion-corrected wind `5min/30min` 表、`FL_pass_anomaly_transport_feasibility.csv` 和 `FL_position_time_pass_bin_diagnostics.csv`。对应既有脚本主要来自 `ecpreproc`、`com_3sites_horizontal\COMPUTE` 和 `com_mass_balance`。本轮新增脚本为 `D:\00 博士阶段\博一\05 Project\com_assemble\scripts\build_step0_2_event_foundation.R`。  
[已核验: D:\00 博士阶段\博一\05 Project\com_assemble\outputs\reports\existing_code_and_results_index.md]

## 缺失输入与 partial 项

远端 execution plan 已读取并保存到 `outputs\provenance\2026-06-04_CO2_event_competing_hypotheses_execution_plan.remote_snapshot.md`，缺失报告不再把 plan 作为硬性缺失输入。`FL` 四个站点日期没有固定 CO2 事件节点：缺少 `t_profile_switch`、`t_pre_min`、`t_peak2` 和 `t_decline_end`，因此事件主表中 `FL` 四行保持 partial。`02_event_aligned_5min.csv` 因缺少 5 min profile/AP、标准 EA/EC、`ustar`、`H` 等产品，`96/96` 行保留 partial；`02_event_aligned_30min.csv` 有 `43/96` 行 partial。  
[已核验: D:\00 博士阶段\博一\05 Project\com_assemble\outputs\logs\missing_inputs_report.md]

## Step3 readiness

暂不建议直接进入 Step3。最小补充数据是确认 Step3 是否只使用 `CVT/MT` 固定塔 CO2 事件节点，或是否需要为 `FL` 建立独立 CO2 事件节点。若 Step3 需要 5 min 尺度的 profile/AP、EA/EC 或 MET 变量，还需要先提供对应 5 min 产品或明确这些字段只使用 30 min 对齐结果。  
[已核验: D:\00 博士阶段\博一\05 Project\com_assemble\outputs\reports\step0_2_summary.md]
