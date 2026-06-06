# REgov 项目记忆网络

## 总原则

REgov 现在把当前项目和 `04 Lee` 都视为长期科研项目网络的一部分，但保留各自独立的 `project_memory`。跨项目使用时，REgov 只维护索引、读取路径和联系规则，不把两个项目的事实合并成一个无来源的总叙事。 [来源: 用户当前对话 2026-05-27] [推断：基于 REgov 项目注册表]

## 项目节点

### Current

- 记忆路径：`D:\00 博士阶段\99 Project\06 EA\project_memory`。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory]
- 当前主线：`W1`，围绕复杂地形通量计量修正，重点组织 EC 适用条件、storage 修正、平流/通风/局地环流 residual 解释、FL 空间约束和状态分类；`09:00` 左右 CO2 次高峰归因现调整为复现与支撑分支。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory\runtime\01_current_snapshot.md]
- 默认轻量读取：`anchors/01_anchor_facts.md`、`anchors/02_key_constraints.md`、`anchors/03_active_decisions.md`、`runtime/01_current_snapshot.md`、`runtime/02_open_questions.md`、`runtime/03_recent_actions.md`。 [已核验: D:\00 博士阶段\99 Project\06 EA\project_memory]

### 04 Lee

- 记忆路径：`D:\00 博士阶段\99 Project\04 Lee\project_memory`。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory]
- 结构状态：该项目已有新分层目录 `anchors/`、`runtime/`、`workstreams/`、`evidence/`、`artifacts/`，同时保留旧 `00-08` 文件作为兼容层。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory]
- 当前主线：`W4 日变化垂直平流与环流归因` 最活跃，已进入次高峰现象固定、强弱对照和 REA 式条件分组诊断阶段。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\workstreams\_index.md] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\runtime\01_current_snapshot.md]
- 默认轻量读取：`anchors/01_anchor_facts.md`、`anchors/02_key_constraints.md`、`anchors/03_active_decisions.md`、`runtime/01_current_snapshot.md`、`runtime/02_open_questions.md`、`runtime/03_recent_actions.md`、`workstreams/_index.md`。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\runtime] [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\workstreams\_index.md]

## 04 Lee 读取边界

- 普通状态回答只读 `runtime/01_current_snapshot.md` 和 `workstreams/_index.md`，不要默认展开全部 evidence。 [推断：基于 project-progress-memory 轻量模式]
- 解释 `W4` 时，优先补读 `workstreams/W4_diurnal_vertical_advection_and_circulation.md`。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\workstreams\_index.md]
- 需要追溯早期判断、旧结构或旧行动记录时，才读取旧 `02_workstreams.md`、`04_open_questions.md`、`05_action_log.md` 或 `07_thread_index.md`。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory]
- 需要解释数据截断、近似回退、EC 时间口径或高频风对齐时，必须进入 `evidence/verifications/` 追证。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\runtime\02_open_questions.md]

## 跨项目调用规则

- 当当前项目涉及 09:00 左右 CO2 次高峰、日出后结构切换、raw `w`/垂直输送、FL/移动平台切面形态、三站风场、REA 式条件分组或 EC 时间口径时，可以把 `04 Lee` 作为历史背景读取。 [推断：基于当前项目与 `04 Lee` 的 workstream 主题重叠]
- 从 `04 Lee` 借来的内容只能作为历史背景、方法先例或机制候选提示；除非当前项目有直接证据，否则不能作为当前项目结论。 [推断：基于 REgov 证据边界]
- 如果两个项目给出相似现象但处理口径不同，优先保留差异，不要为了统一叙事抹平冲突。 [推断：基于 project-progress-memory 证据规则]

## 04 Lee 关键硬约束

- 两处观测的整体偏差仍然较大，后续不能把两处绝对浓度直接拿来做仪器可比解释。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\02_key_constraints.md]
- 后续凡是调用 EC 外部数据，都必须先与仪器内部粗算结果核对时相，并结合 `Quality flag` 剔除明显异常值。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\02_key_constraints.md]
- `diagnostic_30min_with_ec.csv` 中 EC 合并变量采用 start-label `time_30` 口径，后续比较事件时刻时必须明确 start-label 或 end-label。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\02_key_constraints.md]
- `CVT 2025-03-23` 黄昏阶段存在数据不完整约束，不能静默进入同步比较或 dusk summary。 [已核验: D:\00 博士阶段\99 Project\04 Lee\project_memory\anchors\02_key_constraints.md]
