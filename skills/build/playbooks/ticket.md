# Ticket

One ticket from `/rstack:tickets`, done end to end.

1. Read the ticket, its spec, and the board. Confirm every blocker is `done`; if not, stop and say which.
2. Set status `in-progress` in the ticket file and `board.md`.
3. Write the brief to `.work/<feature>/briefs/NN-<slug>.md` (goal, ticket path, spec path, seam, check commands from config, branch name `<feature>/NN-<slug>`).
4. Spawn a fresh `rstack:implementer` with the brief's absolute path. It builds test-first at the ticket's seam and reports with evidence.
5. Read the diff yourself. Run the checks yourself.
6. `/rstack:review` against the ticket as the spec.
7. Findings → a fresh implementer with the original brief plus the review report. Loop until both review axes pass or only judgment calls remain that you explicitly accept.
8. Mark `done`, append the outcome record. `/rstack:pr` unless this ticket is part of a `/rstack:run-spec` integration branch.
