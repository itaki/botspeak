[HANDOFF] DishData · branch: feature/mv-refresh · 2026-05-04

@defs
  E   = establishment_id
  ME  = migration-engine
  MV  = materialized-view
@end

context: project = BUILD migration system / not ops · current test = Amano (expendable)

done: db-pool(src/db/pool.py) ✅ · field-mapping(src/migrate/mapping.py · 47 fields) ✅
      sentry-logging ✅ · admin-dashboard websocket ✅ · n8n-trigger ✅

bugs (fix before staging):
  🔴 src/migrate/validate.py:247 → missing E filter → returns ALL tenants → add WHERE E = :E
  🔴 src/migrate/engine.py:89 → hardcoded N8N webhook URL → use os.environ['N8N_WEBHOOK_URL']

todo (in order):
  1. rollback-test → intentional fail mid-run → verify ME restores DB
  2. e2e on staging
  3. update src/migrate/README (new env vars)

[ALWAYS] 🔴 INVARIANT: BUILD system / DO NOT do ops · test-data = expendable · errors = good (reveal automation gaps)
[ALWAYS] branch = feature/mv-refresh only · unrelated request → stop → A/B/C
