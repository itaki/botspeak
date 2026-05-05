#!/usr/bin/env bash
# BOTSPEAK installer
# installs skills into all detected agents
# use --with-rule to also drop an always-on rule file into the current project

set -e

GITHUB_REPO="itaki/botspeak"
RAW_BASE="https://raw.githubusercontent.com/$GITHUB_REPO/main"

# Detect local repo root — works when run as a file, falls back to empty when
# piped through bash (BASH_SOURCE[0] is empty in curl-pipe context).
_src="${BASH_SOURCE[0]:-}"
REPO_DIR=""
if [ -n "$_src" ] && [ -f "$_src" ]; then
  _d="$(cd "$(dirname "$_src")" 2>/dev/null && pwd)"
  if [ -n "$_d" ] && [ -f "$_d/install.sh" ] && [ -d "$_d/skills" ]; then
    REPO_DIR="$_d"
  fi
fi

RULES_DIR="${REPO_DIR:+$REPO_DIR/rules}"

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

# Write one SKILL.md — copy from local repo if available, else fetch from GitHub.
write_skill_file() {
  local dest="$1"        # full path to destination SKILL.md
  local repo_rel="$2"    # path relative to repo root, e.g. skills/botspeak/SKILL.md

  # Remove any existing file or dangling symlink so cp/curl can write cleanly.
  rm -f "$dest"

  if [ -n "$REPO_DIR" ] && [ -f "$REPO_DIR/$repo_rel" ]; then
    cp "$REPO_DIR/$repo_rel" "$dest"
  else
    if ! command -v curl >/dev/null 2>&1; then
      echo "  error: curl required for remote install" >&2
      return 1
    fi
    curl -fsSL "$RAW_BASE/$repo_rel" -o "$dest"
  fi
}

install_skill() {
  local agent_skills_dir="$1"
  local skill_dir_name="$2"
  local repo_rel="$3"
  if [ -d "$(dirname "$agent_skills_dir")" ]; then
    mkdir -p "$agent_skills_dir/$skill_dir_name"
    write_skill_file "$agent_skills_dir/$skill_dir_name/SKILL.md" "$repo_rel"
    ok "$skill_dir_name → $agent_skills_dir"
    return 0
  fi
  return 1
}

install_skills_for() {
  local label="$1"
  local target_dir="$2"
  local installed=0
  install_skill "$target_dir" "botspeak"           "skills/botspeak/SKILL.md"  && installed=1
  install_skill "$target_dir" "capture-botspeak"   "skills/capture/SKILL.md"   && installed=1
  install_skill "$target_dir" "translate-botspeak" "skills/translate/SKILL.md" && installed=1
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
install_skills_for "Cursor"      "$HOME/.cursor/skills-cursor"
# Codex: only install if the binary is present (a ~/.codex dir alone is not enough)
if command -v codex >/dev/null 2>&1; then
  install_skills_for "Codex" "$HOME/.codex/skills"
else
  skip "Codex"
fi
# Gemini CLI: uses native extensions mechanism (not file copy)
if command -v gemini >/dev/null 2>&1; then
  echo ""
  echo -e "  ${GREEN}→ Gemini CLI detected${RESET}"
  if gemini extensions list 2>/dev/null | grep -qi "botspeak"; then
    echo -e "  ${YELLOW}-${RESET} botspeak already installed (uninstall with: gemini extensions uninstall botspeak)"
  else
    if echo "Y" | gemini extensions install "https://github.com/$GITHUB_REPO" 2>&1 | grep -q "installed successfully"; then
      ok "botspeak → gemini extensions"
    else
      echo -e "  ${YELLOW}!${RESET} Gemini extension install failed — ensure the repo is public on GitHub, then re-run"
    fi
  fi
else
  skip "Gemini CLI"
fi
install_skills_for "Generic (~/.agents)" "$HOME/.agents/skills"

fetch_rule_file() {
  local dest="$1"
  local repo_rel="$2"
  if [ -n "$REPO_DIR" ] && [ -f "$REPO_DIR/$repo_rel" ]; then
    cp "$REPO_DIR/$repo_rel" "$dest"
  else
    curl -fsSL "$RAW_BASE/$repo_rel" -o "$dest"
  fi
}

if [ $WITH_RULE -eq 1 ]; then
  header "Always-on rule (project-local)"

  if [ -n "$REPO_DIR" ] && [ "$PWD" = "$REPO_DIR" ]; then
    skip "skipping rule install in BOTSPEAK repo itself"
  else
    # Cursor
    if [ -d ".cursor" ] || [ -d "$HOME/.cursor" ]; then
      mkdir -p "$PWD/.cursor/rules"
      fetch_rule_file "$PWD/.cursor/rules/botspeak.mdc" "rules/cursor.mdc"
      ok "Cursor → .cursor/rules/botspeak.mdc"
    fi

    # Windsurf
    if [ -d ".windsurf" ] || [ -d "$HOME/.windsurf" ]; then
      mkdir -p "$PWD/.windsurf/rules"
      fetch_rule_file "$PWD/.windsurf/rules/botspeak.md" "rules/botspeak.md"
      ok "Windsurf → .windsurf/rules/botspeak.md"
    fi

    # Cline
    if [ -d ".cline" ] || [ -d "$HOME/.cline" ]; then
      mkdir -p "$PWD/.clinerules"
      fetch_rule_file "$PWD/.clinerules/botspeak.md" "rules/botspeak.md"
      ok "Cline → .clinerules/botspeak.md"
    fi

    # GitHub Copilot (append if instructions file exists, create if not)
    if [ -d ".github" ]; then
      mkdir -p "$PWD/.github"
      if [ -f "$PWD/.github/copilot-instructions.md" ]; then
        echo "" >> "$PWD/.github/copilot-instructions.md"
        curl -fsSL "$RAW_BASE/rules/botspeak.md" >> "$PWD/.github/copilot-instructions.md"
        ok "Copilot → appended to .github/copilot-instructions.md"
      else
        fetch_rule_file "$PWD/.github/copilot-instructions.md" "rules/botspeak.md"
        ok "Copilot → .github/copilot-instructions.md"
      fi
    fi

    # AGENTS.md (universal fallback — Codex, generic agents)
    if [ ! -f "$PWD/AGENTS.md" ]; then
      fetch_rule_file "$PWD/AGENTS.md" "rules/botspeak.md"
      ok "Generic → AGENTS.md"
    else
      skip "AGENTS.md already exists (not overwriting)"
    fi

    echo ""
    echo "  No IDE detected? Copy rules/botspeak.md to your IDE's rules folder manually."
  fi
fi

header "Agent definition"
if [ -n "$REPO_DIR" ]; then
  ok "available at: $REPO_DIR/agents/botspeak-translator.md"
else
  ok "available at: $RAW_BASE/agents/botspeak-translator.md"
fi
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
