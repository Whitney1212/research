# 2026-07-02 MT/CVT full sector-PF 与 FL 质量守恒 30 min 日变化对比

## 来源

- 这份记录整理自当前对话中对 `MT/CVT` 全量 `sector_pf` 通量和 `FL` 质量守恒 half-hour 均值的对比计算要求，以及本地已经生成的脚本、汇总文件和图件。 [来源: 用户当前对话 2026-07-01 至 2026-07-02] [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt]

## 本次新增信息

- 已用 `E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf.csv` 和 `E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf.csv` 作为固定塔全量 `sector_pf` 通量输入，重新计算 30 min 长期日变化均值；`FL` 端没有重新计算质量守恒，而是复用官方 half-hour closure mean 表 `E:\FL_MASSBALANCE\figures\lambda_diagnostics\FL_mass_balance_closure_mean_flux_by_hour_half_hour.csv`。 [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt]
- 本次固定塔参与均值的记录数为 `MT=38316`、`CVT=21447`，日期数为 `MT=883`、`CVT=493`；参与比较的时间范围为 `MT: 2023-06-19 10:28:13` 至 `2026-06-22 13:30:00`，`CVT: 2024-11-01 00:30:00` 至 `2026-05-10 15:00:00`。 [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt]
- `FL` 参与对比的 half-hour 表共有 `96` 行，其中 `broad_closed=48`、`numerically_closed=48`；合并输出表共有 `192` 行，对应 `MT`、`CVT`、`FL_broad` 和 `FL_closed` 四条 30 min 日变化曲线。 [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt]
- 输出图为 `E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_mean.png`，合并数据为 `E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_mean.csv`，脚本为 `E:\FL_MASSBALANCE\calc_mt_pf_fl_30min_diurnal_mean.R`；脚本和结果已经同步复制到 `D:\00 博士阶段\博一\05 Project\com_rotation\results\mt_pf_fl_30min_diurnal`。 [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt] [已核验: D:\00 博士阶段\博一\05 Project\com_rotation\results\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt]

## 和现有记忆的关系

- 这次对比把 2026-07-01 已记录的固定塔全量 `sector_pf` 通量产品，和 2026-06-28 已记录的 `FL` 质量守恒 half-hour closure mean 表接到同一张 30 min 日变化图中；它没有改变 `MT/CVT` 的默认 PF 口径，也没有改变 `FL` 质量守恒的闭合分类口径。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-01_full_pf_flux_progress_locations.md] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-28_fl_mass_balance_closure_mean_flux_and_filtered_heatmaps.md] [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt]
- 图形口径按用户要求简化为 `MT`、`CVT`、`FL_broad` 和 `FL_closed` 四类；`MT/CVT` 不再用圆点表达数据量，`FL` 仍保留点大小表达参与均值的日期数。 [来源: 用户当前对话 2026-07-01] [已核验: E:\FL_MASSBALANCE\calc_mt_pf_fl_30min_diurnal_mean.R]

## 需要保留的解释边界

- 这张图适合用作长期日变化形态的同口径 30 min 对比；固定塔曲线来自全量 `sector_pf co2_flux`，`FL` 曲线来自质量守恒 closure-class 诊断输送量，因此不应把 `FL_broad/FL_closed` 直接写成最终生态系统 CO2 通量。 [推断：基于固定塔 full sector-PF 输出和 FL closure mean 方法边界整理] [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-06-28_fl_mass_balance_closure_mean_flux_and_filtered_heatmaps.md]

## 仍待确认

- 如果后续要在报告中正式解释 `MT` 与 `CVT` 的绝对通量差异，还需要明确是否按 `qc_co2` 进一步筛选；本次均值记录了 `qc_co2` 计数，但没有把它作为额外筛选条件。 [已核验: E:\FL_MASSBALANCE\figures\mt_pf_fl_30min_diurnal\MT_pf_vs_FL_mass_balance_30min_diurnal_summary.txt]
