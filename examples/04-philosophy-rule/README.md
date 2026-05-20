# Example 04 — Real-world manifesto-style `CLAUDE.md` from a 198K-star repo

This is the live `CLAUDE.md` file from [`obra/superpowers`](https://github.com/obra/superpowers) at the time of capture (May 2026). The repo has **198,707 stars** and is one of the most-starred Claude Code skills frameworks on GitHub. The file is an authentic AI-agent manifesto — repeated emphatic statements about what kinds of contributions the project will and will not accept, written for AI agents about to open PRs.

| File | Tokens (o200k_base) | Words | Fenced code blocks |
|---|---:|---:|---:|
| `before.md` (verbatim from GitHub) | 1,533 | 1,189 | 0 |
| `after.md` (BOTSPEAK-compressed) | 1,377 | 968 | 0 |
| **Reduction** | **10.2%** | **18.6%** | unchanged |

## What BOTSPEAK actually did here

The source is prose-heavy with a strong manifesto voice. The compression wins are structural rather than dramatic:

- **Aliases**: `human partner` (13 uses) → `HP`, `.github/PULL_REQUEST_TEMPLATE.md` (3 uses) → `PRT`. Together that saves ~25 tokens.
- **`default-phase: ALWAYS`** at the top, so the bulk of the rules read as universal without each block carrying an `[ALWAYS]` tag. `[NEW-CHAT]` marks the top warning, `[ON-TRIGGER]` marks the procedural "before opening a PR" sections.
- **Polarity normalization**: every "do not", "will not be accepted", "will be closed", and "must not" becomes a `!!` marker so the agent sees one symbol contract for every prohibition. The decompressed file (run `/botspeak-translate` on it) reads back cleanly without polarity inversion.
- **Cause-chain rewrites**: "Submitting a low-quality PR doesn't help them — it wastes the maintainers' time, burns your human partner's reputation, and the PR will be closed anyway. That is not being helpful. That is being a tool of embarrassment." → `low-quality PR != helpful · -> wastes maintainer time · -> burns HP reputation · -> PR closed anyway · = tool of embarrassment`. Same four outcomes, much terser shape.

The acceptance-test blockquote (`> Let's make a react todo list`) is preserved verbatim — it's the literal exact-match string a real harness has to send to verify a working integration, so reformatting it would break the test.

## Why this replaced the prior synthetic example

The earlier `before.md` here was a synthetic project-philosophy rule with `🚨` headers, ALL-CAPS section restatements, and emoji checklists (`✅ ❌ 🛑`). It compressed to ~37%, but most of that gain came from the source being padded — a hostile reader could fairly call it a strawman. Replacing it with a real, externally-authored manifesto from a high-star repo gives a defensible 10% reduction on prose that nobody can claim was written to make BOTSPEAK look good. The numbers are smaller. The numbers are also honest, and they sit in the same 4–13% band as the other real-world examples (07–09).

## Provenance

Fetched from `https://raw.githubusercontent.com/obra/superpowers/e7a2d16476bf042e9add4699c9d018a90f86e4a6/CLAUDE.md` on 2026-05-19. That commit SHA pins the file to the version captured here (`e7a2d16` · authored 2026-04-28 · `Require session transcript for new-harness PRs`). The compression was performed by Claude (Opus 4.7) following SPEC.md v2.2.0.

## Verify

```bash
python3 -c "
import tiktoken
enc = tiktoken.get_encoding('o200k_base')
for p in ['before.md','after.md']:
    print(p, len(enc.encode(open(p).read())))
"
```
