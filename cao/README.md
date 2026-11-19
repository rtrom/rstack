# rstack on CAO

The rstack plugin already runs the supervisor/worker model inside one Claude Code session, using subagents. This folder runs the same model across **separate Claude Code processes** under [CLI Agent Orchestrator](https://github.com/awslabs/cli-agent-orchestrator).

## When to use which

| | In-session (`/rstack:run-spec`) | CAO (`rstack_supervisor`) |
|---|---|---|
| Setup | none | `cao-server`, tmux 3.3+, uv |
| Worker isolation | subagent context | full CLI process per worker, own tmux pane |
| Watch / intervene in a worker | no | yes: attach to its tmux session or the Web UI |
| Survives your terminal closing | no | yes, while `cao-server` runs |
| Mixed providers (Codex, Copilot, Kiro reviewers) | no | yes, set `provider` per profile |
| Durable resumable loops | no | yes, `cao workflow` journal |
| Scheduled runs | no | yes, `cao schedule` |
| Best for | most features, interactive work | overnight graphs, many parallel tickets, cross-vendor review |

Start in-session. Move to CAO when you want to walk away from a big ticket graph or want a different vendor in the review seats.

## Prerequisites

- rstack installed in Claude Code at **user** scope, so every CAO-launched `claude` process loads its skills, agents, and guard hook.
- Python 3.10+, `uv`, tmux 3.3+, `gh` authenticated if you use GitHub.

```bash
uv tool install git+https://github.com/awslabs/cli-agent-orchestrator.git@main --upgrade
```

## Install the profiles

```bash
cao install ./cao/profiles/rstack_supervisor.md
cao install ./cao/profiles/rstack_implementer.md
cao install ./cao/profiles/rstack_reviewer.md
cao install ./cao/profiles/rstack_adversary.md
```

## Run a ticket graph

```bash
# terminal A
cao-server

# terminal B, from the repo root, after /rstack:spec and /rstack:tickets
cao launch --agents rstack_supervisor --provider claude_code
```

Then tell the supervisor: `Run the ticket graph for feature <slug>.` Watch at `http://localhost:9889` or `tmux attach`. Stop with `cao shutdown --session <name>`.

## Permissions

CAO launches Claude Code with `--dangerously-skip-permissions` unless a profile sets `permissionMode`. rstack's guard hook still runs as a PreToolUse hook and blocks force-pushes, pushes to protected branches, PR merges, destructive DB/infra commands, and reading secrets. For a stricter setup, add `permissionMode: auto` (or `acceptEdits`) to the worker profiles.

## Durable ticket loop

`workflows/rstack_ticket.py` runs implement → parallel standards/spec review → up to two fix rounds, journaled so it resumes after a crash. It never merges. See the docstring for install and run commands; CAO requires you to approve the plan before the first run.

## Scheduled retro

`flows/rstack-nightly-retro.md` runs `/rstack:retro week` on weeknights and writes findings to `.work/` without promoting anything. Edit the repo path, then `cao schedule add cao/flows/rstack-nightly-retro.md`. `cao-server` must be running for schedules to fire.

## Optional: CAO memory and self-learning

CAO has its own outcome → lesson → promote loop (`report_outcome`, a retrospector agent, `cao memory promote`), off by default. rstack keeps the equivalent in plain files (`.work/outcomes.jsonl`, `.work/lessons.md`, `/rstack:retro`) so it works with or without CAO. Don't run both on the same repo; pick one source of truth.
