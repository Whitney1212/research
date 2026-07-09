# 2026-07-08 FL 全量 EC_ecpreproc 与 multicaliber BPF 重训方案确认

## 来源

- 本记录整理自用户在当前对话中对 `FL` 全量 EC 计算入口、输出位置、全量范围和重新训练 `BPF`/`FL` 适用参数的连续要求，并在本轮直接核验相关脚本、bundle 输入和输出目录。[来源: 用户当前对话 2026-07-08]

## 已核验事实

- 用户已将后续 `FL` 全量 EC 数据计算根目录指定为 `E:\Dataset_Level1\Flares\EC_ecpreproc`。当前该目录已经存在，但仍为空目录，说明可以作为新的正式输出根目录，不会覆盖既有产品。[来源: 用户当前对话 2026-07-08] [已核验: E:\Dataset_Level1\Flares\EC_ecpreproc]
- 用户本轮定义的 `FL` “全量”不是整库所有日期无差别重跑，而是“只跑有 pass 覆盖的时段和日期”，并且保留所有已检测到的 pass 来源与轨道口径差异，后续再按时间与固定塔对齐。[来源: 用户当前对话 2026-07-08]
- 当前可直接用于构建 multicaliber 训练输入的 bundle 已固定为三组：`oldcode_0_245`、`batch_b_complete` 和 `main_complete`。三组 bundle 当前规模分别为 `passes=1816, records=1102774, track=0-245 m`，`passes=1065, records=1714391, track=0-230 m`，`passes=2306, records=2795780, track=0-245 m`。[已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\bundle_index.csv]
- 三组 bundle 的 `fl_complete_passes_strict.csv` 都已经具备当前 `run_PF_8bin.R` 所需的核心字段：`pass_id/start_time_local/end_time_local/direction/position_start/position_end/reject_reason`，并额外保留了 `source_group/nominal_track_rule/local_track_phase` 等来源标签。[已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\oldcode_0_245\fl_complete_passes_strict.csv] [已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\batch_b_complete\fl_complete_passes_strict.csv] [已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\main_complete\fl_complete_passes_strict.csv]
- `batch_b_complete` 和 `main_complete` 的 `fl_running_records_local.csv` 已满足当前 PF 脚本实际读取的 `time/speed/position` 结构；`oldcode_0_245` 同样使用这套列名，但文件内至少有 `16` 行以空 `time` 开头，因此不能在不修补的情况下直接作为正式重训输入。[已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\batch_b_complete\fl_running_records_local.csv] [已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\main_complete\fl_running_records_local.csv] [已核验: E:\FL_MASSBALANCE\202308\downstream_multicaliber\oldcode_0_245\fl_running_records_local.csv]
- 当前正式 `PF_8bin` 脚本和 `PF_8bin_2ensemble` 脚本都已经存在，路径分别为 `E:\Dataset_Level1\Flares\PFparameter\run_PF_8bin.R` 和 `E:\Dataset_Level1\Flares\PFparameter\run_PF_8bin_2ensemble.R`；仓库内另有 `D:\00 博士阶段\99 Project\06 EA\scripts\build_expanded_pf_training.R`，它已经实现了“重定义输入后复用正式 PF 脚本”的包装思路。[已核验: E:\Dataset_Level1\Flares\PFparameter\run_PF_8bin.R] [已核验: E:\Dataset_Level1\Flares\PFparameter\run_PF_8bin_2ensemble.R] [已核验: D:\00 博士阶段\99 Project\06 EA\scripts\build_expanded_pf_training.R]
- 但当前正式 `PF_8bin` manifest 仍绑定旧单一口径：旧 strict pass、旧 unified running record 和固定 `5-240 m` 轨道；它还没有切换到当前 `downstream_multicaliber` 三 bundle 输入，因此不能直接原样重跑并声称已经采用最新统一口径。[已核验: E:\Dataset_Level1\Flares\PFparameter\manifest.txt]
- 当前四天 `FL` after-PF EC 脚本已经固定了后续全量 EC 更应沿用的窗口 QC 口径：`valid_samples_by_bin`，即窗口至少 `120 s` 有效样本、每个参与 bin 至少 `10 s` 有效样本、至少 `1` 个有效 bin；`coverage_frac` 只保留为诊断量，不再作为硬阈值。[已核验: D:\00 博士阶段\博一\05 Project\com_FLafterPF\scripts\run_fl_pf8bin_ec_covariance_20250320_0323.R]
- 全量高频原始数据根目录和 FL metadata 已齐全，分别为 `E:\Dataset_Level0\Flares\EC` 和 `D:\00 博士阶段\博一\05 Project\com_260507\sh20240701.metadata`。这两类输入已经足够支撑后续 `FL` 全量 EC runner 和参数重训脚本改造。[已核验: E:\Dataset_Level0\Flares\EC] [已核验: D:\00 博士阶段\博一\05 Project\com_260507\sh20240701.metadata]

