@defs
  AG = AGENTS.md
  AGL = AGENTS.local.md
  CL = CLAUDE.local.md
  CG = CLAUDE.md
  COD = agents/codex.md
  CODL = agents/codex.local.md
  AC = .agent-config
  BS = bootstrap/bootstrap.sh
  BP = bootstrap/bootstrap.ps1
  SE = AC/session-event.json
  BE = AC/banner-emitted.json
  CCFG = ~/.claude/settings.json
  CJSON = ~/.claude.json
  CVC = ~/.claude/hooks/version-cache.json
  CCFGH = ~/.codex/config.toml
@end

<context>
[NEW-CHAT] generated-file = true
[NEW-CHAT] regenerated from AG by `scripts/generate_agent_configs.py`; bootstrap reruns each session -> manual edits lost
[NEW-CHAT] precedence (most specific wins): CL > AGL > CG > AG
[NEW-CHAT] per-Claude overrides -> CL; cross-agent per-project overrides -> AGL; upstream changes -> AG in fork

[ON-TRIGGER] runtime-context test:
  if repo-root has BS && BP && `skills/` -> source-repo
  else -> consumer-repo

[ON-TRIGGER] source-repo:
  skip bootstrap block
  go direct to `## Session Start Check`
  !! do not execute bootstrap script in source repo (self-bootstrap risk)

[ON-TRIGGER] consumer-repo:
  !! before any user request response || session checks, run matching bootstrap block each session (PowerShell on Windows, Bash on macOS/Linux)
  bootstrap idempotent -> run every session even when AC exists (refresh shared config/skills/settings)
  after run -> report one-line refresh result (example: "bootstrap: refreshed AGENTS.md, skills, settings")
</context>

<rules>
[REFERENCE] shared config hosted at `https://github.com/yzhao062/anywhere-agents`
[REFERENCE] project repos should embed bootstrap block in AG; bootstrap overwrites consumer root AG every run
[REFERENCE] keep project-local overrides in AGL

[REFERENCE] bootstrap block for project repos:
````
## Shared Agent Config (auto-fetched)

Before starting any task, fetch the shared agent configuration and skills. Use the block for your shell.

PowerShell (Windows):

```powershell
New-Item -ItemType Directory -Force -Path .agent-config, .claude, .claude/commands | Out-Null
Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/yzhao062/anywhere-agents/main/bootstrap/bootstrap.ps1 -OutFile .agent-config/bootstrap.ps1
& .\.agent-config\bootstrap.ps1
```

Bash (macOS/Linux):

```bash
mkdir -p .agent-config .claude/commands
curl -sfL https://raw.githubusercontent.com/yzhao062/anywhere-agents/main/bootstrap/bootstrap.sh -o .agent-config/bootstrap.sh
bash .agent-config/bootstrap.sh
```

This bootstrap flow refreshes the consuming repo's root `AGENTS.md` on every run: by default it composes the shared upstream copy with the `agent-style` rule pack (requires Python 3 + PyYAML; bootstrap attempts a best-effort `pip install --user pyyaml` when missing). When rule-pack composition is disabled (`rule_packs: []` in `agent-config.yaml`) or unavailable (Python or PyYAML absent after the auto-install attempt), the root `AGENTS.md` is written verbatim from the shared upstream copy. If a project later needs repo-local overrides, put them in `AGENTS.local.md`.

Read and follow the rules in `.agent-config/AGENTS.md` as baseline defaults. Any rule in `AGENTS.local.md` overrides the shared default.
When a skill is invoked, read its SKILL.md from `.agent-config/repo/skills/<skill-name>/SKILL.md`.
If a local `skills/<skill-name>/SKILL.md` exists in the project repo, the local copy takes precedence.
Copying `.agent-config/repo/.claude/commands/*.md` only overwrites command files with the same name as the shared repo and does not delete unrelated project-local commands.
Merge shared Claude project defaults (e.g., `permissions`, `attribution`) from `.agent-config/repo/.claude/settings.json` into the project `.claude/settings.json`. Shared keys are updated on every bootstrap run; project-only keys are preserved. Merge requires Python; if unavailable the existing file is left untouched.
Add `.agent-config/` to the project's `.gitignore` so fetched files are not committed.
Bootstrap also sets up user-level config: it copies `scripts/guard.py` to `~/.claude/hooks/` (a PreToolUse hook that guards against destructive commands) and merges `user/settings.json` into `~/.claude/settings.json` (shared permissions, hook wiring, and the `CLAUDE_CODE_EFFORT_LEVEL=max` env entry that sets the default effort level). Remove the user-level section from the bootstrap script if this is not wanted.
````

