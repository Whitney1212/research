# 2026-07-14 固定塔共同窗口核心差异图件

## 目的与口径

- 图件均使用 `2025` 年 MT/CVT 两塔、四种 rotation 方法共同存在的 `12,471` 个硬 QC 半小时窗口；差异定义为 `D = F_CVT - F_MT`。
- 方法比较图保留四种方法全部窗口散点，并仅将显示范围裁至合并分布的 1%–99% 分位数；计算和箱线统计不删点。
- 日变化和条件集中图采用 `sector_pf` 作为主口径；日变化中 `D` 的灰带为既有 3 日块、2,000 次 bootstrap 的 95% CI。

## 输出

- `E:\Dataset_Level1\Comparison\MT_CVT\figures\MT_CVT_hard_qc_rotation_violin.png/pdf`
- `E:\Dataset_Level1\Comparison\MT_CVT\figures\MT_CVT_hard_qc_sector_pf_diurnal_difference.png/pdf`
- `E:\Dataset_Level1\Comparison\MT_CVT\figures\MT_CVT_hard_qc_sector_pf_daytime_wind_stability_heatmap.png/pdf`

## 图件说明

- 方法图显示四个 rotation 口径下窗口级差异均以正值为主，但幅度存在方法敏感性。
- 日变化图同步显示 MT、CVT 和 `CVT-MT`：差异主要在白天增强，约 13:00–16:00 最强；阴影仅用于标出 `06:00–18:00` 时段。
- 条件热图只使用白天窗口；每格为累计碳差异（`gC m^-2`）及窗口数。最大正贡献集中于 `unstable × 240–270°`，并非所有风向或稳定度条件均一致为正。

## 复现

- 方法图：`E:\Dataset_Level1\Comparison\scripts\09_plot_rotation_violin.R`
- 日变化和条件图：`E:\Dataset_Level1\Comparison\scripts\10_plot_hard_qc_core_difference_figures.R`
- 两脚本已于 2026-07-14 成功运行；固定 `theme_bw()` 白底风格、去除 minor grid、标题加粗、图例置顶和 MT/CVT 固定配色遵循项目既定规范。
