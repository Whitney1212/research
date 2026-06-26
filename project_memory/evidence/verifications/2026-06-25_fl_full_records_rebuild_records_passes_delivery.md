# 2026-06-25 FL 全量运行记录与完整单程覆盖重建

## 本次运行

- 本次按固定输出结构对 `E:\Dataset_RAW\Flares\运行记录` 做全量运行记录标准化，输出统一运行记录基础文件 `E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv`，对应来源摘要为 `fl_records_230417_260622_source_summary.csv`。统一运行记录覆盖 `2023-04-17` 至 `2026-06-22`，输出 `6,706,308` 行。 [已核验: E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622.csv] [已核验: E:\Dataset_Level0\Flares\running_time\records\fl_records_230417_260622_source_summary.csv]
- 本次从 `E:\Dataset_Level0\Flares\EC` 生成 EC 文件索引，并用 `E:\FL_pre\scripts\fl_full_records_02_complete_passes_and_ec_availability.R` 执行几何完整单程筛选和 key-complete EC 可用性筛选。结果输出到 `E:\Dataset_Level0\Flares\running_time\passes`，严格完整且 EC key-complete 可用单程为 `1868` 个。 [已核验: E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_incremental_manifest.txt]
- 覆盖图由 `E:\FL_pre\scripts\fl_full_records_03_plot_complete_pass_coverage.R` 重绘，输入 `fl_complete_passes_strict.csv` 共 `1868` 行，绘图 segment 为 `1873` 段，日期范围为 `2023-06-22` 至 `2026-06-04`。 [已核验: E:\Dataset_Level0\Flares\running_time\passes\fl_complete_pass_coverage_timeline.png]

## 固定交付结构

- `records` 目录保留下一次增量需要的运行记录基础文件：`fl_records_230417_260622.csv` 和 `fl_records_230417_260622_source_summary.csv`。 [已核验: E:\Dataset_Level0\Flares\running_time\records]
- `passes` 目录保留三件正式交付：`fl_complete_pass_coverage_daily.csv`、`fl_complete_pass_coverage_timeline.png`、`fl_complete_passes_incremental_manifest.txt`；同时保留下次增量必须的 `fl_complete_passes_strict.csv` 和 `fl_complete_pass_candidates_all.csv`。 [已核验: E:\Dataset_Level0\Flares\running_time\passes]
- `passes` 中的 `ec_raw_files_full_index.csv` 是本次全量筛选实际使用的 EC 文件索引，可作为后续增量运行的可选加速输入；它不是正式科学结果表。 [已核验: E:\Dataset_Level0\Flares\running_time\passes\ec_raw_files_full_index.csv]
- `E:\Dataset_Level0\Flares\running_time` 根目录已收敛为只包含 `records` 和 `passes` 两个子目录，旧根目录三件交付已删除，避免后续混用旧位置。 [已核验: E:\Dataset_Level0\Flares\running_time]

## 代码变更

- `E:\FL_pre\scripts\fl_full_records_01_running_records_prepare.R` 和 `fl_update_records_01_running_records_incremental.R` 已改为默认向 `records` 输出按实际覆盖日期命名的 `fl_records_yymmdd_yymmdd*.csv`。 [已核验: E:\FL_pre\scripts\fl_full_records_01_running_records_prepare.R] [已核验: E:\FL_pre\scripts\fl_update_records_01_running_records_incremental.R]
- `E:\FL_pre\scripts\fl_full_records_02_complete_passes_and_ec_availability.R`、`fl_update_records_02_complete_passes_and_ec_availability.R` 和 `fl_full_records_03_plot_complete_pass_coverage.R` 已改为默认使用 `passes` 作为完整单程覆盖输出位置，并保留 key-complete EC 可用性筛选口径。 [已核验: E:\FL_pre\scripts\fl_full_records_02_complete_passes_and_ec_availability.R] [已核验: E:\FL_pre\scripts\fl_update_records_02_complete_passes_and_ec_availability.R] [已核验: E:\FL_pre\scripts\fl_full_records_03_plot_complete_pass_coverage.R]
