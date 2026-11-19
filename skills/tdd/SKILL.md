---
name: tdd
description: Test-driven development at agreed seams, one vertical slice at a time. Use when building a feature or fixing a bug with a cheap local test path, or when the user mentions TDD, red-green, or integration tests.
---

# TDD

Red → green, one slice at a time, at seams that were agreed in advance. Read `.work/config.md` for `test_one` and `test_all`, and `GLOSSARY.md` so test names use the domain's words.

## Seams

A seam is the public boundary where you observe behavior without reaching inside. **Test only at agreed seams**: those in the spec or ticket. If none were agreed, propose them (each with one line on what it catches and misses) and confirm before writing tests. In an unattended run, pick the highest public seam, log the choice in `decisions.tsv`, and proceed.

## The loop

1. **Red.** Write one failing test at the seam for the next smallest behavior. Run it with `test_one`. Watch it fail *for the right reason* (assertion, not a compile error or missing fixture).
2. **Green.** Write only enough code to pass. No speculative features, no anticipating the next test.
3. Run `test_one` until green, then typecheck/build.
4. Commit. Next slice.

Run `test_all` at the end, and whenever a change touches shared code.

Refactoring is not part of the loop. It happens in review.

## What a good test is

Asserts what the code's users can observe through the public interface. It fails when that behavior breaks and keeps passing when only internals change. Reads like a spec: `Checkout_succeeds_with_valid_cart`, `rejects an expired token`.

## Anti-patterns

- **Implementation-coupled:** mocks internal collaborators, tests private methods, or verifies through a side channel (querying the DB instead of the API). Tell: it breaks on a refactor with no behavior change. Mock only at system boundaries (network, clock, filesystem, third-party APIs).
- **Tautological:** the expected value is computed the same way the code computes it (`Assert.Equal(a + b, Add(a, b))`). Expected values come from an independent source: a literal, a worked example, the spec.
- **Horizontal slicing:** all tests first, then all code. It tests imagined behavior. One test, one implementation, repeat.
- **Snapshot sprawl:** large snapshots nobody reads. Assert the specific property that matters.

## Bugs

The failing test reproduces the user's exact symptom and lands in history *before* the fix commit.
