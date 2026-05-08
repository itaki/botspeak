# Context Handoff — Data Development Project, May 4, 2026

**Context from the previous session:** This document provides context for the next agent session to pick up where the previous one left off.

## Project Summary

**In every turn:**

The project involves developing an automated onboarding workflow system for restaurant establishments. It is critical to remember that this is a **development project building the automation system itself—not actually onboarding real restaurants.** The test environment is Fred's Italian Bistro, which serves only as a test vehicle for the system. All test data used is entirely expendable; you can destroy and recreate it at any time without consequences. The ultimate goal is to create automation that could work for any restaurant onboarding in the future.

## Active Branch

**In every turn:** All work must happen on the `feature/mv-refresh` branch only. It is forbidden to make changes to the main branch or other branches without explicit instruction to do so.

## Completed

**In every turn:**

- Database connection pooling has been implemented and is working correctly in `src/db/pool.py`
- Field mapping is complete, covering 47 fields, and is implemented in `src/migrate/mapping.py`
- Sentry error logging has been set up and is working; errors automatically appear in the Sentry dashboard
- The admin dashboard displays real-time migration progress via WebSocket
- The n8n trigger workflow has been tested and is working correctly

## Outstanding Bugs (fix before staging)

### Bug 1: Missing Tenant Filter in Validation Query

**In every turn:**

- **Location:** `src/migrate/validate.py` line 247
- **Issue:** The query is not filtering by `establishment_id`
- **Symptom:** The query returns results from all establishments instead of just the target establishment
- **Impact on multi-tenant system:** This leads to incorrect validation results in a multi-tenant system, which is forbidden
- **Fix:** This is straightforward—add `WHERE establishment_id = :establishment_id` to the query

### Bug 2: Hardcoded Webhook URL

**In every turn:**

- **Location:** `src/migrate/engine.py` line 89
- **Issue:** The n8n webhook URL is hardcoded into the source code
- **Should be:** The URL should be read from the `N8N_WEBHOOK_URL` environment variable
- **Blocker:** This prevents deployment outside of local development environments
- **Fix:** This is a one-line change

## Remaining Tasks (after bugs fixed)

**In every turn:**

1. Write a rollback test that intentionally fails mid-migration and then verifies that the rollback restores the original database state. This test doesn't exist yet and is needed before the system is production-ready.
2. Run a full end-to-end test on the staging environment, completing a migration from start to finish and verifying that the results match expectations.
3. Update the README in `src/migrate/` to document the new environment variables that have been added.

## Critical Reminder

**In every turn:**

Remember that this is a **development project building the migration system itself—not actually migrating Fred's real data.** All test data is entirely expendable, and errors in the automation are valuable because they reveal gaps in the system design. This means you can take fewer precautions than you would with a real production migration (because the data is test data). Keep the scope focused on the `feature/mv-refresh` branch only; if the user asks you to work on something unrelated, stop and ask whether a new branch or worktree should be created for that work.

---

## What This Means in Practice

This handoff document establishes the immediate context for the next session. The agent should start by understanding that this is a development and testing effort, not a live migration, which means data loss is acceptable and even useful for revealing system flaws. The two critical bugs must be fixed before any staging environment testing can occur—these are blocking issues that will cause either incorrect validation or deployment failures. Once the bugs are fixed, the remaining work follows a clear sequence: implement the missing rollback test, run a full end-to-end test on staging, and update documentation. The boundary condition is strict: all work stays on `feature/mv-refresh` unless explicitly redirected to a new branch or worktree.
