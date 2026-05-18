<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-18 -->
<!--
GENERATED FILE -- do not edit by hand.
Regenerated from AGENTS.md by scripts/generate_agent_configs.py.
BS re-runs generator every session → edits here lost.

Precedence (most specific wins):
  1. CLAUDE.local.md      per-agent, per-project overrides
  2. AGENTS.local.md      cross-agent, per-project overrides
  3. CLAUDE.md            generated from AGENTS.md (this file)
  4. AGENTS.md            upstream baseline

Customize for CC only: create CLAUDE.local.md (generator never touches it).
Customize all agents: edit AGENTS.local.md.
Change upstream: edit AGENTS.md in your fork.
-->

<!-- Quick start: In Claude Code, read @AGENTS.md to run bootstrap, session checks, and task routing -->

@defs
  CC   = Claude Code
  CX   = Codex
  AA   = anywhere-agents
  AM   = AGENTS.md
  ALM  = AGENTS.local.md
  CLM  = CLAUDE.local.md
  CM   = CLAUDE.md
  CXM  = agents/codex.md
  AC   = .agent-config/
  ACY  = agent-config.yaml
  SK   = skills/
  SKM  = SKILL.md
  BS   = bootstrap
  GP   = guard.py
  SBP  = session_bootstrap.py
  UCS  = ~/.claude/settings.json
  SEJ  = session-event.json
  BEJ  = banner-emitted.json
  PR   = project-root
  PVF  = anywhere-agents pack verify --fix
  NJ24 = Node.js 24
  CCEL = CLAUDE_CODE_EFFORT_LEVEL
@end

default-phase: ALWAYS

> **CC / CX / other agents -- determine context before proceeding:**
>
> **Source repo test:** If `BS/bootstrap.sh`, `BS/bootstrap.ps1`, and `SK` all exist at repo root → you are in AA source repo (or same-layout fork). Skip BS block below; proceed to Session Start Check. !! do not execute BS script in source repo — it would try to BS itself.
>
> **Consumer repo path:** Otherwise → you are in a consumer project. MUST execute matching BS block at start of every session, before responding to any user request or running session checks. Use PowerShell block on Windows, Bash block on macOS/Linux. BS is idempotent: run every session even if AC already exists — refreshes shared config, SK, and settings from upstream before any work. !! do not treat block as reference documentation — it is required runtime command. After running, report refresh result in one line (e.g., "bootstrap: refreshed AM, SK, settings").

## Bootstrap: Shared Config and Skills

[REFERENCE] AA hosted at `https://github.com/yzhao062/anywhere-agents`. Project repos include BS block in their AM so agents pull latest shared defaults and SK before any task. BS overwrites consumer's root AM on every run → block serves two roles in consumer repos: embedded reference for setup + runtime command agent executes each session (see source-vs-consumer test above for which role applies).

### Bootstrap block for project repos

[REFERENCE] Copy block below into top of each project repo's AM. BS overwrites AM on every run → put project-local overrides in ALM.

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

### What gets shared

[REFERENCE]

| Content | Source | How fetched |
|---------|--------|-------------|
| User profile, writing defaults, formatting rules, environment notes | AM (this file) | `curl` raw file |
| Per-agent rule files (CM, CXM) | Generated from AM by `scripts/generate_agent_configs.py` | Regenerated locally on every BS; hand-authored files preserved + warned |
| Shared SK (`implement-review`, `my-router`, `ci-mockup-figure`, `readme-polish`) | SK directory (committed only) | sparse `git clone` |
| CC pointer commands for shared SK | `.claude/commands/` | sparse `git clone` plus non-destructive copy into project `.claude/commands/` |
| CC project defaults (`permissions`, `attribution`, etc.) | `.claude/settings.json` | sparse `git clone` plus key-level merge into project `.claude/settings.json` on every run |
| User-level hooks (GP, SBP) + settings | `scripts/` + `user/settings.json` | Scripts copied to `~/.claude/hooks/`; settings merged into UCS (shared permissions, PreToolUse guard, SessionStart BS hook, `CCEL=max`) |

### Override rules

[REFERENCE]

