<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-18 -->

# one-shot breakout spec

<context>
build: single self-contained .html · no external deps · runs via file:// · no server required
!! no external images · fonts · audio files · JS libs · everything generated programmatically
</context>

<defs>
@defs
  CV  = canvas
  BL  = ball
  PD  = paddle
  BR  = brick
  FR  = frames
  GO  = gameover
@end
</defs>

default-phase: [ALWAYS]

<rules>

## visual-design

[ALWAYS] CV: 480×640 · centered horizontal · page-bg #0a0a0a · subtle box-shadow · CV-bg #0d1b2a
[ALWAYS] render: 2D canvas API only · !! no SVG · !! no DOM game objects · !! no CSS animations

PD: rounded-rect · w=80 · h=12 · radius=6 · color=#00bfff
  PD.y = CV.h - 40 · PD.x clamped so PD stays fully within CV

BL: white circle · radius=7 · position = center

BR grid: 5 rows × 8 cols · BR.w=54 · BR.h=20 · gap=4 · grid-top y=60 · centered horizontal
  BR inner border = 2px darker shade
  row colors top→bottom:
    row0=#ff4d4d · row1=#ff944d · row2=#ffd84d · row3=#4dd47e · row4=#4d9dff

score: "SCORE: 0" x=12 y=28 · bold sans-serif 18px white
lives: "LIVES: 3" top-right right-aligned · same font

center-text (menu · win · GO):
  title: bold sans-serif 40px white
  subtitle: 20px white · opacity 0.4↔1.0 / 60FR period

## physics

[ALWAYS] physics loop: requestAnimationFrame fixed-timestep · cap delta-time to prevent physics explosion on tab blur

BL init (per serve): BL.cx = PD.cx · BL.y = PD.y - BL.r · BL.vx = ±3 (randomized per serve) · BL.vy = -4
BL speed: constant per-FR velocity · no speed-up during life

[ON-TRIGGER] BL hits PD:
  BL.vy = -|BL.vy|
  BL.vx = ((BL.cx - PD.cx) / (PD.w / 2)) × 5
  clamp |BL.vx| <= 7

wall bounce:
  BL.left <= 0 || BL.right >= CV.w -> invert BL.vx
  BL.top <= 0 -> invert BL.vy
  !! BL bottom edge = lose condition · no bounce

[ON-TRIGGER] BL overlaps BR:
  compare BL prev-FR center to BR edges:
    top/bottom entry -> invert BL.vy
    left/right entry -> invert BL.vx
    corner entry -> invert both
  remove BR from active grid · award score
  row score: row0=50 · row1=40 · row2=30 · row3=20 · row4=10

PD speed (keyboard): left/A -> PD.x -= 8 each FR · right/D -> PD.x += 8 each FR
PD position (mouse): PD.cx = mouse.x (clamped to CV) — overrides keyboard
PD position (touch): PD.cx = touch.x — overrides keyboard

[ON-TRIGGER] BL.top >= CV.h:
  lives -= 1
  lives > 0 -> reset BL above PD · serve_delay = 30 FR
  lives = 0 -> GO state

## game-states

states: menu · playing · win · GO

menu:
  show: BR · PD · idle BL on PD-top
  title "BREAKOUT" centered at CV.h×0.35
  subtitle "Press SPACE or click to start" pulsing at CV.h×0.50
  score/lives visible at initial values

playing:
  normal gameplay · BR destroyed on hit · score/lives update real-time
  all BR destroyed -> win state
  lives = 0 -> GO state

win:
  overlay rgba(0,0,0,0.6)
  title "YOU WIN!" color=#4dd47e centered at CV.h×0.35
  final score 28px white below title
  subtitle "Press SPACE to play again" pulsing at CV.h×0.60

GO:
  overlay rgba(0,0,0,0.6)
  title "GAME OVER" color=#ff4d4d centered at CV.h×0.35
  final score 28px white below title
  subtitle "Press SPACE to try again" pulsing at CV.h×0.60

[ON-TRIGGER] SPACE || tap in win || tap in GO:
  restart: score=0 · lives=3 · BR repopulated · BL serves above PD

## audio

[ALWAYS] Web Audio API only · !! no audio files · AudioContext lazy-init on first user interaction

[ON-TRIGGER] BL hits PD      -> paddle-snd: 50ms square-wave 440Hz fade-to-silence
[ON-TRIGGER] BL hits side/top wall -> wall-snd: 40ms sine 220Hz fade-to-silence
[ON-TRIGGER] BL destroys BR  -> brick-snd: 80ms chirp (660Hz/40ms → 880Hz/40ms)
[ON-TRIGGER] BL falls off bottom -> life-snd: 200ms descend 300Hz→100Hz
[ON-TRIGGER] enter win state -> win-snd: 523Hz(C5)/120ms → 659Hz(E5)/120ms → 784Hz(G5)/120ms

## controls

keyboard: left/A -> PD left · right/D -> PD right · SPACE -> start/restart
mouse: over CV -> PD.cx = mouse.x (clamped) · click on CV (not playing) -> start/restart
touch: drag on CV -> PD.cx = touch.x · tap on CV (not playing) -> start/restart
!! do not preventDefault on page touch events · only on CV touch events

## technical

[ALWAYS] !! no <script src> · !! no <link href> · !! no fetch() · !! no import
[ALWAYS] file:// compatible · no CORS
[ALWAYS] 'use strict' in JS
[ALWAYS] JS sections (clearly labeled): constants · state · audio · draw · physics · input · game-loop
[ALWAYS] game loop: requestAnimationFrame
[ALWAYS] frame_counter: integer · increments each FR · used for serve_delay · subtitle pulse · !! not wall-clock time
[ALWAYS] resize: recalculate scale = fit CV within window maintaining 480×640 aspect · apply CSS transform:scale() to CV element
  !! CV internal resolution = 480×640 always · !! never change internal resolution

</rules>

<reference>

## deliverable

[REFERENCE] output: complete ready-to-run .html · saves as breakout.html · runs without modification in Chrome/Firefox/Safari
[REFERENCE] include HTML comment at top: approx line count + major sections list

</reference>
