---
aliases:
  - 06EA 阶段交付台账
type: registry
registry: deliverables
project: 06EA
updated: 2026-07-14
tags:
  - 06EA
  - registry/deliverable
---

# 06EA 阶段交付台账

> [!tip] 怎么用
> 搜索 `delivery_level:: stage_delivery` 查看阶段交付，搜索 `delivery_level:: paper_candidate` 查看论文候选结果。正式使用前必须同时阅读 `interpretation_boundary` 和 `verification_ref`。

## A-W1-001 FL multicaliber BPF 默认参数产品

> [!success]- 交付属性
> artifact_id:: A-W1-001
> path_id:: [[../runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02]]
> artifact_class:: parameters
> status:: verified
> delivery_level:: stage_delivery
> script_ids:: 
> input_stage:: processed
> input_refs:: `E:\Dataset_Level1\Flares\BPF\PF_8bin` · `E:\Dataset_Level1\Flares\BPF\PF_8bin_2ensemble`
> output_uri:: `E:\Dataset_Level1\Flares\BPF\BPF_default_parameters_for_flux.csv`
> verification_ref:: [[../evidence/verifications/2026-07-09_fl_full_bpf_ec_delivery_and_diurnal]]
> interpretation_boundary:: 作为后续 FL 通量运行默认 PF 参数；不等同于最终通量结果。
> last_verified:: 2026-07-09

## A-W1-002 FL 全量 EC_ecpreproc 多旋转正式交付