- ALM exists in project root → read + follow after AM · ALM rules override shared defaults
- !! do not edit root AM for local overrides — BS will overwrite it
- Project-local `SK/<name>/SKM` always wins over shared copy of same SK
- Shared keys in `.claude/settings.json` updated on every BS run · project-only keys preserved · to override shared key locally → use `.claude/settings.local.json`
- Shared SK not found locally → use fetched copy from `AC/repo/SK/`

### Configuration Precedence

[REFERENCE] Three independent configuration layers. When two rules conflict, more specific source wins.

**1. Agent rule files (Markdown)** — most specific wins:

| Layer | File | Scope |
|---|---|---|
| 1 | CLM / `agents/codex.local.md` | Per-agent + project-local. Hand-authored; never touched by BS. |
| 2 | ALM | Cross-agent + project-local. Hand-authored; never touched by BS. |
| 3 | CM / CXM | Per-agent, generated from AM by `scripts/generate_agent_configs.py`. |
| 4 | AM | Cross-agent, synced from upstream on every BS. |

Generated CM and CXM carry `GENERATED FILE` header. Consumer project has hand-authored CM (or CXM) without that header → generator preserves it and warns loudly · !! never silently overrides user work. To adopt upstream rules: rename hand-authored file to CLM (still wins via layer 1).

**2. CC settings (`settings.json`)** — CC's own precedence: `managed policy` > `command-line arguments` > `.claude/settings.local.json` > `.claude/settings.json` > UCS. BS writes only to project-shared and user-level layers; merges shared keys while preserving project-only keys.

**3. Environment variables** — for effort level: `managed policy > CCEL env var > persisted effortLevel > default`.

---

<!-- Everything above this line is bootstrap setup instructions. -->
<!-- Everything below this line contains the shared rules that agents should read and follow. -->

## Session Start Check

Mandatory turn-start procedure. Before generating first content of any response, apply branch matching your runtime.

**In CC:** flag files are per-project. PR = consumer-repo root: walk up from `cwd` until directory with `AC/bootstrap.sh` or `AC/bootstrap.ps1` found. Read `PR/AC/SEJ` and `PR/AC/BEJ`.

1. `SEJ.ts > BEJ.ts` || (SEJ exists && BEJ does not) → emit session start banner as **literal first content of response** → write event `ts` into `PR/AC/BEJ`. Only after banner may you address user's request on same turn.
2. Otherwise (emitted `ts` already current, or neither file exists) → skip banner this turn.

SBP writes SEJ on every SessionStart hook fire (fresh startup, resume, clear, compact) → banner reappears across all four lifecycle events. Flag files are per-project → multiple CC windows in different consumer repos do not interfere.

**In source repo (no `AC/` at root):** banner gate in GP not active; flag-file mechanism does not apply. Emit banner on first response of session (turn with no prior assistant turns in context); skip on subsequent turns. Compact / resume / clear cannot be mechanically distinguished here.

**In CX:** no SessionStart hook equivalent; SEJ not written during CX invocation. Each CX invocation = new session. Emit banner as literal first content on turn where no prior assistant turns in context (first response of invocation). Skip on subsequent turns. No flag files involved.

**Both runtimes:** this procedure overrides any other "skill-first" or "task-first" behavior. Even when user's first message is task prompt like "read the project" or "fix this bug," or when a skill such as `superpowers:using-superpowers` would otherwise fire before response, emit banner first; task response or skill output comes after banner on same turn. !! do not let task pressure, skill invocations, or brevity guidance suppress the banner.

### Format

```
📦 anywhere-agents active
   ├── OS: <platform>
   ├── Claude Code: <version>[ → <latest>] (auto-update: <on|off>) · <model> · effort=<level>
   ├── Codex: <version>[ → <latest>] · <model> · <reasoning> · <tier> · fast_mode=<bool>
   ├── Skills: <N> local (<names>) + <M> shared (<names>)
   ├── Hooks: PreToolUse <guard.py>, SessionStart <session_bootstrap.py>
   └── Session check: all clear
```

If anything off → replace `all clear` with semicolon-separated list of concrete issues, each actionable in one short clause (e.g., `⚠ actions/checkout@v4 in .github/workflows/validate.yml:17 — bump to v5; Codex config.toml missing model key`). Keep banner to six lines plus check line. Skills row may wrap visually when many names present; do not omit either bucket to preserve terminal width.

