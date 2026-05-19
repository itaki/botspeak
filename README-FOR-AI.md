<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-18 -->

# BOTSPEAK

@defs
  BT  = BOTSPEAK
  BST = /botspeak-translate
  AOR = always-on rule
@end

default-phase: REFERENCE

bot-to-bot notation · strip human scaffolding · keep signal

![Two bots chatting in BOTSPEAK](images/two-bots-chatting.png)

Human view: you are here · Bot view: [README-FOR-AI.md](README-FOR-AI.md) · Why: [PHILOSOPHY.md](PHILOSOPHY.md) · Evals: [showcase](showcase/index.html) · [MIT](LICENSE)

---

Human writing = scaffolding-heavy (articles · transitions · hedging). LLM cognition ≠ human → scaffolding earns nothing. BT = AI-to-AI docs without human scaffolding.

primary mode: new rules · skills · memory pages · handoffs -> BT automatically · no prompting
secondary mode: compress existing prose docs on demand · file or directory

*Same information. Shorter token count = measurement, not motive — see [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## Before / After

| Document type                                         | Before (tokens) | After (tokens) | Reduction | Example folder                                                   |
| ----------------------------------------------------- | --------------- | -------------- | --------- | ---------------------------------------------------------------- |
| Context handoff (one session → next)                  | 1,019           | 624            | **39%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Project philosophy / manifesto rule                   | 1,748           | 1,005          | **42%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)     |
| Wiki / memory page (Karpathy LLM-wiki style)          | 1,003           | 758            | **24%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Short rule (branch guard)                             | 411             | 337            | **18%**   | [examples/01-short-rule/](examples/01-short-rule/)               |
| Long CLAUDE.md (code-heavy)                           | 8,083           | 7,159          | **11%**   | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan (heavy code blocks)       | 12,063          | 9,783          | **19%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

*Tokens = chars / 4 (standard BPE approximation). Reproduce: `wc -c examples/$N/before.md examples/$N/after.md`.*

Per-file unlock: BT across CLAUDE.md · rules · skills · memory pages · handoffs. Prose-heavy: 18–42%. Code-heavy (fenced blocks preserved byte-for-byte): 11–19%. Repo burning 30,000 tokens before first word -> ~24,000.

---

## What BT Is

Every rule · skill · memory page · handoff agent re-reads every session = prose written for humans → token burn before first word.

BT = writing convention for AI-primary docs:

- **Aliases** (`@defs E = establishment_id`) declared once → `E` everywhere · kills #1 token sink in CLAUDE.md files
- **Symbol contracts** (`!!` = never · `ok` = allowed · `->` = leads to) defined once, used everywhere
- **Phase tags** (`[NEW-CHAT]` `[ALWAYS]` `[REFERENCE]`) → agents skip inapplicable context
- **XML structure** for long docs: Claude parses XML semantic boundaries more reliably than markdown headings

BST renders any BT file -> human prose on demand.

---

## Won't Fewer Tokens Make My Agent Worse?

No — opposite.

