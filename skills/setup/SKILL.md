---
name: setup
description: Configure rstack for the current repo. Detects build/test/lint commands, tracker, base branch, and writes .work/config.md. Run once per repo, and again when the toolchain changes.
disable-model-invocation: true
---

# rstack setup

Goal: every other rstack skill reads one file, `.work/config.md`, instead of guessing how this repo builds, tests, and tracks work.

## Steps

1. **Detect, don't ask.** Inspect the repo and fill in what you can find yourself:
   - Base branch: `git symbolic-ref refs/remotes/origin/HEAD` or fall back to `main`/`master`.
   - Stack and check commands. Look for `*.sln`/`*.csproj` (→ `dotnet build`, `dotnet test`, `dotnet format --verify-no-changes`), `package.json` scripts (`typecheck`/`tsc`, `test`, `lint`), `pyproject.toml`, `Cargo.toml`, `go.mod`, a `Makefile`, and CI workflow files. CI is the source of truth for what "green" means; prefer its commands.
   - Fastest single-test command (e.g. `dotnet test --filter "FullyQualifiedName~X"`, `npx vitest run path`). TDD loops depend on this being fast.
   - Run each detected command once. Record which pass on the current base. A check that is already red on base is noted as `pre-existing-red`, not silently dropped.
   - Tracker: `gh auth status` succeeding and a GitHub remote → offer `github`. Otherwise `local`.
   - Existing `GLOSSARY.md`, `docs/adr/`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `CLAUDE.md`.
2. **Ask only for decisions** (one round, recommended answer marked): tracker (`local` vs `github`), whether `.work/` is committed or gitignored, max parallel implementers (default 3), and whether the agent may open PRs without asking (default yes, ready-for-review, never draft).
3. Write `.work/config.md` from the plugin's `templates/config.md` (two levels above this skill's base directory, which Claude Code shows when the skill loads). Overwrite the whole file.
4. If `.work/` should be ignored, add `.work/` to `.gitignore`, but keep `GLOSSARY.md` and `docs/adr/` committed. Those are shared language, not scratch.
5. If the repo has no guardrail (no CI job and no pre-commit hook running its checks), say so as the first finding. An unguarded repo makes every agent run less trustworthy.
6. Append a short `## rstack` section to the repo's `CLAUDE.md` (create it if missing) that points at `.work/config.md`, `GLOSSARY.md`, and `docs/adr/`. Pointers only, no copied rules.

## Reply

A table of detected commands with pass/fail on base, the choices you made, and anything red on base.
