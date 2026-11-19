// rstack guard: blocks irreversible Bash commands before they run.
// Exit code 2 blocks the tool call and shows stderr to the agent.
// Encodes the "always pause" list as structure instead of prose.
import { readFileSync } from "node:fs";

let input;
try {
  input = JSON.parse(readFileSync(0, "utf8"));
} catch {
  process.exit(0); // never break the session on malformed input
}

const cmd = String(input?.tool_input?.command ?? "");
const PROTECTED = "(main|master|trunk|develop|release[\\w/.-]*)";

const rules = [
  [new RegExp(`git\\s+push\\b[^\\n]*(--force(?!-with-lease)|\\s-f\\b)`), "Force-push is irreversible. Use --force-with-lease on your own branch, or ask the operator."],
  [new RegExp(`git\\s+push\\b[^\\n]*(\\s|:)${PROTECTED}(\\s|$)`), "Pushing directly to a protected branch. Open a PR instead."],
  [/git\s+reset\s+--hard\s+(origin\/)?(main|master)\b/, "Hard reset onto the base branch discards work. Ask the operator."],
  [/git\s+branch\s+-D\s+(main|master)\b/, "Deleting the base branch."],
  [/\brm\s+-[a-zA-Z]*r[a-zA-Z]*f?[a-zA-Z]*\s+(\/|~|\$HOME|\.\s*$|\*)(\s|$)/, "Recursive delete of a root, home, or whole working directory."],
  [/\b(gh\s+pr\s+merge|gh\s+release\s+create)\b/, "Merging or releasing is an operator decision."],
  [/\b(dotnet\s+ef\s+database\s+drop|DROP\s+(DATABASE|TABLE)|TRUNCATE\s+TABLE)\b/i, "Destructive database operation."],
  [/\b(terraform\s+(apply|destroy)|kubectl\s+delete|az\s+group\s+delete|aws\s+\S+\s+delete-)/, "Infrastructure change or deletion. Ask the operator."],
  [/(cat|less|more|head|tail|type)\s+[^|;&]*(\.env\b|id_rsa|\.pem\b|credentials\b)/, "Reading secrets into the transcript."],
];

if (process.env.RSTACK_GUARD_OFF === "1") process.exit(0);

for (const [re, reason] of rules) {
  if (re.test(cmd)) {
    process.stderr.write(`rstack guard blocked this command: ${reason}\nCommand: ${cmd}\nIf the operator explicitly approved it, they can run it themselves or set RSTACK_GUARD_OFF=1.\n`);
    process.exit(2);
  }
}
process.exit(0);
