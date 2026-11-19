# Multi-phase

For work that spans phases, stacked PRs, or doesn't fit another playbook.

1. If the plan isn't settled, run `/rstack:grill` first. If there's no spec, `/rstack:spec`.
2. Draw the dependency graph of phases. Each phase ends in a verifiable state and is independently landable.
3. Converge on the target architecture. Don't build throwaway compatibility states just to keep intermediates smooth.
4. Per phase: `/rstack:tickets`, then `/rstack:run-spec` (parallel) or the `ticket` playbook (serial).
5. Stack PRs only when a later one truly builds on an earlier one; otherwise open independent PRs.
6. At each phase boundary: rewrite the throughput checkpoint, update `board.md`, write a `/rstack:handoff` so any agent can resume.