[REFERENCE] shared content:
  user profile + writing defaults + formatting rules + env notes <- AG (curl raw)
  per-agent rules (CG, COD) <- generated from AG by `scripts/generate_agent_configs.py` each bootstrap
  shared skills <- `skills/` sparse clone
  Claude pointer commands <- `.claude/commands/` sparse clone + non-destructive copy into project
  Claude project defaults <- `.claude/settings.json` sparse clone + key-level merge each run
  user hooks/settings <- `scripts/` + `user/settings.json` copied/merged to user home

[ALWAYS] override rules:
  if AGL exists, read after AG; AGL overrides shared defaults
  do not edit root AG for local overrides (bootstrap overwrites)
  local `skills/<name>/SKILL.md` > shared same-name skill
  shared keys in project `.claude/settings.json` updated each run, project-only keys preserved
  local override for shared key -> `.claude/settings.local.json`
  if shared skill missing locally, use fetched copy from AC repo skills

[ALWAYS] config precedence:
  markdown rules: CL/CODL > AGL > CG/COD > AG
  generated CG/COD with `GENERATED FILE` header; hand-authored files without header are preserved + warned
  to adopt upstream when hand-authored CG/COD exists -> rename to CL/CODL
  Claude settings precedence (Claude-native): managed policy > CLI args > `.claude/settings.local.json` > `.claude/settings.json` > CCFG
  bootstrap writes project-shared + user-level layers, merges shared keys, preserves project-only
  effort-level env precedence: managed policy > `CLAUDE_CODE_EFFORT_LEVEL` env var > persisted effortLevel > default
</rules>

<session_start_check>
[ALWAYS] mandatory turn-start procedure before first response content
[ON-TRIGGER] in Claude Code:
  find `<project-root>` by walking up from cwd until `AC/bootstrap.sh` || `AC/bootstrap.ps1`
  read SE + BE
  if `SE.ts > BE.ts` || (SE exists && BE missing):
    emit session-start banner as literal first response content
    then write SE `ts` to BE
    then continue normal response same turn
  else skip banner
  note: `session_bootstrap.py` writes SE on SessionStart events (fresh startup/resume/clear/compact); flags per-project

[ON-TRIGGER] in source repo (`agent-config` or `anywhere-agents`, no AC):
  banner gate + flag files do not apply
  emit banner first response of session (no prior assistant turn), skip later turns
  compact/resume/clear cannot be mechanically distinguished

[ON-TRIGGER] in Codex:
  no SessionStart hook equivalent; each invocation = new session
  emit banner as first response only when no prior assistant turns in invocation
  no flag files for Codex

[ALWAYS] banner procedure overrides skill-first/task-first behavior
[ALWAYS] even first-turn task prompt -> banner first, task output after banner same turn

[REFERENCE] banner format (ASCII-rendered here):
```
[BOX] anywhere-agents active
   |- OS: <platform>
   |- Claude Code: <version>[ -> <latest>] (auto-update: <on|off>) | <model> | effort=<level>
   |- Codex: <version>[ -> <latest>] | <model> | <reasoning> | <tier> | fast_mode=<bool>
   |- Skills: <N> local (<names>) + <M> shared (<names>)
   |- Hooks: PreToolUse <guard.py>, SessionStart <session_bootstrap.py>
   `- Session check: all clear
