# BOTSPEAK Improvement Plan — v2.1.0 → v2.2.0
<!-- based on: evals/round-trip-results.md · 9 round-trip evals · 2026-05-08 -->

## What the evidence says

9 round-trip evals. 7 PASS, 2 PARTIAL. Zero FAILs. Zero hallucinations across all runs.

The compression grammar is reliable for its design target (short-to-medium AI-facing rules/skills/handoffs under ~1500 words). Two PARTIALs both came from long, complex docs (4000+ and 6000+ words) with a specific, consistent failure pattern.

Three improvement targets identified, ranked by severity.

---

## Fix 1: Polarity verification in !! application [CRITICAL · v2.2.0]

**Failure class**: Compressor applies `!!` to language that *sounds* cautionary without verifying the underlying semantic is actually a warning/prohibition.

**Example**: Source says "To opt out, set DISABLE_AUTOUPDATER=1" → compressor reads "disable" + env var as dangerous → emits `!! DISABLE_AUTOUPDATER=1` → decompressor renders as "is forbidden" → actively wrong.

**Proposed SPEC change (§9 new pitfall)**:
```
**14. !! applied to correct-but-cautionary statements**
`!!` means "forbidden / never do this." Before emitting `!!`, verify the underlying claim is a prohibition, not:
- an opt-out mechanism ("to disable X, do Y")
- a conditional warning ("only do X if Y")
- a recommended alternative ("prefer X over Z")
If the source describes a legitimate action in cautionary language, use a phase tag ([CAUTION]) or inline note rather than `!!`.
```

**Proposed SKILL change (step 6 verify pass)**:
```
!! polarity check: for every `!!` in output, confirm the source statement is a prohibition — not an opt-out, conditional, or alternative
```

---

## Fix 2: Code block preservation enforcement [HIGH · v2.2.0]

**Failure class**: Skill says "preserve code blocks verbatim" but on long/complex docs the rule gets crowded out during compression and code blocks are dropped.

**Example**: Mermaid diagrams and pipeline.yml in a 6000-word migration spec were dropped entirely despite the rule.

**Proposed SKILL change (step 6 verify pass)**:
```
code blocks: count fenced blocks (``` or ~~~) in source → confirm same count in output → if missing, go back and embed them
```

**Proposed SPEC change (§4 "Keep absolutely")**:
```
all fenced code blocks (``` or ~~~) — verbatim, no exceptions; if this bloats the output, the doc may be too large for single-pass compression (see §10 size guidance)
```

**New §10 (size guidance)**:
```
## §10 Document size guidance

BOTSPEAK works best on docs under ~1500 words. Above that:
- code blocks, diagrams, and inline examples become disproportionately large relative to compressible prose
- compression ratio falls below 0.25, which means most content is already dense
- consider splitting the doc into sections and compressing each separately
- or compress only the rules/constraints section, leaving code blocks as appendices
```

---

## Fix 3: Named grounding examples [LOW · v2.3.0]

**Failure class**: Concrete named entities (DabaBase, Fred's Italian Bistro) used as the anchor example for an abstract rule are dropped as "flavor text."

**Example**: "Do not name a database after a client project (e.g. DabaBase)" → compressed drops "DabaBase" → rule becomes abstract and easier to rationalize around.

**Proposed SPEC change (§4 "Keep absolutely")**:
```
named entities used as the primary grounding example for a constraint — preserve the name, not just the abstract rule
signal: source says "e.g. X" or "such as X" or "for example X" where X is a proper noun or specific identifier
```

**Proposed SKILL change (step 2 inventory)**:
```
flag: any "e.g. <ProperNoun>" or "such as <identifier>" used as the sole concrete example of a constraint → mark as KEEP during compress
```

---

## What NOT to change

- `@defs` hygiene (v2.1.0) — working perfectly across all 9 runs
- Entity-state vs ambient/offset rule (v2.1.0) — working for game-prompt evals
- Phase tag handling — round-trips correctly in all 9 runs
- General prohibition preservation — working in 8/9 runs (only the one polarity-inversion case)

---

## Proposed version bump: v2.1.0 → v2.2.0

Changes for v2.2.0 (MINOR — two new rules, no breaking changes):
1. SPEC §9 pitfall 14: polarity verification for `!!`
2. SPEC §4 + §10: code block preservation + size guidance
3. SKILL step 6: two new verify checks (polarity, code block count)

Fix 3 (named examples) deferred to v2.3.0 — lower severity, needs more evidence from additional evals before hardening into the spec.

---

## Evidence quality note

All 9 source docs were compressed and translated by the same model (Claude) in the same session. A more rigorous eval would use different models for compression vs. translation, and multiple independent runs. The polarity inversion (Fix 1) and code block drop (Fix 2) are high-confidence findings because they represent a clear skill instruction being violated, not a judgment call. Fix 3 is a hypothesis from 2 docs — run more evals before committing to a rule.
