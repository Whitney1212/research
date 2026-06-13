# Step3D wind source sector diagnostics log

记录日期：2026-06-08

## 执行范围

本轮在既有 Step3 H1/H2 结果之后，只新增“风从哪条轴线、哪一侧来”的事件级几何诊断。该诊断使用风向来向 `wind-from`，不使用图中箭头的 `flow-to` 方向作为来源方向；不执行 H3-H6、FL 机制分类、rotation 风险评分或最终机制排序。

## 本地输出

输出根目录：
`D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2`

新增脚本：
- `D:\00 博士阶段\博一\05 Project\com_assemble\com_peakH1&H2\scripts\build_wind_source_sector_diagnostics.R`

新增输出：
- `outputs\03D_wind_source_sector_diagnostics.csv`
- `outputs\03D_wind_source_sector_summary.csv`
- `outputs\fig05_wind_source_axis_event_diagnostics.png`
- `outputs\wind_source_sector_diagnostics_report.md`

## 几何规则

- 谷轴使用 `45° / 225°`。
- FL 横谷切面使用 `129.551° / 309.551°`。
- FL 位置锚点使用 `0 m = MT 侧/偏南侧`、约 `122.5 m = CVT 正上方`、`245 m = 远端侧/偏北侧`。该侧向命名来自用户在 2026-06-08 的补充，用于后续把 `FL_245m_remote_side` 解释为偏北远端侧、把 `MT_0m_side` 解释为偏南 MT 侧。
- 每个事件优先使用 `pre_min -> peak2` 的 30 min `wind-from` 风向，并用风速加权圆均值作为分类方向；若该窗口不足，再回退到更宽的峰前检测窗口。

## 当前结果摘要

- 8 个 CVT/MT 事件均有足够风向数据，`qc_flag = ok`。
- `2025-03-20 CVT`、`2025-03-21 CVT` 和 `2025-03-21 MT` 被判为强沿谷轴来源，来源侧为 `valley_225deg_side`。
- `2025-03-20 MT` 为中等斜交横谷切面来源，来源侧接近 `MT_0m_side`。
- `2025-03-22 CVT/MT` 与 `2025-03-23 CVT/MT` 被判为强横谷切面来源，来源侧均为 `FL_245m_remote_side`，即从 FL 245 m 偏北远端侧吹向 MT/0 m 偏南侧。
- FL `F_anom` 绝对热点与风向来源侧并不总一致：03-22 热点在 `MT_0m_side`，03-23 热点在 `CVT_mid_track`。这说明 FL 色带更适合作为空间结构证据，不应简单等同为来源侧判据。

## 方法边界

该输出足以支持事件级判断：“风更像沿谷轴、横谷切面，或斜交，并来自哪一侧”。它仍不足以直接确定具体 CO2 源区、footprint 或最终机制来源。若继续推进，应把该表与 CO2 廓线转换、CVT/MT 相位差、FL `F_anom(position,time)` 形态和地形/footprint 资料交叉使用。
