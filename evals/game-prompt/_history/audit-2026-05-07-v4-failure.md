# BOTSPEAK eval — v4 failure forensic audit

- **Date:** 2026-05-07
- **Auditor:** Claude Opus 4.7
- **Subject:** `evals/game-prompt/source-botspeak-v4.md` failed to one-shot Flappy Bird via claude-haiku-4. Compare against `source.md` (prose · works) and `archive-v1-20260505/source-botspeak-iter1.md` (compressed · works).
- **Word counts:** prose 1415 · v4 818 (42% reduction) · iter1 614 (57% reduction).

> Scope note: the v4 audit ran on a single Haiku one-shot. We have N=1 success on prose, N=1 success on iter1, N=3 failures on v2/v3/v4 BOTSPEAK. That sample is enough to identify a coherent failure *class* (same bug shape across v2/v3/v4) but not enough to quantify pass-rate distributions.

---

## TL;DR

The v4 build's bug is a **simulation–rendering schism on pipe state**: pipes are stored with a fixed `x = CV.w` and *never mutated*; only the *render* shifts them by `fr * PHYS.pipeSpd`. Consequence: pipe 1 appears mid-screen at frame 120, slides off in ~40 frames, pipe 2 spawns at frame 210 already off-screen-left (because the render-offset has grown larger than the canvas), and is never visible. Collision and scoring both read the static `p.x = 480`, so the bird never collides and the score never increments → infinite flight.

This is the **same failure class** the user attributed to v3. v4's new strict-`=` rule did not address it because the rule targets scalar timing variables, not entity-motion architecture.

