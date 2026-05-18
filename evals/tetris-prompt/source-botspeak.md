<!-- BOTSPEAK v2.1.0 · compressed by claude-sonnet-4-5 · 2026-05-08 -->

@defs
  BG   = #1a1a2e
  CV   = canvas (300×600px · 10col×20row · 30px/cell)
  AP   = active piece (per-instance entity)
  GR   = gravity tick rate (frames/cell · level-dependent)
  LD   = lock delay (500ms resting timer)
  NQ   = next queue (3-piece preview)
  HB   = hold box (1-piece swap)
  SRS  = Super Rotation System wall kicks
  FC   = frame counter (rAF primary timing source)
  LS   = localStorage key `tetrisBest`
  WAA  = Web Audio API (lazy-init on first user interaction)
@end

default-phase: [ALWAYS]

<context>
[NEW-CHAT] target = single-file HTML+JS Tetris · CV rendering · vanilla JS · no external assets · `file://` compatible
[NEW-CHAT] output = one `.html` file · `'use strict'` · rAF game loop
</context>

<rules>

## board

board: 10col × 22row (20 visible + 2 hidden buffer at top)
board_state: 2D grid · mutates in place (line-clear + row-shift-down)
spawn: AP enters hidden buffer rows at top

## AP entity state (per-instance)

AP.col_init    = spawn column (centered)
AP.row_init    = 0 (hidden buffer)
AP.col:        += / -= 1 each move-left/right         ← entity: per-instance col
AP.row:        += 1 each GR tick                      ← entity: per-instance row
AP.rot_idx:    = 0..3 · mutates per rotate action     ← entity: per-instance rotation
AP.shape:      = matrix derived from (piece_type, AP.rot_idx)
AP.remove-when: AP locked -> merge into board · spawn next piece

!! AP.col · AP.row · AP.rot_idx = instance-owned · NOT global offsets

## tetrominoes

7 types: I · O · T · S · Z · J · L
each type: 4 rotation matrices · all precomputed
rotation: SRS wall kicks · test 5 offset positions per rotation attempt

colors (byte-for-byte):
  I -> #00f5ff
  O -> #ffd700
  T -> #b44fff
  S -> #39ff14
  Z -> #ff3131
  J -> #1e90ff
  L -> #ff8c00

## timing (three distinct concepts — do not merge)

GR_interval:    level 1 = 48 FR/cell · level 20+ = 1 FR/cell (NES gravity table)
LD_duration:    = 500ms · resets on any AP move/rotate while resting · expires -> lock AP
render_frame:   rAF loop · FC increments each frame · GR fires when FC % GR_interval == 0

!! GR_interval != render_frame != LD_duration · three separate variables

## gravity tick

[ON-TRIGGER] FC % GR_interval == 0:
  AP.row += 1
  collision? -> do NOT move · start LD timer if not already running

## lock delay

[ON-TRIGGER] AP resting on surface && LD timer expires (500ms no move/rotate):
  merge AP.shape into board at (AP.row, AP.col)
  check line clears -> animate (200ms fade/flash) -> shift rows down
  spawn next piece from NQ · refill NQ · reset LD timer

[ON-TRIGGER] AP moves || rotates while resting:
  LD timer resets

## line clear + scoring

lines_cleared_total: track across game
level: = floor(lines_cleared_total / 10) + 1
speed increases every 10 lines

score deltas (exact values):
  1 line  (Single):  +100  × level
  2 lines (Double):  +300  × level
  3 lines (Triple):  +500  × level
  4 lines (Tetris):  +800  × level
  soft drop:         +1 per row
  hard drop:         +2 per row

line_clear_anim: 200ms fade/flash · rows above fall after anim completes

## NQ + HB

NQ: show next 3 pieces · rendered in right panel
HB: 1 piece · swap with AP · can_hold resets to true only on AP lock
[ON-TRIGGER] hold action && can_hold == true:
  swap AP <-> HB piece · can_hold = false

## controls

←  →        : AP.col -= / += 1 · collision check
↑            : rotate AP (SRS) · wall kick
↓            : soft drop (AP.row += 1 immediately · +1 score)
spacebar     : hard drop (AP.row to bottom instantly · +2/row score)
Shift        : hold
R            : reset game
P            : pause / resume toggle

## ghost piece

ghost: AP shape projected downward until collision
render: same shape · landing row · opacity 0.2

## high score

LS: persist best score · key = `tetrisBest`
[ON-TRIGGER] game over && score > stored: update LS

## audio (WAA · lazy-init on first user interaction)

move sound:       30ms · 220Hz · low vol · soft click
rotate sound:     50ms · 440Hz · tone
lock sound:       80ms · white noise burst fading to silence
line clear:       arpeggio 523Hz -> 659Hz -> 784Hz -> 1047Hz · 40ms/note
tetris (4 lines): sweep 400Hz -> 1200Hz · 300ms
game over:        descending 600Hz -> 200Hz · 500ms

## rendering

CV: 300×600px · internal resolution fixed · responsive via CSS transform (scale to window · no canvas resize)
background: BG
grid: subtle cell color variation
UI layout:
  HB panel: left
  CV: center
  NQ panel: right
  score / level / lines: above or beside CV
  pause + restart buttons: visible

</rules>

<reference>
[REFERENCE] NES gravity table (FR/cell): lvl1=48 · lvl2=43 · lvl3=38 · lvl4=33 · lvl5=28 · lvl6=23 · lvl7=18 · lvl8=13 · lvl9=8 · lvl10-12=6 · lvl13-15=5 · lvl16-18=4 · lvl19=3 · lvl20+=1
[REFERENCE] SRS wall kick offsets: I-piece and JLSTZ-piece offset tables differ · test 5 positions per rotation
[REFERENCE] deliverable: complete ready-to-run `.html` · works Chrome/Firefox/Safari via `file://` · comment at top: line count + major sections
</reference>
