# 2026-06-02 `Fc_adv_2025.csv` 作图时间相位修正

## 问题确认

- 用户指出原始 `time-fc_adv` 图与异常剔除图中的剔除位置不完全对齐。本轮复核确认第一版原始图确实存在时间相位问题。 [来源: 用户当前对话 2026-06-02]
- 原因是 `plot_teacher_fc_adv_20250320_0323.R` 第一版使用 `data.table::fread()` 默认读取 `time`，`fread()` 自动把 `time` 解析为 `POSIXct`。脚本随后又按 `Asia/Shanghai` 计算日期和小时，导致显式日期时间行被整体表现为约 `+8 h` 的相位偏移，部分晚间点还会被归到次日。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_teacher_fc_adv_20250320_0323.R]

## 修正

- 已修改 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_teacher_fc_adv_20250320_0323.R`：读取 CSV 时强制 `time` 为 character，并按 CSV 字符串日期筛选 `2025-03-20` 到 `2025-03-23`，与异常剔除版脚本保持一致。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_teacher_fc_adv_20250320_0323.R]
- 已重跑原始全量图并覆盖输出到 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\teacher_fc_adv_20250320_0323\teacher_Fc_adv_2025_20250320_0323_time_series.png`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\teacher_fc_adv_20250320_0323\teacher_Fc_adv_2025_20250320_0323_time_series.png]

## 修正后核验

- 修正后四天仍共 `187` 个点，但每日点数变为：`2025-03-20 = 43`、`2025-03-21 = 48`、`2025-03-22 = 48`、`2025-03-23 = 48`。第一版记录中的 `2025-03-20 = 44`、`2025-03-21 = 47` 是相位错位下的筛选结果，不应继续使用。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\teacher_fc_adv_20250320_0323\teacher_Fc_adv_2025_20250320_0323_daily_summary.csv]
- 修正后原始全量图中的 `coef == 1` 极端点时间与过滤图中的红色异常标记完全一致；对比结果 `same anomaly hours: TRUE`。 [已核验: 本轮 R 对比 `teacher_Fc_adv_2025_20250320_0323_subset.csv` 与 `Fc_adv_2025_20250320_0323_filtered_subset.csv`]
