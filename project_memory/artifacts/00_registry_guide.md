# 06EA 结构化台账说明

这套台账是现有项目记忆的轻量索引，不替代 `workstreams/`、`artifacts/01_registry.md` 或 `evidence/` 中的详细记录。它负责让研究路径、阶段交付和可复用脚本可以被查看、修改、筛选和相互关联。[来源: 用户当前对话 2026-07-14]

## 四个入口

- `runtime/research_paths/*.md`：每个文件是一张独立的“研究决策卡”，稳定 ID 不变。
- `runtime/06_research_paths.base`：原生 Obsidian Bases 看板，自动读取卡片 YAML 属性。
- `runtime/06_research_path_registry.md`：日常总入口，嵌入 P0、工作线、阻塞和交付视图。
- `runtime/visual/research_paths.canvas`：只显示路径依赖和导航，不保存新的科研判断。

交付和脚本仍使用两张聚合台账：

- `artifacts/02_deliverable_registry.md`：阶段数据、参数、图件、报告和正式交付目录。
- `artifacts/03_script_registry.md`：正式入口或已核验的高价值脚本。

它们通过 `path_id`、`artifact_id`、`script_id` 和 `[[内部链接]]` 连接。详细事实仍以工作线、核验记录和实际文件为准。

## 借鉴来源

- `rasilab/github_template`：使用稳定 ID 连接研究问题、分析、脚本和结果。
- `The Turing Way reproducible-project-template`：明确 `milestone`、`next_gate` 和 `next_deliverable`。
- `rOpenSci/targets`：显式记录输入、脚本、输出和依赖，为后续 W3 计算依赖图试点留接口。
- `Cookiecutter Data Science`：区分处理阶段和交付类型，但不迁移现有目录。

## 固定词表

- 路径 `status`：`scoped / data_ready / analysis_active / result_provisional / verified / deliverable_ready / paused`。
- 路径 `trend`：`advancing / stable / blocked / closing`。它表示最近走势，不表示科研价值高低。
- 交付 `delivery_level`：`working / validated / stage_delivery / paper_candidate / final`。
- 脚本 `reusability`：`one_off / workflow / parameterized / reusable / deprecated`。

## 更新规则

1. 新想法只有形成明确问题或下一判断门槛后，才新增研究路径卡。
2. 每张路径卡只保留一个当前 `next_action`。
3. 只有 `next_gate` 所需证据真实存在并可定位时，才推进 `status`。
4. 更新 YAML 属性时，同步更新正文决策卡；Bases 和 Canvas 不另写科研事实。
5. 普通临时图和中间文件不进入交付表；只有阶段主构件进入。
6. 脚本经过实际运行或 verification note 核验后，才能标为 `parameterized` 或 `reusable`。
7. 历史解释和来源冲突继续保留在 workstream 与 evidence 中。
8. 本轮只优化 `D:\00 博士阶段\99 Project\06 EA` 的实际应用，不修改通用 `project-progress-memory` skill。[来源: 用户当前对话 2026-07-14]

## Obsidian 编辑约定

- 不修改稳定 ID，例如 `W2-P01`。
- 在路径卡顶部属性面板修改状态、走势和下一动作；不要直接编辑 `.base` 来改科研内容。
- 项目内部来源优先使用 `[[双向链接]]`，外部磁盘位置保留为代码路径。
- YAML 中的 `last_verified` 只在实际重新核验后更新。
