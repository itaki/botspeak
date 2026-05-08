# Marketing TODO (Codex)

This is the Codex take: optimize for **proof of value**, then distribution.
If people see real token/time savings in 2 minutes, they install.

---

## Tomorrow (must-do)

- [ ] **Ship a "2-minute proof" section** near the top of `README.md`:
  - pick one large AI-facing file
  - run `/botspeak @file`
  - compare before/after token counts
  - if savings <30%, skip; if >30%, install always-on rule
- [ ] **Add one screenshot/GIF** showing before/after token delta from a real file.
- [ ] **Pin one canonical claim** and use it everywhere:
  - "Primary mode: always-on generation for new AI-facing docs. Secondary mode: back-compress legacy docs."
- [ ] **Run install smoke test** from a fresh shell using the raw GitHub installer URL.
- [ ] **Publish launch post** in one channel where you can reply fast (HN or X).

## Launch copy (use this framing)

- [ ] Hook: "Most AI-facing docs are written for humans, then re-read by agents every session."
- [ ] Outcome: "BOTSPEAK reduces recurring context tax and improves agent focus."
- [ ] Scope: "Works with Claude/Cursor/Codex/Gemini workflows."
- [ ] Safety: "Round-trip via `/botspeak-translate` when you need human audit."

## Distribution (first 72 hours)

- [ ] HN post with token delta screenshot and README link.
- [ ] X thread (5 posts): problem -> before/after -> how it works -> safety -> install.
- [ ] Reddit where relevant (`r/ClaudeAI`, `r/cursor`, `r/LocalLLaMA`) with the same proof image.
- [ ] Discord share in relevant channels (Cursor/Anthropic/Codex communities), no spam.

## Product credibility assets (week 1)

- [ ] Publish `BENCHMARKS.md` with at least 5 real files and before/after token counts.
- [ ] Add one "long `CLAUDE.md` in the wild" case study (already partially done in `examples/05`).
- [ ] Add one "handoff doc" case study with recurring token savings estimate.
- [ ] Add one "dense/code-heavy doc" case to show realistic floor (~40%).

## Message discipline (keep repeating)

- [ ] "This is not just compression tooling."
- [ ] "Primary value is default AI-facing doc generation in BOTSPEAK."
- [ ] "Compression of old docs is the migration path."
- [ ] "More signal, less noise."

## What to avoid

- [ ] Don't overclaim ("always 70%"). Keep "up to" and show range.
- [ ] Don't lead with jargon. Lead with recurring cost/time reduction.
- [ ] Don't launch in 6 places at once if you can't answer comments quickly.

## Success checks (week 1)

- [ ] 100+ stars
- [ ] 3+ external mentions
- [ ] 5+ real users reporting before/after token deltas
- [ ] At least one independent repo adopting `botspeak-always-on` rules

If these don't move, rewrite the top README section and launch copy before changing the product.
