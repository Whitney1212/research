# Project Memory Read Manifest

## 默认读取

普通进展、阻塞和下一步问题只读：

- `runtime/00_light_entry.md`

## 按需补读

- 需要项目级稳定约束时，补读 `anchors/00_anchor_digest.md`。
- 点名工作线时，只补读 `workstreams/_index.md` 和对应工作流文件。
- 需要具体当前结果时，补读 `runtime/01_current_snapshot.md`、`runtime/02_open_questions.md` 或 `runtime/05_next_mainline_tasks.md`。
- 需要追证时，先读 `evidence/00_thread_index.md`，再读命中的 evidence note。
- 需要构件位置时，按关键词查询 `artifacts/01_registry.md`，不默认整文件读取。

## 不默认读取

- `evidence/threads/`、`evidence/discussions/`、`evidence/verifications/`
- `runtime/03_recent_actions.md`
- `runtime/visual/`
- 各工作流中的历史长段落

## 写入边界

- 所有写入使用 `D:\00 博士阶段\99 Project\06 EA\project_memory`，不得通过旧 C 盘 Junction 别名操作。
- evidence 保留原文和 provenance；整理时不通过删除 evidence 去重。
- runtime 只维护当前视图，历史动作留在 `runtime/03_recent_actions.md` 或 evidence。
- anchors 只保存遗忘后会导致方法、路径或解释出错的稳定约束。

