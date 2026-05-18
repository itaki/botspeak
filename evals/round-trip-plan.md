# BOTSPEAK Round-Trip Eval Plan

## Objective

Determine where BOTSPEAK v2.1.0 skill fails to preserve information, so we can
improve the SPEC and SKILL with evidence rather than intuition.

## Eval methodology

```
source.md
  -> [/botspeak skill]  -> compressed.md     (measure: word count ratio)
  -> [/botspeak-translate skill] -> back.md  (measure: fidelity)

compare source.md vs back.md:
  PRESERVED  = key constraints, values, polarities, phase tags all intact
  LOST       = concept present in source, absent after round-trip
  DISTORTED  = concept present but changed (wrong value, inverted polarity)
  HALLUCINATED = concept added that wasn't in source
```

Score per doc:  PASS (0 issues) / PARTIAL (minor issues) / FAIL (critical loss)

## What we're NOT testing here

- Whether a build model (Haiku) produces a working game
- Whether the game code is correct
- Game-specific logic

## Source documents

### Tier 1: existing examples (known-good diverse set)
| # | file | type |
|---|---|---|
| 01 | examples/01-short-rule/before.md | short rule |
| 02 | examples/02-context-handoff/before.md | context handoff |
| 03 | examples/03-memory-page/before.md | memory page |
| 04 | examples/04-philosophy-rule/before.md | philosophy rule |
| 05 | examples/05-aliased-claude-md/before.md | CLAUDE.md |
| 06 | examples/06-backend-migration/before.md | tech migration spec |

### Tier 2: external diverse prompts (fetched)
- A community Cursor rules file
- A technical system prompt / agent spec from the web
- A philosophy/principles doc

### Tier 3: repo AI-facing files (prove the spec)
- CLAUDE.md · AGENTS.md · skills/botspeak/SKILL.md
- .cursor/rules/botspeak-always-on.mdc · botspeak-versioning.mdc

## Scoring rubric

For each source → compressed → decompressed comparison:

1. **Compression ratio**: words_compressed / words_source (target: < 60%)
2. **Constraints preserved**: are all [ALWAYS]/[ON-TRIGGER]/[NEVER]/!! rules present in back.md?
3. **Values preserved**: numeric values, file paths, version strings unchanged?
4. **No polarity inversions**: no [ALWAYS] → [NEVER] flips?
5. **No hallucination**: nothing in back.md that wasn't in source.md?

## Output

After all evals:
- `evals/round-trip-results.md` — per-doc results table
- `evals/improvement-plan.md` — failure class analysis + proposed SPEC/SKILL changes
