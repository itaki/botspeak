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

Human view: [README.md](README.md) · Bot view: you are here · Why: [PHILOSOPHY.md](PHILOSOPHY.md) · **Live evals: [showcase](showcase/index.html)** · [MIT](LICENSE)

---

## The problem

agent re-reads same files every session: `CLAUDE.md` · `AGENTS.md` · rules/ · skills/ · last handoff · all written for humans (articles · transitions · hedging). nothing earns its place in context window already paying for unstarted conversation -> token burn before first word.

## The fix

BT = writing convention for AI-primary docs · removes only human-cognition scaffolding · keeps everything LLM parses (symbols · structure · constraints · code). same information · less rot.

primary mode: new rules · skills · memory pages · handoffs -> BT automatically · no prompting
secondary mode: compress existing prose docs on demand · file or directory

*Same meaning. Token savings = measurement, not motive — see [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## See it work — primary public proof

[![BT showcase preview: prose-built Breakout next to BT-built Breakout, identical](images/showcase-preview.png)](showcase/index.html)

**→ [open showcase/index.html](showcase/index.html)**

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

| Document type                                         | Before  | After  | Reduction | Folder                                                           |
| ----------------------------------------------------- | -------:| ------:| ---------:| ---------------------------------------------------------------- |
| Short rule (branch guard)                             | 411     | 335    | **18%**   | [examples/01-short-rule/](examples/01-short-rule/)               |
| Context handoff (one session → next)                  | 1,019   | 624    | **39%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Wiki / memory page (Karpathy LLM-wiki style)          | 1,003   | 758    | **24%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Project philosophy / manifesto rule                   | 1,748   | 1,005  | **42%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)     |
| Long CLAUDE.md (code-heavy)                           | 8,083   | 7,159  | **11%**   | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan (code-heavy)              | 12,063  | 9,783  | **19%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

*Tokens = chars / 4 (standard BPE approximation). Reproduce: `wc -c examples/$N/before.md examples/$N/after.md`.*

Prose-heavy docs (rules · handoffs · philosophy): 18–42%. Code-heavy docs (long CLAUDE.md · arch plans): 11–19% — BT preserves fenced code blocks verbatim. Stack BT across CLAUDE.md · rules · skills · memory pages · handoffs -> savings compound: repo burning 30,000 tokens pre-first-word -> ~24,000.

---

## How it works

5 mechanisms do almost all the work.

### 1. Aliases (`@defs`) — killer feature

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

```
[NEW-CHAT]    load at session start; agent may skip once context established
[ALWAYS]      every turn
[ON-TRIGGER]  condition-gated; read only when pattern fires
[REFERENCE]   look-up only; skip during normal session load
[HANDOFF]     cross-session context; new agent reads first turn only
```

Correctly tagged 1,500-token file -> ~600 tokens loaded mid-session. Rest = established context · deferred lookups · first-turn orientation.

### 3. Symbol contracts

ASCII operators · 1 token each · guaranteed by every modern BPE tokenizer:

```
->   leads to       !!   never / forbidden
&&   AND            ok   allowed / correct
||   OR             ~~   warn / check first
!=   not-equal      =    defined-as
```

Full table -> [SPEC.md](SPEC.md).

### 4. XML structure for long docs

XML tags > markdown headings for model reliability in long files. Claude · GPT · Gemini all parse named XML blocks more accurately than loose `##` headings.

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

Anything in triple-backtick fences (Mermaid · SQL · YAML · regex · JSON · shell · file trees) = already dense -> BT never rewrites it. Block count in source == output · byte-for-byte. Why code-heavy docs still compress 11–19%: prose around blocks shrinks · blocks themselves don't.

---

## Install

### Step 1 — Skills (one line)

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

Drops 2 skills into every detected agent (Claude Code · Cursor · Codex · Gemini CLI · anything in `~/.agents`):

- `/botspeak` — compress file or directory -> BT. File ref = replace in place. Pasted text = create new file. Flags: `-bu` backup · `-c` chat output.
- `BST` — render BT -> human prose -> `[filename].bst.md`. `-c` = chat instead.

Opt-in: nothing changes until invoked. For automatic primary mode -> also install AOR (Step 2).

### Step 2 — AOR (manual, by design)

Makes every new AI-facing doc come out in BT by default. Manual because IDE rule systems vary · won't touch what you've already written.

| IDE                 | What to do                                                                                                                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Cursor**          | Copy [rules/botspeak-always-on.mdc](rules/botspeak-always-on.mdc) -> `.cursor/rules/`. All projects -> Cursor Settings → Rules → User Rules. |
| **Claude Code**     | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> project's `CLAUDE.md` (or `~/.claude/CLAUDE.md` for all projects).                                                                                       |
| **Windsurf**        | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.windsurf/rules/`.                                                                                                                                        |
| **Cline**           | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.clinerules/`.                                                                                                                                            |
| **Copilot**         | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.github/copilot-instructions.md`.                                                                                                                       |
| **Codex / generic** | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `AGENTS.md`.                                                                                                                                               |
| **Anything else**   | Paste [rules/botspeak-always-on.md](rules/botspeak-always-on.md) wherever harness keeps always-on instructions.                                                                                                               |

Don't see your IDE? [Add it](CONTRIBUTING.md).

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
A: No · usually better. 2025 paper found constraining LLMs to brief responses improved accuracy by 26 percentage points on certain benchmarks. Less noise in context window = better attention on what matters.

**Q: Doesn't the AI need prose to understand the rules?**
A: No. LLMs trained on code · JSON · XML · YAML · math notation -> structured text = native language. "Lost in middle" problem is *worse* for prose than symbols.

**Q: My IDE's skill tool wrote plain prose. Now what?**
A: Expected — IDE tools don't know about BT. Run `/botspeak` on file. With AOR installed · anything AI writes for itself -> BT from then on.

**Q: Should I rewrite all existing rules right now?**
A: No. Start with whatever agent reads most — usually `CLAUDE.md` or largest always-on rule. Compress that one · measure · go from there.

**Q: How do I skip BT for one doc?**
A: Say *"write this in prose"* · *"no botspeak"* · or `-bs`.

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
