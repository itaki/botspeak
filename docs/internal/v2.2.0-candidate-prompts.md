# Candidate Games for BOTSPEAK Eval Suite — Research Digest

**Purpose.** Identify HTML5 canvas games beyond Flappy Bird that current frontier models
(Claude Haiku / Sonnet / Opus, GPT-5.2, Gemini 3) have demonstrably produced from a single
prompt, so the BOTSPEAK eval can test whether compressed prompts preserve enough
information for one-shot generation.

**Research value: high** — multiple recent (Q4 2025 – Q1 2026), explicit one-shot
comparisons across models exist for several candidate games, with concrete failure modes
documented. The space is well-covered enough to make defensible difficulty-tier picks.

**Method.** Phased web search (2026-05) across vibe-coding case studies, Ars Technica /
Tom's Hardware / KDnuggets head-to-head model comparisons, GitHub repos that publish
multi-model outputs from a single prompt, and engineering blog post-mortems. Sources
emphasized are ones that explicitly state "single prompt" or "first attempt" and name the
model + date.

**Important caveat.** "One-shot" in the wild usually means "the developer typed one prompt
and got something playable that may still need polish." The eval needs a stricter definition
(e.g. "compiles, runs, all mechanics from spec implemented, no fatal bugs"). Treat the
external evidence below as a ranking signal, not a guarantee.

---

## Candidate 1 — Pong

**Mechanics.** Two paddles (one per player or one vs CPU), ball with linear motion, paddle
collision that reflects with an angle modifier, score on miss, first-to-N wins.

**Evidence of one-shot success.**
- Smartchunks "Build A Simple HTML5 Game With Claude Code" (Apr 2026) reports Pong as
  the canonical 30–60 minute single-screen arcade build with Claude Code, citing the
  Linuxbeast write-up's claim: *"The first prototype always worked. Every time I described
  a new game concept, Claude produced a working version on the first attempt."*
  <https://smartchunks.com/build-html5-game-claude-code-prompt-to-playable/>
- Listed as a one-prompt game in the openclaw "opencode-games" skill catalog (referenced
  in multiple search results) and present in many community Claude Artifacts galleries.
- Linuxbeast (3 browser games in a day) used a similar single-prompt-first workflow.
  <https://linuxbeast.com/blog/how-i-built-3-browser-games-in-one-day-with-claude-ai/>

**Complexity.** Lowest complexity in the candidate set — two rectangles, one circle, four
collision walls, no AI beyond simple paddle-tracking on the CPU side.

**Spec elements a one-shot prompt must include.**
- Canvas size (e.g. 800×600), background color, paddle/ball colors
- Paddle dimensions, movement speed, and which keys (W/S vs Up/Down) drive which paddle
- Ball initial velocity, speed-up rule on bounce (or none), serve direction after a point
- Wall bounce on top/bottom, scoring on left/right edge
- Score display, win condition (e.g. first to 7), reset / "press space to play again" flow
- CPU AI behavior if single-player (track-ball with max speed cap)

**Known failure modes.**
- Tunneling on fast balls (ball passes through paddle in one frame) — needs continuous
  collision detection or speed cap.
- Bounce angle is sometimes constant (flat reflection) rather than modified by where the
  ball hit the paddle, producing boring deterministic rallies.
- CPU paddle either unbeatable (perfect tracking) or trivially beatable (no speed cap).
- Keyboard input that drops one of two simultaneously-held keys on some browsers.

**Recommended tier.** **Tier 1 (Haiku-reliable).** Use as the "compression should not break
this" baseline. If BOTSPEAK ever fails on Pong, the compression is too aggressive.

---

## Candidate 2 — Breakout / Arkanoid

**Mechanics.** Paddle at the bottom, ball bouncing off walls and paddle, grid of bricks
that disappear on hit and award points, lose a life on miss, win on clearing all bricks.

**Evidence of one-shot success.**
- "30 Days of Vibe Coding — Day 5 Breakout" (N9O, 2026) explicitly used a single
  paragraph prompt: *"I want to create a Breakout/Arkanoid style arcade game with multiple
  levels, power-ups, combo scoring, and smooth physics."*
  <https://n9o.xyz/posts/202604-vibe30/day05-breakout/>
