---
type: research_path
path_id: W1-P02
title: FL 全量 BPF 与 EC 产品
workstream: W1
parent_path: fl_flux_processing
status: deliverable_ready
trend: closing
evidence_level: high
data_readiness: high
priority: P0
milestone: "FL 全量 BPF 与 EC_ecpreproc 正式交付"
research_question: "FL 经 BPF 和多旋转处理后能否形成与固定塔可比较的正式 30 min EC 产品？"
current_result: "FL BPF 默认参数已于 2026-07-21 切换为 0–245 m 固定 8-bin PF8 two-pass ensemble 版本；旧参数已保留备份，8/8 数值核验通过。"
next_gate: "所有新 FL 下游计算显式记录并读取 2026-07-21 标准 BPF 参数版本。"
next_action: "下一次 FL EC 或质量守恒运行前，在其 manifest 中写入新的 BPF 默认参数 SHA256。"
next_deliverable: "A-W1-002"
blocked_by: ""
last_verified: 2026-07-09
tags:
  - 06EA
  - research-path/W1
---

# W1-P02 FL 全量 BPF 与 EC 产品

> [!success] 研究决策卡 · P0 · 接近收束
> **研究问题**：FL 经 BPF 和多旋转处理后能否形成与固定塔可比较的正式 30 min EC 产品？
>
> **已有判断**：BPF 默认参数已切换为 0–245 m 固定 8-bin PF8 two-pass ensemble；旧默认参数已备份，八个 bin 的数值核验均通过。
>
> **进入下一阶段的门槛**：所有新 FL 下游计算显式记录并读取 2026-07-21 标准 BPF 参数版本。
>
> **现在只做**：下一次 FL EC 或质量守恒运行前，在其 manifest 中写入新的 BPF 默认参数 SHA256。
>
> **下一交付**：[[../../artifacts/02_deliverable_registry#A-W1-002 FL 全量 EC_ecpreproc 多旋转正式交付|A-W1-002]]

> [!info]- 路径来源
> 工作线：[[../../workstreams/W1_EA_EC_flux|W1 EC/FL 与通量修正]]  
> 核验：[[../../evidence/verifications/2026-07-21_fl_bpf_0_245_fixed8_rebuild]]  
> 最后核验：2026-07-21
