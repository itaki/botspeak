# BOTSPEAK

**A way for bots to talk to bots.** Strip the human scaffolding. Keep the signal.

![Two bots chatting in BOTSPEAK](images/two-bots-chatting.png)

- **You are here** (human view)
- For bots: [README-FOR-AI.md](README-FOR-AI.md)
- Deep understanding: [PHILOSOPHY.md](PHILOSOPHY.md)

<h2 align="center">

→ [Open the live showcase](https://itaki.github.io/botspeak/showcase/) ←

</h2>

<p align="center"><em>Four games, two builds, identical physics.</em></p>

<p align="center"><sub>Hosted on GitHub Pages. Offline? Run <code>python3 -m http.server</code> from a clone and open <code>http://localhost:8000/showcase/index.html</code> — browsers block iframe loading from <code>file://</code>.</sub></p>

---

## The problem

Your agent now writes for other agents — `CLAUDE.md`, `AGENTS.md`, plans, handoffs, subagent prompts. Almost none of it is for you, but all of it is still prose: articles, transitions, hedging, scaffolding for human cognition that the next AI reader doesn't need and pays for anyway.

### `prose -> tokens++ -> context-- -> signal--`

Worst case is fan-out. When a main agent spawns ten subagents, every brief going out is prose and every reply coming back is prose. The main agent's context fills with both sides of a conversation written for an audience that doesn't exist — and unlike a file you write once and ship, those costs repeat on every task.

## The fix

Cutting prose isn't just about saving money. A March 11, 2026 paper, <a href="https://arxiv.org/abs/2604.00025v1" target="_blank" rel="noopener noreferrer">"Brevity Constraints Reverse Performance Hierarchies in Language Models"</a>, found that constraining LLMs to brief responses improved accuracy on certain benchmarks. Less noise really does mean better attention.

BOTSPEAK is a writing convention for any output whose primary reader is AI — a file on disk or a prompt sent to another agent. It keeps symbols, structure, constraints, and code, and drops everything that was only there for human cognition. Same information, less rot.

Three modes:

- **Files** — your agent writes new rules, skills, memory pages, and handoffs in BOTSPEAK by default. No prompting, no reformatting.
- **Compress** — convert existing prose docs on demand: `/botspeak @file`, or point it at a whole folder.
- **Subagents** — outgoing briefs and incoming reports both compress. Every fan-out saves tokens twice, and the workers get clearer instructions because BOTSPEAK strips ambiguity along with the prose.

Anthropic's <a href="https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices" target="_blank" rel="noopener noreferrer">prompting guide</a> endorses the underlying moves — XML structure for unambiguous parsing, long input above the query (up to 30% quality gain), terse over verbose. BOTSPEAK applies them consistently across every doc and every subagent call.

*Token savings are the measurement, not the motive — see [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

That one command does three things:

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

[![BOTSPEAK showcase preview: prose-built Breakout next to BOTSPEAK-built Breakout, identical](images/showcase-preview.png)](https://itaki.github.io/botspeak/showcase/)

Four games. Left iframe built from a prose spec by a clean-room Claude Sonnet 4.6 subagent. Right iframe built from the BOTSPEAK-compressed version by a separate clean-room Sonnet 4.6 subagent. Neither subagent saw the other's prompt or output. Same model, isolated sessions — that's what these runs test. They play identically.

| Game | Prose tokens | BOTSPEAK tokens | Reduction | Constants matched |
|---|---:|---:|---:|---:|
| Flappy Bird | 1,934 | 1,729 | **11%** | 15 / 15 |
| Snake | 1,192 | 895 | **25%** | 10 / 10 |
| Pong | 1,892 | 1,461 | **23%** | 14 / 14 |
| Breakout | 2,175 | 1,603 | **26%** | 21 / 21 |

Token counts are `o200k_base` (GPT/Claude family). Word counts are also tracked in `evals/scripts/token-counts.json` if you prefer them — words reduce more (31–44%) because prose has more articles and connectives than tokens do. Constants match is the count of physics constants (gravity, paddle speed, brick layout, etc.) that an [automated parity script](evals/scripts/parity_check.py) confirmed are present in both HTML builds.

→ [**Open the showcase**](https://itaki.github.io/botspeak/showcase/) to play either column.

---

## Before / After

All token counts on this page are `o200k_base` (the GPT/Claude family tokenizer). Reproduce any row by running `python3 evals/scripts/count_tokens.py` from the repo root.

### Real `CLAUDE.md` from popular repos (lead with these — externally authored, hard to game)

| Repository (stars)                          | Before tok | After tok | Reduction | Folder                                                                       |
| ------------------------------------------- | ----------:| ---------:| ---------:| ---------------------------------------------------------------------------- |
| <a href="https://github.com/obra/superpowers" target="_blank" rel="noopener noreferrer"><code>obra/superpowers</code></a> (198K ★)         | 1,533      | 1,377     | **10%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)                 |
| <a href="https://github.com/langchain-ai/langchain" target="_blank" rel="noopener noreferrer"><code>langchain-ai/langchain</code></a> (137K ★)   | 2,934      | 2,810     | **4%**    | [examples/07-langchain-claude-md/](examples/07-langchain-claude-md/)         |
| <a href="https://github.com/browser-use/browser-use" target="_blank" rel="noopener noreferrer"><code>browser-use/browser-use</code></a> (94K ★) | 2,495      | 2,179     | **13%**   | [examples/08-browser-use-claude-md/](examples/08-browser-use-claude-md/)     |
| <a href="https://github.com/BerriAI/litellm" target="_blank" rel="noopener noreferrer"><code>BerriAI/litellm</code></a> (47K ★)             | 3,565      | 3,338     | **6%**    | [examples/09-litellm-claude-md/](examples/09-litellm-claude-md/)             |

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

Bots and humans parse text differently. Bots track symbols, tags, and discrete tokens more reliably than they track flowing English; humans are the reverse. Five mechanisms in BOTSPEAK exploit that gap.

### Aliases (`@defs`)

Repeated identifiers are the single largest token sink in a typical agent file. Bind them once at the top, use the short form everywhere else. A human reader has to scroll back to remember what `E` means; a bot binds the symbol once and tracks it without slipping.

```
@defs
  E   = establishment_id
  MV  = materialized-view
@end

[ALWAYS] all queries -> filter by E
[ON-TRIGGER] MV stale -> refresh-concurrently
!! never hardcode E
```

In a 2,000-token file, the aliases block alone saves ~280 tokens. Every session.

### Phase tags

A human would write *"please load this at session start, but you can skip it once context is established."* A bot reads `[NEW-CHAT]` once and knows the lifecycle.

```
[NEW-CHAT]    load at session start; agent may skip once context is established
[ALWAYS]      every turn
[ON-TRIGGER]  condition-gated; read only when the pattern fires
[REFERENCE]   look-up only; skip during normal session load
[HANDOFF]     cross-session context; new agent reads first turn only
```

A correctly tagged 1,500-token file may load ~600 tokens mid-session. The rest is deferred lookups and first-turn orientation the agent doesn't need again.

### Symbol contracts

ASCII operators are one token each on every modern BPE tokenizer. They look like noise without a legend, but the model treats each one as a logical primitive without a decoding step.

```
->   leads to       !!   never
&&   AND            ||   OR
!=   not-equal      =    defined-as
~~   warn           ok   allowed
```

Full table: [SPEC.md](SPEC.md).

### XML for long docs

Markdown headings (`## context`) are hints; XML tags (`<context>…</context>`) are boundaries. Anthropic's <a href="https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices" target="_blank" rel="noopener noreferrer">prompting guide</a> is explicit: XML tags "help Claude parse complex prompts unambiguously," and for long inputs you should "structure document content and metadata with XML tags." Humans find the angle brackets noisy. Bots treat them as schema.

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

Three quick checks to confirm everything's wired up:

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
Usually better. Anthropic's <a href="https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices" target="_blank" rel="noopener noreferrer">prompting guide</a> calls Claude's latest models "less verbose" by design; XML-tagged structured input "can improve response quality by up to 30%" over loose prose.

**Doesn't the AI need prose?**
No. LLMs are native to HTML, JSON, XML, YAML, regex, Python, Rust, SQL, Mermaid, math, and dozens of DSLs. A SQL migration that will never run can spec a data shape more precisely than three paragraphs about it. Pick the densest notation that fits.

**My IDE wrote plain prose. Now what?**
Run `/botspeak` on the file. With the always-on rule installed, new docs come out in BOTSPEAK from then on.

**Should I rewrite everything now?**
No. Start with whatever your agent reads most — usually `CLAUDE.md` or your largest always-on rule. Compress one file, measure the difference, then expand from there.

**Skip BOTSPEAK for one doc?**
Pass `-p` (think *p*rose), or just say "write this in prose." The flag used to be `-bs`, which read ambiguously — `-p` is unambiguous: dash-p, prose.

**New agent can't read it?**
Every modern LLM (Claude, GPT, Gemini, Llama, Mistral) reads BOTSPEAK without preamble. If you're worried about a model you don't recognize, drop `SPEC.md` into the project once and the agent reads it on first load.

**vs Caveman?**
Different layer. <a href="https://github.com/JuliusBrussee/caveman" target="_blank" rel="noopener noreferrer">Caveman</a> shapes AI → human output. BOTSPEAK shapes AI → AI files. They compose.

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

*Inspired by <a href="https://github.com/JuliusBrussee/caveman" target="_blank" rel="noopener noreferrer">Caveman</a>'s insight that token efficiency is a design choice.*
