# BOTSPEAK

**A way for bots to talk to bots.** Strip the human scaffolding. Keep the signal.

![Two bots chatting in BOTSPEAK](images/two-bots-chatting.png)

Human view: you are here  ·  Bot view: [README-FOR-AI.md](README-FOR-AI.md)  ·  Why: [PHILOSOPHY.md](PHILOSOPHY.md)  ·  Evals: [showcase](showcase/index.html)  ·  [MIT](LICENSE)

---

When two humans communicate, language is full of scaffolding. Articles like "the" and "a." Transitions like "as mentioned above." Hedging like "typically." Humans need that scaffolding because human cognition is sequential, distractible, and emotional. When a modern language model reads, almost none of it earns its place. **BOTSPEAK is what AI-to-AI documents look like when you remove what was only there for humans.**

A skill for AI coding agents:

**Primary mode** — Every new rule, skill, memory page, and handoff your agent writes comes out in BOTSPEAK automatically. No prompting. No reformatting. Structured docs by default.

**Secondary mode** — Compress your existing prose docs on demand. One file or an entire directory.

*Same information. The shorter token count is the measurement, not the motive — see [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## Before / After


| Document type                                         | Before (tokens) | After (tokens) | Reduction | Example folder                                                   |
| ----------------------------------------------------- | --------------- | -------------- | --------- | ---------------------------------------------------------------- |
| Context handoff (one session → next)                  | 1,019           | 624            | **39%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Project philosophy / manifesto rule                   | 1,748           | 1,005          | **42%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)     |
| Wiki / memory page (Karpathy LLM-wiki style)          | 1,003           | 758            | **24%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Short rule (branch guard)                             | 411             | 337            | **18%**   | [examples/01-short-rule/](examples/01-short-rule/)               |
| Long CLAUDE.md (the file your AI reads every session) | 8,083           | 7,159          | **11%**   | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan (code-heavy, 50% blocks)  | 12,063          | 9,783          | **19%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

*Token counts are character-count / 4, the standard GPT/Claude byte-pair-encoding approximation. Verify any row yourself: `wc -c examples/$N/before.md examples/$N/after.md`.*

**The real unlock is each individual file.** A prose-heavy strategic doc (philosophy rule, handoff, branch guard) compresses 18–42%. Code-heavy docs (long `CLAUDE.md`, architecture plans) land 11–19% because BOTSPEAK preserves fenced code blocks verbatim. Apply BOTSPEAK across your `CLAUDE.md`, rules, skills, memory pages, handoffs, and philosophy docs and the savings stack: a repo that burned 30,000 tokens before you typed your first word might cost 24,000. That's the difference between starting a session clear and starting it already underwater.

---

## What This Is in 30 Seconds

**Avoid the rot — speak bot.** Every rule, skill file, memory page, and handoff your agent re-reads every session was written in prose for humans. You're burning tokens before you type your first word.

**More signal, less noise.** BOTSPEAK = more context, less rot.

**BOTSPEAK** is a writing convention for documents whose primary reader is AI:

- **Symbol contracts** (`!!` = never, `ok` = allowed, `->` = leads to) defined once, used everywhere
- **Aliases** (`@defs E = establishment_id`) declared once, used as `E` everywhere after — kills the #1 token sink in real `CLAUDE.md` files
- **Phase tags** (`[NEW-CHAT]` `[ALWAYS]` `[REFERENCE]`) so agents skip context that doesn't apply to the current session phase
- **XML structure** for long docs because Claude parses XML semantic boundaries more reliably than markdown headings

**Still readable?** `/botspeak-translate` renders any BOTSPEAK file into clear human prose on demand.

---

## Won't Fewer Tokens Make My Agent Worse?

No. The opposite.

