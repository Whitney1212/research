# 2026-07-08 固定塔标准化全量产品 2025 rotation 敏感性重算

## 来源

- 这份记录整理自用户在当前对话中提出的要求：不要再补跑原始通量，直接用已经标准化好的固定塔全量产品，按统一 downstream 口径重算两塔 `2025` 自然年的 `year audit + 夜间 u* 过滤 + gapfilling + annual NEE`，并比较 rotation 方法敏感性。[来源: 用户当前对话 2026-07-08]

## 本次脚本与入口

- 本轮继续复用 `D:\00 博士阶段\99 Project\06 EA\scripts\build_fixed_tower_ec_year_audit.R` 和 `D:\00 博士阶段\99 Project\06 EA\scripts\estimate_fixed_tower_nee_2025.R` 作为核心入口，没有重写 year audit 或 gapfilling 主逻辑。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\build_fixed_tower_ec_year_audit.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\estimate_fixed_tower_nee_2025.R]
- 为了与现有 `W3` 严格版保持一致，本轮把 `build_fixed_tower_ec_year_audit.R` 的 `u*` 判据改成“仅夜间应用”，并补入 `day_start_hour/day_end_hour` 参数；`estimate_fixed_tower_nee_2025.R` 继续沿用“短缺口线性内插 -> 同塔多年份 climatology -> 跨塔同期回归兜底”的既有 gapfilling 口径。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\build_fixed_tower_ec_year_audit.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\estimate_fixed_tower_nee_2025.R]
- 本轮新增薄包装脚本 `D:\00 博士阶段\99 Project\06 EA\scripts\run_fixed_tower_rotation_sensitivity_standardized_2025.R`，它只负责按 manifest 取标准化输入、循环 9 个 case、落盘 per-method 输出并汇总公共四方法总表与 MT/CVT 差异表。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\run_fixed_tower_rotation_sensitivity_standardized_2025.R]

## 输入与输出

- 本轮统一输入 manifest 为 `E:\Dataset_Level1\FixedTower\EC\fixed_tower_full_flux_standardized_30min_manifest.csv`；公共四方法矩阵为 `MT/CVT: no_rotation / dr / global_pf / sector_pf`，另加 `MT season_sector_pf` 作为 MT-only 补充敏感性。[已核验: E:\Dataset_Level1\FixedTower\EC\fixed_tower_full_flux_standardized_30min_manifest.csv]
- 两塔 per-method 输出目录分别为 `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025` 和 `E:\Dataset_Level1\CVT\EC\whole year computation\rotation_sensitivity_standardized_2025`；双塔汇总目录为 `E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_run_plan.csv]
- 汇总目录当前已落盘 `rotation_sensitivity_standardized_2025_year_audit_summary_all_methods.csv`、`rotation_sensitivity_standardized_2025_annual_summary_all_methods.csv`、`rotation_sensitivity_standardized_2025_common_four_methods_summary.csv`、`rotation_sensitivity_standardized_2025_mt_cvt_method_difference_summary.csv` 和 `rotation_sensitivity_standardized_2025_delta_vs_sector_pf.csv`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_year_audit_summary_all_methods.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_annual_summary_all_methods.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_common_four_methods_summary.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_mt_cvt_method_difference_summary.csv] [已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_delta_vs_sector_pf.csv]

## 公共四方法结果

- `MT` 公共四方法的严格主口径结果分别为：`no_rotation = -788.4071`、`dr = -883.5240`、`global_pf = -1018.4899`、`sector_pf = -919.9188 gC m^-2`；对应 `observed_valid_windows` 分别为 `5699 / 5832 / 5873 / 5508`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_common_four_methods_summary.csv]
- `CVT` 公共四方法的严格主口径结果分别为：`no_rotation = -261.1940`、`dr = -256.5141`、`global_pf = -325.0168`、`sector_pf = -533.5506 gC m^-2`；对应 `observed_valid_windows` 分别为 `3842 / 4700 / 4639 / 4518`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_common_four_methods_summary.csv]
- `MT season_sector_pf` 的 MT-only 补充敏感性结果为 `observed_valid_windows = 5461`、`gapfilled_windows = 12059`、`annual_nee_estimate_gC_m2 = -1050.4370`；本轮跨塔兜底 donor 仍沿用 `CVT sector_pf`，但该方法没有并入双塔公共四方法比较表。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_annual_summary_all_methods.csv]

## 敏感性摘要

- 相对各自 `sector_pf` 基线，`MT` 的年值差异为 `no_rotation +131.5118`、`dr +36.3948`、`global_pf -98.5711`、`season_sector_pf -130.5181 gC m^-2`；`CVT` 的年值差异为 `no_rotation +272.3567`、`dr +277.0366`、`global_pf +208.5339 gC m^-2`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_delta_vs_sector_pf.csv]
- 双塔公共四方法下，`MT - CVT` 的年值差异分别为 `no_rotation = -527.2131`、`dr = -627.0100`、`global_pf = -693.4732`、`sector_pf = -386.3682 gC m^-2`。[已核验: E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\rotation_sensitivity_standardized_2025_mt_cvt_method_difference_summary.csv]
- 从公共四方法的范围看，`MT` 年值跨度约为 `230.083 gC m^-2`，`CVT` 年值跨度约为 `277.037 gC m^-2`，塔间差异跨度约为 `307.105 gC m^-2`；这说明 rotation 方法会明显改变两塔的 `2025` 年值和塔间差异量级，且 `CVT` 的年值对 rotation 选择更敏感。[推断：基于 `rotation_sensitivity_standardized_2025_common_four_methods_summary.csv` 与 `rotation_sensitivity_standardized_2025_mt_cvt_method_difference_summary.csv` 的直接计算]

## 解释边界

- 这批结果已经足够作为固定塔统一 downstream 口径下的 `2025` 年值审计、gapfilling 和 rotation 敏感性记录，但仍只应写成 `EC-only annual NEE estimate / proxy`，不应直接升级为最终碳收支或 `NECB` 结论。[来源: 用户当前对话 2026-07-05 至 2026-07-08] [推断：基于当前脚本口径仍未并入 storage、advection 与更正式年闭合整理]
