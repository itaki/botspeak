# Translated: 05-aliased-claude-md

**Note:** This stub is a placeholder; for the actual round-trip audit of this
document, see [evals/round-trip-results.md](../../evals/round-trip-results.md) row 05.

**Source:** `before.md` (8,083 tokens) → BOTSPEAK `after.md` (7,159 tokens) =
**11% token reduction**.

**Why so modest:** This document is unusually code-heavy — a verbatim bootstrap
shell block, banner format examples, and structured generated-file frontmatter
that the skill is required to preserve byte-for-byte. The prose around those
blocks compresses well (~30%) but the protected blocks dilute the headline number.

**Why this matters:** The v2.1.0 version of this compression (preserved at
`_history/after-v21-pre-polarity-fix.md`) reached 34% reduction — but only by
mis-tagging `DISABLE_AUTOUPDATER=1` as `!!` (forbidden) when the source actually
described it as an opt-out instruction. v2.2.0 trades the headline number for
correctness.

**To audit fidelity yourself:** run `/botspeak-translate after.md` and diff the
result against `before.md`. Every constraint, every prohibition, every numeric
value should survive the round trip with the same polarity.

**Key insight:** BOTSPEAK is not lossy compression — it is restructuring. When
the source is mostly prose, compression is large. When the source is mostly
code blocks, compression is modest. Either way the semantics survive.
