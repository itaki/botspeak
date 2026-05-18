# One-Shot Snake — Full Specification Prompt

Build a complete, playable Snake game in a single self-contained HTML file with no external dependencies. The game must run by opening the file directly in any modern browser without a local server. Do not use any external images, fonts, audio files, or JavaScript libraries. Everything — graphics, sounds, and UI — must be generated programmatically in the file itself.

---

## Visual Design

Draw everything on an HTML5 canvas element using the 2D canvas API.

The canvas should be 400 pixels wide and 400 pixels tall, centered horizontally on the page. The page background should be dark (#111). The canvas should have a subtle box-shadow.

**Grid:** The playfield is a 20×20 grid of cells (each cell 20×20 pixels). Draw a very subtle dark grid overlay so cells are faintly visible.

**Snake:** Draw each body segment as a rounded rectangle filling its cell (2px corner radius). The head segment uses a slightly brighter color (#39ff14 neon green) than the body segments (#2ecc71). Draw a pair of small dark eyes on the head — two 3px circles positioned in the direction the snake is currently moving.

**Food:** Draw food as a red circle (radius 8px) centered in its cell, with a small bright highlight dot (2px white circle) at the upper-left to give a shiny appearance. The food item pulses in size gently: oscillate radius between 7px and 9px over a 60-frame cycle.

**Score display:** Show the current score as a large white number centered above the canvas (not on it). Show the best score below the current score in smaller text. Both use a monospace font.

**Game states UI:**
- **Menu:** Show "SNAKE" in large neon green bold text centered in the canvas. Below it, show "Press SPACE or click to start" pulsing in opacity. Show the best score at the bottom.
- **Game over:** Flash the canvas with a brief red tint (3 frames). Then show a semi-transparent dark overlay with "GAME OVER" text, the final score, best score (with "NEW BEST!" in gold if applicable), and "Press SPACE or click to restart".

---

## Game Logic

**Grid:** 20 columns × 20 rows. The snake and food always occupy full cells. Coordinates are (col, row), zero-indexed from top-left.

**Snake movement:**
- The snake moves one cell per tick
- The head moves in the current direction; the tail follows
- The body is stored as an array of {col, row} objects, head at index 0
- On each tick: prepend a new head in the current direction; remove the tail unless food was eaten this tick
- The snake cannot reverse direction (moving right cannot immediately move left, etc.)
- Input buffering: queue up to 1 pending direction change so rapid key presses aren't lost

**Food:**
- Exactly one food item exists at all times
- Food spawns at a random empty cell (not occupied by any snake segment) after the previous food is eaten
- If no empty cells exist (snake fills the board), the player wins — show a "YOU WIN!" screen

**Collision:**
- The game ends (dies) if the head moves to a cell occupied by any body segment
- The game ends if the head moves outside the grid boundary

**Scoring:**
- Each food eaten: +10 points
- Best score persisted to localStorage under key `snakeBest`
- Best score updates immediately when beaten

**Speed:**
- Start at 1 tick per 150ms (wall-clock time using `setTimeout` / `requestAnimationFrame`)
- Every 5 foods eaten: decrease tick interval by 10ms (minimum 60ms)
- Speed resets to 150ms on game restart

---

## Audio

Synthesize all sounds using the Web Audio API. Do not load any audio files. Create the AudioContext lazily on the first user interaction.

- **Eat sound:** Short (60ms) ascending two-tone: 440Hz for 30ms, then 660Hz for 30ms
- **Death sound:** Descending tone from 300Hz to 100Hz over 250ms, with a brief white noise burst at the end (50ms)
- **Move sound:** No sound on normal movement (keep it clean)

---

## Controls

- **Keyboard:** Arrow keys change direction. Spacebar starts/restarts the game.
- **Click/Tap:** Clicking the canvas starts/restarts the game. Swipe gestures on touch devices change direction (detect swipe direction from touchstart → touchend delta).

---

## Technical Requirements

- The entire game must be in one `.html` file
- No `<script src="...">`, no `<link rel="stylesheet" href="...">`, no `fetch()`, no `import`
- Must work via `file://` protocol
- Use `'use strict'`
- Game loop: use `requestAnimationFrame` for rendering at every frame (60fps visual updates). Use a separate `setTimeout`-based tick for game logic updates (direction changes, movement, collision). Keep rendering and logic loops separate.
- Frame counter: track an integer frame counter incrementing each animation frame, used for food pulse animation and any opacity oscillations
- Store best score in localStorage under key `snakeBest`. Read on page load. Update immediately on new best.

---

## Deliverable

Output the complete, ready-to-run HTML file. Works without modification saved as `snake.html` and opened in Chrome, Firefox, or Safari. Include a brief HTML comment at the top with approximate line count and major sections.
