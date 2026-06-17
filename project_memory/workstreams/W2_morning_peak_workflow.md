# W2 晨间 CO2 peak 事件机制工作流

## 继承背景

本工作线继承 `regov_memory/00_shared_research_context.md` 中的研究区背景、站点定义、FL 几何、时间口径、方法边界、编码要求和长期解释风险。具体证据仍按本工作线自己的 `evidence/` 与对应项目 `project_memory` 追溯。 [已核验: regov_memory/00_shared_research_context.md]

## 目标

这条工作流的目标，是把晨间 CO2 peak 从 `W1` 的 EA/raw-w 与复杂地形通量修正支撑案例中独立出来，专门回答长期稳定晨间 CO2 事件的边界层转换、空间传播与局地再分配机制。 [来源: 用户当前对话 2026-06-17]

推断：它与长期碳收支主线并行，而不是替代长期碳收支主线。长期主线继续回答复杂地形下 EC、storage、平流、通风和方法不确定性如何影响碳收支解释；本工作流则把晨间 peak 当作稳定事件系统，优先发展事件气候学、机制判据和补充观测设计。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-06_regov_mainline_reset.md]

## 当前已确认的前期进展

- 已有四天典型窗口的全天 30 min 对齐表和 `04:00-12:00` 事件窗口表；此前事件窗口表共有 `202` 行，机制图件已经输出到 `EA_timeline_alignment\figures_mechanism`。 [已核验: project_memory/evidence/verifications/2026-05-24_current_calculated_results.md]
- 前期 8 个事件中，`pre-min` 稳定早于次高峰；按跨日出 `05:30-11:00` 判据重跑后，`profile switch` 也表现为 `8/8 before_peak`，其中 `MT 2025-03-21` 的切换时间为 `2025-03-21 06:00:00`。 [已核验: project_memory/evidence/verifications/2026-05-25_meteorology_focused_mechanism_visualization.md]
- 当前气象过程证据矩阵显示，`wind max` 为 `4 before / 4 after`，`raw w max` 为 `1 before / 3 near / 4 after`，`sigma_w max`、`u* max` 与 `H abs max` 更多出现在峰后或近峰；因此湍流和热力变量还不能写成稳定峰前先导因子。 [已核验: project_memory/evidence/verifications/2026-05-25_meteorology_focused_mechanism_visualization.md]
- 2026-05-26 的机制收束是：晨间次高峰不再优先按湍流主控解释，而应重点检查固定日出相对时段是否有随风向转变输入的高 CO2 气团，并区分峰后下降是本地吸收/垂直混合稀释，还是被后续风场平流带走。 [已核验: project_memory/evidence/verifications/2026-05-26_two_main_mechanism_directions.md]
- FL 目前应定位为空间结构约束，帮助区分整区同步、单侧输入、谷底增强、横谷再分配或通风带走，而不是第三个平均通量站。 [来源: 用户当前对话 2026-05-21] [已核验: project_memory/evidence/verifications/2026-06-03_fl_moving_transect_anomaly_transport_feasibility.md]

## 数据入口与可复用历史信息

