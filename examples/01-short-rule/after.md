---
description: One branch per focus; confirm git before coding; use worktrees for parallel features
alwaysApply: true
---

@defs
  br = git branch
  wt = git worktree
@end

# Branch and Worktree Guard

## Why

[ALWAYS] parallel-chats on unrelated-features in one working-tree = mixed commits · lost work · confused review
[ALWAYS] one checkout = one active br

## Before Implement or Edit

[ALWAYS]
  1. run: `git br --show-current` && `git status -sb` (workspace root)
  2. state br-name once in plain language (e.g. "On `feature/mv-refresh`")

## When User Request = Different Feature

[ALWAYS] treat as SCOPE-SEPARATION (not "one more task on side")

[ALWAYS] STOP · !! edit until user chooses:

  A — same br · same PR: only if work truly belongs · restate how · proceed
  B — new br (this folder): user creates/switches · proceed that br only
  C — parallel work: recommend `git wt add` (sibling folder · second Cursor window)
      same repo + .cursor rules · no second clone · link: https://git-scm.com/docs/git-worktree

[ALWAYS] !! edit even on prompt-again -> force user to pick A/B/C

## Red Flags (always trigger stop + options)

[ALWAYS] trigger when:
  user jumps another area (wine-report while br=DB/MV/n8n)
  "quick fix on something else"
  multiple unrelated deliverables without one br-name covering all
