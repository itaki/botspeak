<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-19 -->
# BOTSPEAK

@defs
  BT = BOTSPEAK
  HP = human-prose
@end

[NEW-CHAT] read PHILOSOPHY.md first · this repo = AI-to-AI language · !! NOT compression tool · !! NOT game demo
[NEW-CHAT] repo = BT spec + skills + rule + agent · for AI coding agents

[REFERENCE] skills (recommended primary):
  /botspeak           -> HP doc (file or directory) -> BT (compress)
  /botspeak-translate -> BT doc -> HP (audit, round-trip safety)

[REFERENCE] SPEC.md · examples/ · agents/botspeak-translator.md

[ALWAYS] new AI-facing docs -> BT format · @defs aliases · phase tags
[ALWAYS] user-visible output -> HP only · in user's language · zero BT

## dev guidelines (hardening BT itself)

[ALWAYS] no overfitting when adding rules to SPEC / skills / examples:
  ok: general rules (grammar · structure · behavior)
  !!: case-specific rules naming domain concepts from one eval
  one new failure -> ask "what class of failure does this represent?" -> harden against the class
  prefer shorter · more general · over longer · more specific