> [A 2025 paper](https://arxiv.org/abs/2604.00025v1) found that constraining LLMs to brief responses improved accuracy by **26 percentage points** on certain benchmarks.

Less noise in the context window means better attention on what matters. Compressed, structured instructions outperform verbose prose because attention is finite. Your agent will likely get *better*, not worse.

---

## Install

### Step 1 — Install the skills

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

Drops two skills into every AI agent we detect (Claude Code, Cursor, Codex, Gemini CLI, anything in `~/.agents`):

- `/botspeak` — compress a file or directory into BOTSPEAK. File ref: replaces in place. Pasted text: creates a new file. Flags: `-bu` backup first · `-c` output to chat.
- `/botspeak-translate` — render BOTSPEAK → human prose. Creates `[filename].bst.md` next to the original. Flag: `-c` to render in chat instead.

Opt-in. Nothing changes until you invoke one. Want it on all the time? Step 2.

### Step 2 — Install the always-on rule (manual, by design)

Makes every new AI-facing doc come out in BOTSPEAK by default — no prompting needed. Manual by design: IDE rule systems vary and we won't touch what you've already written.


| IDE                 | What to do                                                                                                                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Cursor**          | Copy [rules/botspeak-always-on.mdc](rules/botspeak-always-on.mdc) into `.cursor/rules/botspeak-always-on.mdc` in your project root. (For globally-active rules, paste the contents into Cursor Settings → Rules → User Rules.) |
| **Claude Code**     | Append the contents of [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to your project's `CLAUDE.md` (or `~/.claude/CLAUDE.md` for all projects).                                                                   |
| **Windsurf**        | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.windsurf/rules/botspeak-always-on.md` in your project root.                                                                                               |
| **Cline**           | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.clinerules/botspeak-always-on.md` in your project root.                                                                                                   |
| **Copilot**         | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.github/copilot-instructions.md`.                                                                                                                        |
| **Codex / generic** | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) into `AGENTS.md` in your project root.                                                                                                                         |
| **Anything else**   | Paste [rules/botspeak-always-on.md](rules/botspeak-always-on.md) wherever your harness keeps always-on instructions.                                                                                                           |


Don't see your IDE? Add it — see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## First 60 Seconds After Install

Open your agent and follow these four steps in order.

**1. Compress your most-read file.**

```
/botspeak -bu @CLAUDE.md
```

`-bu` saves a datestamped backup (`CLAUDE.bu.20260506.md`) before touching anything. The original is replaced in place with the BOTSPEAK version. You'll see a token-savings summary and a two-sentence description of what the file now says.

**2. Read it back in plain English (optional sanity check).**

```
/botspeak-translate @CLAUDE.md
```

Creates `CLAUDE.bst.md` next to the original — all aliases expanded, all symbols decoded. Open it, verify nothing drifted, delete it. Add `-c` to get the translation in chat instead of a file.

**3. Let BOTSPEAK write your next doc automatically.**  
*(requires the [always-on rule](#step-2--install-the-always-on-rule-manual-by-design) from Step 2)*

```
"Save what we just talked about as a handoff doc for tomorrow."
```

The agent writes the handoff in BOTSPEAK without being asked — correct notation, phase tags, aliases, everything. This is the main event: every new rule, skill, memory page, and handoff comes out compressed by default.

**4. Compress a whole folder at once.**

```
/botspeak ~/.cursor/skills/
```

The skill scans every `.md` and `.mdc` file, shows a token-count table with flags for large files, asks whether to back up first, then converts the whole directory and prints before/after totals. **Use a cheap model (Haiku, GPT-4o-mini) for big batches.**

---

## "I Need to Read a BOTSPEAK Document"

`/botspeak-translate @file` — creates `file.bst.md` next to the original. The translation is intentionally exhaustive: every abbreviation spelled out, every symbol expanded to full phrase, every constraint stated explicitly. This makes it more verbose than the original BOTSPEAK—that's by design. The extra words prove that nothing was lost in the compression; it just got restructured. Read it to verify what the BOTSPEAK actually says.

**You don't strictly need the skill.** Any modern AI can read a BOTSPEAK file and render it back to prose if you just ask — the format is built on patterns LLMs already understand. The skill exists so the AI knows exactly *how* the compression was done, which gives you a faithful one-to-one decompression instead of a paraphrase, with zero effort on your part. Skip it when good-enough is fine; use it when fidelity matters.

---

## The Four Things That Do the Work

### 1. Aliases (`@defs`) — the killer feature

Repeated identifiers are the #1 token sink. `establishment_id` 47 times. `materialized_view_refresh_concurrently` 23 times. Each one costs 4–8 tokens, every session, forever.

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

This block alone, used in a 2,000-token file, saves 400+ tokens. Every session.

### 2. Phase Tags

```
[NEW-CHAT]    load at session start; agent may skip after context established
[ALWAYS]      every turn
[ON-TRIGGER]  condition-gated; read only when pattern fires
[REFERENCE]   look-up only; skip during normal session load
[HANDOFF]     cross-session context; new agent reads first turn only
```

A correctly tagged 1,500-token file loads ~600 tokens mid-session. The rest is already-established context, deferred lookups, or first-turn orientation the agent doesn't need again.

### 3. Symbols

**ASCII** (recommended default — every symbol is 1 token guaranteed):

```
->   leads to       !!   never / forbidden
&&   AND            ok   allowed / correct
||   OR             ~~   warn / check first
!=   not-equal      =    defined-as
```

ASCII operators are 1 token each — guaranteed by every modern BPE tokenizer. See [SPEC.md](SPEC.md) for the full table.

### 4. XML Structure (for long docs)

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

All three major model families (Claude, GPT, Gemini) parse named XML blocks more reliably than loose markdown headings. `<context>`, `<defs>`, `<rules>`, `<reference>` — unambiguous boundaries, better retrieval.

---

## "Wait, won't this break things?" — FAQ

**Q: Doesn't the AI need prose to understand the rules?**  
A: No. LLMs are trained on code, JSON, XML, YAML, and math notation — structured text is their native language. The "lost in the middle" problem is *worse* for prose than for symbols. Try it yourself: BOTSPEAK a rule, then ask your agent to summarize it. The summary will match.

**Q: My IDE's skill tool wrote plain prose. Now what?**  
A: Expected — IDE tools don't know about BOTSPEAK. Run `/botspeak` on the file (or a whole directory: `/botspeak ~/.cursor/skills/`). With the always-on rule installed, anything the AI writes *for itself* comes out in BOTSPEAK from then on.

**Q: Should I rewrite all my existing rules right now?**  
A: No. Start with whatever your agent reads most — usually `CLAUDE.md` or your largest always-on rule. Compress that one, measure the savings, go from there.

**Q: How do I output to chat instead of a file?**  
A: Use `-c` or `--chat`. Works on both `/botspeak` and `/botspeak-translate`.

**Q: What if I want BOTSPEAK on all the time?**  
A: Install the always-on rule — [Step 2](#step-2--install-the-always-on-rule-manual-by-design).

**Q: What if I want to skip BOTSPEAK for just one document?**  
A: Say so: *"write this in prose"*, *"no botspeak"*, or just `-bs`.

**Q: What if a new agent on my team can't read it?**  
A: Every modern LLM (Claude, GPT, Gemini, Llama, Mistral) handles BOTSPEAK without preamble. If you're worried, drop `SPEC.md` into your project — the agent reads it once and you're set.

**Q: What about Caveman?**  
A: Different problem. [Caveman](https://github.com/JuliusBrussee/caveman) compresses what the AI *outputs to humans*. BOTSPEAK shapes what the AI *writes for other AI readers*. Install both — they compose perfectly.

**Q: Why not CRUX-Compress / llm-min.txt / Compresr?**  
A: Those are compressor *tools* — they process existing prose with a custom DSL. BOTSPEAK is a *writing convention*: write in it natively, no compressor required. We also ship a round-trip translate skill so you can always read your own files back.

**Q: How do I uninstall?**  
A: Run the uninstaller:

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```

Skills are removed from all detected agents automatically. *The always-on rule is not auto-removed* (it lives inside your IDE's rule system); the uninstaller tells you exactly where to look.

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


BOTSPEAK is the only convention (not tool) for AI-facing document writing and compression with a verified round-trip. We expect it to coexist with Caveman, not compete.

---

## What's in the Box

```
botspeak/
├── README.md                            ← you are here
├── README-FOR-AI.md                     ← BOTSPEAK-compressed version of this README
├── PHILOSOPHY.md                        ← the why — AI-to-AI communication thesis
├── SPEC.md                              ← language spec: symbols, aliases, grammar, pitfalls
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE                              ← MIT
├── CLAUDE.md, AGENTS.md, GEMINI.md      ← bootstrap files for AI agents working on this repo
├── install.sh                           ← one-line installer (skills only — rules install manually)
├── uninstall.sh                         ← removes skills from all detected agents
├── rules/                               ← always-on rule templates (manual install, see README)
│   ├── botspeak-always-on.md            ← universal markdown (Claude · Windsurf · Cline · Copilot · etc.)
│   └── botspeak-always-on.mdc           ← Cursor format (with alwaysApply frontmatter)
├── .cursor/rules/                       ← Cursor rules active in this repo (self-hosting)
├── skills/
│   ├── botspeak/SKILL.md                ← compress: file or directory → BOTSPEAK
│   ├── botspeak-translate/SKILL.md      ← translate: BOTSPEAK → [filename].bst.md
│   └── _archive/                        ← versioned history of every spec + skill
├── agents/
│   └── botspeak-translator.md           ← bidirectional agent (for tools that load agent definitions)
├── examples/                            ← six before/after pairs
│   ├── 01-short-rule/                   ← branch guard:                    411 →   337 (18%)
│   ├── 02-context-handoff/              ← session handoff:               1,019 →   624 (39%)
│   ├── 03-memory-page/                  ← Karpathy-style wiki page:      1,003 →   758 (24%)
│   ├── 04-philosophy-rule/              ← project manifesto:             1,748 → 1,005 (42%)
│   ├── 05-aliased-claude-md/            ← long CLAUDE.md (code-heavy):   8,083 → 7,159 (11%)
│   └── 06-backend-migration/            ← arch migration plan (code-heavy): 12,063 → 9,783 (19%)
├── showcase/index.html                  ← single-page eval rendering — open in browser to play
├── evals/                               ← round-trip + game synthesis evidence
│   ├── round-trip-results.md            ← canonical round-trip eval (v2.2.0)
│   ├── external-prompts/                ← real-world docs for clean-room reproduction
│   └── {game}-prompt/                   ← prose + BOTSPEAK + parity report per game
└── docs/
    ├── handoffs-archive/                ← historical investigation handoffs
    └── internal/                        ← v2.2.0 release planning artifacts
```

---

## On Karpathy's LLM Wiki

Andrej Karpathy's [LLM wiki pattern](https://github.com/Ar9av/obsidian-wiki) is the right idea: compile reusable knowledge once into interconnected markdown pages.

BOTSPEAK is the compressed upgrade path for that pattern: same operational meaning, fewer tokens per retrieval, lower recurring context burn. Your wiki grows; your token cost grows much slower.

See [examples/03-memory-page/](examples/03-memory-page/) for a concrete BOTSPEAK wiki-style page.

---

## Evals

The release is gated on two evidence signals — see the [showcase page](showcase/index.html) for the live artifacts.

**Round-trip fidelity** (the canonical eval) — compress 6 real AI-facing documents into BOTSPEAK, then audit. v2.2.0: **6 / 6 PASS** (up from 4 / 6 in v2.1.0). Three additional external real-world docs also pass; their sources are checked in at [evals/external-prompts/](evals/external-prompts/) so you can re-run them yourself. See [evals/round-trip-results.md](evals/round-trip-results.md).

**Game synthesis** (the stress test) — give a fresh model only the BOTSPEAK-compressed prompt and have it build a game. Compare the result to the prose-built version. Four games passed clean-room as of v2.2.0:

| Game | Compression | Physics constants matched |
|---|---|---|
| [Flappy Bird](evals/game-prompt/parity-report.md) | 31% | 15 / 15 |
| [Snake](evals/snake-prompt/parity-report.md) | 35% | 10 / 10 |
| [Pong](evals/pong-prompt/parity-report.md) | 39% | 14 / 14 |
| [Breakout](evals/breakout-prompt/parity-report.md) | 44% | 21 / 21 |

The showcase page renders both prose-built and BOTSPEAK-built versions side by side as live iframes you can play.

→ **[Open the showcase](showcase/index.html)** for the side-by-side comparison.

See [evals/README.md](evals/README.md) for methodology and how to run the evals yourself.

---

## Notes & Caveats

- **BOTSPEAK shines** on prose-heavy docs — rules, philosophy manifestos, handoffs, branch guards. Real measured range across our six canonical examples: **18–42% token reduction**. Game-prompt evals (also prose-heavy): **31–44%**.
- **BOTSPEAK slouches** on already-dense content — Mermaid diagrams, SQL, YAML configs, numeric tables, fenced code blocks, file trees. These get preserved byte-for-byte (verified by SPEC §9 pitfall 15). Code-heavy docs land **11–19%**. Still worth it: `@defs` aliases and phase tags sharpen agent behavior even when byte savings are modest.
- **Go cheap on batch jobs.** Directory compression is mechanical; Haiku-class models nail it at a fraction of the cost.
- **Timing:** Haiku clocks at ~~2 min / 50 KB (~~12.5K tokens). Rule of thumb: 200 KB ≈ 8 min. Thinking models (Sonnet, Opus) run 3–5× slower.
- `**.gitignore`: add `*.bst.md` and `*.bu.*.md`** to keep translated files and backups out of your repo. They're disposable artifacts — read them, toss them.
- `**/botspeak` replaces files in place.** Add `-bu` to keep a datestamped backup (`filename.bu.YYYYMMDD.md`) before compressing. Directory mode always offers the backup option before bulk conversion.

---

## License

MIT. Free, like your next context window.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight that token efficiency is a design choice. Built for the realization that AI is now a first-class reader of your codebase, and it deserves a format that respects its attention.*