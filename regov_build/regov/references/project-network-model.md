# REgov Project Network Model

## Purpose

Use this reference when REgov must coordinate multiple project memories, especially the current project and `04 Lee`.

## Model

REgov treats the research program as a network:

- `program`: the long-running research direction.
- `project`: a concrete analysis project with its own `project_memory`.
- `workstream`: a focused line of work inside a project.
- `claim`: a scientific, methodological, or interpretive statement.
- `evidence`: a thread, file, script, figure, table, verification note, or user-provided note.
- `theory card`: a reusable theoretical or methodological boundary.
- `style guide`: rules for code, paper text, captions, and project notes.

## Reading Rule

Do not load every project memory by default. Start from:

1. REgov project registry.
2. Current project lightweight memory.
3. Relevant workstream.
4. Relevant `04 Lee` memory only when the user asks for historical context, a related precedent, or a cross-project comparison.

## Cross-Project Synthesis Rule

When connecting two projects:

- identify what is shared: site, instrument, method, variable, phenomenon, mechanism, code lineage, or theoretical frame
- identify what is not shared
- preserve provenance tags from each project
- mark cross-project interpretation as `推断：`
- do not promote a pattern from one project into a stable rule for another project without direct evidence

## Registry Fields

Use these fields for each project:

- project id
- display name
- project memory path
- status
- main workstreams
- stable constraints
- linked projects
- last verified date
- unresolved path or provenance issues
