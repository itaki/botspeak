<!-- BOTSPEAK v2.0.0 · compressed by claude-sonnet-4-5 · 2026-05-07 -->

@defs
  CV      = canvas (480×640 px)
  FR      = frame (rAF integer tick counter)
  BIRD    = bird game object
  PP      = pipe pair game object
  PART    = particle game object
  GS      = game state enum {menu, playing, dying, gameover}
  rAF     = requestAnimationFrame
  PP_SPD  = pipe pair leftward speed (px/FR)
  GRAV    = gravitational acceleration (px/FR²)
  SC      = current score (integer)
  BSC     = best score (localStorage integer)
@end

# One-Shot Flappy Bird — Full Specification

[ALWAYS] output = single self-contained .html · no external deps · runs via file:// · no local server
[ALWAYS] no external images · no external fonts · no audio files · no JS libraries · all generated programmatically

---

## Canvas & Page

CV.w = 480
CV.h = 640
page-bg = #1a1a2e
canvas: centered-horizontal · subtle box-shadow
[ALWAYS] internal canvas resolution = 480×640 (never changes on resize)
[ON-TRIGGER] window resize -> recalculate scale-factor -> apply CSS transform:scale() to canvas element · preserve 480×640 aspect ratio

---

## Visual Design

[ALWAYS] all drawing = HTML5 canvas 2D API · no SVG · no DOM elements · no CSS animation for game objects

### Sky
sky-gradient-top    = #0f3460
sky-gradient-bottom = #16213e
sky-render: linear gradient top→bottom

### Clouds  ← ambient parallax: no per-instance x; single layer offset
cloud-SPD = PP_SPD * 0.25
cloud-style: small white ellipses · slight transparency
cloud-layer-offset: += cloud-SPD each FR
cloud-render: each cloud drawn at (cloud.base-x - cloud-layer-offset % CV.w)
  (cloud.base-x = fixed base position, NOT a per-frame mutating variable)

### Ground  ← ambient parallax: no per-instance x; single layer offset
ground-h            = 40
ground-color        = #2d5a27
ground-stripe-color = #8fbc45
ground-stripe: thin · top edge of ground strip · full width
ground-y            = CV.h - ground-h
ground-SPD          = PP_SPD
ground-layer-offset: += ground-SPD each FR
ground-render: ground rect drawn at (baseX - ground-layer-offset % CV.w)
  (ground-layer-offset = single scalar, NOT stored per ground segment)

### Bird  ← entity: x fixed; y and vy mutate every FR during playing/dying
BIRD.x            = CV.w * 0.20   (fixed screen position · NEVER mutates · not a parallax offset)
BIRD.radius       = 14
BIRD.color        = yellow
BIRD.eye-radius   = 4
BIRD.eye: upper-right of body center
BIRD.beak: orange triangle · pointing right
BIRD.wing: slightly-darker-yellow ellipse · left side of body
BIRD.wing-anim-period = 8    (FR per up/down flap cycle)
BIRD.rotation: tracks BIRD.vy · nose-down when falling · nose-up briefly post-flap
BIRD.rotation-min = -30   (degrees · nose-up clamp)
BIRD.rotation-max = 90    (degrees · nose-down clamp)

(per-frame state mutations — playing state)
BIRD.vy: += GRAV each FR   (mutable per-instance variable · not a computed offset)
BIRD.y:  += BIRD.vy each FR
BIRD.vy: capped at TERM_V (downward maximum)

(per-frame state mutations — dying state)
BIRD.x: frozen (no mutation · same fixed value as playing)
BIRD.vy: += GRAV continues (bird still falls)
PP motion: frozen (PP.x stops mutating)
ground/cloud scroll: frozen (offsets stop incrementing)

### Pipes  ← entity: x is per-instance variable that mutates every FR
PP.w              = 60
PP.cap-w          = 70
PP.cap-h          = 20
PP.gap            = 150   (px between top pipe bottom edge and bottom pipe top edge)
PP.gap-y-min      = CV.h * 0.20
PP.gap-y-max      = CV.h * 0.75
PP.body-color     = #2d6a4f
PP.highlight-color = #40916c
PP.highlight-w    = 8
PP.cap-color      = #2d6a4f   (same scheme as body · with highlight)

(per-instance per-frame mutation — THIS IS NOT A PARALLAX OFFSET)
PP.x_init       = CV.w                      (spawned at right edge · stored per instance)
PP.x:           -= PP_SPD each FR           (PP.x is a mutable per-instance variable)
PP.remove-when: PP.x + PP.w < 0            (despawn when fully off-screen left)

!! treat PP.x as a parallax offset or computed value   (PP.x must be stored + mutated per instance)
!! PP_SPD increases with SC                             (speed is constant · never scales)

### Score Display
score-font    = '48px bold sans-serif'
score-color   = white
score-x       = CV.w * 0.50   (centered)
score-y       = 40
score-bg: dark semi-transparent rect behind score number
bscore-font   = '20px sans-serif'
bscore-pos: top-right corner of canvas

### Particles  ← entity: x, y, vx, vy all mutate per FR per instance
PART.count       = 20
PART.radius-min  = 3
PART.radius-max  = 6    (random per instance)
PART.color: random warm per instance (yellows · oranges · reds)
PART.lifetime    = 40   (FR)
PART.fade: opacity = 1 - (age / PART.lifetime) per FR

