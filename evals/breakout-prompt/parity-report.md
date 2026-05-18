# Breakout Parity Report — v2.2.0

Comparison of physics constants between the prose-built and BOTSPEAK-built HTML for Breakout.

- **Prose build:** `results/prose-sonnet.html` (built clean-room from `source.md` by Claude Sonnet 4.6)
- **BOTSPEAK build:** `results/botspeak-sonnet-v22.html` (built clean-room from `source-botspeak-v22.md` by Claude Sonnet 4.6)

The BOTSPEAK source was itself produced clean-room from `source.md` by Claude Sonnet 4.6 using the v2.2.0 skill, with no prior context.

---

## Physics constants

| Constant | Prose build | BOTSPEAK build | Match |
|---|---|---|---|
| Canvas width | 480 | 480 | ✓ |
| Canvas height | 640 | 640 | ✓ |
| Paddle width (px) | 80 | 80 | ✓ |
| Paddle height (px) | 12 | 12 | ✓ |
| Paddle corner radius (px) | 6 | 6 | ✓ |
| Paddle y position (canvas_height − 40) | 600 | 600 | ✓ |
| Paddle speed (px/frame) | 8 | 8 | ✓ |
| Ball radius (px) | 7 | 7 | ✓ |
| Ball initial vx | ±3 | ±3 | ✓ |
| Ball initial vy | -4 | -4 | ✓ |
| Ball vx cap (px/frame) | 7 | 7 | ✓ |
| Brick columns | 8 | 8 | ✓ |
| Brick rows | 5 | 5 | ✓ |
| Brick width (px) | 54 | 54 | ✓ |
| Brick height (px) | 20 | 20 | ✓ |
| Brick padding (px) | 4 | 4 | ✓ |
| Top row y offset (px) | 60 | 60 | ✓ |
| Row colors (5 colors) | red/orange/yellow/green/blue | red/orange/yellow/green/blue | ✓ |
| Row scores | 50 / 40 / 30 / 20 / 10 | 50 / 40 / 30 / 20 / 10 | ✓ |
| Serve delay (frames) | 30 | 30 | ✓ |
| Starting lives | 3 | 3 | ✓ |

**Result: 21 / 21 constants match.**

---

## Mechanic parity checks

| Check | Prose | BOTSPEAK | Match |
|---|---|---|---|
| Paddle bounce angle uses (ball.cx − paddle.cx) / (paddle.w/2) × 5 | ✓ | ✓ | ✓ |
| Brick collision determines hit edge from previous-frame center | ✓ | ✓ | ✓ |
| Lose life when ball top edge passes bottom | ✓ | ✓ | ✓ |
| Game states: menu / playing / win / gameover | ✓ | ✓ | ✓ |
| Win on all bricks cleared, gameover on lives = 0 | ✓ | ✓ | ✓ |
| Mouse/touch override keyboard for paddle position | ✓ | ✓ | ✓ |
| Audio: 440Hz square paddle, 220Hz sine wall, 660+880Hz brick | ✓ | ✓ | ✓ |
| Restart resets lives = 3, score = 0, repopulates bricks | ✓ | ✓ | ✓ |

---

## What this demonstrates

Breakout is the Tier 1–2 game from the research digest — adds a brick grid data structure on top of Pong's physics, testing whether compression preserves combined specs. The clean-room v2.2.0 build matched the prose build exactly on all 21 numeric constants and all behavioral rules.

Of particular note: the per-row color array, the per-row score array, and the brick collision-edge detection logic all survived compression and round-tripped to functionally identical implementations.
