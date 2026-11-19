---
name: run-spec
description: Supervisor mode. Implements a whole ticket graph on one integration branch, running fresh implementer subagents in parallel worktrees across the ready frontier, with review gating every merge. CAO's supervisor/worker model inside Claude Code.
disable-model-invocation: true
argument-hint: "<feature-slug>"
---

# Run spec

You are the **supervisor**. You coordinate; you don't write feature code. Workers implement, reviewers judge, a merger integrates. All communication flows through you, and through files.

Read `.work/config.md`, `.work/<feature>/spec.md`, every ticket, and `board.md`. Run `rstack:review`, `rstack:pr`, and `rstack:handoff` through the Skill tool when a step calls for them. Read `.work/lessons.md` if present. Load the **principles** skill.

## Rules (from CAO's supervisor protocol)

1. **Never write feature code yourself.** Exception: a one-line, fully specified fix (a version bump, a typo in a test name) where delegating costs more than it saves. Say when you use it.
2. **Every brief is a file** at `.work/<feature>/briefs/<id>.md`. Workers get its absolute path, not a pasted copy.
3. **Every worker report is a file** at `.work/<feature>/reports/<id>.md`, and the worker's final message names its absolute path and the branch head SHA. A "done" message without a SHA and evidence is a gap, not a pass.
4. **Absolute paths everywhere.** Briefs point at the main checkout's `.work/` by absolute path, because worktrees don't contain gitignored files.
5. **Async vs blocking.** Implementers run in the background (CAO's `assign`): dispatch the whole frontier in one message, then end your turn and wait for completion notifications. Reviews and merges you need before deciding run in the foreground (CAO's `handoff`). Never poll with `sleep`.
6. **Every piece of new or revised code is reviewed before it merges.**

## Steps

1. **Frame.** Restate the spec's goal. Compute the frontier: tickets whose blockers are all `done`. Re-read the throughput checkpoint; tickets that write the same shared state (migrations, DI registration, lockfiles, a shared enum) don't run concurrently unless you split the shared target first.
2. **Explore once (optional).** If tickets need shared context, one `rstack:explorer` writes `.work/notes/<feature>/*.md`. Every later brief points there so implementers don't re-explore.
3. **Integration branch.** `git switch -c <feature>/integration <base>` and push it if there's a remote.
4. **Dispatch the frontier**, up to `max_parallel_implementers`. Per ticket:
   - `git worktree add <worktree_root>/<feature>-NN -b <feature>/NN-<slug> <feature>/integration`
   - write the brief (goal, ticket path, spec path, notes path, seam, check commands, worktree path, branch, report path);
   - spawn a fresh `rstack:implementer` (background) with the brief's absolute path and the model from config;
   - mark `in-progress` with owner and branch in `board.md`.
5. **On each completion:**
   - Read the report and the diff (`git -C <worktree> diff <feature>/integration...HEAD`). Rerun the ticket's checks yourself in the worktree.
   - Spawn `rstack:reviewer` (foreground) on that diff with the ticket as the spec.
   - Findings → a **fresh** implementer in the same worktree, with the original brief, the review report, and the prior report. Re-review. Two failed rounds on the same finding → stop and reframe the ticket (its premise is probably wrong) instead of a third attempt.
   - Pass → spawn `rstack:merger` (foreground) to merge the ticket branch into the integration branch and run the full checks there. Mark `done`, append the outcome record, remove the worktree.
   - Recompute the frontier and dispatch newly unblocked tickets immediately. Keep the pipeline full.
6. **Whole-branch review.** When every ticket is `done`, run `/rstack:review` on `<feature>/integration` against the spec (both axes). If the design was contested, add `adversarial`. Fix everything in one fresh implementer, re-review.
7. **Ship.** `/rstack:pr` from the integration branch, closing the spec and tickets. Don't merge to base unless told to.
8. **Clean up** remaining worktrees (`git worktree prune`). Write `/rstack:handoff` if anything is left open.

## Failure handling

- A worker drops out or returns nothing: respawn once with the same brief. Second miss → mark `blocked` with the reason and keep the rest of the graph moving.
- A ticket turns out to be mis-sliced (can't land green alone): stop dispatching its dependents, re-slice with the user if it changes scope, otherwise re-slice and note it in `decisions.tsv`.
- Merge conflict at integration: the merger reports it. Resolve with a fresh implementer whose brief names both tickets, never by discarding either side.

## Reply (each check-in)

The board as a table (ticket, status, owner, branch, review state), what changed since the last check-in, blocked items with reasons, and decisions waiting on the user.
