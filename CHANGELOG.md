# Changelog

All notable changes to BOTSPEAK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.2.1] — 2026-05-20 — Pre-release audit fixes

PATCH bump — no SPEC rule or symbol changes; clarifications, bug fixes, and honesty
improvements across docs, examples, installer, and the translate skill.

### Fixed

- **Translate skill no longer mandates synthetic content.** `skills/botspeak-translate/SKILL.md` step 5 used to say "add a 'What this means in practice' paragraph" — which directly contradicted its own step 7 ("do NOT add interpretation beyond what the BT content states"). The skill now produces a faithful 1:1 expansion only, with a `diff`-against-source verification target. All `translated.md` files regenerated accordingly.
- **Cursor skills install path corrected** everywhere from the non-existent `~/.cursor/skills-cursor/` to the documented `~/.cursor/skills/` (`install.sh`, `uninstall.sh`, `.cursor/rules/botspeak-versioning.mdc`, `SPEC.md`). The uninstaller also cleans up legacy installs at the old path.
- **Showcase model claim corrected.** README, README-FOR-AI, and showcase now say "isolated Sonnet 4.6 subagent sessions, neither saw the other's prompt or output." Cross-model parity is explicitly called a v2.3 target, not a v2.2 claim — `showcase/index.html` had already correctly named "Sonnet 4.6 (all builds)" but the README contradicted it.
- **Example 01 (`examples/01-short-rule/after.md`).** Dropped the broken `br = git branch` and `wt = git worktree` aliases that expanded to `git git branch` inside command literals. Restored the missing `## Do not` section. Disambiguated previously-ambiguous `!!` polarity ("STOP all edits · wait for user to pick A/B/C" and "[ON-TRIGGER] user prompts again without picking A/B/C -> repeat the three options · !! proceed").
- **Example 02 (`examples/02-context-handoff/after.md`).** Removed hallucinated `@defs` aliases (`SPA`, `EF`) — declared but never used in the body, violating SPEC §9 pitfall 12.
- **Example 03 (`examples/03-memory-page/after.md`).** Restored YAML frontmatter (`tags: [react · hooks · …]` was invalid YAML) and restored fenced code-block contents verbatim — SPEC §4 explicitly forbids compressing inside fences.
- **Installer hardening.** Claude global-rule strip refuses to run if the `END` marker is missing (previously would have silently truncated the file). `write_skill_file` no longer blindly overwrites a customized SKILL.md — it `cmp`s and writes a timestamped `.bu.<stamp>.md` backup if contents differ. Same defensive check in `uninstall.sh`.
- **Showcase `file://` note.** README now includes the `python3 -m http.server` one-liner so cloners get working iframe loading.

### Changed

