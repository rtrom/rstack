---
name: pr
description: Open a ready-for-review pull request from small ordered commits, with a conventional title and a one-minute briefing body that includes evidence and a merge-risk call.
argument-hint: "[base branch]"
---

# PR

1. **Clean the branch.** Rebase onto the base into small, landable commits, each building and passing its checks. Regression tests land before their fixes. Strip comments that restate the code; keep ones that explain *why*.
2. **Final checks.** Run every check in `.work/config.md` on the branch head. Don't open a PR on red unless the red is `pre_existing_red` on base, and say so.
3. **Title:** `type(scope): subject` (feat, fix, refactor, perf, test, docs, chore), naming the real symbol when one carries the change.
4. **Body:** under 40 lines, these headings in order, empty ones dropped:

```markdown
## Why
<the goal, one or two sentences>

## What changed
<bullets, by behavior not by file>

## Scope
<what's deliberately not in this PR>

## Tradeoffs
<only rejected alternatives a reviewer would otherwise ask about>

## Blast radius
<what else this can affect> · Merge risk: low | medium | high, and why

## Verification
<commands run and results; before/after evidence for behavior or perf; screenshots for UI>
```

Long logs and tables go in a PR comment or a linked file, not the body.

5. **Open it ready, never draft:** `gh pr create --base <base> --title ... --body-file <file>`. Link closing issues. For stacked work, base it on the PR it builds on.
6. Reply with the PR URL and the merge-risk call. Opening a PR doesn't merge it.
