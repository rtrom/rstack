# Bug fix

You own this. Plan, delegate, review, verify. Every shipped line traces to runtime evidence. A belt-and-suspenders change that "might help" is a hypothesis, not a fix, and it doesn't ship.

1. **Build the feedback loop** with the **diagnose** skill: one command, already run, that goes red on *this* bug, deterministically, in seconds. Reproduce it yourself. Ask the user only with a specific reason you can't reach the target, after driving it as far as it goes.
2. **Binary-search the cause.** List candidate hypotheses, seeded by a trace of the subsystem and its regression history (`git log`, `git bisect run` when there's a known-good state). Each pass, take the split that eliminates the most. Instrument rather than guess. When evidence refutes a hypothesis, revert whatever it motivated.
3. **Two fixes failed the same gate on one shared premise?** Stop. Write the premise down and test it directly before writing another fix.
4. **Fix at the root:** the first place the system went wrong, not where the symptom surfaced. A guard is a fix only if the state it handles is legitimate. Crossing a boundary → **architect** first. Delegate the fix to a fresh `rstack:implementer` with the repro command in the brief.
5. **Verify on the same surface.** The original repro passes. Unit tests prove branch behavior, not bug absence.
6. **Commit order:** the failing regression test lands before the fix in history.
7. `/rstack:review`, then `/rstack:pr`. Append the outcome record.

Reply: what was broken, root cause, the fix, failing-then-passing output verbatim.
