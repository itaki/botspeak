# BOTSPEAK

[NEW-CHAT] this repo = BOTSPEAK spec + skills + rule + agent · goal: teach agents to write AI-facing docs in compressed notation
[NEW-CHAT] target audience = developers using Claude Code · Cursor · Codex · Gemini CLI · any AI coding agent

@defs
  BT = BOTSPEAK
  HP = human-prose
@end

skills (recommended primary delivery mechanism):
  /botspeak           -> compress existing AI-facing doc (file or directory) -> BT
  /botspeak-translate -> render BT -> HP for human audit (the round-trip safety net)

agent: agents/botspeak-translator.md (bidirectional, auto-detect direction)
rule:  rules/botspeak-always-on.md · rules/botspeak-always-on.mdc (manual install per IDE)

[REFERENCE] SPEC.md = symbol contracts · @defs aliases · phase tags · grammar
[REFERENCE] examples/ = 5 before/after pairs across doc types

[ALWAYS] writing new BT docs → follow SPEC · @defs for repeated terms · phase tags · verify constraints preserved
[ALWAYS] user-visible content (questions · choices · errors) → full HP · zero BT · in user's language
