---
name: retro
description: Retrospective that turns session outcomes into durable improvements, most severe first. Distills .work/outcomes.jsonl into lessons and proposes encoding them as checks, standards, or skill edits. Use after a feature lands, after a painful session, or weekly.
disable-model-invocation: true
argument-hint: "[feature-slug | 'week' | session]"
---

# Retro

You're improving the **environment** agents work in, not grading the code. The loop: outcomes → lessons → structure.

## 1. Gather signal

- `.work/outcomes.jsonl` entries in scope (feature, or the last 7 days).
- Reports, review findings, and `decisions.tsv` for the feature.
- The session transcripts (delegate to `rstack:explorer`; only this workspace's folder under `~/.claude/projects/`).
- What the user had to correct by hand. Those are the most expensive mistakes.

## 2. Find candidates, by category

- **Navigation:** the agent took long to find something. Fix: a pointer in `CLAUDE.md`, a glossary term, a better module name.
- **Automated checks:** a mistake a check could have caught, or a check that exists but isn't wired into CI or a hook. No guardrail at all is itself a finding.
- **Standards:** the reviewer missed something. Classify it: **mechanical** (banned API, import shape, naming pattern, file location) → a deterministic check (Roslyn analyzer, `.editorconfig` rule, ESLint rule, pre-commit hook, CI job). Only genuine **judgment calls** go to `CODING_STANDARDS.md`.
- **Steering bloat:** instructions in `CLAUDE.md` that don't change behavior, or that belong in a check.
- **Tool economy:** expensive tool calls, token-heavy output that a script could summarize.
- **Information access:** a fact the agent needed but couldn't reach (logs, a DB schema, a service's docs).
- **Workflow:** a skill or playbook step that misled, or a recipe worth capturing as a skill edit.

## 3. Rank and present

Most severe first. Each: the evidence (quote the outcome or transcript moment), the proposed encoding, and where it goes. Prefer, in order: architecture or types → analyzer/lint/CI → test → hook → skill or playbook edit → prose in `CLAUDE.md`. Prose is last because it's the weakest enforcement.

## 4. Record lessons

Append each accepted lesson to `.work/lessons.md` as one or two sentences, with the date and a pointer to its evidence. `/rstack:build` and `/rstack:run-spec` read this file at start.

```markdown
- 2026-11-19 · EF migrations from parallel tickets collided; serialize tickets that add migrations. (outcomes: feat-x/03, feat-x/05)
```

## 5. Promote (with approval)

A lesson that recurs (seen in 2+ outcomes) is a promotion candidate: encode it in structure, or edit the relevant rstack skill/playbook or `CLAUDE.md`. Show the exact diff and wait for approval; this changes every future session. After promotion, mark the lesson `(promoted → <where>)`.
