---
description: One branch per focus; confirm git before coding; use worktrees for parallel features
alwaysApply: true
---

<!-- BOTSPEAK v2.2.0 · compressed by claude-sonnet-4-6 · 2026-05-19 -->

# Branch and Worktree Guard

[ALWAYS] one checkout = one active branch
[ALWAYS] parallel chats on unrelated features in one tree -> mixed commits · lost work · confused review

## Before edit

[ALWAYS] run `git branch --show-current` && `git status -sb` (workspace root) · state branch name once in plain language

## When user request != current branch

[ALWAYS] scope-separation (not "one more task on the side") -> STOP all edits · wait for A/B/C:

  A — same branch · same PR: only if work belongs · restate fit · proceed
  B — new branch in this folder: user switches · proceed on new branch only
  C — parallel work: `git worktree add` (sibling folder · second editor window · same repo + .cursor rules · no second clone) · ref https://git-scm.com/docs/git-worktree

[ON-TRIGGER] user prompts again without picking A/B/C -> repeat the three options · !! proceed

## Red flags (trigger STOP + options)

[ALWAYS] trigger on: user jumps area (e.g. wine-report while branch=DB/MV/n8n) · "quick fix on something else" · multiple unrelated deliverables without one branch covering all

## Do not

!! silently work across unrelated features in one branch
!! assume chat title = git branch name