**Verdict:** **C primary** (compression-class hazard — BOTSPEAK can express entity motion but its current idioms collapse the entity-vs-ambient distinction the prose preserves), with **A secondary** (the skill failed to apply its own strict-`=` rule on at least 5 lines), and **D as a contributor** (Haiku is at the edge — iter1's success was probably partially luck).

---

## Section 1 — Compression fidelity (block-by-block)

Walking `source.md` against `source-botspeak-v4.md`. Categorization symbols: ✅ preserved · ⚠️ distorted · ❌ lost · ❓ ambiguous · ➕ new ambiguity introduced.

### 1.1 Preamble (delivery contract)

Prose `source.md:3`:
> "Build a complete, playable Flappy Bird clone in a single self-contained HTML file with no external dependencies of any kind. The game must run by opening the file directly in any modern browser without a local server. Do not use any external images, fonts, audio files, or JavaScript libraries. Everything — graphics, physics, sounds, UI — must be generated programmatically in the file itself."

v4 `source-botspeak-v4.md:4`:
> `[ALWAYS] deliver = single self-contained .html · no external deps · runs via file:// in any modern browser · no server · no external images/fonts/audio/libs · all assets generated programmatically`

✅ semantically preserved · ➕ **strict-`=` rule violated**: RHS of `deliver =` is a long descriptive list, not a value. By the skill's own §step 4 rule (SKILL.md:84-98), this should be either tag-level `[ALWAYS]` invariants or a renamed-key-with-value form. See Section 2.

### 1.2 Visual / canvas chrome

Prose `source.md:11`:
> "The canvas should be 480 pixels wide and 640 pixels tall, centered horizontally on the page. The page background behind the canvas should be a dark color (#1a1a2e). The canvas should have a subtle box-shadow to make it feel like a screen."

v4 `source-botspeak-v4.md:20`:
> `**CV:** 480×640 · centered horizontally · page bg #1a1a2e · subtle box-shadow`

✅ preserved.

### 1.3 Sky · clouds · ground (the ambient-motion section — critical for the bug)

Prose `source.md:13`:
> "**Sky and background:** Draw a gradient sky that transitions from a deep blue (#0f3460) at the top to a lighter blue (#16213e) at the bottom. Add a layer of distant, slowly-scrolling clouds: small white ellipses with slight transparency, moving at one-quarter the speed of the pipes. Add a scrolling ground strip at the very bottom of the canvas — a green rectangle (40 pixels tall, color #2d5a27) with a thin yellow stripe at the top edge (#8fbc45). The ground scrolls at the same speed as the pipes."

v4 `source-botspeak-v4.md:22`:
> `**Sky/bg:** gradient #0f3460 (top) -> #16213e (bottom) · clouds: small white ellipses, semi-transparent, scroll at PP_speed × 0.25 · ground: green rect (40px tall, #2d5a27) + thin yellow top stripe (#8fbc45), scrolls at PP_speed`

✅ visual values preserved.
➕ **New ambiguity introduced (the bug seed):** prose has a *paragraph break* between "background" and "ground", and uses "moving at one-quarter the speed of the pipes" / "scrolls at the same speed". The v4 line bundles three ambient-motion concepts on one bullet line using the verb "scroll". The next bullet (pipes, line 26) reuses the same compressed-bullet form for what is a fundamentally different motion architecture (entity motion). The compressed form makes the two visually equivalent. **This is the seed of the schism.**

### 1.4 Bird

Prose `source.md:15` and v4 `source-botspeak-v4.md:24` — ✅ preserved (radius, eye, beak, wing animation cadence, rotation clamp, fixed horizontal pos all carried over). Minor loss: prose says wing animates "up and down at 8 frames per flap cycle"; v4 says "8 FR/flap-cycle" — same.

### 1.5 Pipes — the bug site

Prose `source.md:17`:
> "**Pipes:** Draw pipes as pairs — one from the top of the canvas downward, one from the bottom of the canvas upward — with a gap of 150 pixels between them. The gap position is randomized vertically between 20% and 75% of the canvas height. Pipes are 60 pixels wide. Draw the pipe body as a dark green rectangle (#2d6a4f) with a lighter green highlight stripe (#40916c) along the left edge (8 pixels wide). Draw a pipe cap — a slightly wider rectangle (70 pixels wide, 20 pixels tall) at the open end of each pipe, same color scheme with a highlight. **Pipes enter from the right edge and move left at a constant speed.**"

v4 `source-botspeak-v4.md:26`:
> `**PP:** top pipe down + bottom pipe up · gap = 150px · gap_y randomized 20–75% CV_height · width = 60px · body: #2d6a4f rect + #40916c left-edge highlight (8px wide) · cap: 70px wide × 20px tall, same colors + highlight, at open end · **spawn right edge, move left**`

✅ visuals preserved.
⚠️ **Motion phrase weakened.** Prose: "Pipes **enter** from the right edge and **move left** at a constant speed." — `enter` + `move` is a verb pair that strongly implies a per-entity trajectory (something that has its own state, enters, then moves). v4: "spawn right edge, move left" — `spawn` is correct (object instantiation) but the bullet form sits in a list of **static visual descriptors** (gap, width, body color, cap dims). The reader is being told "here is what a pipe looks like and where it shows up", not "here is how a pipe behaves over time".
❌ **Lost: motion mechanics location.** Prose anchors the speed in physics (`source.md:32`: "Pipes move left at 3 pixels per frame.") *and* re-asserts the motion verb in visual ("Pipes enter from the right edge and move left at a constant speed."). v4 has no per-frame imperative description anywhere — `PP_speed = 3 px/FR left` is a *number*, not an *update rule*. The connective tissue ("each frame, decrement pipe.x by PP_speed") is gone.
➕ **New ambiguity:** "spawn right edge, move left" uses the same syntactic shape as "scrolls at PP_speed" two bullets above. The reader who reaches for the same implementation twice will produce the bug.

### 1.6 Score display

Prose `source.md:19` and v4 `source-botspeak-v4.md:28` — ✅ preserved.

### 1.7 Particles

Prose `source.md:21`:
> "When the bird dies (collides with a pipe or the ground), emit 20 particles from the bird's position. Each particle should be a small circle (radius 3-6px, random), a random warm color (yellows, oranges, reds), with an initial velocity in a random direction at a random speed (2-6px per frame), and gravity applied to each particle at the same rate as the bird. Particles fade out over 40 frames and then disappear. Do not restart the game until all particles have finished their animation."

v4 `source-botspeak-v4.md:30`:
> `**Particles on death:** emit 20 from BRD pos · r=3–6px random · color = random warm (yellows/oranges/reds) · velocity = random direction, speed 2–6px/FR · gravity = same rate as BRD · fade over 40 FR then disappear · !! game does not restart until all particles done`

✅ all values preserved including the "!!" gate on restart.

### 1.8 Physics

Prose `source.md:27-34` ↔ v4 `source-botspeak-v4.md:36-43`:

| Prose | v4 | Status |
|---|---|---|
| `requestAnimationFrame` + cap delta-time | `[ALWAYS] physics loop = requestAnimationFrame fixed timestep · cap delta-time (tab blur protection)` | ✅ · ➕ strict-`=` violation (RHS is description) |
| `Gravity: 0.5 px/FR² downward while playing` | `gravity: +0.5 px/FR² downward while state = playing` | ✅ |
| `Flap velocity: -9 px/FR (upward). Do not allow flapping when state ≠ playing` | `flap_velocity = -9 px/FR (upward) · !! no flap when state != playing` | ✅ |
| `Terminal velocity: 12 px/FR cap downward` | `terminal_velocity = 12 px/FR downward` | ✅ |
| `Pipe speed: 3 px/FR left. Do not change with score.` | `PP_speed = 3 px/FR left · !! speed does not increase with SC` | ✅ |
| `Spawn every 90 FR. First pipe at FR 120 after entering playing.` | `PP_spawn_interval = 90 FR · PP_first = 120 FR after state -> playing` | ✅ — strict-`=` rule cleanly applied (this is what the rule was *designed* for) |
| `Circle-rect collision for pipe bodies/caps and ground; 4px forgiveness` | `collision = circle-rect for PP bodies, PP caps, ground · forgiveness_margin = 4px (shrink collision box 4px each side)` | ✅ · ➕ strict-`=` violation on first half |

❌ **Lost (tacit):** prose's *imperative-loop* feel ("on every frame while playing", "Do not allow flapping when ...") is replaced by declarative state descriptions. None of the bullets says "each frame, update pipe.x by -PP_speed". This is the same gap as in 1.5.

### 1.9 Game states

Prose `source.md:42-48` ↔ v4 `source-botspeak-v4.md:51-57`:
- ✅ All four states (menu / playing / dying / gameover) preserved.
- ✅ Score increment trigger, particle gate on dying→gameover transition, NEW BEST badge logic, no-return-to-menu rule all preserved.
- ⚠️ Prose `dying` says "Triggered the moment a collision is detected. The bird stops moving horizontally." v4 `dying:` says "BRD stops horizontal movement". This is fine because the bird's horizontal pos is fixed at 20% (the stop is a no-op anyway), but it carries the same per-frame-mutation gap — no explicit `BRD.vx = 0`.
- ❌ **Lost (subtle):** prose `gameover:` says "Pressing SPACE or tapping restarts immediately into 'playing' state, **resetting the bird position, clearing all pipes, and resetting the score to zero**." v4 says `SPACE or tap -> playing (reset BRD pos, clear all PP, SC=0)`. ✅ actually preserved. Skip.

### 1.10 Audio · Controls · Tech

Audio `source.md:54-61` ↔ v4 `source-botspeak-v4.md:63-69`: ✅ all 4 sounds with correct frequencies/durations/triggers.
Controls `source.md:67-71` ↔ v4 `source-botspeak-v4.md:75-80`: ✅ preserved.
Tech `source.md:77-84` ↔ v4 `source-botspeak-v4.md:86-92`: ✅ preserved.

### 1.11 Compression-fidelity scorecard

| Class | Count | Examples |
|---|---|---|
| ✅ Preserved correctly | ~85% of constraints | values, colors, frequencies, state names, polarity gates |
| ⚠️ Distorted | 1 high-impact | pipe motion verb weakened from "enter and move" to bullet-form "spawn right edge, move left" |
| ❌ Lost | 1 critical | per-frame imperative-update mental model for entity motion (no spec line says "each frame, decrement pipe.x") |
| ❓ Ambiguous | 1 medium | parallax-vs-entity motion architecture (see Section 1.3 + 1.5) |
| ➕ New ambiguity | 6 lines | strict-`=` violations using descriptive RHS (Section 2) |

---

## Section 2 — Strict `=` rule audit

The skill mandates (`SKILL.md:86-98`): "**after `=`, the right-hand side MUST be a value, not a description.**"

Every `=` line in `source-botspeak-v4.md`:

| Line | Quote | RHS type | Verdict |
|---|---|---|---|
| 4 | `[ALWAYS] deliver = single self-contained .html · no external deps · runs via file:// in any modern browser · no server · no external images/fonts/audio/libs · all assets generated programmatically` | descriptive phrase listing many constraints | ❌ **violates** — should be invariant bullets, not `=` |
| 7-11 | `CV = canvas (480×640, HTML5 2D)` etc. inside `@defs` | alias bindings | ✅ allowed by SPEC §2 |
| 18 | `[ALWAYS] render = CV 2D API only · !! no SVG · no DOM game objects · no CSS animations` | descriptive phrase | ❌ **violates** |
| 24 | `... horizontal pos = CV_width × 0.2` | typed value | ✅ |
| 26 | `gap = 150px` · `width = 60px` | typed values | ✅ |
| 30 | `r=3–6px random` · `color = random warm (yellows/oranges/reds)` · `velocity = random direction, speed 2–6px/FR` · `gravity = same rate as BRD` | mixed: range value · descriptive · descriptive · derived-equiv | ❌ **3 of 4 violate** ("random warm (yellows/oranges/reds)", "random direction, speed 2–6px/FR", "same rate as BRD" are all descriptions, not values) |
| 36 | `[ALWAYS] physics loop = requestAnimationFrame fixed timestep · cap delta-time (tab blur protection)` | descriptive phrase | ❌ **violates** |
| 39 | `flap_velocity = -9 px/FR (upward)` | typed value with descriptor | ✅ borderline (descriptor is parenthetical clarification) |
| 40 | `terminal_velocity = 12 px/FR downward` | typed value | ✅ |
| 41 | `PP_speed = 3 px/FR left · !! speed does not increase with SC` | typed value | ✅ |
| 42 | `PP_spawn_interval = 90 FR · PP_first = 120 FR after state -> playing` | typed values | ✅ — **this is the rule's success case** — what v3's `PP_spawn = every 90FR · first at FR120` looked like before the rule existed |
| 43 | `collision = circle-rect for PP bodies, PP caps, ground · forgiveness_margin = 4px ...` | descriptive ↦ algorithm name | ❌ **first half violates** ("circle-rect for PP bodies, PP caps, ground" is a description) |
| 51 | `amplitude=8px, period=60 FR` | typed values | ✅ |
| 64 | `[ALWAYS] AudioContext = lazy init on first user interaction (browser autoplay policy)` | descriptive phrase | ❌ **violates** |
| 90 | `frame_counter = integer incrementing each FR · !! not wall-clock time · frame_counter = primary timing source for spawn/animation` | declarative + restated | ⚠️ marginal — `integer` is a type, but "incrementing each FR" is a behavior description on RHS |
| 91 | `localStorage key = 'flappyBirdBest'` | literal value | ✅ |
| 92 | `CV resize: recalculate scale = fit CV in window (maintain 480×640 aspect)` | descriptive phrase | ❌ **violates** |

**Strict-`=` audit tally:** 5 hard violations (lines 4, 18, 36, 64, 92), 2 partial (30, 43, 90). The strict-`=` rule that the new skill *introduced specifically as the one-shot reliability fence* is itself violated on 5+ lines in the very output the skill produced.

**Conflated state variables:** the rule also says "every distinct timing concept — interval, first, duration, delay are SEPARATE variables" (`SKILL.md:82`). v4 mostly honors this (line 42 split cleanly), but **fails for entity motion**: `PP_speed` is one named variable carrying both the value (`3 px/FR`) and the implicit per-frame-update semantic. The skill has no rule that requires entity motion to be split into `state.x_init` + `state.x_update_per_FR` + `state.x_remove_when` variables — which is exactly the gap the bug exploits.

---

## Section 3 — Code-level forensic comparison

### 3.1 prose.html — pipe spawning, motion, collision (works)

`results/flappy-prose.html:350-364` — **separate spawn, separate motion, separate cleanup**:

```350:364:evals/game-prompt/results/flappy-prose.html
function updatePipes() {
    if (gameState === 'playing' && frameCount >= FIRST_PIPE_FRAME && (frameCount - FIRST_PIPE_FRAME) % PIPE_SPAWN_INTERVAL === 0) {
        const minGap = CANVAS_HEIGHT * 0.2;
        const maxGap = CANVAS_HEIGHT * 0.75;
        const gapStart = Math.random() * (maxGap - minGap) + minGap;
        pipes.push({
            x: CANVAS_WIDTH,
            topY: gapStart
        });
    }
    pipes.forEach(pipe => {
        pipe.x -= PIPE_SPEED;
    });
    pipes = pipes.filter(pipe => pipe.x + PIPE_WIDTH > 0);
}
```

Line 361: `pipe.x -= PIPE_SPEED` — **per-entity, per-frame mutation**. This is the architecture the prose implies and Haiku correctly produced from prose.

Background motion in the same file is *separately* implemented as parallax offset (`drawClouds`, `drawGround` use `frameCount * speed % width`) — `results/flappy-prose.html:188-218`. Two motion architectures, cleanly separated.

Collision uses live `pipe.x` (`results/flappy-prose.html:382-399`) so it tracks the moving pipes correctly.

### 3.2 botspeak.html — the bug (broken)

`results/flappy-botspeak.html:261-273` — spawn and cleanup, **no motion update**:

```261:273:evals/game-prompt/results/flappy-botspeak.html
function spawnPipes() {
    if (state === ST.PLAY && fr === nextPipeF) {
        const gapMin = CV.h * 0.2;
        const gapMax = CV.h * 0.75;
        const gy = gapMin + Math.random() * (gapMax - gapMin);
        pipes.push({ x: CV.w, y: gy });
        nextPipeF += PIPE.spawnInt;
    }
}

function cleanPipes() {
    pipes = pipes.filter(p => p.x + PIPE.w > 0);
}
```

Pipes are pushed with `x: CV.w` (line 266). `cleanPipes()` filters by `p.x + PIPE.w > 0`. **Nowhere in the file does `p.x` get decremented.** Search confirmed: no `p.x -=`, `pipe.x -=`, or equivalent expression mutates pipe state.

The motion lives only in the *renderer*:

```197:206:evals/game-prompt/results/flappy-botspeak.html
function drawPipes(pa, off) {
    pa.forEach(p => {
        const px = p.x - off * PHYS.pipeSpd;
        drawPipeBody(px, 0, PIPE.w, p.y);
        drawPipeCap(px, p.y - PIPE.capH);
        const bpy = p.y + PIPE.gap;
        drawPipeBody(px, bpy, PIPE.w, CV.h - bpy);
        drawPipeCap(px, bpy);
    });
}
```

`drawPipes(pipes, fr)` is called with the global frame counter. Each pipe renders at `px = p.x - fr * PHYS.pipeSpd`. **This is parallax-style scrolling, identical in shape to how `drawClouds(off)` and `drawGnd(off)` work** (`results/flappy-botspeak.html:141-160`). Haiku built one motion abstraction and used it for everything.

### 3.3 Trace: why "pipes appear late then never again"

With `firstSpawn = 120`, `spawnInt = 90`, `pipeSpd = 3`:

| Frame | Action | First pipe `p.x` (stored) | First pipe rendered `px = p.x - fr*3` | Visible? |
|---|---|---|---|---|
| 0 | menu | — | — | — |
| 120 | spawn pipe 1 with `p.x = 480` | 480 | 480 - 360 = **120** | yes (mid-canvas, jarring "pop" entry) |
| 160 | — | 480 | 480 - 480 = **0** | leaves left edge |
| 161+ | — | 480 | negative | gone |
| 210 | spawn pipe 2 with `p.x = 480` | 480 | 480 - 630 = **-150** | **already off-screen left, never visible** |
| 300+ | spawn pipe 3 with `p.x = 480` | 480 | 480 - 900 = **-420** | never visible |

`cleanPipes` never removes anything (since `p.x + PIPE.w = 540 > 0` is always true), so the pipes array grows unboundedly with invisible-rendered pipes.

Collision (`results/flappy-botspeak.html:275-290`) reads `p.x` directly:

```280:288:evals/game-prompt/results/flappy-botspeak.html
for (let p of pipes) {
    const px = p.x;
    const prx = px + PIPE.w;
    if (bird.x + BD.r >= px + MISC.forgive && bird.x - BD.r <= prx - MISC.forgive) {
        const tpby = p.y - MISC.forgive;
        const bpty = p.y + PIPE.gap + MISC.forgive;
        if (bird.y - BD.r < tpby || bird.y + BD.r > bpty) return true;
    }
}
```

`px = 480`, `prx = 540`. Bird `x = 96`. The check `bird.x + 14 >= 484` is **never true**. **Collision is impossible against any pipe**, ever. The only collision that fires is the ground check (line 277), which works because it doesn't depend on the broken motion. This is why the bird flies forever in clear air, eventually only dying if it touches the ground.

Scoring (`results/flappy-botspeak.html:292-300`) reads the same static `p.x`:

```292:300:evals/game-prompt/results/flappy-botspeak.html
function checkSc() {
    pipes.forEach(p => {
        if (!p.scored && bird.x > p.x + PIPE.w) {
            sc++;
            p.scored = true;
            sndPoint();
        }
    });
}
```

`bird.x = 96` is never `> 540`. **Score never increments**, ever.

### 3.4 Is the bug inherent to v4's spec, or a Haiku mistake possible from any spec?

**Both, but spec content lifts the probability.** The bug is a real Haiku failure mode (entity-motion vs ambient-motion conflation) that *could* happen from any compact spec. But v4 specifically:

1. Lists three motion behaviors using *the same compressed-bullet syntactic shape*: clouds "scroll at PP_speed × 0.25", ground "scrolls at PP_speed", pipes "spawn right edge, move left" (lines 22, 26).
2. Provides no per-frame imperative cue for pipes anywhere — neither in the visual section ("move left" without "each frame") nor in the physics section (`PP_speed = 3 px/FR left` is a *number*, not a *rule*).
3. Bullet-lists pipe state as static configuration (gap, width, body color, cap dims, motion) without distinguishing the static visual properties from the dynamic state variable.

The prose, by contrast, uses verb forms ("Pipes **enter** from the right edge and **move left**", "Pipes move left at 3 pixels per frame") that activate Haiku's "this is an entity that moves" implementation pattern. Prose redundancy *and* the verb-heavy phrasing are doing the work that v4 lost.

---

## Section 4 — vs known-good iter1

`source-botspeak-iter1.md` produced a working game with the same Haiku model.

### 4.1 Pipe motion — what iter1 said

`archive-v1-20260505/source-botspeak-iter1.md:33-37`:
```
PP (pairs: top↓ + bottom↑):
  gap = 150px · gap_y randomized 20%-75% CV_H
  body: 60px wide #2d6a4f · highlight stripe #40916c 8px left edge
  cap: 70px wide × 20px tall · same colors · at open end of each PP
  enter from right · move left constant speed
```

vs v4 `source-botspeak-v4.md:26`:
```
**PP:** top pipe down + bottom pipe up · gap = 150px · gap_y randomized 20–75% CV_height · width = 60px · body: #2d6a4f rect + #40916c left-edge highlight (8px wide) · cap: 70px wide × 20px tall, same colors + highlight, at open end · spawn right edge, move left
```

**Differences:**
- **iter1 uses indented child-bullets**, putting "enter from right · move left constant speed" on its own line with structural emphasis.
- **iter1 uses "enter"** (entity verb) instead of v4's "spawn" (technical verb). Both are correct semantically, but `enter from right · move left` reads as a behavioral description on its own line; v4's flat one-liner buries `spawn right edge, move left` at the end of a comma-list of static visual properties.
- iter1 keeps the parent header `PP (pairs: top↓ + bottom↑)` which establishes a grouped object identity *before* listing properties; v4 collapses into a single line.

### 4.2 The iter1 build

`archive-v1-20260505/flappy-botspeak.html:380-390`:
```
pipeTimer++;
if (pipeTimer >= PP_FIRST && (pipeTimer - PP_FIRST) % PP_SPAWN_INT === 0) spawnPipe();
for (const p of pipes) {
    p.x -= PP_SPEED;
    if (!p.scored && bird.x > p.x + PP_W) {
        ...
```

Line 383: `p.x -= PP_SPEED`. **Entity motion done correctly.** Same Haiku model, similar-but-not-identical spec phrasing, correct architecture.

### 4.3 Why iter1's phrasing might have helped

The smallest-but-most-plausible delta: iter1 puts "enter from right · move left constant speed" on its **own indented line** at the bottom of the PP block. v4 packs it at the end of a long comma-list of static visual descriptors. Visually grouping "enter / move" with "gap, width, body, cap" weakens the entity-trajectory cue. The line **looks like** a property of how a pipe is drawn, not an action a pipe takes over time.

That's a subtle compression-style choice, not a notation gap. But it's exactly the kind of subtlety that determines whether Haiku reaches for `p.x -= speed` or `px = p.x - fr*speed`.

**Caveat:** iter1 worked once with this Haiku. We can't rule out luck. But the phrasing change is real and plausible as the difference-maker.

---

## Section 5 — vs failed v3

v3 had two suspected issues per the user: (a) `PP_spawn = every 90FR · first at FR120` (ambiguous timing assignment), and (b) parallax/entity schism.

### 5.1 What v3 said about pipe timing

`source-botspeak-v3.md:42`:
```
- pipe_spawn_interval = 90 FR · pipe_spawn_first = 120 FR (after playing starts)
```

Interesting: **v3 already had clean separated timing variables** — `pipe_spawn_interval` and `pipe_spawn_first` are exactly what the new strict-`=` rule prescribes. v3 was *not* the broken `PP_spawn = every 90FR · first at FR120` form. (That was attributed to v2.)

### 5.2 What v3 said about pipe motion

`source-botspeak-v3.md:35`:
```
- Movement: left @ 3 PX/frame
```

v3 has **a single bullet** that says "Movement: left @ 3 PX/frame" — which is even sparser than v4. Same architectural gap.

### 5.3 What v4 changed vs v3

| Aspect | v3 | v4 | Net effect |
|---|---|---|---|
| Pipe timing variables | `pipe_spawn_interval = 90 FR · pipe_spawn_first = 120 FR` | `PP_spawn_interval = 90 FR · PP_first = 120 FR` | Functionally same; v4 uses the alias. ✅ both clean. |
| Pipe motion | `Movement: left @ 3 PX/frame` | `PP_speed = 3 px/FR left ... · spawn right edge, move left` (split across visual and physics sections) | v4 splits across two sections; arguably *worse* because the visual section's "spawn right edge, move left" sits in a static-descriptor list. |
| Strict-`=` rule | not yet applied | applied to *some* lines, ignored on 5+ others | Partial uptake. |

**Did the new strict-`=` rule clean up the spawn assignment, or only appear to?** It cleaned up nothing on this specific point, because **v3 already had clean spawn timing**. The strict-`=` rule was solving last-iteration's problem (v2's `PP_spawn = every 90FR · first at FR120`), not v3's or v4's actual bug. **The bug shifted; the rule did not follow.**

