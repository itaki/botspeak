# Translated: 05-aliased-claude-md

**Note:** This stub is a placeholder; for the actual round-trip audit of this
document, see [evals/round-trip-results.md](../../evals/round-trip-results.md) row 05.

**Source:** `before.md` (8,083 tokens) → BOTSPEAK `after.md` (7,159 tokens) =
**11% token reduction**.

**Why so modest:** This document is unusually code-heavy — a verbatim bootstrap
shell block, banner format examples, and structured generated-file frontmatter
that the skill is required to preserve byte-for-byte. The prose around those
blocks compresses well (~30%) but the protected blocks dilute the headline number.

**Polarity discipline:** Note that `DISABLE_AUTOUPDATER=1` appears in the output as a normal instruction (no `!!`) even though the source phrased it cautiously. `!!` is reserved for true prohibitions — substitute the literal word "forbidden" for each `!!` and verify the resulting statement holds (SPEC §9 pitfall 14).

**To audit fidelity yourself:** run `/botspeak-translate after.md` and diff the
result against `before.md`. Every constraint, every prohibition, every numeric
value should survive the round trip with the same polarity.

**Key insight:** BOTSPEAK is not lossy compression — it is restructuring. When
the source is mostly prose, compression is large. When the source is mostly
code blocks, compression is modest. Either way the semantics survive.
