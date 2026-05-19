# Flappy Bird — one-shot spec (BOTSPEAK iter 1)

@defs
  CV = canvas
  BD = bird
  PP = pipe/pipes
  GM = game
  FR = frame
  SC = score
  ST = state
  LS = localStorage
@end

[ALWAYS] output = single self-contained .html · no external deps (images/fonts/audio/libs) · runs via file:// · 'use strict'

<context>
## CV setup
CV: 480×640 · centered · bg #1a1a2e · box-shadow
CV scale on resize: CSS transform:scale() · internal resolution fixed 480×640
!! change internal resolution

## visual
sky gradient: #0f3460 (top) -> #16213e (bottom)
clouds: white ellipses · transparency 0.35 · speed = PP_speed/4 · count 6
ground: green strip 40px tall #2d5a27 · yellow stripe top edge #8fbc45 · scrolls at PP speed

BD:
  body = yellow circle r=14 · eye dark r=4 upper-right · beak orange triangle right
  wing = darker-yellow ellipse left side · animates up/down 8 FR/cycle
  rotation = clamp(-30deg nose-up, 90deg nose-down) matching vy
  x fixed at CV_W * 0.2

PP (pairs: top↓ + bottom↑):
  gap = 150px · gap_y randomized 20%-75% CV_H
  body: 60px wide #2d6a4f · highlight stripe #40916c 8px left edge
  cap: 70px wide × 20px tall · same colors · at open end of each PP
  enter from right · move left constant speed

SC display: large white centered 40px from top · bold sans-serif 48px · semi-transparent bg rect
  best SC: top-right 20px font
particles on death: 20 × (r=3-6px · warm color · random dir+speed 2-6px/FR · gravity applied · fade 40FR)
</context>

<rules>
## physics
gravity = 0.5 px/FR² (playing ST only)
flap_vy = -9 px/FR
terminal_vy = 12 px/FR (downward)
PP_speed = 3 px/FR (constant · !! scale with SC)
PP_spawn_interval = 90 FR · first PP at FR 120 after entering playing ST
collision = circle-rect · PP bodies + PP caps + ground · forgiveness margin = 4px each side

## states (exactly 4)
menu:
  BG + ground + clouds scroll · BD bobs sine-wave amp=8px period=60FR at CV center
  title "FLAPPY BIRD" centered at CV_H*0.4 · bold large white
  subtitle "Press SPACE or tap to start" pulsing opacity 0.4-1.0 period=60FR

playing:
  normal gameplay
  SC++ each time BD x-center passes right edge of PP pair
  [ON-TRIGGER] SC++ -> play point sound

dying:
  [ON-TRIGGER] collision detected -> enter dying ST
  BD: stops horizontal movement · gravity continues
  sounds: hit immediately · die 100ms later
  run particle animation
  -> gameover ST when: particles done && (BD landed || BD below CV)

gameover:
  semi-transparent dark overlay on stopped scene
  panel center: final SC · best SC (from LS) · "Press SPACE or tap to restart"
  [ON-TRIGGER] score > best -> show "NEW BEST!" badge gold · update LS immediately
  SPACE || tap -> restart directly into playing ST (reset BD pos · clear PP · SC=0)
  !! return to menu on restart

## audio (Web Audio API · synthesized · lazy AudioContext on first interaction)
flap:  sine 520Hz · 80ms · fade to silence
point: 660Hz 50ms -> 880Hz 50ms · 100ms total
hit:   white noise · 150ms · fade
die:   descending 400Hz->200Hz · 300ms · start 100ms after hit

## controls (all simultaneous)
space   -> flap (keyboard)
tap CV  -> flap (touch · preventDefault on CV only)
click CV-> flap (mouse)
!! flap when ST != playing (except menu tap = start · gameover tap = restart)

## tech
GM loop: requestAnimationFrame · FR counter (int) as primary timing · !! wall-clock time
LS key: 'flappyBirdBest' · read on load · write immediately on new best
JS sections: constants · state · audio · drawing · physics · input · GM loop
deliverable: flappy-bird.html · runs Chrome/Firefox/Safari · HTML comment: line count + sections
</rules>
