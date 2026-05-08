---
description: One branch per focus; confirm git before coding; use worktrees for parallel features
alwaysApply: true
---

# Branch and Worktree Guard

## Why

In every turn, working on parallel chats with unrelated features in one working tree results in mixed commits and lost work and confused review. In every turn, one checkout should equal one active git branch.

## Before Implement or Edit

In every turn:
 1. Run `git branch --show-current` and `git status -sb` in the workspace root
 2. State the branch name once in plain language (for example, "On `feature/mv-refresh`")

## When User Request is for a Different Feature

In every turn, treat this as scope separation (not "one more task on the side").

In every turn, stop work. Never make edits until the user chooses one of the following options:

 A — Same branch and same pull request: Only proceed if the work truly belongs in this context. Restate how it fits and proceed.
 B — New branch (in this folder): The user creates or switches to a new branch. Proceed only within that branch.
 C — Parallel work: Recommend using `git worktree add` to create a sibling folder with a second Cursor window. This allows working in the same repository with the same `.cursor` rules without creating a second clone. See: https://git-scm.com/docs/git-worktree

In every turn, never proceed until you have waited for the user's selection. Force the choice if they simply prompt again without selecting.

## Red Flags (always trigger stop and options)

In every turn, trigger this rule when:
 - The user jumps to another area (wine report while working on a database or migration or n8n branch)
 - The user mentions a "quick fix on something else"
 - Multiple unrelated deliverables are mentioned without one branch name covering all of them

## What This Means in Practice

When a user starts asking you to work on a feature that's different from the current branch's purpose, you must pause and make them explicitly choose where this work should go. Don't silently mix it into the current branch. The three options clarify the choice: continue the current effort (if truly related), switch to an existing branch, or create parallel work using git worktrees so you can maintain two independent checkouts without creating duplicate clones of the repository. This prevents commits from becoming polluted with unrelated changes and keeps code review focused on a single concern.