---

## Section 6 — Verdict

### Primary: C — Compression-class hazard

BOTSPEAK *can* express entity motion correctly (iter1 demonstrates) but its current idioms make the entity-vs-ambient distinction syntactically invisible. Three independent compressions of this prose (v2, v3, v4) all produced the same class of motion-architecture bug. The base rate of failure in this class, across compressions of this prose, is **3/4** in our sample. The bug is not random Haiku noise — it is a coherent, reproducible failure mode tied to how compressed bullet syntax flattens motion architectures.

**Evidence:**
- Section 1.3 + 1.5: the v4 spec uses syntactically identical bullet shapes for ambient parallax ("scrolls at PP_speed") and pipe entity motion ("spawn right edge, move left"), where the prose uses paragraph separation and verb pairs to distinguish them.
- Section 3.2: Haiku built one motion abstraction (`px = p.x - fr * speed`) and used it for clouds, ground, *and* pipes. The compressed spec did not steer it otherwise.
- Section 5: the bug class persists across three compression attempts; only the prose and the (slightly differently phrased) iter1 escaped it.

### Secondary: A — Skill bug

The v4 skill failed to apply its own strict-`=` rule on at least 5 lines of its own output (Section 2 audit). More critically, the skill has **no rule whatsoever** for entity-motion declaration. It correctly added the strict-`=` rule for v2's timing-assignment failure class, but did not generalize from "scalar-timing ambiguity" to "stateful-update ambiguity". The new failure exposed by v3/v4 is a different sub-class of the same underlying problem (descriptive RHS ↔ behavior conflation) that the rule did not extend to cover.

