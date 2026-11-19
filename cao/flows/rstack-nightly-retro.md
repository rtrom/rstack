---
name: rstack-nightly-retro
schedule: "17 22 * * 1-5"   # 10:17pm weeknights
agent_profile: rstack_implementer
provider: claude_code
---

<!-- Flows have no working-directory field; the session starts wherever
     cao-server runs. Replace the path below before `cao schedule add`. -->

First, `cd <ABSOLUTE_REPO_PATH>`.

Then run `/rstack:retro week` in that repository.

This is unattended. Do not ask questions. Do not edit CLAUDE.md, skills,
checks, or `.work/lessons.md`: promotion needs the operator's approval.
Write the ranked findings to `.work/retro-<today's date>.md` and finish
with that file's absolute path.
