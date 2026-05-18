<!-- BOTSPEAK v2.0.0 · compressed by claude-sonnet-4-5 · 2026-05-07 -->
[HANDOFF] BOTSPEAK · versioning system · 2026-05-07

## what changed

[ALWAYS] BOTSPEAK now has a formal version number: `v2.0.0` (semver · MAJOR.MINOR.PATCH)

files updated:
  SPEC.md             H1 -> `# BOTSPEAK SPEC v2.0.0` · metadata comment line 3 added · §6 rewritten with full versioning protocol
  skills/botspeak/SKILL.md   version comment added after frontmatter `---` · step 7 format string updated v0.2.0 -> v2.0.0
  ~/.cursor/skills-cursor/botspeak/SKILL.md   same changes (the installed copy)
  .cursor/rules/botspeak-versioning.mdc       new rule — versioning + publish protocol
  skills/_archive/README.md                   v08 row added
  skills/_archive/botspeak/v08-20260507-200L-versioning-header.md   new archive entry

## why

problem: compressed outputs stamp a version header (e.g. `<!-- BOTSPEAK v0.2.0 ... -->`), but the skill had no version in its own header and SPEC.md had no semver → no way to confirm which skill version produced a given output → regressions were invisible

fix: 4 canonical version locations that MUST agree:
  SPEC.md H1 · SPEC.md metadata comment · SKILL.md header comment · SKILL.md step 7 format string

## publish protocol (summary)

[ON-TRIGGER] user says "publish skill" || "release skill":
  1. confirm SPEC.md version bumped
  2. get short-tag from user (e.g. "conflict-detection" · "strict-equals-rule")
  3. distill SPEC -> skills/botspeak/SKILL.md · update version in comment + step 7
  4. archive: cp SKILL.md skills/_archive/botspeak/v<seq>-<YYYYMMDD>-<lines>L-<short-tag>.md
  5. install: cp SKILL.md ~/.cursor/skills-cursor/botspeak/SKILL.md
  6. update skills/_archive/README.md table (seq · date · lines · git hash · 1-sentence notes)

## version bump rules

  PATCH  clarification · wording · new example (no new rules/symbols)
  MINOR  new section · new symbol · new phase tag
  MAJOR  overhaul · breaking symbol contract

[REFERENCE] full protocol: .cursor/rules/botspeak-versioning.mdc
[REFERENCE] archive log: skills/_archive/README.md
