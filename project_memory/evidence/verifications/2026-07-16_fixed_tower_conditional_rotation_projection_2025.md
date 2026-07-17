# 2025 固定塔 rotation 条件投影来源分解

## 来源与边界

- 本次分析只使用 `2025` 年计算阶段硬 QC 的 MT/CVT 共同窗口，并只比较 `no_rotation / dr / global_pf / sector_pf`。条件分类使用不受 rotation 改变的 `no_rotation` 参考风向和 `z_L` 稳定度；没有接入 `qc_co2/flag9`、夜间 `u*`、平稳性筛选或 gapfill。 [来源: 用户当前任务] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\analyze_conditional_rotation_nee_projection_2025.R]
- 条件分析脚本为 `D:\00 博士阶段\99 Project\06 EA\scripts\analyze_conditional_rotation_nee_projection_2025.R`，SHA256 为 `839C6EAECACABC9CEDF451D18BA7D1EFD6690CD8F30A772148AFE3EA5C57CA8D`；独立检查脚本为 `D:\00 博士阶段\99 Project\06 EA\scripts\check_conditional_rotation_nee_projection_2025.R`，SHA256 为 `4BCC23D53B1A8B87310318204BE8CAAFFA6F714515B714CE2999E4DACA3577D1`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\analyze_conditional_rotation_nee_projection_2025.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\check_conditional_rotation_nee_projection_2025.R]
- 新结果写入 `E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis`，没有覆盖既有重算结果。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis]

## 前置核验

- MT/CVT 四方法共同窗口数为 `14,469 / 14,431`。重算与既有硬 QC 基准的最大绝对差仍为：MT `dr/global_pf/sector_pf = 0.6888/6.2359/4.6848`，CVT `dr/global_pf/sector_pf = 2.3484/2.5116/2.2202`。CVT 三种 rotation 的最大差都出现在 `2025-04-29 15:00:00`；MT `dr` 的最大差在 `2025-02-21 12:00:00`，MT `global_pf/sector_pf` 在 `2025-02-21 20:30:00`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\preflight_max_rerun_minus_baseline_2025.csv]
- 最大差窗口的标准化输出行与 hard-QC baseline copy 行在 `co2_flux`、`scf_co2`、合并行数和 rotation 标识上可直接对照；PF 输入、标准化输出、baseline copy、rotation-details RDS 和重算脚本的版本记录均存在。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\preflight_max_window_source_comparison_2025.csv] [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\preflight_input_version_check_2025.csv]
- 当前重算口径记录为：`lag_params = list()`，`block_average` detrend，PF 使用 `allow_bias=TRUE, n_sectors=12, min_points=10, min_win=50`，`rho_m_dry=(rho_air_mean-rho_v_mean)/0.02896`，异常干空气摩尔密度回退为 `41.6`，组件换算为 `rho_m_dry*scf_co2`，半小时换算因子为 `0.0216 gC m^-2`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\preflight_method_settings_check_2025.csv]
- 推断：上述核验没有发现可用的单一时间键、lag、频率修正、密度或单位换算窄修复；因此保留明确偏差表，不把重算结果宣称为逐窗口已与旧成品完全一致，并继续在重算产品内部做条件结构分析。 [推断: 基于上述 preflight source/version/settings 文件的联合核对]

## 条件投影结果

- 年度净投影分解为：MT `dr = (-83.9,-89.3,+25.3,-147.9)`、`global_pf = (-55.7,-68.6,+11.3,-113.0)`、`sector_pf = (-80.5,-84.2,+17.7,-147.1)`；CVT `dr = (+32.4,+114.4,+10.7,+157.6)`、`global_pf = (+27.7,-21.9,+0.8,+6.6)`、`sector_pf = (-115.3,+13.8,+13.7,-87.8) gC m^-2`，每组顺序为 `Delta u / Delta v / Delta w / Delta NEE`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\projection_by_window_with_conditions_2025.csv]
- CVT DR 在参考风向 `150–240°` 且不稳定窗口的净分解为 `Delta u=+4.37`、`Delta v=+59.15`、`Delta w=+5.37`、`Delta NEE=+68.88 gC m^-2`；CVT Sector PF 在参考风向 `330–090°` 且稳定窗口的净分解为 `Delta u=-63.65`、`Delta v=-22.71`、`Delta w=-5.60`、`Delta NEE=-91.96 gC m^-2`。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\conditional_projection_summary_2025.csv]
- MT 三种 rotation 的 `u/v` 同时为负共有 `13,184` 个方法行；按时间键去重后，三种 rotation 同窗均为负的窗口为 `1,154/14,469`，任一 rotation 为负的窗口为 `8,084/14,469`。CVT Global PF 的 `u/v` 符号相反窗口为 `8,268/14,431 = 57.3%`，属于同窗内抵消。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\priority_window_overlap_2025.csv]

