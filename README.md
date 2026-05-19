# BOTSPEAK

**A way for bots to talk to bots.** Strip the human scaffolding. Keep the signal.

![Two bots chatting in BOTSPEAK](images/two-bots-chatting.png)

- **You are here** (human view)
- For bots: [README-FOR-AI.md](README-FOR-AI.md)
- Deep understanding: [PHILOSOPHY.md](PHILOSOPHY.md)

<h2 align="center">

→ [Open the live showcase](showcase/index.html) ←

</h2>

<p align="center"><em>The real magic — four games, built two ways, identical physics. See for yourself.</em></p>

---

## The problem

Your agent re-reads the same files at the start of every session. `CLAUDE.md`, `AGENTS.md`, the rules folder, the skills folder, the last handoff. All of it was written in prose — for humans. Articles like "the" and "a." Transitions like "as mentioned above." Hedging like "typically." None of it earns its place inside a context window that's already paying for the conversation you haven't started yet.

You're burning tokens before you type your first word.

## The fix

BOTSPEAK is a writing convention for documents whose primary reader is AI. It removes only the parts that were written for human cognition and keeps everything an LLM actually parses — symbols, structure, constraints, code. Same information. Less rot. Two modes:

**Primary** — Every new rule, skill, memory page, and handoff your agent writes comes out in BOTSPEAK automatically. No prompting. No reformatting.

**Secondary** — Compress your existing prose docs on demand. One file or an entire directory.

*Same meaning. The token savings are the measurement, not the motive — see [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## Side by side: prose-built vs BOTSPEAK-built

[![BOTSPEAK showcase preview: prose-built Breakout next to BOTSPEAK-built Breakout, identical](images/showcase-preview.png)](showcase/index.html)

Four games — Flappy Bird, Snake, Pong, Breakout — built two ways. The left iframe is the game built from a prose specification by one model. The right iframe is the same game built from the BOTSPEAK-compressed version of that same spec by a different fresh model with no shared context. **They play identically.** Every physics constant matches.

| Game | Prose words | BOTSPEAK words | Compression | Physics matched |
|---|---:|---:|---:|---:|
| Flappy Bird | 1,415 | 974 | **31%** | 15 / 15 |
| Snake | 851 | 549 | **35%** | 10 / 10 |
| Pong | 1,350 | 820 | **39%** | 14 / 14 |
| Breakout | 1,499 | 838 | **44%** | 21 / 21 |

Same gravity, same bounce angle, same spawn cadence, same brick scoring, ~half the tokens. Click any game in the showcase to play it. Both columns work.

---

## Before / After (real documents)

| Document type                                         | Before | After | Reduction | Folder                                                           |
| ----------------------------------------------------- | ------:| -----:| ---------:| ---------------------------------------------------------------- |
| Short rule (branch guard)                             | 411    | 335   | **18%**   | [examples/01-short-rule/](examples/01-short-rule/)               |
| Context handoff (one session → next)                  | 1,019  | 624   | **39%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Wiki / memory page (Karpathy LLM-wiki style)          | 1,003  | 758   | **24%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Project philosophy / manifesto rule                   | 1,748  | 1,005 | **42%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)     |
| Long CLAUDE.md (the file your AI reads every session) | 8,083  | 7,159 | **11%**   | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan (code-heavy)              | 12,063 | 9,783 | **19%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

*Tokens = `chars / 4` (the standard GPT/Claude BPE approximation). Verify any row yourself: `wc -c examples/$N/before.md examples/$N/after.md`.*

Prose-heavy docs (rules, handoffs, philosophy) hit 18–42%. Code-heavy docs (long `CLAUDE.md`, architecture plans) hit 11–19% because BOTSPEAK preserves fenced code blocks verbatim. Stack BOTSPEAK across `CLAUDE.md`, rules, skills, memory pages, and handoffs and the savings compound: a repo that burned 30,000 tokens before your first word might cost 24,000.

---

## How it works

Five mechanisms do almost all of the work.

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

In a 2,000-token file, this block alone saves 400+ tokens. Every session.

### 2. Phase tags

```
[NEW-CHAT]    load at session start; agent may skip once context is established
[ALWAYS]      every turn
[ON-TRIGGER]  condition-gated; read only when the pattern fires
[REFERENCE]   look-up only; skip during normal session load
[HANDOFF]     cross-session context; new agent reads first turn only
```

A correctly tagged 1,500-token file loads ~600 tokens mid-session. The rest is established context, deferred lookups, or first-turn orientation the agent doesn't need again.

### 3. Symbol contracts

