# Repository Index

This file maps the repository into a few layers that a model can read quickly.

## How the memory layers connect

Use `project_memory/` for project-specific evidence and workstream state. Use `regov_memory/` for shared research context, dissertation-level questions, method menus, data inventory, theory cards, and cross-project governance. Root files such as `README.md`, `analysis_snapshot.md`, `data_manifest.md`, and this index are fast-entry views that connect those two memory layers.

## Root entry files

- `README.md`: human-readable entry point and current reading order.
- `analysis_snapshot.md`: compact current-state snapshot for stable numerical results, interpretation boundaries, and mechanism synthesis.
- `data_manifest.md`: in-repo and external data / output locations.
- `repo_index.md`: repository map.

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

## Layer 2: Immediate synthesis and next-step plans

`next_step/` contains working synthesis notes and immediate next-step plans that connect existing evidence into the next analysis action.

### Important files
- `next_step/01_FL_moving_transect_anomaly_transport_plan.md`
- `next_step/02_FL_pass_feasibility_result_summary.md`
- `next_step/2026-06-04_CO2_event_competing_hypotheses_status.md`

The 2026-06-04 file is currently the most important bridge between existing memory and the next analysis step. It organizes the CO2 secondary-peak problem into H1-H8 competing hypotheses and proposes event-level mechanism scoring tables.

## Layer 3: Research context

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

## Layer 4: REgov skill package

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

## Layer 5: Dashboard

`regov_dashboard/` contains rendered summary views.

### Important files
- `regov_dashboard/workstream_map.md`
- `regov_dashboard/workstream_map_test.md`

## External references

Some source data, scripts, and verification outputs are stored outside the repo on local drives.
When that happens, the repo should include a clear path note in a manifest file rather than copying the full data here.

## Current model reading path

For fast orientation, read:

1. `README.md`
2. `analysis_snapshot.md`
3. `project_memory/runtime/01_current_snapshot.md`
4. `project_memory/runtime/05_next_mainline_tasks.md`
5. `next_step/2026-06-04_CO2_event_competing_hypotheses_status.md`
6. `regov_memory/06_research_question_map.md`
7. `regov_memory/07_data_inventory.md`
8. `regov_memory/08_method_menu.md`
