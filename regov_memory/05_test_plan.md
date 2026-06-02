# REgov 测试计划

## 测试目标

REgov 的测试重点不是看它能不能“回答得长”，而是看它是否能稳定做到：按层读取项目记忆、保留 provenance、正确调用相关技能、生成 workstream 可视化，并在机制讨论中降低理论幻觉。 [推断：基于 REgov 设计目标]

## 已完成 smoke test

- `C:\Users\admin\.codex\skills\regov\SKILL.md` 可以从原 Codex skill 路径读取。 [已核验: C:\Users\admin\.codex\skills\regov\SKILL.md]
- `C:\Users\admin\.codex\skills` 当前是指向 `D:\CodexSkills\skills` 的 junction。 [已核验: C:\Users\admin\.codex\skills]
- REgov dashboard 脚本可以读取当前项目和 `04 Lee`，并生成测试图谱 `C:\Users\admin\Documents\New project\regov_dashboard\workstream_map_test.md`。 [已核验: C:\Users\admin\Documents\New project\regov_dashboard\workstream_map_test.md]
- 测试 dashboard 已识别当前项目 `W1`，以及 `04 Lee` 的 `W1`、`W2`、`W3`、`W4` 四条工作流。 [已核验: C:\Users\admin\Documents\New project\regov_dashboard\workstream_map_test.md]

## 当前发现的问题

- REgov 本体可用，但部分 K-Dense 依赖技能的当前入口指向 `D:\CodexSkills\k-dense-scientific-skills-upstream`，该目录下对应 skill 文件夹为空；完整版本位于 `D:\CodexSkills\k-dense-scientific-skills`。这会影响 `paper-lookup`、`statistical-analysis`、`scientific-visualization` 等 REgov 可能调度的能力。 [已核验: D:\CodexSkills\k-dense-scientific-skills] [已核验: D:\CodexSkills\k-dense-scientific-skills-upstream]
- 由于写入 `D:\CodexSkills\k-dense-scientific-skills-upstream` 需要授权，本轮自动恢复命令两次授权检查超时，尚未实际修复该依赖入口。 [来源: 当前工具执行结果 2026-05-27]

## 建议测试用例

### T1 轻量状态读取

提示词：

```text
用 REgov 告诉我当前项目现在推进到哪一步，只读必要记忆，不展开全部 evidence。
```

通过标准：

- 只读取当前项目轻量层。
- 不默认展开 `04 Lee`。
- 能说清当前主线、开放问题和下一最小步。

### T2 跨项目背景调用

提示词：

```text
用 REgov 比较当前项目和 04 Lee 关于 09:00 左右 CO2 次高峰归因的相同点和差异。
```

通过标准：

- 同时读取当前项目和 `04 Lee`。
- 保留两个项目的证据边界。
- 明确哪些只是历史背景或方法先例，不能直接变成当前结论。

### T3 理论边界审查

提示词：

```text
用 REgov 检查“CVT 日出后负 w_mean 说明谷底补偿下沉”这个判断现在能不能写进论文。
```

通过标准：

- 区分观测、解释、理论 warrant、方法边界和反证。
- 提醒未旋转 raw `w`、水平风投影、流线倾斜等限制。
- 给出下一步最小验证，而不是直接定论。

### T4 workstream 可视化

提示词：

```text
用 REgov 刷新所有项目 workstream 和进展图。
```

通过标准：

- 生成或更新 `regov_dashboard/workstream_map.md`。
- 包含当前项目和 `04 Lee`。
- 标出各项目 workstream 数量、开放问题数量和当前重点。

### T5 固定输出风格

提示词：

```text
用 REgov 把当前机制判断写成一段论文 discussion 草稿，保持证据边界。
```

通过标准：

- 论文文本风格稳定、克制。
- 不把候选机制写成确定因果。
- 不把普通讨论格式强行套到论文草稿外的回答里。

## 优化优先级

1. 先修复 K-Dense 依赖技能入口，确保 `paper-lookup`、`statistical-analysis`、`scientific-visualization` 可用。 [推断：基于 REgov 调度依赖]
2. 给 REgov 增加一个 `scripts/smoke_test_regov.py`，自动检查 skill 路径、项目注册表、dashboard 生成和关键依赖 skill 是否可读。 [推断：基于本轮测试流程]
3. 给 REgov 增加 `theory_cards/` 和 `method_cards/` 目录，用于长期保存局地环流、垂直平流、REA 条件分组、EC 时间口径等高频理论边界。 [推断：基于当前科研项目需求]
4. 给 dashboard 增加状态字段，例如 `active`、`paused`、`needs evidence`、`blocked by method boundary`，让 workstream 可视化更适合长期项目管理。 [推断：基于当前 dashboard 输出]
