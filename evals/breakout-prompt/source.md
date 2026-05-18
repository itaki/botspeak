# One-Shot Breakout — Full Specification Prompt

Build a complete, playable Breakout (Arkanoid-style) clone in a single self-contained HTML file with no external dependencies of any kind. The game must run by opening the file directly in any modern browser without a local server. Do not use any external images, fonts, audio files, or JavaScript libraries. Everything — graphics, physics, sounds, UI — must be generated programmatically in the file itself.

---

## Visual Design

Draw everything on an HTML5 canvas element using the 2D canvas API. Do not use SVG, DOM elements, or CSS animations for game objects.

The canvas should be 480 pixels wide and 640 pixels tall, centered horizontally on the page. The page background behind the canvas should be a dark color (#0a0a0a). The canvas should have a subtle box-shadow.

**Background:** Solid dark navy (#0d1b2a). No grid, no decoration.

**Paddle:** Draw the paddle as a rounded rectangle, 80 pixels wide and 12 pixels tall, with a corner radius of 6 pixels. Color it cyan (#00bfff). The paddle's vertical position is fixed at y = canvas_height - 40. The paddle's x clamps so it stays fully on the canvas.

**Ball:** Draw the ball as a white circle with a radius of 7 pixels. The ball's position refers to its center.

**Bricks:** Arrange bricks in a 5-row by 8-column grid near the top of the canvas. Each brick is 54 pixels wide and 20 pixels tall, with 4 pixels of padding between bricks. The grid is centered horizontally; the top row starts at y = 60. Color each row a distinct color from top to bottom:
- Row 0 (top): #ff4d4d (red)
- Row 1: #ff944d (orange)
- Row 2: #ffd84d (yellow)
- Row 3: #4dd47e (green)
- Row 4: #4d9dff (blue)

Each brick has a 2-pixel inner border in a slightly darker shade for visual definition.

**Score display:** Show "SCORE: 0" in the top-left corner of the canvas at x = 12, y = 28, in a bold sans-serif font at 18px white. Show "LIVES: 3" in the top-right corner aligned to the right edge, same font.

**Center text:** When the game is in the menu, win, or gameover state, show centered text on the canvas. Title text uses a bold sans-serif font at 40px white. Subtitle uses 20px white with pulsing opacity (oscillates between 0.4 and 1.0 over a 60-frame period).

---

## Physics

Use a fixed timestep physics loop driven by `requestAnimationFrame`. Cap the delta time to prevent physics explosions if the tab loses focus.

- **Ball initial velocity:** When the game starts or after a life is lost, the ball spawns just above the paddle at its center, with velocity (vx = ±3, vy = -4). The horizontal sign is randomized per serve.
- **Ball speed:** The ball moves at the velocity each frame. There is no speed-up over time (constant speed for the duration of a single life — players have to learn the timing).
- **Paddle bounce angle:** When the ball collides with the paddle, set ball.vy = -|ball.vy| (always rebound upward) and modify ball.vx based on where the ball hit the paddle: ball.vx = ((ball.center_x - paddle.center_x) / (paddle.width / 2)) × 5. Clamp |ball.vx| to a maximum of 7 pixels per frame. This makes the paddle feel responsive — hit the ball near an edge to angle the bounce sharply.
- **Wall bounce:** When the ball's left or right edge passes x = 0 or x = canvas_width, invert ball.vx. When the ball's top edge passes y = 0, invert ball.vy. The bottom wall is the lose condition (see below) — do not bounce off the bottom.
- **Brick collision:** When the ball overlaps a brick, determine which edge was hit by comparing the ball's previous-frame center to the brick's edges. If the ball entered from the top or bottom, invert ball.vy. If it entered from the left or right, invert ball.vx. If it entered from a corner, invert both. Remove the brick from the active grid and award score.
- **Score per brick:** Top row (red) = 50 pts, next (orange) = 40, yellow = 30, green = 20, blue (bottom) = 10. This rewards reaching the harder-to-hit upper rows.
- **Paddle speed:** When the left arrow key (or A) is held, the paddle moves left at 8 pixels per frame. When right arrow (or D) is held, it moves right at 8 pixels per frame. Mouse and touch override keyboard: when the mouse is over the canvas, the paddle's center_x follows the mouse x position (clamped to canvas). When a touch is active on the canvas, the paddle's center_x follows the touch x position.
- **Lose a life:** When the ball's top edge passes y = canvas_height (ball fell off bottom), decrement lives by 1. If lives > 0, reset the ball above the paddle for a new serve after a 30-frame delay. If lives = 0, transition to the gameover state.

---

## Game States

The game has exactly four states: **menu**, **playing**, **win**, **gameover**.

**Menu state:** Show the bricks, paddle, and an idle ball resting on top of the paddle. Show "BREAKOUT" as the centered title at canvas_height × 0.35. Show "Press SPACE or click to start" as the pulsing subtitle at canvas_height × 0.50. Score and lives are visible in the corners but show their initial values.

**Playing state:** Normal gameplay. Bricks are destroyed as hit. Score and lives update in real time. If all bricks are destroyed, transition to win. If lives reaches 0, transition to gameover.

**Win state:** Show a semi-transparent dark overlay (rgba(0, 0, 0, 0.6)) on top of the final frame. Show "YOU WIN!" in green (#4dd47e) as the centered title at canvas_height × 0.35. Show the final score below in 28px white. Show "Press SPACE to play again" as the pulsing subtitle at canvas_height × 0.60.

**Gameover state:** Show a semi-transparent dark overlay on top of the final frame. Show "GAME OVER" in red (#ff4d4d) as the centered title at canvas_height × 0.35. Show the final score below in 28px white. Show "Press SPACE to try again" as the pulsing subtitle at canvas_height × 0.60.

Pressing SPACE or tapping in win or gameover restarts the game with score = 0, lives = 3, bricks fully repopulated, and the ball serving above the paddle.

---

## Audio

Synthesize all sounds using the Web Audio API. Do not load any audio files.

- **Paddle hit sound:** A short (50ms) square wave at 440Hz, fading to silence. Triggered when the ball hits the paddle.
- **Wall hit sound:** A short (40ms) sine wave at 220Hz, fading to silence. Triggered when the ball hits a side or top wall.
- **Brick hit sound:** A short (80ms) ascending two-tone chirp — 660Hz for 40ms, then 880Hz for 40ms. Triggered when the ball destroys a brick.
- **Life lost sound:** A short (200ms) descending tone from 300Hz to 100Hz. Triggered when the ball falls off the bottom.
- **Win sound:** An ascending three-tone fanfare — 523Hz (C5), 659Hz (E5), 784Hz (G5), each for 120ms. Triggered when entering the win state.

Create the AudioContext lazily on the first user interaction to comply with browser autoplay policies.

---

## Controls

- **Keyboard:** Left Arrow or A moves the paddle left. Right Arrow or D moves the paddle right. Spacebar starts or restarts the game.
- **Mouse:** When the mouse is over the canvas, the paddle's center_x follows the mouse x position. Mouse click anywhere on the canvas starts or restarts the game when not playing.
- **Touch:** A touch on the canvas drags the paddle (paddle.center_x = touch.x). A tap starts or restarts the game when not playing.

Mouse and touch override keyboard for paddle position. Do not prevent default touch behavior on the page; only on canvas touch events.

---

## Technical Requirements

- The entire game must be contained in one `.html` file.
- No `<script src="...">`, no `<link rel="stylesheet" href="...">`, no `fetch()`, no `import`.
- The game must work when opened via `file://` protocol (no CORS issues).
- Use `'use strict'` in the JavaScript.
- Organize the JavaScript with clearly labeled sections: constants, state, audio, drawing functions, physics functions, input handling, game loop.
- The game loop must use `requestAnimationFrame` and track a frame counter (integer, incrementing each frame) as the primary timing source for the serve delay and the subtitle opacity pulse — not wall-clock time.
- The canvas should respond to window resize: on resize, recalculate a `scale` factor to fit the canvas within the window while maintaining the 480×640 aspect ratio. Apply the scale via CSS `transform: scale()` on the canvas element. Do not change the internal canvas resolution — keep it at 480×640 always.

---

## Deliverable

Output the complete, ready-to-run HTML file. The file should work without modification when saved as `breakout.html` and opened in Chrome, Firefox, or Safari. Include a brief HTML comment at the top with the approximate line count and a list of the major sections.
