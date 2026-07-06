# 2026-06-30 W2 晨间 peak 幅度清单与阈值重审

## 来源

- 用户指出当前事件阈值方法不够明确，要求先用差值定位所有出现 peak 的事件并确认幅度，再根据所有幅度划定阈值。 [来源: 用户当前对话 2026-06-30]

## 当前检测口径

- 当前 `detect_morning_peak_events_2025.R` 仍沿用固定日出相对时间窗口：`sunrise_ref` 来自 `CVT_MET SW_in_Avg` 聚合到 30 min 后首个 `SW_in >= 20 W m^-2`；`pre_min_window` 为 `sunrise_ref + 0 h` 到 `+2.5 h`；`peak_window` 为 `sunrise_ref + >2.5 h` 到 `+4.5 h`。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]
- 当前幅度定义为 `amp_ppm = peak_window max CO2 - pre_min_window min CO2`。新增 `peak_by_diff = amp_ppm > 0`，作为不依赖 5/10 ppm 阈值的连续幅度清单入口。 [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]
- `event_5ppm = amp_ppm >= 5` 与 `event_10ppm = amp_ppm >= 10` 当前只保留为 provisional threshold flags，不再作为唯一事件定义。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\summary\morning_peak_events_2025_run_notes.txt]

## 新增输出

- 全部可判定站点日幅度清单输出为 `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\metrics\morning_peak_amplitude_inventory_2025_site_day.csv`。该表保留 `pre_min_time`、`pre_min_co2`、`peak_time`、`peak_co2`、`amp_ppm`、`peak_by_diff` 和 provisional `event_5ppm/event_10ppm`。 [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\metrics\morning_peak_amplitude_inventory_2025_site_day.csv]
- 幅度分位数输出为 `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\summary\morning_peak_amplitude_quantiles_2025_by_site.csv`。当前 `CVT` 的 `q50=3.606829`、`q75=10.765214`、`q90=23.96526`、`q95=33.76707`；`MT` 的 `q50=1.385237`、`q75=5.347846`、`q90=11.71201`、`q95=17.28170`。 [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\summary\morning_peak_amplitude_quantiles_2025_by_site.csv]

## 当前幅度结果

- `CVT` 可判定站点日为 `342` 天，其中 `amp_ppm > 0` 为 `233` 天，`amp_ppm >= 5` 为 `154` 天，`amp_ppm >= 10` 为 `90` 天。 [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\metrics\morning_peak_amplitude_inventory_2025_site_day.csv]
- `MT` 可判定站点日为 `339` 天，其中 `amp_ppm > 0` 为 `214` 天，`amp_ppm >= 5` 为 `91` 天，`amp_ppm >= 10` 为 `47` 天。 [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\metrics\morning_peak_amplitude_inventory_2025_site_day.csv]
- 双塔日表中，任一塔 `amp_ppm > 0` 为 `262` 天，双塔同时 `amp_ppm > 0` 为 `185` 天。 [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\metrics\morning_peak_events_2025_day_pair.csv]

## 方法边界

- 当前修正不改变日出、窗口和 `amp_ppm` 的计算方式，只改变阈值解释：后续应先检查 `amp_ppm` 分布、噪声水平和事件形态，再决定正式阈值。 [来源: 用户当前对话 2026-06-30] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]
- 推断：在正式阈值冻结前，`5 ppm` 和 `10 ppm` 可以用于敏感性和阶段性比较，但不应写成最终发生率定义。 [推断：基于用户当前方法修正和新增幅度清单整理]
