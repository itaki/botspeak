<!-- botspeak-version: 2.0.0 · published: 2026-05-07 · repo: https://github.com/itaki/botspeak -->
[HANDOFF] BOTSPEAK · regression investigation · 2026-05-07

# Mission

Finish the versioning system (SPEC archive is the only piece left), then investigate why a BOTSPEAK-compressed Flappy Bird spec produces a broken game even on Sonnet, while the same prose spec works on Haiku. The investigation must be evidence-driven and end with a verdict on whether BOTSPEAK is viable for AI-facing rule/skill/handoff docs (its actual design target) — independent of whether it can carry game synthesis.

**Do not harden, tighten, or extend the skill until the diagnostic chain below has been walked through. We have a history of adding rules in response to single failures and creating new failures elsewhere. Stop the reflex.**

---

# Background you need

## What BOTSPEAK is

A notation for compressing AI-facing prose docs (Cursor rules, Claude skills, CLAUDE.md, agent handoffs, memory pages) into a denser symbolic form. Repo at `/Users/michaelmcreynolds/Dropbox/BOTSPEAK`. The product is the language + a `/botspeak` skill that compresses prose into BOTSPEAK + a `/botspeak-translate` skill that renders BOTSPEAK back to prose for human audit.

Per `CLAUDE.md`, the design target is AI-facing rule/skill/handoff docs — **not** one-shot game synthesis. Game synthesis is being used as a stress-test eval; a failure there does not by itself invalidate the language. But three failures across three skill versions does indicate a real problem worth understanding.

## Read these to understand the language

- `SPEC.md` — language spec, currently at v2.0.0
- `skills/botspeak/SKILL.md` — compression skill, currently at v2.0.0
- `skills/botspeak-translate/SKILL.md` — translation skill (BOTSPEAK → prose)
- `skills/_archive/README.md` — version table for both skills
- `.cursor/rules/botspeak-versioning.mdc` — versioning + publish protocol
- `examples/01-short-rule/` through `examples/06-backend-migration/` — six before/after pairs

---

# Current state of the versioning system

| Artifact | Location | Version | Status |
|---|---|---|---|
| SPEC.md | repo root | v2.0.0 | done |
| SPEC metadata header | SPEC.md line 3 | v2.0.0 | done |
| SKILL.md (botspeak) | `skills/botspeak/SKILL.md` | v2.0.0 | done |
| SKILL metadata header | SKILL.md line 6 | v2.0.0 | done |
| SKILL step 7 format string | inside SKILL.md | v2.0.0 | done |
| Installed skill copy | `~/.cursor/skills-cursor/botspeak/SKILL.md` | v2.0.0 | done, matches repo (`diff -q` confirms) |
| Versioning protocol rule | `.cursor/rules/botspeak-versioning.mdc` | v1 | done |
| Skill archive | `skills/_archive/botspeak/v01–v08.md` | 8 versions | done |
| Skill archive table | `skills/_archive/README.md` | up to v08 | done |
| **SPEC archive** | **does not exist** | **n/a** | **MISSING** |

## Mission step 1 — finish the versioning system

Create the SPEC archive parallel to the skill archive. Suggested:

- Directory: `skills/_archive/spec/` (kept under `skills/_archive/` for consistency with the existing structure; alternative is a new top-level `_archive/spec/` but `_archive/` at root is already used for old example archives).
- Naming convention: same as skill archive — `<seq>-<YYYYMMDD>-<lines>L-<short-tag>.md`.
- Seed the archive with prior SPEC versions from git history. Get the commit log with `git log --pretty=format:"%h | %ad | %s" --date=short -- SPEC.md` and extract each blob with `git show <hash>:SPEC.md > skills/_archive/spec/<filename>`.
- Mark anything before the v2.0.0 bump as "pre-semver" in the filename or table; v2.0.0 forward uses semver.
- Add a `## spec/` table to `skills/_archive/README.md` matching the skill table format.
- Update `.cursor/rules/botspeak-versioning.mdc` to require archiving SPEC.md on every version bump (currently it covers SKILL archiving but not SPEC archiving — verify this and patch if needed).

