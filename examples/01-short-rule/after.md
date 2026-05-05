---
description: One checkout = one branch · git before code · worktrees for parallel work
alwaysApply: true
---

# branch/worktree guard

[NEW-CHAT] run: `git branch --show-current` + `git status -sb` → state: "On <branch>"
[ALWAYS] invariant: one-working-tree = one-active-branch · cross-feature mixing → lost work + broken review

request ≠ branch-feature → scope-split → 🔴 STOP · zero edits until user picks:
  A same-branch/PR (only if it fits — say how, then proceed)
  B new-branch-here (user switches; proceed only there)
  C parallel → `git worktree add` (sibling path · 2nd Cursor window · shared repo + .cursor rules · not full clone)
     ref: https://git-scm.com/docs/git-worktree

user replies without picking → 🔴 stop again · require A/B/C

[ON-TRIGGER] red flags = same stop + A/B/C:
  topic-jump (wine report while branch = DB/MV/n8n) · "quick unrelated fix" · multi unrelated deliverables in one thread

🔴 never: silent cross-feature on one branch · assume chat-title = HEAD
