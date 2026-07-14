# 2026-07-14 固定塔硬 QC 共同窗口差异与 MET 配对核验

## 口径与时间键

- 本轮只使用计算阶段硬 QC 后、`MT/CVT` 两塔及 `no_rotation / dr / global_pf / sector_pf` 四方法共同存在的 2025 半小时窗口；不追加 `qc_co2`、`flag9_co2`、夜间 `u*`、平稳性、频谱 QC 或 gapfill 筛选。共同窗口为 `12,471` 个，配对主表为 `49,884 = 12,471 × 4` 行。[来源: 用户当前对话 2026-07-14] [已核验: E:\Dataset_Level1\Comparison\MT_CVT\hard_qc_common_window_manifest_2025.csv] [已核验: E:\Dataset_Level1\Comparison\MT_CVT\MT_CVT_hard_qc_paired_flux_difference_2025.csv]
- 高频块时间键按半小时起始时间向下归属，例如 `2025-01-22 16:00:17.85` 归入 `2025-01-22 16:00:00`，避免把高频文件首条采样时刻误当成必须精确落整点的窗口键。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_four_method_exchange_diagnostics_2025.R]

## 重建与差异结果

- `MT` 和 `CVT` 均完成 `12,471/12,471` 个共同窗口的高频属性重建，包括 `sigma_w`、平均垂直风、旋转角、原始平均水平风、矢量平均风速和 CO2 协方差诊断。[已核验: E:\Dataset_Level1\Comparison\MT\MT_hard_qc_common_window_attributes_2025.csv] [已核验: E:\Dataset_Level1\Comparison\CVT\CVT_hard_qc_common_window_attributes_2025.csv]
- 半小时差异定义为 `D = F_CVT - F_MT`，碳贡献定义为 `C = D × 1800 × 12 × 10^-6`。四方法累计 `C` 分别为 `no_rotation 279.9553`、`dr 538.0198`、`global_pf 398.2928`、`sector_pf 362.1800 gC m^-2`；四者均为正，表示该共同窗口内 `MT` 总体比 `CVT` 更负。[已核验: E:\Dataset_Level1\Comparison\MT_CVT\MT_CVT_hard_qc_paired_flux_difference_2025_summary.csv]
- 1 日和 3 日 block bootstrap 均完成 `2,000` 次；3 日块累计差异 95% CI 分别为 `198.9430–363.2535`、`437.3149–641.0677`、`311.0396–488.5342`、`290.9850–434.6831 gC m^-2`，顺序同上。[已核验: E:\Dataset_Level1\Comparison\MT_CVT\MT_CVT_hard_qc_block_bootstrap_overall_3d_2000rep.csv]
- 最终 8 项检查全部通过，包括共同窗口数、每时间戳四方法、累计差异与既有硬 QC 跨塔结果一致，以及月份、半小时、季节、日夜分组可重构总差异。[已核验: E:\Dataset_Level1\Comparison\MT_CVT\MT_CVT_hard_qc_comparison_verification_2025.csv]

## MET 配对

- 已按同一半小时起始时间戳，把 `MT/CVT` 的 `rn`、`ta_ec`、`rh_ec`、`vpd`、`ws_ec`、`wd_ec`、`rain_flag`、`n_records` 及各变量插值标记左连接到配对主表，字段分别带 `_mt` 与 `_cvt` 后缀。两份 MET 表时间戳唯一，`12,471` 个共同窗口均存在对应时间键；长缺测仍保留 `NA`。[已核验: E:\Dataset_Level1\MT\MET\MT_MET_30min_full.csv] [已核验: E:\Dataset_Level1\CVT\MET\CVT_MET_30min_full.csv] [已核验: E:\Dataset_Level1\Comparison\scripts\03_build_paired_hard_qc_difference_master.R]
- 在 `12,471` 个唯一窗口中，`rn/vpd` 有效窗口为 `MT 10,242`、`CVT 12,459`；两塔 `rain_flag` 同时有记录的 `10,233` 个窗口中无不一致。[已核验: E:\Dataset_Level1\Comparison\MT_CVT\MT_CVT_hard_qc_paired_flux_difference_2025.csv]

## 交付位置与边界

- 计算脚本与输出根目录为 `E:\Dataset_Level1\Comparison`；主配对表为 `MT_CVT\MT_CVT_hard_qc_paired_flux_difference_2025.csv`，四方法小提琴图为 `MT_CVT\figures\MT_CVT_hard_qc_rotation_violin.png/pdf`。[已核验: E:\Dataset_Level1\Comparison]
- 该结果描述的是硬 QC 共同观测窗口内的塔间差异，不是全年外推值；共同窗口可能在季节、时段和气象状态上分布不均。[来源: 用户当前对话 2026-07-14]
