# 2026-06-27 FL 质量守恒处理状态补记

## 当前处理结果

- 本轮 FL 质量守恒正式结果已以 `E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_strict.csv` 为严格完整单程输入，并以 `E:\Dataset_Level0\Flares\EC` 全量高频 EC 索引和 `PF_8bin_2ensemble` 坐标旋转口径覆盖写入 `E:\FL_MASSBALANCE`。主脚本和核验脚本均已同步到新输入入口。 [来源: 用户当前对话 2026-06-26] [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R] [已核验: E:\FL_MASSBALANCE\verify_fl_mass_balance_8bin_2ensemble.R]
- 独立核验通过：主结果保留 `2933` 个严格单程且 `pass_id` 无重复；`2868` 个单程达到 `data_status == calculated`；其中 `2789` 个 mixed-sign 单程实现质量平衡，最大 `abs(corrected_sum_w)` 为 `2.282896e-15`。 [已核验: E:\FL_MASSBALANCE\qc\verification_summary.txt]
- 可视化已按新结果重绘：月度热力色带覆盖 `15` 个有效月份，合并图覆盖 `125` 个有效日期和 `2805` 个跨午夜拆分 segment，统一对称色标为 `+/-35 umol m-2 s-1`。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_verification.txt] [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest.txt]

## warnings 状态

- 正式重算日志只保留了 R 的汇总提示 `There were 50 or more warnings (use warnings() to see the first 50)`，`stderr` 日志为空，未保存逐条 warning 文本。该情况没有改变结果完整性核验和质量守恒代数核验结论，但目前不能据此判断 warning 的具体来源。 [已核验: E:\FL_MASSBALANCE\logs\mass_balance_recompute_20260626_stdout.log] [已核验: E:\FL_MASSBALANCE\logs\mass_balance_recompute_20260626_stderr.log] [已核验: E:\FL_MASSBALANCE\qc\verification_summary.txt]
- 2026-06-27 曾尝试在临时目录 `E:\FL_MASSBALANCE\_warn_diag_20260627` 以 `options(warn=1)` 和 `FL_MB_MAX_DATES=10` 做即时 warning 诊断，但该运行只记录到读取严格单程和统一运行记录阶段，尚未产生逐条 warning 明细；用户随后中断该追查，因此 warning 原文仍未确认。 [已核验: E:\FL_MASSBALANCE\logs\warning_diag_20260627_first10.log] [来源: 用户当前对话 2026-06-27]
- 代码层面可疑但尚未实证的 warning 来源包括：TOA5 文件缺少必要列时脚本主动 `warning("Skipping TOA5 file with missing columns")`，以及分钟聚合里直接调用 `min(position_m_record)`、`max(position_m_record)` 或 `max(running_gap_s, na.rm = TRUE)` 时遇到全缺失组。后续若要确认，应单独运行更小日期范围的即时 warning 诊断，不应从当前日志反推定论。 [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R] [推断：基于脚本 warning 调用点和聚合边界整理]

## 后续最小动作

- 若只使用当前正式结果，优先沿用 `verification_summary.txt` 与图件 manifest 的通过结论；若要解释 warning，下一步应单独挑选少量日期重跑并保存 `warnings()` 或 `withCallingHandlers()` 输出，避免覆盖正式 `E:\FL_MASSBALANCE` 结果。 [推断：基于当前日志保留情况和用户要求整理]
