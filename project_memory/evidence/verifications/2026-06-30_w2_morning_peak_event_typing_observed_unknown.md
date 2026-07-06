# 2026-06-30 W2 晨间 peak 事件分类与 observed_unknown 口径核验

## 背景

用户要求在 2025 自然年晨间 peak 自动识别基础上，生成 `5 ppm` 和 `10 ppm` 两套双固定塔事件类型表，并明确：一塔达到阈值、另一塔不可判定时，不能归入 `Only` 事件；应标注清楚，但在机制判定和四类对照汇总中不计入有 `observed_unknown` 的天数。

## 脚本与输出

- 自动识别脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\detect_morning_peak_events_2025.R`
- 事件分类脚本：`D:\00 博士阶段\99 Project\06 EA\scripts\build_morning_peak_event_types_2025.R`
- 自动识别输出根目录：`E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025`
- 事件分类输出目录：`E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing`
- 固定集合输出目录：`E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections`

## 当前固定数据集合

- `site_valid_events`：单塔可判定即可进入，用于单塔发生率、季节性和长期频率分析。当前文件为 `collections/site_valid_events_2025.csv`，共 `681` 个站点日，其中 `CVT=342`、`MT=339`；对应事件数为 `CVT 5 ppm=154`、`CVT 10 ppm=90`、`MT 5 ppm=91`、`MT 10 ppm=47`。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections\site_valid_events_2025.csv]
- `paired_valid_typing`：双塔都可判定才进入，用于 `CVT_only / MT_only / both / none` 双塔机制分类。当前文件为 `collections/paired_valid_typing_2025.csv`，采用 `threshold_ppm` 长表保存 `5 ppm` 和 `10 ppm` 两套分类，共 `650` 行，即两个阈值各 `325` 个双塔可比日期。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections\paired_valid_typing_2025.csv]
- `paired_missing_one_site`：一塔可判定、另一塔缺失时进入，只用于缺口说明，不进入双塔机制判断。当前文件为 `collections/paired_missing_one_site_2025.csv`，采用 `threshold_ppm` 长表保存 `5 ppm` 和 `10 ppm` 两套缺口说明，共 `62` 行，即两个阈值各 `31` 个单侧缺失日期。 [来源: 用户当前对话 2026-06-30] [已核验: E:\Dataset_Level1\MorningPeak\W2_2025_candidates\auto_peak_r_2025\event_typing\collections\paired_missing_one_site_2025.csv]

## 当前事件分类规则

- `CVT_only`、`MT_only`、`both`、`none` 只用于两塔在该阈值下都可判定的可比日期。
- 一塔达到阈值、另一塔不可判定时，不归入 `Only`，而标注为：
  - `CVT_observed_MT_unknown`
  - `MT_observed_CVT_unknown`
- `observed_unknown` 日期保留在 counts 和 day-level 明细中，用于说明“任一塔事件日”和可比四类事件日之间的差额。
- `observed_unknown` 日期属于 `paired_missing_one_site` 的阈值相关缺口说明，不进入 `paired_valid_typing`、`summary_by_class_site`、双塔相位比较和后续 `CVT_only / MT_only / both / none` 对照解释。
- `insufficient_data` 用于没有观测到达阈值事件、且当天无法形成双塔可比判定的日期。

## 2025 当前计数

`10 ppm` 分类：

| event_class | n_days |
|---|---:|
| CVT_only | 55 |
| MT_only | 11 |
| both | 35 |
| none | 224 |
| MT_observed_CVT_unknown | 1 |
| insufficient_data | 39 |

`10 ppm` 中，任一塔观测到事件为 `102` 天；可比四类中的事件日为 `55 + 11 + 35 = 101` 天，差额 `1` 天为 `MT_observed_CVT_unknown`。

`5 ppm` 分类：

| event_class | n_days |
|---|---:|
| CVT_only | 77 |
| MT_only | 12 |
| both | 76 |
| none | 160 |
| CVT_observed_MT_unknown | 1 |
| MT_observed_CVT_unknown | 3 |
| insufficient_data | 36 |

`5 ppm` 中，任一塔观测到事件为 `169` 天；可比四类中的事件日为 `77 + 12 + 76 = 165` 天，差额 `4` 天为 `observed_unknown`。

`paired_missing_one_site` 缺口说明：

| threshold_ppm | available_site | missing_site | event_class | n_rows |
|---:|---|---|---|---:|
| 5 | CVT | MT | CVT_observed_MT_unknown | 1 |
| 5 | CVT | MT | insufficient_data | 16 |
| 5 | MT | CVT | MT_observed_CVT_unknown | 3 |
| 5 | MT | CVT | insufficient_data | 11 |
| 10 | CVT | MT | insufficient_data | 17 |
| 10 | MT | CVT | MT_observed_CVT_unknown | 1 |
| 10 | MT | CVT | insufficient_data | 13 |

## 双塔相位输出

- `10 ppm` 双塔同时事件 `both = 35` 天：`near_sync = 19`，`unclear = 16`。
- `5 ppm` 双塔同时事件 `both = 76` 天：`CVT_leads = 1`，`MT_leads = 1`，`near_sync = 39`，`unclear = 35`。

当前 `lead-lag` 分类仍按 peak/rise 一致性和时间差规则输出；`observed_unknown` 日期不参加该相位判定。

## 核验

- `Rscript D:\00 博士阶段\99 Project\06 EA\scripts\build_morning_peak_event_types_2025.R --self-test` 返回 `self-test ok`。
- `git diff --check -- scripts/build_morning_peak_event_types_2025.R` 通过。
- 重新运行 `build_morning_peak_event_types_2025.R` 后，新增 `collections/site_valid_events_2025.csv`、`collections/paired_valid_typing_2025.csv` 和 `collections/paired_missing_one_site_2025.csv`。
- 重新运行事件分类后，`summary/event_class_2025_summary_by_class_site.csv` 与 `summary/event_class_5ppm_2025_summary_by_class_site.csv` 的 `event_class` 只包含 `CVT_only`、`MT_only`、`both`、`none` 四类。
- 计数表中保留 `observed_unknown` 标签，用于解释任一塔事件日数量与可比四类事件日数量的差额。

## 解释边界

当前分类解决的是双固定塔事件日的可比性问题，不直接证明水平传播或局地再分配机制。后续机制分析应以 `paired_valid_typing` 中四类可比日期和 `both` 相位日期为主；`site_valid_events` 只用于单塔长期频率和季节性，`paired_missing_one_site` 只用于缺口说明和 QC 注释，不能用于判断“只有某一塔响应”。
