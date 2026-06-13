# Step3E FL co2_mean source-context log

记录日期：2026-06-08

## 执行范围

本轮补充计算 FL `co2_mean(position,time)` 的事件窗口源区辅助诊断。该计算只复用既有 FL pass-position-bin 表中的 `co2_mean`，按每个事件 `pre_min -> peak2` 窗口重新汇总位置分布；不从高频原始数据重算，不做最终 CO2 源区或机制排序。

## 本地输出

输出根目录：
`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2`

新增脚本：
- `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2\scripts\build_FL_co2_mean_source_context.R`

新增输出：
- `outputs\03E_FL_co2_mean_source_context.csv`
- `outputs\03E_FL_co2_mean_position_profile.csv`
- `outputs\fig06_FL_co2_mean_event_source_context.png`
- `outputs\fig06b_FL_co2_anomaly_event_source_context.png`
- `outputs\FL_co2_mean_source_context_report.md`

## 输入和几何口径

- 事件和风来源侧来自 `outputs\03D_wind_source_sector_diagnostics.csv`。
- FL 位置分箱来自 `D:\00 博士阶段\博一\05 Project\com_mass_balance\FL_position_time_pass_bin_diagnostics.csv`。
- 位置锚点使用 `0 m = MT/偏南侧`、约 `122.5 m = CVT 正上方`、`245 m = 偏北远端侧`。
- 每个事件用 position-bin median `co2_mean` 减去该事件窗口整体 median，得到 `co2_anom_vs_event_median_ppm`。
- 2026-06-08 根据用户反馈，主图 `fig06_FL_co2_mean_event_source_context.png` 已改为使用真实 position-bin median `co2_mean` 色带，以更直接展示 CO2 浓度水平变化。
- 原相对异常视图保留为 `fig06b_FL_co2_anomaly_event_source_context.png`；其 anomaly 基准是每个事件、每个站点 `pre_min -> peak2` 窗口内所有 FL 位置分箱 `co2_mean` 的整体 median。
- 2026-06-08 进一步按用户要求，`fig06b_FL_co2_anomaly_event_source_context.png` 的纵轴刻度改为日期/站点 + 事件窗口 `wind_from_classification_deg`，用于直接对照 CO2 anomaly 空间结构与该窗口的来向风角度。

## 当前结果摘要

- 输出事件汇总表共 `8` 行，位置剖面表共 `200` 行，即每个事件 `25` 个 FL 位置分箱；所有事件 `qc_flag = ok`。
- `2025-03-20 CVT` 和 `2025-03-21 CVT/MT` 属于沿谷轴来源事件，因此 FL 南北侧 CO2 只能作为背景空间结构，不用于横谷来源侧支持判断。
- `2025-03-20 MT` 为偏南 MT 侧斜交来源，但南北侧 CO2 差异很弱，`co2_source_side_support = weak_side_contrast`。
- `2025-03-22 CVT/MT` 为偏北 245 m 侧横谷来风，但南北 CO2 均值几乎相同，`north_minus_south_co2_ppm` 约 `0.004`，仍是弱侧向对比。
- `2025-03-23 CVT` 为偏北 245 m 侧横谷来风，且偏北侧 CO2 明显高于偏南侧，`north_minus_south_co2_ppm` 约 `1.224`，支持“风来源侧高 CO2”。
- `2025-03-23 MT` 也是偏北 245 m 侧横谷来风，但偏南侧 CO2 更高，`north_minus_south_co2_ppm` 约 `-0.801`，不支持简单北侧 CO2 源区直输。

## 方法边界

该输出能辅助判断高 CO2 是否位于风来源侧，但仍不是 footprint 或源区反演。更稳妥的表述是：03-23 CVT 具备“偏北来风 + 偏北高 CO2”的一致证据；03-22 横谷来风没有明显南北 CO2 梯度；03-23 MT 显示局地或中段/南侧结构可能更重要。
