# Investigation

Read-only. Answer the question; change nothing.

1. Restate the question and what a complete answer looks like.
2. Fan out `rstack:explorer` subagents across independent slices (one per subsystem, or one for code and one for history). Each saves notes to `.work/notes/<topic>.md` and returns a short summary with file:line citations.
3. For "why is it like this", read the record, not just the code: `git log -L`, `git blame`, the PRs and issues that introduced and later changed it (`gh pr view`). Quote what authors wrote. Mark your own inferences.
4. Verify any claim you can cheaply run (a query, a test, a script) instead of asserting it.
5. Reply: the answer first, then the evidence (file:line, commits, command output), then what the record doesn't answer.
