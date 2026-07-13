# 2026-07-10 FL 全量平均风速日变化图

## 目的

可视化 `FL` 全量产品的平均风速日变化。

## 脚本

- `D:\00 博士阶段\99 Project\06 EA\scripts\plot_fl_full_ec_wind_speed_diurnal.R`

## 输入

- `E:\Dataset_Level1\Flares\EC_ecpreproc\oldcode_0_245\results\FL_flux_no_rotation.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\oldcode_0_245\results\FL_flux_dr.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\oldcode_0_245\results\FL_flux_PF_8bin_2ensemble.csv`
- 以及 `batch_b_complete`、`main_complete` 下对应三种方法的同名结果表

## 口径

- 不回原始风场重算
- 直接复用已交付 `FL` 全量 `30 min EC` 结果表中的 `u_mean` 与 `v_mean`
- 平均风速定义为 `sqrt(u_mean^2 + v_mean^2)`
- 所有 `source_group` pooled 后，按半小时计算中位数与 `25-75%` 四分位带
- 三种方法 `no_rotation / dr / PF_8bin_2ensemble` 同图对比

## 输出

- 图：`E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_wind_speed_diurnal.png`
- 作图表：`E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_wind_speed_diurnal_plot_data.csv`
- 说明：`E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_wind_speed_diurnal_summary.txt`

## 验证

- 脚本已成功执行
- 三种方法都覆盖完整 `48` 个 half-hour bin
- `PF_8bin_2ensemble` 的 `n_dates` 范围为 `42-126`
- `dr` 与 `no_rotation` 的 `n_dates` 范围为 `56-127`
