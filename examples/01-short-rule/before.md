---
description: One branch per focus; confirm git before coding; use worktrees for parallel features
alwaysApply: true
---

# Branch and worktree guard

## Why

Parallel chats on unrelated features in one working tree mix commits, lose work, and confuse review. **One checkout = one active branch.**

## Before you implement or edit files

1. Run: `git branch --show-current` and `git status -sb` (from the workspace root).
2. State the branch name once in plain language (e.g. "On `feature/mv-refresh`.").

## When the user's request is a different feature than this branch

Treat as **scope separation**, not "one more task on the side."

**Stop.** Do not start edits until the user chooses:

- **A — Same branch, same PR:** Only if the work truly belongs with the current branch; restate how it fits; then proceed.
- **B — New branch (this folder):** User creates/switches branch here; then proceed on that branch only.
- **C — Parallel work:** Recommend **`git worktree add`** (sibling folder, second Cursor window). Same repo and `.cursor` rules; no second full clone. Link: [Git worktree](https://git-scm.com/docs/git-worktree).

Do not continue until the user selects one of these. If the user just puts in another prompt without selecting one, **force them to select one.**

## Red flags (always trigger the stop + options)

User jumps to another area (e.g. wine report while branch is DB/MV/n8n), "quick fix on something else," or multiple unrelated deliverables in one thread without one branch name that covers them all.

## Do not

Silently work across unrelated features in one branch, or assume chat title equals git branch.
