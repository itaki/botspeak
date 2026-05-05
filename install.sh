#!/usr/bin/env bash
# BOTSPEAK installer
# installs the botspeak + translate-botspeak skills into all detected agents

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
AGENT_DEF="$REPO_DIR/agents/botspeak-translator.md"
CURSOR_RULE="$REPO_DIR/.cursor/rules/botspeak.mdc"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

ok()    { echo -e "  ${GREEN}✓${RESET} $1"; }
skip()  { echo -e "  ${YELLOW}-${RESET} $1 (not detected)"; }
header(){ echo -e "\n${GREEN}$1${RESET}"; }

install_skill() {
  local agent_skills_dir="$1"
  local skill_dir_name="$2"
  local source_skill="$3"
  if [ -d "$(dirname "$agent_skills_dir")" ]; then
    mkdir -p "$agent_skills_dir/$skill_dir_name"
    ln -sf "$source_skill" "$agent_skills_dir/$skill_dir_name/SKILL.md"
    ok "$skill_dir_name → $agent_skills_dir"
    return 0
  fi
  return 1
}

install_skills_for() {
  local label="$1"
  local target_dir="$2"
  local installed=0
  install_skill "$target_dir" "botspeak"           "$SKILLS_DIR/botspeak/SKILL.md"   && installed=1
  install_skill "$target_dir" "capture-botspeak"   "$SKILLS_DIR/capture/SKILL.md"   && installed=1
  install_skill "$target_dir" "translate-botspeak" "$SKILLS_DIR/translate/SKILL.md" && installed=1
  if [ $installed -eq 0 ]; then
    skip "$label"
  fi
}

cat <<'BANNER'
┌─────────────────────────────────────────┐
│   BOTSPEAK — bots talking to bots        │
│   installing skills · rule · agent      │
└─────────────────────────────────────────┘
BANNER

header "Skills"
install_skills_for "Claude Code" "$HOME/.claude/skills"
install_skills_for "Cursor"      "$HOME/.cursor/skills"
install_skills_for "Codex"       "$HOME/.codex/skills"
install_skills_for "Gemini CLI"  "$HOME/.gemini/skills"
install_skills_for "Generic (~/.agents)" "$HOME/.agents/skills"

header "Cursor rule (project-local, always-on)"
if [ -d ".cursor" ] || [ -f ".cursor/rules/.gitkeep" ] || [ -d "$PWD" ]; then
  if [ "$PWD" != "$REPO_DIR" ]; then
    mkdir -p "$PWD/.cursor/rules"
    cp "$CURSOR_RULE" "$PWD/.cursor/rules/botspeak.mdc"
    ok "botspeak.mdc → $PWD/.cursor/rules/"
  else
    skip "skipping rule install in BOTSPEAK repo itself"
  fi
fi

header "Agent definition"
ok "available at: $AGENT_DEF"
ok "import into your agent system as needed"

cat <<'DONE'

done.

triggers:
  /botspeak           - compress an existing AI-facing doc into BOTSPEAK
  /capture-botspeak   - capture messy chat input as a focused BOTSPEAK doc
  /translate-botspeak - render BOTSPEAK back to human prose (audit safety net)

or just say:
  "botspeak this"
  "capture this as a handoff"
  "translate this for me"

reference: SPEC.md, examples/, README.md

DONE
