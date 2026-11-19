// Adds or removes rstack's guard hook in a Claude Code settings.json, used by
// the --copy installers. Idempotent, keeps every other setting, and writes a
// .bak before changing an existing file.
//   node settings-merge.mjs add    <settings.json> <guard.mjs path>
//   node settings-merge.mjs remove <settings.json>
import { existsSync, readFileSync, writeFileSync, copyFileSync, mkdirSync } from "node:fs";
import { dirname } from "node:path";

const [, , action, file, guardPath] = process.argv;
const MARK = "rstack-guard.mjs";

let settings = {};
if (existsSync(file)) {
  const raw = readFileSync(file, "utf8").trim();
  if (raw) {
    try { settings = JSON.parse(raw); }
    catch { console.error(`!! ${file} is not valid JSON; not touching it. Add the hook by hand.`); process.exit(1); }
  }
}

const pre = (settings.hooks ??= {}).PreToolUse ??= [];
const isOurs = (entry) => (entry.hooks ?? []).some((h) => String(h.command ?? "").includes(MARK));
const kept = pre.filter((e) => !isOurs(e));
const changed = kept.length !== pre.length || action === "add";

if (action === "add") {
  if (!guardPath) { console.error("missing guard path"); process.exit(1); }
  kept.push({
    matcher: "Bash",
    hooks: [{ type: "command", command: `node "${guardPath.replace(/\\/g, "/")}"` }],
  });
} else if (action !== "remove") {
  console.error(`unknown action: ${action}`); process.exit(1);
}

settings.hooks.PreToolUse = kept;
if (kept.length === 0) delete settings.hooks.PreToolUse;
if (Object.keys(settings.hooks).length === 0) delete settings.hooks;

if (changed) {
  mkdirSync(dirname(file), { recursive: true });
  if (existsSync(file)) copyFileSync(file, `${file}.bak`);
  writeFileSync(file, JSON.stringify(settings, null, 2) + "\n");
  console.log(`==> ${action === "add" ? "Added" : "Removed"} rstack guard hook in ${file}`);
}