- 当前 W2 批量整理的统一数据根入口为 `E:\Dataset_Level0`。后续固定塔自然年数据和 `20-30` 个三站独立事件日都应先从该根目录建立数据清单，再按自然年、站点、数据类型和事件日展开。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_level0_and_04lee_memory_query.md]
- 当前处理记录和覆盖登记表为 `E:\Dataset_Level0\数据存入-处理记录.xlsx`；`E:\Dataset_RAW` 是仪器直接输出数据入口。按该处理记录，`MT/CVT AP` 共同覆盖为 `2024-11-12 14:30` 至 `2026-02-02 09:30`，以及 `2026-02-02 10:00` 至 `2026-05-10 15:00`；这支持先用 AP 均值作为自然年晨间 peak 主 CO2 指标，再按 EC/MET 可用性补机制协变量。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]
- 按同一处理记录，`MT/CVT MET` 共同覆盖为 `2024-11-12 14:30` 至 `2025-12-28 23:59`，以及 `2026-02-22 00:00` 至 `2026-03-15 23:59`；同时具有两塔 `EC/AP/MET` 的完整共同窗口被分成多段，完整分段已写入固定塔覆盖核验证据记录。 [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]
- 用户后续确认，当前检测到的已经是全部数据；如果固定塔覆盖只有这些，就改为做一个自然年，部分断口来自仪器维修且无法避免。推断：第一版 W2 固定塔事件气候学应以 `2025` 自然年为主分析年，`2024-11` 至 `2024-12` 和 `2026-01` 至 `2026-05` 作为边界敏感性或补充材料，不再把两个完整自然年作为当前前置条件。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]
- Codex thread `019d4d7f-99f1-7201-87fb-409488ce10a4` 提供旧 E 盘目录级地图：主塔/Maintower 的历史入口主要是 `E:\老师拷贝大量数据（4-30）\MET_TOWER_RAW`、`EC_TOWER_RAW`、`EC_ShH_new\AP200_tower\AP200`；Flares/移动平台的历史入口主要是 `EC_FLARES_RAW`、`MET_FLARES_RAW` 和 `EC_ShH_new\AP200`；`Operation_state\20250313_20250419.xlsx` 可作为 FL 运行状态和事件日追溯线索。该信息只作为找数和 provenance 辅助，正式 W2 批量数据仍以 `E:\Dataset_Level0` 和当前 Level0 处理记录重建。 [已核验: project_memory/evidence/threads/2026-06-17_thread_019d4d7f_e_drive_data_organization.md] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]
- 旧线程中的小写 `mt/cvt/evt/nvt/svt` 是硬盘整理口径，不能直接替代当前 W2 的站点定义；后续所有固定塔自然年和三站事件日分析，必须优先使用当前 `MT=谷缘高地`、`CVT=谷底`、`FL=移动平台` 的站点定义，并用 Level0 子目录或 metadata 核对映射。 [已核验: project_memory/evidence/threads/2026-06-17_thread_019d4d7f_e_drive_data_organization.md]
- `D:\00 博士阶段\99 Project\research\projects\04_lee\project_memory` 中已有可复用的 W4 晨间次高峰信息。最直接可调用的是 `com_260507` 的多日数据组织方式、四天 `06:30` 短波日出 proxy、`06:30-09:00` 前期低值与 `09:00-11:00` 次高峰事件口径、AP `co2_mean` 与 `upper_co2` 峰值时序一致性，以及移动平台四天晨起窗口运行段结果。 [已核验: project_memory/evidence/verifications/2026-06-17_level0_and_04lee_memory_query.md]
- 当前已追溯到四天窗口短波日出 proxy 的具体字段和阈值：历史脚本读取 `CVT_MET` 的 `SW_in_Avg`，聚合为 `30 min` 的 `SW_in`，并以 `SW_in >= 20 W m^-2` 的首个窗口作为 `sunrise_ref_sw`。`SW_out_Avg` 和 `Rn_Avg` 也被读入和聚合，但不参与日出判定；四天 `2025-03-20` 至 `2025-03-23` 的输出均为 `06:30`。 [已核验: project_memory/evidence/verifications/2026-06-17_cvt_sw_in_sunrise_reference.md]
- 对当前 W2 而言，`04_lee` 的信息应作为方法先例和历史证据，不应直接替代当前固定塔自然年批量数据核查。自然年批量应用前仍需确认 `E:\Dataset_Level0` 中 `CVT_MET` 的 `SW_in_Avg` 字段、时间分辨率、缺测处理和异常短波值处理是否与旧脚本相容。 [已核验: project_memory/evidence/verifications/2026-06-17_cvt_sw_in_sunrise_reference.md] [推断：基于批量扩展边界整理]

## 分析层级

### 第一层：一个自然年双固定塔事件气候学

目标是回答晨间 peak 是否长期稳定存在、通常发生在日出相对时间的哪个阶段，以及它受季节、天气类型、风向扇区、夜间稳定度和日出后辐射增长条件的哪些控制。 [来源: 用户当前对话 2026-06-17]

当前执行口径改为用一个自然年推进，优先候选为 `2025` 年；维修断口按缺测窗口处理，不补插为连续观测，也不把断口当天误判为无 peak 日。核心指标仍包括发生率、峰值时间、幅度、持续时间、峰后下降率、有 peak 日与无 peak 日的气象匹配对照，以及两塔同步/固定领先/随风向改变的领先关系。此前“第一年建规则、第二年独立验证”保留为未来数据补齐后的理想设计，不作为当前第一版分析的阻塞条件。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-17_fixed_tower_level0_coverage.md]

### 第二层：20-30 个三站独立事件日机制分析

目标是判断 CO2 回升更像区域同步、水平传播，还是局地垂直再分配。每个事件日应计算三站 CO2 开始回升时间、peak 时间和幅度、站点间 lead-lag、表观传播速度与实际水平风速的关系、profile transition、风向变化和 CO2 回升的先后顺序，以及 peak 后 EC、湍流、风速和三站同步下降程度。 [来源: 用户当前对话 2026-06-17]