The skill's `[ALWAYS] one-shot reliability > brevity` line (`SKILL.md:10`) is precisely the principle that should have produced an "entity motion must be expressed as an explicit per-frame update rule" guideline. It did not.

### Tertiary: D — Haiku ceiling

Haiku is at the edge of its capability here. The prose worked because of verbose redundancy and verb-heavy phrasing that activated the right implementation pattern. iter1 worked partly because its phrasing landed on the right side of Haiku's interpretation, partly because of luck. A larger model (Sonnet, Opus) would probably succeed from any of v2/v3/v4. We have **not tested** that — we'd need to run Sonnet on v4 to confirm. But: *the fact that this verdict requires that experiment to disambiguate from C is itself meaningful.*

### Why not B (notation gap)

BOTSPEAK *could* have expressed the entity motion correctly within its current notation. e.g.:

```
PP (entity · per-FR state):
  PP_x_init = CV.w           // spawn position
  PP_x_per_FR = -PP_speed    // update rule
  PP_remove_when = PP_x + PP_width < 0
```

Nothing about that uses notation BOTSPEAK doesn't already have. So the notation is sufficient; the *guidance for using it* is not. That puts the locus of the fix in the skill (A) and in the broader compression discipline (C), not in the notation (B).

### Why not E

There's no surprising fifth cause. The picture is the well-known "compression strips redundancy that helped a small model do the right thing", combined with "the skill didn't add the rule that would have prevented this specific class".

