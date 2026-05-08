# Context Handoff — Data Development Project, May 4, 2026

@defs
  proj = build automated onboarding workflows (NOT actual restaurant onboarding)
  env = Fred's Italian Bistro (test-vehicle only)
  dta = expendable test data
  br = feature/mv-refresh (current branch)
  SPA = Supabase
  EF = Edge Function
@end

[HANDOFF] new-agent-session pickup where previous left off

## Project Summary

[ALWAYS]
  proj: development project building automated onboarding for restaurant establishments
  !! BUILD project · NOT actually onboarding restaurants
  env: Fred's Italian Bistro (testing only)
  dta: entirely expendable · can destroy + recreate any time
  goal: automation that works for ANY restaurant onboarding (future)

## Active Branch

[ALWAYS] all-work on br only · !! no changes main || other branches without explicit instruction

## Completed

[ALWAYS]
  DB connection-pooling: implemented · working · src/db/pool.py
  field-mapping: complete · 47 fields · src/migrate/mapping.py
  Sentry error-logging: setup · working · errors auto-appear
  admin-dashboard: real-time progress via WebSocket
  n8n trigger-workflow: tested · working

## Outstanding Bugs (fix before staging)

### Bug 1: Missing Tenant Filter in Validation Query

[ALWAYS]
  location: src/migrate/validate.py line 247
  issue: query not filtering by establishment_id
  symptom: returns results from ALL establishments (not just target)
  multi-tenant system: !! incorrect validation results
  fix: straightforward · add `WHERE establishment_id = :establishment_id`

### Bug 2: Hardcoded Webhook URL

[ALWAYS]
  location: src/migrate/engine.py line 89
  issue: n8n webhook URL hardcoded
  should: read from N8N_WEBHOOK_URL env-var
  blocker: can't deploy non-local without this
  fix: one-line

## Remaining Tasks (after bugs fixed)

[ALWAYS]
  1. write rollback-test: intentionally fail mid-migration · verify rollback restores original DB state · doesn't exist yet · needed before production-ready
  2. full end-to-end on staging: complete migration start→finish · verify results match expectations
  3. update README src/migrate/: document new env-vars

## Critical Reminder

[ALWAYS]
  !! BUILD project · building migration-system (not actually migrating Fred's data)
  dta: entirely expendable · errors reveal automation-gaps
  safety: less caution than real production-migration (because dta)
  scope: feature/mv-refresh only this session · if user asks unrelated · stop + ask new branch/worktree
