# 2026-06-30 MT 固定塔 PF 方案筛选与默认口径判断

## 来源

- 这份记录整理自用户在当前对话中提供的 MT PF 推理、筛选、全量重跑和配对差异分析说明，并对关键脚本和结果文件做了本地存在性与核心数值核验。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW]

## ecpreproc 中 PF 实现边界

- `ecpreproc` 当前 PF/SPF 逻辑是先做预拟合，再按 block 应用拟合参数；当 PF/SPF/CPF/CFPF 输入数据时长小于 `15` 天时，代码会降级为 double rotation。这个 `<15 天降级 DR` 规则不是“每 15 天切块拟合一套 PF”的实现。 [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\R\process_rep_flux.R] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\man\process_rep_flux.Rd]
- `ecpreproc` 中 `PF` 基于有效 30 min block mean 做全局拟合，`SPF` 按风向扇区拟合；用户本轮对 EddyPro 与文献逻辑的整理结论是，PF 通常需要足够长的 assessment period，可按风向扇区拟合，但没有明确要求固定每 `15` 天更新一套 PF。 [来源: 用户当前对话 2026-06-30] [已核验: D:\00 博士阶段\博一\05 Project\ecpreproc\man\rotate_coordinates.Rd]

## 加权 PF 窗口与分组筛选

- 本轮加权筛选脚本为 `E:\Dataset_Level1\MT\EC\PF\WINDOW\run_pf_window_screening_weighted.R`，输入使用已有全量 30 min block-mean，权重为 `min(n_points / 18000, 1)`，比较 `global_pf`、`season_pf`、`season_year_pf`、`sector_pf`、`season_sector_pf`、`30d`、`60d` 和 `90d` 等方案。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\run_pf_window_screening_weighted.R]
- 加权筛选结果使用 `42154` 个 block；按 `rmse_w_after` 排序为：`season_sector_pf=0.10356`、`sector_pf=0.10558`、`window_30d_pf=0.11923`、`window_60d_pf=0.12097`、`season_year_pf=0.12189`、`window_90d_pf=0.12212`、`season_pf=0.12630`、`global_pf=0.13025`。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\results\MT_pf_weighted_scheme_metrics.csv] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\results\MT_pf_weighted_screening_report.md]
- 推断：筛选结果说明 MT 的 PF 残差差异主要由风向结构驱动；额外分季节相对 `sector_pf` 的收益较小，固定 30/60/90 天时间窗口也没有优于扇区方案。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\results\MT_pf_weighted_scheme_metrics.csv] [来源: 用户当前对话 2026-06-30]

## 三组完整通量重跑

- 本轮只保留 `global_pf`、`sector_pf` 和 `season_sector_pf` 三个候选做完整通量重跑；脚本为 `E:\Dataset_Level1\MT\EC\PF\WINDOW\run_mt_three_pf_flux.R`，三组输出各为 `38316` 行。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\run_mt_three_pf_flux.R] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\MT_three_pf_flux_run_summary.csv]
- 三组完整通量结果分别写入 `E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\global_pf\MT_flux_global_pf.csv`、`E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\sector_pf\MT_flux_sector_pf.csv` 和 `E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\season_sector_pf\MT_flux_season_sector_pf.csv`。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\global_pf\MT_flux_global_pf.csv] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\sector_pf\MT_flux_sector_pf.csv] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\season_sector_pf\MT_flux_season_sector_pf.csv]

## 配对差异分析

- 配对差异分析脚本为 `E:\Dataset_Level1\MT\EC\PF\WINDOW\analyze_three_pf_flux_differences.R`；配对后每组使用 `37649` 个唯一 timestamp，相当于从每组 `38316` 行完整输出中去除了 `667` 个重复 timestamp。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\analyze_three_pf_flux_differences.R] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis\MT_pf_flux_paired_analysis_report.md]
- `sector_pf - global_pf` 的总体差异为：`co2_flux mean=-0.1481, mean_abs=0.8757`；`H mean=1.6717, mean_abs=6.2314`；`LE mean=-0.6269, mean_abs=8.4579`；`u_star mean=0.0043, mean_abs=0.0430`。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis\MT_pf_flux_diff_overall.csv]
- `season_sector_pf - sector_pf` 的总体差异为：`co2_flux mean=-0.0029, mean_abs=0.2573`；`H mean=-0.1154, mean_abs=1.8873`；`LE mean=-0.2575, mean_abs=2.4548`；`u_star mean=-0.0003, mean_abs=0.0136`。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis\MT_pf_flux_diff_overall.csv]

## 当前判断

- 当前默认判断是：MT 固定塔后续全量通量处理优先采用 `sector_pf`，暂不把 `season_sector_pf` 作为默认处理，也不默认采用固定 15/30/60/90 天时间窗口 PF。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\results\MT_pf_weighted_scheme_metrics.csv] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis\MT_pf_flux_diff_overall.csv]
- 推断：`season_sector_pf` 可以作为敏感性实验或报告补充，因为它在筛选 RMSE 上略优于 `sector_pf`，但完整通量配对差异显示它相对 `sector_pf` 的增量较小；把 `sector_pf` 设为默认可以保留主要风向依赖，同时避免额外季节分组带来的复杂度。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\results\MT_pf_weighted_scheme_metrics.csv] [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis\MT_pf_flux_diff_overall.csv]

## 关键文件

- 加权筛选结果目录为 `E:\Dataset_Level1\MT\EC\PF\WINDOW\results`，关键文件包括 `MT_pf_weighted_scheme_metrics.csv`、`MT_pf_weighted_fit_parameters.csv` 和 `MT_pf_weighted_screening_report.md`。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\results]
- 三组完整通量结果目录为 `E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs`，全量重跑汇总为 `MT_three_pf_flux_run_summary.csv`。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs]
- 配对差异分析结果目录为 `E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis`，关键文件包括 `MT_pf_flux_diff_overall.csv`、`MT_pf_flux_diff_by_season.csv`、`MT_pf_flux_diff_by_direction.csv`、`MT_pf_flux_paired_differences.csv` 和 `MT_pf_flux_paired_analysis_report.md`。 [已核验: E:\Dataset_Level1\MT\EC\PF\WINDOW\flux_runs\paired_analysis]
