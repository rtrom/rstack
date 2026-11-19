#!/usr/bin/env bash
# rstack installer (macOS, Linux, Git Bash on Windows)
#
#   ./install.sh               plugin install via the claude CLI; falls back to --copy
#   ./install.sh --plugin      plugin install only (fails if the claude CLI is missing)
#   ./install.sh --copy        copy skills, agents, and the guard hook into ~/.claude
#   ./install.sh --uninstall   remove a --copy install
#
# Run from a clone, or pipe it (public repo only):
#   curl -fsSL https://raw.githubusercontent.com/rtrom/rstack/main/install.sh | bash
set -euo pipefail

REPO="${RSTACK_REPO:-rtrom/rstack}"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
MODE="${1:-auto}"

say()  { printf '\033[1m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# Locate the plugin source: this script's folder if it's a clone, else a temp clone.
src_dir() {
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  if [[ -n "$here" && -f "$here/.claude-plugin/plugin.json" ]]; then
    echo "$here"; return
  fi
  command -v git >/dev/null || die "git is required to fetch $REPO"
  local tmp; tmp="$(mktemp -d)"
  git clone --depth 1 -q "https://github.com/$REPO.git" "$tmp/rstack" \
    || die "could not clone $REPO (private repo? clone it yourself and run ./install.sh)"
  echo "$tmp/rstack"
}

install_plugin() {
  command -v claude >/dev/null || return 1
  say "Installing with the claude CLI"
  local target="$REPO"
  # From a clone, register the local folder so unpushed edits install too.
  local here; here="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)"
  [[ -n "$here" && -f "$here/.claude-plugin/marketplace.json" ]] && target="$here"
  claude plugin marketplace add "$target" || claude plugin marketplace update rstack || return 1
  claude plugin install rstack@rstack || return 1
  say "Installed. Skills are namespaced: /rstack:setup, /rstack:build, ..."
}

install_copy() {
  command -v node >/dev/null || die "node is required for the guard hook (Claude Code ships with it)"
  local src
  src="$(src_dir)" || exit 1
  say "Copying rstack into $CLAUDE_DIR (skills and agents get an rstack- prefix)"
  mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks"

  # Plugin names (/rstack:build, rstack:implementer) become rstack-build, rstack-implementer.
  local rewrite='s/rstack:/rstack-/g'

  for d in "$src"/skills/*/; do
    local name dest; name="$(basename "$d")"; dest="$CLAUDE_DIR/skills/rstack-$name"
    rm -rf "$dest"; cp -R "$d" "$dest"
    find "$dest" -name '*.md' -print0 | while IFS= read -r -d '' f; do
      sed -i.bak -e "$rewrite" -e "s/^name: $name\$/name: rstack-$name/" "$f" && rm -f "$f.bak"
    done
  done

  for f in "$src"/agents/*.md; do
    local name dest; name="$(basename "$f" .md)"; dest="$CLAUDE_DIR/agents/rstack-$name.md"
    sed -e "$rewrite" -e "s/^name: $name\$/name: rstack-$name/" "$f" > "$dest"
  done

  cp "$src/hooks/guard.mjs" "$CLAUDE_DIR/hooks/rstack-guard.mjs"
  node "$src/hooks/settings-merge.mjs" add "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/hooks/rstack-guard.mjs"

  say "Installed. Skills are /rstack-setup, /rstack-build, ... Restart Claude Code to load them."
}

uninstall_copy() {
  say "Removing the --copy install from $CLAUDE_DIR"
  rm -rf "$CLAUDE_DIR"/skills/rstack-* "$CLAUDE_DIR"/agents/rstack-*.md "$CLAUDE_DIR/hooks/rstack-guard.mjs"
  local src
  src="$(src_dir)" || exit 1
  [[ -f "$CLAUDE_DIR/settings.json" ]] && node "$src/hooks/settings-merge.mjs" remove "$CLAUDE_DIR/settings.json"
  say "Done. A plugin install is removed with: claude plugin uninstall rstack@rstack"
}

case "$MODE" in
  auto)        install_plugin || { warn "claude CLI unavailable or plugin install failed; using --copy"; install_copy; } ;;
  --plugin)    install_plugin || die "plugin install failed (is the claude CLI on PATH?)" ;;
  --copy)      install_copy ;;
  --uninstall) uninstall_copy ;;
  -h|--help)   sed -n '2,11p' "$0" ;;
  *)           die "unknown option: $MODE (try --help)" ;;
esac

echo
say "Next: open a repo in Claude Code and run setup once."
