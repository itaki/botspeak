<!-- BOTSPEAK v2.2.0 · compressed by claude-opus-4-7 · 2026-05-19 -->

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

agent now writes for other agents: `CLAUDE.md` · `AGENTS.md` · plans · handoffs · subagent prompts. almost none of it is for you · all still prose.

### `prose -> tokens++ -> context-- -> signal--`

worst case = fan-out · main agent fires prose at 10 subagents · pays for prose coming back. both legs addressable.

## The fix

writing convention for any output whose primary reader = AI. keep symbols · structure · constraints · code. drop the rest.

- **files** — agent writes new rules · skills · memory pages · handoffs in BT by default
- **compress** — convert existing prose docs on demand (`/botspeak @file` || folder)
- **subagents** — outbound briefs + inbound reports both compress · double savings on fan-out

Anthropic [prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) endorses the moves: XML structure for unambiguous parsing · long input above query (up to 30% quality gain) · terse over verbose. BT applies them consistently.

*Token savings = measurement · not motive — [PHILOSOPHY.md](PHILOSOPHY.md).*

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

- **skills** — `/botspeak` + BST installed into every detected agent (Claude Code · Cursor · Codex · Gemini CLI · `~/.agents`)
- **AOR** — idempotent managed block written into `~/.claude/CLAUDE.md` · new AI-facing docs -> BT by default
- **paste paths** — printed for IDEs whose rules are per-project or UI-only:

