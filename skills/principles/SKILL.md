---
name: principles
description: rstack's engineering principles index (when each applies and the rule). Load at the start of any build, run-spec, or review, and when making a design, testing, debugging, or delegation decision.
---

# Principles

Name each principle that changed a decision, and what it changed. Don't cite one you didn't apply.

## Core

| Principle | Applies when | Rule |
|---|---|---|
| **Laziness protocol** | Sizing a diff; tempted to add a layer | Bias to deletion and the smallest change that solves the problem. |
| **Foundational thinking** | Before writing logic | Get the data structures right and the code becomes obvious. Decide what concurrent actors share. |
| **Redesign from first principles** | Adding a requirement to an existing design | Redesign as if it had been a day-one assumption. Don't bolt it on. |
| **Attack the premise** | Two fixes sharing one premise failed the same gate | Write the premise down and test it directly before another fix. |
| **Subtract before you add** | Sequencing any addition or rewrite | Remove dead weight first, then build on the simpler base. |
| **Minimize reader load** | Code is hard to trace | Count layers between question and answer; collapse one-caller wrappers; shrink mutable scope. |
| **Outcome-oriented execution** | Planned migrations with phases | Converge on the target; don't build throwaway compatibility states. |
| **Experience first** | Scope and UX trade-offs | User delight over implementation convenience. Fewer polished features over more rough ones. |
| **Exhaust the design space** | Novel decision with no precedent | Build 2-3 competing prototypes and compare before committing. |
| **Build the lever** | Any non-trivial or repetitive work | Write the tool (codemod, script, analyzer, generator) that does or proves it. The tool is what a reviewer reruns. |

## Architecture

| Principle | Applies when | Rule |
|---|---|---|
| **Deep modules** | Designing an interface | Lots of behavior behind a small interface. Shallow pass-through modules are cost without benefit. |
| **Model the domain** | Stateful or branchy logic | Encode the domain in a structure (state machine, typed model, table/registry, reducer) instead of scattered conditionals. |
| **Shared language** | Naming anything | Use `GLOSSARY.md` terms. One concept, one name, everywhere. |
| **Boundary discipline** | Validation, errors, adapters | Guards at system boundaries (HTTP, CLI, config, DB, third-party). Trust internal types. Business logic pure. |
| **Type-system discipline** | Designing types or signatures | Illegal states unrepresentable; brand semantic primitives; parse external data at the boundary; exhaust variants; derive from the authoritative schema. |
| **Idempotent operations** | Commands, jobs, migrations, retries | Converge to the same end state regardless of partial prior runs. |
| **Migrate callers, then delete** | New internal API with old callers | Migrate and delete the old API in the same wave. |
| **Separate before serializing** | Concurrent actors might write the same file, branch, row, or key | Eliminate the sharing first. Serialize only for a real single-writer invariant. |

## Verification

| Principle | Applies when | Rule |
|---|---|---|
| **Prove it works** | Before declaring done | Verify the real artifact (run it, read the value, diff the output), not a proxy, self-report, or "it compiles". |
| **Feedback loops first** | Any code change | Types, tests, and a runnable surface are what let an agent know it's right. No loop, no confidence. |
| **Fix root causes** | Debugging | Fix at the first place the system went wrong. A guard is a fix only if the state is legitimate. |
| **Sequence verifiable units** | Multi-step work; stacking commits/PRs | Small units, each ending in a check; verify before the next; order so history proves itself. |
| **Test behavior, not implementation** | Writing or keeping a test | Assert what users of the code observe. |
| **Explain the number** | Trusting or reporting a measurement | Find what limits it; rule out that it measured something else. |

## Delegation

| Principle | Applies when | Rule |
|---|---|---|
| **Guard the context window** | Large outputs, long files, fan-out | Bulk goes to subagents; summaries stay in the main thread. |
| **Never block on the human** | Tempted to ask about reversible work | Proceed, show the result, let them course-correct. Ask only for irreversible actions and real product/preference decisions. |
| **Fresh context per task** | Retries, fix rounds, next ticket | New subagent with the original brief and prior report, not a resumed one. |
| **Review separation** | Any code a worker wrote | The author doesn't approve its own work. |

## Meta

| Principle | Applies when | Rule |
|---|---|---|
| **Encode lessons in structure** | Writing the same instruction a second time | Make it a lint rule, analyzer, test, hook, or script instead of more prose. |
| **Small steps** | Planning | Tracer bullets: thin end-to-end slices that give feedback fast. |
| **Care about design** | Every few days on an active codebase | Survey for deepening opportunities (shallow modules, leaky boundaries) before they become a ball of mud. |
