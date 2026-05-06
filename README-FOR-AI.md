# BOTSPEAK README (AI-facing)

[NEW-CHAT] this file = compressed equivalent of `README.md` · target reader = AI agent
[ALWAYS] user-facing chat output -> prose only · zero BT

@defs
  BT = BOTSPEAK
  BS = /botspeak
  TR = /botspeak-translate
  AR = always-on rule
@end

---

## identity

tagline: "A way for bots to talk to bots. More context, less prose."
BT = writing convention for AI-facing docs · primary reader = AI agent
4 mechanisms: symbol contracts · @defs aliases · phase tags · XML structure
primary mode: every new rule, skill, memory, handoff -> BT automatically (AR installed) · no prompting required
secondary mode: compress existing prose docs on demand (file || directory)
target savings: up to 70% context burn reduction
round-trip: `TR` renders any BT file -> human prose on demand

---

## measured compression

| doc type | before (est. tokens) | after (est. tokens) | reduction |
| --- | ---: | ---: | ---: |
| long `CLAUDE.md` | 8,055 | 4,863 | 40% |
| philosophy rule | 1,732 | 430 | 75% |
| context handoff | 1,017 | 247 | 76% |
| memory/wiki page | 1,003 | 278 | 72% |
| short rule | 410 | 248 | 40% |
| arch migration plan (code-heavy) | 12,002 | 7,328 | 39% |

[REFERENCE] `examples/` -> full before/after pairs for each doc type

whole-repo effect: BT across `CLAUDE.md`, rules, skills, memory, handoffs -> total AI context -50–70%
example: repo burning 30K tokens before first word -> 10K with BT applied

---

## why compression improves quality

