---
name: regov
description: Research evidence governance for long-running scientific projects. Use when the user mentions REgov, asks to manage or synthesize project memory across current project and 04 Lee, govern research evidence/provenance, coordinate workstreams, build or refresh a project progress visualization, check theoretical plausibility, preserve dissertation strategic focus, decide knowledge-source connections, or enforce stable code/paper output style for a long-running research program.
---

# REgov

REgov is a research governance skill for long-running scientific projects. It coordinates project memory, evidence, theory checks, workstreams, code outputs, and paper-style outputs without turning every ordinary reply into a rigid template.

## Core Rule

Treat current project memory and `04 Lee` project memory as historical background sources for the larger research program. Do not load or restate all background by default. Select the smallest relevant memory layer for the current task.

Before creating a new workstream or new project memory for the same research area, read `regov_memory/00_shared_research_context.md` when it exists. Treat it as the inherited research-area background and method-boundary layer.

## Research Focus Filter

When working on this research project, do not only optimize for task completion. Also help preserve the strategic focus of the dissertation.

Use these three questions as a recurring research filter:

1. What is uniquely strong about the user's observation system?
2. Which scientific questions can only this project answer, or answer substantially better than others, because of this observation system?
3. Which highly cited papers or accepted assumptions in this field are influential but still leave an unresolved problem that the user's data or method can address?

Use this filter especially when the task involves literature review, research gap analysis, hypothesis generation, paper outline design, discussion section writing, figure/storyline planning, method justification, observation-system interpretation, dissertation structure, or deciding whether a side analysis is worth doing.

Do not force this filter into routine tasks such as file cleanup, syntax fixes, plotting bugs, environment setup, or mechanical data conversion unless the result affects research direction.

When relevant, include a short section named `Research focus checkpoint` with:

- Observation-system advantage.
- Question only this project can answer.
- Unresolved high-impact literature gap.
- Whether the current task strengthens or distracts from the main dissertation line.

Keep this checkpoint concise. It should guide prioritization, not become a long philosophical discussion.

## Operating Modes

1. **Orientation mode**
   - Use for progress, next step, or "where are we" questions.
   - Read only the project registry, current project anchors, current snapshot, open questions, recent actions, and the relevant workstream index.

2. **Cross-project mode**
   - Use when the user asks to connect current work with `04 Lee` or another project.
   - Read `references/project-network-model.md` first, then only the relevant project memories.
   - Preserve source boundaries. Do not silently merge two project memories into one clean story.

3. **Theory-guard mode**
   - Use for mechanism interpretation, causal claims, physical reasoning, statistical inference, or literature-backed judgment.
   - Read `references/theory-and-evidence-guardrails.md`.
   - Use installed skills such as `paper-lookup`, `pyzotero`, `statistical-analysis`, `database-lookup`, and domain-specific skills when needed.

4. **Execution-governance mode**
   - Use when running or editing analysis code.
   - Keep changes narrow, follow the project's existing script style, and produce a verification note when a run changes scientific state.
   - Fixed style applies to code, paper drafts, captions, reviewer responses, and project notes; ordinary discussion may stay natural and concise.

5. **Workstream-visualization mode**
   - Use when the user asks for a clear map of workstreams, progress, open questions, or project network.
   - Run `scripts/build_workstream_map.py` or update the equivalent dashboard manually if the script cannot see the needed paths.
   - Read `references/workstream-visualization.md` before revising the visualization format.

## Knowledge Source Policy

Read `references/knowledge-source-policy.md` when deciding whether to connect a knowledge base.

Default hierarchy:

1. Local project memory with provenance tags.
2. Local verified files, scripts, data manifests, and generated verification notes.
3. User-provided notes, discussion excerpts, or thread IDs.
4. Literature databases via `paper-lookup` or Zotero via `pyzotero`.
5. Public scientific or official databases via `database-lookup`.
6. Web search only when information is current, not in local sources, or the user explicitly asks for it.

Never use model memory as a scientific source.

## Coordination With Existing Skills

Prefer using installed local skills instead of duplicating them:

- `project-progress-memory`: layered project memory and provenance.
- `paper-lookup`: literature discovery and paper metadata.
- `pyzotero`: Zotero library retrieval and reference management.
- `statistical-analysis`: statistical test choice, assumptions, and reporting.
- `scientific-visualization`: publication-ready scientific figures.
- `database-lookup`: public scientific and environmental data APIs.
- `meteorological-quality-control-standards`: source-grounded meteorological QA/QC rules.
- `my-writing-style`: fixed writing style for paper/prose outputs when requested. For REgov research discussion notes, project-memory summaries, method planning, evidence-boundary clarification, and staged research plans, call its `Research Thinking Notes Mode`. For formal paper abstracts, introductions, discussions, conclusions, and reviewer responses, call its `Academic paper mode`.

REgov is the coordinator; these skills are specialist tools.

## Output Discipline

For normal discussion, answer directly and briefly.

For governed scientific outputs, use this pattern unless the user asks otherwise:

1. Current judgment.
2. Evidence chain.
3. Theory boundary.
4. Uncertainty or counter-check.
5. Next smallest verification step.

For paper or code outputs, read `references/output-style-policy.md`.

For research-thinking outputs that are not formal manuscript prose, use `my-writing-style` research thinking notes mode rather than academic paper mode.

## Visualization Tool

Generate a dashboard from one or more project memory roots:

```bash
python scripts/build_workstream_map.py --root <workspace> --project "Current=<path-to-current-project>" --project "04 Lee=<path-to-04-lee-project>" --output <dashboard.md>
```

If a project path is unknown, mark it as unresolved in the registry rather than inventing it.

## Borrowed Frameworks

REgov borrows these design ideas without requiring their full frameworks:

- Codex skills: compact instructions plus optional scripts and references.
- Letta-style git-backed memory: inspectable markdown memory and versioned edits.
- Graphiti/Zep-style temporal knowledge graphs: represent evolving relationships over time when a graph backend is later justified.
- Academic Research Skills-style reasoning guards: traceability, epistemic status, argumentation, and anti-overclaiming.

Use these as design patterns, not as automatic dependencies.