### Causal weight ranking

1. **C** (compression-class hazard) — the bug class is reproducible across compressions; the prose's redundancy is doing real work.
2. **A** (skill bug) — actionable: harden the skill to require explicit per-frame update rules for stateful entities, and to enforce its own strict-`=` rule on every line.
3. **D** (Haiku ceiling) — contributes; bigger models likely escape; not directly fixable without changing the eval target.

---

## Section 7 — Recommendations

### Priority 1 — Add an entity-state declaration rule to the skill

**Action:** In `skills/botspeak/SKILL.md`, extend the strict-`=` rule with a sibling rule:

> **Entity-state rule.** Any object whose state mutates per frame (or per tick) must declare its update rule explicitly. A bullet-list of static visual properties is insufficient. Required form:
> ```
> Entity:
>   init: <values at spawn>
>   per-FR: <update expression(s)>
>   remove-when: <termination condition>
> ```
> Background scrolling that does *not* maintain per-instance state (clouds, ground) may use the offset form (`offset = fr * speed % width`). The two motion architectures must be syntactically distinguishable in the spec.

**Expected outcome:** Compressors writing future game/sim specs split entity motion from ambient motion, eliminating the v2/v3/v4 failure class. Haiku and similar small models read the per-FR update rule and produce `entity.x -= speed` style code reliably.
**Risk:** Adds ~6 lines to the skill. May feel verbose for non-game docs. Mitigation: scope the rule with `[ON-TRIGGER] doc describes time-evolving state -> apply entity-state rule`.

