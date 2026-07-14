# Anchor Digest

## 路径与数据入口

- project memory 的唯一规范写入根目录是 `D:\00 博士阶段\99 Project\06 EA\project_memory`；旧 C 盘路径是 Junction 别名，不得通过该别名写入、删除或汇报。 [已核验: runtime/00_project_memory_root_guard.md]
- 当前批量数据统一以 `E:\Dataset_Level0` 为 Level0 主入口，以 `E:\Dataset_Level0\数据存入-处理记录.xlsx` 为覆盖登记表；`E:\Dataset_RAW` 只作为原始数据与 provenance 追溯入口。 [已核验: anchors/01_anchor_facts.md] [已核验: anchors/03_active_decisions.md]

## 站点与时间硬约束

- 当前科学解释固定使用 `MT=谷缘高地`、`CVT=谷底`、`FL=沿横谷切面移动平台`；旧目录中的小写站点名不能直接替代当前站点定义。 [已核验: anchors/01_anchor_facts.md]
- 本地时间字段必须优先按字符读取，再显式按 `Asia/Shanghai` 解析；不得让读取函数自动推断为 UTC/POSIX 时间而产生 `8 h` 错位。 [已核验: anchors/02_key_constraints.md] [已核验: anchors/06_time_parsing_constraints.md]

## 当前生效的方法口径

- 固定塔 rotation 与 W3 年度重算默认使用 `*_standardized_30min.csv`；公共矩阵固定为 `no_rotation / dr / global_pf / sector_pf`，`season_sector_pf` 只作最初敏感性分析，除非专门指定，否则不进入后续坐标旋转对比结果计算。 [已核验: anchors/03_active_decisions.md]
- W3 主分析年固定为 `2025`，结果只能称为 `EC-only annual NEE estimate / proxy`；在 storage、advection 和复杂地形代表性未并入前，不得写成最终碳收支或 `NECB`。 [已核验: anchors/03_active_decisions.md] [已核验: workstreams/W3_fixed_tower_annual_nee_estimation.md]
- FL 高频通量的 PF 参数口径固定为 `PF_8bin`；质量守恒分支使用 `PF_8bin_2ensemble`，两者不得自动互相替代。 [已核验: anchors/03_active_decisions.md]
- FL 完整单程覆盖阶段只确认几何完整和 EC key-complete 数据量，不提前执行风速、诊断码或标量物理范围 QC。 [已核验: anchors/02_key_constraints.md] [已核验: anchors/03_active_decisions.md]
- 本项目科研绘图优先调用本机 `nature-figure` skill；R 图件沿用该 skill 的 R 后端，同时不得覆盖项目既有配色、时间解析和科学解释边界。 [已核验: anchors/03_active_decisions.md]

## 解释边界

- 未旋转 raw `w` 与 raw-w 总输送不能直接解释为严格地形法向风或生态系统 CO2 交换；经验倾斜修正仍暂停作为主线依据。 [已核验: anchors/02_key_constraints.md] [已核验: anchors/03_active_decisions.md]
- FL 的默认角色是提供单塔看不到的空间结构、平流、通风和局地再分配约束，不是第三个固定平均通量站。 [已核验: anchors/03_active_decisions.md]
- W2 的 `peak_by_diff = amp_ppm > 0` 是基础事件入口，`5 ppm` 与 `10 ppm` 仅作强度分层；单塔频率、双塔机制分类和单塔缺测说明必须使用三个独立集合。 [已核验: anchors/03_active_decisions.md]
- AP 廓线的柱异常和变化率只能称为 proxy，不能直接写成正式 `storage flux` 或用于 `F_EC + F_storage` 闭合。 [已核验: anchors/02_key_constraints.md]

## 冲突与详细锚点

- 不能静默消解的站点命名、raw-w 物理解释和旧路径风险继续以 `anchors/04_conflicts_to_keep.md` 为准。 [已核验: anchors/04_conflicts_to_keep.md]
- 完整事实、约束和决策仍保存在 `anchors/01_anchor_facts.md`、`anchors/02_key_constraints.md`、`anchors/03_active_decisions.md`、`anchors/05_window_level_raw_w_diagnostic_definitions.md` 与 `anchors/06_time_parsing_constraints.md`；本文件只是默认读取摘要，不替代原文。