| IDE                 | AOR location                                                                                                                                  |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cursor (project)**| Copy [rules/botspeak-always-on.mdc](rules/botspeak-always-on.mdc) -> `.cursor/rules/`.                                                        |
| **Cursor (global)** | Paste [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> Cursor Settings → Rules → User Rules.                                     |
| **Windsurf**        | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.windsurf/rules/`.                                                        |
| **Cline**           | Copy [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.clinerules/`.                                                            |
| **Copilot**         | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `.github/copilot-instructions.md`.                                       |
| **Codex / generic** | Append [rules/botspeak-always-on.md](rules/botspeak-always-on.md) -> `AGENTS.md`.                                                             |

AOR = 14 lines. Don't see your IDE? [Add it](CONTRIBUTING.md).

---

## Side by side

[![BT showcase preview: prose-built Breakout next to BT-built Breakout, identical](images/showcase-preview.png)](showcase/index.html)

4 games. Left iframe = built from prose spec by one model. Right iframe = built from BT-compressed version by different fresh model · zero shared context. Play identically.

| Game | Prose words | BT words | Compression | Physics matched |
|---|---:|---:|---:|---:|
| Flappy Bird | 1,415 | 974 | **31%** | 15 / 15 |
| Snake | 851 | 549 | **35%** | 10 / 10 |
| Pong | 1,350 | 820 | **39%** | 14 / 14 |
| Breakout | 1,499 | 838 | **44%** | 21 / 21 |

→ [**Open the showcase**](showcase/index.html) to play either column.

---

## Before / After

### Synthetic (6 doc types we round-trip)

| Document type                                         | Before  | After  | Reduction | Folder                                                           |
| ----------------------------------------------------- | -------:| ------:| ---------:| ---------------------------------------------------------------- |
| Short rule (branch guard)                             | 410     | 331    | **19%**   | [examples/01-short-rule/](examples/01-short-rule/)               |
| Context handoff                                       | 1,017   | 619    | **39%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Wiki / memory page                                    | 1,003   | 754    | **25%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Project philosophy rule                               | 1,731   | 1,000  | **42%**   | [examples/04-philosophy-rule/](examples/04-philosophy-rule/)     |
| Long CLAUDE.md (restaurant ops)                       | 8,055   | 7,101  | **12%**   | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan                           | 12,001  | 9,709  | **19%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

### Real `CLAUDE.md` from popular repos

| Repository (stars)                          | Before | After  | Reduction | Folder                                                                       |
| ------------------------------------------- | ------:| ------:| ---------:| ---------------------------------------------------------------------------- |
| [`langchain-ai/langchain`][lc] (137K ★)     | 3,236  | 2,997  | **7%**    | [examples/07-langchain-claude-md/](examples/07-langchain-claude-md/)         |
| [`browser-use/browser-use`][bu] (94K ★)     | 2,787  | 2,275  | **18%**   | [examples/08-browser-use-claude-md/](examples/08-browser-use-claude-md/)     |
| [`BerriAI/litellm`][ll] (47K ★)             | 3,767  | 3,469  | **8%**    | [examples/09-litellm-claude-md/](examples/09-litellm-claude-md/)             |

[lc]: https://github.com/langchain-ai/langchain
[bu]: https://github.com/browser-use/browser-use
[ll]: https://github.com/BerriAI/litellm

Big-repo `CLAUDE.md` files already had hundreds of contributors tuning them · 7-18% = on top of that pre-optimization. Your own docs (written by your agent · never optimized) -> 25-50% on first compression. 7% = floor.

*Tokens ≈ chars / 4. Per-example folders carry exact `o200k_base` counts.*

---

## Human-to-bot understanding

5 mechanisms. each leans on something bots parse better than you do.

### Aliases (`@defs`)

repeat `establishment_id` × 47 -> repeat `E` × 47 -> ~280 tokens saved · every session.

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

`[NEW-CHAT]` · `[ALWAYS]` · `[ON-TRIGGER]` · `[REFERENCE]` · `[HANDOFF]` — agent knows what to load when · no English required. 1,500-token file -> ~600 loaded mid-session.

### Symbol contracts

ASCII operators · 1 token each on every modern BPE tokenizer.

```
->   leads to       !!   never
&&   AND            ||   OR
!=   not-equal      =    defined-as
~~   warn           ok   allowed
```

Full table -> [SPEC.md](SPEC.md).

### XML for long docs

XML tags "help Claude parse complex prompts unambiguously" ([Anthropic prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)). markdown headings = hints · XML tags = boundaries.

```
<context>
  <defs>…</defs>
  <rules>…</rules>
  <reference>…</reference>
</context>
```

### Fenced code blocks preserved verbatim

regex · Mermaid · JSON · SQL = already dense · already native to LLMs. BT never rewrites contents of triple-backtick fence. prose around shrinks · blocks don't. Code-heavy docs cap at ~7-19%.

---

## First 60 seconds

```
/botspeak -bu @CLAUDE.md         # compress most-read file (-bu = backup first)
BST @CLAUDE.md                   # read back in plain English
/botspeak ~/.cursor/skills/      # compress folder; use cheap model
```

Then ask agent to save next handoff. With AOR installed -> comes out in BT automatically · this is the main event.

---

## Evals

- **Round-trip fidelity** — 6 AI-facing docs -> BT · every constraint / polarity / code block audited. **6 / 6 PASS**. Plus 3 external real-world docs ([evals/round-trip-results.md](evals/round-trip-results.md)).
- **Game synthesis** — fresh model gets only BT prompt · builds game · parity-checked vs prose build. 4 games pass clean-room (table above · methodology in [evals/README.md](evals/README.md)).

---

## What's in the box

```
botspeak/
├── README.md                            ← human view
├── README-FOR-AI.md                     ← you are here (BT-compressed README)
├── PHILOSOPHY.md                        ← AI-to-AI communication thesis
├── SPEC.md                              ← symbols · aliases · grammar · pitfalls
├── CHANGELOG.md · CONTRIBUTING.md · LICENSE (MIT)
├── CLAUDE.md, AGENTS.md, GEMINI.md      ← bootstrap files for agents in this repo
├── install.sh · uninstall.sh
├── rules/                               ← AOR templates
├── skills/
│   ├── botspeak/SKILL.md                ← compress: file or directory -> BT
│   ├── botspeak-translate/SKILL.md      ← translate: BT -> [filename].bst.md
│   └── _archive/
├── agents/botspeak-translator.md
├── examples/                            ← 9 before/after pairs (token-verified)
├── showcase/index.html                  ← single-page eval rendering
├── evals/
└── docs/
```

---

## FAQ

**Won't fewer tokens make my agent worse?**
Usually better. Anthropic [prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) calls Claude's latest models "less verbose" by design · XML-tagged structured input "can improve response quality by up to 30%" over loose prose.

**Doesn't the AI need prose?**
No. LLMs native to HTML · JSON · XML · YAML · regex · Python · Rust · SQL · Mermaid · math · dozens of DSLs. SQL migration that will never run can spec a data shape more precisely than 3 paragraphs about it. Pick densest notation that fits.

**My IDE wrote plain prose · now what?**
Run `/botspeak` on file. With AOR installed · new docs -> BT from then on.

**Should I rewrite everything now?**
No. Start with whatever agent reads most — usually `CLAUDE.md`.

**Skip BT for one doc?**
Pass `-p` (think *p*rose). Or just say "write this in prose."

**New agent can't read it?**
Every modern LLM (Claude · GPT · Gemini · Llama · Mistral) reads BT without preamble. Drop `SPEC.md` once if nervous.

**vs Caveman?**
Different layer. [Caveman](https://github.com/JuliusBrussee/caveman) shapes AI -> human output. BT shapes AI -> AI files. They compose.

**vs CRUX-Compress · llm-min.txt · Compresr?**
Those = post-hoc compressors. BT = writing convention · no compressor required.

**Uninstall**

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```

---

## Operational notes

- `.gitignore` 2 patterns: `*.bst.md` (translations) + `*.bu.*.md` (backups). Both disposable.
- `/botspeak` replaces in place. `-bu` = keep backup. Directory mode always asks first.
- Batch jobs: cheap model (Haiku · GPT-4o-mini). Thinking models = 3-5× slower for no quality gain on mechanical compression.

---

## License

MIT.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight: token efficiency = design choice.*