- **Example 04 replaced with a real-world `CLAUDE.md`.** The prior synthetic project-philosophy rule was padded with `🚨` headers, ALL-CAPS section restatements, and `✅`/`❌` emoji checklists — fairly called a strawman. Replaced with the live `CLAUDE.md` from [`obra/superpowers`](https://github.com/obra/superpowers) (198K stars, pinned to commit `e7a2d16`), which is an authentic manifesto-shaped doc. New `examples/04-philosophy-rule/README.md` documents provenance.
- **All token counts switched to `o200k_base`** (the GPT/Claude family tokenizer) across README, README-FOR-AI, showcase, `evals/round-trip-results.md`, and per-example folder READMEs. Replaces the prior `chars / 4` approximation. Compression numbers are smaller and now reproducible from one command. README explicitly notes word-based numbers as a footnote for those who prefer them (the file `evals/scripts/token-counts.json` carries both).
- **README leads with real CLAUDE.md examples** (07, 08, 09, plus the new 04 from `obra/superpowers`) before the synthetic ones — externally authored docs are harder to call self-serving.
- **Round-trip eval table** in `evals/round-trip-results.md` expanded from 6 to 9 in-repo rows (added the four real-world CLAUDE.md as full audit rows). Headline updated from "6/6 PASS" to "9/9 PASS." New "How PASS is defined" section spells out the four programmatic checks the verification harness runs.
- **`evals/round-trip/run.sh` rewritten** as a no-LLM verification harness. Runs four SPEC v2.2.0 checks (polarity, polarity-collision, code-block parity, alias hygiene) against committed iter files. Documents the manual LLM reproduction procedure in a heredoc at the top so reviewers can regenerate iter files from the actual shipped skills.
- **`agents/botspeak-translator.md` rewritten** to v2.2.0 ASCII dialect (no `🔴` / `✅` / `→` glyphs) per SPEC §0 Tenet 4 ("don't use two different symbols for the same meaning"). Adds the v2.2.0 verify pass (polarity substitution, code-block parity, alias hygiene, entity-state form).
- **`gemini-extension.json`** description corrected — removed the reference to the deprecated `/capture-botspeak` skill that was removed in v2.0.0. Bumped extension version to 2.2.0.
- **Version stamps aligned** across `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/*.mdc`, `agents/botspeak-translator.md`, and `skills/botspeak-translate/SKILL.md`.

### Added

- **`evals/scripts/count_tokens.py`** — reproducible o200k_base token counts for every example pair and game prompt. Reviewers can re-run from the repo root.
- **`evals/scripts/parity_check.py`** — extracts numeric constants from each game HTML pair and diffs by identifier name and normalized value. Exits 0 with zero shared-name mismatches across all four games. Surfaces honest data: most constants live in "only in one file" buckets because the two builds use different naming conventions (e.g. `CANVAS_WIDTH` vs `CW`), which the script reports plainly rather than papering over.
- **CHANGELOG v0.1.0 annotation** explaining that the historical 41/78/71/74/56% reduction numbers were from a more aggressive earlier compressor and aren't directly comparable to current v2.x numbers — current numbers are lower by design (clarity over compression).

## [2.2.0] — 2026-05-18 — Polarity verification, code-block parity, size guidance

### Added

- **SPEC §9 pitfall 14 — polarity inversion.** `!!` must be reserved for true prohibitions. Source language that sounds cautionary (opt-out instructions, conditional rules, preferences) is not always a prohibition; using `!!` on these inverts the polarity and produces actively wrong constraints when round-tripped.
- **SPEC §9 pitfall 15 — code-block dropping.** On long technical docs, the existing "preserve code blocks verbatim" rule got crowded out. Mermaid, YAML, and code snippets — the highest-value content in many specs — were summarized or dropped.
- **SPEC §10 — document size guidance.** Recommended strategy by source size (single-pass under 1500 words, section-scoped `<defs>` up to 4K words, split above that).
- **Skill step 6 verify checks.** Two new entries:
  - `!!` polarity check: substitute the literal word "forbidden" for each `!!` and verify the resulting statement holds.
  - Code-block parity count: count fenced ``` blocks in source vs output; fail compression if counts disagree.
- **PHILOSOPHY.md** — reframes BOTSPEAK as a language for AI-to-AI communication rather than a compression tool. The shorter token count is the measurement, not the motive.
- **showcase/index.html** — single-page eval showcase with side-by-side iframes of prose-built vs BOTSPEAK-built games (Flappy Bird, Snake, Pong, Breakout) plus the round-trip eval table.
- **Game eval suite expanded** to Pong and Breakout in addition to Flappy Bird and Snake. Each game has prose source, BOTSPEAK source, prose-built HTML, BOTSPEAK-built HTML, and a parity report. All builds were done clean-room (fresh subagent, no shared context) using Claude Sonnet 4.6.

### Changed

- **SPEC §4 keep-list** explicitly names "all fenced code blocks — verbatim, no exceptions."
- **Round-trip eval score: 6/6 PASS** on the in-repo examples (was 4/6 PASS · 2/6 PARTIAL in v2.1.0). The two PARTIALs (doc 05 polarity inversion on `DISABLE_AUTOUPDATER=1`; doc 06 Mermaid + YAML dropped) both now PASS. Three additional external real-world docs (Django `.cursorrules`, Rust `AGENTS.md`, ai-dev `.mdc`) also pass; their sources are checked in at `evals/external-prompts/` for clean-room reproduction.
- **Repo hygiene.** Old handoff files moved to `docs/handoffs-archive/`. Historical `evals/game-prompt/` artifacts (v3/v4/v5/v6 iterations, audit doc, prior demo HTML) moved to `evals/game-prompt/_history/`. Repo root now contains only canonical documents.
- **README.md** lead with the philosophy framing instead of compression numbers. Links prominently to PHILOSOPHY.md and showcase.

## [2.1.0] — 2026-05-08 — Entity-state rule, @defs hygiene

### Added

- **SPEC §9 pitfall 13 — entity-state vs. ambient-offset conflation.** Per-entity mutable state (each object carries its own position that mutates per frame) must be expressed with the three-part form (`x_init` · `-= speed each FR` · `remove-when`). Ambient/parallax effects use the offset form (`layer_offset += speed each FR`). This was the root cause of the v2.0.0 Flappy Bird failure where pipes were modeled as a shared offset rather than per-instance state.
- **SPEC §9 pitfall 12 — `@defs` hygiene.** No alias for a concept absent from source; every alias declared must appear in body; every alias used in body must be declared.
- **Skill step 6 verify checks** for both pitfalls 12 and 13.

## [2.0.0] — 2026-05-07 — Semver-aligned versioning, version provenance

### Changed (breaking)

- **Version scheme.** Bumped from `0.x` to `2.x` to reflect semver intent and that the language is now stable.
- **Versioning header protocol.** Every BOTSPEAK output begins with `<!-- BOTSPEAK vX.Y.Z · compressed by [model] · YYYY-MM-DD -->`. SPEC.md, SKILL.md, the format string, and the installed skill copy must all agree on version.
- **Archive protocol.** New skill or SPEC versions go to `skills/_archive/spec/v<seq>-<date>-<lines>L-<short-tag>.md` and `skills/_archive/botspeak/v<seq>-<date>-<lines>L-<short-tag>.md` so any prior version can be diffed against a regression.

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

> **Note on historical numbers:** the reduction percentages in this v0.1.0 entry
> (41% / 78% / 71% / 74% / 56%) reflect the more aggressive compression of the
> v0.1.0 skill. v2.x became deliberately more conservative — preserving fenced
> code blocks verbatim, refusing to drop named constraints, and verifying
> polarity — so current numbers for the same examples are lower (see the
> v2.2.0 entry above and `evals/round-trip-results.md` for the audited figures).
> The drop is intentional: clarity over compression.

### Added

- **SPEC.md** — language specification covering symbol vocabulary (ASCII + Symbol dialects), `@defs` aliases with reliability bounds, phase tags, grammar rules, document structure patterns, frontmatter preservation rules, and pitfalls.
- **Three skills**:
  - `/botspeak` — compress an existing AI-facing document into BOTSPEAK
  - `/capture-botspeak` — capture rambling chat input as a focused BOTSPEAK doc
  - `/translate-botspeak` — render any BOTSPEAK file into clear human prose (the round-trip safety net)
- **Cursor rule** (`.cursor/rules/botspeak.mdc`) — always-on rule for users who want BOTSPEAK applied automatically to new AI-facing docs.
- **Bidirectional agent** (`agents/botspeak-translator.md`) — auto-detects direction (BOTSPEAK ↔ prose) for tools that load agent definitions.
- **Five before/after examples** demonstrating short rules, context handoffs, Karpathy-style memory pages, project manifestos, and long aliased CLAUDE.md. See the note above on historical compression numbers.
- **Bootstrap files** (CLAUDE.md, AGENTS.md) for host-tool discovery.
- **install.sh** — installs skills into all detected agents (Claude Code, Cursor, Codex, Gemini CLI, generic AGENTS.md targets).

### Design decisions documented

- ASCII operators (`->`, `&&`, `!!`) recommended as primary because they tokenize to 1 token guaranteed in every modern BPE tokenizer; emoji symbols (`🔴`, `→`, `·`) presented as optional dialect for human-audited docs.
- `@defs` aliases scoped to first ~2K body tokens for literal-key recall reliability; longer documents must re-declare per major section (grounded in 2025 NoLiMa long-context benchmarks).
- Frontmatter explicitly off-limits to compression because `name`/`description`/`triggers` are how host tools route.
- Skill is the recommended primary delivery mechanism; rule and agent are presented as advanced/optional.
