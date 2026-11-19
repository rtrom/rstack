---
name: pickup
description: Resume or take over in-flight work from a handoff, a branch, or a prior session transcript without redoing it. Use at the start of a session that continues earlier work.
disable-model-invocation: true
argument-hint: "[feature-slug | handoff path | branch]"
---

# Pickup

The prior trail is authoritative input. Read it, don't re-derive it.

1. **Locate the trail.** In order: a `handoff.md` under `.work/`, the feature's `board.md` and `decisions.tsv`, the branch history, then this workspace's Claude Code transcripts (`~/.claude/projects/<workspace-slug>/*.jsonl`, newest first; only this workspace's folder). Parse a long transcript in an `rstack:explorer` subagent and keep only the reduced timeline here.
2. **Reconstruct state.** Branch and worktrees (`git worktree list`), what landed (`git log`, `git diff <base>...`), open tickets, decisions made.
3. **Diff done vs pending.** Name the resume point. Don't rerun completed repros or redo finished work. A "let me verify everything from scratch" pass treats the trail as untrustworthy when it's authoritative.
4. **Verify inherited claims that the remaining work depends on** against the real artifact, once. A prior self-report is not proof.
5. **Route** the rest to the matching `/rstack:build` playbook or `/rstack:run-spec`.

Reply: where the prior session stopped, what you inherited vs redid (ideally nothing redone), the resume point, and what you're doing next.