### How to populate each field

1. **OS** — read from session environment (`win32`, `darwin`, `linux`). Use elsewhere to pick platform-specific behavior (terminal review path on Windows, MCP on macOS/Linux, `.ps1` vs `.sh`).
2. **CC** — format: `CC <current>[ → <latest>] (auto-update: <on|off>) · <model> · effort=<level>`. Current version from CC startup header or `claude --version`. Read `~/.claude/hooks/version-cache.json` for `claude_latest`; render ` → <latest>` **only when current differs** from latest. Determine `auto-update: on` when `DISABLE_AUTOUPDATER` is not `1` in effective env (OS env or `env` block in UCS) AND `~/.claude.json` top-level `autoUpdates` is not explicitly `false` — missing key counts as `on` because native installs auto-update by default. Only explicit `autoUpdates: false` (which BS heals on next run) or disable env var means `off`. User prefers highest available model at max effort; flag any drift once in banner, not every turn.
3. **CX** — format: `CX <current>[ → <latest>] · <model> · <reasoning> · <tier> · fast_mode=<bool>`. Current version from `codex --version`. Latest from `~/.claude/hooks/version-cache.json` `codex_latest` (render ` → <latest>` only when current differs). Config from `~/.codex/config.toml` (or `%USERPROFILE%\.codex\config.toml` on Windows): `model` · `model_reasoning_effort` · `service_tier` · `[features].fast_mode`. Expected values: `model = "gpt-5.5"` (or latest), `model_reasoning_effort = "xhigh"`, `service_tier = "fast"`, `[features] fast_mode = true`. Binary not on PATH → `CX: not installed`. Binary exists but `config.toml` missing → version + `not configured` in place of config summary.
4. **Skills** — list both active sets. Count directories under `SK` (project-local) and `AC/repo/SK` (bootstrapped). For shared count/list, exclude any shared SK whose name also exists under project-local `SK` — project-local overrides shared on name conflict. Format: `<N> local (<names>) + <M> shared (<names>)`. Omit either half if empty.
5. **Hooks** — check `~/.claude/hooks/` for GP (PreToolUse) and SBP (SessionStart). If one missing → include in Session check line as issue.
6. **Session check** — scan `.github/workflows/*.yml` for action version pins below minimums in GitHub Actions Standards section. Combine with any CX-config or hook drift detected above. Emit `all clear` only when nothing needs attention.

7. **Pack deployment** — perform this check exactly:

    a. Read user-level config: on Windows `%APPDATA%\anywhere-agents\config.yaml`; on POSIX `$XDG_CONFIG_HOME/anywhere-agents/config.yaml`, default `~/.config/anywhere-agents/config.yaml`. If absent → `user_packs = []`.

    b. Read durable project config: ACY then merge `agent-config.local.yaml` overrides by name. `AGENT_CONFIG_PACKS` env var is **excluded**. If both files absent → `project_packs = []`.

    c. For each pack `u` in `user_packs`, normalize identity tuple `(u.name, normalize_pack_source_url(u.source.url), u.source.ref)`. Find any pack `p` in `project_packs` with same `u.name` (case-sensitive name match). If `project_packs` contains duplicate-named entries (e.g., same name in both ACY and `agent-config.local.yaml`), apply local-overrides-tracked: keep only local entry. Count `u` toward `gap_count` if: no matching `p` exists, OR `p`'s normalized identity tuple differs from `u`'s.

    d. Read `AC/pack-lock.json` (project-local lock written by composer). For each entry in `data.packs`, count toward `update_count` when **both** `latest_known_head` and `resolved_commit` are non-empty strings AND `latest_known_head != resolved_commit`. Optional `latest_known_head` / `fetched_at` fields land via `pack verify` (which runs `git ls-remote` opportunistically) and via composer fetches at install time. Old locks predating v0.5.2 omit both fields → contribute zero, no migration needed.

    e. Compose banner contribution. Each is a half-clause; drop half whose count is 0; emit `all clear` only when both are 0:

       - `gap_count > 0` → ``⚠ <gap_count> user-level pack(s) not deployed (run `PVF`)``
       - `update_count > 0` → ``ℹ <update_count> pack update(s) available (run `PVF`)``

       Append surviving half-clauses to Session check line, semicolon-separated. CLI command differs from v0.5.1: v0.5.2 collapses verify-then-BS dance into `PVF`, which now invokes composer subprocess after writing config rows.

