# research

This repository contains the project memory, governance notes, research context, and workstream records for the 06EA / REgov project.

Current repository status: updated through the 2026-06-04 CO2-event competing-hypotheses synthesis.

## What this repo is for

The goal of this repository is to make the project readable by both humans and models:
- explain the research background
- show the current workstream state
- keep evidence and verification notes traceable
- expose the project structure in a compact, machine-readable way

## Memory architecture

The repository uses two memory layers:

- `project_memory/` is the evidence-site layer. It records project-specific facts, verification notes, runtime snapshots, workstream state, open questions, and concrete analysis decisions.
- `regov_memory/` is the governance layer. It records shared research background, dissertation-level research questions, data inventory, method menu, theory cards, source policy, and cross-project context.

Do not collapse these two layers. When a new result is produced, record the detailed evidence in `project_memory/`; when that result changes the broader research strategy, method boundary, or shared background, promote a short provenance-tagged summary into `regov_memory/`.

## Current analysis state

The active scientific line is no longer just generating flux outputs. It is now organizing existing EA/EC, raw-`w`, CO2 profile, three-site wind, rotation-sensitivity, and FL moving-transect anomaly evidence into an event-level mechanism ranking for the 09:00 CO2 secondary-peak problem.

The current interpretation boundary is:

- EC/EA based on `w'` remains the turbulence-flux reference.
- raw `wc` remains a current-coordinate mean-flow / air-amount diagnostic.
- FL is a moving cross-section evidence layer, not a third fixed mean-flux tower.
- rotation sensitivity is a method-risk layer that must be checked before writing raw `w_mean` as physical vertical circulation.

## Main folders

- `project_memory/`  
  Current project memory, anchors, runtime state, evidence index, and workstream notes.

- `regov_memory/`  
  Research background layer, data inventory, method menu, theory cards, and project registry.

- `regov_build/regov/`  
  REgov skill definition, reference policies, and the workstream map generator script.

- `regov_dashboard/`  
  Prebuilt project dashboard and test version of the workstream map.

- `analysis_snapshot.md`  
  Compact summary of the most stable numerical results and interpretation boundaries.

- `next_step/`
  Working synthesis notes and immediate next-step plans. The current key file is `next_step/2026-06-04_CO2_event_competing_hypotheses_status.md`.

## Reading order

If you want to understand the project quickly, read in this order:

1. `README.md`
2. `repo_index.md`
3. `analysis_snapshot.md`
4. `project_memory/00_governance.md`
5. `project_memory/anchors/01_anchor_facts.md`
6. `project_memory/anchors/02_key_constraints.md`
7. `project_memory/anchors/03_active_decisions.md`
8. `project_memory/runtime/01_current_snapshot.md`
9. `project_memory/runtime/02_open_questions.md`
10. `project_memory/runtime/05_next_mainline_tasks.md`
11. `project_memory/workstreams/W1_EA_EC_flux.md`
12. `next_step/2026-06-04_CO2_event_competing_hypotheses_status.md`
13. `regov_memory/00_shared_research_context.md`
14. `regov_memory/06_research_question_map.md`
15. `regov_memory/07_data_inventory.md`
16. `regov_memory/08_method_menu.md`
17. `regov_memory/theory_cards/README.md`

## Current next output

The next useful repository artifact is an event-level mechanism table. It should connect profile switch timing, CO2 pre-minimum timing, wind-sector changes, three-site CO2 synchronization, EC/air-mass structure, FL spatial pattern labels, and rotation/projection risk into one compact scoring table.

Suggested target files:

- `next_step/CO2_event_lead_lag_table.csv`
- `next_step/FL_event_spatial_pattern_labels.csv`
- `next_step/CO2_event_mechanism_ranking.csv`

## Notes

- Evidence files use provenance tags and should be read together with the workstream notes.
- Some source data and verification artifacts live outside the repo on a local research drive.
- The repo is organized to preserve source boundaries rather than merge every note into one summary.
