# Knowledge Source Policy

## Default Answer

Yes, REgov should connect knowledge sources, but in layers. Start with local, inspectable sources. Add external or graph-based systems only when the use case justifies them.

## Source Layers

1. **Local project memory**
   - Primary source for project history, decisions, conflicts, and provenance.
   - Use `project-progress-memory` rules.

2. **Local verified artifacts**
   - Scripts, CSV files, manifests, figures, run logs, and verification notes.
   - Use direct file checks before changing scientific state.

3. **Reference manager**
   - Use Zotero through `pyzotero` when bibliography continuity matters.
   - Store literature links in theory cards or method cards.

4. **Scholarly search**
   - Use `paper-lookup` for papers, reviews, and methodological sources.
   - Prefer primary papers, reviews, and official datasets over general web pages.

5. **Scientific databases**
   - Use `database-lookup` for public APIs when structured data is needed.
   - Store queried endpoints in verification notes.

6. **Temporal knowledge graph**
   - Consider Graphiti/Zep only after local memory grows beyond markdown navigation.
   - Use it for relationships, not as the only source of truth.

## Connection Decision

Connect a knowledge source when at least one is true:

- the source will be reused across multiple workstreams
- it reduces hallucination risk for theory or method claims
- it provides stable identifiers or citations
- it allows direct verification of data or literature
- it helps visualize relationships across projects

Do not connect a source only because it sounds advanced.

## Citation Discipline

Every external-source summary must preserve:

- source name
- query or citation
- retrieval date when relevant
- what the source supports
- what it does not support
