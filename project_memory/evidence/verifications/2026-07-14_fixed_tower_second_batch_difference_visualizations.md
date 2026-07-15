# 2026-07-14 固定塔共同窗口差异第二批补充图

## 共同口径

- 所有图均来自 `2025` 年 MT/CVT 的硬 QC 共同半小时窗口，并以 `sector_pf` 为主口径；差异均定义为 `F_CVT - F_MT`。
- 图件保持项目固定科研风格：`theme_bw()` 白底、无 minor grid、标题加粗、浅灰分面标题和 300 dpi 输出。

## 输出

- 季节 × 半小时热图：`E:\Dataset_Level1\Comparison\MT_CVT\figures\MT_CVT_hard_qc_sector_pf_season_halfhour_heatmap.png/pdf`
  - 色阶为每个季节 × 半小时格的平均差异，而非累计值，避免把季节覆盖量差异直接当作物理强度。
- 条件贡献及 CI：`E:\Dataset_Level1\Comparison\MT_CVT\figures\MT_CVT_hard_qc_sector_pf_condition_contributions.png/pdf`
  - 覆盖 MT 稳定度、风速和风向扇区；柱为累计碳差异，误差线为既有 3 日块、2,000 次 bootstrap 95% CI，标签为窗口数。
- 核心条件机制诊断：`E:\Dataset_Level1\Comparison\MT_CVT\figures\MT_CVT_hard_qc_sector_pf_core_condition_mechanisms.png/pdf`
  - 限定为 MT `unstable`、`06:00–18:00`、风向 `180–270°` 的窗口；展示 `D` 与两塔 `w_mean`、`sigma_w`、tilt 差的二维密度及线性趋势。趋势只作描述性诊断，不作因果或机制证明。

## 复现与核验

- 脚本：`E:\Dataset_Level1\Comparison\scripts\11_plot_hard_qc_second_batch_figures.R`
- 已成功运行；脚本断言季节 × 半小时格完整、条件分组数为 19、bootstrap CI 有限且核心机制窗口数大于 500。
