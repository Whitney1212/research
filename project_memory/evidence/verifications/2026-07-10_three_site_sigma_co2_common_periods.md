# 2026-07-10 MT / CVT / FL sigma_co2 单图对比

## 目的

把三个观测点的 `sigma_co2` 日变化画到一张图上：

- 不分面
- 用颜色区分 `MT / CVT / FL`
- 保留各自的中位数线和 `25-75%` 四分位色带

## 脚本

- `D:\00 博士阶段\99 Project\06 EA\scripts\plot_three_site_sigma_co2_common_periods.R`

## 输入

- 固定塔：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\mechanism_diagnostics\rotation_sigma_co2_diurnal_plot_data.csv`
- `FL`：`E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_diurnal_plot_data.csv`

## 输出

- 图：`E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\figures\three_site_sigma_co2_common_periods.png`
- 作图表：`E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_sigma_co2_common_periods_plot_data.csv`
- 说明：`E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_sigma_co2_common_periods_summary.txt`

## 验证

- 三个站点都成功进入同一面板
- 每站均为完整 `48` 个 half-hour bin
- 当前颜色固定为 `MT=#619CFF`、`CVT=#F8766D`、`FL=#00BA38`

## 说明

这张图里：

- `MT/CVT` 用的是固定塔 `common-period raw sigma_co2`
- `FL` 用的是三方法公共半小时上的 `raw sigma_co2`

所以它已经避开了此前 `FL scalar_sd` 与固定塔 `raw sigma_co2` 口径不一致的问题。
