# 2026-06-02 `Fc_adv_2025.csv` 四天 `coef` 与 `fc_adv` 异常剔除可视化

## 新增输出

- 按用户要求，在 `E:\老师拷贝大量数据（4-30）\EC_ShH_new\Process\20250420\Fc_adv_2025.csv` 四天 `2025-03-20` 到 `2025-03-23` 结果基础上，新增异常剔除版可视化。新脚本为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fc_adv_coef_20250320_0323_filtered.R`。 [来源: 用户当前对话 2026-06-02] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\plot_fc_adv_coef_20250320_0323_filtered.R]
- 新图输出为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\Fc_adv_2025_20250320_0323_filtered\Fc_adv_2025_20250320_0323_coef_fc_adv_filtered.png`，版式为每个日期一行、左列 `time-coef`、右列 `time-fc_adv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\Fc_adv_2025_20250320_0323_filtered\Fc_adv_2025_20250320_0323_coef_fc_adv_filtered.png]

## 核验结果

- 本轮脚本强制把 `time` 列作为字符读入，并按 CSV 字符串日期筛选四天，避免自动日期解析造成跨日错位。四天共筛出 `187` 个点，其中 `coef = 1` 异常点共 `21` 个。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\Fc_adv_2025_20250320_0323_filtered\Fc_adv_2025_20250320_0323_filtered_daily_summary.csv]
- 异常点剔除规则为 `coef == 1`。这些点已从 `coef` 和 `fc_adv` 两列曲线中同时剔除，并用红色虚线标出异常发生时间。异常时间点表为 `D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\Fc_adv_2025_20250320_0323_filtered\Fc_adv_2025_20250320_0323_coef1_anomaly_times.csv`。 [已核验: D:\00 博士阶段\博一\05 Project\com_260507\COMPUTE\EA_com\Fc_adv_2025_20250320_0323_filtered\Fc_adv_2025_20250320_0323_coef1_anomaly_times.csv]
- 剔除后各日 `fc_adv` 最大绝对值为：`2025-03-20 = 58.50`、`2025-03-21 = 43.88`、`2025-03-22 = 103.03`、`2025-03-23 = 43.66`。新脚本和 manifest 中未检出 `teacher/Teacher` 字样，图标题不含 `teacher`。 [已核验: 本轮 `rg` 检查与 PNG 人工打开检查]

## 方法边界

- 该图只剔除了 `coef == 1` 的异常点。非 `coef == 1` 但 `coef` 很大的段仍保留，因为用户本轮要求限定在 `coef` 为 `1` 时的极端异常值。 [推断: 基于用户本轮要求和本轮脚本规则整理]