## User Profile

- User-level defaults reusable across projects unless local repo rule or task-specific instruction is stricter.
- **Customize this section in your fork of AA** to describe your role, domain, and common task types. Agents read this to tailor their work (e.g., researcher vs backend engineer vs data scientist get different defaults).
- Fork serves multiple use cases → keep description general ("developer working on infrastructure and research tooling") rather than overspecifying.

## Agent Roles

- **CC** = primary workhorse: drafting, implementation, research, heavy-lifting tasks.
- **CX** = gatekeeper: review, feedback, quality checks on work produced by CC or user.
- Both agents available → default to this division of labor unless user overrides.

## Task Routing

- Before starting task, read router SK to determine which domain SK to use. Look in order: `SK/my-router/SKM` (repo-local), then `AC/repo/SK/my-router/SKM` (bootstrapped from shared config).
- Router inspects prompt keywords, file types, project structure → dispatches automatically. !! do not ask user which SK to use when routing table provides clear match.
- `superpowers` plugin active → router operates during execution phase. Superpowers handles outer workflow (brainstorm, plan, execute, verify); router handles inner dispatch to right domain SK.
- Routing ambiguous (multiple SK could apply) → state detected context + proposed SK → ask user to confirm.

## Writing Defaults

- Use scientifically accessible language.
- Do not oversimplify unless user asks.
- Keep meaningful technical detail.
- Keep factual accuracy and clarity high in scientific contexts.
- Use consistent terms. Abbreviation defined once → do not define again later.
- Citing papers → verify they exist.
- Paper citations requested → provide BibTeX entries that can be copied into `.bib` file.
- Provide code only when necessary. Confirm code is correct and can run as written.
- Avoid the following words and close variants unless user explicitly asks (default AI-tell list; trim or extend in your fork): `encompass`, `burgeoning`, `pivotal`, `realm`, `keen`, `adept`, `endeavor`, `uphold`, `imperative`, `profound`, `ponder`, `cultivate`, `hone`, `delve`, `embrace`, `pave`, `embark`, `monumental`, `scrutinize`, `vast`, `versatile`, `paramount`, `foster`, `necessitates`, `provenance`, `multifaceted`, `nuance`, `obliterate`, `articulate`, `acquire`, `underpin`, `underscore`, `harmonize`, `garner`, `undermine`, `gauge`, `facet`, `bolster`, `groundbreaking`, `game-changing`, `reimagine`, `turnkey`, `intricate`, `trailblazing`, `unprecedented`.

## Formatting Defaults

- Preserve original format when input is in LaTeX, Markdown, or reStructuredText.
- !! do not convert paragraphs into bullet points unless user asks for that format.
- Prefer full forms `it is`, `he would` over contractions.
- `e.g.,` and `i.e.,` are fine when appropriate.
- !! do not use Unicode character `U+202F`.
- !! do not use em dashes (`—`) or en dashes (`–`) as casual sentence punctuation. Prefer commas, semicolons, colons, or parentheses instead. En dashes in numeric ranges (e.g., `1–3`, `2020–2025`), paired names, or citations are fine. Normal hyphenation in compound words and technical terms (e.g., `command-line`, `co-PI`, `zero-shot`) is fine and should not be avoided.
- Break extremely long or complex sentences into shorter, more readable ones. Sentence has multiple clauses or nested qualifications → split it.
- Vary sentence length and structure. Prefer not to start several consecutive sentences with same word or phrase. Avoid overusing transition words like "Additionally" or "Furthermore." Not every paragraph needs a tidy summary sentence at end. Mix short, direct sentences with longer ones to keep writing natural.

## Git Safety

- !! never run `git commit` or `git push` without explicit user approval. Always show proposed action + ask for confirmation before executing.
- Rule is non-negotiable · applies to all projects that consume this shared config.
- Includes any variant: `git commit -m`, `git commit --amend`, `git push`, `git push --force`, `gh pr create` (which pushes), etc.

## Mechanical Enforcement

BS deploys GP to `~/.claude/hooks/guard.py` and wires it as `PreToolUse` hook in UCS. Hook runs before every tool call and mechanically enforces:

