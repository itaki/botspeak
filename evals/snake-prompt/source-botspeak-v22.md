<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-18 -->

# One-Shot Snake — Full Spec

@defs
 CV    = canvas
 DIR   = direction
 rAF   = requestAnimationFrame
 LS    = localStorage
 FR    = frame
 SBKEY = 'snakeBest'
@end

default-phase: [ALWAYS]

## Deliverable

single self-contained .html · no external deps · runs via file:// · opens in Chrome/Firefox/Safari without modification
include HTML comment at top: approx line count + major sections

!! no: `<script src>` · `<link rel=stylesheet href>` · fetch() · import · external images/fonts/audio/libraries

## Visual Design

CV: 400×400px · centered horizontally · page bg #111 · subtle box-shadow · 2D canvas API

grid: 20×20 cells · each cell 20×20px · subtle dark grid overlay (cells faintly visible)

snake:
 each segment: rounded rect filling cell · 2px corner radius
 head: #39ff14 (neon green) · body: #2ecc71
 eyes: 2×3px dark circles on head · positioned in current movement DIR

food:
 red circle · radius 8px · centered in cell
 highlight: 2px white circle · upper-left (shiny appearance)
 pulse: radius oscillates 7–9px over 60-FR cycle

score display: above CV · not on it
 current score: large white number · centered · monospace
 best score: below current · smaller · monospace

game states:
 menu:
  "SNAKE" → large neon green bold · centered on CV
  "Press SPACE or click to start" → pulsing opacity
  best score at bottom
 game-over:
  flash: red tint overlay · 3 FR
  then: semi-transparent dark overlay showing:
   "GAME OVER" · final score · best score
   if new best -> "NEW BEST!" in gold
   "Press SPACE or click to restart"

## Game Logic

grid: 20 cols × 20 rows · coords (col, row) · zero-indexed from top-left · snake + food occupy full cells

snake movement:
 1 cell per tick
 body: array of {col, row} · head at index 0
 each tick: prepend new head in current DIR · remove tail unless food eaten this tick
 !! no reverse DIR (right cannot immediately move left, etc.)
 input buffer: queue max 1 pending DIR change

food:
 exactly 1 at all times
 spawns: random empty cell (not occupied by any snake segment)
 if no empty cells remain -> show "YOU WIN!" screen

collision:
 head → any body segment -> game over
 head → outside grid boundary -> game over

scoring:
 eat food: +10 pts
 best score: LS[SBKEY] · read on page load · update immediately on new best

speed:
 start: 150ms/tick
 every 5 foods eaten: interval -= 10ms
 minimum: 60ms
 reset to 150ms on restart
 loop: setTimeout-based tick (game logic) + rAF (render) · separate

## Audio

[ON-TRIGGER] first user interaction -> create AudioContext (lazy init)
!! no audio files · Web Audio API only

eat sound:   60ms total · 440Hz/30ms then 660Hz/30ms (ascending two-tone)
death sound: 300Hz → 100Hz over 250ms · + white noise burst 50ms
move sound:  none

## Controls

keyboard: arrow keys = DIR change · spacebar = start/restart
click/tap:  CV click = start/restart
            swipe (touchstart → touchend delta) = DIR change

## Technical Requirements

'use strict'
render loop: rAF · every FR · 60fps visual updates
logic loop:  setTimeout-based tick · DIR changes · movement · collision · separate from render
FR counter:  integer · increments each animation FR · used for food pulse + opacity oscillations
LS[SBKEY]:  read on page load · update immediately on new best