## 系数与协方差来源

- `conditional_source_statistics_2025.csv` 对关键状态和大水平投影前 `10%` 窗口保存了 `a/b`、`cov(u,c)/cov(v,c)` 和 `P_u/P_v` 的中位数、IQR、5/25/75/95 分位数；来源分类使用每个 tower×method 全体窗口的绝对系数与绝对协方差 `95%` 分位数。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\conditional_source_statistics_2025.csv]
- 在 CVT 不稳定 `150–240°` 的 DR `v` 分量 top-10% 窗口中，`covariance_high` 是主导类别，贡献 `51.2%` 的 `|P_v|`，`both_high` 贡献 `27.2%`；在 CVT 稳定 `330–090°` 的 Sector PF `u` 分量中，二者分别为 `50.5%` 和 `16.1%`；在 MT `u/v` 同负状态的 Global PF `u` 分量中，二者分别为 `74.8%` 和 `4.5%`。这支持“协方差异常大为主、部分窗口存在系数×协方差耦合”的判读，而不是单独把大投影归因于系数异常。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_source_origin_classification_2025.csv] [推断: 基于 top-10% 窗口分类与绝对乘积贡献]
- Sector PF 相邻扇区第三行系数存在跳变，最大绝对相邻差为 CVT `|Delta a|=0.371, |Delta b|=0.215`，MT `|Delta a|=0.308, |Delta b|=0.195`；环状 `330–360°` 到 `000–030°` 的边界也纳入了相邻比较。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\sector_pf_adjacent_sector_coefficients_2025.csv]

## 稳健性与闭合

- 删除 `|Delta C|` 最大的 top `1%/5%/10%` 窗口后，六个 tower×rotation 组合的年度净方向均未改变；被删除窗口贡献的绝对 `Delta C` 范围为 `11.7–62.5%`。留一月后，所有组合的年度方向也保持不变。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\robustness_sensitivity_2025.csv]
- 独立检查命令为 `Rscript D:\00 博士阶段\99 Project\06 EA\scripts\check_conditional_rotation_nee_projection_2025.R`。检查通过：方法集合为四方法集合，MT/CVT 为 `14,469/14,431`；最大逐窗口闭合残差 `2.188e-12`，最大年度闭合残差 `9.948e-14`，最大条件汇总闭合残差 `1.990e-13`，最大累计曲线闭合残差 `1.098e-12`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\check_conditional_rotation_nee_projection_2025.R]
- 四张核心图分别为风向扇区×稳定度、月份×本地半小时、关键状态 coefficient-vs-covariance 和累计曲线/极端敏感性图，均位于输出目录的 `figures` 子目录。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\figures]

## 解释边界与下一步

- 推断：MT 的年度负投影由 `u'c'` 与 `v'c'` 共同贡献，`w'c'` 部分抵消；CVT DR 的正投影主要由 `v'c'`，CVT Sector PF 的负投影主要由 `u'c'`。CVT Global PF 的年度接近零主要体现同窗内 `u/v` 抵消。 [推断: 基于 conditional_projection_summary_2025.csv 与 priority_window_overlap_2025.csv]
- `no_rotation` 只是统一比较基线，不是真值；水平协方差投影不能直接等同于水平平流。本轮结果只说明当前重算产品内部的坐标投影贡献。 [来源: 用户当前任务]
- 由于窗口级 rerun-minus-baseline 偏差仍未消除，不能把条件投影结果直接包装成旧成品的逐窗口物理归因，也不能把年度差异全部归因于流动条件。 [已核验: E:\Dataset_Level1\Rotation\nee_aligned_projection_2025_rebuild\conditional_projection_analysis\preflight_max_rerun_minus_baseline_2025.csv]
- 下一最小步是只针对 `preflight_top5_windows_2025.csv` 中的实质偏差窗口，逐条锁定旧成品使用的原始文件、PF 参数/rotation-details 版本和后处理链，再做窄重跑；在此之前不扩展到 soft QC、gapfill 或年度完整链。 [推断: 基于本次 preflight 与用户任务边界]
