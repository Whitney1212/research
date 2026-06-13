# 2026-06-12 FL PF_8bin 逐点运行记录位置与实际速度矢量版

## 本次同步对象

本次记录的是 FL 移动平台 planar fit 参数口径的最新正式版本：`PF_8bin`。该版本只保留原 B2 的 8-bin bin-wise planar fit 思路，但预处理已从“单程起止位置线性插值 + 固定 `0.137 m/s` 小车速度”升级为“统一运行记录逐点位置插值 + 实际有符号速度矢量水平风修正”。[已核验: `E:\Dataset_Level1\Flares\PFparameter\run_PF_8bin.R`] [已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md`]

## 输入与输出位置

- 输出根目录固定为 `E:\Dataset_Level1\Flares\PFparameter`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\manifest.txt`]
- 完整单程表使用 `E:\Dataset_Level0\Flares\260611_clasified\30min\fl_complete_passes_strict.csv`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\manifest.txt`]
- FL 高频 EC 数据根目录使用 `E:\Dataset_Level0\Flares\EC`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\manifest.txt`]
- 统一运行记录使用 `E:\Dataset_RAW\Flares\运行记录\unified_output\fl_running_records_unified.csv`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\manifest.txt`]
- 后续高频通量计算应调用的参数表为 `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv`]

## 核心计算口径

`PF_8bin` 使用 `5-240 m` 有效轨道范围，将轨道等分为 `8` 个 bin，每个 bin 宽约 `29.375 m`。每个 10 Hz 高频点先按统一运行记录插值得到 `position_m_record` 与 `speed_cm_s_record`，再按 `position_m_record` 分配 `bin_id`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md`]

水平风运动修正使用实际有符号速度，而不是固定名义速度。脚本中采用：

```text
cart_speed_m_s = speed_cm_s_record / 100
cart_velocity_east  = cart_speed_m_s * sin(track_rad)
cart_velocity_north = cart_speed_m_s * cos(track_rad)
U_east_corr  = U_east  + cart_velocity_east
U_north_corr = U_north + cart_velocity_north
```

PF 方程仍为 `w = a + b * U_east_corr + c * U_north_corr`，后续高频应用时应计算 `w_pf = Uz - (a + b * U_east_corr + c * U_north_corr)`。本轮仍未修正轨道坡度导致的垂直平台速度。[已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md`]

## 样本量与拟合结果

本次运行严格通过完整单程 `1529` 个，覆盖 `73` 天，构造有效 four-pass ensemble `334` 个。高频风数据 QC 后 `32,525,634` 行，匹配完整单程 `16,805,783` 行，运行记录插值成功并保留进入 `PF_8bin` 的样本为 `16,804,313` 行。[已核验: `E:\Dataset_Level1\Flares\PFparameter\manifest.txt`]

`PF_8bin` 的 PF 输入点总数为 `1852`，8 个 bin 全部拟合成功，`fit_ok = 8/8`；每个 bin 的输入点数为 `231-232`，`min_n_samples = 1,840,482`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\manifest.txt`] [已核验: `E:\Dataset_Level1\Flares\PFparameter\pf_fit_summary.csv`]

`PF_8bin` 的倾角范围为 `8.4200-11.8022 deg`，倾角中位数约 `9.5073 deg`。输入点层面 RMSE before/after 各 bin 均下降，中位 RMSE 降幅约 `38.1%`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\pf_fit_summary.csv`]

## A/B 预处理对比

A/B 对比中，旧口径 A 为“单程起止位置线性插值 + 固定 `fw=+0.137 m/s`、`bw=-0.137 m/s`”，新口径 B 为“运行记录逐点位置 + 实际速度”。整体上，逐点位置相对线性位置的平均绝对差约 `0.0747 m`，q95 绝对差上界约 `12.0039 m`，10 Hz 样本 bin 重分配比例约 `0.245%`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_preprocessing_ab_summary.csv`]

实际速度相对固定速度的平均绝对差约 `0.00267 m/s`；对应到水平风修正差异，east/north 分量的平均绝对差约为 `0.00206/0.00170 m/s`。因此本次升级主要是正式化位置与速度口径，对 8-bin 空间分箱和整体 PF 参数没有造成大范围重排。[已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_preprocessing_ab_summary.csv`] [推断: 基于 A/B 汇总数值和 8-bin 拟合结果整理]

## 关键输出图件

本次生成了 A/B 预处理对比图与 PF 验证图，均位于 `E:\Dataset_Level1\Flares\PFparameter\figures`。[已核验: `E:\Dataset_Level1\Flares\PFparameter\figures`]

主要图件包括：

- `fig_ab_position_difference_by_bin.png`
- `fig_ab_bin_change_fraction_by_bin.png`
- `fig_ab_speed_actual_vs_nominal.png`
- `fig_ab_wind_correction_difference_by_bin.png`
- `fig_ab_bin_transition_matrix.png`
- `fig_pf8bin_tilt_by_bin.png`
- `fig_pf8bin_w_before_after_by_bin.png`
- `fig_pf8bin_rmse_reduction_by_bin.png`
- `fig_pf8bin_residual_distribution_by_bin.png`
- `fig_pf8bin_input_residual_vs_position.png`
- `fig_pf8bin_passbin_w_after_by_direction.png`
- `fig_pf8bin_validation_by_direction.png`

## 当前决策与后续约束

后续 FL 高频通量计算中的 PF 旋转参数名称固定为 `PF_8bin`，并应调用 `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv`。应用时必须沿用同一套预处理：统一运行记录逐点位置插值、实际有符号速度矢量水平风修正、`5-240 m` 轨道范围和 8-bin 划分。[来源: 用户当前对话 2026-06-11 至 2026-06-12] [已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_parameters_for_flux.csv`]

如果后续更换运行记录、位置插值规则、速度字段、轨道有效范围或 bin 划分，则当前参数表不应直接复用，需要重新生成 `PF_8bin` 参数。[推断: 基于 PF 参数与预处理变量一致性要求整理] [已核验: `E:\Dataset_Level1\Flares\PFparameter\PF_8bin_method_notes.md`]

