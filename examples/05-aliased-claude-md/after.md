# CLAUDE.md -- DishData

<defs>
  E    = establishment_id
  ES   = establishment_settings (JSONB col on establishments table)
  WR   = wine-report
  CSR  = customer-satisfaction-report
  MV   = materialized-view
  EF   = Edge Function
  WF   = n8n workflow
  PGMQ = postgres-message-queue
</defs>

<context>
[NEW-CHAT] DishData = multi-tenant restaurant analytics, Toast POS -> SFTP -> normalize -> MV -> dashboards
[NEW-CHAT] phase = BUILD onboarding system, NOT ops, current test = Amano (data expendable)
</context>

<architecture>
[REFERENCE]
  WF (workflows.dishdata.example) orchestrates all multi-step processes, triggers EF, monitors, auto-restart on stuck
  EF on Supabase: SFTP -> CSV parse -> normalize -> DB write, deploy via `supabase functions deploy`
  PGMQ queues jobs, workers dequeue && process
  pg_cron schedules: MV refresh, WR daily, CSR weekly
  MV refreshed CONCURRENTLY, policy in docs/mv-refresh.md && obs_mv_refresh_policy table
  admin dashboard (Next.js, admin.dishdata.example), WebSocket progress, serves WR && CSR
</architecture>

<rules>
[ALWAYS] !! INVARIANT: BUILD system, DO NOT do-the-work
[ALWAYS] !! NEVER hardcode any per-E value, ALL sourced from ES JSONB:
  E, name, Toast account_id, SFTP base_path, SFTP creds key,
  business hours, operating schedule, menu structure, pricing rules, grace periods
[ALWAYS] all queries -> filter by E, all EF -> accept E param, all WF -> use input E (never hardcoded)
[ALWAYS] WR && CSR both per-E, both filter by E
[ALWAYS] RLS = defense-in-depth, NOT substitute for app-level E filter

[ON-TRIGGER] request != current branch -> !! STOP, A/B/C choice (A same-branch, B switch-here, C `git worktree add`)
[ON-TRIGGER] red flags = same stop: topic-jump (e.g. WR question while branch = MV), "quick unrelated fix", multi unrelated deliverables
!! never silent cross-feature on one branch

[ON-TRIGGER] about-to-do-manual: data-process || fix-stuck || repeat-trigger -> !! STOP
  exception: ONE test call to verify fix = ok, multiple = doing-the-work
  write: "I was about to [X]" + "automation gap: [Y]" + "fix: [Z]" -> wait for user
</rules>

<reports>
[REFERENCE] WR (supabase/functions/wine-report/index.ts):
  reads mv_wine_sales, agg by varietal, region, price tier
  delivered email 06:00 ET daily, pg_cron `wine_report_daily`
  respects ES.operating_schedule, excludes closure days from averages
  also in admin dashboard

[REFERENCE] CSR (supabase/functions/customer-satisfaction-report/index.ts):
  aggregates: Toast tips, Yelp API, Google Reviews API -> rolling 30d score
  writes mv_customer_satisfaction, refreshed nightly pg_cron `customer_satisfaction_refresh`
  delivered email Mon 09:00 ET weekly
</reports>

<state>
done: db-pool ok, field-mapping(47 fields) ok, sentry ok, dashboard-websocket ok,
      WF migration-trigger ok, WR EF + cron ok, CSR EF + cron ok,
      MV refresh policy: mv_wine_sales ok, mv_customer_satisfaction ok

todo:
  !! src/migrate/validate.py:247 -> missing E filter -> add WHERE E = :E
  !! src/migrate/engine.py:89 -> hardcoded N8N webhook URL -> use os.environ
  -> rollback test (intentional fail mid-run, verify DB restored)
  -> e2e on staging
  -> update src/migrate/README (new env vars)
</state>
