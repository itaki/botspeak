# BOTSPEAK

**A way for bots to talk to bots.** Strip the human scaffolding. Keep the signal.

![Two bots chatting in BOTSPEAK](images/two-bots-chatting.png)

- **You are here** (human view)
- For bots: [README-FOR-AI.md](README-FOR-AI.md)
- Deep understanding: [PHILOSOPHY.md](PHILOSOPHY.md)

<h2 align="center">

→ [Open the live showcase](showcase/index.html) ←

</h2>

<p align="center"><em>Four games, two builds, identical physics.</em></p>

<p align="center"><sub>Local clone: <code>python3 -m http.server</code> from the repo root, then open <a href="http://localhost:8000/showcase/index.html"><code>http://localhost:8000/showcase/index.html</code></a> — most browsers block cross-file iframe loading from <code>file://</code>.</sub></p>

---

## The problem

Your agent now writes for other agents — `CLAUDE.md`, `AGENTS.md`, plans, handoffs, subagent prompts. Almost none of it is for you, but all of it is still prose.

### `prose -> tokens++ -> context-- -> signal--`

Worst case is fan-out: a main agent fires prose at ten subagents and pays for prose coming back. Both legs are addressable.

## The fix

A March 11, 2026 paper, ["Brevity Constraints Reverse Performance Hierarchies in Language Models"](https://arxiv.org/abs/2604.00025v1), found that constraining LLMs to brief responses improved accuracy on certain benchmarks.

A writing convention for any output whose primary reader is AI. Keep symbols, structure, constraints, code. Drop the rest.

- **Files** — your agent writes new rules, skills, memory pages, and handoffs in BOTSPEAK by default.
- **Compress** — convert existing prose docs on demand (`/botspeak @file` or a folder).
- **Subagents** — outgoing briefs and incoming reports both compress. Double savings on every fan-out.

Anthropic's [prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) endorses the underlying moves: XML structure for unambiguous parsing, long input above the query (up to 30% quality gain), terse over verbose. BOTSPEAK applies them consistently.

*Token savings are the measurement, not the motive — [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

- **Skills** — `/botspeak` and `/botspeak-translate` installed into every detected agent (Claude Code, Cursor, Codex, Gemini CLI, `~/.agents`).
- **Always-on rule** — idempotent managed block written into `~/.claude/CLAUDE.md`. New AI-facing docs come out in BOTSPEAK by default.
- **Paste paths** — printed for IDEs whose rules are per-project or UI-only:

| IDE                 | Where the always-on rule goes                                                                                                                  |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cursor (project)**| Copy [rules/botspeak-always-on.mdc](rules/botspeak-always-on.mdc) into `.cursor/rules/`.                                                       |
| **Cursor (global)** | Paste [rules/botspeak-always-on.md](rules/botspeak-always-on.md) into Cursor Settings → Rules → User Rules.                                    |
| **Windsurf**        | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.windsurf/rules/`.                                                         |
| **Cline**           | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.clinerules/`.                                                             |
| **Copilot**         | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `.github/copilot-instructions.md`.                                        |
| **Codex / generic** | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) to `AGENTS.md`.                                                              |

Rule is 14 lines. Don't see your IDE? [Add it](CONTRIBUTING.md).

---

## Side by side

[![BOTSPEAK showcase preview: prose-built Breakout next to BOTSPEAK-built Breakout, identical](images/showcase-preview.png)](showcase/index.html)

Four games. Left iframe built from a prose spec by a clean-room Claude Sonnet 4.6 subagent. Right iframe built from the BOTSPEAK-compressed version by a separate clean-room Sonnet 4.6 subagent. Neither subagent saw the other's prompt or output. Same model, isolated sessions — that's what these runs test. They play identically.

| Game | Prose tokens | BOTSPEAK tokens | Reduction | Constants matched |
|---|---:|---:|---:|---:|
| Flappy Bird | 1,934 | 1,729 | **11%** | 15 / 15 |
| Snake | 1,192 | 895 | **25%** | 10 / 10 |
| Pong | 1,892 | 1,461 | **23%** | 14 / 14 |
| Breakout | 2,175 | 1,603 | **26%** | 21 / 21 |

Token counts are `o200k_base` (GPT/Claude family). Word counts are also tracked in `evals/scripts/token-counts.json` if you prefer them — words reduce more (31–44%) because prose has more articles and connectives than tokens do. Constants match is the count of physics constants (gravity, paddle speed, brick layout, etc.) that an [automated parity script](evals/scripts/parity_check.py) confirmed are present in both HTML builds.

→ [**Open the showcase**](showcase/index.html) to play either column.

---

## Before / After

All token counts on this page are `o200k_base` (the GPT/Claude family tokenizer). Reproduce any row by running `python3 evals/scripts/count_tokens.py` from the repo root.

### Real `CLAUDE.md` from popular repos (lead with these — externally authored, hard to game)

| Repository (stars)                          | Before tok | After tok | Reduction | Folder                                                                       |
| ------------------------------------------- | ----------:| ---------:| ---------:| ---------------------------------------------------------------------------- |
| [`obra/superpowers`][sp] (198K ★)           | 1,533      | 1,377     | **10%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)                 |
| [`langchain-ai/langchain`][lc] (137K ★)     | 2,934      | 2,810     | **4%**    | [examples/07-langchain-claude-md/](examples/07-langchain-claude-md/)         |
| [`browser-use/browser-use`][bu] (94K ★)     | 2,495      | 2,179     | **13%**   | [examples/08-browser-use-claude-md/](examples/08-browser-use-claude-md/)     |
| [`BerriAI/litellm`][ll] (47K ★)             | 3,565      | 3,338     | **6%**    | [examples/09-litellm-claude-md/](examples/09-litellm-claude-md/)             |