After this, the user should be able to confirm any compressed BOTSPEAK output's metadata header (`<!-- BOTSPEAK v2.0.0 · compressed by claude-haiku-4 · 2026-05-07 -->`) traces back to:
- An exact SPEC.md snapshot in `skills/_archive/spec/`
- An exact SKILL.md snapshot in `skills/_archive/botspeak/`

That trace is the foundation for everything that follows.

---

# The regression — what we know, what we don't

## The eval

Compress `evals/game-prompt/source.md` (Flappy Bird prose spec, 90 lines, 1415 words) into BOTSPEAK using the `/botspeak` skill, then ask an LLM to one-shot a working HTML5 Flappy Bird from each version. Compare the resulting `flappy-prose.html` and `flappy-botspeak.html`.

## Confirmed failures

| Iteration | Skill version | Build model | Result |
|---|---|---|---|
| v1 (iter1) | v03 (72-line, archived) | Haiku | **works** — `evals/game-prompt/archive-v1-20260505/source-botspeak-iter1.md` |
| v2 | v07 (339-line, archived) | Haiku | broken (pipes appear late, then never) |
| v3 | v07 (339-line, archived) | Haiku | broken (same bug) |
| v4 | v08 / v2.0.0 (200-line, current) | Haiku | broken (same bug) |
| v4 | v08 / v2.0.0 (200-line, current) | **Sonnet** | **broken** (same bug) |

The Sonnet result is critical: it rules out Haiku-ceiling as the dominant cause. The bug is in the compression pipeline, not the build pipeline.

## The bug, exactly

`evals/game-prompt/results/flappy-botspeak.html` is the broken artifact.

- Pipes spawn at fixed `x = CV.w` (480) on line 266: `pipes.push({ x: CV.w, y: gy });`
- There is no `p.x +=` or `p.x -=` for pipes anywhere in the file (the only `p.x +=` on line 254 is for *particles*).
- The renderer offsets each pipe visually by `fr * pipeSpd` (line 199): `const px = p.x - off * PHYS.pipeSpd;`
- Collision (line 281) uses static `p.x = 480`. Bird is at `x = 96`. Bird never reaches pipes. **Collision is mathematically impossible.**
- Score (line 294) uses static `p.x + PIPE.w`. Never fires.
- Culling (line 272) checks `p.x + PIPE.w > 0`. Static 480, never culled. Pipes accumulate forever; spawn timer keeps ticking.

The build model conflated *parallax* (background scroll, no per-instance state) with *entity motion* (per-pipe `x` state that mutates each frame). It used the parallax pattern for everything.

`flappy-prose.html` does the same game correctly (`p.x` mutates per frame, collision and score work). Same model, same task, different input format.

## Full audit

`evals/game-prompt/audit-2026-05-07-v4-failure.md` — 479 lines of line-by-line analysis. Verdict was:

- **C primary** (compression-class hazard) — BOTSPEAK can express this (iter1 proves it) but the current skill produces output where parallax and entity motion are syntactically indistinguishable
- **A secondary** (skill bug) — the current v2.0.0 skill failed to apply its own strict-`=` rule on at least 5 lines of v4
- **D tertiary** (Haiku ceiling) — **NOW LARGELY RULED OUT** by the Sonnet retest

If the audit interests you, read it before forming your own. If you'd rather form an independent take first, audit yourself, then compare.

## What the iter1 vs v4 diff says

iter1 (working) used distinct constructs for parallax and entity motion — there's a literal `p.x -= PP_SPEED;` in the iter1-generated game. v4 (broken) uses bullet shapes that look syntactically identical for clouds, ground, and pipes. The build model built one motion abstraction and applied it to all three. The diff between iter1 and v4 is where the regression lives.

---

# User's open hypotheses (untested)

