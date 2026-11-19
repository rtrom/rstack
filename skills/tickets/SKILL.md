---
name: tickets
description: Break a spec into tracer-bullet tickets with blocking edges, plus a throughput checkpoint that decides what runs in parallel. Writes .work/<feature>/tickets/ and board.md, or GitHub issues.
disable-model-invocation: true
argument-hint: "<feature-slug | spec path | issue URL>"
---

# Tickets

Turn a spec into a **task graph**, not a to-do list. Read `.work/config.md` and the spec (full body and comments if it's an issue).

## 1. Prefactor first

Look for changes that make the feature easy before building it. "Make the change easy, then make the easy change." Prefactor tickets come first and block the rest.

## 2. Slice vertically

Each ticket is a **tracer bullet**:
- cuts a narrow but complete path through every layer it touches (schema, API, UI, tests);
- is demoable or verifiable on its own, against one of the spec's seams;
- fits in one fresh context window;
- declares the tickets that **block** it.

**Exception, wide refactors:** a mechanical change with a huge blast radius (rename a column, retype a shared symbol) goes expand → migrate in batches → contract. Expand adds the new form beside the old. Migrate batches (per package/project) each block on expand and keep CI green. Contract deletes the old form, blocked by every batch. Migrate callers and delete the legacy API in the same wave; don't leave compatibility shims behind.

## 3. Throughput checkpoint

Write these four items under the ticket list. A dimension that doesn't apply keeps its line with `n/a: <reason>`.

- **Blocking first steps:** what must land before any fan-out.
- **Independent workstreams:** tickets touching disjoint files, projects, or layers. These parallelize.
- **Shared mutable state:** files, migrations, DI registrations, lockfiles, or config that several tickets would write. Default to splitting the target so they don't share it. Serialize only for a real invariant.
- **Smallest safe decomposition:** if one implementer is best, say why.

## 4. Quiz the user

Show the numbered breakdown (title, blocked by, what it delivers, seam it's verified at) and the checkpoint. Ask: granularity right? edges right? merge or split anything? Iterate until approved.

## 5. Publish

**Local** (`tracker: local`): one file per ticket, `.work/<feature>/tickets/NN-<slug>.md`, numbered in dependency order:

```markdown
# NN: <title>
Status: ready | in-progress | review | done | blocked
Blocked by: <NN, NN | none>
Seam: <from spec>

## What to build
End-to-end behavior from the user's perspective.

## Acceptance criteria
- [ ] ...
```

Also write `.work/<feature>/board.md`: a table of ticket, status, blocked-by, owner, branch. `/rstack:run-spec` keeps it current.

**GitHub** (`tracker: github`): one issue per ticket in dependency order, label `ready-for-agent`, "Blocked by #N" lines (or native sub-issues/dependencies when available). Mirror the board locally anyway.

Don't close or edit the parent spec.

**Next:** `/rstack:run-spec <feature>` for the whole graph in parallel, or `/rstack:build ticket NN` for one ticket.
