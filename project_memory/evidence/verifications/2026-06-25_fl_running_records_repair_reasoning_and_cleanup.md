# 2026-06-25 FL 运行记录匹配修复推理与过程数据清理

## 目标

确认此前 FL 运行记录匹配、完整单程筛选、EC 可用性筛选与增量交付的代码和输出来源，将修复推理过程固化到 project memory；随后清理旧的过程目录，只保留原始输入、当前正式交付和整理后的可复用代码。

## 核对来源

- Codex thread `codex://threads/019ecbff-9be2-74f2-80b5-9ff7b61c1ef7`：记录了 `2025-08-17` 至 `2025-10-01` 运行记录的 0-230 m 特例增量修复。本段新增严格完整且 EC 可用单程 `1065` 个，合并后严格完整单程为 `2632` 个。
- `E:\Dataset_RAW\Flares\运行记录\unified_output`：旧的统一运行记录与严格单程过程目录，包含历史 `fl_running_records_unified.csv`、候选/严格单程中间表、脚本和测试输出。
- `E:\Dataset_Level0\Flares\260611_clasified`：旧的全量完整单程与分类过程目录。其中 `30min\fl_complete_passes_strict.csv` 曾作为 PF_8bin 与质量守恒全量计算输入，历史口径为 `1529` 个严格完整单程。
- `E:\Dataset_Level0\Flares\running_time\20260626`：2025 年 8-9 月修复的诊断、测试、批次和增量过程目录，包含 0-230 m 特例的过程输出。
- `E:\Dataset_Level0\Flares\running_time`：当前正式交付目录。按用户要求，根目录仅保留 `fl_complete_pass_coverage_daily.csv`、`fl_complete_pass_coverage_timeline.png`、`fl_complete_passes_incremental_manifest.txt` 三件交付。
- `E:\FL_pre\scripts`：当前整理后的 FL 运行记录代码目录，分为 `fl_full_records_*` 全量流程和 `fl_update_records_*` 增量流程。

## 修复推理链

1. 早期全量口径先由旧统一运行记录和 `260611_clasified\30min\fl_complete_passes_strict.csv` 建立，形成 `1529` 个严格完整单程。该表被后续 PF_8bin 参数、PF_8bin_2ensemble 质量守恒等历史计算引用，因此需要在 memory 中保留来源和数量，但不要求继续保留旧过程目录。
2. `2025-08-17` 至 `2025-10-01` 运行记录存在特殊轨道端点问题：实际最大位置约到 `230 m`，若套用默认 `5-240 m` 规则无法触发北端完整单程。因此该时段按 `0-230 m` 特例重筛；新增 `1065` 个严格完整且 EC 可用单程，合并后为 `2632` 个。该特例不得自动推广到全部 FL 数据，也不得直接替代 PF_8bin 默认 `5-240 m` 口径。
3. `2026-03-01` 至 `2026-03-31` 增量按默认 `5-240 m` 单程规则处理，并采用新的 EC 可用性筛选口径：先定位候选单程覆盖时段内 EC 数据，再只检查关键变量完整性。本段保留 `203` 个严格完整且 EC 可用单程。
4. `2023` 前期测试文件 `E:\Dataset_RAW\Flares\运行记录\20230315_20231226.csv` 使用 `MCGS_TIME + 位置反馈` 两列格式，位置反馈列即小车位置；速度按固定绝对值 `13.7 cm/s`，方向符号由相邻位置变化推断。该文件有效解析记录从 `2023-04-17 12:00:57` 开始，并带有前期约 `3 s` 一个点的测试期特征。该频率只作备注，不作为后续常规采样假设。
5. 当前固定的 EC 可用性筛选只用于判断“候选单程内是否有可用于后续 EC 计算的数据量”，不提前做风速范围、诊断码和标量物理范围 QC。固定规则为：时间落在候选单程内；关键变量列 `Ux/Uy/Uz/CO2/TA_1_1_1/PA` 存在；六列均为有限值；至少一个时钟分钟关键变量完整行数达到 `>=300`。
6. 为减少停止运行时段造成的索引膨胀，运行记录标准化脚本加入长静止段压缩：同一位置连续 `>=15 min` 且 `>=300` 点时，只保留首尾点。这里 `15 min` 是主判断，`300` 点是辅助阈值。

## 当前正式代码

- `E:\FL_pre\scripts\fl_full_records_01_running_records_prepare.R`：全量运行记录整理，统一为 `time/speed/position`，并压缩长静止段。
- `E:\FL_pre\scripts\fl_full_records_02_complete_passes_and_ec_availability.R`：全量完整单程筛选与 key-complete EC 可用性筛选。
- `E:\FL_pre\scripts\fl_full_records_03_plot_complete_pass_coverage.R`：全量覆盖图绘制。
- `E:\FL_pre\scripts\fl_update_records_01_running_records_incremental.R`：增量运行记录整理与合并。
- `E:\FL_pre\scripts\fl_update_records_02_complete_passes_and_ec_availability.R`：增量完整单程替换合并与 EC 可用性筛选。
- `E:\FL_pre\scripts\fl_update_records_03_plot_complete_pass_coverage.R`：增量后覆盖图重绘。
- `E:\FL_pre\scripts\README_FL_records_pipeline.md`：流程说明、默认口径和 2025 年 8-9 月特例备注。

## 当前正式交付

目录：`E:\Dataset_Level0\Flares\running_time`

- `fl_complete_pass_coverage_daily.csv`
- `fl_complete_pass_coverage_timeline.png`
- `fl_complete_passes_incremental_manifest.txt`

当前 manifest 记录：合并后严格完整且 EC 可用单程 `2873` 个，方向 `fw=1450, bw=1423`，覆盖日表 `126` 行，日期范围 `2023-06-22` 至 `2026-06-04`；其中 `2023` 增量 `38` 个，`2026-03` 增量 `203` 个，并保留此前 `2025` 年 8-9 月特例修复结果。

## 清理边界

保留：

- 原始运行记录源文件，例如 `E:\Dataset_RAW\Flares\运行记录\*.csv`。
- 当前正式交付三件文件：`E:\Dataset_Level0\Flares\running_time\fl_complete_pass_coverage_daily.csv`、`fl_complete_pass_coverage_timeline.png`、`fl_complete_passes_incremental_manifest.txt`。
- 当前整理后的代码：`E:\FL_pre\scripts`。
- project memory 中的历史依据记录。

删除：

- `E:\Dataset_RAW\Flares\运行记录\unified_output`
- `E:\Dataset_Level0\Flares\260611_clasified`
- `E:\Dataset_Level0\Flares\running_time\20260626`

## 清理状态

已删除并复核：

- `E:\Dataset_RAW\Flares\运行记录\unified_output`：删除后 `Test-Path = False`。
- `E:\Dataset_Level0\Flares\260611_clasified`：删除后 `Test-Path = False`。
- `E:\Dataset_Level0\Flares\running_time\20260626`：删除后 `Test-Path = False`。

保留复核：

- `E:\Dataset_Level0\Flares\running_time` 根目录仅剩三件正式交付：`fl_complete_pass_coverage_daily.csv`、`fl_complete_pass_coverage_timeline.png`、`fl_complete_passes_incremental_manifest.txt`。
- `E:\FL_pre\scripts` 保留 6 个流程脚本和 `README_FL_records_pipeline.md`。
