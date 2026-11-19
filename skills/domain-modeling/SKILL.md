---
name: domain-modeling
description: Build and sharpen the project's shared language. Use when discussing domain terminology, when a term is fuzzy or overloaded, or when writing GLOSSARY.md or an ADR.
---

# Domain modeling

Failure mode this prevents: *the agent is too verbose* and *names drift*. A shared glossary lets humans and agents say one precise word instead of a paragraph, keeps names consistent across the codebase, and cuts thinking tokens.

## Files

- `GLOSSARY.md` at the repo root (or per bounded context, listed in `GLOSSARY-MAP.md`).
- `docs/adr/NNNN-<slug>.md` for decisions.
- Create each lazily, when you first have something to write.

## During any design conversation

- **Challenge against the glossary.** A term used in conflict with `GLOSSARY.md` gets called out immediately: "The glossary defines *Cancellation* as X, you seem to mean Y. Which?"
- **Sharpen fuzzy words.** "Account": Customer or User? Propose one canonical term.
- **Probe with scenarios.** Invent concrete edge cases that force a boundary between two concepts.
- **Cross-check the code.** If the user's description and the code disagree, say so with the file and line.
- **Write terms inline**, the moment they settle. Don't batch.

## Glossary entry format

```markdown
## <Term>
<One or two sentences: what it is in this domain.>
- Not: <near-miss term it must not be confused with, and why>
- Related: <Term>, <Term>
```

The glossary holds language only. No implementation details, file paths, or decisions.

## ADRs, sparingly

Offer one only when all three hold: hard to reverse, surprising without context, and the result of a real trade-off. Format:

```markdown
# NNNN. <Decision title>
Status: accepted | superseded by NNNN
## Context
## Decision
## Alternatives considered
## Consequences
```