- Smartchunks Claude Code guide ranks Breakout alongside Pong and Snake in the 30–60 min
  one-shot tier, citing MDN's Breakout tutorial as the reference mechanic set.
- Frequently appears in Claude Artifacts galleries and community demos as a "Claude
  produced this on first try" example.

**Complexity.** Slightly above Pong — adds a brick grid (data structure), per-brick
collision, and lives/score state. Power-ups in the Vibe-Coding version add iteration but
are optional for an eval.

**Spec elements a one-shot prompt must include.**
- Canvas size, paddle dimensions and speed, ball radius and initial velocity
- Brick grid layout (rows × cols, brick dimensions, padding, top offset, colors per row)
- Collision rules: ball ↔ wall, ball ↔ paddle (with angle modifier), ball ↔ brick (which
  edge was hit determines x vs y reflection)
- Lives counter (e.g. 3), score per brick, win condition (all bricks cleared)
- Controls (mouse, arrow keys, or both) and serve mechanic (start on click/space)

**Known failure modes.**
- Brick collision frequently treats the ball as a point, producing wrong reflection on
  corner hits.
- Multi-brick destruction in a single frame is often unhandled (ball clips through two
  bricks at once).
- "Stuck ball" edge case where the ball trapped between paddle and wall oscillates
  forever.
- Win/lose state transitions missing (game just stops with no restart UI).

**Recommended tier.** **Tier 1–2 (Haiku-borderline, Sonnet-reliable).** Good second-tier
test — physics + grid data combined, but mechanics are widely represented in training data.

---

## Candidate 3 — Asteroids

**Mechanics.** Ship with rotation + thrust + inertia (no friction), screen-wrap on edges,
fire bullets, asteroids that split into smaller pieces when shot, lose on collision, level
clears when all asteroids destroyed.

**Evidence of one-shot success.**
- AST3ROIDX (pagefault.it / rogue1.it, 2026) — full Asteroids clone with realistic
  physics, particle effects, 17 achievements, built with Claude Sonnet 4.5 + Claude Code
  in under 8 hours of conversational work. The author explicitly notes the *core
  mechanics* (inertia, fragmentation, collisions) landed quickly; iteration was on polish.
  <https://www.rogue1.it/en/ast3roidx-recreating-asteroids-claude-sonnet/>
- "30 Days of Vibe Coding" series includes an Asteroids clone (announcement page, 2026).
  <https://n9o.xyz/posts/202604-vibe30/announcement/>
- Referenced in the smartchunks "single-screen arcade" tier (fixed-view variant).

**Complexity.** Notably harder than Pong/Breakout — vector math (rotation, thrust along a
heading), screen wrap, asteroid fragmentation, multi-entity collision. This is where
"compression loses something" might show up.

**Spec elements a one-shot prompt must include.**
- Canvas size, ship triangle dimensions and color, asteroid sizes (large/medium/small)
- Ship physics: rotation speed, thrust acceleration, max velocity (or no cap), drag (or
  none — original has none), screen wrap on all four edges
- Bullet physics: muzzle velocity, lifetime (frames or ms), max simultaneous bullets
- Asteroid spawn count and velocities, fragmentation rule (split into 2 smaller pieces on
  hit, smallest size destroyed outright)
- Scoring per asteroid size, lose condition (ship-asteroid collision), level-clear
  condition, respawn flow (invulnerability window?)
- Controls (rotate left/right, thrust, fire) — typically arrow keys + space

**Known failure modes.**
- **Screen wrap missing or one-sided** — ship or bullets disappear off the right edge but
  don't reappear on the left. Most common Asteroids regression.
- **Thrust angle off by 90°** — ship moves sideways or backwards because the model used
  `0 rad = right` convention but drew the ship pointing up (or vice versa). Documented in
  Stack Overflow Asteroids threads. <https://stackoverflow.com/questions/55250882>
