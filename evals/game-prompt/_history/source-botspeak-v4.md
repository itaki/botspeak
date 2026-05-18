<!-- BOTSPEAK v0.2.0 · compressed by claude-sonnet-4-5 · 2026-05-07 -->
# One-Shot Flappy Bird — Full Specification Prompt

[ALWAYS] deliver = single self-contained .html · no external deps · runs via file:// in any modern browser · no server · no external images/fonts/audio/libs · all assets generated programmatically

@defs
  CV  = canvas (480×640, HTML5 2D)
  BRD = bird
  PP  = pipe pair
  FR  = frame
  SC  = score
@end

---

## Visual Design

[ALWAYS] render = CV 2D API only · !! no SVG · no DOM game objects · no CSS animations

**CV:** 480×640 · centered horizontally · page bg #1a1a2e · subtle box-shadow

**Sky/bg:** gradient #0f3460 (top) -> #16213e (bottom) · clouds: small white ellipses, semi-transparent, scroll at PP_speed × 0.25 · ground: green rect (40px tall, #2d5a27) + thin yellow top stripe (#8fbc45), scrolls at PP_speed

**BRD:** yellow circle (r=14px) · dark eye (r=4px, upper-right) · orange triangle beak pointing right · wing = darker-yellow ellipse left side, animates up/down at 8 FR/flap-cycle · rotation tracks velocity: nose-up after flap · nose-down falling · clamp [-30°, 90°] · horizontal pos = CV_width × 0.2

**PP:** top pipe down + bottom pipe up · gap = 150px · gap_y randomized 20–75% CV_height · width = 60px · body: #2d6a4f rect + #40916c left-edge highlight (8px wide) · cap: 70px wide × 20px tall, same colors + highlight, at open end · spawn right edge, move left

**SC display:** current SC = white bold 48px centered, 40px from top, dark semi-transparent bg rect · best SC = 20px top-right

**Particles on death:** emit 20 from BRD pos · r=3–6px random · color = random warm (yellows/oranges/reds) · velocity = random direction, speed 2–6px/FR · gravity = same rate as BRD · fade over 40 FR then disappear · !! game does not restart until all particles done

---

## Physics

[ALWAYS] physics loop = requestAnimationFrame fixed timestep · cap delta-time (tab blur protection)

- gravity: +0.5 px/FR² downward while state = playing
- flap_velocity = -9 px/FR (upward) · !! no flap when state != playing
- terminal_velocity = 12 px/FR downward
- PP_speed = 3 px/FR left · !! speed does not increase with SC
- PP_spawn_interval = 90 FR · PP_first = 120 FR after state -> playing
- collision = circle-rect for PP bodies, PP caps, ground · forgiveness_margin = 4px (shrink collision box 4px each side)

---

## Game States

[ALWAYS] exactly 4 states: menu · playing · dying · gameover

**menu:** bg + ground + clouds scroll · BRD bobs (sine, amplitude=8px, period=60 FR) · title "FLAPPY BIRD" white bold centered at 40% CV_height · "Press SPACE or tap to start" below, pulse opacity 0.4–1.0 period=60 FR

**playing:** normal gameplay · SC++ each time BRD horizontal center passes right edge of PP · play "point" SFX on SC++

**dying:** triggered on collision · BRD stops horizontal movement · gravity continues · play "hit" SFX · run particle animation · -> gameover after particles done && BRD landed or passed CV bottom

**gameover:** semi-transparent dark overlay · center panel: final SC · best SC (localStorage) · "Press SPACE or tap to restart" · if new best -> gold "NEW BEST!" badge · SPACE or tap -> playing (reset BRD pos, clear all PP, SC=0) · !! no return to menu

---

## Audio

[ALWAYS] synthesize all sounds via Web Audio API · !! no audio files
[ALWAYS] AudioContext = lazy init on first user interaction (browser autoplay policy)

- flap: sine wave, 520Hz, 80ms, fade full->silence · trigger: each flap
- point: ascending chirp, 660Hz×50ms then 880Hz×50ms (total 100ms) · trigger: each PP passed
- hit: white noise burst, 150ms, fade->silence · trigger: on collision
- die: descending tone 400Hz->200Hz over 300ms · trigger: 100ms after hit

---

## Controls

- spacebar -> flap
- CV tap -> flap
- CV left-click -> flap

[ALWAYS] all 3 inputs work simultaneously
[ALWAYS] preventDefault on CV touch events only · !! not on page touch (avoid blocking scroll)

---

## Technical Requirements

- single .html · no `<script src>` · no `<link rel=stylesheet href>` · no fetch() · no import
- file:// protocol compatible (no CORS)
- `'use strict'`
- JS sections (labeled): constants · state · audio · drawing · physics · input · game loop
- game loop = requestAnimationFrame · frame_counter = integer incrementing each FR · !! not wall-clock time · frame_counter = primary timing source for spawn/animation
- best SC: localStorage key = 'flappyBirdBest' · read on page load · update immediately on new best
- CV resize: recalculate scale = fit CV in window (maintain 480×640 aspect) · apply via CSS transform:scale() on CV element · !! internal CV resolution always 480×640

---

## Deliverable

Output complete ready-to-run .html file · works unmodified as flappy-bird.html in Chrome/Firefox/Safari · HTML comment at top: approx line count + major sections list
