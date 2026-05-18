<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-18 -->

# One-Shot Flappy Bird — Full Specification

@defs
  CV  = canvas
  B   = bird
  PP  = pipe pair
  FR  = frame
  GS  = game state
  SC  = score
  PT  = particle
  GND = ground
  VEL = velocity
  FL  = flap
  COL = collision
@end

[ALWAYS] single self-contained .html · no external dependencies · runs via file:// in any modern browser
!! no external images · fonts · audio · JS libraries · SVG · DOM elements · CSS animations for game objects
[ALWAYS] render all game objects on HTML5 canvas 2D API

## Visual Design

CV: 480×640 px · centered horizontally · page bg #1a1a2e · subtle box-shadow

**Sky:** gradient top→bottom #0f3460→#16213e

**Clouds:** small white ellipses · slight transparency
  cloud_offset: += PP.speed × 0.25 each FR
  render: draw at (base_x - cloud_offset % CV.w)
  ← ambient: single offset

**GND:** green rect · CV bottom · 40px tall · #2d5a27 · thin yellow stripe top #8fbc45
  GND_offset: += PP.speed each FR
  render: draw at (base_x - GND_offset % CV.w)
  ← ambient: single offset

**B:**
  B.r       = 14 px (yellow circle)
  eye.r     = 4 px · positioned upper-right
  beak      = orange triangle pointing right
  wing: slightly darker yellow ellipse · left side · animates up/down · wing_cycle = 8 FR
  B.rot: derived from B.VEL.y · clamp [-30, 90] deg  ← nose-up -30 · nose-down 90
  B.x_fixed = CV.w × 0.20  ← horizontal pos fixed

**PP:**
  top PP: CV top downward · bottom PP: CV bottom upward
  PP.gap        = 150 px (between top and bottom pipe)
  PP.gap_center: randomized 20%–75% CV.h
  PP.w          = 60 px
  PP.x_init     = CV.w              ← entity: per-instance x
  PP.x:         -= 3 px each FR
  PP.remove-when: PP.x + PP.w < 0
  body: dark green rect #2d6a4f · left highlight stripe 8px #40916c
  cap:  70×20 px · same color scheme with highlight · at open end of each pipe

**SC display:**
  current SC: large white num · centered · 40px from CV top · dark semi-transparent bg rect · bold sans-serif 48px
  best SC: top-right corner · 20px font

**PT (on B death):**
  PT.count      = 20 · emitted from B position
  PT.r: random 3–6 px
  PT.color: random warm — yellow · orange · red
  PT.speed_init = 2–6 px/FR (random)
  PT.dir_init: random direction
  PT.gravity    = 0.5 px/FR²  ← same rate as B
  PT.life       = 40 FR · fade to 0 opacity → remove
  !! game does not restart until all PT animation complete

## Physics

[ALWAYS] fixed timestep loop via requestAnimationFrame · cap delta time (tab-focus-loss protection)

gravity         = 0.5 px/FR²  ← applied to B.VEL.y each FR while GS = "playing"
FL.VEL          = -9 px/FR    ← applied to B.VEL.y on FL · upward
!! FL only when GS = "playing"
terminal_VEL    = 12 px/FR    ← cap B downward VEL
PP.speed        = 3 px/FR     ← constant · !! no increase with SC
PP_spawn_interval = 90 FR
PP_spawn_first    = 120 FR    ← after GS -> "playing"

COL:
  B vs PP body: circle-rect
  B vs PP cap:  circle-rect
  B vs GND:     circle-rect
  forgiveness:  shrink effective COL box 4px each side (all collisions)

## Game States

GS states: menu · playing · dying · gameover

[ON-TRIGGER] GS = "menu":
  background · GND · clouds scroll continuously
  B bobs: sine wave · amplitude = 8 px · period = 60 FR · center of CV
  title: "FLAPPY BIRD" · large white bold · centered · y = CV.h × 0.40
  subtitle: "Press SPACE or tap to start" · smaller · pulse opacity 0.4→1.0 · period = 60 FR

[ON-TRIGGER] GS = "playing":
  normal gameplay
  SC += 1 when B.x_center passes right edge of PP
  play "point" sound on each SC increment

[ON-TRIGGER] GS = "dying":
  trigger: COL detected
  B.x: frozen (no horizontal movement)
  B.VEL.y: gravity continues
  play "hit" sound
  run PT animation
  transition -> GS = "gameover" when: PT complete && (B on GND || B.y > CV.h)

[ON-TRIGGER] GS = "gameover":
  scene: semi-transparent dark overlay on stopped game
  panel center: "GAME OVER" · final SC · best SC (localStorage) · "Press SPACE or tap to restart"
  [ON-TRIGGER] new best SC -> show "NEW BEST!" badge (gold)
  SPACE || canvas-tap -> GS = "playing" immediately
    reset: B position · clear all PP · SC = 0
  !! do NOT return to GS = "menu" — always restart to GS = "playing"

## Audio

[ALWAYS] synthesize all sounds via Web Audio API · !! no audio file loads
[ALWAYS] AudioContext: created lazily on first user interaction (browser autoplay policy)

FL sound:    80ms · sine · 520Hz · fade full→silence · trigger: each FL
point sound: 100ms · ascending two-tone: 660Hz×50ms → 880Hz×50ms · trigger: each PP passed
hit sound:   150ms · white noise · fade full→silence · trigger: on COL
die sound:   300ms · descending 400Hz→200Hz · trigger: 100ms after hit sound

## Controls

SPACE || canvas-tap || canvas-left-click -> FL · all three simultaneous
!! no other keyboard inputs
canvas touch: preventDefault() · !! do NOT preventDefault() on page touch events

## Technical Requirements

[ALWAYS] single .html · !! no <script src> · no <link rel=stylesheet> · no fetch() · no import
[ALWAYS] file:// compatible (no CORS)
[ALWAYS] 'use strict' in JS

JS sections (labeled): constants · state · audio · drawing functions · physics functions · input handling · game loop
game loop: requestAnimationFrame · integer frame counter (primary timing · !! not wall-clock time)

best SC: localStorage key = 'flappyBirdBest' · read on page load · update immediately on new best

[ON-TRIGGER] window resize:
  CV.scale: recalculate to fit 480×640 in window
  apply: CSS transform:scale(CV.scale) on CV element
  !! do NOT change internal CV resolution — always 480×640

## Deliverable

output: complete ready-to-run .html · saves as flappy-bird.html · works unmodified in Chrome · Firefox · Safari
include: HTML comment at top with approx line count + list of major sections
