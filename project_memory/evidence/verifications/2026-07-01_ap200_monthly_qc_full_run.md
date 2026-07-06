# 2026-07-01 AP200 月批 QC 与全量执行核验

## 来源

- 本次记录整理自用户在当前对话中给出的 AP200 月批执行要求、输入目录和目标输出目录，并结合本回合直接核验与执行的本地脚本、源数据目录和输出文件整理而成。[来源: 用户当前对话 2026-07-01]

## 月批脚本与执行口径

- 已新增月批执行脚本 `D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R`。该脚本复用现有 `MT/CVT` AP200 QC 逻辑，按月输出 raw-file、cycle、after-qc、day、missing-dates、overall、bad-files 和 month-summary 八类结果，并在不指定 `--month` 时自动汇总为站点全时段总表。[已核验 D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R]
- 该脚本当前只读取 profile 类 `.dat` 文件，而不把 `CalAvg` 或 `IntAvg` 混入剖面 QC。`MT` 使用文件名模式 `(SiteAvg|main_tower_co2_data).*\\.dat$`，`CVT` 使用 `SiteAvg.*\\.dat$`；这是为了同时兼容旧批次 `main_tower_co2_data_*` 和后续批次 `SiteAvg_*` 的长表结构。[已核验 D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R] [已核验 E:\Dataset_Level0\MT\AP\20240704-20260131] [已核验 E:\Dataset_Level0\MT\AP\202601011920-202604141057] [已核验 E:\Dataset_Level0\CVT\AP\202411121700-202602020930]
- 月批脚本会为每个月额外带入前后各一个支持文件，用于闭合跨月轮次，然后只把 `cycle_time` 落在目标月份内的轮次写回该月目录。这意味着月目录结果适合中断后续跑与按月追溯，同时仍尽量避免月边界轮次被截断。[已核验 D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R]

## 特殊约束与最小验证

- `CVT 2025-03-23` 的 `valve_number = 7/c32` 特殊剔除规则已经在月批脚本中继承为窄范围条件：只对 `2025-03-23 17:53:30` 之后的 `c32` 置为缺测，而不是对所有后续日期都屏蔽。[已核验 D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R] [已核验 D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-05-25_cvt0323_c32_profile_qc.md]
- 最小运行验证已经通过。`MT 2026-05` 月批结果为 `files=32`、`cycles=29677`、`keep=29529`；`CVT 2026-05` 月批结果为 `files=32`、`cycles=22300`、`keep=21679`。脚本修正后，两站测试月均可无 warning 完成运行。[已核验 E:\Dataset_Level1\MT\AP\20240704-20260622\monthly\2026-05\MT_AP_profile_overall_qc_summary_2026-05.csv] [已核验 E:\Dataset_Level1\CVT\AP\20240704-20260622\monthly\2026-05\CVT_AP_profile_overall_qc_summary_2026-05.csv]
- `CVT 2025-03` 的特殊日边界也已核验：`2025-03-23 17:51:45` 仍保留完整 `c24/c32/c43`，而 `2025-03-23 17:53:45` 之后轮次开始因 `c32` 缺测变为 `qc_flag_cycle = 3` 且 `qc_keep_cycle = FALSE`；`18:00` 之后不再保留合格轮次。这与既有 `CVT 2025-03-23` profile QC 约束一致。[已核验 E:\Dataset_Level1\CVT\AP\20240704-20260622\monthly\2025-03\CVT_AP_profile_cycle_qc_summary_2025-03.csv]

## 输入覆盖与全量执行结果

