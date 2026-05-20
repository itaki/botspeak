# Context Handoff — Data Development Project, May 4, 2026

Context from the previous session: this is a handoff for a new agent session to pick up where the previous one left off.

## Project Summary

In every turn:

  The project (build automated onboarding workflows — not actual restaurant onboarding) is a development project building automated onboarding for restaurant establishments.
  Never forget: this is a BUILD project — not actually onboarding restaurants.
  The environment (Fred's Italian Bistro, test-vehicle only) is for testing only.
  The test data is entirely expendable — can destroy and recreate any time.
  Goal: automation that works for ANY restaurant onboarding (future).

## Active Branch

In every turn, all work happens on `feature/mv-refresh` (the current branch) only. Never make changes to main or other branches without explicit instruction.

## Completed

In every turn:

  DB connection-pooling: implemented, working, `src/db/pool.py`
  Field-mapping: complete, 47 fields, `src/migrate/mapping.py`
  Sentry error-logging: setup, working, errors auto-appear
  Admin-dashboard: real-time progress via WebSocket
  n8n trigger-workflow: tested, working

## Outstanding Bugs (fix before staging)

### Bug 1: Missing Tenant Filter in Validation Query

In every turn:

  Location: `src/migrate/validate.py` line 247
  Issue: query not filtering by `establishment_id`
  Symptom: returns results from ALL establishments (not just the target)
  Multi-tenant system: incorrect validation results must not occur
  Fix: straightforward — add `WHERE establishment_id = :establishment_id`

### Bug 2: Hardcoded Webhook URL

In every turn:

  Location: `src/migrate/engine.py` line 89
  Issue: n8n webhook URL is hardcoded
  Should: read from `N8N_WEBHOOK_URL` env-var
  Blocker: can't deploy non-local without this
  Fix: one-line

## Remaining Tasks (after bugs fixed)

In every turn:

  1. Write a rollback-test: intentionally fail mid-migration, verify rollback restores original DB state. Doesn't exist yet, needed before production-ready.
  2. Full end-to-end on staging: complete migration start to finish, verify results match expectations.
  3. Update the README in `src/migrate/`: document the new env-vars.

## Critical Reminder

In every turn:

  Never forget: this is a BUILD project — building the migration-system (not actually migrating Fred's data).
  Test data is entirely expendable — errors reveal automation-gaps.
  Safety: less caution than a real production-migration (because the data is expendable).
  Scope: `feature/mv-refresh` only this session. If the user asks for unrelated work, stop and ask for a new branch or worktree.