[sp]: https://github.com/obra/superpowers
[lc]: https://github.com/langchain-ai/langchain
[bu]: https://github.com/browser-use/browser-use
[ll]: https://github.com/BerriAI/litellm

These files were already hand-tuned by hundreds of contributors. 4–13% reduction is on top of that pre-optimization. Every constraint, every prohibition, every code block survives — verified by the [round-trip audit](evals/round-trip-results.md).

### Synthetic before/after (five document types we audit end-to-end)

| Document type                                         | Before tok | After tok | Reduction | Folder                                                           |
| ----------------------------------------------------- | ----------:| ---------:| ---------:| ---------------------------------------------------------------- |
| Short rule (branch guard)                             | 381        | 352       | **8%**    | [examples/01-short-rule/](examples/01-short-rule/)               |
| Context handoff                                       | 807        | 567       | **30%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Wiki / memory page                                    | 892        | 763       | **14%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Long CLAUDE.md (restaurant ops)                       | 7,807      | 7,081     | **9%**    | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan                           | 11,777     | 9,937     | **16%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

Lower numbers than you'd see on a first naive pass — that's the point. SPEC v2.2.0 preserves fenced code blocks verbatim (§4), refuses to drop named constraints (§9 pitfall 12), and verifies polarity (§9 pitfall 14). Compression is what survives those checks, not what an aggressive rewrite would produce.

---

## Human-to-bot understanding

Five mechanisms. Each one leans on something bots parse better than you do.

### Aliases (`@defs`)

Repeat `establishment_id` 47 times. Repeat `E` 47 times. Save ~280 tokens, every session.

```
@defs
  E   = establishment_id
  MV  = materialized-view
@end

[ALWAYS] all queries -> filter by E
[ON-TRIGGER] MV stale -> refresh-concurrently
!! never hardcode E
```

### Phase tags

`[NEW-CHAT]` · `[ALWAYS]` · `[ON-TRIGGER]` · `[REFERENCE]` · `[HANDOFF]`. The agent knows what to load when, no English required. A 1,500-token file may load ~600 mid-session.

### Symbol contracts

ASCII operators — one token each on every modern BPE tokenizer.

```
->   leads to       !!   never
&&   AND            ||   OR
!=   not-equal      =    defined-as
~~   warn           ok   allowed
```

Full table: [SPEC.md](SPEC.md).

### XML for long docs

XML tags "help Claude parse complex prompts unambiguously" ([Anthropic prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)). Markdown headings are hints; XML tags are boundaries.

```
<context>
  <defs>…</defs>
  <rules>…</rules>
  <reference>…</reference>
</context>
```

### Fenced code blocks preserved verbatim

Regex, Mermaid, JSON, SQL — already dense, already native to LLMs. BOTSPEAK never rewrites the inside of a triple-backtick fence. The prose around shrinks; the blocks don't. That's why code-heavy docs cap at single-digit percentage reductions, and that's correct: the code is the highest-value content in those docs, and the SPEC §9 pitfall 15 check enforces it.

---

## First 60 seconds after install

