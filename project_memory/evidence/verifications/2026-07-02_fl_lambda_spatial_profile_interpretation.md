# 2026-07-02 FL F_lambda(x) 空间 profile 解释边界

## 来源

- 本记录整理自当前对话中对 `E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure` 两张空间 profile 图的解释，并结合本轮已核验的脚本、summary 和 profile CSV 数值范围。 [来源: 用户当前对话 2026-07-02] [已核验: E:\FL_MASSBALANCE\calc_fl_spatial_profile_and_mt_cvt_segments.R] [已核验: E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure\FL_lambda_position_profile_fw_bw_by_closure.csv] [已核验: E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure\FL_lambda_spatial_profile_summary.txt]

## 已核验的计算口径

- 当前空间 profile 的分钟级诊断量为 `F_lambda_1min = factor(w_pf_1min) * co2_1min * pa_1min*1000/(R*(ta_1min+273.15))`，其中 `w_pf_1min < 0` 时 `factor=lambda`，否则 `factor=1`。它是质量守恒修正后的移动剖面 CO2 垂直输送诊断量，不是 30 min EC 湍流通量，也不是最终日变化均值。 [已核验: E:\FL_MASSBALANCE\calc_fl_spatial_profile_and_mt_cvt_segments.R] [已核验: E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure\FL_lambda_spatial_profile_summary.txt]
- 当前 profile 的聚合顺序是 `minute -> pass x 10 m position bin -> direction x closure_class x position bin`，纳入 `broad_closed`、`numerically_closed` 和 `extreme_forced` 三类，最终 profile 表有 `144` 行，即 `fw/bw × 3 closure_class × 24 position bins`。 [已核验: E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure\FL_lambda_spatial_profile_summary.txt]

## 图形解释

- 纵轴量级偏大主要来自 `w_lambda * CO2 * rho_air` 的定义，而不是 EC covariance 口径。以 `CO2 * rho_air` 约为 `1.7e4 umol m-3` 估算，即使 `w_lambda` 只有 `0.05 m s-1`，诊断量也会达到约 `800 umol m-2 s-1`；当负 `w` 被较大的 `lambda` 放大时，`numerically_closed` 或 `extreme_forced` 的均值可以进入几千量级。 [推断：基于已核验公式和当前 profile 数值范围整理] [已核验: E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure\FL_lambda_position_profile_fw_bw_by_closure.csv]
- `broad_closed` 内的空间起伏相对小：当前 profile 中 `bw broad_closed` 的 position-bin 均值范围约为 `-639` 到 `949.2 umol m-2 s-1`，`fw broad_closed` 约为 `-907.9` 到 `588.9 umol m-2 s-1`。这支持将主解释写成：在较可信 closure 层内，`F_lambda(x)` 沿 FL 轨道的位置依赖不强。 [已核验: E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure\FL_lambda_position_profile_fw_bw_by_closure.csv] [推断：基于 broad_closed 分组范围和图形形态整理]
- 若把 `numerically_closed` 与 `extreme_forced` 一起纳入，全数据图中前 `0-50 m` 更容易出现明显向下输送信号；但这类信号同时伴随更强的 `lambda` 放大风险，不宜直接解释为稳健的全样本空间结构。当前数值范围显示 `numerically_closed` 可到 `-5839.5`，`extreme_forced` 可到 `-6343.8 umol m-2 s-1`，明显大于 `broad_closed`。 [已核验: E:\FL_MASSBALANCE\figures\fl_lambda_spatial_profile_fw_bw_closure\FL_lambda_position_profile_fw_bw_by_closure.csv] [推断：基于 closure_class 分组范围和当前图形解释整理]

## 当前建议写法

- 推荐在方法解释中表述为：在 `broad_closed` 样本内，`F_lambda(x)` 的沿轨道空间差异相对有限，说明主分析结果不强烈依赖 FL 轨道位置；若纳入 `numerically_closed` 与 `extreme_forced`，`0-50 m` 区段出现更明显的向下输送诊断信号，但该结构同时伴随更强的 `lambda` 放大风险，因此更适合作为高风险样本的空间诊断，而不宜直接作为稳健主结论。 [推断：基于当前对话解释、已核验公式和 profile 数值范围整理]

