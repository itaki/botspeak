# BOTSPEAK README (AI-facing)

[NEW-CHAT] this file = compressed equivalent of `README.md` · target reader = AI agent
[ALWAYS] user-facing chat output -> prose only · zero BT

@defs
  BT = BOTSPEAK
  TR = /botspeak-translate
  BS = /botspeak
  AR = always-on rule
@end

---

## identity

BT = writing convention for AI-facing docs.
Tagline = "A way for bots to talk to bots. More context, less prose."

[ALWAYS] goal -> more signal && less noise in AI context windows
[ALWAYS] preserve meaning: constraints · invariants · trigger logic · exact values

---

## measured compression

| doc type | before | after (BT) | reduction |
|---|---:|---:|---:|
| long `CLAUDE.md` | 985 words | 433 words | 56% |
| philosophy rule | 1,095 | 285 | 74% |
| context handoff | 640 | 138 | 78% |
| memory/wiki page | 612 | 178 | 71% |
| short rule | 262 | 154 | 41% |
| code-heavy migration plan | 6,356 | 3,614 | 43% |

[REFERENCE] `examples/` -> full before/after pairs

---

## core mechanism

BT = 3 levers:
1. aliases (`@defs`) -> collapse repeated identifiers
2. phase tags (`[NEW-CHAT] [ALWAYS] [ON-TRIGGER] [REFERENCE] [HANDOFF]`) -> load only relevant context
3. symbol contracts (`!!`, `ok`, `->`, `&&`, `||`, `!=`, `=`) -> compact unambiguous semantics

[ALWAYS] for long docs (>10 lines) -> XML macro-structure ok: `<context> <defs> <rules> <reference>`

---

## install

### step 1: install skills

```bash
curl -fsSL https://raw.githubusercontent.com/itaki/botspeak/main/install.sh | bash
```

installs 2 skills in detected agents:
- `BS` -> compress file || directory into BT
- `TR` -> BT -> human prose (audit / round-trip safety)

### step 2: install AR manually (recommended)

[ALWAYS] AR = what makes new AI-facing docs default to BT without repeated prompting
[ALWAYS] manual install by design (IDE rule systems differ)

| IDE | path / action |
|---|---|
| Cursor (project) | copy `rules/botspeak-always-on.mdc` -> `.cursor/rules/botspeak-always-on.mdc` |
| Cursor (global) | paste same content into Cursor Settings -> Rules -> User Rules |
| Claude Code | append `rules/botspeak-always-on.md` -> project `CLAUDE.md` or `~/.claude/CLAUDE.md` |
| Windsurf | copy `rules/botspeak-always-on.md` -> `.windsurf/rules/botspeak-always-on.md` |
| Cline | copy `rules/botspeak-always-on.md` -> `.clinerules/botspeak-always-on.md` |
| Copilot | append `rules/botspeak-always-on.md` -> `.github/copilot-instructions.md` |
| Codex / generic | copy `rules/botspeak-always-on.md` -> `AGENTS.md` |

---

## first-minute usage

examples:
- "Compress my `CLAUDE.md` into BOTSPEAK."
- "Save this discussion as a handoff for tomorrow."
- "Translate this BOTSPEAK rule into plain English."

[ON-TRIGGER] AR installed && request = handoff/rule/memory doc -> output doc in BT automatically

---

## directory mode (`BS`)

[ON-TRIGGER] input = directory != file

D1 scan -> enumerate `.md` + `.mdc`
D2 per file -> name · KB · est tokens (chars/4)
D3 flags -> >5K tokens significant · >10K alert · >25K enormous
D4 ask -> backup+convert || convert-no-backup || cancel
D5 convert in batch -> report before/after token estimate

math:
- 1 KB ~= 256 tokens
- 50 KB ~= 12.5K tokens
- 100 KB ~= 25K tokens
- 400 KB ~= 100K tokens

timing reference (Haiku, May 2026): ~2 min / 50 KB plain text

[ALWAYS] batch jobs -> cheap model preferred (Haiku / GPT-4o-mini)

---

## rule safety / behavior

[ALWAYS] BT only in docs written for AI
[ALWAYS] chat replies to user -> prose only
[ON-TRIGGER] user asks prose for one doc ("write this in prose", "don't botspeak this file") -> prose output for that doc only

---

## relation to caveman

Caveman compresses AI output to humans.
BT compresses AI input docs read by AI.
[ALWAYS] they compose well together.

---

## repo map

```text
botspeak/
├── README.md
├── README-BOTSPEAK-EXAMPLE.md
├── SPEC.md
├── install.sh
├── rules/
│   ├── botspeak-always-on.md
│   └── botspeak-always-on.mdc
├── skills/
│   ├── botspeak/SKILL.md
│   └── botspeak-translate/SKILL.md
├── agents/botspeak-translator.md
└── examples/
```

---

## notes

[REFERENCE] `README.md` = human onboarding + rationale
[REFERENCE] this file = direct AI handoff doc
[ALWAYS] if user gives repo link only, agent usually reads prose README first
[ON-TRIGGER] user can explicitly provide this file path/URL to skip prose overhead
