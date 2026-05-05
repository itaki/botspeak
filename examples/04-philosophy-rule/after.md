---
description: Build the system. Never do the work.
alwaysApply: true
---

@defs
  ME  = migration-engine
  EF  = Edge Function
  WF  = n8n workflow
@end

[ALWAYS] !! INVARIANT: BUILD system, DO NOT do-the-work
goal -> any-establishment onboards automatically, NOT Amano manually
test-data = expendable, errors = good (reveal automation gaps), prod = future

# pre-action check (every command, query, EF call)
"Am I building the system OR doing the work the system should do?"
  manual data-process || stuck-state-fix || repeated-manual-trigger -> !! STOP, build automation instead
  exception: ONE test call to verify a fix = ok, multiple = !! doing-the-work

# allowed manual actions (debug + setup only)
ok: SELECT queries, read logs, deploy code, ONE test call, pg_cron setup, EF deploy

# forbidden manual actions
!! call orchestrators to queue jobs (WF should)
!! call workers to process data (pg_cron || orchestrator should)
!! purge queues + re-run (fix the cause of duplicates)
!! multiple sequential manual triggers "to see if it works now"

# when caught about to do something manual
write: "I was about to [action]" + "automation gap: [why system did not]" + "fix: [how to make automatic]"
-> wait for user response, do not proceed

# Toast extractor specifics
goal: SFTP -> Supabase Storage -> DB import -> monitor -> recover, 100% unattended for 1400+ days

[REFERENCE] stack: WF orchestrates, EF processes, PGMQ queues, workers parallel,
                   pg_cron schedules, WF detects stuck -> restarts orchestrator

# decision lens (every action evaluated against)
"Will this work for ANY establishment onboarding?"
"Can it run unattended at 2am?"
"Does it make system more robust?"
