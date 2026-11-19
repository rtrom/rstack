---
name: diagnose
description: Gated diagnosis loop for hard bugs and regressions. Build a red-capable feedback loop, reproduce, minimise, hypothesise, instrument, fix at the root, regression-test. Use when something is broken, throwing, failing, flaky, or slow.
---

# Diagnose

If you have a tight pass/fail signal that goes red on *this* bug, you will find the cause. If you don't, no amount of reading code will save you. Skip a phase only with a stated reason.

**Redact** secrets in every command and output you show (`<REDACTED>`). Drive loops from env vars so credentials never appear in transcripts.

## Phase 1: Build the feedback loop

Spend disproportionate effort here. In roughly this order of preference:

1. Failing test at the seam that reaches the bug.
2. HTTP script (`curl`, `.http` file) against a running dev server.
3. CLI invocation with a fixture input, diffed against a known-good output.
4. Headless browser script (Playwright) asserting on DOM, console, or network.
5. Replay a captured request, payload, or event log through the code path.
6. Throwaway harness: the smallest slice of the system that hits the path.
7. Property/fuzz loop for "sometimes wrong".
8. `git bisect run <script>` when there's a known-good state.
9. Differential: same input through old vs new, diff outputs.
10. Last resort, a human in the loop: a script that tells the human exactly what to click and captures what happened.

Tighten it: faster (narrow scope, cache setup), sharper (assert the exact symptom, not "didn't crash"), deterministic (pin time, seed RNG, isolate FS and network). For flaky bugs, raise the reproduction rate (loop 100×, parallelize, add stress) until it's debuggable.

**Gate:** you can name one command, already run (show it and its output), that is red-capable on the user's exact symptom, deterministic, fast, and agent-runnable. If you catch yourself theorizing before this exists, stop. If you truly can't build one, say what you tried and ask for access, a captured artifact, or permission to instrument.

## Phase 2: Reproduce and minimise

Confirm it's the user's failure, not a neighbor. Shrink the input and the code path until removing anything makes it pass.

## Phase 3: Hypothesise

List candidate causes. For each, the observation that would rule it out. Take the cheapest discriminating test first.

## Phase 4: Instrument

Add logging or breakpoints at the boundary between "state still correct" and "state wrong". Read values as the code runs. Bisect the gap. Remove the instrumentation afterward.

**Attack the premise:** two fixes sharing one assumption both failed? Write the assumption down and test it directly.

## Phase 5: Fix at the root

The first place the system went wrong. A guard is a fix only if the state it handles is legitimate. Smallest change the evidence justifies.

## Phase 6: Regression test

The loop from Phase 1, made permanent at the right seam, committed before the fix. Show it red on the parent commit and green on the fix.
