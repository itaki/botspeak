# BOTSPEAK

**A language for bots to talk to bots.** Stop wasting tokens on prose your AI doesn't read.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Before / After

| Document type | Before | After (BOTSPEAK) | Reduction |
|---|---|---|---|
| **Long CLAUDE.md** (the file your AI reads every session) | 985 words | 433 words | **56%** |
| Project philosophy / manifesto rule | 1,095 words | 285 words | **74%** |
| Context handoff (one session → next) | 640 words | 138 words | **78%** |
| Wiki / memory page (Karpathy LLM-wiki style) | 612 words | 178 words | **71%** |
| Short rule (branch guard) | 262 words | 154 words | 41% |

Every behavioral constraint, invariant, trigger, and exception preserved. See [`examples/`](examples/) for the full before/after pairs.

**The biggest win: the long `CLAUDE.md` example saves ~550 words on every single session.** Read 200 sessions a year — that's 110,000 words of unnecessary input tokens cut. The agent gets the same instructions in less context, with more room left for actual work.

---

## What This Is, in 30 Seconds

Your AI agent reads your `CLAUDE.md`, `AGENTS.md`, every `.cursor/rules/*.mdc`, every skill file, every memory file — every single session. A human might read those files once. The other 999 times, an LLM is parsing prose written for an audience that isn't there.

BOTSPEAK is a writing convention for documents whose primary reader is an AI:

- **Symbol contracts** (`!!` = never, `ok` = allowed, `->` = leads to) defined once, used everywhere
- **Aliases** (`@defs E = establishment_id`) declared once, used as `E` everywhere after — kills the #1 token sink in real `CLAUDE.md` files
- **Phase tags** (`[NEW-CHAT]` `[ALWAYS]` `[REFERENCE]`) so agents skip context that doesn't apply to the current session phase
- **XML structure** for long docs because Claude parses XML semantic boundaries more reliably than markdown headings

Still readable. A `/translate-botspeak` skill renders any BOTSPEAK file into clear human prose on demand — you'll rarely need it, but it's there.

---

## Install (the skill — the recommended primary)

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

Installs three skills into every AI agent we detect:

- **`/botspeak`** — compress an existing AI-facing document
- **`/capture-botspeak`** — capture rambling chat input as a focused BOTSPEAK doc
- **`/translate-botspeak`** — render any BOTSPEAK file → clear human prose

The skill is opt-in: nothing changes until you invoke it. No surprises. Easy to test, easy to uninstall.

If you want it always-on (BOTSPEAK applied automatically when your agent writes new AI-facing docs), see the [Cursor rule](.cursor/rules/botspeak.mdc) and the [agent definition](agents/botspeak-translator.md). Both are advanced.

---

## First 60 Seconds After Install

Open your agent. Try one of these:

```
"Compress my CLAUDE.md into BOTSPEAK."
```

```
"Capture this as a context handoff for tomorrow's session:
[paste your messy chat conversation]"
```

```
"Translate this BOTSPEAK rule into plain English so I can review it:
[paste the BOTSPEAK file]"
```

That's it. You'll see a clean BOTSPEAK output, a token-savings summary, and (in the case of `/translate-botspeak`) a confirmation that nothing important was lost in compression.

---

## The Three Things That Do the Work

### 1. Aliases (`@defs`) — the killer feature

Repeated identifiers are the largest single source of token waste in real `CLAUDE.md` files. `establishment_id` appears 47 times. `materialized_view_refresh_concurrently` appears 23 times. Each one costs you 4-8 tokens, every session, forever.

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

A correctly tagged 1,500-token rule file lets a mid-session agent process maybe 600 tokens of it. The rest is context the agent already has, lookup material it doesn't need yet, or first-turn orientation.

### 3. Symbols (two dialects)

**ASCII** (recommended default — every symbol is 1 token guaranteed):
```
->   leads to       !!   never / forbidden
&&   AND            ok   allowed / correct
||   OR             ~~   warn / check first
!=   not-equal      =    defined-as
```

**Symbol** (when human auditing matters more than max tokens):
```
🔴 = !!     ✅ = ok     ⚠️ = ~~     →  = ->     ·  = &&
```

Honest tradeoff: emojis cost 3-4 tokens each but pay for themselves in attention salience. ASCII operators are 1 token each — guaranteed by every modern BPE tokenizer because the code corpus saturated those merges. See [`SPEC.md`](SPEC.md) for the full table.

---

## "Wait, won't this break things?" — FAQ

**Q: Doesn't the AI need prose to understand the rules?**
A: No. LLMs are trained on enormous amounts of structured text — code, JSON, XML, YAML, math notation. They parse symbol contracts at least as well as prose, often better. The "lost in the middle" problem is *worse* for prose than for structured symbols. You can prove this on your own files: BOTSPEAK a rule, then ask your agent to summarize what it says. The summary will match the original prose version.

**Q: What if I write bad BOTSPEAK?**
A: Run `/translate-botspeak` on it. The output is your audit. If the translation matches what you meant, the BOTSPEAK is correct. If not, fix it. The skill is your safety net.

**Q: What if a new agent on my team can't read it?**
A: Every modern LLM (Claude, GPT, Gemini, Llama, Mistral) handles BOTSPEAK without preamble. The notation is intuitive enough that even older models infer it. If you're worried, include `SPEC.md` in your project; the agent reads it once and you're set.

