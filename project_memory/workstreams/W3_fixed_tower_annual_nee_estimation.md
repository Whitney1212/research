# W3 两固定塔 2025 自然年 NEE 估算

## 目标

这条工作流专门维护 `MT/CVT` 两固定塔的 `2025` 自然年 `EC-only annual NEE estimate / proxy`，把覆盖审计、gapfilling、长缺口、筛选敏感性和对外表述边界从 `W1/W2` 中拆开。 [来源: 用户当前对话 2026-07-05 至 2026-07-06] [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-06_fixed_tower_nee_gapfill.md]

## 当前已确认

- 输入主表固定为 `E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf.csv` 和 `E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf.csv`。 [已核验: E:\Dataset_Level1\MT\EC\Flux_ecprecproc_afterPF\MT_flux_sector_pf.csv] [已核验: E:\Dataset_Level1\CVT\EC\PF\CVT_flux_sector_pf.csv]
- 当前第一版目标年固定为 `2025`，因为它是两塔现有全量数据里更适合作为双塔比较主分析年的自然年。 [来源: 用户当前对话 2026-07-05] [已核验: E:\Dataset_Level1\MT\EC\whole year computation\MT_ec_2025_year_audit_summary.csv] [已核验: E:\Dataset_Level1\CVT\EC\whole year computation\CVT_ec_2025_year_audit_summary.csv]
- 当前默认主结果使用严格版筛选，即 `qc_co2 <= 1 + flag9_co2 <= 3 + 夜间 u*`，然后执行“短缺口线性内插 + 同塔多年份 climatology + 跨塔同期回归兜底”的 gapfilling。 [来源: 用户当前对话 2026-07-05] [已核验: E:\Dataset_Level1\MT\EC\whole year computation\MT_nee_2025_estimate_summary.csv] [已核验: E:\Dataset_Level1\CVT\EC\whole year computation\CVT_nee_2025_estimate_summary.csv]

## 当前结果

- 严格主口径下，`MT` 的 `annual_nee_estimate_gC_m2 = -917.9625`，`CVT` 的 `annual_nee_estimate_gC_m2 = -533.0063`。 [已核验: E:\Dataset_Level1\MT\EC\whole year computation\MT_nee_2025_estimate_summary.csv] [已核验: E:\Dataset_Level1\CVT\EC\whole year computation\CVT_nee_2025_estimate_summary.csv]
- 当前还并行保留两套敏感性试算：`qc_co2 <= 1 + u*` 但不要求 `flag9_co2 <= 3`，以及只保留 `u*`、不再使用 `qc_co2/flag9_co2`。三版结果已经足够界定筛选口径对年值和塔间差异的影响边界。 [已核验: E:\Dataset_Level1\MT\EC\whole year computation\MT_nee_2025_estimate_qc1_ustar_noflag9_fullpool_summary.csv] [已核验: E:\Dataset_Level1\CVT\EC\whole year computation\CVT_nee_2025_estimate_qc1_ustar_noflag9_fullpool_summary.csv] [已核验: E:\Dataset_Level1\MT\EC\whole year computation\MT_nee_2025_estimate_ustar_only_fullpool_summary.csv] [已核验: E:\Dataset_Level1\CVT\EC\whole year computation\CVT_nee_2025_estimate_ustar_only_fullpool_summary.csv]

## 当前解释边界

- 当前结果足够支持“估算这个地方的碳汇量级和两塔差异”，但仍不应写成最终碳收支或 NECB，因为 storage、advection、复杂地形代表性和更正式的年度闭合口径还没有并入这条公式。 [来源: 用户当前对话 2026-07-05 至 2026-07-06] [推断：基于本轮试算口径和用户限定整理]
- 当前排除结构显示，严格版里最主要的损失不是夜间 `u*`，而是 `qc_co2_fail`、`missing_no_record` 和 `flag9_co2_fail`；因此解释两塔差异时，不能把差异简单归因于生态本身。 [已核验: E:\Dataset_Level1\MT\EC\whole year computation\MT_nee_2025_estimate_30min_gapfilled.csv] [已核验: E:\Dataset_Level1\CVT\EC\whole year computation\CVT_nee_2025_estimate_30min_gapfilled.csv] [推断：基于排除结构和敏感性结果整理]

## 下一步最小动作

下一步先把三版结果整理成一张固定口径敏感性对照表，明确哪一版用于“当前阶段估算值”，哪两版用于“敏感性边界”，再决定是否引入 storage 或更正式的复杂地形修正链条。 [来源: 用户当前对话 2026-07-05 至 2026-07-06] [推断：基于当前工作流状态整理]