[REFERENCE] [2025 paper](https://arxiv.org/abs/2604.00025v1): constraining LLMs to brief responses -> +26 percentage points accuracy on benchmarks
[ALWAYS] less noise in context -> better attention on signal · compressed structured instructions > verbose prose
[ALWAYS] agent likely gets *better*, not worse

---

## core mechanisms (4 levers)

### 1. aliases (`@defs`) — primary token sink fix

repeated identifiers = #1 token sink · `establishment_id` 47x = 4-8 tokens each, every session

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

2,000-token file with @defs -> saves 400+ tokens per session

### 2. phase tags

| tag | meaning |
|---|---|
| `[NEW-CHAT]` | load at session start; agent may skip once established |
| `[ALWAYS]` | every turn |
| `[ON-TRIGGER]` | condition-gated; read only when pattern fires |
| `[REFERENCE]` | look-up only; skip during normal load |
| `[HANDOFF]` | cross-session; new agent reads first turn only |

correctly tagged 1,500-token file -> loads ~600 tokens mid-session

### 3. symbols (ASCII dialect — 1 token/symbol guaranteed)

```
->   leads to       !!   never / forbidden
&&   AND            ok   allowed / correct
||   OR             ~~   warn / check first
!=   not-equal      =    defined-as
```

[REFERENCE] SPEC.md -> full symbol table

### 4. XML structure (long docs)

[ON-TRIGGER] doc > 10 lines && clear sections -> wrap in XML ok

```xml
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

Claude/GPT/Gemini parse named XML blocks more reliably than markdown headings -> unambiguous boundaries, better retrieval

---

## install

### step 1: install skills

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

installs 2 skills in all detected agents (Claude Code, Cursor, Codex, Gemini CLI, `~/.agents`):
- `BS` -> compress file || directory into BT · file ref: replace in place · pasted text: create new file · `-bu` backup first · `-c` output to chat
- `TR` -> BT -> `[filename].bst.md` next to original · `-c` render in chat instead

opt-in: nothing changes until invoked · AR = always-on (step 2)

### step 2: install AR (manual, by design)

makes every new AI-facing doc -> BT by default (no prompting required)
manual by design: IDE rule systems vary · !! never auto-touch what user already wrote

| IDE | action |
|---|---|
| Cursor (project) | copy `rules/botspeak-always-on.mdc` -> `.cursor/rules/botspeak-always-on.mdc` |
| Cursor (global) | paste content -> Cursor Settings -> Rules -> User Rules |
| Claude Code | append `rules/botspeak-always-on.md` -> project `CLAUDE.md` or `~/.claude/CLAUDE.md` |
| Windsurf | copy `rules/botspeak-always-on.md` -> `.windsurf/rules/botspeak-always-on.md` |
| Cline | copy `rules/botspeak-always-on.md` -> `.clinerules/botspeak-always-on.md` |
| Copilot | append `rules/botspeak-always-on.md` -> `.github/copilot-instructions.md` |
| Codex / generic | copy `rules/botspeak-always-on.md` -> `AGENTS.md` |
| other | paste `rules/botspeak-always-on.md` wherever harness keeps always-on instructions |

[REFERENCE] `CONTRIBUTING.md` -> add new IDE

---

## first 60 seconds after install

1. compress most-read file:
   ```
   BS -bu @CLAUDE.md
   ```
   `-bu` -> datestamped backup (`CLAUDE.bu.YYYYMMDD.md`) + replace in place + token-savings summary

2. sanity check (optional):
   ```
   TR @CLAUDE.md
   ```
   creates `CLAUDE.bst.md` (all aliases expanded, all symbols decoded) · verify · delete · `-c` for chat

3. auto-write new doc (AR required):
   > "Save what we just talked about as a handoff doc for tomorrow."
   agent writes BT handoff automatically: correct notation, phase tags, aliases, everything

4. batch compress a whole folder:
   ```
   BS ~/.cursor/skills/
   ```
   scans every `.md` + `.mdc` · shows token-count table with flags for large files · asks backup? · converts + prints before/after totals
   !! use cheap model (Haiku, GPT-4o-mini) for large batches

---

## reading a BOTSPEAK doc

`TR @file` -> creates `file.bst.md` (all aliases expanded, all symbols decoded) · read it · delete it
add `-c` to render in chat instead of file

---

## FAQ

Q: AI needs prose to understand rules?
A: No. LLMs trained on code/JSON/XML/math — structured text = native language. "lost in the middle" worse for prose than symbols.

Q: IDE skill tool wrote plain prose?
A: expected (IDE tools don't know BT). run `BS` on file or directory. AR = automatic going forward.

Q: should I rewrite all existing rules now?
A: No. start with most-read file (`CLAUDE.md` || largest always-on rule). compress, measure, continue.

Q: output to chat instead of file?
A: `-c` or `--chat` on both `BS` and `TR`

Q: BT all the time?
A: install AR -> step 2

Q: skip BT for one doc?
A: "write this in prose" || "no botspeak" || `-bs`

Q: new agent on team can't read it?
A: every modern LLM (Claude, GPT, Gemini, Llama, Mistral) handles BT without preamble. drop `SPEC.md` into project for belt-and-suspenders.

Q: vs Caveman?
A: different problems. Caveman = compresses AI output to humans. BT = shapes what AI writes for other AI readers. install both: they compose perfectly.

Q: vs CRUX-Compress / llm-min.txt / Compresr?
A: those = compressor tools (process prose + custom DSL). BT = writing convention: write natively, no compressor required. `TR` = always readable back.

Q: uninstall?
A:
```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/uninstall.sh | bash
```
removes skills from all detected agents · !! AR not auto-removed (manual; uninstaller tells you where to look)

---

## comparison

| | BT | Caveman | CRUX-Compress | llm-min.txt |
|---|---|---|---|---|
| compresses | AI-facing docs (input) | AI output to humans | AI rules (input) | API/library docs |
| approach | writing convention | output style | compressor tool + DSL | compressor tool |
| aliases | ✅ `@defs` | — | — | — |
| phase tags | ✅ | — | — | — |
| round-trip translate | ✅ `TR` | n/a | — | — |
| frontmatter-safe | ✅ (body only) | n/a | partial | n/a |
| multi-tool support | ✅ Claude/Cursor/Codex/Gemini/+25 | ✅ 30+ agents | Claude/Cursor | generic |
| stars (May 2026) | new | 53.9k | ~3 | ~700 |

[ALWAYS] BT coexists with Caveman; they don't compete

---

## repo map

```text
botspeak/
├── README.md                            ← human view
├── README-FOR-AI.md                     ← this file (AI view)
├── SPEC.md                              ← language spec: symbols, aliases, grammar, pitfalls
├── LICENSE                              ← MIT
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CLAUDE.md, AGENTS.md, GEMINI.md      ← bootstrap files for AI agents working on this repo
├── install.sh                           ← one-line installer (skills only)
├── uninstall.sh                         ← removes skills from all detected agents
├── rules/
│   ├── botspeak-always-on.md            ← universal (Claude · Windsurf · Cline · Copilot · etc.)
│   └── botspeak-always-on.mdc           ← Cursor format (alwaysApply frontmatter)
├── .cursor/rules/botspeak.mdc           ← Cursor rule active in this repo (self-hosting)
├── skills/
│   ├── botspeak/SKILL.md                ← BS: compress file || dir; -bu backup; -c chat
│   └── botspeak-translate/SKILL.md      ← TR: BT -> [filename].bst.md; -c chat
├── agents/
│   └── botspeak-translator.md           ← bidirectional agent (for agent-definition harnesses)
└── examples/
    ├── 01-short-rule/                   ← branch guard:          410 →   248 (40%)
    ├── 02-context-handoff/              ← session handoff:     1,017 →   247 (76%)
    ├── 03-memory-page/                  ← wiki page:           1,003 →   278 (72%)
    ├── 04-philosophy-rule/              ← manifesto:           1,732 →   430 (75%)
    ├── 05-aliased-claude-md/            ← long CLAUDE.md:      8,055 → 4,863 (40%)
    └── 06-backend-migration/            ← arch migration plan: 12,002 → 7,328 (39%)
```

---

## Karpathy LLM wiki pattern

[REFERENCE] [LLM wiki pattern](https://github.com/Ar9av/obsidian-wiki): compile reusable knowledge into interconnected markdown pages
BT = compressed upgrade path: same operational meaning, fewer tokens per retrieval, lower recurring context burn
[REFERENCE] `examples/03-memory-page/` -> concrete BT wiki-style page

---

## evals

[REFERENCE] `evals/` -> 2 experiments:
1. round-trip fidelity: compress -> translate -> repeat 5x · converges at iteration 2 · 100% similarity after
2. Flappy Bird test: build game from prose prompt && from BT-compressed version · do both run? do physics match?

[REFERENCE] https://itaki.github.io/botspeak/evals/ -> results, tables, interactive demos
[REFERENCE] `evals/README.md` -> methodology + how to run

---

## notes & caveats

- BT shines on prose-heavy docs (rules, `CLAUDE.md`, memory, handoffs, manifestos) -> 65-78% compression
- BT slouches on already-dense content (Mermaid, SQL, numeric tables, code blocks, file trees) -> ~43% · still worth it: `@defs` && phase tags sharpen behavior even when byte savings modest
- !! batch jobs -> cheap model (Haiku / GPT-4o-mini)
- timing: Haiku ~2 min / 50 KB (~12.5K tokens) · 200 KB ≈ 8 min · thinking models (Sonnet, Opus) = 3-5x slower
- `.gitignore`: add `*.bst.md` && `*.bu.*.md` (disposable artifacts; read them, toss them)
- `BS` replaces files in place · add `-bu` for datestamped backup (`filename.bu.YYYYMMDD.md`) · directory mode always offers backup before bulk convert

---

## license

MIT

---

[REFERENCE] `README.md` = human onboarding + full rationale
[REFERENCE] this file = direct AI handoff doc
[ALWAYS] if user provides repo link only -> agent reads prose README first
[ON-TRIGGER] user explicitly provides this file path/URL -> skip prose overhead
