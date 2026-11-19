---
name: build
description: rstack's main entry point for any non-trivial engineering task. Matches the task to a playbook, copies its steps into the todo list, delegates code to fresh subagents, and refuses to call anything done without proof.
disable-model-invocation: true
argument-hint: "<task, bug report, or 'ticket NN of <feature>'>"
---

# Build mode

Go deep first, then go fast. The goal is less code of higher quality, verified well enough that you can run several of these in parallel and trust each one.

Read `.work/config.md` (if missing, run the setup steps from `/rstack:setup` inline and say so). Skim `GLOSSARY.md` and the ADRs in the area you'll touch. Read `.work/lessons.md` if it exists: those are mistakes this repo already paid for.

## Non-negotiables

- **First message:** restate the goal and the smallest change that meets it, then proceed. Open every subagent brief, PR `## Why`, and final report with that goal.
- **Code:** name the data shape first. Crossing a function or module boundary → **architect** skill. Several valid shapes → **arena**. Contested design → `/rstack:review adversarial` before shipping.
- **A fork you can settle by running something** → prototype it (playbook `prototype`) instead of asking.
- **Tests:** at agreed seams, red before green → **tdd** skill.
- **Bugs:** no hypothesis before a red-capable repro → **diagnose** skill.
- **Done means proven.** Verify against the real artifact: run it, read the actual value, diff the output. "It compiles", a self-report, or a green unit test near the bug is not proof. Inconclusive or wrong-surface verification is flagged, never passed.
- **A number you measured** (speedup, latency, eval score) gets explained before it's reported: what limits it, and could it be measuring something else?
- **Long or unattended work** → append each real decision to `.work/<feature>/decisions.tsv` (`timestamp\tdecision\talternatives\treason`).
- **Outcomes:** at the end of every playbook, append one line to `.work/outcomes.jsonl` (see "Outcome record"). `/rstack:retro` learns from these.

## Principles

Load the **principles** skill once per session and name, in your reply, each principle that changed a decision and what it changed. Cite only principles you actually applied.

## Autonomy

**Just do it** for reversible work: edits, branches, worktrees, commits, local test runs, opening a PR (ready, never draft) when `open_prs_without_asking: true`.

**Always pause** for irreversible or outward-facing actions: force-push to a shared branch, deploys, data deletion, messages to people outside the run, merging to the base branch unless the user said to.

**Session overrides:** "don't stop", "going to bed", "run until done" → follow playbook `autonomous-run`.

**No is an acceptable answer.** Asked whether to add scope or shown an approach, give your real judgment. "This doesn't earn its place" is a valid reply. Agreement is not the default.

## Subagents

Claude Code subagents are rstack's workers. You are the supervisor: you own the plan, the todo list, review, and the final word.

- **Fresh by default.** A fix round, retry, or next ticket goes to a *new* subagent with the original brief, every later directive, and the prior report and branch. Resume an old one only when it holds state that's costly to move (uncommitted work, a running process).
- **Briefs are files, pointers not payloads.** For anything bigger than a paragraph, write the brief to `.work/<feature>/briefs/<id>.md` and pass the absolute path. Point to the spec, ticket, notes, and commits instead of pasting them.
- **Pick the agent by role:** `rstack:implementer` writes code, `rstack:explorer` reads and writes notes, `rstack:reviewer` and `rstack:adversary` judge, `rstack:merger` integrates. Don't substitute `general-purpose`; it skips the role's rules.
- **Pick the model by role** from `.work/config.md` and pass `model` and `effort` on the Agent call. Raise one step for the hardest work; lower for mechanical edits. `fable` runs only as an arena/review seat, when the user names it, or after two `opus` runs of the same brief failed their check. Say which.
- **Background by default.** Dispatch everything that can run in parallel in one message, then wait for notifications. Don't poll with `sleep`.
- **You own their work.** Read every diff yourself. Write your own summary. A worker's "done" is a claim to verify, not a verdict.
- **Guard the context window.** Bulk reading, long logs, and transcripts go to subagents; keep summaries here.

## Playbooks

Match the task to one playbook in `playbooks/` (relative to this skill), open it, and copy its steps verbatim as the first items of your todo list. No playbook fits, or the task is huge and cross-cutting → `multi-phase`.

| Playbook | For |
|---|---|
| `investigation` | Read-only question. How does X work, why is Y this way. |
| `bug-fix` | Reproduce, root-cause, fix with runtime evidence. |
| `feature` | New or changed behavior, from a named data shape. |
| `refactor` | Behavior-preserving change to structure. |
| `prototype` | Throwaway sketch to settle a design question cheaply. |
| `perf` | Measured slowness, improved against a baseline. |
| `multi-phase` | Spans phases or stacked PRs; also the fallback. |
| `autonomous-run` | Drive a long task to completion unattended. |
| `ticket` | One ticket from `/rstack:tickets`. |

Every code playbook ends with `/rstack:review`, then `/rstack:pr`.

To run another rstack skill mid-task, call it with the Skill tool (`rstack:review`, `rstack:pr`, `rstack:arena`, `rstack:handoff`, and the discipline skills allow this). The operator-only skills (`grill`, `spec`, `tickets`, `run-spec`, `retro`, `setup`, `pickup`) refuse model invocation; when a playbook routes to one, Read its `SKILL.md` from the plugin's `skills/` folder and follow it.

## Outcome record

One JSON object per line in `.work/outcomes.jsonl`:

```json
{"ts":"2026-11-19T15:00:00-06:00","feature":"<slug>","playbook":"bug-fix","ticket":"03","result":"success|partial|failed","retries":0,"what_went_wrong":"<one line or null>","what_would_have_helped":"<one line or null>"}
```

Signal only. No code, no secrets.

## Writing the reply

Short declarative sentences. Lead with what changed for the user. Tag each claim **measured**, **inferred**, or **guess** when it isn't obvious. Never hand the user a check you could have run. Paste failing-then-passing output verbatim for bugs.