## 方案决定

- 本轮将用户口头所说的 `BPF` 解释为当前仓库中实际对应的 `bin-wise planar fit / PF_8bin` 这一类 `FL` 专用位置分箱平面拟合参数，而不是仓库里另一套独立命名的方法。后续若需要写脚本或 manifest，应把这个映射显式写清，避免把 `BPF`、`PF_8bin` 和 `PF_8bin_2ensemble` 混成同义词。[来源: 用户当前对话 2026-07-08] [推断：基于当前代码命名和用户口头术语整理]
- `FL` 全量 EC runner 的正式脚本和输出目录统一落到 `E:\Dataset_Level1\Flares\EC_ecpreproc`。该 runner 只处理有 pass 覆盖的日期和时段，并在文件内只保留落在 pass 窗口内的 10 Hz 点，再按固定塔一致的 `Asia/Shanghai + 30 min` 窗口出表。[来源: 用户当前对话 2026-07-08] [推断：基于固定塔全量脚本和 FL 四天脚本的共同处理边界整理]
- 参数重训不覆盖当前正式 `PFparameter` 与 `PFparameter_2ensemble`，而是先写到新的并行目录：`E:\Dataset_Level1\Flares\PFparameter_multicaliber` 和 `E:\Dataset_Level1\Flares\PFparameter_multicaliber_2ensemble`。这样可以保留旧正式参数作为 provenance，并避免在方案尚未执行和核验前污染现有正式产品。[推断：基于当前正式参数仍服务历史产品、且本轮只定方案不执行的边界整理]
- 参数重训前应先构造一套新的 canonical multicaliber PF 输入包，而不是直接把 `fl_multicaliber_merged_records_segment_summary.csv` 当作 PF 输入。原因是 `run_PF_8bin.R` 需要的是 pass 表和逐点运行记录，而不是单纯 segment 汇总表。[已核验: E:\FL_MASSBALANCE\202308\fl_multicaliber_merged_records_segment_summary.csv] [已核验: E:\Dataset_Level1\Flares\PFparameter\run_PF_8bin.R]
- 这套 canonical 输入包的最小结构应为两张表：一张统一的 `passes_csv`，一张统一的 `running_records_csv`。`passes_csv` 来自三组 bundle 的 `fl_complete_passes_strict.csv` 直合并并保留 `source_group/nominal_track_rule`；`running_records_csv` 来自三组 bundle 的 `fl_running_records_local.csv` 逐点合并，但 `oldcode_0_245` 必须先修补空时间行，不能直接拼接进正式训练集。[推断：基于当前 PF 脚本输入格式、bundle 字段和 oldcode 局部脏数据整理]
- `oldcode_0_245` 的空时间行修补应优先回到 `E:\FL_MASSBALANCE\202308\fl_multicaliber_merged_records.csv` 或其更上游的 oldcode 对齐产物中重建，再写回新的 canonical running-record 输入；不建议在 bundle local records 上手工猜时间或直接删除这些行后静默重训。[已核验: E:\FL_MASSBALANCE\202308\fl_multicaliber_merged_records.csv] [推断：基于空时间行会破坏逐点插值而直接删行会改变训练覆盖整理]
- 全量 `FL` EC 结果的旋转主口径应在新参数固定后统一使用 multicaliber 重训得到的 `BPF/PF_8bin`；`no rotation` 和 `dr` 可以作为并行敏感性产品复用同一个 `FL` EC runner，只切换 `w` 的生成方式，不再各自维护独立的时间窗、QC 或输出结构。[推断：基于固定塔现有多旋转产品结构和 FL 四天脚本可复用逻辑整理]

## 仍待执行的最小前置项

- 需要新增一个 multicaliber PF 输入适配脚本，把三组 bundle 组装成新的 canonical `passes_csv + running_records_csv`，并专门修补 `oldcode_0_245` 的空 `time` 行。
- 需要新增一个 `FL` 全量 EC runner，复用四天 `FL after-PF` 脚本里的时间解析、逐点位置/速度修正和 `valid_samples_by_bin` QC，但把日期范围从四天推广为“所有 pass 覆盖日期”。
- 本记录只确认方案和前置内容已基本齐全，尚未执行重训，也尚未执行 `FL` 全量 EC 计算。[来源: 用户当前对话 2026-07-08]
