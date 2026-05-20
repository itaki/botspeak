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

- Human view: [README.md](README.md)
- Bot view: you are here
- Deep understanding: [PHILOSOPHY.md](PHILOSOPHY.md)

<h2 align="center">

→ [Open the live showcase](showcase/index.html) ←

</h2>

<p align="center"><em>4 games · 2 builds · identical physics</em></p>

---

## The problem

AI now writes for other AIs: `CLAUDE.md` · `AGENTS.md` · rules/ · skills/ · plans mid-session · handoffs no human reads · prompts main agent fires at 10 subagents in parallel. **Almost none of it is for you.**

all still prose · articles · transitions · hedging · scaffolding for human cognition that next AI reader doesn't need · pays for anyway.

worst leak = fan-out. main agent spawns 10 subagents (executor · researcher · critic · market-scanner) -> every brief out = prose · every reply back = prose · main context fills w/ both sides of conversation written for audience that doesn't exist. cut each leg by 1/3 -> every fan-out cut by 1/3 on both directions · every time.

token burn before first word · then again every time agent talks to another agent.

## The fix

BT = writing convention for any output whose primary reader = AI · file on disk OR prompt to another agent. removes only human-cognition scaffolding · keeps everything LLM parses (symbols · structure · constraints · code). same information · less rot. 3 modes:

**primary** — AI-facing files -> BT automatically · no prompting · no reformatting
**secondary** — compress existing prose docs on demand · file or directory
**tertiary** — subagent prompts -> BT · outbound briefs + inbound reports both compress · save tokens on send AND return · workers get clearer instructions (BT strips ambiguity w/ the prose)

endorsed by model trainers. Anthropic [prompting best-practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices): "structure prompts with XML tags" -> they "help Claude parse complex prompts unambiguously" · structured input above query "can improve response quality by up to 30%". BT = convention that does this consistently · every doc · every subagent call.

