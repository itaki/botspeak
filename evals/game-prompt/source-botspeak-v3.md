<!-- BOTSPEAK v0.2.0 · compressed by claude-sonnet-4-6 · 2026-05-07 -->
# Flappy Bird — One-Shot HTML Spec

@defs
  BG  = background
  FPS = frames per second
  LS  = localStorage
  MS  = milliseconds
  PX  = pixels
  HZ  = Hertz
@end

Single HTML file · no deps · file:// protocol · no server needed.

## Canvas & Layout

- 480w × 640h PX · centered · dark BG (#1a1a2e) · box-shadow
- BG gradient: #0f3460 (top) -> #16213e (bottom)
- Clouds: white ellipses @ 1/4 pipe speed · semi-transparent
- Ground: 40 PX green (#2d5a27) + yellow stripe (#8fbc45) @ pipe speed
- Resize: maintain 480×640 aspect · CSS `scale()` · no canvas res change

## Bird

- Circle r=14 PX · yellow · dark eye (r=4) upper-right · orange triangular beak (right)
- Wing: darker ellipse · animates up/down @ 8 FPS per flap cycle
- Rotation: -30° (up) to 90° (down) · nose angle = velocity
- Pos: 20% from left · fixed horizontally

## Pipes

- Pairs: top->down + bottom->up · 150 PX gap
- Gap position: random 20%-75% height
- 60 PX wide · dark green body (#2d6a4f) + light stripe (#40916c · 8 PX left edge)
- Cap: 70 PX wide × 20 PX tall · same color scheme
- Movement: left @ 3 PX/frame

## Score & UI

- Current: centered @ top (40 PX down) · 48px bold sans-serif white · semi-transparent dark BG
- Best: top-right @ 20px
- Collision: 4 PX forgiveness margin

## Physics

- Gravity: 0.5 PX/frame² downward
- Flap: velocity := -9 PX/frame (upward)
- Terminal velocity: cap ↓ @ 12 PX/frame
- pipe_spawn_interval = 90 FR · pipe_spawn_first = 120 FR (after playing starts)
- !! only flap when state="playing"

## States

[ALWAYS] state: menu || playing || dying || gameover

**menu:**
  - BG + ground + clouds scrolling
  - bird: sine bobbing (amp=8 PX · period=60 FR) · center canvas
  - "FLAPPY BIRD" @ 40% height · white bold
  - "Press SPACE or tap" · pulsing opacity (0.4-1.0 · period=60 FR)

**playing:**
  - score++ when bird.x passes right edge of pipe
  - play "point" sound

**dying:**
  - trigger: collision detected
  - bird: stop horiz movement · gravity continues
  - play "hit" sound
  - particles: 20× · r 3-6 PX · warm colors · random direction/speed 2-6 PX/frame · gravity · fade_duration=40 FR
  - transition -> gameover after particles done && bird grounded/off-screen

**gameover:**
  - semi-transparent dark overlay
  - panel: final score · best score · "Press SPACE or tap to restart"
  - new-best badge (gold) if record beaten
  - restart -> playing (not menu) · reset bird · clear pipes · score=0

## Audio (Web Audio API · synthesized · no files)

- flap:  520 HZ sine · 80 MS · fade -> silence · on flap
- point: 660 HZ (50 MS) + 880 HZ (50 MS) chirp · on pipe pass
- hit:   white noise burst · 150 MS · fade -> silence · on collision
- die:   400 HZ -> 200 HZ sweep · 300 MS · +100 MS after hit

Context lazy-init on first user interaction (autoplay policy).

## Input

- spacebar || tap canvas || left-click canvas -> flap
- !! all simultaneous · prevent default on canvas touch only (not page)

## Implementation

- `'use strict'`
- Sections: constants · state · audio · drawing · physics · input · game loop
- Loop: `requestAnimationFrame` + frame counter (int) · not wall-clock
- LS key: `'flappyBirdBest'` · read on load · update on new record
- File: `.html` only
  !! no `<script src>` · no `<link rel>` · no `fetch` · no `import`
  !! file:// protocol compatible
- Deliverable: `flappy-bird.html` · Chrome/Firefox/Safari · no mods needed
- Comment block: approx line count + major sections list

## Deliverable

Ready-to-run single HTML · works inline · no setup.
