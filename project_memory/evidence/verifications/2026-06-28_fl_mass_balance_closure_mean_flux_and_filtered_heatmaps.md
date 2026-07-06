# 2026-06-28 FL 质量守恒分层热图与日期等权均值图

## 来源与目标

- 本轮记录整理自 2026-06-28 当前对话中围绕 `E:\FL_MASSBALANCE` 的一组连续更新：先将质量守恒 `lambda` 闭合分类整理为 `broad_closed`、`numerically_closed` 和 `extreme_forced` 三类，再按用户要求只保留 `broad_closed` 与 `numerically_closed` 两类 mixed-sign 单程重绘热力分布图，并补做按“时段内时长加权、再按日期等权平均”的均值折线图与 `month × hour × closure_class` 均值热图。 [来源: 用户当前对话 2026-06-28]
- 本次正式记录只采纳已经落地到本地文件的脚本、图件、CSV 与核验摘要，不把中途讨论过但未写出的替代口径升级为既成事实。 [推断：基于 project-progress-memory 证据规则整理]

## broad_closed 与 numerically_closed 筛选热图

- 月度热力色带脚本 `E:\FL_MASSBALANCE\plot_fl_mass_balance_monthly_transport_heatbands.R` 已补充 `FL_MB_CLOSURE_CLASSES` 与 `FL_MB_OUTPUT_TAG` 两个环境变量入口；合并图脚本 `E:\FL_MASSBALANCE\plot_fl_mass_balance_combined_transport_heatband.R` 同步支持带后缀读写筛选后的 segment 表与图件，避免覆盖全量 mixed-sign 版本。 [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_monthly_transport_heatbands.R] [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_combined_transport_heatband.R]
- 当前仅保留 `broad_closed,numerically_closed` 两类 mixed-sign 单程的新图组已经输出到 `E:\FL_MASSBALANCE\figures\monthly_transport_heatbands`，文件名统一带后缀 `_broad_numerically_closed`。其中合并图为 `FL_mass_balance_transport_heatband_all_valid_dates_broad_numerically_closed.png`，并额外生成 15 张月度图和 5 张观测簇拆分图。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_broad_numerically_closed.png] [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_clustered_manifest_broad_numerically_closed.txt]
- 这套筛选热图当前使用 `2589` 个 mixed-sign 单程，对应 `123` 个有效日期、`2602` 个跨午夜拆分后的绘图 segment，日期范围为 `2023-06-22` 至 `2026-06-04`，覆盖 `15` 个有效月份。由于只保留 `broad_closed` 与 `numerically_closed`，图中 `extreme_forced` 黑框数为 `0`；月图仍保留 `27` 个 `low_minute_coverage` 虚线框提示。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_verification_broad_numerically_closed.txt] [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest_broad_numerically_closed.txt]
- 该套筛选热图继续沿用统一对称色标 `+/-35 umol m-2 s-1`。合并图仍只排列有有效结果的日期，不为无效日期保留横轴占位，且合并图版本不标注 `low_minute_coverage`。因此横向列间距不能解释为真实日历间隔，精确值也应回到主表或 segment 表读取。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_verification_broad_numerically_closed.txt] [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest_broad_numerically_closed.txt]

## 日期等权均值图

- 新脚本 `E:\FL_MASSBALANCE\plot_fl_mass_balance_closure_mean_flux.R` 已生成 `broad_closed` 与 `numerically_closed` 两类的均值折线图 `FL_mass_balance_closure_mean_flux_by_hour.png`、`month × hour × closure_class` 均值热图 `FL_mass_balance_closure_mean_flux_month_hour_heatmap.png`，并同步导出 `by_hour.csv`、`month_hour.csv` 和核验摘要 `FL_mass_balance_closure_mean_flux_summary.txt`。脚本内含最小 `self_check()`，核验整点切分与“先时长加权、再日期等权”的汇总逻辑。 [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_closure_mean_flux.R] [已核验: E:\FL_MASSBALANCE\figures\lambda_diagnostics\FL_mass_balance_closure_mean_flux_summary.txt]
- 当前均值图同样只使用 `2589` 个 mixed-sign 单程，并先将单程按与每个整点小时的重叠时长切分为 `3044` 个 hour-overlap segment；闭合类别计数为 `broad_closed=947`、`numerically_closed=1642`。均值结果覆盖 `123` 个有效日期与 `15` 个有效月份。 [已核验: E:\FL_MASSBALANCE\figures\lambda_diagnostics\FL_mass_balance_closure_mean_flux_summary.txt]
- 小时均值折线图采用的正式口径是：在每个 `date × hour_bin × lambda_closure_class` 内，按单程与该小时的 `overlap_sec` 对 `F_lambda_pf_umol_m2_s` 加权平均；随后对这些日小时均值按日期等权求平均。该口径避免让某一天因为单程更多、单程更碎或停留更久而主导小时均值。 [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_closure_mean_flux.R]
- `month × hour × closure_class` 热图沿用同一层级逻辑：先在 `date × hour_bin × class` 内按 `overlap_sec` 加权，再在每个 `month × hour_bin × class` 单元内对日期均值做等权平均。图中灰格表示该月该小时该类别没有有效日期。 [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_closure_mean_flux.R] [已核验: E:\FL_MASSBALANCE\figures\lambda_diagnostics\FL_mass_balance_closure_mean_flux_month_hour_heatmap.png]
- 当前小时均值摘要显示，两类 closure-class 的最强负向均值都出现在午前后：`broad_closed@12=-14.80`、`numerically_closed@12=-14.00`；其后依次是 `broad_closed@13=-11.67`、`numerically_closed@11=-11.26` 和 `broad_closed@11=-10.79`。热图色标使用聚合均值绝对值的 `P98` 裁剪，当前对称上限为 `25`，以避免少数极端月小时格把主体结构冲淡。 [已核验: E:\FL_MASSBALANCE\figures\lambda_diagnostics\FL_mass_balance_closure_mean_flux_summary.txt] [已核验: E:\FL_MASSBALANCE\figures\lambda_diagnostics\FL_mass_balance_closure_mean_flux_month_hour_heatmap.png]

## 当前解释边界

- 这套均值图和筛选热图都只针对质量守恒修正后的 mixed-sign 垂直输送诊断量 `F_lambda_pf_umol_m2_s`，不应直接写成最终生态系统 CO2 通量。`broad_closed` 可作为主解释样本，`numerically_closed` 更适合作为强制闭合敏感性对照；`single_sign` 与 `extreme_forced` 仍应分开解释。 [已核验: E:\FL_MASSBALANCE\results\FL_mass_balance_PF8bin_2ensemble_by_pass.csv] [推断：基于当前分类口径和图件用途整理]
