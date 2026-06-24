# 2026-06-24 FL 质量守恒垂直输送合并热力色带图

## 来源与图形口径

- 用户要求在已有月度图基础上再生成一张合并图，横轴日期标注年份，无效日期不占横轴位置，并且不再标注 `low_minute_coverage`。 [来源: 用户当前对话 2026-06-24]
- 合并图直接读取已经核验的月度作图 segment 表，不重新计算质量守恒结果。图中仅保留996个成功实现质量平衡的 mixed-sign 完整单程，共1000个跨日拆分后的 segment。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest.txt]
- 横轴只排列41个存在有效 segment 的日期，标签采用完整 `YYYY-MM-DD`；日期范围为 `2024-10-13` 至 `2025-04-22`。无效日期和无结果日期不生成占位列，月份之间用细实线分隔。 [已核验: E:\FL_MASSBALANCE\plot_fl_mass_balance_combined_transport_heatband.R]
- 图中保留20个 `extreme_lambda` 单程的黑色实线边框，不绘制 `low_minute_coverage` 虚线边框。所有日期继续共用以0为中心的 `+/-30 umol m-2 s-1` 色标。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest.txt]

## 输出与验证

- 绘图脚本为 `E:\FL_MASSBALANCE\plot_fl_mass_balance_combined_transport_heatband.R`，图件为 `E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates.png`。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates.png]
- R脚本语法检查和完整执行均成功；manifest 的验证结论为 `PASS`。本轮还按原始分辨率目视检查了完整年份日期标签、0–24时纵轴、日期压缩、月份分隔和边框样式，未发现残留虚线标记。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest.txt]

## 边界

- 合并图压缩的是无效日期，而不是实际观测时间；因此相邻两列在图上等宽，不代表它们在日历上连续。月份分隔线用于提醒这种非连续性。 [推断：基于离散有效日期横轴的显示口径整理]
- 图中空白时段表示该有效日期对应时段没有成功质量平衡的 mixed-sign 单程结果，不能直接解释为没有垂直运动。 [推断：基于质量守恒结果筛选边界整理]

