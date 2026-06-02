# Output Style Policy

## Scope

REgov does not force every casual reply into one fixed format. Fixed style applies to:

- code
- analysis scripts
- project memory notes
- verification notes
- research thinking notes
- method planning notes
- evidence-boundary discussion notes
- paper drafts
- abstracts
- figure captions
- reviewer responses
- thesis-style summaries

## Code Style

- Follow the existing project language and script organization.
- Make one narrow change at a time.
- Reuse project helper functions and parsing rules.
- Keep paths, output directories, and filenames explicit.
- Generate or update a verification note when a run changes scientific interpretation.
- Do not silently overwrite previous result branches.

## Project Note Style

Use Chinese by default for project memory notes.

Each substantive factual point should include a source marker:

- `[来源: ...]`
- `[已核验: ...]`
- `推断：...`

Keep notes complete enough to preserve reasoning, but avoid rewriting every memory file after each small change.

## Paper Style

Use a restrained academic style:

- distinguish result, interpretation, and limitation
- avoid overconfident causal language
- keep mechanism claims tied to evidence and theory warrants
- write uncertainty explicitly when evidence is incomplete
- do not use generic AI endings

If the user's academic writing style has not been calibrated, say so when producing a final manuscript-like draft. For provisional drafts, use a clear, disciplined academic voice.

## Research Thinking Style

For non-manuscript research discussion, project-memory synthesis, staged analysis planning, method design, and uncertainty sorting, use `my-writing-style` in `Research Thinking Notes Mode`.

This mode is preferred over academic paper mode when the output is meant to preserve thinking, mechanism splitting, evidence boundaries, and next-step reasoning rather than polished publication prose.
