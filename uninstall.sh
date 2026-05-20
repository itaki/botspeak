#!/usr/bin/env bash
# BOTSPEAK uninstaller
# - removes skills from all detected agents
# - strips the managed always-on rule block from ~/.claude/CLAUDE.md
# - manually-installed per-IDE rules are listed at the end for cleanup

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ok()    { echo -e "  ${GREEN}✓${RESET} $1"; }
skip()  { echo -e "  ${YELLOW}-${RESET} $1 (not found)"; }
header(){ echo -e "\n${GREEN}$1${RESET}"; }

remove_skill_dir() {
  local dir="$1"
  local label="$2"
  if [ -d "$dir" ]; then
    rm -rf "$dir"
    ok "removed $label"
  else
    skip "$label"
  fi
}

remove_skills_for() {
  local label="$1"
  local target_dir="$2"
  local found=0
  if [ -d "$target_dir/botspeak" ] || [ -d "$target_dir/botspeak-translate" ]; then
    remove_skill_dir "$target_dir/botspeak"           "$label → botspeak"
    remove_skill_dir "$target_dir/botspeak-translate" "$label → botspeak-translate"
    found=1
  fi
  if [ $found -eq 0 ]; then
    skip "$label"
  fi
}

cat <<'BANNER'
┌─────────────────────────────────────────┐
│   BOTSPEAK — uninstalling skills        │
└─────────────────────────────────────────┘
BANNER

header "Skills"
remove_skills_for "Claude Code" "$HOME/.claude/skills"
remove_skills_for "Cursor"      "$HOME/.cursor/skills"
# Also clean up any legacy install in the wrong path (~/.cursor/skills-cursor/),
# which earlier installer versions used by mistake.
remove_skills_for "Cursor (legacy path)" "$HOME/.cursor/skills-cursor"
if command -v codex >/dev/null 2>&1; then
  remove_skills_for "Codex" "$HOME/.codex/skills"
else
  skip "Codex"
fi
if command -v gemini >/dev/null 2>&1; then
  echo ""
  echo -e "  ${GREEN}→ Gemini CLI detected${RESET}"
  if gemini extensions list 2>/dev/null | grep -qi "botspeak"; then
    gemini extensions uninstall botspeak 2>/dev/null && ok "botspeak → gemini extensions removed"
  else
    skip "Gemini (botspeak extension not found)"
  fi
else
  skip "Gemini CLI"
fi
remove_skills_for "Generic (~/.agents)" "$HOME/.agents/skills"

# Remove the always-on rule block install.sh injected into Claude's global CLAUDE.md.
remove_claude_global_rule() {
  local target="$HOME/.claude/CLAUDE.md"
  local start_marker='<!-- BOTSPEAK-ALWAYS-ON:START - managed by install.sh -->'
  local end_marker='<!-- BOTSPEAK-ALWAYS-ON:END -->'
  if [ ! -f "$target" ]; then
    skip "Claude global rule (~/.claude/CLAUDE.md not present)"
    return
  fi
  if ! grep -qF "$start_marker" "$target"; then
    skip "Claude global rule (no managed block found in CLAUDE.md)"
    return
  fi
  if ! grep -qF "$end_marker" "$target"; then
    echo -e "  ${YELLOW}!${RESET} Claude global rule: START marker present but END marker missing in $target"
    echo "    Refusing to strip (would truncate the file). Manually restore the"
    echo "    END marker ($end_marker) and re-run, or remove the block by hand."
    return
  fi
  local tmp
  tmp="$(mktemp)"
  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { in_block=1; next }
    $0 == end   { in_block=0; next }
    !in_block   { print }
  ' "$target" > "$tmp"
  mv "$tmp" "$target"
  ok "removed managed block from $target"
}

header "Always-on rule (global)"
remove_claude_global_rule

cat <<'DONE'

done.

⚠  per-project / manually-installed rules are not auto-removed.
   Remove them yourself from wherever you put them:

   Cursor (project)  →  .cursor/rules/botspeak-always-on.mdc
   Cursor (global)   →  Cursor Settings → Rules → User Rules
   Windsurf          →  .windsurf/rules/botspeak-always-on.md
   Cline             →  .clinerules/botspeak-always-on.md
   Copilot           →  .github/copilot-instructions.md
   Codex / generic   →  AGENTS.md

DONE
