<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-18 -->

# One-Shot Pong — Full Spec Prompt

@defs
  CW  = canvas_width
  CH  = canvas_height
  BL  = ball
  PD  = paddle
  PL  = player
  GO  = gameover
  FR  = frame
@end

default-phase: REFERENCE

[ALWAYS] output: single self-contained `.html` file · no external deps of any kind
[ALWAYS] !! no `<script src>` · no `<link rel="stylesheet" href>` · no `fetch()` · no `import`
[ALWAYS] !! no external images · fonts · audio files · JS libraries · all generated programmatically
[ALWAYS] must open directly in any modern browser · no local server · must work via `file://` (no CORS)
[ALWAYS] !! no SVG · DOM elements · CSS animations for game objects · use HTML5 canvas 2D API only
[ALWAYS] `'use strict'` in JS
[ALWAYS] internal canvas res = 800×500 always · resize via CSS `transform: scale()` only · never change internal res
[ALWAYS] game loop: `requestAnimationFrame` · integer FR counter = primary timing source (serve_delay + subtitle opacity) · !! not wall-clock time
[ALWAYS] JS sections (labeled): constants · state · audio · drawing functions · physics functions · input handling · game loop
[ALWAYS] audio: Web Audio API only · !! no audio file loading · AudioContext = lazy init on first user interaction
[ALWAYS] ok prevent_default: canvas touch events · !! prevent_default on page touch events (breaks scroll)
[ALWAYS] all input methods work simultaneously

---

## Visual Design

canvas: 800×500 · centered horizontally · box-shadow (subtle screen feel)
page_bg: #0a0a0a
court_bg: #000
center_line: vertical dashed · #ffffff · dash=10px · gap=10px · width=4px · x = CW/2

PD: white rect · 12px wide × 80px tall · y clamped to canvas
PL_PD:  x = 30 (left edge of PD)
CPU_PD: x = CW - 30 - 12 (left edge of PD)

BL: white square · 12×12px · position = top-left corner · serve init = canvas center

resize: on window resize -> recalculate scale to fit window maintaining 800×500 ratio -> apply via CSS `transform: scale()`

score_display:
  PL:  center_x = CW×0.25 · y = 80
  CPU: center_x = CW×0.75 · y = 80
  font: bold sans-serif 64px · #ffffff · opacity=0.5

center_text (menu || GO state):
  title:    bold sans-serif 48px · white
  subtitle: 24px white · opacity oscillates 0.4–1.0 · period = 60 FR

---

## Physics

loop: fixed timestep via `requestAnimationFrame` · cap delta time (tab-focus-loss guard)

BL_serve:
  vx = ±5 px/FR (sign = serve direction)
  vy = random [-3, +3] px/FR

BL_speedup (per PD hit): vx ×= 1.05 · vy ×= 1.05 · |vx| cap = 12 px/FR · vy uncapped

PD_bounce_angle: BL.vy = ((BL.center_y - PD.center_y) / (PD.h / 2)) × 7

wall_bounce: BL.top ≤ 0 || BL.bottom ≥ CH -> BL.vy ×= -1 · clamp BL.y

PL_PD_speed: 7 px/FR (Up/Down || W/S held) · clamped to canvas

CPU_PD_speed:
  BL.vx > 0 (approaching) -> move toward BL.y · max 5 px/FR
  BL.vx ≤ 0 (retreating)  -> drift toward CH/2 · max 2 px/FR

scoring:
  BL.right > CW -> PL +1 · BL reset to center · BL.vx = +5
  BL.left  < 0  -> CPU +1 · BL reset to center · BL.vx = -5
  serve_delay = 60 FR (BL frozen at center)

win: PL or CPU reaches 7 -> GO state

---

## Game States

states = menu · playing · GO (exactly 3)

menu:
  show: court + dashed center line · score hidden
  title:    "PONG" · y = CH×0.35
  subtitle: "Press SPACE or tap to start" · y = CH×0.55

playing:
  both PDs visible · score increments · ends when PL or CPU = 7

GO:
  overlay: rgba(0,0,0,0.6) over final frame
  PL wins  (PL ≥ 7):  "YOU WIN!" · #39ff14 · y = CH×0.35
  CPU wins (CPU ≥ 7): "CPU WINS" · #ff3939 · y = CH×0.35
  final_score: 32px white · below title
  subtitle: "Press SPACE or tap to play again" · y = CH×0.65
  SPACE || tap -> restart: both scores = 0 · serve toward loser of previous match

---

## Audio

PD_hit:    square wave · 440 Hz · 60 ms · fade to silence
wall_hit:  sine wave   · 220 Hz · 50 ms · fade to silence
score_sfx: 880 Hz/80 ms -> 440 Hz/80 ms (descending two-tone chirp)
win_sfx:   523 Hz/120 ms -> 659 Hz/120 ms -> 784 Hz/120 ms (C5->E5->G5 ascending fanfare)

triggers:
  PD hit    -> PD_hit
  wall hit  -> wall_hit
  score     -> score_sfx
  GO entry  -> win_sfx

---

## Controls

keyboard:
  Up || W   -> PL PD up
  Down || S -> PL PD down
  Space     -> start || restart

touch/mouse:
  upper-half canvas press/hold -> PL PD up (continuous)
  lower-half canvas press/hold -> PL PD down (continuous)
  release -> stop movement
  tap anywhere (non-playing state) -> start || restart

---

## Deliverable

output: complete ready-to-run HTML · works unmodified as `pong.html` · Chrome · Firefox · Safari
include: HTML comment at top · approx line count · major section list
