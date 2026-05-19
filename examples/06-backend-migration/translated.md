# Translated: 06-backend-migration

**Note:** This stub is a placeholder; for the actual round-trip audit of this
document, see [evals/round-trip-results.md](../../evals/round-trip-results.md) row 06.

**Source:** `before.md` (12,063 tokens) → BOTSPEAK `after.md` (9,783 tokens) =
**19% token reduction**.

**Why so modest:** This document is roughly 40% fenced code blocks — three
Mermaid diagrams, five `text` blocks, one SQL snippet, one YAML config — all
of which BOTSPEAK preserves byte-for-byte. The skill verifies this with a
code-block parity count check on every compression (SPEC §9 pitfall 15).

**To audit fidelity yourself:** count fenced blocks in `before.md` and
`after.md`; the counts must match (20 in both). Run `/botspeak-translate after.md`
and diff against `before.md` for full content fidelity.

**Key insight:** Compression ratios on code-heavy documents are bounded by
how much code there is. The prose around protected blocks compresses well;
the blocks themselves don't move. This is by design.