### Priority 2 — Enforce the existing strict-`=` rule in step 6 verification

**Action:** Tighten `SKILL.md` step 6 ("verify · pass C"). The v4 output had 5+ uncaught violations. Add an automated mental-check pass:

> For every line containing `=`:
> 1. Is it inside `@defs`? → ok.
> 2. Otherwise: is the RHS a literal value, typed value, or aliased reference? → ok.
> 3. Otherwise → REWRITE. Either rename the variable (so the description moves into the name) or convert the line to an invariant bullet.

**Expected outcome:** The strict-`=` rule actually applies to compressor output. Cuts ambiguous declarative prose from future BT files.
**Risk:** Slightly slower compression. Negligible.

### Priority 3 — Run the eval at multiple model sizes before declaring a verdict

**Action:** Re-run v4 (and a freshly v5-compressed-with-the-Priority-1-rule) on Sonnet and on Opus, not just Haiku. This is the experiment that disambiguates **C** from **D**.

**Expected outcome:**
- If Sonnet/Opus succeed on v4: the verdict is **D-dominated** — Haiku is below the eval's competence floor. Recommendation: change the eval target model OR accept that compressed game specs target ≥ Sonnet.
- If Sonnet/Opus *also* fail: the verdict is **C-dominated** — the compression genuinely loses signal needed for one-shot synthesis at any model size. Recommendation: BOTSPEAK should not be marketed for one-shot game synthesis, only for AI-to-AI rule/skill docs (its actual use case per `CLAUDE.md`).

