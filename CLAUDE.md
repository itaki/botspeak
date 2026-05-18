<!-- BOTSPEAK v2.1.0 · compressed by claude-sonnet-4-6 · 2026-05-08 -->
# BOTSPEAK

[NEW-CHAT] read PHILOSOPHY.md first · this repo = AI-to-AI language · !! NOT compression tool · !! NOT game demo
[NEW-CHAT] this repo = BOTSPEAK spec + skills + rule + agent · goal: teach agents to write AI-facing docs in compressed notation
[NEW-CHAT] target audience = developers using Claude Code · Cursor · Codex · Gemini CLI · any AI coding agent

@defs
  BT = BOTSPEAK
  HP = human-prose
@end

[REFERENCE] skills (recommended primary delivery mechanism):
  /botspeak           -> compress existing AI-facing doc (file or directory) -> BT
  /botspeak-translate -> render BT -> HP for human audit (the round-trip safety net)

[REFERENCE] agent: agents/botspeak-translator.md (bidirectional, auto-detect direction)
[REFERENCE] rule:  rules/botspeak-always-on.md · rules/botspeak-always-on.mdc (manual install per IDE)

[REFERENCE] SPEC.md = symbol contracts · @defs aliases · phase tags · grammar
[REFERENCE] examples/ = 5 before/after pairs across doc types

[ALWAYS] writing new BT docs -> follow SPEC · @defs for repeated terms · phase tags · verify constraints preserved
[ALWAYS] user-visible content (questions · choices · errors) -> full HP · zero BT · in user's language

## dev guidelines (when building/hardening BT itself)

[ALWAYS] no overfitting · when adding rules to SPEC · skills · or examples:
  ok: general rules naming grammar / structure / behavior (e.g. "RHS of `=` must be a value, not a description")
  !!: case-specific rules naming domain concepts from one eval (e.g. "PP_spawn_interval needs the `_interval` suffix")
  test: if a rule names a specific concept from one eval -> generalize · keep concrete examples in the catalog · keep rules abstract
  rationale: skill/spec must stay concise · we want generalized solutions for failure classes · NOT a catalog of every failure that ever happened
[ALWAYS] one new failure -> ask "what class of failure does this represent?" -> harden against the class
[ALWAYS] when in doubt about scope, prefer SHORTER · more general · over LONGER · more specific
