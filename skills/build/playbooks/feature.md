# Feature

You own the design. Plan, review, verify. Delegate implementation.

1. Trace the affected subsystem (delegate to `rstack:explorer` if it's large).
2. **architect** the shape: data shape, signatures, module boundaries. Encode the domain in a structure (state machine over scattered booleans, table/registry over branching, typed model over repeated shape assumptions).
3. Write the throughput checkpoint as four todo items (blocking first steps, independent workstreams, shared mutable state, smallest safe decomposition). Non-applicable items stay with `n/a: <reason>`.
4. Delegate code to a fresh `rstack:implementer` with: goal, file scope, the named data shape, the seams, the check commands, success criteria. When several shapes are valid (error handling, layering, test structure), use **arena** instead so alternatives surface and a cross-judge guards the pick. Even for small features, keep review separation: the agent that wrote it doesn't approve it.
5. Verify on the matching surface (run the app, hit the endpoint, drive the UI). Wrong surface is not a pass.
6. Rebase into small ordered commits, each building and passing its own checks.
7. Contested design → `/rstack:review adversarial`. Otherwise `/rstack:review`.
8. `/rstack:pr`. Append the outcome record.

Code-coupled work goes to one owner who fans out internally after the blocking phase. Parent-level fan-out is for slices that produce independent artifacts.

Reply: what you built, what you chose and why (table for alternatives), the checkpoint, open decisions.