**Q: Why not just use Caveman?**
A: Different problem. [Caveman](https://github.com/JuliusBrussee/caveman) compresses what the AI *outputs to humans* (chat replies, PR comments, commit messages). BOTSPEAK compresses what the AI *reads from itself* (rules, skills, memory). They compose — install both and you get the full token-efficiency stack.

**Q: Why not just use CRUX-Compress / llm-min.txt / Compresr?**
A: Those are tools that compress existing prose with a custom DSL. BOTSPEAK is a *writing convention* — write in it natively, no compressor agent required. We also ship a round-trip translate skill (CRUX doesn't have a reliable expander), so you can always read your own files. Comparison table below.

**Q: Will this make my agent worse?**
A: A March 2026 paper ("Brevity Constraints Reverse Performance Hierarchies in Language Models") found that constraining LLMs to brief responses *improved* accuracy by 26 percentage points on certain benchmarks. Less context noise = better attention. Your agent will likely get *better*, not worse.

**Q: How do I uninstall?**
A: Delete the skill files in your agent's skill directory. No traces left, no migrations needed. The skill is opt-in and stateless.

**Q: Should I rewrite all my existing rules right now?**
A: No. Start with the file your agent reads most often (usually `CLAUDE.md` or your largest always-on rule). Compress that one. Measure the savings. Decide if you want to do more.

---

## Compared to Other Tools

| | BOTSPEAK | Caveman | CRUX-Compress | llm-min.txt |
|---|---|---|---|---|
| **Compresses** | AI-facing docs (input) | AI output to humans | AI rules (input) | API/library docs |
| **Approach** | Writing convention | Output style | Compressor tool + DSL | Compressor tool |
| **Aliases** | ✅ `@defs` | — | — | — |
| **Phase tags** | ✅ | — | — | — |
| **Round-trip translate** | ✅ `/translate-botspeak` | n/a (output is final) | — | — |
| **Frontmatter-safe** | ✅ (compresses body only) | n/a | partial | n/a |
| **Multi-tool support** | ✅ Claude/Cursor/Codex/Gemini/+25 | ✅ 30+ agents | Claude/Cursor | Generic |
| **Stars (May 2026)** | new | 53.9k | ~3 | ~700 |

BOTSPEAK is the only convention (not tool) for AI-facing document compression with a verified round-trip. We expect it to coexist with Caveman, not compete.

---

## What's in the Box

```
botspeak/
├── README.md                      ← you are here
├── SPEC.md                        ← language spec: symbols, aliases, grammar, pitfalls
├── LICENSE                        ← MIT
├── CHANGELOG.md
├── CONTRIBUTING.md
├── MARKETING-TODO.md              ← things to do to grow adoption
├── CLAUDE.md, AGENTS.md           ← bootstrap files (BOTSPEAK)
├── .cursor/rules/botspeak.mdc      ← always-on Cursor rule (advanced — opt in if you want)
├── skills/
│   ├── botspeak/SKILL.md           ← compress: messy doc → BOTSPEAK
│   ├── capture/SKILL.md           ← capture: rambling chat → focused BOTSPEAK doc
│   └── translate/SKILL.md         ← translate: BOTSPEAK → human prose
├── agents/
│   └── botspeak-translator.md      ← bidirectional agent (advanced — for tools that load agents)
├── examples/                      ← five before/after pairs
│   ├── 01-short-rule/             ← branch guard:                   262 → 154 (41%)
│   ├── 02-context-handoff/        ← session handoff:                640 → 138 (78%)
│   ├── 03-memory-page/            ← Karpathy-style wiki page:       612 → 178 (71%)
│   ├── 04-philosophy-rule/        ← project manifesto:             1095 → 285 (74%)
│   └── 05-aliased-claude-md/      ← long doc + ASCII + aliases:     985 → 433 (56%)
└── install.sh
```

---

## On Karpathy's LLM Wiki

Andrej Karpathy's [LLM wiki pattern](https://github.com/Ar9av/obsidian-wiki) is the right idea: compile knowledge once into interconnected markdown pages instead of re-asking the AI the same questions. But those pages are still written in prose. The primary reader of those pages is another AI call, not you.

A BOTSPEAK wiki page carries the same semantic content at 60-75% of the token cost. Your wiki grows; your query cost doesn't. See [`examples/03-memory-page/`](examples/03-memory-page/) for what a wiki page looks like in BOTSPEAK — including the `summary:` frontmatter that makes index-only queries cheap.

---

## On XML for Claude

Claude was trained on enormous quantities of structured text including HTML and XML. [Anthropic's prompt engineering docs](https://docs.claude.com/en/docs/use-xml-tags) recommend XML tags for documents over a few hundred tokens. Internal benchmarks show XML structural boundaries deliver +20-40% accuracy on multi-step reasoning, +30-50% retry consistency, and better long-context retrieval.

BOTSPEAK uses XML for **macro-structure** in long docs (`<context>`, `<rules>`, `<reference>`, `<defs>`) and BOTSPEAK notation for **content** inside those tags. The combination outperforms markdown headings + prose for Claude. See [`examples/05-aliased-claude-md/after.md`](examples/05-aliased-claude-md/after.md) for the canonical example.

---

## Note to Humans Reading This

The README you're reading is in human prose. Intentionally. It's for you.

The `SPEC.md`, all three `SKILL.md` files, the `.cursor/rules/botspeak.mdc`, the agent definition, and every `after.md` in `examples/` is in BOTSPEAK. Run `/translate-botspeak` on any of them whenever you want to audit one in plain English.

You don't need to read BOTSPEAK. Your agent does.

---

## License

MIT. Free as in mammoth on the open plain.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight that token efficiency is a design choice. Built for the realization that AI is now a first-class reader of your codebase, and it deserves a format that respects its attention.*