ASCII operators — 1 token each, guaranteed by every modern BPE tokenizer:

```
->   leads to       !!   never / forbidden
&&   AND            ok   allowed / correct
||   OR             ~~   warn / check first
!=   not-equal      =    defined-as
```

See [SPEC.md](SPEC.md) for the full table.

### 4. XML structure for long docs

XML tags outperform markdown headings for model reliability in long files. All three major model families (Claude, GPT, Gemini) parse named XML blocks more accurately than loose `##` headings.

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

`<context>`, `<defs>`, `<rules>`, `<reference>` — unambiguous boundaries, better retrieval.

### 5. Fenced code blocks preserved verbatim

Anything inside triple-backtick fences — Mermaid, SQL, YAML, regex, JSON, shell, file trees — is already dense. BOTSPEAK never rewrites it. Block count in the source equals block count in the output, byte-for-byte. This is why code-heavy docs still compress 11–19%: the prose around the blocks shrinks, the blocks themselves don't.

---

## Install — one line

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

This single command:

1. **Drops both skills** into every AI agent we detect — Claude Code, Cursor, Codex, Gemini CLI, anything under `~/.agents`.
   - `/botspeak` — compress a file or directory into BOTSPEAK. File ref replaces in place; pasted text creates a new file. Flags: `-bu` backup first · `-c` output to chat.
   - `/botspeak-translate` — render BOTSPEAK → human prose as `[filename].bst.md`. `-c` puts it in chat instead.
2. **Installs the always-on rule globally for Claude Code** by writing a managed block into `~/.claude/CLAUDE.md` (idempotent — re-run anytime to refresh). After install, every new AI-facing doc Claude writes comes out in BOTSPEAK by default.
3. **Prints paste-ready paths** for IDEs whose rules are per-project or live in a settings UI (Cursor, Windsurf, Cline, Copilot, Codex). Pick the one you use:

| IDE                 | Where the always-on rule goes                                                                                                                                          |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cursor (project)**| Copy [rules/botspeak-always-on.mdc](rules/botspeak-always-on.mdc) into `.cursor/rules/` in your project root.                                                          |
| **Cursor (global)** | Paste [rules/botspeak-always-on.md](rules/botspeak-always-on.md) into Cursor Settings → Rules → User Rules. (UI-only — no file path.)                                  |
| **Windsurf**        | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.windsurf/rules/`.                                                                                 |
| **Cline**           | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.clinerules/`.                                                                                     |
| **Copilot**         | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.github/copilot-instructions.md`.                                                                |
| **Codex / generic** | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `AGENTS.md` in your project root.                                                                 |

The rule itself is 14 lines. Don't see your IDE? [Add it](CONTRIBUTING.md).

> **Two things, one command.** BOTSPEAK ships *skills* (called explicitly, like `/botspeak @CLAUDE.md`) and an *always-on rule* (so the agent writes in BOTSPEAK by default without prompting). Skills install globally; rules live wherever your IDE keeps them. The installer handles both wherever it can and prints clear paste paths for the rest.

---

## First 60 seconds after install

**1 — Compress your most-read file.**

```
/botspeak -bu @CLAUDE.md
```

`-bu` saves a datestamped backup before touching anything. You'll see a token-savings summary and a one-line description of what the file now says.

**2 — Read it back in plain English (optional sanity check).**

```
/botspeak-translate @CLAUDE.md
```

Creates `CLAUDE.bst.md` next to the original — every alias expanded, every symbol decoded. Verify nothing drifted, then delete it. Add `-c` to get the translation in chat.

**3 — Let BOTSPEAK write the next doc automatically** *(requires the always-on rule)*.

```
"Save what we just talked about as a handoff doc for tomorrow."
```

The agent writes the handoff in BOTSPEAK without being asked — correct notation, phase tags, aliases, everything. This is the main event.

**4 — Compress a whole folder at once.**

```
/botspeak ~/.cursor/skills/
```

Scans every `.md` and `.mdc`, shows a token-count table, asks about backups, converts the directory, prints before/after totals. **Use a cheap model (Haiku, GPT-4o-mini) for big batches.**

---

## Evals

Two evidence signals gate every release — see the [showcase page](showcase/index.html) for the live artifacts.

**Round-trip fidelity** — compress 6 real AI-facing documents into BOTSPEAK, then audit every constraint, polarity marker, and code block. **6 / 6 PASS**. Three additional external real-world docs (Django `.cursorrules`, Rust `AGENTS.md`, ai-dev `.mdc`) also pass; their sources are checked in at [evals/external-prompts/](evals/external-prompts/) so you can re-run them clean-room. Full table: [evals/round-trip-results.md](evals/round-trip-results.md).

**Game synthesis** — give a fresh model only the BOTSPEAK-compressed prompt and have it build a game. Compare to the prose-built version. Four games pass clean-room:

| Game | Compression | Physics constants matched |
|---|---|---|
| [Flappy Bird](evals/game-prompt/parity-report.md) | 31% | 15 / 15 |
| [Snake](evals/snake-prompt/parity-report.md) | 35% | 10 / 10 |
| [Pong](evals/pong-prompt/parity-report.md) | 39% | 14 / 14 |
| [Breakout](evals/breakout-prompt/parity-report.md) | 44% | 21 / 21 |

Methodology and reproduction steps: [evals/README.md](evals/README.md).

---

## What's in the box

```
botspeak/
├── README.md                            ← you are here
├── README-FOR-AI.md                     ← BOTSPEAK-compressed version of this README
├── PHILOSOPHY.md                        ← the why — AI-to-AI communication thesis
├── SPEC.md                              ← language spec: symbols, aliases, grammar, pitfalls
├── CHANGELOG.md  ·  CONTRIBUTING.md  ·  LICENSE (MIT)
├── CLAUDE.md, AGENTS.md, GEMINI.md      ← bootstrap files for agents working on this repo
├── install.sh  ·  uninstall.sh          ← one-line installer / remover for skills
├── rules/                               ← always-on rule templates (manual install)
├── skills/
│   ├── botspeak/SKILL.md                ← compress: file or directory → BOTSPEAK
│   ├── botspeak-translate/SKILL.md      ← translate: BOTSPEAK → [filename].bst.md
│   └── _archive/                        ← versioned history of every spec + skill
├── agents/botspeak-translator.md        ← bidirectional agent
├── examples/                            ← six before/after pairs (token-verified)
├── showcase/index.html                  ← single-page eval rendering — open in a browser
├── evals/                               ← round-trip + game-synthesis evidence
└── docs/                                ← handoff archive + internal release notes
```

---

## FAQ

**Q: Won't fewer tokens make my agent worse?**
A: No — usually better. A 2025 paper found that constraining LLMs to brief responses improved accuracy by 26 percentage points on certain benchmarks. Less noise in the context window means better attention on what matters.

**Q: Doesn't the AI need prose to understand the rules?**
A: No. LLMs are trained on code, JSON, XML, YAML, and math notation — structured text is their native language. The "lost in the middle" problem is *worse* for prose than for symbols.

**Q: My IDE's skill tool wrote plain prose. Now what?**
A: Expected — IDE tools don't know about BOTSPEAK. Run `/botspeak` on the file. With the always-on rule installed, anything the AI writes for itself comes out in BOTSPEAK from then on.

**Q: Should I rewrite all my existing rules right now?**
A: No. Start with whatever your agent reads most — usually `CLAUDE.md` or your largest always-on rule. Compress that one, measure, go from there.

**Q: How do I skip BOTSPEAK for one doc?**
A: Say *"write this in prose"*, *"no botspeak"*, or `-bs`.

**Q: What if a new agent on my team can't read it?**
A: Every modern LLM (Claude, GPT, Gemini, Llama, Mistral) reads BOTSPEAK without preamble. If you're worried, drop `SPEC.md` into the project once.

**Q: What about Caveman?**
A: Different problem. [Caveman](https://github.com/JuliusBrussee/caveman) compresses what the AI *outputs to humans*. BOTSPEAK shapes what the AI *writes for other AI readers*. Install both — they compose.

**Q: Why not CRUX-Compress, llm-min.txt, Compresr?**
A: Those are compressor tools that process existing prose via a custom DSL. BOTSPEAK is a *writing convention* — write in it natively, no compressor required. The round-trip translate skill means you can always read your own files back.

**Q: How do I uninstall?**

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```

Skills are removed automatically. The always-on rule lives inside your IDE's rule system; the uninstaller tells you where to look.

---

## Operational notes

- **`.gitignore` two patterns:** `*.bst.md` (translated files) and `*.bu.*.md` (backups). Both are disposable artifacts.
- **`/botspeak` replaces files in place.** Add `-bu` to keep a datestamped backup before compressing. Directory mode always asks first.
- **Batch jobs:** directory compression is mechanical — use a cheap model. Haiku clocks ~2 min / 50 KB. Thinking models (Sonnet, Opus) are 3–5× slower at the same job.

---

## License

MIT. Free, like your next context window.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight that token efficiency is a design choice. Built for the realization that AI is now a first-class reader of your codebase, and it deserves a format that respects its attention.*