- **Asteroids that don't fragment** — hit destroys the asteroid outright instead of
  splitting it.
- **No inertia** — ship stops when thrust key is released (Newtonian physics replaced with
  arrow-key character movement).
- Bullet collision detection missed due to high bullet speed (tunneling, same as Pong but
  worse because of more entities).

**Recommended tier.** **Tier 2–3 (Sonnet-reliable, Haiku-flaky).** Strongest candidate for
*differentiating* prose vs BOTSPEAK because the physics details are easy to silently drop
in compression.

---

## Candidate 4 — Minesweeper

**Mechanics.** Grid of hidden tiles, some containing mines. Click reveals a tile; if it's
a mine you lose; if it's adjacent to N mines it shows N; if N=0 it flood-fills adjacent
empties. Right-click flags. Win when all non-mine tiles are revealed.

**Evidence of one-shot success.** *This is the strongest direct multi-model evidence in
the candidate set.*
- Ars Technica AI Coding Agent Test (Dec 2025) ran the same single prompt across Claude
  Code (Opus 4.5), OpenAI Codex (GPT-5.2), Mistral Vibe, and Gemini CLI. Prompt asked for
  a full-featured Minesweeper with sound, standard gameplay, a "surprise" feature, and
  mobile touch support. **Codex scored 9/10, Claude Code 7/10, Mistral 4/10, Gemini CLI
  0/10** (Gemini produced only a non-functional framework).
  <https://arstechnica.com/ai/2025/12/the-ars-technica-ai-coding-agent-test-minesweeper-edition/>
- senko/vibesweeper-2025 — GitHub repo collecting Minesweeper outputs from Claude, GPT,
  Gemini, DeepSeek, and others from a single prompt: *"Create a complete, fully functional
  Minesweeper game clone in HTML/CSS/JS (all in one file). Make it look really nice."*
  <https://github.com/senko/vibesweeper-2025>
- Medium "Building Minesweeper from Scratch with Claude 3.5" documents incremental build.
  <https://medium.com/@xuezaigds/building-minesweeper-game-from-scratch-with-claude3-5-basic-features-8904eaaa0231>

**Complexity.** Pure grid logic — no physics, no real-time loop. Bulk of the difficulty
sits in the flood-fill reveal algorithm and mine placement on first-click (often the
first revealed cell must not be a mine).

**Spec elements a one-shot prompt must include.**
- Grid dimensions (e.g. 16×16) and mine count (e.g. 40)
- First-click safety rule (first revealed tile is guaranteed empty — usually with empty
  neighbors too)
- Reveal mechanic: show number; if zero, flood-fill all connected zeros and their numbered
  borders
- Flag mechanic (right-click or long-tap), flag counter
- Win condition (all non-mine tiles revealed), lose condition (mine clicked), end-of-game
  state revealing all mines
- Visual style for hidden vs revealed vs flagged vs mine tiles, color per number 1–8
- Optional: chording (click on numbered tile with correct flags reveals neighbors)

**Known failure modes.**
- **Chording missing** — Ars Technica found Claude Code's version lacked it; Codex
  included it. Often the single biggest UX gap.
- **First-click can be a mine** — produces a game that's lost before it starts.
- **Flood-fill bugs** — either doesn't propagate (reveal one cell at a time), or
  propagates through numbered cells incorrectly.
- **Right-click handling** — context menu fires on desktop, no flag UI on mobile.
- **Difficulty/mine count miscalibrated** — too many or too few mines on a small grid.
- Gemini CLI produced just a clickable grid with no game logic at all (Ars Technica).

