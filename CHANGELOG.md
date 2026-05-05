# Changelog

All notable changes to BOTSPEAK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

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
