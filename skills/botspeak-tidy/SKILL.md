---
name: botspeak-tidy
description: >
  Convert all AI-facing docs (skills, rules, CLAUDE.md, AGENTS.md) in your
  setup to BOTSPEAK in one pass. Backs up before touching anything.
  Use when: "tidy everything", "convert all my skills to botspeak",
  "botspeak tidy", "/botspeak-tidy", or after a session where IDE tools
  (create-skill, create-rule) generated prose files you want to compress.
---

@defs
  BT = BOTSPEAK
  AI-docs = skills · rules · CLAUDE.md · AGENTS.md · memory pages · handoffs
  BKP = backup directory
@end

[ON-TRIGGER] "tidy everything" || "convert all skills" || "/botspeak-tidy" || "botspeak my whole setup"

# Workflow

## 1. Confirm scope

Ask which directories to scan. Defaults:
- `~/.cursor/skills/` (personal Cursor skills)
- `~/.agents/skills/` (cross-agent personal skills)
- `.cursor/rules/` (project Cursor rules)
- `.cursor/skills/` (project Cursor skills)
- `CLAUDE.md` · `AGENTS.md` in project root

Let user add or remove paths.

## 2. Backup !! required step

!! never write any file before confirming backup

Ask: "Back up all files before converting? (strongly recommended — this is irreversible)"
- yes (default) -> copy entire scope to `<parent>-botspeak-backup-<date>/` · confirm BKP path before proceeding
- no -> show warning: "No backup. This cannot be undone." · ask again · proceed only on second explicit "no"

## 3. Inventory scan

For each file in scope (.md · .mdc):
- classify: `already-BT` (has @defs || phase tags) · `needs-conversion` · `skip` (frontmatter-only · binary)
- show inventory table: filename · status · estimated size

Ask: "Proceed with converting N files? Skip M already-converted."

## 4. Convert loop

For each `needs-conversion` file:
- read file
- apply /botspeak conversion (preserve frontmatter · compress body only)
- write back in place
- log: original word count -> new word count · savings %

~~ large files (>500 lines): warn before converting · offer to skip individually

## 5. Summary

Report:
- files converted · already-BT (skipped) · errors
- total token savings estimate
- BKP location (if backup taken)
- next: "Run /translate-botspeak on any file to audit it in plain English"
