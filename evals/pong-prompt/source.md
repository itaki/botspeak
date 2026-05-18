# One-Shot Pong — Full Specification Prompt

Build a complete, playable Pong clone (single-player vs CPU) in a single self-contained HTML file with no external dependencies of any kind. The game must run by opening the file directly in any modern browser without a local server. Do not use any external images, fonts, audio files, or JavaScript libraries. Everything — graphics, physics, sounds, UI — must be generated programmatically in the file itself.

---

## Visual Design

Draw everything on an HTML5 canvas element using the 2D canvas API. Do not use SVG, DOM elements, or CSS animations for game objects.

The canvas should be 800 pixels wide and 500 pixels tall, centered horizontally on the page. The page background behind the canvas should be a dark color (#0a0a0a). The canvas should have a subtle box-shadow to make it feel like a screen.

**Court:** Draw the canvas background as solid black (#000). Draw a vertical dashed center line in white (#ffffff) — 10-pixel-tall dashes with 10-pixel gaps, 4 pixels wide, running the full height of the canvas at x = canvas_width / 2.

**Paddles:** Draw both paddles as white rectangles, 12 pixels wide and 80 pixels tall. The player's paddle is on the left, fixed at x = 30 (left edge of paddle). The CPU paddle is on the right, fixed at x = canvas_width - 30 - 12. Both paddles' y values are clamped so the paddle stays fully on the canvas.

**Ball:** Draw the ball as a white square, 12 pixels by 12 pixels. The ball's position refers to its top-left corner. The ball is initialized at the center of the canvas when serving.

**Score display:** Show the player's score in the top-left and the CPU's score in the top-right, both rendered in a bold sans-serif font at 64px in white. The player's score is centered horizontally at canvas_width × 0.25, y = 80. The CPU's score is centered horizontally at canvas_width × 0.75, y = 80. Use semi-transparent white (0.5 opacity) for visibility against the black court without overpowering the play.

**Center text:** When the game is in the menu or gameover state, show centered text on the canvas. Title text uses a bold sans-serif font at 48px white. Subtitle uses 24px white with pulsing opacity (oscillates between 0.4 and 1.0 over a 60-frame period).

---

## Physics

Use a fixed timestep physics loop driven by `requestAnimationFrame`. Cap the delta time to prevent physics explosions if the tab loses focus.

- **Ball speed:** The ball starts each serve with a horizontal velocity of ±5 pixels per frame (sign chosen by serve direction) and a vertical velocity randomly chosen between -3 and +3 pixels per frame.
- **Ball speedup:** Each time the ball hits a paddle, multiply both ball velocity components by 1.05. Cap the absolute horizontal speed at 12 pixels per frame. Do not cap vertical speed independently.
- **Paddle bounce angle:** When the ball collides with a paddle, modify the ball's vertical velocity based on where the ball hit the paddle relative to the paddle's center. Specifically, set ball.vy = ((ball.center_y - paddle.center_y) / (paddle.height / 2)) × 7. This produces sharper angles when the ball hits the paddle's edges and flatter trajectories when it hits the center.
- **Wall bounce:** When the ball's top edge reaches y = 0 or its bottom edge reaches y = canvas_height, invert ball.vy (multiply by -1). Clamp the ball's y so it does not visually clip into the wall.
- **Paddle speed (player):** When an arrow key (Up or Down) or W/S is held, move the player paddle at 7 pixels per frame in that direction. Clamp to the canvas.
- **Paddle speed (CPU):** Each frame, if the ball is moving toward the CPU (ball.vx > 0), the CPU paddle moves toward the ball's y at a maximum of 5 pixels per frame. If the ball is moving away from the CPU, the CPU paddle drifts toward the canvas vertical center at 2 pixels per frame.
- **Scoring:** When the ball's right edge passes x = canvas_width, the player scores 1 point and the ball resets for a new serve in the player's direction (ball.vx = +5). When the ball's left edge passes x = 0, the CPU scores 1 point and the ball resets in the CPU's direction (ball.vx = -5).
- **Serve delay:** After a score, freeze the ball at the center for 60 frames before launching it.

---

## Game States

The game has exactly three states: **menu**, **playing**, and **gameover**.

**Menu state:** Show the court and dashed line. Show "PONG" as the centered title at canvas_height × 0.35. Show "Press SPACE or tap to start" as the pulsing subtitle at canvas_height × 0.55. Score is hidden in menu state.

**Playing state:** Normal gameplay. Both paddles are visible. Score increments as described above. Game continues until either player or CPU reaches 7 points.

**Gameover state:** Show a semi-transparent dark overlay (rgba(0, 0, 0, 0.6)) on top of the final frame. Show "YOU WIN!" (if player ≥ 7) or "CPU WINS" (if CPU ≥ 7) as the centered title in green (#39ff14) for a win or red (#ff3939) for a loss, at canvas_height × 0.35. Show the final score below the title in 32px white. Show "Press SPACE or tap to play again" as the pulsing subtitle at canvas_height × 0.65. Pressing SPACE or tapping restarts the game with both scores reset to 0 and the ball serving toward the loser of the previous match.

---

## Audio

Synthesize all sounds using the Web Audio API. Do not load any audio files.

- **Paddle hit sound:** A short (60ms) square wave tone at 440Hz, quickly fading to silence. Triggered when the ball hits either paddle.
- **Wall hit sound:** A short (50ms) sine wave tone at 220Hz, quickly fading to silence. Triggered when the ball hits the top or bottom wall.
- **Score sound:** A descending two-tone chirp — 880Hz for 80ms, then 440Hz for 80ms. Triggered when either player scores.
- **Win sound:** An ascending three-tone fanfare — 523Hz (C5), 659Hz (E5), 784Hz (G5), each for 120ms. Triggered when the gameover state is entered.

Create the AudioContext lazily on the first user interaction to comply with browser autoplay policies.

---

## Controls

- **Keyboard:** Up Arrow or W moves the player paddle up. Down Arrow or S moves the player paddle down. Spacebar starts or restarts the game.
- **Touch / mouse:** Tapping or clicking on the upper half of the canvas moves the player paddle up by a continuous press; tapping or clicking on the lower half moves it down. Releasing the input stops the movement. Tapping anywhere also starts or restarts the game when not in the playing state.

All input methods should work simultaneously. Do not prevent default touch behavior on the page itself — only prevent default on the canvas touch events to avoid scroll-triggering.

---

## Technical Requirements

- The entire game must be contained in one `.html` file.
- No `<script src="...">`, no `<link rel="stylesheet" href="...">`, no `fetch()`, no `import`.
- The game must work when opened via `file://` protocol (no CORS issues).
- Use `'use strict'` in the JavaScript.
- Organize the JavaScript with clearly labeled sections: constants, state, audio, drawing functions, physics functions, input handling, game loop.
- The game loop must use `requestAnimationFrame` and track a frame counter (integer, incrementing each frame) as the primary timing source for the serve delay and the subtitle opacity pulse — not wall-clock time.
- The canvas should respond to window resize: on resize, recalculate a `scale` factor to fit the canvas within the window while maintaining the 800×500 aspect ratio. Apply the scale via CSS `transform: scale()` on the canvas element. Do not change the internal canvas resolution — keep it at 800×500 always.

---

## Deliverable

Output the complete, ready-to-run HTML file. The file should work without modification when saved as `pong.html` and opened in Chrome, Firefox, or Safari. Include a brief HTML comment at the top with the approximate line count and a list of the major sections.
