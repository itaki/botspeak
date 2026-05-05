# One-Shot Flappy Bird — Full Specification Prompt

Build a complete, playable Flappy Bird clone in a single self-contained HTML file with no external dependencies of any kind. The game must run by opening the file directly in any modern browser without a local server. Do not use any external images, fonts, audio files, or JavaScript libraries. Everything — graphics, physics, sounds, UI — must be generated programmatically in the file itself.

---

## Visual Design

Draw everything on an HTML5 canvas element using the 2D canvas API. Do not use SVG, DOM elements, or CSS animations for game objects.

The canvas should be 480 pixels wide and 640 pixels tall, centered horizontally on the page. The page background behind the canvas should be a dark color (#1a1a2e). The canvas should have a subtle box-shadow to make it feel like a screen.

**Sky and background:** Draw a gradient sky that transitions from a deep blue (#0f3460) at the top to a lighter blue (#16213e) at the bottom. Add a layer of distant, slowly-scrolling clouds: small white ellipses with slight transparency, moving at one-quarter the speed of the pipes. Add a scrolling ground strip at the very bottom of the canvas — a green rectangle (40 pixels tall, color #2d5a27) with a thin yellow stripe at the top edge (#8fbc45). The ground scrolls at the same speed as the pipes.

**The bird:** Draw the bird as a yellow circle (radius 14 pixels) with a dark eye (radius 4 pixels, positioned upper-right), an orange triangular beak pointing right, and two wing shapes — a slightly darker yellow ellipse on the left side of the body that animates up and down at 8 frames per flap cycle. The bird rotates to match its velocity: nose down when falling, nose up briefly after a flap. Clamp the rotation between -30 degrees (nose up) and 90 degrees (nose straight down). The bird's horizontal position is fixed at 20% from the left edge of the canvas.

**Pipes:** Draw pipes as pairs — one from the top of the canvas downward, one from the bottom of the canvas upward — with a gap of 150 pixels between them. The gap position is randomized vertically between 20% and 75% of the canvas height. Pipes are 60 pixels wide. Draw the pipe body as a dark green rectangle (#2d6a4f) with a lighter green highlight stripe (#40916c) along the left edge (8 pixels wide). Draw a pipe cap — a slightly wider rectangle (70 pixels wide, 20 pixels tall) at the open end of each pipe, same color scheme with a highlight. Pipes enter from the right edge and move left at a constant speed.

**Score display:** Show the current score as a large white number centered horizontally near the top of the canvas (40 pixels from top), with a dark semi-transparent rectangle behind it for legibility. Use a bold sans-serif font at 48px. Show the best score in the top-right corner at 20px.

**Particle effects:** When the bird dies (collides with a pipe or the ground), emit 20 particles from the bird's position. Each particle should be a small circle (radius 3-6px, random), a random warm color (yellows, oranges, reds), with an initial velocity in a random direction at a random speed (2-6px per frame), and gravity applied to each particle at the same rate as the bird. Particles fade out over 40 frames and then disappear. Do not restart the game until all particles have finished their animation.

---

## Physics

Use a fixed timestep physics loop driven by `requestAnimationFrame`. Cap the delta time to prevent physics explosions if the tab loses focus.

- **Gravity:** Apply 0.5 pixels per frame squared downward acceleration to the bird's vertical velocity on every frame while the game state is "playing".
- **Flap velocity:** When the player flaps, set the bird's vertical velocity to -9 pixels per frame (upward). Do not allow flapping when the game state is not "playing".
- **Terminal velocity:** Cap the bird's downward velocity at 12 pixels per frame.
- **Pipe speed:** Pipes move left at 3 pixels per frame. Do not change the pipe speed as the score increases.
- **Pipe spawn interval:** Spawn a new pipe pair every 90 frames. The first pipe spawns 120 frames after the game enters "playing" state.
- **Collision detection:** Use circle-rectangle collision for pipe bodies and pipe caps. Use circle-rectangle collision for the ground. Add a 4-pixel forgiveness margin to all collisions — shrink the effective collision box by 4 pixels on each side to make the game feel fair.

---

## Game States

The game has exactly four states: **menu**, **playing**, **dying**, and **gameover**.

**Menu state:** Show the background, ground, and clouds scrolling continuously. Show the bird bobbing gently up and down in the center of the canvas (a sine wave oscillation, amplitude 8 pixels, period 60 frames). Show the game title "FLAPPY BIRD" in large white bold text, centered, at 40% canvas height. Below it, show "Press SPACE or tap to start" in smaller text, pulsing in opacity (0.4 to 1.0, period 60 frames).

**Playing state:** Normal gameplay. Score increments by 1 each time the bird's horizontal center passes the right edge of a pipe pair. Play a short synthesized "point" sound effect on each score increment.

**Dying state:** Triggered the moment a collision is detected. The bird stops moving horizontally. Gravity continues to apply. Play a synthesized "hit" sound effect. Run the particle animation. Transition to "gameover" state after the particle animation completes and the bird has landed on the ground or passed the bottom of the canvas.

**Gameover state:** Show a semi-transparent dark overlay on top of the stopped game scene. Show a "GAME OVER" panel in the center with: the final score, the best score (persisted to localStorage), and a "Press SPACE or tap to restart" prompt. If the player achieved a new best score, show a "NEW BEST!" badge in gold. Pressing SPACE or tapping restarts immediately into "playing" state, resetting the bird position, clearing all pipes, and resetting the score to zero. Do not go back to menu — always restart directly into playing.

---

## Audio

Synthesize all sounds using the Web Audio API. Do not load any audio files.

- **Flap sound:** A short (80ms) sine wave tone at 520Hz, quickly fading from full volume to silence. Triggered on each flap.
- **Point sound:** A short (100ms) ascending two-tone chirp: 660Hz for 50ms, then 880Hz for 50ms. Triggered each time a pipe is passed.
- **Hit sound:** A short (150ms) burst of white noise, quickly fading to silence. Triggered on collision.
- **Die sound:** A descending tone from 400Hz to 200Hz over 300ms. Triggered 100ms after the hit sound.

Create the AudioContext lazily on the first user interaction to comply with browser autoplay policies.

---

## Controls

- **Keyboard:** Spacebar causes a flap. No other keyboard inputs are used.
- **Touch:** A tap anywhere on the canvas causes a flap.
- **Mouse:** A left-click anywhere on the canvas causes a flap.

All three input methods should work simultaneously. Do not prevent default touch behavior on the page itself — only prevent default on the canvas touch events to avoid scroll-triggering.

---

## Technical Requirements

- The entire game must be contained in one `.html` file.
- No `<script src="...">`, no `<link rel="stylesheet" href="...">`, no `fetch()`, no `import`.
- The game must work when opened via `file://` protocol (no CORS issues).
- Use `'use strict'` in the JavaScript.
- Organize the JavaScript with clearly labeled sections: constants, state, audio, drawing functions, physics functions, input handling, game loop.
- The game loop must use `requestAnimationFrame` and track a frame counter (integer, incrementing each frame) as the primary timing source for spawning and animation, not wall-clock time.
- Store the best score in `localStorage` under the key `flappyBirdBest`. Read it on page load. Update it immediately when a new best is achieved.
- The canvas should respond to window resize: on resize, recalculate a `scale` factor to fit the canvas within the window while maintaining the 480×640 aspect ratio. Apply the scale via CSS `transform: scale()` on the canvas element. Do not change the internal canvas resolution — keep it at 480×640 always.

---

## Deliverable

Output the complete, ready-to-run HTML file. The file should work without modification when saved as `flappy-bird.html` and opened in Chrome, Firefox, or Safari. Include a brief HTML comment at the top with the approximate line count and a list of the major sections.
