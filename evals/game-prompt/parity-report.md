# Flappy Bird Parity Report — v2.2.0

Comparison of physics constants between the prose-built and BOTSPEAK-built HTML for Flappy Bird.

- **Prose build:** `results/flappy-prose.html` (built from `source.md` by Claude)
- **BOTSPEAK build:** `results/botspeak-sonnet-v22.html` (built clean-room from `source-botspeak-v22.md` by Claude Sonnet 4.6, with no other context)

The BOTSPEAK source `source-botspeak-v22.md` was itself produced clean-room from `source.md` by Claude Sonnet 4.6 using the v2.2.0 skill, with no prior context about earlier compressions.

---

## Physics constants

| Constant | Prose build | BOTSPEAK build | Match |
|---|---|---|---|
| Canvas width | 480 | 480 | ✓ |
| Canvas height | 640 | 640 | ✓ |
| Ground height | 40 | 40 | ✓ |
| Bird radius | 14 | 14 | ✓ |
| Gravity (px/frame²) | 0.5 | 0.5 | ✓ |
| Flap velocity (px/frame) | -9 | -9 | ✓ |
| Terminal velocity (px/frame) | 12 | 12 | ✓ |
| Pipe speed (px/frame) | 3 | 3 | ✓ |
| Pipe width (px) | 60 | 60 | ✓ |
| Pipe gap (px) | 150 | 150 | ✓ |
| Pipe spawn interval (frames) | 90 | 90 | ✓ |
| First pipe spawn frame | 120 | 120 | ✓ |
| Collision forgiveness margin (px) | 4 | 4 | ✓ |
| Particle count on death | 20 | 20 | ✓ |
| Particle life (frames) | 40 | 40 | ✓ |

**Result: 15 / 15 physics constants match.**

---

## Mechanic parity checks

| Check | Prose | BOTSPEAK | Match |
|---|---|---|---|
| Per-pipe state (each pipe has its own `x` that mutates) | ✓ | ✓ | ✓ |
| Pipe removal when off-screen | ✓ | ✓ | ✓ |
| Ground & clouds use ambient offset (shared scalar) | ✓ | ✓ | ✓ |
| Game states: menu / playing / dying / gameover | ✓ | ✓ | ✓ |
| Particle animation completes before gameover transition | ✓ | ✓ | ✓ |
| localStorage best score | ✓ | ✓ | ✓ |
| Web Audio API flap / point / hit / die sounds | ✓ | ✓ | ✓ |
| SPACE or canvas tap restarts to playing (not menu) | ✓ | ✓ | ✓ |
| `requestAnimationFrame` + integer frame counter for timing | ✓ | ✓ | ✓ |

---

## What this demonstrates

The BOTSPEAK v2.2.0 skill preserved every numeric constant and every behavioral rule from the prose specification through compression. A fresh model with no context, given only the compressed file, produced a game with identical physics to one built from the prose source.

This is the eval the project was designed to pass: round-trip equivalence between prose and BOTSPEAK at the level of generated artifact behavior, not just at the level of file content.

---

## Historical note

The v4 botspeak-built Flappy Bird (May 2026, BOTSPEAK v2.0.0) failed this exact eval because the compression conflated per-entity pipe state with ambient offset scrolling. The v2.1.0 spec added the entity-state vs. ambient-offset rule (SPEC §9 pitfall 13) and v2.2.0 added the polarity and code-block parity verify checks (§9 pitfalls 14 and 15). The clean-room v2.2.0 build above is the first build that passed the eval without any in-context guidance to the build agent.
