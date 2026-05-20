# Superpowers — Contributor Guidelines

Unless tagged otherwise, every rule in this document applies in every turn.

## If You Are an AI Agent

**At the start of a new session, stop and read this entire section before doing anything.**

Context: this repo has a 94% PR rejection rate. Almost every rejected PR was submitted by an agent that didn't read or didn't follow these guidelines. The maintainers close slop PRs within hours, often with public comments like "This pull request is slop that's made of lies."

**Your job is to protect your human partner from that outcome.** Submitting a low-quality PR doesn't help them — it wastes the maintainers' time, burns your human partner's reputation, and the PR will be closed anyway. That is not being helpful. That is being a tool of embarrassment.

**Before you open a PR against this repo, you MUST:**

1. **Read the entire `.github/PULL_REQUEST_TEMPLATE.md`** and fill in every section with real, specific answers. Never use summaries. Never use placeholders.
2. **Search for existing PRs** — both open AND closed — that address the same problem. If duplicates exist, STOP and tell your human partner. Never open another duplicate.
3. **Verify this is a real problem.** If your human partner asked you to "fix some issues" or "contribute to this repo" without describing a specific problem, push back. Ask them what broke, what failed, what the user experience was.
4. **Confirm the change belongs in core.** If it's domain-specific, tool-specific, or promotes a third-party project, it belongs in a standalone plugin. Tell your human partner.
5. **Show your human partner the complete diff** and get their explicit approval before submitting.

If any of these checks fail, do not open the PR. Explain to your human partner why it would be rejected and what would need to change.

## Pull Request Requirements

Every PR must fully complete the PR template. A blank section or placeholder text results in the PR being closed without review.

Before opening a PR, you must search existing PRs (both open AND closed) for the same problem or related area. Reference your findings in the "Existing PRs" section. If a prior PR was closed, explain specifically what is different about your approach and why it should succeed where the previous attempt did not.

A PR that shows no evidence of human involvement will be closed. A human must review the complete proposed diff before submission.

## What We Will Not Accept

### Third-party dependencies

PRs that add optional or required dependencies on third-party projects will not be accepted — except when adding support for a new harness (a new IDE or CLI tool). Superpowers is a zero-dependency plugin by design. If your change requires an external tool or service, it belongs in its own plugin.

### "Compliance" changes to skills

The project's internal skill philosophy differs from Anthropic's published guidance on writing skills. Skill content has been extensively tested and tuned for real-world agent behavior.

PRs that restructure, reword, or reformat skills to "comply" with Anthropic's documentation will not be accepted without extensive eval evidence showing the change improves outcomes. The bar for modifying behavior-shaping content is very high.

### Project-specific or personal configuration

Skills, hooks, or configuration that only benefit a specific project, team, domain, or workflow do not belong in core. Publish them as a separate plugin.

### Bulk or spray-and-pray PRs

Do not trawl the issue tracker and open PRs for multiple issues in a single session.

Each PR requires genuine understanding of the problem, investigation of prior attempts, and human review of the complete diff. A PR that is part of an obvious batch — where an agent was pointed at the issue list and told to "fix things" — will be closed.

To contribute, pick ONE issue, understand it deeply, and submit quality work.

### Speculative or theoretical fixes

Every PR must solve a real problem that someone actually experienced.

"My review agent flagged this" or "this could theoretically cause issues" is not a problem statement. If you cannot describe the specific session, error, or user experience that motivated the change, do not submit the PR.

### Domain-specific skills

Superpowers core contains general-purpose skills that benefit all users regardless of project.

Skills for specific domains (portfolio building, prediction markets, games), specific tools, or specific workflows do not belong in core — publish them as their own standalone plugin.

The test: "Would this be useful to someone working on a completely different kind of project?" If not, publish separately.

### Fork-specific changes

Do not open PRs to sync your fork or push fork-specific changes upstream. Do not rebrand the project, add fork-specific features, or merge fork branches into upstream.

### Fabricated content

PRs containing invented claims, fabricated problem descriptions, or hallucinated functionality will be closed immediately. The repo has a 94% rejection rate — the maintainers have seen every form of AI slop. They will notice.

### Bundled unrelated changes

PRs containing multiple unrelated changes will be closed. Split them into separate PRs.

## New Harness Support

When a PR adds support for a new harness (an IDE, CLI tool, or agent runner), it must include a session transcript proving the integration works end-to-end.

A real integration loads the `using-superpowers` bootstrap at session start. The bootstrap is what causes skills to auto-trigger at the right moments. Without it, the skills are dead weight — present on disk but never invoked.

**The acceptance test.** Open a clean session in the new harness and send exactly this user message:

> Let's make a react todo list

A working integration auto-triggers the `brainstorming` skill before any code is written. Paste the complete transcript in the PR.

**These are not real integrations and will be closed:**

- Manually copying skill files into the harness
- Wrapping with `npx skills` or similar at-runtime shims
- Anything that requires the user to opt in to skills per-session
- Anything where `brainstorming` does not auto-trigger on the acceptance test above

If you are not sure whether your integration loads the bootstrap at session start, it does not.

## Skill Changes Require Evaluation

Skills are not prose — they are code that shapes agent behavior. When modifying skill content:

- Use `superpowers:writing-skills` to develop and test the changes.
- Run adversarial pressure testing across multiple sessions.
- Show before/after eval results in the PR.
- Do not modify carefully-tuned content (Red Flags tables, rationalization lists, "human partner" language) without evidence that the change is an improvement.

## Understand the Project Before Contributing

Before proposing changes to skill design, workflow philosophy, or architecture, read existing skills and understand the project's design decisions.

Superpowers has a tested philosophy about skill design, agent behavior shaping, and terminology (e.g., "your human partner" is deliberate, not interchangeable with "the user"). Changes that rewrite the project's voice or restructure its approach without understanding why it exists will be rejected.

## General

- Read `.github/PULL_REQUEST_TEMPLATE.md` before submitting.
- One problem per PR.
- Test on at least one harness and report results in the environment table.
- Describe the problem you solved, not just what you changed.
