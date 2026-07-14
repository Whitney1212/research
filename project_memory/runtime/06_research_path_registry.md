---
aliases:
  - 06EA 研究路径台账
type: dashboard
registry: research_paths
project: 06EA
updated: 2026-07-14
tags:
  - 06EA
  - registry/research-path
---

# 06EA 研究路径台账

> [!tip] 一句话用法
> 平时打开“当前 P0”，进入对应研究决策卡，只维护一个 `next_action`。当卡片写明的 `next_gate` 已有可核验的文件、数据或结论时，再更新 `status` 进入下一阶段。

## 当前 P0

![[06_research_paths.base#当前 P0]]

## 按工作线浏览

![[06_research_paths.base#按工作线浏览]]

## 有依赖或阻塞

![[06_research_paths.base#有依赖或阻塞]]

## 接近交付

![[06_research_paths.base#接近交付]]

## 路径关系

- [[visual/research_paths.canvas|打开研究路径关系图]]
- 关系图只用于导航和查看依赖；研究判断仍以各路径卡及其 evidence/workstream 来源为准。

## 阶段如何推进

> [!check] 只问三个问题
> 1. `next_gate` 要求的证据是否已经实际存在？
> 2. 是否能用文件、数据、图表或核验记录指出它在哪里？
> 3. 更新 `status` 后，是否同时写出了新的唯一 `next_action`？

如果三项都满足，更新卡片顶部 YAML 中的 `status`、`trend`、`current_result`、`next_gate`、`next_action`、`next_deliverable` 和 `last_verified`，并同步修改正文决策卡。否则保持当前阶段，不因“做了很多工作”而自动推进。

## 状态词

- `scoped`：问题与范围已明确。
- `data_ready`：正式分析所需数据和口径已具备。
- `analysis_active`：正在执行能够回答问题的分析。
- `result_provisional`：已有初步结果，仍需关键验证。
- `verified`：主要判断已有核验记录支持。
- `deliverable_ready`：已有明确可交付文件及使用边界。
- `paused`：主动暂停，需记录原因。

> [!info]- 编辑规则
> 每条研究路径位于 `runtime/research_paths/` 的独立 Markdown 中。YAML 属性是 Bases 的数据来源；正文研究决策卡是阅读入口。两处表达同一事实，修改时应一起更新。详细事实、历史解释和证据仍保留在 workstream 与 evidence 中。
