# 2026-07-02 W2 晨间 peak 固定口径：整体先降后升 + 廓线均值幅度

## 来源

- 用户要求：将当前“日出后廓线均值整体先降后升”的事件定义固定为现行口径，并把对应重跑结果作为当前固定口径写入项目记忆。[来源: 用户当前对话 2026-07-02]
- 本轮直接修改并重跑的事件检测脚本为 `D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]

## 本轮固定的事件定义

- 当前固定口径继续沿用 `CVT_MET` 的 `SW_in_Avg` 聚合到 `30 min` 后首个 `SW_in >= 20 W m^-2` 作为 `sunrise_ref_sw`，并继续使用 `pre_min_window = sunrise_ref + 0.0-2.5 h` 与 `peak_window = sunrise_ref + (2.5,4.5] h` 两个时间窗。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]
- 当前固定口径不再要求逐点单调下降或逐点单调上升，而是要求廓线均值 `co2_mean` 从 `sunrise_ref` 到 `pre_min_time` 呈“整体下降”，并从 `pre_min_time` 到 `peak_time` 呈“整体上升”；脚本实现为首末值比较，即 `tail(x, 1) < x[1]` 和 `tail(x, 1) > x[1]`。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]
- 当前固定口径下的 `amp_ppm` 明确写为 `profile_mean_CO2(peak_time) - profile_mean_CO2(pre_min_time)`，也就是用同一时刻整条廓线均值的差，而不是某层浓度极值的差。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]
- `peak_by_diff = amp_ppm > 0` 仍保留为无固定阈值的基础事件入口；`event_5ppm` 与 `event_10ppm` 继续作为强度分层字段保留，但在当前固定口径中不替代主事件定义。[已核验: D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R]

## 本轮重跑结果

- 本轮已运行 `Rscript D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R --self-test`，返回 `self-test ok`；`git diff --check` 对该脚本通过。[来源: 用户当前对话 2026-07-02]
- 本轮已重新运行 `detect_morning_peak_events_2025.R`、`build_morning_peak_event_types_2025.R` 与 `plot_morning_peak_amplitude_2025.R`，并覆盖 `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025` 下的事件表、分类表与幅度图。[来源: 用户当前对话 2026-07-02] [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\summary\morning_peak_events_2025_run_notes.txt]
- 按当前固定口径，`CVT` 的 `total_site_days = 365`、`usable_days = 199`、`peak_by_diff_days = 199`、`event_5ppm_days = 83`、`event_10ppm_days = 42`、`mean_amp_ppm = 6.230903`、`median_amp_ppm = 4.027771`。[已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\summary\morning_peak_events_2025_summary_by_site.csv]
- 按当前固定口径，`MT` 的 `total_site_days = 365`、`usable_days = 182`、`peak_by_diff_days = 182`、`event_5ppm_days = 72`、`event_10ppm_days = 34`、`mean_amp_ppm = 5.937104`、`median_amp_ppm = 3.918939`。[已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\summary\morning_peak_events_2025_summary_by_site.csv]
- 双塔按天汇总为 `total_days = 365`、`peak_by_diff_any_days = 229`、`peak_by_diff_both_days = 152`、`event_5ppm_any_days = 96`、`event_5ppm_both_days = 59`、`event_10ppm_any_days = 46`、`event_10ppm_both_days = 30`。[已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\summary\morning_peak_events_2025_summary_by_day.csv]

## 与下游分类集合的关系

- 本轮事件分类脚本也已重跑，当前固定集合输出仍位于 `E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections`；当前 `site_valid_events_2025.csv` 为 `89` 行，`paired_valid_typing_2025.csv` 为 `34` 行。后续引用时应把这些下游机制分类集合与事件检测分母分开表述，不要直接混用。[已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections\site_valid_events_2025.csv] [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections\paired_valid_typing_2025.csv]

## 当前含义

- 推断：截至 2026-07-02，W2 晨间 peak 的“当前固定口径”已经从 2026-06-30 的阈值重审阶段推进到“整体先降后升 + 廓线均值幅度”的可复现版本。后续若继续调整，应视为新口径并单独留痕，而不应与本口径混写。[推断：基于本轮脚本修改、重跑输出与用户要求整理]
