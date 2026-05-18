# Snake Parity Report — v2.2.0

Comparison of physics constants between the prose-built and BOTSPEAK-built HTML for Snake.

- **Prose build:** `results/prose-sonnet.html` (built clean-room from `source.md` by Claude Sonnet 4.6)
- **BOTSPEAK build:** `results/botspeak-sonnet-v22.html` (built clean-room from `source-botspeak-v22.md` by Claude Sonnet 4.6)

The BOTSPEAK source was itself produced clean-room from `source.md` by Claude Sonnet 4.6 using the v2.2.0 skill, with no prior context.

---

## Game constants

| Constant | Prose build | BOTSPEAK build | Match |
|---|---|---|---|
| Grid columns | 20 | 20 | ✓ |
| Grid rows | 20 | 20 | ✓ |
| Cell size (px) | 20 | 20 | ✓ |
| Tick start (ms) | 150 | 150 | ✓ |
| Tick minimum (ms) | 60 | 60 | ✓ |
| Tick decrement per 5 foods (ms) | 10 | 10 | ✓ |
| LocalStorage best score key | `snakeBest` | `snakeBest` | ✓ |
| Food pulse cycle (frames) | 60 | 60 | ✓ |
| Food pulse radius range (px) | 7–9 | 7–9 | ✓ |
| Subtitle opacity oscillation | sine of frame count | sine of frame count | ✓ |

**Result: 10 / 10 constants and mechanics match.**

---

## Mechanic parity checks

| Check | Prose | BOTSPEAK | Match |
|---|---|---|---|
| Single food at a time, random empty cell | ✓ | ✓ | ✓ |
| No-reverse-direction rule | ✓ | ✓ | ✓ |
| Input buffer holds at most 1 pending direction change | ✓ | ✓ | ✓ |
| Head ↔ body collision = game over | ✓ | ✓ | ✓ |
| Head ↔ wall collision = game over | ✓ | ✓ | ✓ |
| +10 points per food | ✓ | ✓ | ✓ |
| Eat → ascending two-tone (440/660 Hz) | ✓ | ✓ | ✓ |
| Death → descending tone + noise burst | ✓ | ✓ | ✓ |
| Separate logic loop (setTimeout) and render loop (rAF) | ✓ | ✓ | ✓ |
| `'use strict'` and labeled sections | ✓ | ✓ | ✓ |

---

## What this demonstrates

Identical to the Flappy Bird parity result: a fresh model given only the BOTSPEAK-compressed file produced a game with the same numeric constants and mechanics as one built from the prose source. The two were built independently with no shared context.

Snake is a grid-based logic game with different failure modes than Flappy Bird (no per-entity physics, but the input-buffer rule and the no-reverse direction rule are exactly the kind of details a sloppy compression could lose). The v2.2.0 skill preserved both.