统计独立样本应是事件日，不是 `1 min` 或 `30 min` 数据点。`20-30` 个事件日更适合预定义机制判据、事件级回归和按事件 bootstrap；如果事件日几乎全部属于同一种天气，只能证明该天气状态下的机制，不应写成普遍分类。 [来源: 用户当前对话 2026-06-17]

### 第三层：谷中央上空固定观测

目标是补足两个地面固定塔无法区分的垂直过程，判断谷底浓度变化如何传递到谷地上空。推荐目标是 `12-15` 个有效固定观测早晨，理想状态为 `18-20` 个有效事件；考虑缺测、降雨、仪器异常和事件不完整，实际可安排 `16-20` 个固定观测早晨。 [来源: 用户当前对话 2026-06-17]

每次固定观测至少覆盖日出前约 `1 h` 到晨间 peak 后 `2-3 h`。若谷底先升、空中后升，较支持垂直再分配增强；若上风侧固定塔先升、空中和下风侧依次升高，较支持水平输入增强；若三站近同步，较支持区域尺度背景转换；若谷底与空中反相或具有稳定补偿关系，则局地环流成为候选机制。 [来源: 用户当前对话 2026-06-17]

### 第四层：移动切面

移动切面继续用于回答事件期间横谷空间结构是同步、单侧增强、谷底增强还是偶极结构。推断：这与既有 FL 定位一致，即 FL 主要提供平流、通风和局地环流的空间约束，而不是第三个平均通量站。 [来源: 用户当前对话 2026-06-17] [已核验: project_memory/evidence/verifications/2026-06-03_fl_moving_transect_anomaly_transport_feasibility.md]

## AP 廓线使用边界

- 廓线梯度指数可写为 `G_s(t) = C_low,s(t) - C_top,s(t)`，用于识别稳定层积累、廓线倒转和晨间混合。 [来源: 用户当前对话 2026-06-17]
- 柱浓度异常代理量可写为 `P_s(t) = sum_i dz_i [C_s,i(t) - C_s,i(t_ref)]`，其中 `t_ref` 可取日出前固定背景窗口；单位可保留为 `ppm m` 或标准化无量纲值。 [来源: 用户当前对话 2026-06-17]
- 柱异常变化率代理可写为 `T_s(t) = dP_s(t) / dt`，但只能称为 `column anomaly tendency proxy`、柱浓度异常变化代理或廓线库存变化指数。 [来源: 用户当前对话 2026-06-17]
- 不应把这些 AP 代理量称为正式 `storage flux`，也不应把它们直接加入 `F_EC + F_storage` 做碳收支闭合。跨站比较应优先比较 profile switch 时间、梯度符号、标准化变化幅度、变化速率，以及相对于 peak 的提前或滞后时间。 [来源: 用户当前对话 2026-06-17]

## 下一最小步

1. 先整理 `2025` 自然年双固定塔数据的可用性、维修断口标记和日出相对时间入口，并生成按日覆盖清单。 [来源: 用户当前对话 2026-06-17] [推断：基于本工作流目标和固定塔覆盖核验整理]
2. 在已有 8 个事件判据基础上，形成一版冻结前的自动事件识别草案，明确 peak、pre-min、duration、post-peak decline、profile switch 和无 peak 对照日的定义。 [已核验: project_memory/evidence/verifications/2026-05-25_meteorology_focused_mechanism_visualization.md] [推断：基于用户当前对话 2026-06-17 整理]
3. 对候选 `20-30` 个三站事件日先做气象状态分布核查，至少区分弱风晴空晨间转换、峰前风向转变或增风、较强通风且 peak 较弱或快速消散三类。 [来源: 用户当前对话 2026-06-17]
4. 把谷中央上空固定观测写成独立采样计划，优先争取 `12-15` 个有效事件，并保留 `8-10` 天移动切面用于横谷空间结构约束。 [来源: 用户当前对话 2026-06-17]

## 验证完成标准

本工作流的第一阶段完成标准不是新增更多图，而是在 `2025` 自然年内形成可复现的晨间 peak 识别规则、发生率、时序链和环境控制统计，并明确维修断口如何进入缺测处理；同时能用事件日级别的三站 lead-lag、profile transition 和 FL/固定上空观测判断 CO2 回升更接近区域同步、水平传播还是局地垂直再分配。 [来源: 用户当前对话 2026-06-17] [推断：基于本工作流四层分析结构整理]
