# Example 09 — Real-world `CLAUDE.md` from a 47K-star repo

This is the live `CLAUDE.md` file from [`BerriAI/litellm`](https://github.com/BerriAI/litellm) at the time of capture (May 2026). The repo has **47,485 stars** and is the unified-LLM-interface library most multi-provider proxies are built on. Just under the 50K-star bar, but the file itself is the longest of the three real-world samples in the repo (3,565 tokens of pure prose, zero fenced code blocks).

| File | Tokens (o200k_base) | Words | Fenced code blocks |
|---|---:|---:|---:|
| `before.md` (verbatim from GitHub) | 3,565 | 2,166 | 0 |
| `after.md` (BOTSPEAK-compressed) | 3,338 | 2,029 | 0 |
| **Reduction** | **6.4%** | **6.3%** | unchanged |

## Why the compression is modest (and an honest observation)

When BOTSPEAK launched we expected files like this one to compress hard — no code blocks to preserve, just prose. Reality: real-world `CLAUDE.md` files in big repos tend to **already be terse**. Their authors have been hand-tuning prompts against agents for months, so the easy wins (drop articles, drop hedging, drop throat-clearing) have largely been taken before BOTSPEAK ever sees the file.

What's left for BOTSPEAK to do:

- Alias `litellm/proxy/` (5 uses) → `PROX` and `LiteLLM` (12 uses) → `LL`. That's worth ~30 tokens.
- Normalize the polarity language: every "Never X", "Don't X", "Do not X" becomes a uniform `!! X` marker. The agent gets one symbol contract for every prohibition in the file instead of three different English phrasings.
- Strip the few remaining articles, "you should", "make sure to", "It is" leading phrases.
- Add `default-phase: ALWAYS` so the 100+ rule lines don't each carry a phase tag.

The compression number (~6%) understates the **structural** win: every prohibition now reads as `!!`, every causal chain reads as `->`, every condition reads as `[ON-TRIGGER]`. An agent ingesting this file has zero ambiguity about what is a rule vs. what is context, even if the token savings are modest.

## What this example demonstrates

Real-world `CLAUDE.md` files in large repos compress in a 4–13% band when they're code-heavy or already-terse. The ~30% number in example 02 (context handoff, prose-heavy) is not an exaggeration — it applies to a different class of document. BOTSPEAK's value is structural consistency across both classes, with token savings as a bonus.

## Provenance

Fetched from `https://raw.githubusercontent.com/BerriAI/litellm/HEAD/CLAUDE.md` on 2026-05-19. The compression was performed by Claude (Opus 4.7) following SPEC.md v2.2.0.
