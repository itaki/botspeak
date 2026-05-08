# BOTSPEAK

@defs
  BT = BOTSPEAK
  HP = human-prose
@end

repo = BT spec + skills + rule + agent · for AI coding agents

skills (recommended primary):
  /botspeak           -> HP doc (file or directory) -> BT (compress)
  /botspeak-translate -> BT doc -> HP (audit, round-trip safety)

[REFERENCE] SPEC.md · examples/ · agents/botspeak-translator.md

[ALWAYS] new AI-facing docs → BT format · @defs aliases · phase tags
[ALWAYS] user-visible output → HP only · in user's language · zero BT

## dev guidelines (hardening BT itself)

[ALWAYS] no overfitting when adding rules to SPEC / skills / examples:
  ok: general rules (grammar · structure · behavior)
  !!: case-specific rules naming domain concepts from one eval
  one new failure -> ask "what class of failure does this represent?" -> harden against the class
  prefer shorter · more general · over longer · more specific