```
/botspeak -bu @CLAUDE.md          # compress your most-read file (-bu = backup first)
/botspeak-translate @CLAUDE.md    # read it back in plain English
/botspeak ~/.cursor/skills/       # compress a whole folder; use a cheap model
```

Then ask your agent to save the next handoff. With the always-on rule installed, it comes out in BOTSPEAK automatically — that's the main event.

---

## Evals

- **Constraint-preservation audit** — 9 AI-facing docs compressed to BOTSPEAK (5 synthetic, 4 real-world CLAUDE.md from 47K–198K-star repos), audited for polarity (SPEC §9 pitfall 14), code-block parity (§9 pitfall 15), alias hygiene (§9 pitfall 12), and constraint preservation. **9 / 9 PASS**. Methodology and per-row evidence: [evals/round-trip-results.md](evals/round-trip-results.md). Plus three external docs (Django `.cursorrules`, Rust `AGENTS.md`, ai-dev `.mdc`) that pass when re-run clean-room from `evals/external-prompts/`.
- **Game synthesis** — a Sonnet 4.6 subagent gets only the BOTSPEAK prompt and no prior context, builds the game; a separate Sonnet 4.6 subagent builds from the prose spec. An [automated parity script](evals/scripts/parity_check.py) extracts numeric constants from both HTML builds and confirms they match. Four games pass clean-room (table above; full methodology in [evals/README.md](evals/README.md)). Same model, isolated sessions — that's what these runs validate. Cross-model parity is a v2.3 target, not a v2.2 claim.

---

## What's in the box

```
botspeak/
├── README.md                            ← you are here
├── README-FOR-AI.md                     ← BOTSPEAK-compressed version of this README
├── PHILOSOPHY.md                        ← AI-to-AI communication thesis
├── SPEC.md                              ← symbols, aliases, grammar, pitfalls
├── CHANGELOG.md · CONTRIBUTING.md · LICENSE (MIT)
├── CLAUDE.md, AGENTS.md, GEMINI.md      ← bootstrap files for agents in this repo
├── install.sh · uninstall.sh
├── rules/                               ← always-on rule templates
├── skills/
│   ├── botspeak/SKILL.md                ← compress: file or directory → BOTSPEAK
│   ├── botspeak-translate/SKILL.md      ← translate: BOTSPEAK → [filename].bst.md
│   └── _archive/
├── agents/botspeak-translator.md
├── examples/                            ← nine before/after pairs (token-verified)
├── showcase/index.html                  ← single-page eval rendering
├── evals/
└── docs/
```

---

## FAQ

**Won't fewer tokens make my agent worse?**
Usually better. Anthropic's [prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) calls Claude's latest models "less verbose" by design; XML-tagged structured input "can improve response quality by up to 30%" over loose prose.

**Doesn't the AI need prose?**
No. LLMs are native to HTML, JSON, XML, YAML, regex, Python, Rust, SQL, Mermaid, math, and dozens of DSLs. A SQL migration that will never run can spec a data shape more precisely than three paragraphs about it. Pick the densest notation that fits.

**My IDE wrote plain prose. Now what?**
Run `/botspeak` on the file. With the always-on rule installed, new docs come out in BOTSPEAK from then on.

**Should I rewrite everything now?**
No. Start with whatever your agent reads most — usually `CLAUDE.md`.

**Skip BOTSPEAK for one doc?**
Pass `-p` (think *p*rose). Or just say "write this in prose."

**New agent can't read it?**
Every modern LLM (Claude, GPT, Gemini, Llama, Mistral) reads BOTSPEAK without preamble. Drop `SPEC.md` into the project once if you're nervous.

**vs Caveman?**
Different layer. [Caveman](https://github.com/JuliusBrussee/caveman) shapes AI → human output. BOTSPEAK shapes AI → AI files. They compose.

**vs CRUX-Compress / llm-min.txt / Compresr?**
Those are post-hoc compressors. BOTSPEAK is a writing convention — write it natively, no compressor required.

**Uninstall**

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```

---

## Operational notes

- `.gitignore` two patterns: `*.bst.md` (translations) and `*.bu.*.md` (backups). Both disposable.
- `/botspeak` replaces files in place. Add `-bu` to keep a backup. Directory mode always asks first.
- Batch jobs: use a cheap model (Haiku, GPT-4o-mini). Thinking models are 3–5× slower for no quality gain on mechanical compression.

---

## License

MIT.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight that token efficiency is a design choice.*
