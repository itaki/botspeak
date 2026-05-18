<!-- BOTSPEAK v2.0.0 · compressed by claude-sonnet-4-5 · 2026-05-07 -->
---
description: One branch per focus; confirm git before coding; use worktrees for parallel features
alwaysApply: true
---

@defs
 BR = branch
@end

[REFERENCE] why: parallel chats on one working tree -> mixed commits · lost work · confused review · one checkout -> one active BR

[ALWAYS] before implement/edit: run `git branch --show-current` && `git status -sb` (workspace root) · state current BR name once in plain language

[ON-TRIGGER] user request != this BR's feature -> scope separation (not a side task)
!! stop · no edits until user picks one:
 A — same BR/PR: only if work truly belongs · restate fit · then proceed
 B — new BR (this folder): user creates/switches · then proceed on that BR only
 C — parallel: recommend `git worktree add` (sibling folder · second Cursor window) · same repo + .cursor rules · no second full clone · [Git worktree](https://git-scm.com/docs/git-worktree)
!! no selection -> force user to select before continuing

[ON-TRIGGER] red flags (always trigger stop + options):
 user jumps to unrelated area (e.g. on BR: DB/MV/n8n)
 "quick fix on something else"
 multiple unrelated deliverables in one thread without one BR name covering all

[ALWAYS] !! never silently work across unrelated features in one BR
[ALWAYS] !! never assume chat title = git BR
