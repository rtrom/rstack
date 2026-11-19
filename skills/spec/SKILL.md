---
name: spec
description: Synthesize the current conversation into a spec with agreed test seams. No new interview. Writes .work/<feature>/spec.md, or a GitHub issue when the tracker is github.
disable-model-invocation: true
argument-hint: "<feature-slug>"
---

# Spec

Synthesize what was already decided (usually in a `/rstack:grill` session). Do not interview again. Read `.work/config.md` first; if missing, tell the user to run `/rstack:setup`.

## Steps

1. Explore the affected code if you haven't (delegate bulk reading to `rstack:explorer`). Use `GLOSSARY.md` vocabulary throughout and respect ADRs in the area.
2. **Name the data shape.** Before anything else, write the core types or state the feature revolves around. Most downstream decisions fall out of this.
3. **Pick the seams.** A seam is the public boundary where tests observe behavior. Prefer existing seams; propose new ones at the highest point possible. Fewer is better; one is ideal. Give each seam a one-line note on what it catches and what it misses. Confirm the seams with the user. This is the only question this skill asks.
4. Write the spec with the template below to `.work/<feature>/spec.md` (or publish as a GitHub issue labelled `ready-for-agent` when `tracker: github`, and save the URL in `.work/<feature>/spec.link`).

## Template

```markdown
# <Feature>

## Goal
One paragraph, from the user's perspective.

## Problem
What hurts today, and for whom.

## Data shape
The core types/state, as a short code block in the repo's language. Mark it "sketch" if not final.

## User stories
1. As a <actor>, I want <capability>, so that <benefit>.
(Extensive. Cover the edges.)

## Decisions
- Modules built or changed, and their interfaces
- Contracts, schema changes, error behavior
- Each decision with the alternative that lost, in one clause

## Test seams
| Seam | Catches | Misses |
|---|---|---|

## Out of scope

## Open questions
(Empty if grilling was complete. Each one names who decides.)
```

No file paths or line-level code outside "Data shape": they go stale. Exception: a prototype snippet that encodes a decision more precisely than prose (state machine, reducer, schema), trimmed to its decision-rich part and labelled as from a prototype.

**Next:** `/rstack:tickets <feature>`.
