"""rstack ticket loop as a durable CAO workflow.

implement -> (standards review || spec review) -> fix round(s) -> report.

Why a workflow instead of the supervisor terminal: the journal makes the loop
resumable after a crash or reboot, and each step's result is recorded.

Install and run (approval is a human act; see CAO docs/workflows.md):
    cao workflow create rstack_ticket --from-file cao/workflows/rstack_ticket.py
    cao workflow run rstack_ticket --run-id feat-x-03 \
        --input feature=feat-x --input ticket=03 \
        --input brief=/abs/path/repo/.work/feat-x/briefs/03-slug.md \
        --input worktree=/abs/path/repo-wt/feat-x-03 \
        --input work=/abs/path/repo/.work

The supervisor (or you) still creates the worktree and writes the brief first.
Merging stays with the supervisor: this workflow never touches the integration
or base branch.
"""

from __future__ import annotations

import re
from concurrent.futures import ThreadPoolExecutor

from cao_workflow import emit_output, get_inputs, step

PROVIDER = "claude_code"
MAX_FIX_ROUNDS = 2
VERDICT = re.compile(r"Verdict:\s*(pass|changes)", re.IGNORECASE)


def verdict(text: str) -> str:
    m = VERDICT.search(text or "")
    return m.group(1).lower() if m else "unknown"


def review(axis: str, feature: str, ticket: str, worktree: str, work: str, rnd: int) -> tuple[str, str]:
    report = f"{work}/{feature}/reports/{ticket}-review-{axis}-r{rnd}.md"
    h = step(
        PROVIDER,
        "rstack_reviewer",
        (
            f"Axis: {axis}. Review the diff in {worktree} against its integration branch "
            f"(three-dot diff from the merge-base). Spec: the ticket and spec referenced in "
            f"{work}/{feature}/briefs/. Write findings to {report}."
        ),
        recovery="idempotent",  # read-only; rerunning just re-reviews
        step_id=f"review-{axis}-r{rnd}",
    )
    return axis, h.output


def main() -> None:
    inputs = get_inputs()
    feature = str(inputs["feature"])
    ticket = str(inputs["ticket"])
    brief = str(inputs["brief"])
    worktree = str(inputs["worktree"])
    work = str(inputs["work"])  # absolute path to the main checkout's .work/

    impl = step(
        PROVIDER,
        "rstack_implementer",
        f"Read the brief at {brief} and build it in {worktree}. Report path is in the brief.",
        recovery="manual",  # writes commits; a blind rerun could double-apply
        step_id="implement-r0",
    )

    history = [{"round": 0, "implement": impl.output}]
    for rnd in range(MAX_FIX_ROUNDS + 1):
        with ThreadPoolExecutor(max_workers=2) as pool:
            results = dict(pool.map(
                lambda axis: review(axis, feature, ticket, worktree, work, rnd),
                ["standards", "spec"],
            ))
        verdicts = {axis: verdict(out) for axis, out in results.items()}
        history[-1]["reviews"] = verdicts

        if all(v == "pass" for v in verdicts.values()):
            emit_output({"feature": feature, "ticket": ticket, "status": "ready-to-merge",
                         "rounds": rnd, "history": history})
            return
        if rnd == MAX_FIX_ROUNDS:
            break

        fix = step(
            PROVIDER,
            "rstack_implementer",
            (
                f"Fix round {rnd + 1}. Original brief: {brief}. Work in {worktree}. "
                f"Address the findings in {work}/{feature}/reports/"
                f"{ticket}-review-*-r{rnd}.md. Judgment-call smells may be declined with a reason."
            ),
            recovery="manual",
            step_id=f"implement-r{rnd + 1}",
        )
        history.append({"round": rnd + 1, "implement": fix.output})

    emit_output({"feature": feature, "ticket": ticket, "status": "needs-reframe",
                 "reason": f"review still failing after {MAX_FIX_ROUNDS} fix rounds",
                 "history": history})


if __name__ == "__main__":
    main()
