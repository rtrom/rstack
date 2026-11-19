---
name: grill
description: Relentless alignment interview before any non-trivial work. Maps the plan as a design tree and asks the whole decision frontier each round with recommended answers. Pass "docs" to also build GLOSSARY.md and ADRs as terms and decisions settle.
disable-model-invocation: true
argument-hint: "[docs] <the plan, idea, or feature>"
---

# Grill

Failure mode this prevents: *the agent didn't do what I wanted*. Nobody knows exactly what they want until they're questioned. Align first, build second.

## 0. Play it back

Before the first question, restate in your own words: the goal, the problem behind it, and the smallest change that would meet it. If your restatement is wrong, the user corrects it now, cheaply.

## 1. Build the design tree

Every decision branches into the decisions that hang off it. The **frontier** is every decision whose prerequisites are already settled, the questions you can ask *now* without guessing at answers you haven't heard.

## 2. Ask in rounds

Ask the whole frontier in one round. Number each question and give your recommended answer. Word each question so "yes" accepts your recommendation.

```
❓ **Q1 - <title>**: <question, with options if useful>

➡️ <recommended answer and the one-line reason>

---
```

Then stop and wait. A question that depends on another question still open in this round belongs to a later round.

## 3. Facts are yours, decisions are theirs

Never ask the user for something you can look up. When a frontier question needs a fact (how the code works today, what a library supports, what the tests cover), dispatch an `rstack:explorer` subagent with a fresh context and keep asking the rest of the frontier. Only the questions downstream of a running exploration wait for it.

A fork you could settle by running something cheap is not a question either. Prototype it (see the **build** skill's prototype playbook) and bring back the result.

## 4. With `docs`

Also run the **domain-modeling** skill throughout: challenge terms against `GLOSSARY.md`, sharpen fuzzy words into canonical ones, write each resolved term the moment it settles, and offer an ADR only for decisions that are hard to reverse, surprising without context, and a real trade-off.

## 5. Done

The session is done when the frontier is empty: every branch visited, nothing silently assumed. Summarize the settled decisions as a numbered list and ask the user to confirm shared understanding. Do not start building until they do.

**Next:** `/rstack:spec` turns this conversation into a spec. For a small change, go straight to `/rstack:build`.
