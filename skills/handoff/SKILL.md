---
name: handoff
description: Compact the current session into a handoff document a fresh agent can resume from. Use before ending a long session, at phase boundaries, or before an unattended stop.
argument-hint: "[what the next session will focus on]"
---

# Handoff

Write `.work/<feature>/handoff.md` (or `.work/handoff-<date>.md` with no feature). Overwrite any older handoff for the same feature.

Point to artifacts; don't copy them. Specs, tickets, ADRs, commits, and PRs are referenced by path or URL.

Redact secrets, tokens, and personal data.

```markdown
# Handoff: <feature> · <date>

## Goal
<one paragraph>

## State
- Branch / worktrees: <names, head SHAs>
- Landed: <commits or PRs>
- Board: <path to board.md> (<n> done, <n> in progress, <n> blocked)

## In flight
<what's half-done, exactly where it stopped, uncommitted changes and where they live>

## Decisions made
<pointer to decisions.tsv, plus the 3-5 that matter most>

## Next steps
1. <the very next action, concrete enough to start without reading anything else>

## Watch out for
<traps discovered this session>

## Suggested skills
<e.g. /rstack:pickup, then /rstack:run-spec <feature>>
```

If the user passed a focus, tailor "Next steps" to it.