> [A 2025 paper](https://arxiv.org/abs/2604.00025v1) found that constraining LLMs to brief responses improved accuracy by **26 percentage points** on certain benchmarks.

Less noise -> better attention. Compressed structured instructions outperform verbose prose; attention is finite. Agent likely gets *better*, not worse.

---

## Install

### Step 1 — Install the skills

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

Drops two skills into every AI agent detected (Claude Code · Cursor · Codex · Gemini CLI · anything in `~/.agents`):

- `/botspeak` — compress file or directory -> BT · file ref: replaces in place · pasted text: creates new file · flags: `-bu` backup first · `-c` output to chat
- `BST` — render BT -> human prose · creates `[filename].bst.md` · flag: `-c` to render in chat

Opt-in. Nothing changes until invoked. Want always-on? Step 2.

### Step 2 — Install the AOR (manual, by design)

New AI-facing docs -> BT by default, no prompting. Manual by design: IDE rule systems vary; won't touch existing files.

| IDE                 | What to do                                                                                                                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Cursor**          | Copy [rules/botspeak-always-on.mdc](rules/botspeak-always-on.mdc) into `.cursor/rules/botspeak-always-on.mdc` in project root. (Global: paste contents into Cursor Settings → Rules → User Rules.) |
| **Claude Code**     | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to project's `CLAUDE.md` (or `~/.claude/CLAUDE.md` for all projects).                                                                   |
| **Windsurf**        | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.windsurf/rules/botspeak-always-on.md` in project root.                                                                               |
| **Cline**           | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.clinerules/botspeak-always-on.md` in project root.                                                                                   |
| **Copilot**         | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.github/copilot-instructions.md`.                                                                                                   |
| **Codex / generic** | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) into `AGENTS.md` in project root.                                                                                                         |
| **Anything else**   | Paste [rules/botspeak-always-on.md](rules/botspeak-always-on.md) wherever harness keeps always-on instructions.                                                                                           |

Don't see your IDE? Add it — see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## First 60 Seconds After Install

**1. Compress most-read file.**

```
/botspeak -bu @CLAUDE.md
```

`-bu` saves datestamped backup (`CLAUDE.bu.20260506.md`) before touching anything. Original replaced in place with BT version. Shows token-savings summary + two-sentence description.

**2. Read back in plain English (optional sanity check).**

```
/botspeak-translate @CLAUDE.md
```

Creates `CLAUDE.bst.md` next to original — aliases expanded · symbols decoded. Open · verify · delete. Add `-c` for translation in chat.

**3. Let BT write next doc automatically.**
*(requires [AOR](#step-2--install-the-always-on-rule-manual-by-design) from Step 2)*

```
"Save what we just talked about as a handoff doc for tomorrow."
```

Agent writes handoff in BT without being asked: correct notation · phase tags · aliases.

**4. Compress whole folder at once.**

```
/botspeak ~/.cursor/skills/
```

Scans every `.md` and `.mdc` file · shows token-count table with flags for large files · asks whether to back up first · converts directory · prints before/after totals. **Use cheap model (Haiku · GPT-4o-mini) for big batches.**

---

## Reading a BT Document

`BST @file` — creates `file.bst.md` next to original. Translation = intentionally exhaustive: every abbreviation spelled out · every symbol expanded · every constraint stated explicitly. More verbose than original BT by design — extra words prove nothing lost in compression.

skill = optional: any modern AI reads BT -> prose if asked. Skill provides faithful one-to-one decompression vs paraphrase. Use when fidelity matters; skip when good-enough.

---

## The Four Things That Do the Work

### 1. Aliases (`@defs`) — killer feature

Repeated identifiers = #1 token sink. `establishment_id` 47 times · `materialized_view_refresh_concurrently` 23 times · 4–8 tokens each · every session · forever.

```
@defs
  E   = establishment_id
  S   = establishment.settings.toast_config
  MV  = materialized-view
@end

[ALWAYS] all queries -> filter by E
[ON-TRIGGER] MV stale -> refresh-concurrently
!! never hardcode E && S && any per-establishment value
```

This block alone in 2,000-token file -> 400+ tokens saved. Every session.

### 2. Phase Tags

```
[NEW-CHAT]    load at session start; agent may skip after context established
[ALWAYS]      every turn
[ON-TRIGGER]  condition-gated; read only when pattern fires
[REFERENCE]   look-up only; skip during normal session load
[HANDOFF]     cross-session context; new agent reads first turn only
```

Correctly tagged 1,500-token file -> ~600 tokens loaded mid-session. Rest = established context · deferred lookups · first-turn orientation not needed again.

### 3. Symbols

**ASCII** (recommended default — every symbol is 1 token guaranteed):

```
->   leads to       !!   never / forbidden
&&   AND            ok   allowed / correct
||   OR             ~~   warn / check first
!=   not-equal      =    defined-as
```

ASCII operators = 1 token each, guaranteed by every modern BPE tokenizer. See [SPEC.md](SPEC.md) for full table.

### 4. XML Structure (long docs)

XML blocks outperform markdown headings for model reliability in long files.

```
<context>
  <defs>
    @defs
      E = establishment_id
    @end
  </defs>
  <rules>
    [ALWAYS] all queries -> filter by E
    [ON-TRIGGER] stale -> refresh
  </rules>
  <reference>
    examples/05-aliased-claude-md/after.md
  </reference>
</context>
```

All three major model families (Claude · GPT · Gemini) parse named XML blocks more reliably than loose markdown headings. `<context>` `<defs>` `<rules>` `<reference>` = unambiguous boundaries · better retrieval.

---

## FAQ

**Q: Doesn't AI need prose to understand rules?**
A: No. LLMs trained on code · JSON · XML · YAML · math — structured text = native language. "Lost in middle" problem worse for prose than symbols. BT a rule · ask agent to summarize → summary will match.

**Q: IDE skill tool wrote plain prose. Now what?**
A: Expected — IDE tools don't know about BT. Run `/botspeak` on file (or directory: `/botspeak ~/.cursor/skills/`). With AOR installed, anything AI writes *for itself* -> BT from then on.

**Q: Rewrite all existing rules right now?**
A: No. Start with most-read file — usually `CLAUDE.md` or largest always-on rule. Compress that one · measure savings · go from there.

**Q: Output to chat instead of file?**
A: Use `-c` or `--chat`. Works on `/botspeak` and BST.

**Q: BT always on?**
A: Install AOR — [Step 2](#step-2--install-the-always-on-rule-manual-by-design).

**Q: Skip BT for one document?**
A: Say so: *"write this in prose"* · *"no botspeak"* · `-bs`.

**Q: New agent on team can't read it?**
A: Every modern LLM (Claude · GPT · Gemini · Llama · Mistral) handles BT without preamble. Drop `SPEC.md` into project — agent reads once, set.

**Q: What about Caveman?**
A: Different problem. [Caveman](https://github.com/JuliusBrussee/caveman) compresses what AI *outputs to humans*. BT shapes what AI *writes for other AI readers*. Install both — they compose perfectly.

**Q: Why not CRUX-Compress / llm-min.txt / Compresr?**
A: Those = compressor *tools* — process existing prose with custom DSL. BT = *writing convention*: write in it natively, no compressor required. Round-trip translate skill included.

**Q: How to uninstall?**
A: Run uninstaller:

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```

Skills removed from all detected agents automatically. *AOR not auto-removed* (lives inside IDE's rule system); uninstaller tells you exactly where to look.

---

## Compared to Other Tools

|                          | BOTSPEAK                         | Caveman               | CRUX-Compress         | llm-min.txt      |
| ------------------------ | -------------------------------- | --------------------- | --------------------- | ---------------- |
| **Compresses**           | AI-facing docs (input)           | AI output to humans   | AI rules (input)      | API/library docs |
| **Approach**             | Writing convention               | Output style          | Compressor tool + DSL | Compressor tool  |
| **Aliases**              | ✅ `@defs`                        | —                     | —                     | —                |
| **Phase tags**           | ✅                                | —                     | —                     | —                |
| **Round-trip translate** | ✅ `/botspeak-translate`          | n/a (output is final) | —                     | —                |
| **Frontmatter-safe**     | ✅ (compresses body only)         | n/a                   | partial               | n/a              |
| **Multi-tool support**   | ✅ Claude/Cursor/Codex/Gemini/+25 | ✅ 30+ agents          | Claude/Cursor         | Generic          |
| **Stars (May 2026)**     | new                              | 53.9k                 | ~3                    | ~700             |

BT = only convention (not tool) for AI-facing document writing + compression with verified round-trip. Coexists with Caveman; not competing.

---

## What's in the Box

```
botspeak/
├── README.md · README-FOR-AI.md · PHILOSOPHY.md · SPEC.md · CHANGELOG.md · CONTRIBUTING.md · LICENSE
├── CLAUDE.md · AGENTS.md · GEMINI.md      ← per-host bootstrap
├── install.sh · uninstall.sh
├── rules/                                 ← AOR templates (manual install)
├── .cursor/rules/                         ← Cursor rules · self-hosting
├── skills/
│   ├── botspeak/SKILL.md                  ← compress · file or directory → BT
│   ├── botspeak-translate/SKILL.md        ← translate · BT → [filename].bst.md
│   └── _archive/                          ← versioned history · spec + skill
├── agents/botspeak-translator.md          ← bidirectional agent
├── examples/                              ← six before/after pairs
│   ├── 01-short-rule/                     ← branch guard:                  411 →   337 (18%)
│   ├── 02-context-handoff/                ← session handoff:             1,019 →   624 (39%)
│   ├── 03-memory-page/                    ← wiki page:                   1,003 →   758 (24%)
│   ├── 04-philosophy-rule/                ← project manifesto:           1,748 → 1,005 (42%)
│   ├── 05-aliased-claude-md/              ← long CLAUDE.md (code-heavy): 8,083 → 7,159 (11%)
│   └── 06-backend-migration/              ← migration plan (code-heavy): 12,063 → 9,783 (19%)
├── showcase/index.html                    ← single-page eval rendering
├── evals/
│   ├── round-trip-results.md              ← canonical round-trip (v2.2.0)
│   ├── external-prompts/                  ← real-world docs · clean-room repro
│   └── {game}-prompt/                     ← prose + BT + parity per game
└── docs/
    ├── handoffs-archive/                  ← historical handoffs
    └── internal/                          ← release planning artifacts
```

---

## On Karpathy's LLM Wiki

Andrej Karpathy's [LLM wiki pattern](https://github.com/Ar9av/obsidian-wiki) = right idea: compile reusable knowledge once into interconnected markdown pages.

BT = compressed upgrade path for that pattern: same operational meaning · fewer tokens per retrieval · lower recurring context burn. Wiki grows; token cost grows much slower.

See [examples/03-memory-page/](examples/03-memory-page/) for concrete BT wiki-style page.

---

## Evals

Release gated on two evidence signals — see [showcase page](showcase/index.html) for live artifacts.

**Round-trip fidelity** (canonical eval) — compress 6 real AI-facing docs -> BT · then audit. v2.2.0: **6 / 6 PASS** (up from 4 / 6 in v2.1.0). Three additional external real-world docs also pass; sources at [evals/external-prompts/](evals/external-prompts/) for clean-room reproduction. See [evals/round-trip-results.md](evals/round-trip-results.md).

**Game synthesis** (stress test) — give fresh model only BT-compressed prompt · have it build game · compare to prose-built version. Four games passed clean-room as of v2.2.0:

| Game | Compression | Physics constants matched |
|---|---|---|
| [Flappy Bird](evals/game-prompt/parity-report.md) | 31% | 15 / 15 |
| [Snake](evals/snake-prompt/parity-report.md) | 35% | 10 / 10 |
| [Pong](evals/pong-prompt/parity-report.md) | 39% | 14 / 14 |
| [Breakout](evals/breakout-prompt/parity-report.md) | 44% | 21 / 21 |

Showcase page renders both prose-built and BT-built versions side by side as live iframes.

→ **[Open the showcase](showcase/index.html)** for side-by-side comparison.

See [evals/README.md](evals/README.md) for methodology and how to run evals yourself.

---

## Notes & Caveats

- **BT shines** on prose-heavy docs — rules · philosophy manifestos · handoffs · branch guards. Measured range across six canonical examples: **18–42%**. Game-prompt evals (also prose-heavy): **31–44%**.
- **BT slouches** on already-dense content — Mermaid · SQL · YAML · numeric tables · fenced code blocks · file trees. These preserved byte-for-byte (SPEC §9 pitfall 15). Code-heavy docs land **11–19%**. Still worth it: `@defs` aliases + phase tags sharpen behavior even when byte savings modest.
- **Go cheap on batch jobs.** Directory compression = mechanical; Haiku-class models nail it at fraction of cost.
- **Timing:** Haiku clocks at ~2 min / 50 KB (~12.5K tokens). Rule of thumb: 200 KB ≈ 8 min. Thinking models (Sonnet · Opus) run 3–5× slower.
- `.gitignore`: add `*.bst.md` and `*.bu.*.md` to keep translated files and backups out of repo. Disposable artifacts — read them · toss them.
- `/botspeak` replaces files in place. Add `-bu` for datestamped backup (`filename.bu.YYYYMMDD.md`). Directory mode always offers backup option before bulk conversion.

---

## License

MIT. Free, like your next context window.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight that token efficiency = design choice. Built for realization that AI = first-class reader of your codebase, deserving format that respects its attention.*
