# skill archive

Historical versions of the BOTSPEAK skills, kept so we can run evals against any prior version and compare behavior when the live skill changes.

## naming

`v<seq>-<YYYYMMDD>-<lines>L-<short-tag>.md`

- `seq` — chronological order, padded to 2 digits
- `YYYYMMDD` — commit date
- `lines` — line count of the file
- `short-tag` — what changed in that revision

## botspeak/

| version | date | lines | source commit | notes |
|---|---|---|---|---|
| v01 | 2026-05-05 | 66 | `28c90f3` | initial release (BOTSPEAK v0.1.0) |
| v02 | 2026-05-05 | 72 | `80497b8` | added missing /botspeak compress skill |
| v03 | 2026-05-05 | 72 | `38b8cbf` | **known good** — produced working iter1 Flappy Bird in one shot |
| v04 | 2026-05-05 | 127 | `8d85e55` | skills consolidation, batch mode |
| v05 | 2026-05-06 | 163 | `3c70501` | rules + README-FOR-AI sync |
| v06 | 2026-05-06 | 166 | `91cfdf8` | never read target file when replacing |
| v07 | 2026-05-07 | 339 | `75ad417` | hardened v2 — produced **broken** Flappy Bird (pipe spawn schism) |
| v08 | 2026-05-07 | 200 | `pending` | BOTSPEAK v2.0.0 — added versioning header protocol; bumped from v0.2.0 to v2.0.0 |
| v09 | 2026-05-08 | 221 | `pending` | BOTSPEAK v2.1.0 — entity-state vs ambient/offset rule + @defs hygiene check |
| v10 | 2026-05-18 | 224 | `pending` | BOTSPEAK v2.2.0 — polarity-verification on `!!` + code-block parity count in step 6 verify |

## botspeak-translate/

| version | date | lines | source commit | notes |
|---|---|---|---|---|
| v01 | 2026-05-05 | 56 | `8d85e55` | initial |
| v02 | 2026-05-06 | 84 | `3c70501` | rules sync |
| v03 | 2026-05-07 | 147 | `75ad417` | fidelity vs paraphrase distinction |

## spec/

| version | date | lines | source commit | notes |
|---|---|---|---|---|
| v01 | 2026-05-05 | 390 | `28c90f3` | initial release (BOTSPEAK v0.1.0) · pre-semver |
| v02 | 2026-05-05 | 390 | `8d85e55` | skills consolidation · pre-semver |
| v03 | 2026-05-07 | 689 | `75ad417` | **v2.0.0** — expanded examples, entity-motion section |
| v04 | 2026-05-08 | 835 | `pending` | **v2.1.0** — entity-state vs ambient/offset rule (§4 + §9 pitfall 13) + @defs hygiene check (§9 pitfall 12) |
| v05 | 2026-05-18 | 885 | `pending` | **v2.2.0** — polarity-verification on `!!` (§9 pitfall 14) + code-block parity rule (§4 + §9 pitfall 15) + size guidance (§10) |

## why this matters

When a new skill version regresses on an eval that an older version passed, we can:

1. Diff the two skill versions to isolate what changed
2. Re-run the failing eval against both
3. Identify which rule (added or removed) caused the regression

The Flappy Bird eval is the canonical case: v03 (72 lines) one-shotted a working game. v07 (339 lines) one-shotted a broken game. The diff between them is where the regression lives.