| Gate | Tool scope | Trigger | Action |
|---|---|---|---|
| Writing-style | `Write`, `Edit`, `MultiEdit` on `.md` / `.tex` / `.rst` / `.txt` | Outgoing content contains a banned AI-tell word (see Writing Defaults list) | **deny** with hit list |
| Banner emission | Any tool except `Read`, `Grep`, `Glob`, `Skill`, `Task`, `TodoWrite`, `BashOutput`, `WebFetch`, `WebSearch`, `ToolSearch`, `LS`, `NotebookRead`; plus `Write`/`Edit`/`MultiEdit` whose target path exactly equals `PR/AC/BEJ` after absolute-path normalization and Windows case folding | `PR/AC/SEJ.ts > PR/AC/BEJ.ts`. PR found by walking up from `cwd` until `AC/bootstrap.{sh,ps1}` present. Source repos (no `AC/`) and unrelated directories skip gate entirely | **deny** with instruction to emit banner + write acknowledgment to per-project ack file |
| Compound `cd` | `Bash` | Command contains `cd <path> && <cmd>` or `cd <path>; <cmd>` | **deny** with suggestion to use `git -C` or path arguments |
| Destructive git | `Bash` | `git push`, `git commit`, `git merge`, `git rebase`, `git reset --hard`, `git clean`, `git branch -d/-D`, `git tag -d`, `git stash drop/clear` | **ask** (user confirms) |
| Destructive gh | `Bash` | `gh pr create`, `gh pr merge`, `gh pr close`, `gh repo delete` | **ask** (user confirms) |

**Escape hatch:** set env var `AGENT_CONFIG_GATES=off` (or `0`/`disabled`/`false`) via `env` block in UCS to disable writing-style and banner gates. Compound-cd / destructive-git / destructive-gh checks remain active regardless — they guard muscle-memory mistakes that do not tolerate false positives.

Setting escape hatch is right when legitimate write has banned word in meta-discussion context (e.g., style-guide quoting banned words as examples of what to avoid), or when prompt-layer failure is blocking legitimate work. Fix false positive → remove override.

## Shell Command Style

- **Avoid compound `cd <path> && <command>` chains.** CC's hardcoded compound-command protection prompts for approval on these even when both commands individually allowed. Use alternatives:
  - git in another repo → `git -C <path> <subcommand>` instead of `cd <path> && git <subcommand>`
  - non-git commands → pass target path as argument (e.g., `ls <path>`, `python <path>/script.py`) or use separate tool calls
- Read-only invocations that should not require approval: `git status`, `git diff`, `git log`, `git branch` (no flags), `git show`, `git stash list`, `git remote -v`, `git submodule status`, `git ls-files`, `git tag --list`. Filesystem reads (`ls`, `cat`) and benign local operations (`mkdir`) also fine.
- Invocations that always require explicit approval: `git commit`, `git push`, `git reset`, `git checkout`, `git rebase`, `git merge`, `git branch -d`, `git remote add/remove`, `git tag <name>` (creating/deleting), `git stash drop`.
- `cp` and `mv` fine for scratch and temporary files. Moves or renames of git-tracked files should be reviewed before executing.
- **Avoid inline Python with `#` comments in quoted arguments.** CC flags "newline followed by `#` inside a quoted argument" as path-hiding risk → prompts for approval. Instead: write code to `.py` file and run `python <script>.py`.

## GitHub Actions Standards

[REFERENCE] GitHub deprecating Node.js 20 actions. Runners begin using NJ24 by default June 2, 2026; Node.js 20 removal later fall 2026. Keep workflow action pins at or above first NJ24 major for GitHub-maintained actions:

| Action | Minimum version (NJ24) | Replaces |
|--------|------------------------|----------|
| `actions/checkout` | **v5** | v3, v4 |
| `actions/setup-python` | **v6** | v5 |
| `actions/setup-node` | **v5** | v4 |
| `actions/upload-artifact` | **v6** | v4, v5 |
| `actions/download-artifact` | **v7** | v4, v5, v6 |

Session start check detects older versions → list affected files + suggest minimum NJ24 version from table. Repo intentionally wants latest major instead of minimum compatible major → flag as separate manual upgrade (later majors can include behavior changes). Workflow pins SHA instead of tag → flag for manual review rather than auto-suggesting tag. For self-hosted runners → remind user these NJ24 actions require Actions Runner version supporting NJ24.

