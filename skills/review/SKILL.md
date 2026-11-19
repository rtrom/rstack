---
name: review
description: Review a diff on two independent axes (Standards and Spec) with parallel reviewer subagents, plus an optional adversarial pass where only findings proven by a run survive. Use to review a branch, PR, ticket, or work in progress.
argument-hint: "[adversarial] [fixed-point: main | SHA | branch] [spec path or ticket]"
---

# Review

Report findings. Don't apply fixes; the supervisor routes them to a fresh implementer.

## 1. Pin the fixed point

Default: merge-base with `base_branch` from `.work/config.md`. Capture once:
- `git diff <fixed>...HEAD` (three-dot) and `git log <fixed>..HEAD --oneline`.
- Confirm the ref resolves and the diff is non-empty. Fail here, not inside parallel agents.
- Include uncommitted changes if the user is reviewing work in progress.

## 2. Find the spec

In order: argument; ticket/spec under `.work/`; issue refs in commit messages (`gh issue view`); spec matching the branch name. None → the Spec axis reports "no spec available".

## 3. Find the standards

`CLAUDE.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `.editorconfig`, analyzer/lint configs, the `Standards sources` in config, and `GLOSSARY.md` for naming. Skip anything tooling already enforces.

## 4. Run both axes in parallel

Spawn two `rstack:reviewer` subagents in one message, foreground, each with a fresh context:

- **Standards axis:** the diff command, commit list, standards files. Brief: "Axis: standards. Report every place the diff violates a documented standard (cite file and rule) and any baseline smell (name it, quote the hunk). Documented standards are hard violations; smells are judgment calls; the repo overrides the baseline. Under 400 words."
- **Spec axis:** the diff command, commit list, spec path. Brief: "Axis: spec. Report (a) requirements missing or partial, (b) behavior not asked for (scope creep), (c) requirements implemented wrongly. Quote the spec line for each. Under 400 words."

## 5. With `adversarial`

In the same message, also spawn 2-3 `rstack:adversary` subagents, each with its own worktree at HEAD (`git worktree add <worktree_root>/adv-<n> HEAD --detach`, copying uncommitted changes in). Use different models for diversity: `opus` and `fable` from config, plus a second `opus` at different effort. Brief: "Break this change. Prove each finding with a run: failing test, repro script, or command output showing the wrong behavior against the stated intent. Report title, exact command, actual output, expected output. Leave out anything you didn't run. No findings is valid."

Then **verify every adversary finding yourself** by rerunning its command. Keep it only if the output shows the failure and it breaks the intent. Merge findings sharing a root cause. Drop the rest and count them.

## 6. Report

```
## Standards
<reviewer report, lightly cleaned>

## Spec
<reviewer report, lightly cleaned>

## Adversarial (if run)
<verified findings: command, output, how it breaks intent, who found it>
Dropped: <count per adversary and why>

Summary: <findings per axis> · worst Standards issue: … · worst Spec issue: …
```

Don't merge or rerank across axes. Code can follow every standard and build the wrong thing, or build the right thing badly. Keeping axes separate stops one from masking the other.

**Verdict:** `pass` (no hard violations, no spec gaps, no verified adversarial findings) or `changes` with the list a fresh implementer should address.
