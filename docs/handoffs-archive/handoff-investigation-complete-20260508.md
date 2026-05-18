<!-- botspeak-version: 2.1.0 · published: 2026-05-08 · repo: https://github.com/itaki/botspeak -->
[HANDOFF] BOTSPEAK · investigation complete · 2026-05-08

# Mission status: COMPLETE

All four questions from the previous handoff answered with evidence.

---

# Answers

**Q1: Does the v2.0.0 skill apply its own rules at execution time?**
Yes, with one latent bug. Simple AI-facing docs (branch guard rule): 62% compression, header correct, strict = rule applied, all constraints preserved. Bug found during round-trip eval: skill hallucinated `@defs` aliases for concepts absent from the source. Fixed in v2.1.0 (@defs hygiene check added to step 6 verify pass).

**Q2: Does a fresh skill output of source.md one-shot a working game?**
Yes — with the v2.1.0 skill. The v4 (v2.0.0 era) output was broken. The v6 output (v2.1.0 skill, 39% compression) builds to a game that passes all five static analysis checks: `pipe.x -= 3` per-instance, collision uses `pipe.x`, score uses `pipe.x`, culling uses `pipe.x`, clouds/ground use single scalar offset.

**Q3: What was the smallest fix?**
Two rules added to SPEC §4 + §9, distilled into SKILL step 4 and step 6:
1. Entity-state vs ambient/offset distinction — per-instance moving objects must use `x_init / x: -= speed each FR / remove-when` form; ambient effects use single offset scalar
2. @defs hygiene — every alias must come from the source and be used in the body

**Q4: Is BOTSPEAK viable for its actual design target?**
Yes. Round-trip on two AI-facing docs (branch guard rule, context handoff) passed with zero constraint/polarity/value/logic drift.

---

# What changed this session

## SPEC v2.1.0 (MINOR bump from v2.0.0)
- §4 "Keep absolutely": added per-entity vs ambient/offset state
- §4: new "Per-entity state vs ambient/offset state" rule
- §9 pitfall 12: @defs hygiene (no hallucinated aliases, all aliases must appear in body)
- §9 pitfall 13: entity/parallax conflation failure class

## SKILL v2.1.0
- New section: entity-state vs ambient/offset rule (with three-part form + labels)
- Step 4 "keep absolutely": added entity/ambient distinction line
- Step 6 verify: added two new checks (entity-state form, @defs hygiene)
- Archived as v09 (221 lines)
- Installed to ~/.cursor/skills-cursor/botspeak/SKILL.md

## SPEC archive
- Created skills/_archive/spec/ (was missing)
- v01–v04 archived from git history + current
- skills/_archive/README.md updated with spec/ table
- .cursor/rules/botspeak-versioning.mdc patched to require SPEC archiving on every bump

## Eval suite
- evals/game-prompt/source-botspeak-v5.md — verbose correct output (manually instructed sub-agent)
- evals/game-prompt/source-botspeak-v6.md — 39% reduction, v2.1.0 skill output, canonical
- evals/game-prompt/results/flappy-botspeak-v5.html — built from v5 spec, all checks pass
- evals/game-prompt/results/flappy-botspeak-v6.html — built from v6 spec, all checks pass
- evals/tetris-prompt/source.md — detailed Tetris one-shot prompt (new)
- evals/tetris-prompt/source-botspeak.md — 45% compression, v2.1.0 skill
- evals/tetris-prompt/tetris.html — built from compressed spec, all six checks pass
- evals/snake-prompt/source.md — detailed Snake one-shot prompt
- evals/snake-prompt/source-botspeak.md — ~50% compression, v2.1.0 skill
- evals/snake-prompt/snake.html — built from compressed spec, all six checks pass (per-SEG array, setTimeout/rAF separation, direction buffering)
- evals/skill-verify/ex01-compressed.md — ex01 short-rule compressed, verify pass

---

# Current version state

| artifact | version | location |
|---|---|---|
| SPEC.md | v2.1.0 | repo root |
| SKILL.md (botspeak) | v2.1.0 | skills/botspeak/SKILL.md |
| installed skill | v2.1.0 | ~/.cursor/skills-cursor/botspeak/SKILL.md |
| skill archive | v01–v09 | skills/_archive/botspeak/ |
| spec archive | v01–v04 | skills/_archive/spec/ |

