# Workstream Visualization

## Purpose

REgov must provide a clear visual overview of all workstreams and progress.

## Default Dashboard

The default dashboard is a Markdown file with:

- a Mermaid flowchart linking REgov, projects, workstreams, open questions, and next actions
- a project table
- workstream summaries
- unresolved project-memory paths
- source file links

## Refresh Rule

Refresh the dashboard when:

- a workstream is added or closed
- a current priority changes
- cross-project links change
- the user asks for a project map
- a major evidence note changes the mechanism ranking

Do not refresh only because a minor discussion occurred.

## Visual Conventions

- project nodes: project names
- workstream nodes: `W#` plus short title
- unresolved nodes: label with `UNRESOLVED`
- evidence nodes: only include high-level evidence categories, not every file
- keep the diagram readable before making it exhaustive

## Script

Use:

```bash
python scripts/build_workstream_map.py --root <workspace> --output <dashboard.md>
```

For multiple projects:

```bash
python scripts/build_workstream_map.py --project "Current=<path>" --project "04 Lee=<path>" --output <dashboard.md>
```
