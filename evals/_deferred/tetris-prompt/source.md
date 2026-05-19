# One-Shot Tetris — Full Specification Prompt

Implement a single-file HTML + JavaScript Tetris game using modern, clean rendering. The goal is to recreate the classic Tetris gameplay with smooth animations, sound effects, modern UI elements, and a polished user experience — all in one HTML file.

You must use **HTML5 canvas** for rendering and **vanilla JavaScript** (no external libraries or frameworks). Use `<script>` and `<style>` tags within a single `index.html` file. Use no external assets.

---

## Core Features (Required)

**Tetromino Shapes:** Implement the 7 standard tetrominoes (I, O, T, S, Z, J, L), each with correct rotation behavior and bounding constraints.

**Game Loop & Physics:**
- Handle gravity (piece falling), lock delay, and collision detection.
- Implement a rotation system that supports wall kicks (Super Rotation System preferred).

**Input Controls:**
- Move left/right with ← →
- Rotate with ↑
- Soft drop with ↓
- Hard drop with spacebar
- Hold piece with Shift
- Reset game with R
- Pause/resume with P

**Scoring System:**
- Classic Tetris scoring: Single (100 × level), Double (300 × level), Triple (500 × level), Tetris (800 × level)
- Soft drop bonus: +1 per row
- Hard drop bonus: +2 per row
- Track level and lines cleared
- Speed increases every 10 lines cleared

**Next Queue & Hold Box:**
- Show next 3 upcoming pieces in a preview area
- Allow hold-and-swap for one tetromino at a time; can only hold once per piece placement

**Line Clearing Animation:**
- When a line is cleared, animate its disappearance (fade or flash effect, 200ms)
- Lines above fall smoothly to fill the gap after animation completes

---

## Visual & UX Details

**Canvas Rendering:**
- Canvas size: 300px wide × 600px tall for the playfield (10 columns × 20 rows, 30px per cell)
- Animate piece movements and rotations
- Use grid background with subtle color variation between cells

**UI Layout:**
- Playfield centered on page
- Next queue panel on the right (3 pieces shown)
- Hold box panel on the left
- Score, level, and lines cleared displayed above or beside the playfield
- Pause and Restart buttons visible

**Theme:**
- Dark background (#1a1a2e or similar)
- Neon-style tetromino colors:
  - I → Cyan (#00f5ff)
  - O → Yellow (#ffd700)
  - T → Purple (#b44fff)
  - S → Green (#39ff14)
  - Z → Red (#ff3131)
  - J → Blue (#1e90ff)
  - L → Orange (#ff8c00)
- Ghost piece: same shape as active piece, rendered at landing position, very low opacity (0.2)

**Responsive Design:**
- Center canvas on screen
- Scale to fit window while maintaining aspect ratio
- Apply scale via CSS transform, do not change internal canvas resolution

---

## Advanced Features (Required)

- **Ghost piece:** show where the active piece will land (low opacity outline at drop destination)
- **High score persistence:** store best score in localStorage under key `tetrisBest`

---

## Audio

Synthesize all sounds using the Web Audio API. Do not load any audio files. Create the AudioContext lazily on the first user interaction.

- **Move sound:** Very short (30ms) soft click at 220Hz, low volume
- **Rotate sound:** Short (50ms) tone at 440Hz
- **Lock sound:** Short (80ms) thud — brief white noise burst fading to silence
- **Line clear sound:** Ascending arpeggio: 523Hz → 659Hz → 784Hz → 1047Hz, 40ms each note
- **Tetris sound (4-line clear):** Triumphant ascending sweep 400Hz → 1200Hz over 300ms
- **Game over sound:** Descending tone 600Hz → 200Hz over 500ms

---

## Technical Requirements

- The entire game must be in one `.html` file
- No `<script src="...">`, no `<link rel="stylesheet" href="...">`, no `fetch()`, no `import`
- Must work via `file://` protocol (no CORS issues)
- Use `'use strict'`
- Game loop uses `requestAnimationFrame`; track a frame counter as primary timing source
- Gravity tick rate: level 1 = 48 frames/cell, level 20+ = 1 frame/cell (standard NES Tetris gravity table)
- Lock delay: piece locks after 500ms of resting on a surface with no movement
- The board is 10 columns × 20 visible rows + 2 hidden buffer rows at top (pieces spawn in buffer)

---

## Deliverable

Output the complete, ready-to-run HTML file. The file should work without modification when saved as `tetris.html` and opened in Chrome, Firefox, or Safari. Include a brief HTML comment at the top with the approximate line count and a list of major sections.
