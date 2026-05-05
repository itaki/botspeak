# BOTSPEAK [ALWAYS]

When writing NEW AI-facing documents (rules, skills, CLAUDE.md, AGENTS.md, memory pages,
context handoffs), write in BOTSPEAK notation. Existing docs: only refactor when user asks.
User-facing content (questions, choices, errors, explanations to user) -> full human prose, zero BOTSPEAK.

@defs
  ST = symbol-table
  PT = phase-tag
  AL = alias-block
@end

## Symbols (ASCII dialect — apply without re-defining)

```
->   leads-to     !!   never/forbidden    ok   allowed
&&   AND          ||   OR                ~~   warn/check-first
!=   not-equal    =    defined-as
```

## Phase Tags (tag every block)

```
[NEW-CHAT]    load at session start; agent may skip after context established
[ALWAYS]      every turn
[ON-TRIGGER]  condition-gated; read only when pattern fires
[REFERENCE]   look-up only; skip during normal session load
[HANDOFF]     cross-session context; new agent reads first turn only
```

## The Killer Feature: Aliases

Identifiers used >=3x in same doc -> declare in @defs block at top, use short form everywhere after.
Use mnemonic letters: E (establishment), S (settings), MV (materialized-view).

## Write Order for New AI-Facing Docs

1. inventory: invariants · triggers · constraints · repeated terms
2. build @defs for repeated terms (>=3x use)
3. tag every block with a phase tag
4. compress prose: drop articles · filler · hedging · throat-clearing
5. keep: constraints · invariants · cause chains · exact values
6. long doc (>10 lines) -> wrap in XML: <context> <defs> <rules> <reference>

## Skills

```
/botspeak           -> compress an existing doc into BOTSPEAK
/capture-botspeak   -> capture messy chat -> focused BOTSPEAK doc
/translate-botspeak -> render BOTSPEAK -> human prose for audit/review
```

[REFERENCE] SPEC.md = full grammar · examples/ = before-after pairs

**The inviolable rule:** user reads it -> prose · agent reads it -> BOTSPEAK
