# 2026-07-10 FL 全量 sigma_co2 与 sigma_w 日变化图

## 目的

基于已经交付的 `FL` 全量 `EC_ecpreproc` `30 min` 成品，补出：

- `sigma_w` 日变化
- `sigma_co2` 日变化

不回上游重算通量，只复用现有结果表。

## 输入位置

- 根目录：`E:\Dataset_Level1\Flares\EC_ecpreproc`
- 三个 pooled source-group：
  - `oldcode_0_245`
  - `batch_b_complete`
  - `main_complete`
- 三个 rotation 方法：
  - `no_rotation`
  - `dr`
  - `PF_8bin_2ensemble`

对应输入表位于各自 `results\FL_flux_*.csv`。

## 脚本

- `D:\00 博士阶段\99 Project\06 EA\scripts\plot_fl_full_ec_sigma_diurnal.R`

## 输出

- 图：`E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_sigma_diurnal.png`
- 作图表：`E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_sigma_diurnal_plot_data.csv`
- 说明：`E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_sigma_diurnal_summary.txt`

## 口径

- `sigma_w` 直接使用交付表中的 `w_sd`
- `sigma_co2` 直接使用交付表中的 `scalar_sd`
- 所有 `source_group` 合并 pooled 后，按半小时计算中位数与 `25-75%` 四分位带
- 时间轴沿用 `FL` 全量产品既有本地时区口径 `Asia/Shanghai`

## 验证

- `Rscript D:\00 博士阶段\99 Project\06 EA\scripts\plot_fl_full_ec_sigma_diurnal.R` 已成功执行
- `summary` 已确认两类变量、三种方法都覆盖完整 `48` 个 half-hour bin
- `PF_8bin_2ensemble` 的 `n_dates` 范围为 `42-126`
- `dr` 与 `no_rotation` 的 `n_dates` 范围为 `56-127`

## 说明

这次只是重绘 `FL` 已交付 `30 min` 波动统计结果，不涉及重新计算 `EC covariance`、重新旋转或重新做上游高频 `sigma` 汇总。
