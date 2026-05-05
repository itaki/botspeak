# BOTSPEAK Evals

Two experiments that test whether BOTSPEAK actually works.

---

## 1. Round-Trip Fidelity (`round-trip/`)

**The question:** Does BOTSPEAK drift like a telephone game, or does it converge and stabilize?

**The test:** Compress a document into BOTSPEAK, translate it back to prose, compress again, translate again — repeat N times. Compare the first version to the last.

**What we expect:** The document should stabilize after 2-3 iterations. The first compress cuts heavily. Translate adds back prose structure. Second compress is nearly identical to the first because there's little left to remove. After that it flatlines. That convergence is the proof that BOTSPEAK is lossless.

**Run it:**

```bash
# requires claude CLI with /botspeak and /translate-botspeak skills installed
./round-trip/run.sh game-prompt/source.md 10
```

Outputs one file per iteration to `round-trip/results/` plus a CSV of word counts at each step. Visually, word count should look like a sawtooth wave (compress drops, translate rises) with the valleys getting shallower each cycle until they flatline.

---

## 2. Functional Equivalence — The Flappy Bird Test (`game-prompt/`)

**The question:** Does an AI produce the same working software from a BOTSPEAK-compressed prompt as from the original prose prompt?

**The source:** `game-prompt/source.md` is a 900-word, fully-specified one-shot prompt for a complete Flappy Bird game in a single HTML file. It specifies exact physics values, visual design, game states, audio synthesis, collision margins, and technical requirements. This level of specificity is necessary — a vague prompt would let the AI fill in gaps differently each run, making the comparison meaningless.

**The test:**
1. Run the original `source.md` → get `game-prompt/results/flappy-prose.html`
2. Run `/botspeak` on `source.md` → get `game-prompt/source-botspeak.md`
3. Run `source-botspeak.md` through the AI → get `game-prompt/results/flappy-botspeak.html`
4. Compare: do both games run? Do they share the same physics, controls, visual design, and behavior?

**What to look for:**
- Both files open in a browser and produce a playable game
- Gravity (0.5px/frame²), flap velocity (-9px/frame), pipe speed (3px/frame) match in both
- Pipe gap (150px), forgiveness margin (4px), pipe spawn interval (90 frames) match
- Game states (menu/playing/dying/gameover) present in both
- LocalStorage best score present in both
- Web Audio API sounds present in both
- Visual design (canvas size 480×640, ground, clouds, particle effects) match

**The hypothesis:** A sufficiently specific prompt is functionally equivalent in BOTSPEAK and prose form. The AI extracts the same constraints from structured notation as from verbose sentences.

**Run it:**

```bash
# Step 1: build from prose
claude --print "$(cat game-prompt/source.md)" > game-prompt/results/flappy-prose.html

# Step 2: compress the prompt
claude --print "/botspeak $(cat game-prompt/source.md)" > game-prompt/source-botspeak.md

# Step 3: build from BOTSPEAK
claude --print "$(cat game-prompt/source-botspeak.md)" > game-prompt/results/flappy-botspeak.html

# Step 4: open both
open game-prompt/results/flappy-prose.html
open game-prompt/results/flappy-botspeak.html
```

---

## Why Flappy Bird?

- **Binary pass/fail:** the game either runs or it doesn't.
- **Specific physics:** exact numbers (gravity, velocity, gap size) make the outputs directly comparable without subjective judgment.
- **Visual:** side-by-side screenshots are immediately convincing to anyone skeptical about BOTSPEAK.
- **Shareable:** a working `.html` file can be dropped anywhere online without a build step.
- **Well-understood:** every developer knows what Flappy Bird is supposed to feel like.

---

## Results So Far

**Round-trip iteration 1 (manual, acted as /botspeak):**

| | Words |
|---|---|
| `source.md` (original prose) | 1,415 |
| `source-botspeak-iter1.md` (BOTSPEAK) | 614 |
| **Reduction** | **57%** |

All exact values preserved verbatim: every hex color, every pixel dimension, every Hz value, every frame count. See `game-prompt/source-botspeak-iter1.md`.

The working game (built from the prose spec): `game-prompt/results/flappy-prose.html` — open it in any browser.

---

## Contributing Results

If you run these evals, open a PR with your results in `game-prompt/results/` and `round-trip/results/`. Include:
- Which model you used
- Word count at each round-trip iteration (paste the CSV)
- Whether both Flappy Bird versions ran successfully
- Any behavioral differences you noticed between the prose and BOTSPEAK builds
