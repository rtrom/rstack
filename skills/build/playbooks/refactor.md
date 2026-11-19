# Refactor

Behavior-preserving. If behavior changes, it's a feature or a fix; split it out.

1. Pin current behavior. Find the tests that cover the area at its seams. If coverage is thin, add characterization tests at the public seam first, in their own commit.
2. Subtract before you add: delete dead code, redundant validators, and one-caller wrappers first, then reshape the simpler base.
3. **Build the lever:** for anything repetitive (renames, API migrations, call-site rewrites), write the codemod/script/Roslyn fixer/regex pass and commit it, so a reviewer can rerun it. Don't hand-edit 40 files.
4. Wide blast radius → expand, migrate in batches, contract (see the **tickets** skill). Migrate callers and delete the legacy API in the same wave; no lingering compatibility layers.
5. Each step ends green: build, typecheck, tests. Commit per step.
6. Verify behavior unchanged: same test results, and where it matters, same output on a recorded input (differential check).
7. `/rstack:review`, `/rstack:pr`. Append the outcome record.
