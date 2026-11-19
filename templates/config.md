# rstack config

<!-- Written by /rstack:setup. Every rstack skill and agent reads this file. Edit freely. -->

## Repo
- base_branch: main
- stack: <e.g. .NET 9 + React/TS>

## Checks
<!-- One command per line. CI is the source of truth for "green". -->
- build: <dotnet build | npm run build>
- typecheck: <n/a | npx tsc --noEmit>
- lint: <dotnet format --verify-no-changes | npm run lint>
- test_all: <dotnet test | npm test>
- test_one: <dotnet test --filter "FullyQualifiedName~{name}" | npx vitest run {path}>
- pre_existing_red: <none | list checks already failing on base>

## Work tracking
- tracker: local            # local | github
- work_dir: .work           # specs, tickets, briefs, reports, outcomes
- work_dir_committed: false
- glossary: GLOSSARY.md
- adr_dir: docs/adr

## Orchestration
- max_parallel_implementers: 3
- worktree_root: ../{repo}-wt  # one git worktree per ticket
- open_prs_without_asking: true
- pr_style: ready            # never draft

## Models (Claude Code Agent tool values)
<!-- Roles map to model + effort. "inherit" = session model. -->
- implementer: opus high
- implementer_hard: opus xhigh
- reviewer: opus high
- adversary: opus high
- explorer: sonnet medium
- mechanical: sonnet low
- second_opinion: fable high   # used only for arena/interrogate seats, or after two failed opus runs

## Standards sources
- CLAUDE.md
- <CODING_STANDARDS.md | CONTRIBUTING.md | .editorconfig>