These are the user's working theories. Treat them as hypotheses to test, not conclusions:

**H1 — Source-doc clarity.** Maybe `source.md` (the prose spec) is itself ambiguous about per-entity vs. ambient motion, and prose works only because the build model has enough latent Flappy Bird knowledge to fill the gap. Compression strips the latitude for the model to fill gaps, so it follows the doc more literally. **Test:** compress a *clearer*, more explicit version of `source.md` and see if BOTSPEAK output works on Haiku. If yes, the source was the bottleneck.

**H2 — Compressed-as-literal.** Models read prose as advisory ("the user means…") and BOTSPEAK as commanding ("execute this exactly"). Compression therefore shifts the failure mode from "creative interpretation" (sometimes wrong but usually OK) to "literal execution" (only works if every constraint is explicit). **Test:** ask the model to "use your judgment to fill gaps" alongside the BOTSPEAK input and see if behavior changes.

**H3 — Loosyity factor.** The skill should encourage dropping into prose for irreducibly complex passages, not just for "any phrase that could be read two ways." Currently SPEC §0 Tenet 1 says "when in doubt, write it long" but the skill's procedure doesn't operationalize this for *structurally* complex sections (multi-state-variable interactions). **Test:** add a rule "if a section involves multiple coupled state variables → keep that section in prose" and recompress.

**H4 — The current skill doesn't apply its own rules.** Independent of the above, the audit found 5+ strict-`=` violations in v4 — i.e., the skill's verify pass either didn't run or didn't enforce its own rule. **Test:** compress a tiny doc with a deliberate strict-`=` violation in the source. Does the output preserve the violation, or fix it? If preserved, the verify pass is broken at execution time.

---

# Recommended diagnostic chain (run these IN ORDER)

The order matters. Each step's result determines whether the next step is needed.

## Step 0 — Finish the SPEC archive (mission step 1 above)

Without SPEC archives, every "did this work" answer is contaminated by ambiguity about which skill / spec produced the output. Do this first.

## Step 1 — Verify the installed skill applies its own rules

Pick a small AI-facing doc (any of `examples/01-short-rule/before.md` works) and run it through `/botspeak`. Manually verify:
- Output starts with `<!-- BOTSPEAK v2.0.0 · compressed by [model] · 2026-05-07 -->` (the metadata header is required by step 7)
- Every `=` line in the output has a value RHS, not a descriptive RHS
- No undefined aliases, no collisions, no missed substitutions

If the skill fails its own verify pass on a *simple* doc, debugging is at the skill-execution level, not at the language level. Stop and fix that first.

## Step 2 — Recompress source.md with the v2.0.0 skill, fresh

The current `source-botspeak-v4.md` was compressed *before* the v2.0.0 bump (its metadata header says `v0.2.0`). Discard it. Recompress `source.md` with the v2.0.0 skill installed, save as `source-botspeak-v5.md` with the correct `v2.0.0` metadata header. Run it through Haiku and Sonnet.

If the v2.0.0 skill produces output that works → the regression was in the older skill, the new skill fixes it, ship it.

If it still fails → continue to step 3.

## Step 3 — Hand-edit the v5 output to add the entity-state distinction

The audit prescribes: for any object with per-frame mutating state, declare `init / per-FR / remove-when` explicitly. Background offsets without per-instance state may use the parallax form. Hand-edit v5 to apply this manually for pipes, save as `source-botspeak-v5-handfix.md`, run it through Haiku.

If the hand-edit works → verdict is A (skill bug, missing rule). The fix is to add the entity-state-declaration rule to SPEC §4 and bump SPEC + SKILL to v2.1.0 (MINOR — new rule, backward compatible).

If it still fails → continue to step 4.

## Step 4 — Test H1 (source-doc clarity)

Edit `source.md` itself to make per-entity vs. ambient motion explicit in prose. Recompress, retest.

If the explicit prose-edit's BOTSPEAK output works → the source was the bottleneck. The lesson: BOTSPEAK preserves what's there, which means the input has to be clear too. Document this as a known limitation.

