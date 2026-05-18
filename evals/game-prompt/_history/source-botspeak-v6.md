<!-- BOTSPEAK v2.1.0 · compressed by claude-sonnet-4-6 · 2026-05-08 -->

# One-Shot Flappy Bird — Full Specification

@defs
 CV  = canvas (480×640)
 B   = bird
 P   = pipe pair
 FR  = frame
 GS  = game state
@end

[ALWAYS] output = single self-contained .html · no external deps (images · fonts · audio · libs)
[ALWAYS] runs via file:// · no local server required

## Visual Design

[ALWAYS] draw all game objects on HTML5 canvas 2D API · !! no SVG · no DOM elements · no CSS animations

CV: 480×640 · centered horizontally · page bg: #1a1a2e · canvas has box-shadow

sky: gradient #0f3460 (top) -> #16213e (bottom)

clouds:                                         ← ambient: single offset
 cloud_offset: += 0.75 each FR                 (P_speed = 3 px/FR · clouds = 1/4 P_speed)
 render: white ellipses · slight alpha · draw at (base_x - cloud_offset % CV.w)

ground:                                         ← ambient: single offset
 ground_offset: += 3 each FR
 render: green rect (#2d5a27) · 40px tall · bottom of CV · yellow top stripe (#8fbc45)
         draw at (base_x - ground_offset % CV.w)

B:
 shape: yellow circle · radius 14px
 eye: dark circle · radius 4px · upper-right
 beak: orange triangle · pointing right
 wing: darker-yellow ellipse · left side · animates ±Y · period 8 FR/cycle
 rotation: matches velocity · clamp [-30°, 90°]
 x_pos: fixed = CV.w * 0.20

P:                                              ← entity: per-instance x
 P.x_init     = CV.w
 P.x:         -= 3 each FR
 P.remove-when: P.x + 60 < 0
 width: 60px · cap: 70px wide × 20px tall
 gap: 150px · gap_y: random · range [CV.h × 0.20, CV.h × 0.75]
 body: #2d6a4f · left highlight stripe: #40916c · 8px wide
 cap: same color scheme + highlight

score: white · 48px bold sans-serif · centered · 40px from top · semi-transparent bg rect
best score: 20px · top-right

particles:                                      ← entity: per-instance x/y
 spawn: 20 particles from B.pos on death · each has independent x · y · vx · vy
 radius: 3-6px random · color: warm random (yellows/oranges/reds)
 vx_init/vy_init: random direction · random speed 2-6 px/FR
 gravity: same rate as B applied each FR
 lifetime: 40 FR · fade out over lifetime
 !! do not restart game until all particles done

## Physics

[ALWAYS] fixed timestep via requestAnimationFrame · cap delta time (tab-focus guard)

gravity:          0.5 px/FR² downward · applied to B.vy each FR while GS = playing
flap:             B.vy = -9 px/FR · !! no flap when GS != playing
terminal_vel:     B.vy max = 12 px/FR downward
P_speed:          3 px/FR · !! constant · !! no increase with score
P_spawn_interval: 90 FR
P_first:          120 FR after GS -> playing
collision:        circle-rect for P bodies · P caps · ground
                  forgiveness = 4px (shrink collision box 4px each side)

## Game States

[ALWAYS] exactly 4 GS: menu · playing · dying · gameover

menu:
 background + ground + clouds scroll
 B bobs: sine · amplitude 8px · period 60 FR · center of CV
 title "FLAPPY BIRD": large white bold · centered · CV.h × 0.40
 "Press SPACE or tap to start": smaller · opacity pulse [0.4, 1.0] · period 60 FR

playing:
 score += 1 when B.x_center passes P right edge
 [ON-TRIGGER] score increment -> play "point" sound

dying:
 [ON-TRIGGER] collision detected -> B stops horizontal movement · gravity continues · play "hit"
 run particle animation
 -> gameover after: particles done && (B on ground || B.y > CV.h)

gameover:
 semi-transparent dark overlay on stopped scene
 panel: final score · best score (localStorage) · "Press SPACE or tap to restart"
 [ON-TRIGGER] new best -> show "NEW BEST!" gold badge
 [ON-TRIGGER] SPACE or tap -> GS = playing · reset B pos · clear all P · score = 0 · !! no menu return

## Audio

[ALWAYS] Web Audio API · !! no audio files
[ALWAYS] AudioContext created lazily on first user interaction

flap:  80ms · sine · 520Hz · fade to silence · trigger: each flap
point: 100ms · two-tone: 660Hz×50ms then 880Hz×50ms · trigger: each P passed
hit:   150ms · white noise · fade to silence · trigger: collision
die:   400Hz -> 200Hz over 300ms · trigger: 100ms after hit

## Controls

SPACE / canvas tap / canvas left-click -> flap
[ALWAYS] all three inputs active simultaneously
!! only prevent-default on canvas touch events · !! no prevent-default on page touch

## Technical Requirements

[ALWAYS] single .html · !! no <script src> · no <link href> · no fetch() · no import
[ALWAYS] file:// protocol · no CORS
[ALWAYS] 'use strict' in JS
[ALWAYS] JS sections: constants · state · audio · drawing · physics · input · game loop
[ALWAYS] game loop = requestAnimationFrame · frame_counter = integer · increments each FR
         !! no wall-clock time for spawn / animation timing
[ALWAYS] best score: localStorage key = 'flappyBirdBest' · read on page load · update immediately on new best
[ALWAYS] resize: recalculate scale to fit window · maintain 480×640 ratio
         apply via CSS transform:scale() · !! do not change internal CV resolution

## Deliverable

output = complete ready-to-run .html · works unmodified as flappy-bird.html in Chrome · Firefox · Safari
include HTML comment at top: approx line count + list of major sections