## Environment Notes

- !! do not conclude Python unavailable just because `python`, `python3`, or `py` fails in PATH — may resolve to shims, store aliases, or wrong interpreter. Inspect common environment managers (Miniforge/Conda, pyenv, uv, venv) before reporting Python as missing.
- User's fork sets preferred Python interpreter path in ALM → use that first.
- GitHub CLI (`gh`) for PR + issue workflows. Not found → remind user to install (`winget install GitHub.cli` on Windows, `brew install gh` on macOS, `gh` from distro package manager on Linux) and authenticate with `gh auth login`.
- **CC installation**: Prefer **native installer**. Migrate off npm and winget when possible.
  - macOS: `curl -fsSL https://claude.ai/install.sh | sh`
  - Windows (PowerShell, no admin): `irm https://claude.ai/install.ps1 | iex` (requires Git for Windows)
  - Migrate from npm: `npm uninstall -g @anthropic-ai/claude-code` first. From winget: `winget uninstall Anthropic.ClaudeCode` first.
  - Native installs auto-update in background by default. Use `/config` inside CC to set release channel (`latest` or `stable`). Run `claude doctor` to inspect updater status; `claude update` to force immediate update check.
  - To disable auto-updates: set `DISABLE_AUTOUPDATER=1` in environment or add `"env": {"DISABLE_AUTOUPDATER": "1"}` to UCS. Env var takes precedence regardless of other flags. **Caveat:** migrated from npm or winget → earlier install may have left `"autoUpdates": false` at top level of `~/.claude.json`. Observed behavior: native updater daemon never spawns when flag was already false at launch, even with `autoUpdatesProtectedForNative: true`. BS heals this by flipping stale flag to `true` on every run → env-var path is only supported way to opt out.
- **CC effort level**: As of CC v2.1.111, `/effort` slider exposes five levels: `low`, `medium`, `high`, `xhigh`, `max`. Persisted `effortLevel` key in `settings.json` accepts `low`, `medium`, `high`, `xhigh` (v2.1.111 added `xhigh` as valid persisted value). `max` remains session-only: selecting `max` via `/effort` silently does not persist. To get `max` as persistent default: set env var `CCEL=max` in UCS under `"env"`. Shared `user/settings.json` in this repo sets env var; BS merges it into UCS → running BS once on any consuming project lands user-level default. Runtime precedence: managed policy > CCEL env var > persisted `effortLevel` (local > project > user) > CC's built-in default. When env var set: outranks `--effort` at launch and `/effort` inside session; slash command prints warning that env var is overriding live effort. When env var unset: `--effort <level>` at launch is session-only override; `/effort low|medium|high|xhigh` updates persisted user setting; `/effort max` is session-only.

## Local Skills Precedence

- Workspace contains `SK` directory → treat repo-local SK as default source of truth for that project.
- Task matches SK name && both `SK/<skill-name>/SKM` and installed global SK exist → prefer repo-local SK.
- Using repo-local SK → read `SK/<skill-name>/SKM` and local `references/`, `scripts/`, `assets/` before falling back to globally installed copy.
- !! do not modify globally installed SK when repo-local SK of same name exists, unless user explicitly asks to update global copy.
- Repo-local SK overrides global SK → state briefly that local project copy is being used.

## Cross-Tool Skill Sharing

- SK under `SK/` shared between CC, CX, and any future agent.
- `SK/<skill-name>/SKM` = single source of truth for each SK. Agent-specific config files (e.g., `agents/openai.yaml`) are thin wrappers · !! must not duplicate or override logic in SKM.
- CC accesses SK via pointer commands in `.claude/commands/`. Each pointer file references corresponding SKM rather than duplicating content.
- BS sync copies only shared repo's `.claude/commands/*.md` files into project `.claude/commands/` · does not delete unrelated project-local commands.
- When editing SK → modify SKM and its `references/` or `scripts/` directly. !! do not create agent-specific forks of same content.
- New SK added → create both `SK/<skill-name>/SKM` structure and matching `.claude/commands/<skill-name>.md` pointer so both agents can use it immediately.
