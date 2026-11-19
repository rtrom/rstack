# Autonomous run

The user is away. Don't stop for reversible decisions.

1. Write the reading of the request you're acting on at the top of `.work/<feature>/decisions.tsv` and in your first message.
2. Never call a tool that asks the user a question. Make the reversible choice, log it in `decisions.tsv`, keep going.
3. Stop only for: deploys, deleted data, force-push to shared branches, messages to people outside the run, or merging to base unless explicitly told to.
4. Flaky CI: rerun once. Fails twice → investigate as a bug, don't retry blindly.
5. Before stopping for any reason, write `/rstack:handoff` so the next session resumes cleanly.
6. Final report: what landed (PR links), what didn't and why, every decision the user may want to reverse.