**Recommended tier.** **Tier 2 (Sonnet-reliable).** Exceptionally useful because:
(a) there's recent published multi-model one-shot data;
(b) it's grid-only and tests logic compression, not physics compression — complementary
to Asteroids and the existing Snake/Tetris;
(c) failure modes are crisp and binary (chording either works or doesn't), making the
eval easy to grade.

---

## Candidate 5 — 2048

**Mechanics.** 4×4 grid, arrow keys slide all tiles in one direction, equal adjacent tiles
merge into double-value tile, one new 2-or-4 tile spawns each move, win at 2048, lose when
no moves are possible.

**Evidence of one-shot success.**
- Public Claude Artifact for an HTML 2048 game exists and is shareable as a single file.
  <https://claude.ai/public/artifacts/f8f8c6cc-f648-44ed-8c26-e30ccd558aca?fullscreen=true>
- The openclaw "opencode-games" skill catalog (referenced via multiple search results)
  classifies 2048 as **fully tested and verified buildable with Claude Code**, with an
  estimated 500–800 lines of code and ~1–1.5 min generation time. Notes confirmed working
  merge algorithm and undo functionality.
- Appears in dev.to and How-To guides on sharing Claude-generated single-file games.
  <https://dev.to/arcadelab/how-do-i-share-an-interactive-thing-i-made-with-claude-or-ai-5c5p>

**Complexity.** Pure grid puzzle, turn-based — no animation strictly required, but the
merge-and-shift algorithm has nontrivial edge cases. Lowest framerate-pressure of the
candidate set.

**Spec elements a one-shot prompt must include.**
- 4×4 grid, tile colors keyed to value (2, 4, 8, ... 2048), spawn rule (90% chance of 2,
  10% chance of 4 on a random empty cell)
- Slide-and-merge rule per direction: in the direction of motion, each tile slides to the
  furthest empty cell or merges with the next tile of equal value; **a tile merged this
  turn cannot merge again the same turn**
- Move legality: a swipe is a no-op only if no tile moves or merges (and in that case no
  new tile spawns)
- Score: sum of merged tile values added per merge
- Win condition (any tile reaches 2048 — usually game continues), lose condition (no legal
  moves remain)
- Arrow-key controls (and ideally swipe for mobile), restart button

**Known failure modes.**
- **Double-merge in one turn** — a row of `2 2 2 2` becomes `8` instead of `4 4` because
  the merge-once-per-turn rule is dropped.
- **New tile spawns on no-op moves** — pressing into a wall still spawns a tile,
  effectively penalizing the player for thinking.
- **Score not updated** or only updated on win.
- **No lose detection** — game silently freezes when board is full but no merges available.

**Recommended tier.** **Tier 1–2 (Haiku-borderline, Sonnet-reliable).** Mechanically simple
but the merge rule is exactly the kind of small detail a compression pass could lose.

---

## Honorable mentions (researched but not in top 4)

- **Space Invaders.** One-shot vibe-coded with Cursor + Claude Sonnet 4 (emlynoregan
  GitHub repo) and with Claude 3.5 (sjefvanleeuwen). Slightly broader scope than the
  top picks — enemy AI movement pattern, descending waves, destructible barriers — and
  arguably overlaps mechanically with Asteroids + Breakout. *Use as a swap for Asteroids
  if you want a less physics-heavy real-time arcade game.*
- **Conway's Game of Life.** Tested in the Artificial Analysis MicroEval ("Gosper Glider
  Gun" benchmark) across Claude 4 Sonnet and others with positive ratings, and has a
  documented single-file implementation pattern. *Use as a Tier 1 "pure logic, no input
  loop" canary if you want to test compression on rule-stated specs rather than
  game-feel specs.* Less suitable than the top 4 because there's no win/lose condition,
  which makes "did the model implement the game" harder to grade automatically.
- **Sokoban / Pac-Man / Frogger.** Each is feasible but has either more art (Pac-Man
  ghosts and maze rendering), more level data (Sokoban puzzles), or trickier collision
  (Frogger lanes). Recommend deferring until the top 4 produce signal on whether
  BOTSPEAK round-trips at the simpler tier.

---

## Summary table — recommended ranking for the eval suite

| Rank | Game        | Tier   | Mechanic class            | Why it earns the slot                                                                                                                  |
|-----:|-------------|--------|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| 1    | **Pong**        | Tier 1 | Physics (collision, real-time) | Lowest-complexity one-shot game on the list. Baseline canary: if BOTSPEAK breaks Pong, compression is too aggressive. Strong prior-art that Claude produces it on first attempt. |
| 2    | **Breakout**    | Tier 1–2 | Physics + grid (real-time)   | Adds the brick grid data structure to Pong's physics — tests whether compression preserves *combined* specs. Well-represented in training data, so reliable.                  |
| 3    | **Minesweeper** | Tier 2 | Grid logic (turn-based)      | **Strongest external one-shot evidence** (Ars Technica multi-model head-to-head, Dec 2025). Pure logic + flood-fill — complements Pong/Breakout's physics. Crisp failure modes (chording present? first-click safe?). |
| 4    | **Asteroids**   | Tier 2–3 | Physics + rotation/vector (real-time) | The discriminator. Inertia, screen-wrap, and fragmentation are exactly the kind of detail compression could silently drop. AST3ROIDX confirms Sonnet 4.5 handles it; Haiku likely won't. |

**Bench slot (5th if budget allows):** **2048** — Tier 1–2, grid puzzle, turn-based.
Cheapest to spec and grade, and tests merge-rule precision rather than physics precision.

**Diversity check.**
- Physics-driven, real-time: Pong, Breakout, Asteroids
- Grid logic, turn-based: Minesweeper, 2048, (already-have: Snake, Tetris)
- Tier spread: 1 (Pong) → 1–2 (Breakout, 2048) → 2 (Minesweeper) → 2–3 (Asteroids)
- Combined with the existing **Flappy Bird** (Tier 1–2, physics), **Snake** (Tier 1, grid),
  and **Tetris** (Tier 2–3, grid + rotation), the suite would span 7 games across both
  mechanic classes and three difficulty tiers.

---

## Sources

- Smartchunks, "Build A Simple HTML5 Game With Claude Code" (Apr 2026). One-shot tier
  rankings, prompt template, Linuxbeast quote.
  <https://smartchunks.com/build-html5-game-claude-code-prompt-to-playable/>
- KDnuggets, "I Asked ChatGPT, Claude and DeepSeek to Build Tetris" (Jan 2026). Direct
  one-shot Tetris head-to-head with concrete failure modes per model.
  <https://www.kdnuggets.com/i-asked-chatgpt-claude-and-deepseek-to-build-tetris>
- Ars Technica, "We asked four AI coding agents to rebuild Minesweeper" (Dec 2025).
  Definitive multi-model one-shot Minesweeper comparison.
  <https://arstechnica.com/ai/2025/12/the-ars-technica-ai-coding-agent-test-minesweeper-edition/>
- pagefault.it / rogue1.it, "AST3ROIDX: Recreating Asteroids with Claude Sonnet 4.5"
  (2026). Conversational one-shot Asteroids with full physics.
  <https://www.rogue1.it/en/ast3roidx-recreating-asteroids-claude-sonnet/>
- N9O, "30 Days of Vibe Coding" series (2026). Single-prompt Snake (Day 2), Tetris
  (Day 4), Breakout (Day 5), plus Pong, Asteroids, Minesweeper in the series index.
  <https://n9o.xyz/posts/202604-vibe30/announcement/>
- senko/vibesweeper-2025. Multi-model one-shot Minesweeper outputs collected in one repo.
  <https://github.com/senko/vibesweeper-2025>
- Linuxbeast, "How I Built 3 Browser Games in One Day With Claude AI" (2025–2026).
  *"The first prototype always worked"* — three single-screen arcade games one-shot.
  <https://linuxbeast.com/blog/how-i-built-3-browser-games-in-one-day-with-claude-ai/>
- Stack Overflow, Asteroids canvas movement discussion. Documented screen-wrap and
  rotation-angle failure modes outside the LLM context.
  <https://stackoverflow.com/questions/55250882/object-movement-on-html-canvas-asteroids>
- gkamradt/SnakeBench + ARC Prize "Snakebench" writeup. Background on Snake-specific
  reasoning failure modes (less relevant for *generation*, more for *play* — included for
  completeness on Snake's known fragility).
  <https://github.com/gkamradt/SnakeBench> | <https://arcprize.org/blog/snakebench>
