# Example 07 — Real-world `CLAUDE.md` from a 137K-star repo

This is the live `CLAUDE.md` file from [`langchain-ai/langchain`](https://github.com/langchain-ai/langchain) at the time of capture (May 2026). The repo has **137,063 stars** and is one of the most-used Python LLM frameworks in the world.

| File | Tokens (o200k_base) | Words | Fenced code blocks |
|---|---:|---:|---:|
| `before.md` (verbatim from GitHub) | 2,934 | 1,788 | 9 |
| `after.md` (BOTSPEAK-compressed) | 2,810 | 1,677 | 9 |
| **Reduction** | **4.2%** | **6.2%** | unchanged |

## Why the compression is modest

This file is dominated by fenced code blocks — 9 of them. BOTSPEAK preserves every fenced block byte-for-byte (SPEC §4 "Keep absolutely") because code is already optimized: rewriting it would break the example. That cap is by design, not a failure.

What BOTSPEAK still does:

- Aliases the repeated `langchain-profiles` (4 uses) → `LCP`, `.github/workflows/` (8 uses) → `WF`, and the recurring "named entity (class, function, method, parameter, or variable name)" phrase → `NE`. Together that saves ~40 tokens.
- Drops articles ("a", "the", "an") and filler ("In this section we will…") across ~50 prose lines.
- Adds phase tags so the agent can skip parts of the doc once context is established (`[NEW-CHAT]`, `default-phase: ALWAYS`).
- Converts narrative chains to causal arrows (`->`) and constraint markers (`!!` for prohibitions).

The takeaway: when the source is already mostly code examples plus terse bullet lists (as most high-quality `CLAUDE.md` files in big repos are), the prose-stripping headroom is small. For prose-heavy AI-facing docs (handoffs, philosophy, multi-paragraph rules) the same machinery hits 30-40%. See examples 02 and 04.

## Provenance

Fetched from `https://raw.githubusercontent.com/langchain-ai/langchain/HEAD/CLAUDE.md` on 2026-05-19. The compression was performed by Claude (Opus 4.7) following SPEC.md v2.2.0.

## Verify

```bash
python3 -c "
import tiktoken
enc = tiktoken.get_encoding('o200k_base')
for p in ['before.md','after.md']:
    print(p, len(enc.encode(open(p).read())))
"
```
