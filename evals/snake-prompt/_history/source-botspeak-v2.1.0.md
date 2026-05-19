<!-- BOTSPEAK v2.1.0 · compressed by claude-sonnet-4-6 · 2026-05-08 -->

@defs
  SN  = snake
  FD  = food
  TK  = tick
  DIR = direction
  SC  = score
  CV  = canvas
  BD  = body
  GR  = grid
  SEG = segment
@end

default-phase: [ALWAYS]

<context>
single-file Snake · no external deps · file:// compatible · 'use strict'
CV: 400×400px · centered · bg #111 · subtle box-shadow
GR: 20 cols × 20 rows · each cell 20×20px · faint dark grid overlay
</context>

<rules>

## SN state  ← entity: per-instance SEG positions

BD = array of SEG objects {col, row} · head at BD[0]  ← per-instance mutation
SN_DIR:         current DIR (up/down/left/right)
DIR_pending:    buffered DIR change queue · max capacity 1

SN movement (per TK):
  1. apply DIR_pending -> SN_DIR if valid (!! not-reverse) · clear queue
  2. new_head = {col: BD[0].col + dx, row: BD[0].row + dy}  (dx/dy from SN_DIR)
  3. collision check: new_head outside GR [0..19] -> death
                      new_head matches any BD[1..] -> death
  4. BD.unshift(new_head)  ← prepend
  5. if FD_eaten_this_TK -> (tail kept = grow)
     else               -> BD.pop()  ← tail removed = no grow

DIR constraint: !! cannot reverse (RIGHT -> LEFT · LEFT -> RIGHT · UP -> DOWN · DOWN -> UP)
DIR_pending:    key pressed -> validate not-reverse -> store in queue (overwrite if queue full)
                apply at step 1 of next TK

## FD state  ← single instance · random per-tick respawn

FD_pos = {col, row}  ← single instance
FD_spawn: choose random cell not occupied by any BD SEG
if BD.length == 400 (GR full) -> WIN

FD eaten:
  SC         += 10
  foods_eaten += 1
  FD_spawn()
  if foods_eaten % 5 == 0 -> TK_interval = max(TK_interval_min, TK_interval - TK_interval_step)

## speed  ← setTimeout-based · NOT frame counter

TK_interval_start = 150  (ms)
TK_interval_min   = 60   (ms)
TK_interval_step  = 10   (ms)
TK_interval:      current ms for setTimeout · decremented every 5 FD eaten
on restart:       TK_interval = TK_interval_start

## loops  ← two separate loops · !! never merge

rAF loop:   render only · 60fps · frame_counter++ each frame
TK loop:    setTimeout(gameTick, TK_interval) · game logic (movement · collision · FD · SC)
            reschedule with updated TK_interval after each tick
!! TK logic (movement · collision) runs in setTimeout · NOT in rAF

frame_counter: integer · increments each rAF · drives FD pulse + opacity oscillations

## rendering

SN BD[0] (head):  rounded-rect · fill #39ff14 · corner-radius 2px
                   eyes: 2× 3px dark circles · positioned in SN_DIR facing
SN BD[1..] (body): rounded-rect · fill #2ecc71 · corner-radius 2px
FD:               red circle · r_base = 8px · r = 7 + (sin(frame_counter / 60 * 2π) + 1) * 1  (pulse 7–9px)
                   highlight: 2px white circle upper-left of cell center

## SC + persistence

SC_key  = 'snakeBest'  (localStorage)
SC_best: read on page load
         update immediately when SC > SC_best

SC display: large white monospace · centered above CV (not on CV)
SC_best:    smaller text below SC display

## game states

MENU:
  "SNAKE" large neon-green bold · centered in CV
  "Press SPACE or click to start" · opacity pulses (frame_counter driven)
  SC_best at bottom of CV

PLAYING: normal TK+rAF loop

GAME_OVER:
  flash red tint overlay · 3 frames
  semi-transparent dark overlay:
    "GAME OVER" · final SC · SC_best
    "NEW BEST!" in gold if SC > SC_best
    "Press SPACE or click to restart"

WIN:
  "YOU WIN!" screen

## audio (Web Audio API · no files · lazy init on first user interaction)

eat_sound:   440Hz 30ms → 660Hz 30ms  (ascending two-tone · total 60ms)
death_sound: 300Hz → 100Hz descending over 250ms + 50ms white noise burst
move_sound:  none

## controls

keyboard:  ArrowKeys -> DIR_pending · Space -> start/restart
click:     CV click -> start/restart
touch:     touchstart/touchend delta -> swipe -> DIR_pending

## technical

!! no <script src> · no <link href> · no fetch() · no import
!! file:// protocol · no server required
'use strict' in script
HTML comment line 1: approx line count + major sections

</rules>
