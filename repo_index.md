# Repository Index

This file maps the repository into a few layers that a model can read quickly.

## Layer 1: Project memory

`project_memory/` contains the current state of the project.

### Important files
- `project_memory/00_governance.md`
- `project_memory/anchors/01_anchor_facts.md`
- `project_memory/anchors/02_key_constraints.md`
- `project_memory/anchors/03_active_decisions.md`
- `project_memory/anchors/04_conflicts_to_keep.md`
- `project_memory/anchors/05_window_level_raw_w_diagnostic_definitions.md`
- `project_memory/artifacts/01_registry.md`
- `project_memory/evidence/00_thread_index.md`
- `project_memory/runtime/01_current_snapshot.md`
- `project_memory/runtime/02_open_questions.md`
- `project_memory/runtime/03_recent_actions.md`
- `project_memory/runtime/04_latest_window_level_raw_w_diagnostics.md`
- `project_memory/runtime/05_next_mainline_tasks.md`
- `project_memory/workstreams/_index.md`
- `project_memory/workstreams/W1_EA_EC_flux.md`

## Layer 2: Research context

`regov_memory/` contains the broader research background and methodology context.

### Important files
- `regov_memory/00_project_registry.md`
- `regov_memory/00_shared_research_context.md`
- `regov_memory/01_knowledge_sources.md`
- `regov_memory/02_skill_inventory.md`
- `regov_memory/03_visualization.md`
- `regov_memory/04_project_memory_network.md`
- `regov_memory/05_test_plan.md`
- `regov_memory/06_research_question_map.md`
- `regov_memory/07_data_inventory.md`
- `regov_memory/08_method_menu.md`
- `regov_memory/theory_cards/README.md`
- `regov_memory/theory_cards/coordinate_rotation.md`
- `regov_memory/theory_cards/ec_assumptions.md`
- `regov_memory/theory_cards/storage_flux.md`
- `regov_memory/theory_cards/vertical_advection.md`

## Layer 3: REgov skill package

`regov_build/regov/` contains the skill definition and supporting policies.

### Important files
- `regov_build/regov/SKILL.md`
- `regov_build/regov/agents/openai.yaml`
- `regov_build/regov/references/knowledge-source-policy.md`
- `regov_build/regov/references/output-style-policy.md`
- `regov_build/regov/references/project-network-model.md`
- `regov_build/regov/references/theory-and-evidence-guardrails.md`
- `regov_build/regov/references/workstream-visualization.md`
- `regov_build/regov/scripts/build_workstream_map.py`

## Layer 4: Dashboard

`regov_dashboard/` contains rendered summary views.

### Important files
- `regov_dashboard/workstream_map.md`
- `regov_dashboard/workstream_map_test.md`

## External references

Some source data, scripts, and verification outputs are stored outside the repo on local drives.
When that happens, the repo should include a clear path note in a manifest file rather than copying the full data here.
