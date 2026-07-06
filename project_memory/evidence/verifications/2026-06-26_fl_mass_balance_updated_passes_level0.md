# 2026-06-26 FL 质量守恒重算：更新严格单程与 Level0 EC

## 来源与替换边界

- 用户指出旧 pass 筛选不完整，指定以 `E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_strict.csv` 作为新的严格完整单程表、以 `E:\Dataset_Level0\Flares\EC` 作为全部高频EC数据入口，并要求继续使用 `PF_8bin_2ensemble` 后覆盖 `E:\FL_MASSBALANCE` 旧结果。 [来源: 用户当前对话 2026-06-26]
- 新严格表共有2933个 `reject_reason == ok` 单程，起止日期覆盖127天；全量EC索引按这些单程起止日期筛选后保留228个原始TOA5文件，127个日期均无缺失。 [已核验: E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_strict.csv] [已核验: E:\Dataset_Level0\Flares\running_time\passes\ec_raw_files_full_index.csv]

## 实施与核验

- 主脚本 `E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R` 已改为读取新的严格表、EC全量索引和 `E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv`。运行记录源表在脚本内按本地时间转换为 `time_num` 并派生位置速度，后续PF、1 min聚合和lambda公式均沿用既有实现。 [已核验: E:\FL_MASSBALANCE\run_fl_mass_balance_8bin_2ensemble.R]
- 正式重算覆盖 `E:\FL_MASSBALANCE\results`、`qc` 和 `manifest.txt`。独立核验确认2933个严格单程全部保留且 `pass_id` 无重复；2868个达到 `data_status == calculated`，其中2789个mixed-sign单程实现质量平衡，最大 `abs(corrected_sum_w)` 为 `2.282896e-15`。 [已核验: E:\FL_MASSBALANCE\qc\verification_summary.txt]
- 未形成有效分钟结果的65个单程仍保留在主表，其中15个为 `no_pf_retained_minutes_for_pass`、50个为 `minute_coverage_or_scalar_qc_failed`；本轮没有 `no_raw_file_for_pass_date`、零有效风或零PF保留的日期组。 [已核验: E:\FL_MASSBALANCE\qc\verification_summary.txt] [已核验: E:\FL_MASSBALANCE\qc\FL_mass_balance_PF8bin_2ensemble_file_qc.csv]

## 派生图件与边界

- 月度热力色带图已重绘为15个有效月份，合并图重绘为125个有效日期和2805个跨午夜拆分segment；统一对称色标按新结果P98更新为 `+/-35 umol m-2 s-1`。合并图继续不标注 `low_minute_coverage`，保留 extreme-lambda 黑色实线边框。 [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_monthly_transport_heatband_verification.txt] [已核验: E:\FL_MASSBALANCE\figures\monthly_transport_heatbands\FL_mass_balance_transport_heatband_all_valid_dates_manifest.txt]
- 主计算日志仅记录到“50条以上warnings”这一汇总提示，未保留逐条警告文本。结果完整性、原始文件覆盖和质量守恒代数检查均已通过，但 warning 的具体来源未确认；若要追查，应以启用即时警告输出的单独诊断运行进行。 [已核验: E:\FL_MASSBALANCE\logs\mass_balance_recompute_20260626_stdout.log] [推断：基于日志未保留逐条warning文本整理]