```
[ALWAYS] if issues exist, replace `all clear` with semicolon-separated actionable clauses
[ALWAYS] keep banner to six lines + check line; skills row may wrap; do not omit local/shared buckets

[REFERENCE] field population:
  1) OS from session env (`win32`/`darwin`/`linux`)
  2) Claude Code:
     current from startup header || `claude --version`
     latest from CVC `claude_latest`; render ` -> <latest>` only when mismatch
     auto-update = on when `DISABLE_AUTOUPDATER != 1` (effective env) && `CJSON.autoUpdates != false` (missing key = on)
     auto-update off only if disable env var or explicit `autoUpdates:false`
     user prefers highest model + max effort; flag drift once in banner
  3) Codex:
    format `Codex <current>[ -> <latest>] | <model> | <reasoning> | <tier> | fast_mode=<bool>`
     current from `codex --version`
     latest from CVC `codex_latest` (show arrow only on mismatch)
     config from CCFGH (or `%USERPROFILE%\.codex\config.toml` on Windows):
       expected `model="gpt-5.5"` (or latest), `model_reasoning_effort="xhigh"`, `service_tier="fast"`, `[features] fast_mode=true`
     if binary missing -> `Codex: not installed`
     if binary exists but config missing -> show version + `not configured`
  4) Skills:
     count local dirs under `skills/`
     count shared dirs under `.agent-config/repo/skills/` excluding names overridden by local same-name skills
     format `<N> local (<names>) + <M> shared (<names>)`; omit empty half
  5) Hooks:
     check `~/.claude/hooks/` for `guard.py` + `session_bootstrap.py`; missing item -> issue in Session check
  6) Session check:
     scan `.github/workflows/*.yml` for action pins below GitHub Actions minimum table
     combine with Codex-config drift + hook drift
     `all clear` only when no issues
  7) Pack deployment check (exact):
     a. read user config: Windows `%APPDATA%\anywhere-agents\config.yaml`; POSIX `$XDG_CONFIG_HOME/anywhere-agents/config.yaml` default `~/.config/anywhere-agents/config.yaml`; absent -> `user_packs=[]`
     b. read project config `agent-config.yaml` then merge `agent-config.local.yaml` by name; exclude `AGENT_CONFIG_PACKS`; both absent -> `project_packs=[]`
     c. for each user pack `u`, normalize identity `(u.name, normalize_pack_source_url(u.source.url), u.source.ref)`; compare to project pack `p` with same case-sensitive name after local-overrides-tracked dedupe; increment `gap_count` when missing or tuple mismatch
     d. read `.agent-config/pack-lock.json`; for each `data.packs` entry, increment `update_count` when both `latest_known_head` && `resolved_commit` non-empty strings && differ; old locks pre-v0.5.2 may omit fields -> contribute zero
     e. compose banner check:
        if `gap_count>0` -> `WARN <gap_count> user-level pack(s) not deployed (run anywhere-agents pack verify --fix)`
        if `update_count>0` -> `INFO <update_count> pack update(s) available (run anywhere-agents pack verify --fix)`
        append surviving clauses semicolon-separated; `all clear` only when both counts zero
        note: v0.5.2 command is `pack verify --fix` (replaces v0.5.1 verify+bootstrap dance)
</session_start_check>

<defaults>
[REFERENCE] User Profile section = user-level defaults reusable across projects unless stricter local/task rule
[REFERENCE] customize this section in fork of anywhere-agents by role/domain/tasks; keep broad when multiple use-cases

[ALWAYS] Agent Roles:
  Claude Code = primary workhorse (draft/implement/research/heavy-lift)
  Codex = gatekeeper (review/feedback/quality checks)
  if both available, default to this split unless user overrides

[ALWAYS] Task Routing:
  before task, read router skill from `skills/my-router/SKILL.md`, fallback `.agent-config/repo/skills/my-router/SKILL.md`
  router dispatches by keywords/file-types/project-structure
  do not ask user to choose skill when routing clear
  if `superpowers` plugin active, router runs in execution phase (superpowers handles outer workflow)
  if ambiguous routing -> state detected context + proposed skill, ask user to confirm

[ALWAYS] Writing Defaults:
  use scientifically accessible language; do not oversimplify unless user asks
  keep technical detail + factual accuracy + clarity (especially scientific contexts)
  keep terms consistent; if abbreviation defined once, do not redefine
  if citing papers, verify existence
  when paper citations requested, provide BibTeX copyable into `.bib`
  provide code only when needed; ensure runnable correctness
  avoid these words unless user explicitly asks:
  `encompass`, `burgeoning`, `pivotal`, `realm`, `keen`, `adept`, `endeavor`, `uphold`, `imperative`, `profound`, `ponder`, `cultivate`, `hone`, `delve`, `embrace`, `pave`, `embark`, `monumental`, `scrutinize`, `vast`, `versatile`, `paramount`, `foster`, `necessitates`, `provenance`, `multifaceted`, `nuance`, `obliterate`, `articulate`, `acquire`, `underpin`, `underscore`, `harmonize`, `garner`, `undermine`, `gauge`, `facet`, `bolster`, `groundbreaking`, `game-changing`, `reimagine`, `turnkey`, `intricate`, `trailblazing`, `unprecedented`

[ALWAYS] Formatting Defaults:
  preserve input format for LaTeX/Markdown/reStructuredText
  do not convert paragraphs -> bullets unless user asks
  prefer full forms (`it is`, `he would`) over contractions
  `e.g.,` and `i.e.,` ok when appropriate
  do not use Unicode `U+202F`
  avoid heavy dash use; do not use em dash/en dash as casual punctuation
  en dash ok in numeric ranges/paired names/citations
  normal hyphenation in compounds/technical terms ok
  split overly long/complex sentences
  vary sentence length/structure; avoid repeated sentence starts + transition-word overuse

[ALWAYS] Git Safety:
  !! never run `git commit` || `git push` without explicit user approval
  non-negotiable for all consuming projects
  includes variants: `git commit -m`, `git commit --amend`, `git push --force`, `gh pr create` (pushes), etc.
</defaults>

<enforcement_and_ops>
[REFERENCE] `scripts/guard.py` deployed to `~/.claude/hooks/guard.py` as PreToolUse hook via CCFG
[REFERENCE] guard enforcement gates:
  writing-style gate: tool Write/Edit/MultiEdit on `.md/.tex/.rst/.txt`; banned AI-tell word -> deny with hit list
  banner emission gate: applies to most tools (read-only tool allowlist exempt) + BE writes; if `SE.ts > BE.ts` (project-root via AC bootstrap markers) -> deny with instruction: emit banner then write ack file
  compound-cd gate: Bash command containing `cd <path> && <cmd>` or `cd <path>; <cmd>` -> deny; suggest `git -C` or path args
  destructive git gate: `git push/commit/merge/rebase/reset --hard/clean/branch -d/-D/tag -d/stash drop|clear` -> ask confirmation
  destructive gh gate: `gh pr create/merge/close`, `gh repo delete` -> ask confirmation

[REFERENCE] escape hatch:
  set `AGENT_CONFIG_GATES=off|0|disabled|false` in CCFG env to disable writing-style + banner gates
  compound-cd/destructive-git/destructive-gh checks remain active
  use hatch for legitimate false positives (e.g., style guide quoting banned words), then remove override after fix

[ALWAYS] Shell Command Style:
  avoid compound `cd <path> && <command>` chains
  for git other repo -> `git -C <path> <subcommand>`
  for non-git -> pass target path as argument or use separate tool calls
  read-only commands expected no approval: `git status`, `git diff`, `git log`, `git branch` (no flags), `git show`, `git stash list`, `git remote -v`, `git submodule status`, `git ls-files`, `git tag --list`, plus benign reads (`ls`, `cat`) and benign local ops (`mkdir`)
  commands always requiring explicit approval: `git commit`, `git push`, `git reset`, `git checkout`, `git rebase`, `git merge`, `git branch -d`, `git remote add/remove`, `git tag <name>` create/delete, `git stash drop`
  `cp`/`mv` ok for scratch/temp; moves/renames affecting tracked files should be reviewed
  avoid inline Python with `#` comments inside quoted args; write `.py` then run `python <script>.py`

[REFERENCE] GitHub Actions Standards:
  Node.js 20 actions deprecated; runners begin Node.js 24 default on 2026-06-02; Node.js 20 removal later fall 2026
  minimum action majors:
    `actions/checkout` >= v5 (replaces v3/v4)
    `actions/setup-python` >= v6 (replaces v5)
    `actions/setup-node` >= v5 (replaces v4)
    `actions/upload-artifact` >= v6 (replaces v4/v5)
    `actions/download-artifact` >= v7 (replaces v4/v5/v6)
  if session check finds older pins -> list files + suggest minimum Node.js 24 major
  if repo wants latest major beyond minimum -> flag as separate manual upgrade (possible behavior changes)
  if workflow pins SHA, flag manual review (do not auto-suggest tag)
  remind self-hosted runners must support Node.js 24 actions

[ALWAYS] Environment Notes:
  do not conclude Python missing only from `python`/`python3`/`py` PATH failure; inspect Miniforge/Conda, pyenv, uv, venv first
  if fork defines preferred Python interpreter in AGL, use it first
  `gh` used for PR/issue workflows; if missing, suggest install (`winget install GitHub.cli`, `brew install gh`, distro package manager) + `gh auth login`
  Claude Code install preference = native installer:
    macOS: `curl -fsSL https://claude.ai/install.sh | sh`
    Windows PowerShell (no admin): `irm https://claude.ai/install.ps1 | iex` (requires Git for Windows)
    migrate off npm: `npm uninstall -g @anthropic-ai/claude-code`
    migrate off winget: `winget uninstall Anthropic.ClaudeCode`
    native installs auto-update by default; `/config` sets channel (`latest`/`stable`)
    run `claude doctor` to inspect updater, `claude update` to force check
    disable auto-update only via `DISABLE_AUTOUPDATER=1` env var or CCFG env entry
    caveat: stale `CJSON.autoUpdates=false` from npm/winget migration can suppress updater daemon; bootstrap heals by forcing true every run; supported opt-out path = env var
  Claude Code effort levels (v2.1.111):
    `/effort` levels: `low`, `medium`, `high`, `xhigh`, `max`
    persisted `effortLevel` accepts `low|medium|high|xhigh`
    `max` session-only (slash selection does not persist)
    persistent max default -> set `CLAUDE_CODE_EFFORT_LEVEL=max` in CCFG `"env"`
    shared `user/settings.json` already sets env var; bootstrap merge applies it
    runtime precedence: managed policy > `CLAUDE_CODE_EFFORT_LEVEL` env > persisted `effortLevel` (local > project > user) > built-in default
    when env var set: overrides launch `--effort` and in-session `/effort`; slash command warns about override
    when env var unset: `--effort` session-only; `/effort low|medium|high|xhigh` updates persisted user setting; `/effort max` remains session-only

[ALWAYS] Local Skills Precedence:
  if workspace has `skills/`, repo-local skills = default source of truth
  if both local and global skill match, prefer local `skills/<skill-name>/SKILL.md`
  when using local skill, read `SKILL.md` + local `references/`, `scripts/`, `assets/` before global fallback
  do not modify globally installed skill when local override exists unless user explicitly asks to update global too
  if local overrides global, state briefly that local copy is used

[ALWAYS] Cross-Tool Skill Sharing:
  skills under `skills/` shared across Codex/Claude Code/future agents
  `skills/<skill-name>/SKILL.md` = single source of truth
  agent-specific configs (example `agents/openai.yaml`) must be thin wrappers, no duplicated/overridden SKILL logic
  Claude Code uses `.claude/commands/` pointers to SKILL docs (no duplication)
  bootstrap sync copies shared `.claude/commands/*.md` into project `.claude/commands/` without deleting unrelated project-local commands
  when editing skill, modify SKILL + local references/scripts directly; do not create agent-specific forks
  new skill -> create `skills/<skill-name>/SKILL.md` + matching `.claude/commands/<skill-name>.md` pointer
</enforcement_and_ops>
