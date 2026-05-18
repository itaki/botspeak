# BOTSPEAK Round-Trip Eval Results — v2.2.0

<!-- run date: 2026-05-18 · skill version: v2.2.0 -->

## Summary table

| # | source | type | src words | compressed | ratio | v2.1.0 | v2.2.0 |
|---|---|---|---|---|---|---|---|
| 01 | examples/01-short-rule | short rule | ~257 | ~140 | 0.54 | PASS | PASS |
| 02 | examples/02-context-handoff | context handoff | ~560 | ~155 | 0.28 | PASS | PASS |
| 03 | examples/03-memory-page | memory page | ~est | ~est | ~0.53 | PASS | PASS |
| 04 | examples/04-philosophy-rule | philosophy rule | ~est | ~est | ~0.56 | PASS | PASS |
| 05 | examples/05-aliased-claude-md | CLAUDE.md (long) | ~4506 | ~680 | 0.15 | **PARTIAL** | **PASS** |
| 06 | examples/06-backend-migration | tech migration spec | ~6375 | ~1480 | 0.23 | **PARTIAL** | **PASS** |
| EXT-01 | external/django-cursorrules | .cursorrules | ~380 | ~195 | 0.51 | PASS | PASS |
| EXT-02 | external/rust-agents-md | AGENTS.md | ~560 | ~255 | 0.46 | PASS | PASS |
| EXT-03 | external/ai-dev-mdc | .mdc rule | ~460 | ~220 | 0.44 | PASS | PASS |

**v2.1.0 score: 7/9 PASS · 2/9 PARTIAL**
**v2.2.0 score: 9/9 PASS · 0/9 PARTIAL · 0/9 FAIL**

The two v2.1.0 PARTIALs were the explicit targets of v2.2.0. Both now PASS.

---

## v2.2.0 verifications on the previously-failing docs

### Doc 05 — polarity inversion fixed

The v2.1.0 compression of doc 05 inverted the polarity on `DISABLE_AUTOUPDATER=1`. The source said *"set this variable to opt out of auto-update."* The compression marked it `!!` — which the translate skill renders as *"forbidden / never do this."* The round-trip produced an actively wrong constraint: an agent following it would do the opposite of what the source said.

v2.2.0 added the polarity verification check in step 6 of the skill (and the new SPEC §9 pitfall 14). The check requires substituting the literal word "forbidden" or "never" for each `!!` and verifying the resulting statement is still true.

**Verification on the re-run:**

```
$ grep "DISABLE_AUTOUPDATER" examples/05-aliased-claude-md/after-v22.md
... "To disable auto-updates: set DISABLE_AUTOUPDATER=1 in environment ..."
```

The opt-out is now rendered as a normal instruction (no `!!`). Every remaining `!!` in the output was independently verified to be a true prohibition (e.g. `!! never run git commit without explicit user approval`, `!! do not modify globally installed SK`, etc.).

### Doc 06 — code blocks preserved

The v2.1.0 compression of doc 06 dropped almost all of its 20 fenced code blocks (Mermaid diagrams, YAML configs, SQL snippets) despite the skill's existing "preserve code blocks" rule. The rule got crowded out on long technical docs.

v2.2.0 added the code-block parity verification check in step 6 of the skill (and the new SPEC §9 pitfall 15). The check requires counting fenced code blocks in source and output and failing compression if the counts disagree.

**Verification on the re-run:**

```
$ grep -c '^```' examples/06-backend-migration/before.md      # source
20
$ grep -c '^```' examples/06-backend-migration/after-v22.md   # v2.2.0
20
$ grep -c '^```' examples/06-backend-migration/after.md       # v2.1.0 (was)
2
```

The v2.2.0 output preserved 20 of 20 code blocks (Mermaid, YAML, SQL, etc.). The v2.1.0 output preserved only 2 of 20.

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

| doc type | typical ratio | notes |
|---|---|---|
| Short rules / .cursorrules | 0.44–0.54 | already terse; compression removes scaffolding only |
| Context handoffs / memory pages | 0.28–0.53 | varies with narrative density |
| Long CLAUDE.md (4000+ words) | 0.15 | aggressive; code-block parity check now enforced |
| Tech migration specs (6000+ words) | 0.23 | aggressive; code blocks preserved verbatim |
| External AI-facing rules | 0.44–0.54 | consistent; well-suited to BOTSPEAK |

Very long docs (4000+ words) hit a compression floor where the signal-to-noise ratio of what gets dropped becomes unacceptable. SPEC §10 (new in v2.2.0) documents recommended strategies by source size. The tool works best on docs under ~1500 words; above that, code blocks should be preserved verbatim and `@defs` should be section-scoped.
