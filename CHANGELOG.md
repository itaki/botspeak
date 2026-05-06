# Changelog

All notable changes to BOTSPEAK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.2.0] — 2026-05-05 — Skills consolidation, honest install

### Changed (breaking)

- **Renamed skills for autocomplete grouping.** All skills now share the `botspeak-` prefix so typing `/b` surfaces them as a cluster.
  - `/translate-botspeak` → `/botspeak-translate`
- **Renamed rule files for clarity.** Rule files are named for what they do, never for the IDE that consumes them.
  - `rules/botspeak.md` → `rules/botspeak-always-on.md`
  - `rules/cursor.mdc` → `rules/botspeak-always-on.mdc`
- **Removed the `--with-rule` installer flag.** Auto-installing rules across IDEs clobbered existing instructions and made unsafe assumptions about project roots. Rules are now manual-install per IDE — see README "Install" section for paths.

### Removed

- **`/capture-botspeak` skill** — redundant once the always-on rule is installed. Use natural language ("save this chat as a handoff doc") and the rule handles BOTSPEAK formatting automatically.
- **`/botspeak-tidy` skill** — too dangerous as a single sweep operation. Replaced by directory-mode in `/botspeak` (pass a directory path and it scans, warns about size, offers to back up, and converts files one by one).

### Added

- **Pre-flight size check in `/botspeak`.** Before compressing, the skill estimates token count and warns when input exceeds 25 K tokens (recommends cheap model) or 50 K tokens (warns about runtime).
- **Token math + measured timing reference** baked into the skill: 1 KB ≈ 256 tokens, ~2 minutes per 50 KB on Haiku (May 2026 measurement).
- **Directory mode in `/botspeak`** — pass a directory and the skill enumerates `.md`/`.mdc` files, shows a sized table with token estimates, and asks whether to back up before converting in batch.
- **Chat-prose invariant in rule files**: `chat replies to USER = always full human prose · zero BOTSPEAK`. BOTSPEAK belongs in docs, never in chat replies.
- **Prose-on-request trigger in rule files**: ask "write this in prose" or "don't botspeak this file" to get a single document back as plain prose without disabling the rule globally.

## [0.1.0] — 2026-05-05 — Initial release

### Added

- **SPEC.md** — language specification covering symbol vocabulary (ASCII + Symbol dialects), `@defs` aliases with reliability bounds, phase tags, grammar rules, document structure patterns, frontmatter preservation rules, and pitfalls.
- **Three skills**:
  - `/botspeak` — compress an existing AI-facing document into BOTSPEAK
  - `/capture-botspeak` — capture rambling chat input as a focused BOTSPEAK doc
  - `/translate-botspeak` — render any BOTSPEAK file into clear human prose (the round-trip safety net)
- **Cursor rule** (`.cursor/rules/botspeak.mdc`) — always-on rule for users who want BOTSPEAK applied automatically to new AI-facing docs.
- **Bidirectional agent** (`agents/botspeak-translator.md`) — auto-detects direction (BOTSPEAK ↔ prose) for tools that load agent definitions.
- **Five before/after examples** demonstrating short rules (41% reduction), context handoffs (78%), Karpathy-style memory pages (71%), project manifestos (74%), and long aliased CLAUDE.md (56%).
- **Bootstrap files** (CLAUDE.md, AGENTS.md) for host-tool discovery.
- **install.sh** — installs skills into all detected agents (Claude Code, Cursor, Codex, Gemini CLI, generic AGENTS.md targets).

### Design decisions documented

- ASCII operators (`->`, `&&`, `!!`) recommended as primary because they tokenize to 1 token guaranteed in every modern BPE tokenizer; emoji symbols (`🔴`, `→`, `·`) presented as optional dialect for human-audited docs.
- `@defs` aliases scoped to first ~2K body tokens for literal-key recall reliability; longer documents must re-declare per major section (grounded in 2025 NoLiMa long-context benchmarks).
- Frontmatter explicitly off-limits to compression because `name`/`description`/`triggers` are how host tools route.
- Skill is the recommended primary delivery mechanism; rule and agent are presented as advanced/optional.
