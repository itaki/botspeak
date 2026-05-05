# Context Handoff — Data Development Project, Session May 4, 2026

## Purpose of This Document

This document is intended to help a new AI agent session pick up where the previous session left off. Please read this carefully before beginning any work.

## Project Overview

We are working on the Data Development Project, which is a development project to create automated onboarding workflows for restaurant establishments. It is critical to understand that this is a BUILD project — we are building the system, not actually onboarding any restaurants. The current establishment we are working with for testing purposes is Fred's Italian Bistro, but we are not trying to complete their onboarding. We are building the automation that will onboard any restaurant in the future.

## Current Feature Branch

The current feature branch is `feature/mv-refresh`. All work should happen on this branch. Do not make changes to `main` or any other branch without explicit instruction.

## What Has Been Completed

The following items have been implemented and tested:

- Database connection pooling has been implemented and is working correctly. The connection pool configuration is in `src/db/pool.py`.
- The source-to-destination field mapping is complete. The mapping configuration lives in `src/migrate/mapping.py` and covers all 47 fields that need to be migrated.
- Error logging with Sentry has been set up and is working. Errors will appear in the project's Sentry automatically.
- The admin dashboard now shows migration progress in real-time using a WebSocket connection.
- The n8n trigger workflow that initiates a migration run has been tested and is working correctly.

## Outstanding Issues That Need to Be Fixed

There are two bugs that need to be resolved before we can run the migration on staging:

### Bug 1: Missing Tenant Filter in Validation Query

The validation query in `src/migrate/validate.py` at line 247 is not correctly filtering by `establishment_id`. This means the query is currently returning results from all establishments in the database rather than just the one being migrated. This is a multi-tenant system and this bug would cause incorrect validation results. The fix should be straightforward — add a `WHERE establishment_id = :establishment_id` clause to the query.

### Bug 2: Hardcoded Webhook URL

The n8n webhook URL for the post-migration cleanup workflow is currently hardcoded in the migration engine at `src/migrate/engine.py` line 89. This should be read from the environment variable `N8N_WEBHOOK_URL` instead. This is a single-line fix but it needs to happen before we can deploy to any environment other than local development.

## What Still Needs to Be Done

After fixing the two bugs above, the following tasks remain:

1. Write a test for the rollback mechanism. The test should intentionally cause a migration failure partway through the process and then verify that the rollback correctly restores the original database state. This test does not exist yet and is needed before we can consider the migration engine production-ready.

2. Run a full end-to-end test on the staging environment. This includes running a complete migration from start to finish on staging data and verifying the results match expectations.

3. Update the README in `src/migrate/` to document the new environment variables that have been added.

## Important Reminders

Please remember that this is a BUILD project. We are building the migration system. We are not trying to actually migrate Fred's Italian Bistro's data into production. The test data we are working with is entirely expendable and can be destroyed and recreated at any time. This is important because it changes how we think about data safety — in a real production migration, we would be much more careful. Here, errors are useful because they reveal gaps in our automation.

Do not work on any features outside the scope of `feature/mv-refresh` in this session. If the user asks you to work on something unrelated, stop and ask them to create a new branch or worktree.
