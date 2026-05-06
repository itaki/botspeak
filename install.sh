#!/usr/bin/env bash
# BOTSPEAK installer
# installs skills into all detected agents
# rules are install-by-hand; see README.md for per-IDE paths

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
  install_skill "$target_dir" "botspeak"           "skills/botspeak/SKILL.md"           && installed=1
  install_skill "$target_dir" "botspeak-translate" "skills/botspeak-translate/SKILL.md" && installed=1
  if [ $installed -eq 0 ]; then
    skip "$label"
  fi
}

cat <<'BANNER'
┌─────────────────────────────────────────┐
│   BOTSPEAK — bots talking to bots       │
│   installing skills                     │
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
  /botspeak           - compress an existing AI-facing doc (file or directory)
  /botspeak-translate - render BOTSPEAK back to human prose (audit safety net)

or just say:
  "botspeak this"
  "translate this for me"

always-on rule (manual install — recommended):
  See README.md "Install" section for per-IDE rule paths.
  TL;DR: copy rules/botspeak-always-on.md (or .mdc for Cursor) into your IDE's
  rules folder so every new AI-facing doc gets written in BOTSPEAK by default.

reference: SPEC.md, examples/, README.md

DONE
