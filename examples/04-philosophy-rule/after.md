---
description: Development philosophy for building automated production workflows
alwaysApply: true
---

@defs
  proj = onboarding system development project (NOT actual restaurant onboarding)
  dta = expendable test data (can destroy + recreate repeatedly)
  dev = development phase (building automation · not production work)
  WIP = work-in-progress (multiple manual runs)
@end

default-phase: [ALWAYS]

# Development Workflow Philosophy

## !! PROJECT GOAL

[ALWAYS]
  !! WE ARE BUILDING THE ONBOARDING SYSTEM · NOT ONBOARDING RESTAURANTS
  proj = automated workflows that will onboard establishments in future
  current-restaurant (Fred's Italian Bistro) = test-vehicle only
  dta = only to test onboarding automation
  
  can (and should):
    destroy dta + recreate repeatedly
    treat errors as automation-bugs (valuable)
  
  !! cannot:
    manually process 1400+ days data
    "finish" Fred's onboarding in production
    treat dta as precious production data

## Core Principle

[ALWAYS] !! NEVER manually fix things
  [ALWAYS] identify WHY automation failed
  [ALWAYS] fix workflow so it handles issue automatically
  [ALWAYS] ensure workflow runs unattended for onboarding
  [ALWAYS] build monitoring + self-healing into system

## STOP Checklist (before ANY action)

[ALWAYS] ask before executing command · SQL query · EF call:

  1. manually processing data? -> !! STOP
    if: calling orchestrators · workers · processing pending-jobs
    ask: "how should system process this automatically?"

  2. manually fixing stuck-state? -> !! STOP
    if: resetting status · purging queue · triggering process
    ask: "why didn't automation detect + fix this?"

  3. running to test if something works? -> !! STOP
    one-test ok · multiple calls || sequence -> build automated system
    ask: "what automated system should do this?"

  4. will repeat tomorrow/next-week/next-establishment? -> !! STOP
    if: yes -> needs automation · not manual run
    ask: "what system should handle this automatically?"

allowed-manual (debug/investigation only):
  ok: SELECT queries · reading logs · deploying code · one test-call · creating pg_cron jobs

forbidden-manual:
  !! calling orchestrators (n8n or system should do)
  !! calling workers (pg_cron or ORC should do)
  !! purging queues + re-running (fix why duplicates occurred)
  !! multiple sequential manual triggers

## When Caught About to Act Manually

[ALWAYS] STOP + write:
  1. "I was about to [manual-action]"
  2. "The automation-gap is: [why system didn't do this]"
  3. "The fix needed is: [how to make system do this]"
  4. "Should I proceed? (Y/N)"
  
  then WAIT for user response

## Soviet Extractor Workflow Context

goal: build onboarding that:
  1. fetches CSV from Soviet SFTP
  2. uploads to SPA Storage
  3. auto-imports into database
  4. monitors progress · handles errors
  5. !! runs completely unattended for new establishments

"onboarding" meaning: when new restaurant signs up
  -> workflow processes 1400+ historical-days
  -> runs without manual intervention
  -> detects + recovers from errors automatically
  -> notifies when complete (or if true manual-intervention needed)

current-phase (dev):
  n8n = orchestrates entire process
  SPA EF = heavy processing
  PGMQ = job queues
  workers = parallel processing
  status-checker = monitors progress
  n8n = detects stuck + restarts ORC

## Manual Intervention Appropriate Only

[ALWAYS] manual ok:
  1. deploying code (migrations · EF)
  2. testing specific components (verify fix)
  3. investigating root-causes (query DB · understand failure)
  4. one-time setup (pg_cron · initial config)

!! not for:
  processing pending-data (workers should do)
  restarting stuck-processes (auto-restart)
  fixing data-issues that recur (prevent root-cause)

## Remember

[ALWAYS]
  goal = automation · not manual-intervention
  evaluate every decision: "will this work for onboarding new restaurant?"
  can this run unattended?
  does this make system more robust?