*Same meaning. Token savings = measurement, not motive — see [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## Install — one line

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

This single command does 3 things:

1. **Skills** -> every detected agent (Claude Code · Cursor · Codex · Gemini CLI · `~/.agents`):
   - `/botspeak` — compress file or directory -> BT. File ref = replace in place. Pasted text = create new file. Flags: `-bu` backup · `-c` chat output.
   - `BST` — render BT -> human prose -> `[filename].bst.md`. `-c` = chat instead.
2. **AOR global for Claude Code** -> writes managed block into `~/.claude/CLAUDE.md` · idempotent · re-run anytime to refresh.
3. **Paste-ready paths printed** for IDEs whose rules are per-project or UI-only:

| IDE                 | AOR location                                                                                                                                                       |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Cursor (project)**| Copy [rules/botspeak-always-on.mdc](rules/botspeak-always-on.mdc) -> `.cursor/rules/`.                                                                             |
| **Cursor (global)** | Paste [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> Cursor Settings → Rules → User Rules. UI-only · no file path.                                  |
| **Windsurf**        | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.windsurf/rules/`.                                                                             |
| **Cline**           | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.clinerules/`.                                                                                 |
| **Copilot**         | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.github/copilot-instructions.md`.                                                            |
| **Codex / generic** | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `AGENTS.md`.                                                                                 |

AOR = 14 lines. Don't see your IDE? [Add it](CONTRIBUTING.md).

> **2 things · 1 command.** Skills = called explicitly (`/botspeak @file`). AOR = always-on so agent writes in BT by default · no prompting. Skills install globally; AOR lives wherever IDE keeps rules. Installer handles both where possible · prints clear paste paths for the rest.

Keep reading below for proof · side-by-side game builds · real before/after compressions · the human-to-bot gap that does the work.

---

## Side by side: prose-built vs BT-built

→ [**Open the live showcase**](showcase/index.html) (plays in your browser · right-click "Open link in new tab" to keep this page open)

[![BT showcase preview: prose-built Breakout next to BT-built Breakout, identical](images/showcase-preview.png)](showcase/index.html)

4 games (Flappy Bird · Snake · Pong · Breakout) · built 2 ways · head-to-head. Left iframe = built from prose spec by one model. Right iframe = built from BT-compressed version of same spec by different fresh model · zero shared context. **Play identically.** Every physics constant matches.

| Game | Prose words | BT words | Compression | Physics matched |
|---|---:|---:|---:|---:|
| Flappy Bird | 1,415 | 974 | **31%** | 15 / 15 |
| Snake | 851 | 549 | **35%** | 10 / 10 |
| Pong | 1,350 | 820 | **39%** | 14 / 14 |
| Breakout | 1,499 | 838 | **44%** | 21 / 21 |

= same gravity · bounce angle · spawn cadence · brick scoring · ~half tokens. Both columns playable.

---

## Before / After (real documents)

### Synthetic examples (authored + round-tripped)

| Document type                                         | Before  | After  | Reduction | Folder                                                           |
| ----------------------------------------------------- | -------:| ------:| ---------:| ---------------------------------------------------------------- |
| Short rule (branch guard)                             | 410     | 331    | **19%**   | [examples/01-short-rule/](examples/01-short-rule/)               |
| Context handoff (one session → next)                  | 1,017   | 619    | **39%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Wiki / memory page (Karpathy LLM-wiki style)          | 1,003   | 754    | **25%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Project philosophy / manifesto rule                   | 1,731   | 1,000  | **42%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)     |
| Long CLAUDE.md (Toast/restaurant ops · hand-written)  | 8,055   | 7,101  | **12%**   | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan (code-heavy)              | 12,001  | 9,709  | **19%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

### Real CLAUDE.md files from popular GitHub repos

| Repository (stars)                          | Before | After  | Reduction | Folder                                                                       |
| ------------------------------------------- | ------:| ------:| ---------:| ---------------------------------------------------------------------------- |
| [`langchain-ai/langchain`][lc] (137K ★)     | 3,236  | 2,997  | **7%**    | [examples/07-langchain-claude-md/](examples/07-langchain-claude-md/)         |
| [`browser-use/browser-use`][bu] (94K ★)     | 2,787  | 2,275  | **18%**   | [examples/08-browser-use-claude-md/](examples/08-browser-use-claude-md/)     |
| [`BerriAI/litellm`][ll] (47K ★)             | 3,767  | 3,469  | **8%**    | [examples/09-litellm-claude-md/](examples/09-litellm-claude-md/)             |

[lc]: https://github.com/langchain-ai/langchain
[bu]: https://github.com/browser-use/browser-use
[ll]: https://github.com/BerriAI/litellm

*Tokens = chars / 4 (standard BPE approximation). Reproduce: `wc -c examples/$N/before.md examples/$N/after.md`. Per-example folders include exact `o200k_base` counts.*

**Real-repo caveat.** CLAUDE.md files above already had hundreds of contributors + months of PR iteration polishing vs real agents before BT saw them. 7-18% reduction = on top of all that human pre-optimization. Stripping further is hard · easy wins taken years ago.

**Your repo = opposite.** Your CLAUDE.md · rules · handoffs almost certainly written by your agent in plain prose · no committee · no PR review · no token audit. That's where BT does the heavy lifting. Expect 25-50% on a first compression of your own docs (see synthetic examples above) · double that on prompts sent to subagents (never optimized at all). 7% on `langchain` = floor. Your own repo = closer to ceiling.

---

## Human-to-bot understanding

humans read sequentially · need prose to track structure. bots = opposite · parse symbols · tags · discrete tokens far more reliably than flowing English. BT exploits the gap. every mechanism below = strange to a human · native to the model.

### 1. Aliases (`@defs`) — killer feature

human reader hates aliases · has to scroll back to remember what `E` and `MV` mean. bot binds symbol once · tracks through rest of doc · no slip.

Repeated identifiers = #1 token sink. `establishment_id` × 47 · `materialized_view_refresh_concurrently` × 23. Each costs 4–8 tokens · every session · forever.

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

In 2,000-token file, this block alone -> 400+ tokens saved · every session.

### 2. Phase tags

human writes *"please load this at session start, but you can skip it once context is established."* 15 words to say 1 thing. bot reads `[NEW-CHAT]` once · knows the lifecycle.

```
[NEW-CHAT]    load at session start; agent may skip once context established
[ALWAYS]      every turn
[ON-TRIGGER]  condition-gated; read only when pattern fires
[REFERENCE]   look-up only; skip during normal session load
[HANDOFF]     cross-session context; new agent reads first turn only
```

Correctly tagged 1,500-token file -> ~600 tokens loaded mid-session. Rest = established context · deferred lookups · first-turn orientation.

### 3. Symbol contracts

`->` · `!!` · `&&` · `||` unreadable to most humans without a legend. Modern BPE tokenizer assigns each one a single token · model treats them as logical operators directly · no decoding step.

```
->   leads to       !!   never / forbidden
&&   AND            ok   allowed / correct
||   OR             ~~   warn / check first
!=   not-equal      =    defined-as
```

Full table -> [SPEC.md](SPEC.md).

### 4. XML structure for long docs

Markdown headings (`## context`) = hints. XML tags (`<context>…</context>`) = boundaries. Anthropic [prompting best-practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) explicit: XML tags "help Claude parse complex prompts unambiguously" · for long inputs "structure document content and metadata with XML tags" -> wrap `<document>` around `<document_content>` + `<source>`. Humans find angle brackets noisy. Bots treat them as schema.

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

`<context>` · `<defs>` · `<rules>` · `<reference>` = unambiguous boundaries · better retrieval.

### 5. Fenced code blocks preserved verbatim

Regex = noise to most humans. Mermaid = a language. JSON = unreadable past 3 levels of nesting. To a model · all three = first-class · already dense · already parseable. BT never rewrites contents of triple-backtick fence -> nothing to win · model that can't parse regex wasn't going to parse the prose around it either. Block count in source == output · byte-for-byte. Why code-heavy docs still compress 7-19% — prose around blocks shrinks · blocks themselves don't.

---

## First 60 seconds after install

**1 — compress most-read file**
```
/botspeak -bu @CLAUDE.md
```
`-bu` = datestamped backup before touching anything. Output: token-savings summary + one-line description.

**2 — read back in plain English (optional sanity check)**
```
BST @CLAUDE.md
```
Creates `CLAUDE.bst.md` · aliases expanded · symbols decoded. Verify · then delete. `-c` = chat instead.

**3 — let BT write next doc automatically** (requires AOR)
```
"Save what we just talked about as a handoff doc for tomorrow."
```
Agent writes handoff in BT unprompted · correct notation · phase tags · aliases. This is the main event.

**4 — compress whole folder**
```
/botspeak ~/.cursor/skills/
```
Scans every `.md`/`.mdc` · token-count table · backup prompt · converts directory · before/after totals. **Use cheap model (Haiku · GPT-4o-mini) for big batches.**

---

## Evals

2 evidence signals gate every release · see [showcase](showcase/index.html) for live artifacts.

**Round-trip fidelity** — compress 6 real AI-facing docs -> BT -> audit every constraint · polarity marker · code block. **6 / 6 PASS**. 3 additional external docs (Django `.cursorrules` · Rust `AGENTS.md` · ai-dev `.mdc`) also pass · sources at [evals/external-prompts/](evals/external-prompts/) for clean-room reproduction. Full table -> [evals/round-trip-results.md](evals/round-trip-results.md).

**Game synthesis** — give fresh model only BT-compressed prompt · have it build game · compare to prose-built. 4 games pass clean-room:

| Game | Compression | Physics matched |
|---|---|---|
| [Flappy Bird](evals/game-prompt/parity-report.md) | 31% | 15 / 15 |
| [Snake](evals/snake-prompt/parity-report.md) | 35% | 10 / 10 |
| [Pong](evals/pong-prompt/parity-report.md) | 39% | 14 / 14 |
| [Breakout](evals/breakout-prompt/parity-report.md) | 44% | 21 / 21 |

Methodology + reproduction -> [evals/README.md](evals/README.md).

---

## What's in the box

```
botspeak/
├── README.md                            ← human view
├── README-FOR-AI.md                     ← you are here (BT-compressed README)
├── PHILOSOPHY.md                        ← AI-to-AI communication thesis
├── SPEC.md                              ← language spec: symbols · aliases · grammar · pitfalls
├── CHANGELOG.md  ·  CONTRIBUTING.md  ·  LICENSE (MIT)
├── CLAUDE.md, AGENTS.md, GEMINI.md      ← bootstrap files for agents working on this repo
├── install.sh  ·  uninstall.sh          ← one-line installer / remover for skills
├── rules/                               ← AOR templates (manual install)
├── skills/
│   ├── botspeak/SKILL.md                ← compress: file or directory -> BT
│   ├── botspeak-translate/SKILL.md      ← translate: BT -> [filename].bst.md
│   └── _archive/                        ← versioned history of every spec + skill
├── agents/botspeak-translator.md        ← bidirectional agent
├── examples/                            ← 6 before/after pairs (token-verified)
├── showcase/index.html                  ← single-page eval rendering
├── evals/                               ← round-trip + game-synthesis evidence
└── docs/                                ← handoff archive + internal release notes
```

---

## FAQ

**Q: Won't fewer tokens make my agent worse?**
A: No · usually better. Anthropic [prompting best-practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) calls out: Claude's latest models = "less verbose" by design · XML-tagged structured input "can improve response quality by up to 30%" over loose prose · over-prompting in long-form English ("CRITICAL: You MUST...") *degrades* instruction following on newer models. Less prose · more structure · better attention.

**Q: Doesn't the AI need prose to understand the rules?**
A: No — prose = often the worst format you could pick. Modern LLMs pre-trained on much wider vocabulary than English: HTML · JSON · XML · YAML · regex · Python · Rust · SQL · Mermaid · math notation · dozens of DSLs all native. Most precise way to specify a data shape = often a SQL migration that will never run · not 3 paragraphs of English about it. Most precise input rule = a regex · not "the string should generally look like...". BT leans into the idea — pick the densest notation that fits the meaning · then stop. "Lost in middle" hits flat prose hardest of all.

**Q: My IDE's skill tool wrote plain prose. Now what?**
A: Expected — IDE tools don't know about BT. Run `/botspeak` on file. With AOR installed · anything AI writes for itself -> BT from then on.

**Q: Should I rewrite all existing rules right now?**
A: No. Start with whatever agent reads most — usually `CLAUDE.md` or largest always-on rule. Compress that one · measure · go from there.

**Q: How do I skip BT for one doc?**
A: Say *"write this in prose"* · *"no botspeak"* · or pass `-p` (think *p*rose). Flag used to be `-bs` -> ambiguous · could read as "give me BT" or "no BT". `-p` = unambiguous.

**Q: New agent on team can't read it?**
A: Every modern LLM (Claude · GPT · Gemini · Llama · Mistral) reads BT without preamble. Worried? Drop `SPEC.md` into project once.

**Q: What about Caveman?**
A: Different problem. [Caveman](https://github.com/JuliusBrussee/caveman) compresses AI *output to humans*. BT shapes what AI *writes for other AI readers*. Install both — they compose.

**Q: Why not CRUX-Compress · llm-min.txt · Compresr?**
A: Those = compressor tools processing existing prose via custom DSL. BT = *writing convention* — write in it natively · no compressor required. Round-trip translate skill -> always read own files back.

**Q: How do I uninstall?**

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```

Skills removed automatically. AOR lives inside IDE rule system · uninstaller tells you where to look.

---

## Operational notes

- **`.gitignore` 2 patterns:** `*.bst.md` (translated files) + `*.bu.*.md` (backups). Both disposable.
- **`/botspeak` replaces files in place.** `-bu` = datestamped backup before compressing. Directory mode always asks first.
- **Batch jobs:** directory compression = mechanical -> cheap model. Haiku clocks ~2 min / 50 KB. Thinking models (Sonnet · Opus) = 3–5× slower at same job.

---

## License

MIT. Free, like your next context window.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight: token efficiency = design choice. Built for the realization that AI = first-class reader of your codebase · deserves format that respects its attention.*
