# rstack

A Claude Code workflow for agentic engineering: **align → spec → slice → build → prove → review → ship → learn**.

It merges three sources into one pipeline with no duplicate skills:

| Source | What rstack takes from it |
|---|---|
| [pstack](https://github.com/cursor/plugins/tree/main/pstack) (Lauren Tan / poteto) | A single rigorous entry point that routes to playbooks; the principles index; "prove it works"; fresh subagents per task; arena bakeoffs; adversarial review where only run-proven findings survive; the briefing-style PR. |
| [mattpocock/skills](https://github.com/mattpocock/skills) | Grilling in design-tree rounds; shared language (`GLOSSARY.md`, ADRs); spec → tracer-bullet tickets with blocking edges; TDD at agreed seams; two-axis code review; handoff; retro aimed at the environment, not the code. |
| [CLI Agent Orchestrator](https://github.com/awslabs/cli-agent-orchestrator) (AWS Labs) | The supervisor that never writes code; briefs and reports as files with absolute paths; async assign vs blocking handoff; review gating every merge; outcome → lesson → promotion; scheduled flows and durable workflows (optional `cao/` layer). |

## Install

```bash
# from a local clone
/plugin marketplace add /path/to/rstack
/plugin install rstack@rstack

# or after pushing to GitHub
/plugin marketplace add <you>/rstack
/plugin install rstack@rstack
```

Install at **user** scope if you'll use the CAO layer. Then, in each repo: `/rstack:setup`.

## The pipeline

```
/rstack:grill [docs]   align: design-tree interview, glossary + ADRs
        │
/rstack:spec           synthesize: goal, data shape, decisions, test seams
        │
/rstack:tickets        slice: tracer bullets, blocking edges, throughput checkpoint
        │
        ├── /rstack:build ticket NN     one ticket, serial
        └── /rstack:run-spec <feature>  whole graph, parallel worktrees, supervisor mode
                │
        /rstack:review [adversarial]    standards ∥ spec ∥ adversaries
                │
        /rstack:pr                      ready PR, briefing body, merge-risk call
                │
        /rstack:retro                   outcomes → lessons → checks
```

For small work, skip straight to `/rstack:build <task>`. It picks a playbook (bug-fix, feature, refactor, investigation, prototype, perf, multi-phase, autonomous-run, ticket) and runs the rest for you.

## Skills

**You invoke these** (orchestrators):

| Skill | Use |
|---|---|
| `/rstack:setup` | Once per repo. Detects build/test/lint, tracker, base branch → `.work/config.md`. |
| `/rstack:grill` | Before non-trivial work. Add `docs` to build the glossary and ADRs as you go. |
| `/rstack:spec` | Turn the grilled conversation into a spec with agreed seams. |
| `/rstack:tickets` | Spec → tracer-bullet tickets + throughput checkpoint + board. |
| `/rstack:build` | Main entry point for any task. Playbook router. |
| `/rstack:run-spec` | Supervisor mode over the ticket graph. |
| `/rstack:review` | Two-axis review; `adversarial` adds proven-by-run attackers. |
| `/rstack:arena` | N parallel attempts, cross-judged, best one grafted. |
| `/rstack:pr` | Open the PR. |
| `/rstack:handoff` / `/rstack:pickup` | End and resume sessions without redoing work. |
| `/rstack:retro` | Learn from outcomes; encode lessons as structure. |

**Claude loads these when the task fits** (discipline): `tdd`, `diagnose`, `architect`, `principles`, `domain-modeling`.

## Agents

| Agent | Role | Tools |
|---|---|---|
| `rstack:implementer` | Writes code for one brief, test-first, reports with evidence | all |
| `rstack:explorer` | Read-only research, saves cited notes | read + notes |
| `rstack:reviewer` | One review axis, or arena judge | read-only |
| `rstack:adversary` | Breaks a diff in its own worktree | all, own worktree |
| `rstack:merger` | Merges a reviewed ticket into integration, runs checks | read + git |

## Repo state

```
GLOSSARY.md                 shared language (committed)
docs/adr/                   decisions (committed)
.work/
  config.md                 commands, tracker, models, parallelism
  lessons.md                distilled lessons, read at the start of every run
  outcomes.jsonl            one line per finished playbook/ticket
  notes/                    explorer research
  <feature>/
    spec.md  board.md  decisions.tsv  handoff.md
    tickets/NN-slug.md
    briefs/NN-slug.md       what a worker was told
    reports/NN-slug.md      what a worker did, with evidence
```

## Guard hook

`hooks/guard.mjs` runs before every Bash call and blocks: force-push without lease, pushes to main/master/trunk/develop/release, hard reset onto the base branch, recursive deletes of root/home/cwd, `gh pr merge` and releases, destructive DB and infra commands, and reading `.env`/keys into the transcript. It's the "always pause" list as structure instead of prose. Escape hatch: `RSTACK_GUARD_OFF=1`.

## Make it yours

- Models per role live in `.work/config.md`.
- Add a playbook: drop a file in `skills/build/playbooks/` and a row in the table in `skills/build/SKILL.md`.
- When you catch yourself writing the same instruction twice, `/rstack:retro` should turn it into a check, not more prose.

## Credits

Ideas and structure adapted from pstack (MIT, © 2026 Lauren Tan), mattpocock/skills (MIT, © Matt Pocock), and CLI Agent Orchestrator (Apache-2.0, © Amazon.com, Inc.). See `NOTICE`. All text here is rewritten, not copied.
