# Flappy Bird — one-shot spec (BOTSPEAK v2)

@defs
  CV = canvas
  BD = bird
  PP = pipe/pipes
  GM = game
  FR = frame(s)
  SC = score
  ST = state
  LS = localStorage
  fy = forgiveness-margin
  SFX = sound
@end

[ALWAYS] output = single .html · no external deps (images · fonts · audio · libs) · file:// protocol · 'use strict'

<context>

## CV setup
480×640px · centered · bg #1a1a2e · box-shadow
scale on resize: CSS transform · internal res fixed
!! never change internal 480×640

## visual
**sky:** gradient #0f3460→#16213e
**clouds:** white ellipses · 0.35 opacity · speed = PP_speed/4
**ground:** 40px green #2d5a27 + #8fbc45 stripe top · PP_speed scroll
**BD:** yellow circle r=14 · dark eye r=4 upper-right · orange triangle beak right · wing: dark-yellow ellipse LHS animates 8FR/cycle
  rotation: clamp -30°(nose↑) to 90°(nose↓) per vy
  x-pos: fixed 20% from left
**PP pairs (top↓ + bottom↑):** gap 150px · gap_y 20%-75% CV_H
  body: 60px wide #2d6a4f + #40916c stripe 8px left
  cap: 70×20px · same colors · at open end
  enter right · move left constant
**SC display:** large white 40px from top centered · bold 48px · semi-transparent bg
  best SC: top-right 20px
**particles:** death → 20 × (r=3-6px · warm color · random dir·speed 2-6px/FR · gravity · fade 40FR)

</context>

<rules>

## physics
gravity = 0.5 px/FR² (playing ST only)
flap_vy = -9 px/FR ↑
terminal_vy = 12 px/FR ↓
PP_speed = 3 px/FR ← · !! scale w/ SC
PP_spawn = every 90FR · first at FR120 after playing starts
collision = circle-rect (BD vs PP·ground) · fy=4px each side

## ST (exactly 4: menu · playing · dying · gameover)
**menu:**
  BG + ground + clouds scroll
  BD bobs center: sine wave amp=8px period=60FR
  title "FLAPPY BIRD" 40% ht · bold large white
  "Press SPACE or tap to start" pulsing 0.4-1.0 opacity 60FR

**playing:**
  normal gameplay
  SC++ when BD x-center passes PP right edge
  [ON-TRIGGER] SC++ → play point SFX

**dying:**
  [ON-TRIGGER] collision → dying ST
  BD: stop horiz · gravity continues
  play hit SFX · particle fx · die SFX 100ms after hit
  [ON-TRIGGER] particles done && (BD landed ∨ BD below CV) → gameover ST

**gameover:**
  dark semi-transparent overlay
  panel: final SC · best SC (LS key 'flappyBirdBest') · "Press SPACE/tap restart"
  [ON-TRIGGER] new record → "NEW BEST!" gold badge · update LS
  SPACE ∨ tap → restart playing ST (reset BD pos · clear PP · SC=0)
  !! go menu on restart

## audio (Web Audio API · synthesized · lazy AudioContext on first input)
flap: 520Hz sine 80ms fade
point: 660Hz 50ms → 880Hz 50ms (100ms total)
hit: white-noise 150ms fade
die: 400Hz→200Hz descend 300ms · starts 100ms post-hit

## controls (simultaneous: keyboard · touch · mouse)
space ∨ tap ∨ click CV = flap
[ON-TRIGGER] touch on CV → preventDefault (avoid scroll)
!! flap outside playing ST (except menu·gameover entry)

## tech
loop: requestAnimationFrame · FR counter int as primary · !! wall-clock
LS: key 'flappyBirdBest' · read load · write on new record
JS sections: constants · state · audio · draw · physics · input · loop
deliverable: flappy-bird.html · Chrome/Firefox/Safari · HTML comment: line count + sections

</rules>

