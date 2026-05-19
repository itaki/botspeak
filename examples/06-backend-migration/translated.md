# Translated: 06-backend-migration

**Note:** This stub is a placeholder; for the actual round-trip audit of this
document, see [evals/round-trip-results.md](../../evals/round-trip-results.md) row 06.

**Source:** `before.md` (12,063 tokens) → BOTSPEAK `after.md` (9,783 tokens) =
**19% token reduction**.

**Why so modest:** This document is roughly 40% fenced code blocks — three
Mermaid diagrams, five `text` blocks, one SQL snippet, one YAML config — all
of which the skill is required to preserve byte-for-byte. v2.2.0 enforces this
with a code-block parity count check.

**Why this matters:** The v2.1.0 version (preserved at
`_history/after-v21-codeblock-loss.md`) reached 46% reduction — but only by
silently dropping 18 of the 20 fenced blocks. v2.2.0 keeps all of them and
trades the headline number for completeness. The compression is now real, not
the result of unannounced data loss.

**To audit fidelity yourself:** count fenced blocks in `before.md` and
`after.md`; the counts must match. Run `/botspeak-translate after.md` and diff
against `before.md` for full content fidelity.

**Key insight:** Compression ratios on code-heavy documents are bounded by
how much code there is. v2.2.0 reports honest numbers; v2.1.0's higher ratios
were a measurement artifact of silent code loss.