(per-instance init — captured at spawn moment)
PART.x_init  = BIRD.x   (value of BIRD.x at collision frame)
PART.y_init  = BIRD.y   (value of BIRD.y at collision frame)
PART.vx_init: random direction · random magnitude 2–6 (px/FR) · assigned once at spawn
PART.vy_init: random direction · random magnitude 2–6 (px/FR) · assigned once at spawn

(per-frame mutation — each PART instance independently)
PART.x:   += PART.vx each FR
PART.y:   += PART.vy each FR
PART.vy:  += GRAV each FR        (same GRAV as BIRD)
PART.age: += 1 each FR
PART.remove-when: PART.age >= PART.lifetime

---

## Physics

[ALWAYS] fixed-timestep loop via rAF · cap delta-time to prevent physics explosion on tab-blur
[ALWAYS] frame-counter = integer · increments each FR · primary timing source for spawn + animation (not wall-clock)

GRAV         = 0.5    (px/FR²)
FLAP_V       = -9     (px/FR · upward · set on flap)
TERM_V       = 12     (px/FR · downward cap on BIRD.vy)
PP_SPD       = 3      (px/FR · constant)
PP_spawn_int = 90     (FR · interval between PP spawns)
PP_first     = 120    (FR · delay after GS → playing before first PP spawns)
COLL_MARGIN  = 4      (px · shrink each side of collision rect before test)

collision = circle-rect for PP bodies · PP caps · ground strip
[ALWAYS] shrink collision rect by COLL_MARGIN on each side before test
[ON-TRIGGER] BIRD flap -> BIRD.vy = FLAP_V
!! flap -> no effect when GS != playing

PP spawn schedule:
  first spawn: frame-counter = PP_first (after GS → playing resets frame-counter)
  subsequent:  every PP_spawn_int FR thereafter

---

## Game States

GS enum = {menu, playing, dying, gameover}   (exactly four states)

### menu
background · ground · clouds: scroll continuously (offsets increment normally)
BIRD.bob-amplitude   = 8     (px)
BIRD.bob-period      = 60    (FR)
BIRD.y-menu: CV.h * 0.50 + BIRD.bob-amplitude * sin(2π * frame-counter / BIRD.bob-period)
title: "FLAPPY BIRD" · large white bold · centered · y = CV.h * 0.40
subtitle: "Press SPACE or tap to start"
subtitle-opacity-min    = 0.4
subtitle-opacity-max    = 1.0
subtitle-opacity-period = 60   (FR)

### playing
SC: += 1 when BIRD.x center passes right edge of a PP pair (once per pair)
[ON-TRIGGER] SC += 1 -> play point-sfx

### dying
[ON-TRIGGER] collision detected -> GS = dying · play hit-sfx · spawn PART.count PART at BIRD.pos
during dying: BIRD.x frozen · BIRD.vy continues under GRAV · PP.x frozen · scroll offsets frozen
[ON-TRIGGER] all PART removed (age >= lifetime) && (BIRD.y >= ground-y || BIRD.y > CV.h) -> GS = gameover
!! transition to gameover before all PART animation completes

### gameover
overlay: semi-transparent dark · full canvas
panel: centered · contains SC (final) · BSC (from localStorage) · "Press SPACE or tap to restart"
[ON-TRIGGER] SC > BSC -> show "NEW BEST!" badge · badge-color = gold · update BSC immediately
BSC-key = 'flappyBirdBest'   (localStorage key · read on page load)
[ON-TRIGGER] SPACE || canvas-tap -> GS = playing · reset BIRD.y · reset BIRD.vy · clear all PP · SC = 0
!! GS = menu on restart   (always restart to playing · never return to menu)

---

## Audio

[ALWAYS] Web Audio API only · no audio files loaded
[ALWAYS] AudioContext: lazy-init on first user interaction (browser autoplay policy)

flap-sfx:   wave = sine      · freq = 520      · duration = 80ms  · env = decay-to-silence
point-sfx:  wave = sine      · seq = [(660, 50ms), (880, 50ms)]   · total = 100ms
hit-sfx:    wave = white-noise               · duration = 150ms · env = decay-to-silence
die-sfx:    wave = sine      · freq-start = 400 · freq-end = 200 · duration = 300ms · delay = 100ms (after hit-sfx)

---

## Controls

[ALWAYS] Spacebar          -> flap
[ALWAYS] canvas tap        -> flap · preventDefault on canvas touch events only
[ALWAYS] canvas left-click -> flap
[ALWAYS] all three input methods active simultaneously
!! preventDefault on page-level touch events   (page scroll must not be blocked · only canvas touch)

---

## Technical Requirements

[ALWAYS] single .html file · no <script src> · no <link href> · no fetch() · no import
[ALWAYS] 'use strict' in JS
[ALWAYS] JS sections labeled: constants · state · audio · drawing functions · physics functions · input handling · game loop
[ALWAYS] rAF game loop · frame-counter = integer · increments each FR
[ALWAYS] BSC stored under BSC-key · read on page load · update immediately on new best

---

## Deliverable

output: complete ready-to-run .html · no modification needed · works in Chrome · Firefox · Safari
file-comment at top: approximate line count + major sections list
