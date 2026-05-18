# Pong Parity Report — v2.2.0

Comparison of physics constants between the prose-built and BOTSPEAK-built HTML for Pong.

- **Prose build:** `results/prose-sonnet.html` (built clean-room from `source.md` by Claude Sonnet 4.6)
- **BOTSPEAK build:** `results/botspeak-sonnet-v22.html` (built clean-room from `source-botspeak-v22.md` by Claude Sonnet 4.6)

The BOTSPEAK source was itself produced clean-room from `source.md` by Claude Sonnet 4.6 using the v2.2.0 skill, with no prior context.

---

## Physics constants

| Constant | Prose build | BOTSPEAK build | Match |
|---|---|---|---|
| Canvas width | 800 | 800 | ✓ |
| Canvas height | 500 | 500 | ✓ |
| Paddle width (px) | 12 | 12 | ✓ |
| Paddle height (px) | 80 | 80 | ✓ |
| Player paddle speed (px/frame) | 7 | 7 | ✓ |
| CPU paddle approach speed (px/frame) | 5 | 5 | ✓ |
| CPU paddle retreat speed (px/frame) | 2 | 2 | ✓ |
| Ball size (px) | 12 | 12 | ✓ |
| Ball initial vx (px/frame) | 5 | 5 | ✓ |
| Ball speedup multiplier per paddle hit | 1.05 | 1.05 | ✓ |
| Ball vx cap (px/frame) | 12 | 12 | ✓ |
| Win score | 7 | 7 | ✓ |
| Serve delay (frames) | 60 | 60 | ✓ |
| Subtitle pulse period (frames) | 60 | 60 | ✓ |

**Result: 14 / 14 constants match.**

---

## Mechanic parity checks

| Check | Prose | BOTSPEAK | Match |
|---|---|---|---|
| Paddle bounce angle uses (ball.center_y − paddle.center_y) / (paddle.h/2) × 7 | ✓ | ✓ | ✓ |
| Wall bounce inverts ball.vy on top/bottom edge | ✓ | ✓ | ✓ |
| CPU drifts toward center when ball moves away | ✓ | ✓ | ✓ |
| Score resets ball with vx in scoring player's direction | ✓ | ✓ | ✓ |
| Game states: menu / playing / gameover | ✓ | ✓ | ✓ |
| Audio: 440Hz square paddle hit, 220Hz sine wall hit | ✓ | ✓ | ✓ |
| Win fanfare ascends C5 → E5 → G5 at 120ms each | ✓ | ✓ | ✓ |
| Keyboard + touch input both work simultaneously | ✓ | ✓ | ✓ |
| Canvas resize via CSS transform, internal res stays 800×500 | ✓ | ✓ | ✓ |

---

## What this demonstrates

Pong is the Tier 1 canary game from the research digest — the simplest one-shot game in the suite. A failure here would mean BOTSPEAK is too lossy even for trivial cases. The clean-room v2.2.0 build matched the prose build on every numeric constant and every behavioral rule.
