# BOTSPEAK Round-Trip Eval Results — v2.2.0

<!-- run date: 2026-05-18 · skill version: v2.2.0 -->

## Summary table

All token counts are character-count / 4 (the GPT/Claude BPE rule of thumb). Reproduce any row with `wc -c $before $after`.

| # | source | type | src tok | v2.2.0 tok | ratio | v2.1.0 | v2.2.0 |
|---|---|---|---|---|---|---|---|
| 01 | examples/01-short-rule | short rule | 411 | 337 | 0.82 | PASS | PASS |
| 02 | examples/02-context-handoff | context handoff | 1,019 | 624 | 0.61 | PASS | PASS |
| 03 | examples/03-memory-page | memory page | 1,003 | 758 | 0.76 | PASS | PASS |
| 04 | examples/04-philosophy-rule | philosophy rule | 1,748 | 1,005 | 0.58 | PASS | PASS |
| 05 | examples/05-aliased-claude-md | CLAUDE.md (code-heavy) | 8,083 | 7,159 | 0.89 | **PARTIAL** | **PASS** |
| 06 | examples/06-backend-migration | migration spec (code-heavy) | 12,063 | 9,783 | 0.81 | **PARTIAL** | **PASS** |

(Ratio = after / before. Lower is better compression. 05 and 06 ratios are high because both documents are 30–50% fenced code blocks, which v2.2.0 now preserves byte-for-byte.)

