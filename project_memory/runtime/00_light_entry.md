# Project Memory Light Entry

## 当前一句话状态

项目目前并行维护三条工作线：`W1` 已推进到 FL 全量 `EC_ecpreproc`、BPF 与固定塔跨站诊断；`W2` 已固定 2025 晨间 CO2 peak 的可复现事件定义；`W3` 已形成标准化四种 rotation 口径下的 2025 固定塔 `EC-only annual NEE estimate / proxy` 与覆盖敏感性诊断。 [已核验: workstreams/_index.md] [已核验: workstreams/2026-07-10_W1_FL_fixedtower_crosssite_diagnostics_addendum.md] [已核验: workstreams/W2_morning_peak_workflow.md] [已核验: workstreams/W3_fixed_tower_annual_nee_estimation.md]

## 当前重点

- `W1`：使用共同观测口径比较 `MT/CVT/FL` 的 raw `sigma_co2`，并以 `No rotation` 与 `PF` 两个固定分面比较三站 `w_mean`；其中 PF 口径为 `MT/CVT sector_pf + FL PF_8bin_2ensemble (BPF)`。 [已核验: runtime/2026-07-10_fl_fixedtower_crosssite_progress_update.md]
- `W2`：事件形态固定为日出后到 `pre_min_time` 整体下降、再到 `peak_time` 整体上升；下一步是人工复核 `amp > 5 ppm` 的站点日，而不是继续改事件定义。 [已核验: workstreams/W2_morning_peak_workflow.md]
- `W3`：默认公共比较矩阵为 `no_rotation / dr / global_pf / sector_pf`。2026-07-16 已完成 2025 硬 QC 共同窗口的 `u'c' / v'c' / w'c'` 条件投影来源分解并通过独立闭合检查；结果显示关键大投影通常以协方差偏大为主，但部分状态存在系数×协方差耦合。rotation 重算与既有基准仍有窗口级差异待核，全年结果仍只能表述为 `EC-only annual NEE estimate / proxy`，不能写成最终碳收支或 `NECB`。 [已核验: workstreams/W3_fixed_tower_annual_nee_estimation.md]

## 当前阻塞与解释边界

- W3 的 strict 口径共同 observed 覆盖较低，gapfilled-only 对塔间年差异贡献较高；关闭 `qc/flag9` 后共同覆盖明显提高，因此塔间差异不能简单归因于 gapfill，也不能忽略筛选口径。 [已核验: workstreams/W3_fixed_tower_annual_nee_estimation.md]
- FL 继续作为空间结构、平流和局地再分配的约束层，不应包装成第三个固定平均通量站。 [已核验: runtime/05_next_mainline_tasks.md]
- AP 廓线当前只能提供柱异常与变化率代理，不能直接称为正式 `storage flux` 或并入碳收支闭合。 [已核验: workstreams/W2_morning_peak_workflow.md]

## 下一最小步

- W1：直接从 2026-07-10 的跨站输出与对应 evidence 开始解释，不重读或重写 W1 全部历史。 [已核验: workstreams/2026-07-10_W1_FL_fixedtower_crosssite_diagnostics_addendum.md]
- W2：按固定事件口径人工复核 `amp > 5 ppm` 站点日，并保持单塔频率、双塔机制分类和单塔缺测集合分开。 [已核验: workstreams/W2_morning_peak_workflow.md]
- W3：逐条锁定 `preflight_top5_windows_2025.csv` 中实质偏差窗口所对应的旧成品原始文件、PF 参数/rotation-details 版本和后处理链；在此之前沿用当前重算产品内部闭合的条件投影结果，不扩展分析口径。 [已核验: workstreams/W3_fixed_tower_annual_nee_estimation.md]

## 导航

- 稳定约束：`anchors/00_anchor_digest.md`
- 工作流入口：`workstreams/_index.md`
- 详细当前快照：`runtime/01_current_snapshot.md`
- 开放问题：`runtime/02_open_questions.md`
- 历史动作：`runtime/03_recent_actions.md`，仅追溯时读取
- 来源索引：`evidence/00_thread_index.md`
