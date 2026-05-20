<!-- BOTSPEAK v2.2.0 · compressed by claude-opus-4-7 · 2026-05-20 -->

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

→ [Open the live showcase](https://itaki.github.io/botspeak/showcase/) ←

</h2>

<p align="center"><em>4 games · 2 builds · identical physics</em></p>

<p align="center"><sub>hosted on GitHub Pages · offline -> <code>python3 -m http.server</code> from clone · open <code>http://localhost:8000/showcase/index.html</code> · browsers block iframe loading from <code>file://</code></sub></p>

---

## The problem

agent now writes for other agents: `CLAUDE.md` · `AGENTS.md` · plans · handoffs · subagent prompts. almost none of it is for you · all still prose.

### `prose -> tokens++ -> context-- -> signal--`

worst case = fan-out · main agent fires prose at 10 subagents · pays for prose coming back. both legs addressable.

## The fix

A March 11, 2026 paper, ["Brevity Constraints Reverse Performance Hierarchies in Language Models"](https://arxiv.org/abs/2604.00025v1), found constraining LLMs to brief responses improved accuracy on certain benchmarks.

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

[![BT showcase preview: prose-built Breakout next to BT-built Breakout, identical](images/showcase-preview.png)](https://itaki.github.io/botspeak/showcase/)

4 games. Left iframe = built from prose spec by clean-room Sonnet 4.6 subagent. Right iframe = built from BT-compressed version by separate clean-room Sonnet 4.6 subagent. Same model · isolated sessions · zero shared context. Play identically.

| Game | Prose tok | BT tok | Reduction | Constants matched |
|---|---:|---:|---:|---:|
| Flappy Bird | 1,934 | 1,729 | **11%** | 15 / 15 |
| Snake | 1,192 | 895 | **25%** | 10 / 10 |
| Pong | 1,892 | 1,461 | **23%** | 14 / 14 |
| Breakout | 2,175 | 1,603 | **26%** | 21 / 21 |

token counts = `o200k_base` (GPT/Claude family) · word counts in `evals/scripts/token-counts.json` (words reduce 31-44% · more articles & connectives than tokens) · constants matched = automated extraction confirmed by `evals/scripts/parity_check.py`

→ [**Open the showcase**](https://itaki.github.io/botspeak/showcase/) to play either column.

---

## Before / After

all token counts on this page = `o200k_base` · reproduce any row -> `python3 evals/scripts/count_tokens.py` from repo root

### Real `CLAUDE.md` from popular repos (lead · externally authored · hard to game)

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

big-repo `CLAUDE.md` files already hand-tuned by hundreds of contributors · 4-13% reduction = on top of that pre-optimization · every constraint · every prohibition · every code block survives — verified by [round-trip audit](evals/round-trip-results.md)

### Synthetic (5 doc types we audit end-to-end)

| Document type                                         | Before tok | After tok | Reduction | Folder                                                           |
| ----------------------------------------------------- | ----------:| ---------:| ---------:| ---------------------------------------------------------------- |
| Short rule (branch guard)                             | 381        | 352       | **8%**    | [examples/01-short-rule/](examples/01-short-rule/)               |
| Context handoff                                       | 807        | 567       | **30%**   | [examples/02-context-handoff/](examples/02-context-handoff/)     |
| Wiki / memory page                                    | 892        | 763       | **14%**   | [examples/03-memory-page/](examples/03-memory-page/)             |
| Long CLAUDE.md (restaurant ops)                       | 7,807      | 7,081     | **9%**    | [examples/05-aliased-claude-md/](examples/05-aliased-claude-md/) |
| Architecture migration plan                           | 11,777     | 9,937     | **16%**   | [examples/06-backend-migration/](examples/06-backend-migration/) |

lower numbers than naive first pass · that's the point · SPEC v2.2.0 preserves fenced code blocks verbatim (§4) · refuses to drop named constraints (§9 pitfall 12) · verifies polarity (§9 pitfall 14) · compression = what survives those checks

---

## Human-to-bot understanding

5 mechanisms · each leans on something bots parse better than you do

### Aliases (`@defs`)

repeat `establishment_id` × 47 -> repeat `E` × 47 -> ~280 tokens saved · every session

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

`[NEW-CHAT]` · `[ALWAYS]` · `[ON-TRIGGER]` · `[REFERENCE]` · `[HANDOFF]` — agent knows what to load when · no English required · 1,500-token file -> ~600 loaded mid-session

### Symbol contracts

ASCII operators · 1 token each on every modern BPE tokenizer

```
->   leads to       !!   never
&&   AND            ||   OR
!=   not-equal      =    defined-as
~~   warn           ok   allowed
```

Full table -> [SPEC.md](SPEC.md)

### XML for long docs

XML tags "help Claude parse complex prompts unambiguously" ([Anthropic prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)) · markdown headings = hints · XML tags = boundaries

```
<context>
  <defs>…</defs>
  <rules>…</rules>
  <reference>…</reference>
</context>
```

### Fenced code blocks preserved verbatim

regex · Mermaid · JSON · SQL = already dense · already native to LLMs · BT never rewrites contents of triple-backtick fence · prose around shrinks · blocks don't · code-heavy docs cap at single-digit % reductions · that's correct: code = highest-value content · SPEC §9 pitfall 15 check enforces it

---

## First 60 seconds

```
/botspeak -bu @CLAUDE.md         # compress most-read file (-bu = backup first)
BST @CLAUDE.md                   # read back in plain English
/botspeak ~/.cursor/skills/      # compress folder; use cheap model
```

Then ask agent to save next handoff · with AOR installed -> comes out in BT automatically · this = main event

---

## Evals

- **Constraint-preservation audit** — 9 AI-facing docs compressed to BT (5 synthetic · 4 real-world CLAUDE.md from 47K-198K-star repos) · audited for polarity (SPEC §9 pitfall 14) · code-block parity (§9 pitfall 15) · alias hygiene (§9 pitfall 12) · constraint preservation · **9 / 9 PASS** · methodology + per-row evidence: [evals/round-trip-results.md](evals/round-trip-results.md) · plus 3 external docs that pass clean-room from `evals/external-prompts/`
- **Game synthesis** — Sonnet 4.6 subagent gets only BT prompt + no prior context · builds game · separate Sonnet 4.6 subagent builds from prose spec · [automated parity script](evals/scripts/parity_check.py) extracts numeric constants from both HTML builds · confirms match · 4 games pass clean-room (table above · full methodology in [evals/README.md](evals/README.md)) · same model · isolated sessions · cross-model parity = v2.3 target · !! v2.2 claim

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
├── examples/                            ← 9 before/after pairs (token-verified · o200k_base)
├── showcase/index.html                  ← single-page eval rendering
├── evals/
│   └── scripts/                         ← count_tokens.py · parity_check.py
└── docs/
```

---

## FAQ

**Won't fewer tokens make my agent worse?**
Usually better · Anthropic [prompting guide](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) calls Claude's latest models "less verbose" by design · XML-tagged structured input "can improve response quality by up to 30%" over loose prose

**Doesn't the AI need prose?**
No · LLMs native to HTML · JSON · XML · YAML · regex · Python · Rust · SQL · Mermaid · math · dozens of DSLs · SQL migration that will never run can spec a data shape more precisely than 3 paragraphs about it · pick densest notation that fits

**My IDE wrote plain prose · now what?**
Run `/botspeak` on file · with AOR installed · new docs -> BT from then on

**Should I rewrite everything now?**
No · start with whatever agent reads most — usually `CLAUDE.md`

**Skip BT for one doc?**
Pass `-p` (think *p*rose) · or just say "write this in prose"

**New agent can't read it?**
Every modern LLM (Claude · GPT · Gemini · Llama · Mistral) reads BT without preamble · drop `SPEC.md` once if nervous

**vs Caveman?**
Different layer · [Caveman](https://github.com/JuliusBrussee/caveman) shapes AI -> human output · BT shapes AI -> AI files · they compose

**vs CRUX-Compress · llm-min.txt · Compresr?**
Those = post-hoc compressors · BT = writing convention · no compressor required

**Uninstall**

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```

---

## Operational notes

- `.gitignore` 2 patterns: `*.bst.md` (translations) + `*.bu.*.md` (backups) · both disposable
- `/botspeak` replaces in place · `-bu` = keep backup · directory mode always asks first
- batch jobs: cheap model (Haiku · GPT-4o-mini) · thinking models = 3-5× slower for no quality gain on mechanical compression

---

## License

MIT.

---

*Inspired by [Caveman](https://github.com/JuliusBrussee/caveman)'s insight: token efficiency = design choice.*
