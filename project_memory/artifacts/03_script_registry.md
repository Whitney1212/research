---
aliases:
  - 06EA 可复用脚本台账
type: registry
registry: scripts
project: 06EA
updated: 2026-07-21
tags:
  - 06EA
  - registry/script
---

# 06EA 可复用脚本台账

> [!tip] 怎么用
> 优先搜索 `reusability:: workflow` 找正式入口，或搜索 `reusability:: parameterized` 找可换参数复用的脚本。`active` 只表示当前有效；实际运行前仍需打开 `verification_ref` 检查口径。

## S-W1-001 FL 全量多旋转 EC_ecpreproc

> [!code]- 脚本属性
> script_id:: S-W1-001
> path_ids:: [[../runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02]]
> repository_path:: [run_fl_full_ec_multirotation_ecpreproc.R](../../scripts/run_fl_full_ec_multirotation_ecpreproc.R)
> language:: R
> purpose:: 运行 FL 全量 no_rotation、dr、PF_8bin_2ensemble EC_ecpreproc 并生成 manifest/registry。
> pipeline_stage:: transform
> reusability:: workflow
> parameterized:: yes
> self_check:: 运行日志与 registry QC
> input_artifact_ids:: [[02_deliverable_registry#A-W1-001 FL multicaliber BPF 默认参数产品|A-W1-001]]
> output_artifact_ids:: [[02_deliverable_registry#A-W1-002 FL 全量 EC_ecpreproc 多旋转正式交付|A-W1-002]]
> status:: active
> last_validated:: 2026-07-09
> verification_ref:: [[../evidence/verifications/2026-07-09_fl_full_bpf_ec_delivery_and_diurnal]]

## S-W1-003 FL 0–245 m 固定 8-bin BPF 标准训练

> [!code]- 脚本属性
> script_id:: S-W1-003
> path_ids:: [[../runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02]]
> repository_path:: [run_fl_bpf_0_245_8bin.R](../../scripts/run_fl_bpf_0_245_8bin.R)
> language:: R
> purpose:: 以既有 PF8 高处理主链重建 FL 0–245 m 固定八等分参数；主拟合使用 main_complete 与去重 oldcode，PF2 不跨 source_group 配对。
> pipeline_stage:: parameterize
> reusability:: workflow
> parameterized:: limited
> self_check:: 固定边界、8/8 fit_ok、各 bin 输入/方向、去重、跨来源 ensemble 和残差检查。
> input_artifact_ids:: 
> output_artifact_ids:: [[02_deliverable_registry#A-W1-001 FL multicaliber BPF 默认参数产品|A-W1-001]]
> status:: active
> last_validated:: 2026-07-21
> verification_ref:: [[../evidence/verifications/2026-07-21_fl_bpf_0_245_fixed8_rebuild]]

## S-W1-002 FL pooled 日变化图

> [!code]- 脚本属性
> script_id:: S-W1-002
> path_ids:: [[../runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02]]
> repository_path:: [plot_fl_full_ec_diurnal.R](../../scripts/plot_fl_full_ec_diurnal.R)
> language:: R
> purpose:: 从正式 30 min 结果生成 FL pooled 日变化图与作图数据。
> pipeline_stage:: visualize
> reusability:: parameterized
> parameterized:: limited
> self_check:: 输出 summary 与 plot data
> input_artifact_ids:: [[02_deliverable_registry#A-W1-002 FL 全量 EC_ecpreproc 多旋转正式交付|A-W1-002]]
> output_artifact_ids:: [[02_deliverable_registry#A-W1-003 FL 全量 EC pooled 日变化图与作图数据|A-W1-003]]
> status:: active
> last_validated:: 2026-07-09
> verification_ref:: [[../evidence/verifications/2026-07-09_fl_full_bpf_ec_delivery_and_diurnal]]

## S-W2-001 W2 AP200 QC 基础表

> [!code]- 脚本属性
> script_id:: S-W2-001
> path_ids:: [[../runtime/research_paths/W2-P01_morning_peak_climatology|W2-P01]]
> repository_path:: [build_morning_peak_foundation_from_ap_qc_2025.R](../../scripts/build_morning_peak_foundation_from_ap_qc_2025.R)
> language:: R
> purpose:: 从 AP200 QC 后 cycle 数据构建 W2 2025 固定塔 30 min 基础表。
> pipeline_stage:: prepare
> reusability:: workflow
> parameterized:: limited
> self_check:: 时间写出与覆盖核验
> input_artifact_ids:: 
> output_artifact_ids:: [[02_deliverable_registry#A-W2-001 W2 2025 固定塔 AP200 QC 后 30 min 基础表|A-W2-001]]
> status:: active
> last_validated:: 2026-07-01
> verification_ref:: [[../evidence/verifications/2026-07-01_w2_morning_peak_rerun_after_ap200_qc]]

## S-W2-002 W2 晨间 peak 检测

> [!code]- 脚本属性
> script_id:: S-W2-002
> path_ids:: [[../runtime/research_paths/W2-P01_morning_peak_climatology|W2-P01]]
> repository_path:: [detect_morning_peak_events_2025.R](../../scripts/detect_morning_peak_events_2025.R)
> language:: R
> purpose:: 按固定日出相对窗口和整体下降—上升规则检测晨间 peak。
> pipeline_stage:: analyze
> reusability:: parameterized
> parameterized:: yes
> self_check:: `--self-test`
> input_artifact_ids:: [[02_deliverable_registry#A-W2-001 W2 2025 固定塔 AP200 QC 后 30 min 基础表|A-W2-001]]
> output_artifact_ids:: [[02_deliverable_registry#A-W2-002 W2 2025 固定口径晨间 peak 事件表|A-W2-002]]
> status:: active
> last_validated:: 2026-07-02
> verification_ref:: [[../evidence/verifications/2026-07-02_w2_morning_peak_fixed_rule_overall_decline_rise]]

## S-W2-003 W2 事件分类

> [!code]- 脚本属性
> script_id:: S-W2-003
> path_ids:: [[../runtime/research_paths/W2-P01_morning_peak_climatology|W2-P01]]
> repository_path:: [build_morning_peak_event_types_2025.R](../../scripts/build_morning_peak_event_types_2025.R)
> language:: R
> purpose:: 生成单塔频率、双塔有效分类和一塔缺测三套集合。
> pipeline_stage:: analyze
> reusability:: parameterized
> parameterized:: yes
> self_check:: `--self-test`
> input_artifact_ids:: [[02_deliverable_registry#A-W2-002 W2 2025 固定口径晨间 peak 事件表|A-W2-002]]
> output_artifact_ids:: [[02_deliverable_registry#A-W2-003 W2 单塔频率、双塔分类与缺测三集合|A-W2-003]]
> status:: active
> last_validated:: 2026-07-02
> verification_ref:: [[../evidence/verifications/2026-06-30_w2_morning_peak_event_typing_observed_unknown]]

## S-W3-001 固定塔年度审计

> [!code]- 脚本属性
> script_id:: S-W3-001
> path_ids:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> repository_path:: [build_fixed_tower_ec_year_audit.R](../../scripts/build_fixed_tower_ec_year_audit.R)
> language:: R
> purpose:: 构建固定塔年度覆盖、QC 和有效窗口审计。
> pipeline_stage:: qc
> reusability:: parameterized
> parameterized:: yes
> self_check:: year audit summaries
> input_artifact_ids:: [[02_deliverable_registry#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_artifact_ids:: [[02_deliverable_registry#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]]
> status:: active
> last_validated:: 2026-07-08
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_standardized_2025]]

## S-W3-002 固定塔年度 NEE 估算

> [!code]- 脚本属性
> script_id:: S-W3-002
> path_ids:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> repository_path:: [estimate_fixed_tower_nee_2025.R](../../scripts/estimate_fixed_tower_nee_2025.R)
> language:: R
> purpose:: 执行严格筛选、gapfilling 和 EC-only annual NEE 积分。
> pipeline_stage:: analyze
> reusability:: parameterized
> parameterized:: yes
> self_check:: 输出覆盖与 gapfill summary
> input_artifact_ids:: [[02_deliverable_registry#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_artifact_ids:: [[02_deliverable_registry#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]]
> status:: active
> last_validated:: 2026-07-08
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_standardized_2025]]

## S-W3-003 W3 标准化方法矩阵运行

> [!code]- 脚本属性
> script_id:: S-W3-003
> path_ids:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> repository_path:: [run_fixed_tower_rotation_sensitivity_standardized_2025.R](../../scripts/run_fixed_tower_rotation_sensitivity_standardized_2025.R)
> language:: R
> purpose:: 按标准化 manifest 批量运行方法矩阵并汇总年值和塔间差异。
> pipeline_stage:: orchestrate
> reusability:: workflow
> parameterized:: yes
> self_check:: run plan 与汇总表完整性
> input_artifact_ids:: [[02_deliverable_registry#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_artifact_ids:: [[02_deliverable_registry#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]] · [[02_deliverable_registry#A-W3-003 W3 MT/CVT 公共四方法年差异汇总|A-W3-003]]
> status:: active
> last_validated:: 2026-07-08
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_standardized_2025]]

## S-W3-004 W3 rotation 总结图

> [!code]- 脚本属性
> script_id:: S-W3-004
> path_ids:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> repository_path:: [plot_fixed_tower_rotation_sensitivity_standardized_2025.R](../../scripts/plot_fixed_tower_rotation_sensitivity_standardized_2025.R)
> language:: R
> purpose:: 生成公共四方法年值、覆盖和差异总结图。
> pipeline_stage:: visualize
> reusability:: parameterized
> parameterized:: limited
> self_check:: 图件和 plot data
> input_artifact_ids:: [[02_deliverable_registry#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]] · [[02_deliverable_registry#A-W3-003 W3 MT/CVT 公共四方法年差异汇总|A-W3-003]]
> output_artifact_ids:: [[02_deliverable_registry#A-W3-004 W3 rotation 年值、覆盖和差异总结图|A-W3-004]]
> status:: active
> last_validated:: 2026-07-08
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_visualization]]

## S-W3-005 共同有效窗口 NEE

> [!code]- 脚本属性
> script_id:: S-W3-005
> path_ids:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> repository_path:: [compute_fixed_tower_common_observed_window_nee_2025.R](../../scripts/compute_fixed_tower_common_observed_window_nee_2025.R)
> language:: R
> purpose:: 计算双塔同一方法共同有效窗口的 NEE 诊断并与 full gapfilled 对照。
> pipeline_stage:: diagnose
> reusability:: parameterized
> parameterized:: yes
> self_check:: strict 与 no_qc_no_flag9 场景核验
> input_artifact_ids:: [[02_deliverable_registry#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]]
> output_artifact_ids:: [[02_deliverable_registry#A-W3-005 共同有效观测窗口 NEE 与 full gapfilled 对照|A-W3-005]]
> status:: active
> last_validated:: 2026-07-10
> verification_ref:: [[../evidence/verifications/2026-07-10_fixed_tower_common_observed_window_nee]]

## S-W3-006 gapfilled-only 塔间差异分解

> [!code]- 脚本属性
> script_id:: S-W3-006
> path_ids:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> repository_path:: [compute_fixed_tower_gapfilled_only_difference_2025.R](../../scripts/compute_fixed_tower_gapfilled_only_difference_2025.R)
> language:: R
> purpose:: 分解至少一塔 gapfilled 窗口对 CVT-MT 年差异的贡献。
> pipeline_stage:: diagnose
> reusability:: parameterized
> parameterized:: yes
> self_check:: strict 与 no_qc_no_flag9 场景核验
> input_artifact_ids:: [[02_deliverable_registry#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]]
> output_artifact_ids:: 
> status:: active
> last_validated:: 2026-07-10
> verification_ref:: [[../evidence/verifications/2026-07-10_fixed_tower_gapfilled_only_difference_decomposition]]

## S-W3-007 10–18 时段差异贡献

> [!code]- 脚本属性
> script_id:: S-W3-007
> path_ids:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> repository_path:: [compute_fixed_tower_10_18_difference_contribution_2025.R](../../scripts/compute_fixed_tower_10_18_difference_contribution_2025.R)
> language:: R
> purpose:: 计算 10:00–18:00 对全年 CVT-MT 差异的累计贡献。
> pipeline_stage:: diagnose
> reusability:: parameterized
> parameterized:: yes
> self_check:: 双场景合并表核验
> input_artifact_ids:: [[02_deliverable_registry#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]]
> output_artifact_ids:: 
> status:: active
> last_validated:: 2026-07-10
> verification_ref:: [[../evidence/verifications/2026-07-10_fixed_tower_10_18_difference_contribution]]

## S-W3-008 共同四方法高频交换诊断

> [!code]- 脚本属性
> script_id:: S-W3-008
> path_ids:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> repository_path:: [compute_fixed_tower_common_four_method_exchange_diagnostics_2025.R](../../scripts/compute_fixed_tower_common_four_method_exchange_diagnostics_2025.R)
> language:: R
> purpose:: 在 strict 共同有效窗口计算四方法 sigma_w、sigma_c、rwc、Fc、Fneg 和 Fpos。
> pipeline_stage:: diagnose
> reusability:: parameterized
> parameterized:: yes
> self_check:: 共同键、有限值与 sentinel 检查
> input_artifact_ids:: [[02_deliverable_registry#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_artifact_ids:: [[02_deliverable_registry#A-W3-006 共同四方法高频交换诊断|A-W3-006]]
> status:: active
> last_validated:: 2026-07-13
> verification_ref:: [[../evidence/verifications/2026-07-13_fixed_tower_common_four_method_exchange_diagnostics_rerun]]
## S-W3-009 2025 NEE 对齐 rotation 三风向投影重算

> [!code]- 脚本属性
> script_id:: S-W3-009
> path_ids:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> repository_path:: [rebuild_rotation_nee_aligned_projection_2025.R](../../scripts/rebuild_rotation_nee_aligned_projection_2025.R)
> language:: R
> purpose:: 在 2025 硬 QC 共同窗口内重算四种公共 rotation，并将相对 no_rotation 的 NEE 差异拆为 u'c'、v'c'、w'c' 三方向投影。
> pipeline_stage:: diagnose
> reusability:: parameterized
> parameterized:: yes
> self_check:: R parse、共同窗口一致性、flux/delta 投影闭合、重算与既有基准差异
> input_artifact_ids:: [[02_deliverable_registry#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_artifact_ids:: [[02_deliverable_registry#A-W3-007 2025 硬 QC 共同窗口 rotation 三风向投影分解|A-W3-007]]
> status:: provisional
> last_validated:: 2026-07-16
> verification_ref:: [[../evidence/verifications/2026-07-16_fixed_tower_nee_aligned_rotation_projection_2025]]
