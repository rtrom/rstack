---
name: arena
description: Spawn N parallel candidates at the same task in separate worktrees, cross-judge them against a rubric, pick a base, and graft the best parts of the others in. Use when one attempt would lock in the wrong shape.
argument-hint: "<task> [n=3]"
---

# Arena

Phases: Frame, Fan out, Cross-judge, Pick, Graft, Verify. Put each in the todo list first.

## Frame

Every candidate gets the same prompt, so the prompt is the contract.
1. State the artifact each candidate produces.
2. Write a rubric of 3-6 gradeable criteria for *this* task. Candidates never see it; it's for judging.
3. Runners: default three seats, `opus high`, `opus xhigh`, `fable high` (from config). Repeat one model when the work is generation-bound rather than judgment-sensitive.
4. Each candidate gets its own worktree: `git worktree add <worktree_root>/arena-<slug>-<n> -b arena/<slug>/<n>`.

## Fan out

Spawn all candidates as `rstack:implementer` in one message, background. Each brief: the task, grounding paths, its worktree, and "produce the artifact plus a short rationale naming alternatives you considered and rejected". A candidate that produces nothing → continue with N-1 and note it.

## Cross-judge

When all are done, spawn one `rstack:reviewer` with a model different from the one you're running on, given the rubric and the candidate paths (labelled A/B/C, not by model). It scores each criterion and recommends a base.

## Pick

Read every candidate end to end yourself. Score criterion by criterion, not on feel. Compare with the judge: agreement confirms; disagreement means a bias or an ambiguous rubric, so read both rationales before deciding. Ties go to the cleaner boundary and smaller API.

## Graft

Walk each loser once for what's worth porting, usually one or two things. Fold each in by hand so the result has one coherent design. Candidates converged → ship the consensus, no graft. Wildly diverged → the frame was under-specified; reframe and rerun rather than averaging.

## Verify

Prove it works like any other output. Remove the arena worktrees and branches you didn't keep.

## Output

The synthesized artifact and a note: base and why, judge verdict, each graft and its source, what was rejected, dropouts, verification result.
