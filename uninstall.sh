#!/usr/bin/env bash
# BOTSPEAK uninstaller
# removes skills from all detected agents
# note: always-on rules must be removed manually (see below)

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
remove_skills_for "Cursor"      "$HOME/.cursor/skills-cursor"
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

cat <<'DONE'

done.

⚠  always-on rule: not auto-removed (rules are installed manually per IDE).
   Remove it yourself from wherever you put it:

   Cursor (project)  →  .cursor/rules/botspeak-always-on.mdc
   Cursor (global)   →  Cursor Settings → Rules → User Rules
   Claude Code       →  your CLAUDE.md or ~/.claude/CLAUDE.md
   Windsurf          →  .windsurf/rules/botspeak-always-on.md
   Cline             →  .clinerules/botspeak-always-on.md
   Copilot           →  .github/copilot-instructions.md
   Codex / generic   →  AGENTS.md

DONE
