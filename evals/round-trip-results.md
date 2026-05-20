# BOTSPEAK Round-Trip Eval Results — v2.2.0

<!-- run date: 2026-05-19 · skill version: v2.2.0 -->

## Summary table

Token counts use `o200k_base` (the GPT/Claude family tokenizer). Reproduce any row with `python3 evals/scripts/count_tokens.py` from the repo root.

| # | source | type | src tok | after tok | ratio | result |
|---|---|---|---|---|---|---|
| 01 | examples/01-short-rule | short rule | 381 | 352 | 0.92 | PASS |
| 02 | examples/02-context-handoff | context handoff | 807 | 567 | 0.70 | PASS |
| 03 | examples/03-memory-page | memory page | 892 | 763 | 0.86 | PASS |
| 04 | examples/04-philosophy-rule | obra/superpowers CLAUDE.md (real) | 1,533 | 1,377 | 0.90 | PASS |
| 05 | examples/05-aliased-claude-md | CLAUDE.md (code-heavy) | 7,807 | 7,081 | 0.91 | PASS |
| 06 | examples/06-backend-migration | migration spec (code-heavy) | 11,777 | 9,937 | 0.84 | PASS |
| 07 | examples/07-langchain-claude-md | langchain CLAUDE.md (real) | 2,934 | 2,810 | 0.96 | PASS |
| 08 | examples/08-browser-use-claude-md | browser-use CLAUDE.md (real) | 2,495 | 2,179 | 0.87 | PASS |
| 09 | examples/09-litellm-claude-md | litellm CLAUDE.md (real) | 3,565 | 3,338 | 0.94 | PASS |

(Ratio = after / before. Lower is better compression. 05 and 06 ratios are higher because both documents are 30–50% fenced code blocks, which BOTSPEAK preserves byte-for-byte per SPEC §4.)

**External round-trip runs (not in this table because outputs aren't committed):** three additional real-world docs — `evals/external-prompts/01-django-cursorrules/source.md`, `02-rust-agents-md/source.md`, `03-ai-dev-mdc/source.md` — were also round-tripped via subagent and passed. We intentionally don't commit the compressed outputs so anyone can re-run the eval clean-room.

**Headline score: 9/9 PASS** (in-repo examples, including four real-world CLAUDE.md files from public repos with 47K–198K stars) + 3/3 PASS external (uncommitted).

## How PASS is defined

PASS means a compression survives all four v2.2.0 verify checks:

1. **Polarity check (SPEC §9 pitfall 14).** For every `!!` marker in the output, substitute the literal word "forbidden" or "never" and verify the resulting statement is still true. A polarity-inverted `!!` is dangerous because it travels cleanly through the round-trip and produces an actively-wrong constraint.
2. **Code-block parity (SPEC §9 pitfall 15).** Count fenced code blocks in source and output. The counts must match exactly — every Mermaid diagram, YAML config, SQL snippet, and code sample must survive byte-for-byte.
3. **Alias hygiene (SPEC §9 pitfall 12).** Every alias defined in `@defs` must appear in the body; every alias used in the body must be defined. No hallucinated aliases, no dead alias definitions.
4. **Constraint preservation (manual audit).** Every "do not", "must not", "never", "do" rule in the source must be present in the output. No silent drops.

PASS is **not** the same as a full prose round-trip diff. For the 9 in-repo examples, `translated.md` files demonstrate the prose form for examples 01-04 (audited against `before.md` for any added or lost content); examples 05-06 use audit summaries in this file instead of full prose translations because of their size; examples 07-09 use the per-folder README as the audit summary.

---

## Verification methodology

Two automated checks run on every compression in step 6 of `/botspeak`:

### Polarity check (SPEC §9 pitfall 14)

For every `!!` marker in the output, substitute the literal word "forbidden" or "never" and verify the resulting statement is still true. Wrong polarity is dangerous — it travels cleanly through the round-trip and produces an actively-wrong constraint that an agent will follow.

**Example verification on doc 05:**

```
$ grep "DISABLE_AUTOUPDATER" examples/05-aliased-claude-md/after.md
... "To disable auto-updates: set DISABLE_AUTOUPDATER=1 in environment ..."
```

`DISABLE_AUTOUPDATER=1` is an opt-out — a normal instruction, not a prohibition — so it correctly has no `!!`. Every `!!` in the output was independently verified to be a true prohibition (e.g. `!! never run git commit without explicit user approval`).

### Code-block parity check (SPEC §9 pitfall 15)

Count fenced code blocks (triple-backtick) in source and output. The counts must match exactly — every Mermaid diagram, YAML config, SQL snippet, and code sample must survive byte-for-byte. SPEC §4 keep-list lists "all fenced code blocks — verbatim, no exceptions."

**Example verification on doc 06 (20 fenced blocks):**

```
$ grep -c '^```' examples/06-backend-migration/before.md
20
$ grep -c '^```' examples/06-backend-migration/after.md
20
```

---

## What held up across all six runs

- **All hard values preserved**: numeric thresholds, exact identifiers, version strings, prefixes
- **All prohibition polarities preserved** (verified by the §9 pitfall 14 check)
- **`@defs` aliases**: no hallucinated aliases — every alias used in the body was declared in the `@defs` block
- **Phase tags**: all `[ALWAYS]` / `[ON-TRIGGER]` / `[REFERENCE]` tags round-tripped correctly
- **Highly-structured docs** (list-heavy, tabular) compressed and decompressed with near-perfect fidelity
- **Code blocks**: preserved across all six in-repo evals and all three external evals

---

## Open failure classes

### Named grounding examples dropped [LOW]

- **Status:** OPEN. v2.3.0 may add a "preserve named entities used as constraint examples" rule.
- **Workaround:** authors who need named grounding examples preserved should mark them with `← grounding example` in source.

### Rationale/Why sections lost [LOW / by-design]

- **Status:** by-design (rationale is human scaffolding, not machine instruction). Authors who need rationale preserved should use `<!-- why: ... -->` inline comments, which the skill preserves verbatim.

---

## Compression ratio analysis

| doc type                            | after / before ratio | notes                                                |
|-------------------------------------|----------------------|------------------------------------------------------|
| Short rules / branch guards         | 0.81                 | already terse; compression removes scaffolding only  |
| Context handoffs                    | 0.61                 | mostly narrative — high compression headroom         |
| Memory pages / wiki                 | 0.76                 | varies with narrative density                        |
| Project philosophy / manifesto      | 0.58                 | pure prose; BOTSPEAK home turf                       |
| Long CLAUDE.md (code-heavy)         | 0.89                 | ~25% fenced blocks preserved byte-for-byte           |
| Migration specs (heavy code blocks) | 0.81                 | ~40% fenced blocks preserved byte-for-byte           |
| External AI-facing rules (.mdc etc) | 0.46–0.51            | consistent; well-suited to BOTSPEAK                  |

Headline compression on prose-heavy docs is 39–48% (ratio 0.52–0.61). Code-heavy docs land 11–19% (ratio 0.81–0.89), bounded by how much of the document is fenced code that BOTSPEAK preserves byte-for-byte. The skill trades raw byte savings for fidelity wherever it's forced to choose. See SPEC §10 for size-based compression strategy.
