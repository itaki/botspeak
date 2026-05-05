# BOTSPEAK v1

[NEW-CHAT] this file = README.md in full · rewritten as BOTSPEAK · AI-facing equivalent

@defs
  BT = BOTSPEAK
  PT = phase-tag
  TR = /translate-botspeak
  SK = skill
@end

---

## compression gains

| doc type | before (words) | after (words) | reduction |
|---|---|---|---|
| long CLAUDE.md | 985 | 433 | 56% |
| philosophy rule | 1095 | 285 | 74% |
| context handoff | 640 | 138 | 78% |
| memory/wiki page | 612 | 178 | 71% |
| short rule | 262 | 154 | 41% |

all: constraints · invariants · triggers · exceptions preserved
big win: long CLAUDE.md → saves ~550 words/session · 200 sessions/yr = 110k words cut

[REFERENCE] examples/ ← full before/after pairs

---

## what BT is

AI reads every session: CLAUDE.md · AGENTS.md · .cursor/rules/*.mdc · SK files · memory files
human reads same files: once

BT = writing convention for docs whose primary reader = AI

components:
- symbol contracts (!! = never · ok = allowed · -> = leads-to) · defined once · used everywhere
- aliases (@defs E = establishment_id) · declared once · E used everywhere · kills #1 token sink
- PT ([NEW-CHAT] [ALWAYS] [REFERENCE]) → agents skip irrelevant context per session phase
- XML macro-structure for long docs · Claude parses XML boundaries > markdown headings

TR SK → renders any BT file → human prose on demand · rarely needed · always available

---

## install

skills only (recommended first step):
```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

skills + always-on rule (BT applied automatically to new AI docs):
```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash -s -- --with-rule
```

installs 3 SKs:
- /botspeak → compress existing AI-facing doc → BT
- /capture-botspeak → rambling chat → focused BT doc
- TR → BT → human prose

--with-rule drops per-IDE rule file into current project:
  Cursor → .cursor/rules/botspeak.mdc
  Windsurf → .windsurf/rules/botspeak.md
  Cline → .clinerules/botspeak.md
  Copilot → .github/copilot-instructions.md
  everything else → AGENTS.md

manual: copy rules/botspeak.md to wherever your IDE looks for always-on rules
opt-in · nothing fires until invoked · no surprises · easy uninstall

---

## first 60s after install

```
"Compress my CLAUDE.md into BOTSPEAK."
```
```
"Capture this as a context handoff for tomorrow's session: [paste chat]"
```
```
"Translate this BOTSPEAK rule into plain English so I can review it: [paste file]"
```

output: clean BT · token-savings summary · (TR: confirmation nothing lost)

---

## the 3 mechanisms

### 1. aliases (@defs) — killer feature

repeated identifiers = #1 token sink · establishment_id x47 · materialized_view_refresh_concurrently x23 · each = 4-8 tokens/session forever

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

this block in 2000-token file → saves 400+ tokens · every session

### 2. PTs

```
[NEW-CHAT]    load at session start · agent may skip after context established
[ALWAYS]      every turn · no exceptions
[ON-TRIGGER]  condition-gated · read only when pattern fires
[REFERENCE]   look-up only · skip during normal session load
[HANDOFF]     cross-session context · new-agent reads first-turn only
```

correctly-tagged 1500-token file → agent processes ~600 tokens mid-session · rest = already-known || lookup || first-turn-only

### 3. symbols (2 dialects)

**ASCII** (recommended · 1 token guaranteed per symbol · BPE code-corpus saturation):
```
->  leads-to     !!  never      &&  AND
ok  allowed      ||  OR         ~~  warn
!=  not-equal    =   defined-as
```

**Symbol** (human audit matters > max tokens):
```
🔴=!!   ✅=ok   ⚠️=~~   →=->   ·=&&
```

tradeoff: emojis = 3-4 tokens · gain = attention salience · ASCII = 1 token guaranteed
[REFERENCE] SPEC.md ← full symbol table · cost reference

---

## FAQ

Q: AI needs prose to understand rules?
A: no · LLMs trained on code/JSON/XML/YAML/math · parse symbol contracts >= prose · "lost in middle" worse for prose · verify: BT a rule → ask agent to summarize → matches original

Q: wrote bad BT?
A: run TR · output = audit · matches intent → BT correct · doesn't → fix · TR = safety net

Q: new team agent can't read BT?
A: all modern LLMs (Claude/GPT/Gemini/Llama/Mistral) handle BT without preamble · include SPEC.md if concerned · agent reads once · done

Q: why not Caveman?
A: different problem · Caveman = AI output to humans (replies/comments/commits) · BT = AI-to-AI internal docs (rules/SKs/memory) · compose: install both → full token-efficiency stack

Q: why not CRUX-Compress/llm-min.txt/Compresr?
A: those = compress existing prose via custom DSL (tool required) · BT = native writing convention (no compressor) · BT ships TR round-trip · CRUX has no reliable expander

Q: will this make agent worse?
A: no · March 2026 paper "Brevity Constraints Reverse Performance Hierarchies" → brevity improved accuracy +26pp on benchmarks · less context noise = better attention · agent likely better not worse

Q: uninstall?
A: delete SK files in agent SK dir · no traces · no migrations · stateless

Q: rewrite all rules now?
A: no · start: highest-frequency file (usually CLAUDE.md || largest always-on rule) · compress one · measure savings · decide on more

---

## vs other tools

| | BT | Caveman | CRUX-Compress | llm-min.txt |
|---|---|---|---|---|
| compresses | AI-facing docs (input) | AI output to humans | AI rules (input) | API/lib docs |
| approach | writing convention | output style | compressor+DSL | compressor |
| aliases | ✅ @defs | — | — | — |
| PT | ✅ | — | — | — |
| round-trip | ✅ TR | n/a (output final) | — | — |
| frontmatter-safe | ✅ body-only | n/a | partial | n/a |
| multi-tool | ✅ Claude/Cursor/Codex/Gemini/+25 | ✅ 30+ | Claude/Cursor | generic |
| stars (May 2026) | new | 53.9k | ~3 | ~700 |

BT = only convention (not tool) for AI-facing doc compression with verified round-trip · coexists with Caveman

---

## repo structure

```
botspeak/
├── README.md                      ← human prose · you are here (HP)
├── README-BOTSPEAK-EXAMPLE.md     ← this file · same content · BT format
├── SPEC.md                        ← full grammar · symbols · aliases · pitfalls
├── LICENSE · CHANGELOG.md · CONTRIBUTING.md
├── CLAUDE.md / AGENTS.md          ← bootstrap files (BT format)
├── install.sh                     ← one-line installer · --with-rule drops rule files
├── rules/
│   ├── botspeak.md                ← generic rule (Windsurf · Cline · Copilot · any IDE)
│   └── cursor.mdc                 ← Cursor-specific (alwaysApply frontmatter)
├── .cursor/rules/botspeak.mdc     ← Cursor rule active in this repo (self-hosting)
├── skills/
│   ├── botspeak/SKILL.md          ← compress: doc → BT
│   ├── capture/SKILL.md           ← capture: chat → BT doc
│   └── translate/SKILL.md         ← TR: BT → human prose
├── agents/botspeak-translator.md  ← bidirectional agent (advanced)
└── examples/
    ├── 01-short-rule/             ←  262 → 154 words (41%)
    ├── 02-context-handoff/        ←  640 → 138 words (78%)
    ├── 03-memory-page/            ←  612 → 178 words (71%)
    ├── 04-philosophy-rule/        ← 1095 → 285 words (74%)
    └── 05-aliased-claude-md/      ←  985 → 433 words (56%)
```

---

## Karpathy LLM wiki

Karpathy LLM-wiki: right idea · compile knowledge → interconnected markdown pages
problem: pages still prose · primary reader = another AI call

BT wiki page: same semantic content @ 60-75% token cost · wiki grows · query cost flat
[REFERENCE] examples/03-memory-page/ ← BT wiki page example · incl. summary: frontmatter for cheap index scans

---

## XML for Claude

Claude trained on HTML/XML · Anthropic docs recommend XML for docs >few hundred tokens
internal benchmarks: XML boundaries → +20-40% accuracy multi-step reasoning · +30-50% retry consistency · better long-context retrieval

BT approach: XML = macro-structure for long docs · BT notation = content inside tags · outperforms markdown headings + prose for Claude
[REFERENCE] examples/05-aliased-claude-md/after.md ← canonical example

---

## license

MIT · free as in mammoth on the open plain

inspired by Caveman's insight (token efficiency = design choice) · built for the realization that AI = first-class reader of your codebase · it deserves a format that respects its attention