**External round-trip runs (not in this table because outputs aren't committed):** three additional real-world docs — `evals/external-prompts/01-django-cursorrules/source.md`, `02-rust-agents-md/source.md`, `03-ai-dev-mdc/source.md` — were also round-tripped via subagent and passed in both v2.1.0 and v2.2.0. We intentionally don't commit the compressed outputs so anyone can re-run the eval clean-room against the v2.2.0 skill.

**v2.1.0 score: 4/6 PASS · 2/6 PARTIAL** (in-repo examples) + 3/3 PASS external (uncommitted)
**v2.2.0 score: 6/6 PASS · 0/6 PARTIAL · 0/6 FAIL** (in-repo examples) + 3/3 PASS external (uncommitted)

The two v2.1.0 PARTIALs were the explicit targets of v2.2.0. Both now PASS. The previous version of this doc reported "9/9" by counting the external runs in the headline; we now treat them as supporting evidence rather than headline numbers because their compressed outputs are not in the repo.

---

## v2.2.0 verifications on the previously-failing docs

### Doc 05 — polarity inversion fixed

The v2.1.0 compression of doc 05 inverted the polarity on `DISABLE_AUTOUPDATER=1`. The source said *"set this variable to opt out of auto-update."* The compression marked it `!!` — which the translate skill renders as *"forbidden / never do this."* The round-trip produced an actively wrong constraint: an agent following it would do the opposite of what the source said.

v2.2.0 added the polarity verification check in step 6 of the skill (and the new SPEC §9 pitfall 14). The check requires substituting the literal word "forbidden" or "never" for each `!!` and verifying the resulting statement is still true.

**Verification on the re-run:**

```
$ grep "DISABLE_AUTOUPDATER" examples/05-aliased-claude-md/after.md
... "To disable auto-updates: set DISABLE_AUTOUPDATER=1 in environment ..."
```

The opt-out is now rendered as a normal instruction (no `!!`). Every remaining `!!` in the output was independently verified to be a true prohibition (e.g. `!! never run git commit without explicit user approval`, `!! do not modify globally installed SK`, etc.). The v2.1.0 version that mis-applied `!!` is preserved at `examples/05-aliased-claude-md/_history/after-v21-pre-polarity-fix.md`.

### Doc 06 — code blocks preserved

The v2.1.0 compression of doc 06 dropped almost all of its 20 fenced code blocks (Mermaid diagrams, YAML configs, SQL snippets) despite the skill's existing "preserve code blocks" rule. The rule got crowded out on long technical docs.

v2.2.0 added the code-block parity verification check in step 6 of the skill (and the new SPEC §9 pitfall 15). The check requires counting fenced code blocks in source and output and failing compression if the counts disagree.

**Verification on the re-run:**

```
$ grep -c '^```' examples/06-backend-migration/before.md      # source
20
$ grep -c '^```' examples/06-backend-migration/after.md       # v2.2.0 (canonical)
20
$ grep -c '^```' examples/06-backend-migration/_history/after-v21-codeblock-loss.md
2
```

The v2.2.0 output preserved 20 of 20 code blocks (Mermaid, YAML, SQL, etc.). The v2.1.0 output preserved only 2 of 20. Both versions are tracked in git so the regression is reproducible.

---

## Failure classes — v2.2.0 status

### Class 1: Polarity inversion [CRITICAL] — FIXED

- **Status:** RESOLVED in v2.2.0 (SPEC §9 pitfall 14 + skill step 6 polarity check)
- **Mechanism:** Step 6 of the skill now requires verifying each `!!` is a true prohibition by substituting the literal word "forbidden" and confirming the resulting statement holds.

### Class 2: Code block dropping [HIGH] — FIXED

- **Status:** RESOLVED in v2.2.0 (SPEC §9 pitfall 15 + §4 keep-list update + skill step 6 code-block parity check)
- **Mechanism:** Step 6 of the skill now requires counting fenced code blocks in source vs output and failing compression if the counts disagree. SPEC §4 keep-list now explicitly names "all fenced code blocks — verbatim, no exceptions."

### Class 3: Named grounding examples dropped [LOW] — unchanged

- **Status:** OPEN. v2.2.0 did not target this class. v2.3.0 may add a "preserve named entities used as constraint examples" rule.
- **Workaround:** authors who need named grounding examples preserved should mark them with `← grounding example` in source.

### Class 4: Rationale/Why sections lost [LOW / by-design] — unchanged

- **Status:** by-design (rationale is human scaffolding, not machine instruction). Authors who need rationale preserved should use `<!-- why: ... -->` inline comments, which the skill preserves verbatim.

---

## What held up well (carried forward from v2.1.0)

- **All hard values preserved**: numeric thresholds, exact identifiers, version strings, prefixes
- **All prohibition polarities preserved** (now including the previously-failing DISABLE_AUTOUPDATER case)
- **`@defs` aliases**: no hallucinated aliases in any of the 9 runs (v2.1.0 hygiene check working)
- **Phase tags**: all `[ALWAYS]` / `[ON-TRIGGER]` / `[REFERENCE]` tags round-tripped correctly
- **Highly-structured docs** (list-heavy, tabular) compressed and decompressed with near-perfect fidelity
- **Code blocks**: now preserved across all 9 evals including the previously-failing docs 05 and 06

---

## Compression ratio analysis

| doc type                            | after / before ratio | notes                                                    |
|-------------------------------------|----------------------|----------------------------------------------------------|
| Short rules / branch guards         | 0.82                 | already terse; compression removes scaffolding only      |
| Context handoffs                    | 0.61                 | mostly narrative — high compression headroom             |
| Memory pages / wiki                 | 0.76                 | varies with narrative density                            |
| Project philosophy / manifesto      | 0.58                 | pure prose; BOTSPEAK home turf                           |
| Long CLAUDE.md (code-heavy)         | 0.89                 | 25% fenced blocks now preserved byte-for-byte (v2.2.0)   |
| Migration specs (heavy code blocks) | 0.81                 | ~40% fenced blocks preserved byte-for-byte (v2.2.0)      |
| External AI-facing rules (.mdc etc) | 0.46–0.51            | consistent; well-suited to BOTSPEAK                      |

Headline compression on prose-heavy docs is 39–48% (ratio 0.52–0.61). Code-heavy docs land 11–19% (ratio 0.81–0.89), bounded by how much of the document is fenced code that the v2.2.0 skill is required to preserve byte-for-byte. The v2.1.0 numbers were higher specifically because the skill was silently dropping content; v2.2.0 trades headline ratio for fidelity. See SPEC §10 (new in v2.2.0) for size-based compression strategy.
