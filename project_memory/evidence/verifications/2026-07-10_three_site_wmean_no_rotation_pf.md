# 2026-07-10 MT / CVT / FL w_mean 同图对比（No rotation / PF）

## 目的

把三个观测点的 `w_mean` 画在同一张图中，并按坐标旋转方法分成两个分面：

- `No rotation`
- `PF`

其中 `PF` 面板的口径固定为：

- `MT/CVT = sector_pf`
- `FL = PF_8bin_2ensemble (BPF)`

## 脚本

- `D:\00 博士阶段\99 Project\06 EA\scripts\plot_three_site_wmean_no_rotation_pf.R`

## 输入

- 固定塔：`E:\Dataset_Level1\FixedTower\EC\rotation_sensitivity_standardized_2025\mechanism_diagnostics\rotation_wmean_wc_diurnal_summary.csv`
- `FL`：`E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_wmean_diurnal_plot_data.csv`

## 输出

- 图：`E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\figures\three_site_wmean_no_rotation_pf.png`
- 作图表：`E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_wmean_no_rotation_pf_plot_data.csv`
- 说明：`E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_wmean_no_rotation_pf_summary.txt`

## 口径

- 固定塔只取 `w_mean (m s^-1)` 变量
- `No rotation` 面板使用 `MT/CVT No rotation + FL no_rotation`
- `PF` 面板使用 `MT/CVT Sector PF + FL PF_8bin_2ensemble`
- 三站均用中位数线 + `25-75%` 四分位带
- 两个面板共用同一 `y` 轴，便于直接比较方法差异

## 验证

- 三站 `x` 两分面共 `6` 组曲线都已进入图中
- 每组均覆盖完整 `48` 个 half-hour bin
- 图件已成功落盘到 `rotation_comparison_with_FL\figures`