**Risk:** Costs a few inference calls. Worth it before publishing this audit's verdict externally.

### Priority 4 — Consider whether Flappy Bird is the right eval

**Action:** This eval may be the wrong stress test for BOTSPEAK's actual purpose. Per `CLAUDE.md`:
> "repo = BOTSPEAK spec + skills + rule + agent · goal: teach agents to write AI-facing docs in compressed notation"

The intended use case is rules/skills/CLAUDE.md/handoffs — *behavioral guidance for an agent that already knows how to code*. One-shot game synthesis is a different beast: it requires the spec to convey a complete imperative loop, and compression that strips imperative redundancy is genuinely lossy for that case.

**Expected outcome:** Either keep the eval as a stress-test boundary marker ("compressed prose works for behavioral docs but not for one-shot game synthesis below model X") and document that boundary, or replace the eval with one that exercises BOTSPEAK on its actual use case (e.g., compress a real CLAUDE.md, then compare a downstream agent task's accuracy on prose vs BT versions).
**Risk:** The audit would lose its dramatic "BOTSPEAK doesn't work" framing. But the correct framing is "BOTSPEAK is a compression notation for behavioral docs · one-shot synthesis is out-of-scope below Sonnet" — and that's a more defensible scoping than retreating from the notation entirely.

### Priority 5 — Stop iterating on this exact eval against Haiku without changing the conditions

**Action:** Three iterations (v2, v3, v4) of compression-rule changes have not eliminated the bug class on Haiku one-shotting from a compact spec. Continuing to iterate compresssion phrasing without (a) adding the entity-state rule and (b) running on a larger model is unlikely to converge. The user has been bracing for "BOTSPEAK doesn't work"; the honest answer is "BOTSPEAK works for what it's designed for, and Flappy-Bird-on-Haiku is outside that envelope unless we add the entity-state rule."

---

## Closing note

The user asked for ground truth. Ground truth: **the v4 failure is real, the bug is reproducible across three compression iterations, the new strict-`=` rule did not address the actual failure class, and the skill has been hardening the wrong corner of the notation.** But: **the notation itself is not broken**, the eval is not a representative test of BOTSPEAK's actual use case, and there is a concrete fix (Priority 1) that should resolve the entity-motion class on Haiku without dragging compression ratios down meaningfully.

The verdict is harsh on the *current skill* but not on *BOTSPEAK as a notation*. Treat it as such.
