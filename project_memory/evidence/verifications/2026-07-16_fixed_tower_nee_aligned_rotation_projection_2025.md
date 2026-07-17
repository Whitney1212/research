# 2025 固定塔 NEE 对齐三风向投影分解

## 来源与任务边界

- 用户要求从头重建一条独立流程，只计算 `2025` 年，在计算阶段硬 QC 的共同窗口内比较 `no_rotation / dr / global_pf / sector_pf`，不纳入 `season_sector_pf`，并且不得覆盖此前结果。 [来源: 用户当前对话 2026-07-15 至 2026-07-16]
- 本轮目标是把每种 rotation 相对 `no_rotation` 的 `Delta NEE` 分解为 `u'c' / v'c' / w'c'` 三方向投影贡献；strict QC、夜间低湍流附加筛选和 gapfill 均不进入这项物理效应诊断。 [来源: 用户当前对话 2026-07-15 至 2026-07-16]

## 新脚本与输出

- 新脚本为 `D:\00 博士阶段\99 Project\06 EA\scripts\rebuild_rotation_nee_aligned_projection_2025.R`，SHA256 为 `AFD13CA41B734239E6552F7969E36AD7137A59AC98F6149338AF227B97FACF05`；2026-07-16 使用 R 解析检查通过。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\rebuild_rotation_nee_aligned_projection_2025.R]
- 新结果独立写入 `E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild`，其中 `_intermediate` 保存每站每方法的中间结果，`MT` 与 `CVT` 子目录保存窗口级和方法级结果；此前结果未被覆盖。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild]
- 双站正式合并投影表为 `E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv]

## 共同窗口与累计结果

- `MT` 四方法共同保留 `14,469` 个半小时窗口；共同窗口 `no_rotation NEE = -786.4657 g C m^-2`。相对 `no_rotation`，`dr / global_pf / sector_pf` 的 `Delta NEE` 分别为 `-147.8909 / -113.0310 / -147.1003 g C m^-2`，相当于基准绝对累计值的 `-18.80% / -14.37% / -18.70%`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv]
- `MT` 的三方向投影分别为：`dr = (-83.8851, -89.2997, +25.2939)`、`global_pf = (-55.7357, -68.5504, +11.2550)`、`sector_pf = (-80.5043, -84.2470, +17.6509) g C m^-2`，顺序为 `u'c' / v'c' / w'c'`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv]
- `CVT` 四方法共同保留 `14,431` 个半小时窗口；共同窗口 `no_rotation NEE = -415.6485 g C m^-2`。相对 `no_rotation`，`dr / global_pf / sector_pf` 的 `Delta NEE` 分别为 `+157.5935 / +6.5793 / -87.8158 g C m^-2`，相当于基准绝对累计值的 `+37.92% / +1.58% / -21.13%`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv]
- `CVT` 的三方向投影分别为：`dr = (+32.4363, +114.4164, +10.7408)`、`global_pf = (+27.6756, -21.9233, +0.8270)`、`sector_pf = (-115.2874, +13.7597, +13.7119) g C m^-2`，顺序为 `u'c' / v'c' / w'c'`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv]

## 验证与解释边界

- 双站合并表中 `Delta NEE - Delta u'c' - Delta v'c' - Delta w'c'` 的最大绝对闭合残差约为 `7.0e-13 g C m^-2`，说明当前三方向投影在重算产品内部严格闭合。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\four_rotation_projection_decomposition_2025.csv]
- `no_rotation` 重算与既有硬 QC 基准基本完全一致，但 rotation 方法的窗口级 `max_abs_rerun_minus_baseline` 仍达到：`MT dr/global_pf/sector_pf = 0.6888/6.2359/4.6848`，`CVT dr/global_pf/sector_pf = 2.3484/2.5116/2.2202`。因此当前结果可以用于说明重算链内部的坐标投影贡献，但在核清这些窗口级差异前，不应写成“已与此前成品 NEE 对每个窗口完全一致”。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\MT\MT_four_rotation_nee_aligned_projection_summary_2025.csv] [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\CVT\CVT_four_rotation_nee_aligned_projection_summary_2025.csv]
- 推断：`MT` 三种 rotation 的负差异主要由 `u'c'` 与 `v'c'` 的负投影驱动，`w'c'` 仅部分抵消；`CVT dr` 主要由 `v'c'` 正投影驱动，`global_pf` 接近零源于 `u'c'` 与 `v'c'` 抵消，`sector_pf` 的负差异主要由 `u'c'` 负投影驱动。 [推断：基于本轮投影分解表整理]

## 下一最小步

- 逐窗口定位 rotation 重算与既有硬 QC 基准差异最大的记录，核对时间键、PF 参数版本、lag、频率修正和单位换算；完成该核验后，再决定是否把这套分解提升为与既有成品 NEE 完全对齐的正式解释产品。 [推断：基于本轮验证边界整理]
