---
description: One branch per focus; confirm git before coding; use worktrees for parallel features
alwaysApply: true
---

# Branch and Worktree Guard

In every turn, one checkout equals one active branch.

In every turn, parallel chats on unrelated features in one tree lead to mixed commits, lost work, and confused review.

## Before edit

In every turn, run `git branch --show-current` and `git status -sb` from the workspace root, and state the branch name once in plain language.

## When user request differs from current branch

In every turn, treat this as scope separation (not "one more task on the side"), stop all edits, and wait for A, B, or C:

  A — Same branch, same PR: only if the work belongs, restate the fit, and proceed.
  B — New branch in this folder: the user switches branches, then proceed on the new branch only.
  C — Parallel work: `git worktree add` (sibling folder, second editor window, same repo plus `.cursor` rules, no second clone). Reference: https://git-scm.com/docs/git-worktree

When the user prompts again without picking A, B, or C, repeat the three options and never proceed.

## Red flags (trigger STOP and options)

In every turn, trigger on: the user jumps area (for example, wine-report while the branch is DB/MV/n8n), "quick fix on something else," or multiple unrelated deliverables without one branch covering all of them.

## Do not

Never silently work across unrelated features in one branch.

Never assume the chat title equals the git branch name.
