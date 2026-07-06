# 2026-07-06 FL 202308 放宽口径完整单程覆盖叠加图

## 来源

- 用户当前对话，时间范围为 2026-07-05 至 2026-07-06。[来源: 用户当前对话 2026-07-05 至 2026-07-06]

## 已核验事实

- 已将正式 strict 完整单程表 `E:\Dataset_Level0\Flares\running_time\passes\fl_complete_passes_strict.csv` 与放宽口径几何完整单程表 `E:\FL_MASSBALANCE\202308\fl_complete_passes_geometry_relaxed_track15_255_20230315_20231226.csv` 按 exact key 合并，输出为 `E:\FL_MASSBALANCE\202308\fl_complete_passes_coverage_merged_with_relaxed_track15_255.csv`。[已核验: E:\FL_MASSBALANCE\202308\fl_complete_passes_coverage_merged_with_relaxed_track15_255.csv]
- 合并摘要显示：original strict rows=`2933`，relaxed geometry rows=`1823`，added after exact-key dedupe=`1823`，merged total=`4756`。[已核验: E:\FL_MASSBALANCE\202308\fl_complete_passes_coverage_merged_with_relaxed_track15_255_summary.txt]
- 合并摘要同时显示：original strict dates=`126`，relaxed geometry dates=`75`，newly introduced dates=`53`；其中新增日期样例包含 `2023-08-25`、`2023-09-13`、`2023-09-27` 至 `2023-09-30`。[已核验: E:\FL_MASSBALANCE\202308\fl_complete_passes_coverage_merged_with_relaxed_track15_255_summary.txt]
- 放宽口径 geometry-complete 导出摘要显示：源运行记录文件为 `E:\Dataset_RAW\Flares\运行记录\20230315_20231226.csv`，统一记录文件为 `E:\FL_MASSBALANCE\202308\fl_records_20230315_20231226.csv`，候选行数=`1896`，导出 geometry-complete 行数=`1823`，日期范围为 `2023-04-17` 至 `2023-12-08`。[已核验: E:\FL_MASSBALANCE\202308\fl_complete_passes_geometry_relaxed_track15_255_20230315_20231226_summary.txt]
- 同一摘要对关键日期计数为：`2023-08-25=21`，`2023-09-13=48`，`2023-09-27=48`，`2023-09-28=48`，`2023-09-29=48`，`2023-09-30=48`。[已核验: E:\FL_MASSBALANCE\202308\fl_complete_passes_geometry_relaxed_track15_255_20230315_20231226_summary.txt]
- 已复用脚本 `E:\FL_pre\scripts\fl_full_records_03_plot_complete_pass_coverage.R` 生成新的 coverage 图 `E:\FL_MASSBALANCE\202308\FL_complete_pass_coverage_timeline_with_relaxed_track15_255.png`；脚本运行输出显示 input rows=`4756`、plotted segments=`4806`、date range=`2023-04-17 -> 2026-06-04`。[已核验: E:\FL_MASSBALANCE\202308\FL_complete_pass_coverage_timeline_with_relaxed_track15_255.png]

## 解释边界

- 这次新增进入 coverage 叠加图的 `1823` 条记录只满足 `geometry_complete == TRUE` 和放宽轨道范围 `15-255 m`，不等同于 strict pass，也不等同于 EC-valid 或质量守恒主结果样本。[推断: 基于 strict coverage 表、relaxed geometry coverage 表及其摘要文件的口径差异]
- 因此这张新图适合回答“运行记录里这些时段是否被几何覆盖识别到”以及“原 coverage 图遗漏了哪些可见运行时段”，不应用来替代 `2933` strict 单程、`2868` 可计算单程或 `2789` mixed-sign 质量平衡主结果口径。[推断: 基于当前对 strict 主结果与 relaxed geometry coverage 结果的分层用途整理]
