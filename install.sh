#!/usr/bin/env bash
# BOTSPEAK installer
# installs skills into all detected agents
# use --with-rule to also drop an always-on rule file into the current project

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
AGENT_DEF="$REPO_DIR/agents/botspeak-translator.md"
RULES_DIR="$REPO_DIR/rules"

WITH_RULE=0
for arg in "$@"; do
  case "$arg" in
    --with-rule|--all) WITH_RULE=1 ;;
  esac
done

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
  install_skill "$target_dir" "capture-botspeak"   "$SKILLS_DIR/capture/SKILL.md"    && installed=1
  install_skill "$target_dir" "translate-botspeak" "$SKILLS_DIR/translate/SKILL.md"  && installed=1
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

if [ $WITH_RULE -eq 1 ]; then
  header "Always-on rule (project-local)"

  if [ "$PWD" = "$REPO_DIR" ]; then
    skip "skipping rule install in BOTSPEAK repo itself"
  else
    # Cursor
    if [ -d ".cursor" ] || [ -d "$HOME/.cursor" ]; then
      mkdir -p "$PWD/.cursor/rules"
      cp "$RULES_DIR/cursor.mdc" "$PWD/.cursor/rules/botspeak.mdc"
      ok "Cursor → .cursor/rules/botspeak.mdc"
    fi

    # Windsurf
    if [ -d ".windsurf" ] || [ -d "$HOME/.windsurf" ]; then
      mkdir -p "$PWD/.windsurf/rules"
      cp "$RULES_DIR/botspeak.md" "$PWD/.windsurf/rules/botspeak.md"
      ok "Windsurf → .windsurf/rules/botspeak.md"
    fi

    # Cline
    if [ -d ".cline" ] || [ -d "$HOME/.cline" ]; then
      mkdir -p "$PWD/.clinerules"
      cp "$RULES_DIR/botspeak.md" "$PWD/.clinerules/botspeak.md"
      ok "Cline → .clinerules/botspeak.md"
    fi

    # GitHub Copilot (append if instructions file exists, create if not)
    if [ -d ".github" ]; then
      mkdir -p "$PWD/.github"
      if [ -f "$PWD/.github/copilot-instructions.md" ]; then
        echo "" >> "$PWD/.github/copilot-instructions.md"
        cat "$RULES_DIR/botspeak.md" >> "$PWD/.github/copilot-instructions.md"
        ok "Copilot → appended to .github/copilot-instructions.md"
      else
        cp "$RULES_DIR/botspeak.md" "$PWD/.github/copilot-instructions.md"
        ok "Copilot → .github/copilot-instructions.md"
      fi
    fi

    # AGENTS.md (universal fallback — Codex, generic agents)
    if [ ! -f "$PWD/AGENTS.md" ]; then
      cp "$RULES_DIR/botspeak.md" "$PWD/AGENTS.md"
      ok "Generic → AGENTS.md"
    else
      skip "AGENTS.md already exists (not overwriting)"
    fi

    echo ""
    echo "  No IDE detected? Copy rules/botspeak.md to your IDE's rules folder manually."
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

flags:
  --with-rule   also drop an always-on rule file into the current project
  --all         same as --with-rule

reference: SPEC.md, examples/, README.md

DONE