> [!success]- 交付属性
> artifact_id:: A-W1-002
> path_id:: [[../runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02]]
> artifact_class:: processed_data
> status:: verified
> delivery_level:: stage_delivery
> script_ids:: [[03_script_registry#S-W1-001 FL 全量多旋转 EC_ecpreproc|S-W1-001]]
> input_stage:: raw_to_processed
> input_refs:: `E:\Dataset_RAW\Flares` · [[#A-W1-001 FL multicaliber BPF 默认参数产品|A-W1-001]]
> output_uri:: `E:\Dataset_Level1\Flares\EC_ecpreproc`
> verification_ref:: [[../evidence/verifications/2026-07-09_fl_full_bpf_ec_delivery_and_diurnal]]
> interpretation_boundary:: FL 是空间约束层，不包装为第三个固定平均通量站。
> last_verified:: 2026-07-09

## A-W1-003 FL 全量 EC pooled 日变化图与作图数据

> [!success]- 交付属性
> artifact_id:: A-W1-003
> path_id:: [[../runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02]]
> artifact_class:: figure_bundle
> status:: verified
> delivery_level:: stage_delivery
> script_ids:: [[03_script_registry#S-W1-002 FL pooled 日变化图|S-W1-002]]
> input_stage:: processed_to_report
> input_refs:: [[#A-W1-002 FL 全量 EC_ecpreproc 多旋转正式交付|A-W1-002]]
> output_uri:: `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_diurnal.png`
> verification_ref:: [[../evidence/verifications/2026-07-09_fl_full_bpf_ec_delivery_and_diurnal]]
> interpretation_boundary:: pooled 日变化用于总体结构比较，不替代事件日或季节分层。
> last_verified:: 2026-07-09

## A-W2-001 W2 2025 固定塔 AP200 QC 后 30 min 基础表

> [!success]- 交付属性
> artifact_id:: A-W2-001
> path_id:: [[../runtime/research_paths/W2-P01_morning_peak_climatology|W2-P01]]
> artifact_class:: interim_data
> status:: verified
> delivery_level:: validated
> script_ids:: [[03_script_registry#S-W2-001 W2 AP200 QC 基础表|S-W2-001]]
> input_stage:: processed_to_interim
> input_refs:: `E:\Dataset_Level1\MT\AP\20240704-20260622` · `E:\Dataset_Level1\CVT\AP\20240704-20260622`
> output_uri:: `E:\Dataset_Level1\MorningPeak\W2_2025_foundation\fixed_tower_ap_profile_2025_30min.csv`
> verification_ref:: [[../evidence/verifications/2026-07-01_w2_morning_peak_rerun_after_ap200_qc]]
> interpretation_boundary:: AP 廓线代理不能直接称为正式 storage flux。
> last_verified:: 2026-07-01

## A-W2-002 W2 2025 固定口径晨间 peak 事件表

> [!success]- 交付属性
> artifact_id:: A-W2-002
> path_id:: [[../runtime/research_paths/W2-P01_morning_peak_climatology|W2-P01]]
> artifact_class:: analysis_table
> status:: verified
> delivery_level:: validated
> script_ids:: [[03_script_registry#S-W2-002 W2 晨间 peak 检测|S-W2-002]]
> input_stage:: interim_to_analysis
> input_refs:: [[#A-W2-001 W2 2025 固定塔 AP200 QC 后 30 min 基础表|A-W2-001]]
> output_uri:: `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025`
> verification_ref:: [[../evidence/verifications/2026-07-02_w2_morning_peak_fixed_rule_overall_decline_rise]]
> interpretation_boundary:: 事件定义已固定；amp > 5 ppm 站点日仍需人工复核后才能成为正式事件目录。
> last_verified:: 2026-07-02

## A-W2-003 W2 单塔频率、双塔分类与缺测三集合

> [!success]- 交付属性
> artifact_id:: A-W2-003
> path_id:: [[../runtime/research_paths/W2-P01_morning_peak_climatology|W2-P01]]
> artifact_class:: analysis_table
> status:: verified
> delivery_level:: validated
> script_ids:: [[03_script_registry#S-W2-003 W2 事件分类|S-W2-003]]
> input_stage:: analysis_to_report
> input_refs:: [[#A-W2-002 W2 2025 固定口径晨间 peak 事件表|A-W2-002]]
> output_uri:: `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections`
> verification_ref:: [[../evidence/verifications/2026-07-01_w2_morning_peak_rerun_after_ap200_qc]]
> interpretation_boundary:: `site_valid_events`、`paired_valid_typing` 和 `paired_missing_one_site` 不得混用。
> last_verified:: 2026-07-02

## A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest

> [!success]- 交付属性
> artifact_id:: A-W3-001
> path_id:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> artifact_class:: input_manifest
> status:: verified
> delivery_level:: stage_delivery
> script_ids:: 
> input_stage:: processed
> input_refs:: `E:\Dataset_Level1\MT\EC` · `E:\Dataset_Level1\CVT\EC`
> output_uri:: `E:\Dataset_Level1\FixedTower\EC\fixed_tower_full_flux_standardized_30min_manifest.csv`
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_standardized_2025]]
> interpretation_boundary:: 公共比较只使用 MT/CVT 共有的 no_rotation、dr、global_pf、sector_pf。
> last_verified:: 2026-07-08

## A-W3-002 W3 标准化公共四方法 annual NEE 汇总

> [!success]- 交付属性
> artifact_id:: A-W3-002
> path_id:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> artifact_class:: analysis_table
> status:: verified
> delivery_level:: paper_candidate
> script_ids:: [[03_script_registry#S-W3-003 W3 标准化方法矩阵运行|S-W3-003]] · [[03_script_registry#S-W3-001 固定塔年度审计|S-W3-001]] · [[03_script_registry#S-W3-002 固定塔年度 NEE 估算|S-W3-002]]
> input_stage:: processed_to_analysis
> input_refs:: [[#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_uri:: `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_common_four_methods_summary.csv`
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_standardized_2025]]
> interpretation_boundary:: 只能称为 EC-only annual NEE estimate / proxy，不是最终碳收支或 NECB。
> last_verified:: 2026-07-13

## A-W3-003 W3 MT/CVT 公共四方法年差异汇总

> [!success]- 交付属性
> artifact_id:: A-W3-003
> path_id:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> artifact_class:: analysis_table
> status:: verified
> delivery_level:: paper_candidate
> script_ids:: [[03_script_registry#S-W3-003 W3 标准化方法矩阵运行|S-W3-003]]
> input_stage:: analysis
> input_refs:: [[#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]]
> output_uri:: `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_mt_cvt_method_difference_summary.csv`
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_standardized_2025]]
> interpretation_boundary:: 塔间差异不能简单归因于 gapfill，也不能忽略筛选口径。
> last_verified:: 2026-07-13

## A-W3-004 W3 rotation 年值、覆盖和差异总结图

> [!success]- 交付属性
> artifact_id:: A-W3-004
> path_id:: [[../runtime/research_paths/W3-P01_annual_nee_delivery|W3-P01]]
> artifact_class:: figure_bundle
> status:: verified
> delivery_level:: paper_candidate
> script_ids:: [[03_script_registry#S-W3-004 W3 rotation 总结图|S-W3-004]]
> input_stage:: analysis_to_report
> input_refs:: [[#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]] · [[#A-W3-003 W3 MT/CVT 公共四方法年差异汇总|A-W3-003]]
> output_uri:: `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\figures`
> verification_ref:: [[../evidence/verifications/2026-07-08_fixed_tower_rotation_sensitivity_visualization]]
> interpretation_boundary:: 主图只比较公共四方法，MT-only season_sector_pf 只保留为补充敏感性。
> last_verified:: 2026-07-08

## A-W3-005 共同有效观测窗口 NEE 与 full gapfilled 对照

> [!success]- 交付属性
> artifact_id:: A-W3-005
> path_id:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> artifact_class:: diagnostic_table
> status:: verified
> delivery_level:: validated
> script_ids:: [[03_script_registry#S-W3-005 共同有效窗口 NEE|S-W3-005]]
> input_stage:: analysis
> input_refs:: [[#A-W3-002 W3 标准化公共四方法 annual NEE 汇总|A-W3-002]]
> output_uri:: `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\common_observed_window_nee`
> verification_ref:: [[../evidence/verifications/2026-07-10_fixed_tower_common_observed_window_nee]]
> interpretation_boundary:: 共同窗口年化值是诊断量，不替代正式 annual NEE。
> last_verified:: 2026-07-10

## A-W3-006 共同四方法高频交换诊断

> [!success]- 交付属性
> artifact_id:: A-W3-006
> path_id:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> artifact_class:: diagnostic_table
> status:: verified
> delivery_level:: validated
> script_ids:: [[03_script_registry#S-W3-008 共同四方法高频交换诊断|S-W3-008]]
> input_stage:: processed_to_analysis
> input_refs:: [[#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_uri:: `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025\no_rotation\MT_common_four_method_valid_window_exchange_diagnostics_2025.csv` · `E:\Dataset_Level1\CVT\EC\whole year computation\rotation_sensitivity_standardized_2025\no_rotation\CVT_common_four_method_valid_window_exchange_diagnostics_2025.csv`
> verification_ref:: [[../evidence/verifications/2026-07-13_fixed_tower_common_four_method_exchange_diagnostics_rerun]]
> interpretation_boundary:: 登记的是两塔 no_rotation 目录中的代表文件；四种方法目录均有对应同键表。只使用 strict 共同有效窗口，-99999 CO2 sentinel 必须按缺测处理。
> last_verified:: 2026-07-13
## A-W3-007 2025 硬 QC 共同窗口 rotation 三风向投影分解

> [!warning]- 交付属性
> artifact_id:: A-W3-007
> path_id:: [[../runtime/research_paths/W3-P02_rotation_qc_gapfill|W3-P02]]
> artifact_class:: diagnostic_table
> status:: provisional
> delivery_level:: validated_internal_closure
> script_ids:: [[03_script_registry#S-W3-009 2025 NEE 对齐 rotation 三风向投影重算|S-W3-009]]
> input_stage:: level0_to_analysis
> input_refs:: [[#A-W3-001 固定塔全量 rotation 标准化 30 min 输入 manifest|A-W3-001]]
> output_uri:: `E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv`
> verification_ref:: [[../evidence/verifications/2026-07-16_fixed_tower_nee_aligned_rotation_projection_2025]]
> interpretation_boundary:: 三方向投影在重算链内部严格闭合；rotation 方法与既有硬 QC 基准仍有窗口级差异，暂不标记为逐窗口完全对齐。
> last_verified:: 2026-07-16
