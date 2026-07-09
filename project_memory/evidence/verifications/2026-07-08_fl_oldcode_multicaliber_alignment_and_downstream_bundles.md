# 2026-07-08 FL 旧编码 batch C 对齐、多口径合并与下游适配

## 来源

- 这份记录整理自用户当前对话中关于 `FL` 旧编码 `batch C`、多口径合并和下游脚本适配的要求，并在本轮直接核验相关脚本与输出文件。 [来源: 用户当前对话 2026-07-08]

## 已核验事实

- 本轮在 `E:\FL_MASSBALANCE\202308` 新增并保留了四个脚本：`extract_monotonic_segments_from_raw_20230315_20231226.R`、`align_oldcode_batchc_segments_to_local_0_245m.R`、`merge_fl_multicaliber_records.R` 和 `prepare_fl_multicaliber_downstream_inputs.R`；同时给 `E:\FL_pre\scripts\fl_full_records_02_complete_passes_and_ec_availability.R` 增加了默认关闭的 `FL_STRICT_SKIP_EC_AVAILABILITY=1` 开关，供这次只取 `geometry_complete` 完整单程时跳过 EC availability 检查。 [已核验: E:\FL_MASSBALANCE\202308\extract_monotonic_segments_from_raw_20230315_20231226.R] [已核验: E:\FL_MASSBALANCE\202308\align_oldcode_batchc_segments_to_local_0_245m.R] [已核验: E:\FL_MASSBALANCE\202308\merge_fl_multicaliber_records.R] [已核验: E:\FL_MASSBALANCE\202308\prepare_fl_multicaliber_downstream_inputs.R] [已核验: E:\FL_pre\scripts\fl_full_records_02_complete_passes_and_ec_availability.R]
- 旧编码 `batch C` 这次不是从已筛选 records 反推，而是直接从原始运行记录 `E:\Dataset_RAW\Flares\运行记录\20230315_20231226.csv` 切分单调段。摘要显示：原始 `6982418` 行，去除长静止段后保留 `1206124` 行，共识别 `2432` 个连续单调段；若按旧的 `shift-10` 和 `5-240 m` 近似全跨段检查，则有 `1891` 个 full-span 段。 [已核验: E:\FL_MASSBALANCE\202308\fl_monotonic_segments_20230315_20231226_summary.txt]
- 最终旧编码对齐规则已经固定为：去程把每个单调段的起点编码视为本地 `0 m`，返程把每个单调段的终点编码视为本地 `0 m`，两者都只保留本地 `0-245 m` 段。对齐后共有 `1816` 个 segment，其中去程 `893` 个、返程 `923` 个，对齐 records 共 `1102774` 行，段平均速度中位数为 `13.44 cm/s`。 [已核验: E:\FL_MASSBALANCE\202308\fl_batchc_local0_245_from_monotonic_segments_summary.txt]
- 最终保留的旧编码起点簇只剩两个正值编码簇，中心分别约为 `9.6201` 和 `14.6151`；最终 origin-cluster 输出中已经没有负值起点簇，符合“`-5.84` 起点直接删去”的当前处理结果。 [已核验: E:\FL_MASSBALANCE\202308\fl_batchc_local0_245_from_monotonic_segments_origin_clusters.csv]
- `merge_fl_multicaliber_records.R` 当前不再从 retained `strict` pass 表反推主口径和 `B` 批次，而是分别复用 `fl_full_records_02_complete_passes_and_ec_availability.R` 的 `geometry_complete` candidate 输出：`B` 批次取 `2025-08-17` 到 `2025-10-01` 窗口内 `0-230 m` 完整单程，主口径取该窗口外 `0-245 m` 完整单程。对应 helper manifest 已记录 `skip_ec_availability = TRUE`。 [已核验: E:\FL_MASSBALANCE\202308\multicaliber_sources\batch_b_complete\complete_pass_marker\fl_complete_passes_incremental_manifest.txt] [已核验: E:\FL_MASSBALANCE\202308\multicaliber_sources\main_complete\complete_pass_marker\fl_complete_passes_incremental_manifest.txt]
- 多口径合并结果已经输出到 `fl_multicaliber_merged_records*.csv`。当前摘要显示 merged records 共 `5612945` 行、merged segments 共 `5187` 个，来源组固定为 `oldcode_0_245`、`batch_b_complete` 和 `main_complete`，且明确“不做跨来源去重，只保留 `source_group` 标签”。 [已核验: E:\FL_MASSBALANCE\202308\fl_multicaliber_merged_records_summary.txt]
- 三个来源组的当前口径与规模已经固定为：`oldcode_0_245` 对应 `local_zero_clip_0_245`，`1816` 个 segment，日期范围 `2023-04-17` 到 `2023-12-08`；`batch_b_complete` 对应 `complete_run_0_230`，`1065` 个 segment，日期范围 `2025-08-23` 到 `2025-09-30`；`main_complete` 对应 `complete_run_0_245`，`2306` 个 segment，日期范围 `2023-04-17` 到 `2026-06-04`。 [已核验: E:\FL_MASSBALANCE\202308\fl_multicaliber_merged_records_source_summary.csv]
- 下游适配已经另外输出到 `E:\FL_MASSBALANCE\202308\downstream_multicaliber`。当前共有 `3` 个 bundle：`oldcode_0_245`、`batch_b_complete`、`main_complete`；每个 bundle 都同时提供 `fl_complete_passes_strict.csv` 和 `fl_running_records_local.csv`。 [已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\prepare_fl_multicaliber_downstream_inputs_summary.txt] [已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\bundle_index.csv]
- 三个下游 bundle 的当前轨道边界与规模分别为：`oldcode_0_245 = 0-245 m, passes=1816, records=1102774`；`batch_b_complete = 0-230 m, passes=1065, records=1714391`；`main_complete = 0-245 m, passes=2306, records=2795780`。 [已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\bundle_index.csv]

## 解释边界

- 这次旧编码处理的核心不是把不同旧编码数值强行还原成统一原始位置码，而是把几种旧口径都当作“同一个实际零点”的不同编码写法，再按当前主口径只保留相对零点 `0-245 m` 的去程或返程单程。 [来源: 用户当前对话 2026-07-08] [已核验: E:\FL_MASSBALANCE\202308\fl_batchc_local0_245_from_monotonic_segments_summary.txt]
- 多口径合并的当前边界是：旧编码数据按本地零点裁到 `0-245 m`，`B` 批次保留 `0-230 m` 完整单程，主口径保留 `0-245 m` 完整单程；因此 merged 表的作用是并存不同来源口径，不是把三者重新压成一个统一轨道长度的单一 pass 口径。 [来源: 用户当前对话 2026-07-08] [已核验: E:\FL_MASSBALANCE\202308\fl_multicaliber_merged_records_source_summary.csv]
- `downstream_multicaliber` 的三个 bundle 更适合作为下游脚本的输入适配层，而不是回写或覆盖上游 `E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_strict.csv` 的正式交付。 [推断：基于 bundle 目录结构、bundle index 和 merged summary 的职责划分整理]
