# 2026-06-24 FL 质量守恒垂直输送月度热力色带图

## 来源与图形口径

- 用户要求把当前质量守恒后垂直输送按月份绘制热力色带图：每个有效月份一张、一天一列、横轴日期、纵轴0–24时，只展示有有效结果的日期和时段。 [来源: 用户当前对话 2026-06-24]
- 本轮图件只使用 `data_status == calculated`、`mass_balance_achieved == TRUE` 且 `F_lambda_pf_umol_m2_s` 有限的mixed-sign完整单程，共996个。single-sign和不可计算单程不进入主色带；`extreme_lambda` 使用黑色边框，`low_minute_coverage` 使用灰黑虚线边框。 [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_monthly_transport_heatbands.R]
- 所有月份使用统一的以0为中心发散色标。全局 `P98(abs(F_lambda_pf_umol_m2_s))` 为 `28.241794 umol m-2 s-1`，色标上限向上取整为 `+/-30 umol m-2 s-1`，超出值压到色标端点但不删除。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_verification.txt]

## 输出与验证

- 绘图脚本为 `E:\FL_MASSBALANCE\plot_fl_mass_balance_monthly_transport_heatbands.R`，输出目录为 `E:\FL_MASSBALANCE\figures\monthly_transport_heatbands`。有效月份共5个：`2024-10`、`2024-12`、`2025-01`、`2025-03`、`2025-04`，每月各生成一张300 dpi PNG。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_manifest.csv]
- 图件按实际单程起止时间绘制纵向色带；跨午夜单程拆成两段，因此996个有效pass对应1000个作图segment。横轴只保留有有效segment的日期列，纵轴固定为0–24时，空白时间保持不填色。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_segments.csv]
- 5张PNG均存在并已逐张目视检查，日期标签、统一色标、0–24时轴、极端lambda黑边框和低分钟覆盖虚线边框显示正常。图件manifest记录各月有效日期数、pass数、segment数和画布参数；验证文件结论为 `PASS`。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_verification.txt]

## 边界

- 这些图展示的是成功完成上下空气量平衡的mixed-sign输送结果，不展示single-sign持续穿流事件，因此不能用图中空白直接判断“没有垂直运动”。 [推断：基于图件筛选口径与single-sign方法边界整理]
- 色标为了跨月可比而使用统一稳健范围，绝对值超过30的结果会显示为端点颜色；精确数值仍保存在pass主表和作图segment表中。 [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_monthly_transport_heatbands.R]