If it still fails → continue to step 5.

## Step 5 — Test H2 / H3 (loosyity factor)

Augment the skill with an explicit rule: "irreducibly complex sections (multi-state-variable interactions, physics simulations) → keep prose, do not compress." Recompress source.md (the original) with the updated skill, retest.

If this works → the loosyity rule is the fix. Bump SPEC + SKILL to v2.1.0.

If it still fails → verdict is C (compression-class hazard). BOTSPEAK is not viable for game-spec compression, period. Re-scope the eval to round-trip on rules/skills/handoffs (the actual design target) and accept that game synthesis is out of envelope.

## Step 6 — Independent of the above: round-trip eval

Run `/botspeak-translate` on six real AI-facing docs (use `examples/01` through `examples/06`) and compare the translation against the original. Any drift in constraint polarity, value preservation, or conditional logic is a notation/skill bug — and that's the eval that actually matches what BOTSPEAK exists to do.

A green round-trip on real docs is more important than a green Flappy Bird, because it tests the actual product.

---

# Things to NOT do

- **Do not add rules to the skill in response to single failures.** Every prior iteration did this, and each iteration solved the previous failure while introducing the next one.
- **Do not change the SPEC without bumping the version.** The cursor rule at `.cursor/rules/botspeak-versioning.mdc` prescribes the bump rules; follow them.
- **Do not skip the SPEC archive step.** Without it, you cannot trust which spec produced which skill produced which output.
- **Do not treat Flappy Bird as the canonical eval.** It's a stress test, not the design target. The round-trip eval is the canonical eval.
- **Do not soften the verdict.** If the conclusion after step 5 is "BOTSPEAK is not viable for game specs," say so and re-scope.

---

# Files you'll touch first

- `skills/_archive/spec/` (create directory)
- `skills/_archive/spec/<seq>-<date>-<lines>L-<tag>.md` (one per historical SPEC version)
- `skills/_archive/README.md` (add `## spec/` table)
- `.cursor/rules/botspeak-versioning.mdc` (verify SPEC archiving is included; patch if not)

Then, depending on which step in the diagnostic chain you reach:

- `evals/game-prompt/source-botspeak-v5.md` (step 2 output)
- `evals/game-prompt/source-botspeak-v5-handfix.md` (step 3 output, if needed)
- `evals/game-prompt/source.md` edits (step 4, if needed)
- New SPEC §X with entity-state rule or loosyity rule (step 3 or step 5, if needed)

---

# Open questions for the next chat to consider

1. Should the SPEC archive use semver retroactively (backfilling pre-v2.0.0 versions as v0.x) or use a flat sequence number for pre-semver content?
2. Should the audit's recommendation #1 (entity-state declaration rule) go into SPEC, into SKILL, or both? It's a *language* rule (so SPEC) but it manifests as a *procedural* rule (so SKILL).
3. Does the skill's step 6 verify pass actually run, or is it being skipped silently? The 5+ strict-`=` violations in v4 suggest it's being skipped. Worth instrumenting.
4. Is the round-trip eval already wired up? `evals/README.md` mentions it; check whether it's been run and what it shows.
5. After all this, does BOTSPEAK need a section in SPEC that says "here are the kinds of docs BOTSPEAK is *not* good for"? Game specs may belong on that list.

---

# Definition of done

This investigation is complete when the next chat can answer, with evidence:

1. Is the v2.0.0 skill actually applying its own rules at execution time?  (yes/no with proof)
2. Does the v2.0.0 skill produce a BOTSPEAK output of `source.md` that one-shots a working game on Haiku?  (yes/no with retest result)
3. If no in (2), what's the smallest change (to the spec, the skill, or the source) that makes it yes?  (specific patch, retested)
4. If no change makes it yes, is BOTSPEAK still useful for its actual design target (rules/skills/handoffs)?  (yes/no with round-trip eval result)

Anything short of those four answers is incomplete.
