# BOTSPEAK Evals

Two evidence signals gate every BOTSPEAK release: round-trip fidelity and game synthesis. This directory holds the canonical sources, the v2.2.0 outputs, and the reproducibility scripts.

For the live side-by-side rendering of every game, open [`../showcase/index.html`](../showcase/index.html).

---

## Headline results (v2.2.0)

**Round-trip fidelity** — compress a real AI-facing document, then audit. Six in-repo examples, all **PASS**:

| # | doc | result |
|---|---|---|
| 01 | short rule | PASS |
| 02 | context handoff | PASS |
| 03 | memory page | PASS |
| 04 | philosophy rule | PASS |
| 05 | CLAUDE.md (code-heavy) | PASS |
| 06 | migration spec (code-heavy) | PASS |

**6 / 6 PASS.** Three additional external real-world docs in `external-prompts/` also pass. Full table and methodology: [`round-trip-results.md`](round-trip-results.md).

**Game synthesis** — give a fresh model only the BOTSPEAK-compressed prompt; have it build a working game; compare physics constants to the prose-built version.

| game | compression | constants matched | parity report |
|---|---|---|---|
| Flappy Bird | 31% | 15 / 15 | [`game-prompt/parity-report.md`](game-prompt/parity-report.md) |
| Snake | 35% | 10 / 10 | [`snake-prompt/parity-report.md`](snake-prompt/parity-report.md) |
| Pong | 39% | 14 / 14 | [`pong-prompt/parity-report.md`](pong-prompt/parity-report.md) |
| Breakout | 44% | 21 / 21 | [`breakout-prompt/parity-report.md`](breakout-prompt/parity-report.md) |

---

## What's in this directory

```
evals/
├── README.md                    ← you are here
├── round-trip-results.md        ← canonical round-trip eval (v2.2.0)
├── external-prompts/            ← 3 real-world AI-facing docs as round-trip sources
├── game-prompt/                 ← Flappy Bird (prose + BOTSPEAK + parity)
├── snake-prompt/                ← Snake
├── pong-prompt/                 ← Pong
├── breakout-prompt/             ← Breakout
├── round-trip/                  ← N-iteration round-trip reproducibility framework
└── _deferred/                   ← games not in the v2.2.0 showcase (e.g. Tetris)
```

Each `{game}-prompt/` directory contains:

- `source.md` — the original prose specification
- `source-botspeak-v22.md` — the v2.2.0 BOTSPEAK compression
- `results/prose-sonnet.html` — clean-room build from the prose
- `results/botspeak-sonnet-v22.html` — clean-room build from the BOTSPEAK
- `parity-report.md` — physics-constant diff between the two HTML builds

All builds were done by fresh `generalPurpose` subagents with no shared context. Each subagent received only its declared inputs (the source file plus, for compressions, the v2.2.0 skill). The compression subagent never saw the build subagent's output, and vice versa.

---

## Reproduce any result

### Round-trip a single doc

```bash
# requires claude CLI with /botspeak and /botspeak-translate installed
/botspeak @examples/05-aliased-claude-md/before.md  # writes after.md
/botspeak-translate @examples/05-aliased-claude-md/after.md  # writes .bst.md
diff examples/05-aliased-claude-md/before.md examples/05-aliased-claude-md/after.bst.md
```

### Re-run the iteration framework

```bash
# requires claude CLI authenticated; reproduces the N-pass convergence test
./round-trip/run.sh game-prompt/source.md 5
```

Output goes to `round-trip/results/` with one file per half-iteration plus a CSV of word counts. The expected pattern is a sawtooth wave (compress drops, translate rises) with the valleys getting shallower until they flatline — that flatline is the proof that BOTSPEAK is lossless.

### Re-build a game from the BOTSPEAK source

```bash
# Step 1: build from prose
claude --print "$(cat game-prompt/source.md)" > game-prompt/results/prose-{your-model}.html

# Step 2: build from BOTSPEAK
claude --print "$(cat game-prompt/source-botspeak-v22.md)" > game-prompt/results/botspeak-{your-model}.html

# Step 3: open both
open game-prompt/results/*.html
```

Compare the two HTML files: physics constants, render order, audio synthesis, state machine. The parity reports in each game directory document exactly what to look for.

---

## Why these games

- **Pong** is the Tier 1 canary. Simplest physics in the suite — if BOTSPEAK ever fails on Pong, compression is too aggressive.
- **Snake** tests grid logic and input-buffer rules — small details a sloppy compression could lose.
- **Flappy Bird** stress-tests entity-state preservation. Each pipe carries per-instance state (passed-flag, gap-center, x-position) that must survive compression intact — easy to conflate with ambient/parallax offset.
- **Breakout** combines physics with grid data structures — per-row color array, per-row score array, edge-detection collision — testing whether compression preserves both numeric constants and structured tables.

Other candidates (Asteroids, Minesweeper, 2048, Space Invaders) are documented in `docs/internal/v2.2.0-candidate-prompts.md` for a future hard-suite eval.

---

## Contributing results

If you run these evals against a different model — Haiku, Opus, GPT, Gemini, Llama — open a PR with your results in the appropriate `results/` subdirectory. Include:

- which model and version
- which prompt (prose or BOTSPEAK or both)
- whether the game ran successfully
- any behavioral differences you noticed against the Sonnet baseline

The whole point of the eval suite is to let the BOTSPEAK claim be tested by someone other than the people who wrote it.
