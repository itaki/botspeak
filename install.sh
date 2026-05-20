#!/usr/bin/env bash
# BOTSPEAK installer — skills + always-on rule, one command
# - skills go global into every detected agent
# - the always-on rule goes into Claude Code's global CLAUDE.md (file-based, idempotent)
# - paste-ready next steps printed for Cursor User Rules and per-project rules

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
BOLD='\033[1m'
RESET='\033[0m'

ok()    { echo -e "  ${GREEN}✓${RESET} $1"; }
skip()  { echo -e "  ${YELLOW}-${RESET} $1 (not detected)"; }
warn()  { echo -e "  ${YELLOW}!${RESET} $1"; }
header(){ echo -e "\n${BOLD}${GREEN}$1${RESET}"; }

# Write one SKILL.md — copy from local repo if available, else fetch from GitHub.
# If the destination already exists AND differs from the source, back it up
# alongside the original (.bu.<timestamp>) instead of silently clobbering it.
write_skill_file() {
  local dest="$1"        # full path to destination SKILL.md
  local repo_rel="$2"    # path relative to repo root, e.g. skills/botspeak/SKILL.md
  local tmp
  tmp="$(mktemp)"

  if [ -n "$REPO_DIR" ] && [ -f "$REPO_DIR/$repo_rel" ]; then
    cp "$REPO_DIR/$repo_rel" "$tmp"
  else
    if ! command -v curl >/dev/null 2>&1; then
      echo "  error: curl required for remote install" >&2
      rm -f "$tmp"
      return 1
    fi
    if ! curl -fsSL "$RAW_BASE/$repo_rel" -o "$tmp"; then
      rm -f "$tmp"
      return 1
    fi
  fi

  # If a customized SKILL.md already exists, preserve it as a .bu backup.
  if [ -e "$dest" ] && ! cmp -s "$tmp" "$dest"; then
    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    local backup="${dest}.bu.${stamp}.md"
    cp "$dest" "$backup"
    warn "preserved existing $(basename "$dest") as ${backup}"
  fi

  rm -f "$dest"
  mv "$tmp" "$dest"
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

# Fetch the always-on rule contents to a variable.
# Echoes the rule body on stdout, returns 1 if it cannot be fetched.
fetch_rule_body() {
  if [ -n "$REPO_DIR" ] && [ -f "$REPO_DIR/rules/botspeak-always-on.md" ]; then
    cat "$REPO_DIR/rules/botspeak-always-on.md"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_BASE/rules/botspeak-always-on.md"
  else
    return 1
  fi
}

# Install the always-on rule globally into Claude Code (~/.claude/CLAUDE.md).
# Idempotent: marker comments delimit our block, replaced on each re-run.
install_claude_global_rule() {
  local target="$HOME/.claude/CLAUDE.md"
  local parent="$HOME/.claude"
  if [ ! -d "$parent" ]; then
    skip "Claude Code global rule (~/.claude not detected)"
    return 1
  fi

  local body
  if ! body="$(fetch_rule_body)"; then
    warn "Claude global rule: could not fetch rule body"
    return 1
  fi

  local start_marker='<!-- BOTSPEAK-ALWAYS-ON:START - managed by install.sh -->'
  local end_marker='<!-- BOTSPEAK-ALWAYS-ON:END -->'

  mkdir -p "$parent"
  if [ ! -f "$target" ]; then
    {
      echo "$start_marker"
      echo "$body"
      echo "$end_marker"
    } > "$target"
    ok "always-on rule -> $target (created)"
    return 0
  fi

  if grep -qF "$start_marker" "$target"; then
    # Refuse to rewrite if the END marker is missing — without it, the awk
    # strip below would drop everything after START. Tell the user how to fix.
    if ! grep -qF "$end_marker" "$target"; then
      warn "Claude global rule: START marker present but END marker missing in $target"
      warn "  Refusing to rewrite (would truncate the file). Manually restore the"
      warn "  END marker line ($end_marker) or delete the BOTSPEAK block, then re-run."
      return 1
    fi
    # Strip existing managed block, then append a fresh one.
    local stripped
    stripped="$(mktemp)"
    awk -v start="$start_marker" -v end="$end_marker" '
      $0 == start { in_block=1; next }
      $0 == end   { in_block=0; next }
      !in_block   { print }
    ' "$target" > "$stripped"
    {
      cat "$stripped"
      echo "$start_marker"
      echo "$body"
      echo "$end_marker"
    } > "$target"
    rm -f "$stripped"
    ok "always-on rule -> $target (refreshed)"
  else
    {
      echo ""
      echo "$start_marker"
      echo "$body"
      echo "$end_marker"
    } >> "$target"
    ok "always-on rule -> $target (appended)"
  fi
}

cat <<'BANNER'
┌─────────────────────────────────────────┐
│   BOTSPEAK — bots talking to bots       │
│   installing skills + always-on rule    │
└─────────────────────────────────────────┘
BANNER

header "1/3 — Skills (global, per agent)"
install_skills_for "Claude Code" "$HOME/.claude/skills"
install_skills_for "Cursor"      "$HOME/.cursor/skills"
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

header "2/3 — Always-on rule (global, where possible)"
install_claude_global_rule || true

header "3/3 — Manual rule paths"
cat <<MANUAL
  Most IDEs keep rules per-project. The always-on rule lives at:
    $RAW_BASE/rules/botspeak-always-on.md      (universal markdown)
    $RAW_BASE/rules/botspeak-always-on.mdc     (Cursor with alwaysApply frontmatter)

  Per-IDE one-liners (from a project root):
    Cursor       cp <repo>/rules/botspeak-always-on.mdc .cursor/rules/
                 (or paste rules/botspeak-always-on.md into Cursor → Settings → Rules → User Rules)
    Windsurf     cp <repo>/rules/botspeak-always-on.md .windsurf/rules/
    Cline        cp <repo>/rules/botspeak-always-on.md .clinerules/
    Copilot      cat <repo>/rules/botspeak-always-on.md >> .github/copilot-instructions.md
    Codex / any  cat <repo>/rules/botspeak-always-on.md >> AGENTS.md

  The rule itself is small — print it any time with:
    curl -fsSL $RAW_BASE/rules/botspeak-always-on.md
MANUAL

cat <<'DONE'

done.

triggers (skills):
  /botspeak           - compress an existing AI-facing doc (file or directory)
  /botspeak-translate - render BOTSPEAK back to human prose (audit safety net)

or just say:
  "botspeak this"
  "translate this for me"

reference: SPEC.md, examples/, README.md

DONE