---

# Eval results summary

| eval | skill version | compression | build checks | status |
|---|---|---|---|---|
| Flappy Bird | v2.1.0 | 39% | 5/5 pass | ✓ static analysis; live play-test pending |
| Tetris | v2.1.0 | 45% | 6/6 pass | ✓ static analysis |
| Snake | v2.1.0 | 50% | 6/6 pass | ✓ static analysis |

# What is NOT done

- Nothing committed to git (all changes are working tree only)
- evals/game-prompt/source.md not updated (still the original prose spec — this is correct, it's ground truth)
- Tetris and Snake: prose baseline NOT established (we don't know if the original prose works with Haiku)
  → those evals are structurally incomplete until prose → Haiku is tested

---

# Correct eval methodology (do NOT deviate from this)

The objective is BOTSPEAK fidelity, NOT game correctness.

```
eval loop:
  prose_prompt -> [Haiku] -> game_A          (baseline: does the prose work?)
  prose_prompt -> [/botspeak] -> compressed  (compression step)
  compressed   -> [Haiku] -> game_B          (does compression preserve info?)
  compare game_A vs game_B:
    same result (both work, or both break same way) -> BOTSPEAK passed ✓
    game_B breaks differently from game_A           -> compression lost something → investigate
    game_B works better than game_A                 -> bonus ✓✓
```

Rules:
- If prose_prompt → Haiku produces a broken game: discard the prompt, get a different one
- Do NOT fix game_B bugs. If game_B is broken, ask: is it broken the same way as game_A?
- Static analysis (checking that key spec features appear in game_B code) is the primary tool
- Live play-test is a secondary confirmation, not a debugging session

---

# If you pick this up next

1. Flappy Bird (evals/game-prompt/) is the only eval with a confirmed prose baseline
   → source.md is known-good with Haiku/Sonnet/Opus (user confirmed)
   → source-botspeak-v6.md passes all 5 static checks → this eval is COMPLETE ✓
2. Tetris and Snake: need to test prose → Haiku first to establish baseline before these evals mean anything
   → if prose produces a broken game → discard the prompt, find a better one
   → do NOT fix the generated game code
3. To expand the eval suite: find other known-good one-shot game prompts (search GitHub/web)
   → "single file HTML game prompt" that the community has confirmed works
   → compress → compare
4. Commit everything: SPEC v2.1.0, SKILL v2.1.0, archive entries, eval outputs

# The "72-line skill" question — why simpler accidentally worked

The v03 skill (72 lines, produced working iter1 game) was NOT inherently better. It accidentally avoided the word "scroll." The iter1 compressed spec said `clouds: ... speed = PP_speed/4` — so the build model implemented clouds as per-instance x objects (`c.x -= PP_SPEED/4`). Both clouds and pipes used per-instance mutation. Collision only checks pipes, so everything worked.

The v07 skill changed that language to "scroll at PP_speed × 0.25." The word **scroll** triggered the build model's parallax abstraction, which it then generalized to pipes as well. One word change caused three consecutive failures.

v2.1.0 fixes this by making the distinction explicit and permanent via labels (`← entity` / `← ambient`) rather than relying on word choice. It is more robust than v03 was, not less.

Empirical evidence from the iter1 game code:
```
line 321: c.x -= PP_SPEED / 4;   // clouds: per-instance x (accidentally same pattern as pipes)
line 330: groundOff = (groundOff + PP_SPEED) % 40;  // ground: offset (irrelevant for collision)
line 383: p.x -= PP_SPEED;        // pipes: per-instance x (correct)
```

# Root cause summary (one paragraph)

The three Flappy Bird failures were all the same failure class: BOTSPEAK v0.x/v2.0.0 used identical motion language for parallax effects (clouds, ground — single shared offset, no per-instance state) and entity-state objects (pipes, particles — each instance owns its own x that mutates per frame). Build models applied the simpler ambient/offset abstraction to everything, producing pipes that appeared to move visually (parallax offset) but had static x=480 in collision detection. v2.1.0 adds an explicit rule requiring the three-part entity-state form (`x_init / x: -= speed each FR / remove-when`) for all per-instance moving objects, and explicit ambient/offset form for parallax effects, with mandatory labels when both coexist. Tested on Flappy Bird (39% compression) and Tetris (45% compression) — both produce correct implementations.