- 本次全量运行使用的源目录为：`MT` 的 `E:\Dataset_Level0\MT\AP\20240704-20260131`、`E:\Dataset_Level0\MT\AP\202601011920-202604141057`、`E:\Dataset_Level0\MT\AP\202604221000-202605101700`、`E:\Dataset_Level0\MT\AP\202605101700-202606221300`，以及 `CVT` 的 `E:\Dataset_Level0\CVT\AP\202411121700-202602020930`、`E:\Dataset_Level0\CVT\AP\202602020930-202605101500`、`E:\Dataset_Level0\CVT\AP\202605101500-202606221600`。[来源: 用户当前对话 2026-07-01] [已核验 D:\00 博士阶段\99 Project\06 EA\scripts\run_ap_profile_qc_monthly.R]
- 按当前 profile 文件筛选口径，`MT` 共匹配 `661` 个源文件，分目录为 `519 + 79 + 19 + 44`；`CVT` 共匹配 `571` 个源文件，分目录为 `429 + 98 + 44`。月批总表中的 `n_target_files` 求和分别也是 `661` 和 `571`，说明本次全量执行没有漏掉符合口径的 profile 类源文件。[已核验 E:\Dataset_Level0\MT\AP\20240704-20260131] [已核验 E:\Dataset_Level0\MT\AP\202601011920-202604141057] [已核验 E:\Dataset_Level0\MT\AP\202604221000-202605101700] [已核验 E:\Dataset_Level0\MT\AP\202605101700-202606221300] [已核验 E:\Dataset_Level0\CVT\AP\202411121700-202602020930] [已核验 E:\Dataset_Level0\CVT\AP\202602020930-202605101500] [已核验 E:\Dataset_Level0\CVT\AP\202605101500-202606221600] [已核验 E:\Dataset_Level1\MT\AP\20240704-20260622\MT_AP_month_run_summary_20240704_20260622.csv] [已核验 E:\Dataset_Level1\CVT\AP\20240704-20260622\CVT_AP_month_run_summary_20241112_20260622.csv]
- `MT` 的月批目录根为 `E:\Dataset_Level1\MT\AP\20240704-20260622\monthly`，站点级总表根为 `E:\Dataset_Level1\MT\AP\20240704-20260622`。当前总表摘要为：`n_files = 661`、`n_bad_files = 0`、`n_cycles_total = 626347`、`n_cycles_keep = 623854`、`cycle_failure_ratio = 0.004`、`n_days_with_cycles = 658`、`n_missing_dates = 61`。[已核验 E:\Dataset_Level1\MT\AP\20240704-20260622\MT_AP_profile_overall_qc_summary_20240704_20260622.csv]
- `CVT` 的月批目录根为 `E:\Dataset_Level1\CVT\AP\20240704-20260622\monthly`，站点级总表根为 `E:\Dataset_Level1\CVT\AP\20240704-20260622`。当前总表摘要为：`n_files = 571`、`n_bad_files = 0`、`n_cycles_total = 401430`、`n_cycles_keep = 397245`、`cycle_failure_ratio = 0.0104`、`n_days_with_cycles = 565`、`n_missing_dates = 23`。[已核验 E:\Dataset_Level1\CVT\AP\20240704-20260622\CVT_AP_profile_overall_qc_summary_20241112_20260622.csv]

## 输出位置

- `MT` 当前已经生成 8 个站点级总文件：`MT_AP_raw_file_qc_summary_20240704_20260622.csv`、`MT_AP_profile_cycle_qc_summary_20240704_20260622.csv`、`MT_AP_profile_cycle_after_qc_20240704_20260622.csv`、`MT_AP_profile_day_qc_summary_20240704_20260622.csv`、`MT_AP_profile_missing_dates_20240704_20260622.csv`、`MT_AP_profile_overall_qc_summary_20240704_20260622.csv`、`MT_AP_bad_files_20240704_20260622.csv` 和 `MT_AP_month_run_summary_20240704_20260622.csv`，都位于 `E:\Dataset_Level1\MT\AP\20240704-20260622`。[已核验 E:\Dataset_Level1\MT\AP\20240704-20260622]
- `CVT` 当前已经生成 8 个站点级总文件：`CVT_AP_raw_file_qc_summary_20241112_20260622.csv`、`CVT_AP_profile_cycle_qc_summary_20241112_20260622.csv`、`CVT_AP_profile_cycle_after_qc_20241112_20260622.csv`、`CVT_AP_profile_day_qc_summary_20241112_20260622.csv`、`CVT_AP_profile_missing_dates_20241112_20260622.csv`、`CVT_AP_profile_overall_qc_summary_20241112_20260622.csv`、`CVT_AP_bad_files_20241112_20260622.csv` 和 `CVT_AP_month_run_summary_20241112_20260622.csv`，都位于 `E:\Dataset_Level1\CVT\AP\20240704-20260622`。[已核验 E:\Dataset_Level1\CVT\AP\20240704-20260622]

## 口径说明

- `MT` 总表里的 `cycle_flag_ratio = 1` 不是本次月批脚本新增的问题，而是继承自原 `E:\Dataset_Level1\MT\AP\QC.R` 的轮次判据与汇总口径：原脚本就把 `qc_raw_inherited` 计入 `qc_flag_cycle`，并用 `qc_flag_cycle > 0` 统计 `cycle_flag_ratio`。因此这项指标在 `MT` 上不应简单解释为“所有轮次都不可用”，真正的可用性仍应优先看 `qc_keep_cycle` 与 `cycle_failure_ratio`。[已核验 E:\Dataset_Level1\MT\AP\QC.R] [已核验 E:\Dataset_Level1\MT\AP\20240704-20260622\monthly\2026-05\MT_AP_profile_cycle_qc_summary_2026-05.csv] [推断：基于原脚本汇总口径与本次输出对应关系整理]
