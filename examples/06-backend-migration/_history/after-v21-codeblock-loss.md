<!--
HISTORICAL ARTIFACT — preserved as evidence, not as a canonical compression.

This is the v2.1.0 BOTSPEAK compression of examples/06-backend-migration/before.md.
v2.1.0 dropped 18 of 20 fenced code blocks (Mermaid, YAML, SQL) during compression
despite the skill instructing otherwise. v2.2.0 added a code-block parity count check
(SPEC §9 pitfall 15) that refuses to emit a compression with mismatched fence counts.

The canonical v2.2.0 compression is at examples/06-backend-migration/after.md.
It preserves all 10 distinct fenced blocks (some appear in both top-level and the
embedded bootstrap section).
-->

# Backend Migration: n8n → `data_acquisition_and_processing`

@defs
  HP = human prose
  BT = BOTSPEAK
  DAP = data_acquisition_and_processing workflow
  N8N = n8n Cloud (orchestration platform)
  SPA = Supabase
  VRL = Vercel
  PG = Postgres
  EF = Edge Function
  ORC = orchestrator
  WKR = worker
  SFTP = Soviet SFTP sync
  HC = Healthchecks.io
  PP = pipeline_runs table
  DPS = data_processing_status (existing, per-phase ledger)
  DAG = directed acyclic graph
@end

default-phase: [ALWAYS]

## status-snapshot
status: draft v1 · pending review
branch: `feat/replace-n8n` · target folder: `backend/workflows/DAP/` · decommission: `backend/workflows/menu_registry_and_backfill/`
last-updated: 2026-04-21

## executive-summary

[ALWAYS]
  replace N8N orchestration with:
    - master-ORC (EF triggered by pg_cron)
    - VRL cron + serverless SFTP worker (only non-SPA compute)
    - existing PGMQ + worker pattern (already powers 7/21 phases)
    - independent HC monitor (system cannot silently fail)
    - admin dashboard (SPA + Next.js frontend)

  migration scope: glue replacement · algorithms stay · ~90% heavy lifting already in EF/RPC/PGMQ
  architecture: ~200 lines SQL + ~300 lines EF code (boring · Postgres-native)
  folder structure: build DAP alongside running system → decommission old at end

## why-migrate

trigger-event: 2026-04-13 · N8N "Establishment ORC" workflow failed every morning
  node: "Filter Nightly Sync" (trivial JS Code node)
  error: "Task request timed out after 60 seconds"
  impact: !! pipeline produced zero data for entire week
  discovery: 2026-04-21 weekly meeting (silent failure · no alert path)

root-cause: error → n8n downstream blocked → error-email node never runs → no alert
  architectural-defect: system depends on itself to report its own failure
  solution: [ALWAYS] !! independent heartbeat (HC) fires when expected work doesn't happen

even-if-n8n-fixed, migrate anyway:
  1. code-first better for AI-assisted dev (vs visual editor + copy-paste friction)
  2. N8N reliability: CompoundingIssues (TaskRunner beta · MCP gaps · breaking releases)
  3. timing: onboard new establishments soon → migrate before multi-tenant load
  4. N8N surface shrunk: orchestration = cron + sequence + polling + email (~small)
  5. dashboard wanted anyway (system health · multi-tenant view)

## current-state

architecture (hybrid):
  n8n: orchestration
  SPA: heavy-lifting (EF · RPC · PGMQ workers)
  
phases-already-off-n8n (Edge Function ORC + pg_cron workers + PGMQ queues):
  02 import_csv_to_database · 06 backfill_menu_group_ids · 09 backfill_wine_ids
  10 backfill_menu_item_ids · 11 daily_loss_items · 12 sales_data_aggregated · 13 order_rounds
  pattern: Day-Based Worker Pipeline · resumable · observable · fault-tolerant · months in production

phases-still-in-n8n (small surface):
  trigger: n8n Schedule Trigger (daily 2am EST) -> pg_cron
  fan-out: "Filter Nightly Sync" Code node + loop -> Master ORC EF (SQL query)
  sequencing: "Data Ingest & Table Building" workflow nodes -> PP state machine
  polling: n8n loop + httpRequest nodes -> PP advance loop (pg_cron every 1 min)
  SFTP: n8n SFTP nodes -> VRL cron + serverless worker
  failure-alert: n8n Email node -> HC + dashboard

docs-reference (must-read):
  [REFERENCE] DAILY_AND_ONBOARDING_OVERVIEW.md — hybrid orchestration · modes · error handling
  [REFERENCE] PIPELINE_DIAGRAMS.md — 6 Mermaid diagrams · full pipeline · registry · PGMQ pattern · lineage
  [REFERENCE] DAY_BASED_WORKER_PIPELINE.md — PGMQ + pg_cron + EF pattern (preserved in new system)
  [REFERENCE] README_MENU_REGISTRY_AND_BACKFILL.md — 21-phase index

docs-to-create:
  - Master ORC design doc (PP state machine)
  - SFTP service deployment doc (VRL function · env · retry/backoff · chunked onboarding)
  - HC + alerting doc
  - Admin dashboard doc
  - Cutover runbook
  - Decommission checklist

## target-architecture

components:
  pg_cron-daily: daily 02:00 ET trigger
  pg_cron-advance: every 1 min (poll phase progress)
  pg_cron-heartbeat: post-run ping to HC
  master-ORC: EF driven by cron
  PP: state machine (current_phase · status · timestamps · error)
  existing-phases: 02..20 ORC/WKR (unchanged)
  VRL-SFTP-cron: daily 02:00 ET
  VRL-SFTP-fn: chunked · idempotent · per-establishment
  HC: independent monitor
  dashboard: Next.js /admin/pipeline

daily-run-sequence:
  [ALWAYS]
    pg_cron-daily -> master-ORC (invoke)
    master-ORC -> PP (INSERT run per establishment · status=pending · current_phase=01_sftp)
    master-ORC -> VRL-SFTP (POST per establishment)
    VRL-SFTP -> SPA Storage (upload missing CSVs)
    master-ORC -> PP (UPDATE current_phase=02_import_csv)

  loop (pg_cron-advance every 1 min):
    master-ORC -> PP (SELECT running runs)
    master-ORC -> phase (status check)
    
    alt phase-complete:
      master-ORC -> next-phase (invoke ORC)
      master-ORC -> PP (UPDATE current_phase=next)
    alt phase-running:
      noop
    alt phase-failed:
      master-ORC -> PP (UPDATE status=failed · error=...)

  end-of-run:
    master-ORC -> PP (UPDATE status=completed)
    master-ORC -> HC (GET https://hc-ping.com/<uuid>)

design-rationale:
  [ALWAYS]
    !! no long-running processes (all return within seconds)
    !! advancement poll-driven (same model as existing PGMQ)
    !! recovery automatic (stuck run picked by next loop tick)
    !! HC genuinely independent (pipeline cannot silence it)
    !! per-establishment isolation (one fail doesn't block others)
    !! multi-tenant from day-one (nightly_sync config respected)

heavy-phase-performance:
  pattern: phase-internal fan-out unchanged
    ORC fires pg_cron job (process ~60 days at time)
    each chunk → PGMQ per-day jobs
    multiple WKR pull from queue in parallel
    phase-done when completed-days-count == total-days
  master-ORC doesn't care HOW phase completes · only calls ORC + polls status
  existing-pattern preserved · performance proves out (10-min weekly backfill is real data)

new-components:
  | Component | Location | Replaces |
  | --- | --- | --- |
  | pg_cron daily trigger | shared/database/migrations/<date>_pipeline_cron.sql | N8N Schedule |
  | master_ORC EF | supabase/functions/master_orchestrator/ | Establishment ORC + Data Ingest workflow |
  | PP table | shared/database/migrations/<date>_pipeline_runs.sql | N8N execution history |
  | pg_cron advance loop | same migration | N8N wait + poll |
  | /api/cron/sftp-sync | frontend/app/api/cron/sftp-sync/route.ts | N8N SFTP + Soviet Sync |
  | vercel.json cron | frontend/vercel.json | N8N Schedule for SFTP |
  | HC check | external | (net-new) |
  | dashboard | frontend/app/admin/pipeline/ | manual N8N UI |

## sftp-decision

constraint: Soviet delivers daily CSV over SFTP · !! SPA EF cannot make outbound TCP/SSH
evaluation:
  | option | cost | pros | cons | verdict |
  | --- | --- | --- | --- | --- |
  | A. VRL cron + fn | $0 (already Pro) | same project · git deploy · 1-min cron · 800s duration + Fluid | onboarding chunks need 1400+ days ÷ 2 files · cold-start ~1s | **PRIMARY** |
  | B. small VPS (Fly/Railway/Hetzner) | $5/mo | no timeout · persistent · always-on | another vendor · CI/CD · uptime risk | backup |
  | C. DreamHost cron | already paying | owned · no vendor | spotty · low uptime confidence | skip |
  | D. MFT-as-service | $100–500+/mo | SLA | overkill · vendor lock | skip |
  | E. GitHub Actions cron | $0 | zero infra | 5–15 min drift · token mgmt · logs elsewhere | skip |
  | F. AWS Lambda + EventBridge | ~$0 | mature | new vendor · new IAM · new pipeline | skip |
  | G. Cloudflare Workers | $0 | edge | ssh2-sftp-client not supported | skip |

recommended-approach:
  endpoint: POST /api/cron/sftp-sync
  inputs: { establishment_id · mode: "daily" | "onboarding" · max_files?: number }
  
  [ALWAYS]
    read establishment SFTP config from establishment_settings (no hardcoding)
    list remote SFTP folders:
      daily: yesterday + last 3 days (catch-up window)
      onboarding: data_start_date to today
    compare vs data_processing_status (find missing)
    process up to max_files (default 100 · ~100s work)
    per-file: download → SPA Storage → INSERT data_processing_status (phase_01_status=completed)
    return { synced: N · pending: M · has_more: bool }

  daily-mode: VRL cron once at 02:00 ET · calls endpoint per establishment · idempotent
  onboarding-mode: master-ORC calls in loop (mode=onboarding · max_files=100 · loop until has_more=false)
    2800 files ≈ 28 invocations ÷ 100s each = ~50 min onboarding
    chunked-worker-model: same as existing PGMQ

sftp-risks:
  ~~Soviet IP allowlist~~ **RESOLVED** (operator 2026-04-21): SSH-key auth only · no IP restriction
  long-onboarding: rate-limit VRL concurrency (avoid hammering Soviet)
  cold-start: ~1s per day (negligible)
  single-vendor: HC catches if VRL outage on same morning

future: Soviet API (when granted) replaces entire SFTP path with HTTPS · zero non-SPA compute

## phase-mapping

| Old (n8n) | New | Notes |
| --- | --- | --- |
| Schedule Trigger | pg_cron + VRL cron | belt-and-suspenders · both invoke idempotent endpoints |
| Establishment ORC | master_ORC EF | queries establishments where nightly_sync=true |
| Filter Nightly Sync | SQL WHERE clause | 30-line JS → 3 lines SQL |
| Soviet Sync (SFTP) | VRL /api/cron/sftp-sync | chunked · idempotent · per-establishment |
| Data Ingest & Table Building | PP state machine + advance loop | phase sequence is data · not workflow nodes |
| httpRequest nodes (call ORC) | master-ORC HTTP calls | same EF targets · different caller |
| status-check loops | advance loop (1 min) | same pattern · runs in pg_cron |
| Failure Email | HC alert + dashboard + Resend | independent paths |

## folder-reorganization

problem: old layout (00_ · 01_ · 05B_) mixed sort-hints with execution-contract
fix: separate concerns (dbt/Dagster/Airflow approach)
  - folder-names: kebab-case + leading number (sort only) · spaced in 10s (room to insert)
  - manifest: source-of-truth for execution order · references phases by stable id

new-layout:
  ```
  00-establishment-orchestrator/      # block 0 — entry/dispatch
  10-data-sync/                       # block 10 — ingestion (VRL SFTP)
  12-data-import/                     #           (CSV → PG · PGMQ WKR)
  20-setup-and-validation/            # block 20 — preparation
  30-menu-group-registry/             # block 30 — registry
  32-mark-exceptions/
  34-classify-menu-groups/
  36-backfill-menu-group-ids/
  40-wine-registry/                   # block 40 — wine
  42-backfill-wine-ids/
  50-menu-item-registry/              # block 50 — menu items
  52-backfill-menu-item-ids/
  60-daily-loss-items/                # block 60 — derived/aggregations
  62-sales-data-aggregated/
  64-order-rounds/
  66-availability-history/
  68-daily-establishment-summary/
  70-classify-job-titles/             # block 70 — employee
  80-reserved/                        # block 80 — future expansion
  90-heartbeat-and-alerting/          # block 90 — operational
  92-admin-dashboard/
  ```

manifest (`backend/workflows/DAP/pipeline.yml`):
  ```yaml
  version: 1
  name: data_acquisition_and_processing
  phases:
    - id: establishment_orchestrator
      dir: 00-establishment-orchestrator
      type: orchestrator
      next: data_sync
    - id: data_sync
      dir: 10-data-sync
      type: external_worker  # VRL function
      next: data_import
    # ... (each phase declares next by id)
    - id: classify_job_titles
      dir: 70-classify-job-titles
      next: null             # terminal
  ```

per-phase-folder:
  ```
  NN-phase-name/
  ├── README.md               # what · inputs · outputs · error modes
  ├── code/
  └── migrations/             # rare; usually shared
  ```

master-ORC loads pipeline.yml once at startup · builds DAG by id · never touches folder-names
adding-phase: pick unused number · create folder · add manifest entry
renaming-folder: change `dir` in manifest · done
renumbering: change `dir` · code still references by `id`
contract: `id` never renamed without migration

## database-changes

additive-only:
  - PP table: one row per (establishment_id · run_date) with phase id · status · timestamps · error
  - optional pipeline_phase_runs: per-phase timing (v2 · can defer)
  - pg_cron jobs: daily trigger + advance loop

!! no changes to sales_data · immutability-rule holds

PP is loaded by master-ORC at startup · cached for invocation
changes to manifest take effect on next cron tick · no DB migration needed (manifest IS migration)

## migration-phases

shadow-first (prove parity before cutting over) · n8n stays running entire time

timeline:
  engineering-estimate (assistant): 3–4 weeks focused work
  operator-prediction (2026-04-21 16:00 ET): end-of-day 2026-04-22 (~30 hours)
  skip: "stop bleeding" HC-on-n8n · go straight to new system
  
  actual: <TBD>

### phase-A (shadow) — days 1–2 operator / weeks 1–3 assistant

goal: stand up DAP infrastructure · no production impact

  A1. create DAP skeleton + pipeline.yml
  A2. migration: PP table
  A3. EF: master_ORC (basic · can sequence · no error recovery yet)
  A4. VRL: /api/cron/sftp-sync (daily-mode only)
  A5. pg_cron jobs (commented out / disabled)
  A6. smoke-test: manually invoke master-ORC one establishment · test schema
  
  exit: master-ORC completes end-to-end · results match n8n on same date

### phase-B (parity-validation) — days 1–2 operator / weeks 3–4 assistant

goal: run new pipeline against settled historical dates · prove zero-diff parity

mechanism: no shadow_mode flag · no shadow schema
  existing pipeline is idempotent on rerun
  new ORC runs vs dates n8n already processed days ago
  if everything idempotent · diff = zero
  if diff nonzero · either new-ORC bug OR latent non-idempotency in existing phase (both valuable to find)

  B1. **precondition**: idempotency-audit all phases 12–70 (rerun on settled date · confirm zero row changes)
  B2. pick settled date (e.g. 7 days ago) · snapshot relevant tables
  B3. manually invoke new master-ORC for (Fred's Italian Bistro · settled_date)
  B4. diff post vs pre snapshot · expected: empty
  B5. repeat 3 different settled dates
  B6. final: trigger new master-ORC for one fresh date AFTER n8n completes · diff again
  
  exit: 3+ settled-date reruns produce zero diffs + 1 same-day post-n8n rerun = zero diff

### phase-C (cutover) — day after shadow validates

  C1. disable N8N Schedule Trigger
  C2. new pipeline out of shadow (write to production)
  C3. watch 3 daily runs closely
  C4. keep n8n files in repo + account active 2 weeks (rollback option)
  
  exit: 3 successful production runs

### phase-D (decommission) — after 2 weeks clean production

  D1. archive n8n JSONs to _archive/<date>_n8n_workflows/
  D2. delete workflows in N8N account
  D3. cancel N8N subscription (or downgrade free)
  D4. delete menu_registry_and_backfill/ entirely
  D5. update root README · CLAUDE.md · QUICK_REFERENCE (remove N8N refs)
  
  exit: zero N8N references anywhere

### phase-E (dashboard) — parallel track

  E1. /admin/pipeline · gated to admin/superadmin/dev roles
  E2. recent PP list (status · phase · timing)
  E3. drill-down: per-phase progress · error details · retry button
  E4. live today-run status across all establishments
  E5. HC integration (manage check · surface alert state)
  
  genuinely useful in shadow mode · build in parallel by separate workstream

## risks-and-mitigations

| risk | impact | likelihood | mitigation |
| --- | --- | --- | --- |
| shadow diffs reveal logic differences | high | medium | phase-C catches · don't cutover until 5 clean days |
| Soviet requires fixed source IP | high | low | verify first (phase-B1) · fallback to VPS if true |
| VRL timeout during onboarding chunk | medium | low | tuned to 100 files (~100s) · well under 800s |
| VRL + SPA outage same day | high | very low | HC independent · alert within hours |
| pg_cron advance falls behind | medium | low | 1-min interval · phase ORC async anyway |
| master-ORC bug · all establishments break | high | medium | start one establishment (Fred's) 1 week before others |
| decommission too early | medium | low | keep 2 weeks post-cutover · archive N8N JSONs permanently |
| new person can't find docs (folder rename) | low | medium | update README + CLAUDE.md · add forwarding pointer in _archive/ |

## workstream-contracts

two-parallel-chats build this · shared contracts below = single-source-of-truth

### ownership

backend-chat (writes):
  supabase/functions/master_orchestrator/
  supabase/functions/<phase_name>/ (port existing)
  frontend/app/api/cron/sftp-sync/route.ts (VRL worker · backend code)
  frontend/vercel.json (cron entries)
  shared/database/migrations/ (PP table · pg_cron jobs)
  backend/workflows/DAP/ (entire new workflow folder · all phase READMEs · pipeline.yml)
  HC outbound ping in master-ORC (env-gated · ~10 lines)
  rerun phase EF endpoint (dashboard retry button)

frontend-chat (writes):
  frontend/app/admin/pipeline/ (entire dashboard route)
  frontend/components/admin/ (admin-only UI)
  frontend/lib/admin/ (admin-only client utils)
  HC account · check · alert-routing (healthchecks.io · not code)
  UI: alert state · run drill-downs · retry buttons
  read-side queries PP (consume only)

out-of-scope:
  Resend/email routing (HC native sufficient for v1)
  SMS escalation
  multi-user alert distribution (defer post-cutover)
  onboarding workflow UI (separate feature)

### PP table contract

two-ledgers · two-granularities:
  | table | granularity | owner | purpose |
  | --- | --- | --- | --- |
  | PP | one row per (establishment_id · run_date · mode) | master_ORC writes | orchestration — which phase currently |
  | DPS | one row per (establishment_id · date) + per-phase columns | phase WKR update own | per-phase work — what each phase completed |

master-ORC reads DPS ("is current phase done?") · writes PP ("now on phase X")
dashboard: PP = "what is ORC doing right now?" · DPS = "what work has each phase completed?"

backend-chat creates PP migration · frontend consumes read-only (except retry via backend endpoint)
backend may add columns · !! never rename/remove without coordinated update

```sql
CREATE TABLE pipeline_runs (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id    UUID NOT NULL REFERENCES establishments(establishment_id),
  run_date            DATE NOT NULL,              -- business date this run processes
  mode                TEXT NOT NULL,              -- 'daily' | 'onboarding' | 'manual'
  status              TEXT NOT NULL,              -- 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'
  current_phase_id    TEXT,                       -- stable phase id from pipeline.yml; NULL when pending/completed
  started_at          TIMESTAMPTZ,
  completed_at        TIMESTAMPTZ,
  error_message       TEXT,
  error_phase_id      TEXT,                       -- which phase failed (if any)
  triggered_by        TEXT NOT NULL,              -- 'pg_cron' | 'manual' | 'retry' | 'onboarding'
  metadata            JSONB DEFAULT '{}',         -- flexible per-phase state
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (establishment_id, run_date, mode)
);
CREATE INDEX idx_pipeline_runs_status ON pipeline_runs(status) WHERE status IN ('pending', 'running');
CREATE INDEX idx_pipeline_runs_recent ON pipeline_runs(created_at DESC);
```

status-state-machine:
  pending → running → completed
              ↓
            failed → (retry creates new run · triggered_by='retry')
              ↓
          cancelled (manual-override only)

optional-v2: pipeline_phase_runs (per-phase timing) · defer until dashboard demands

### environment-variables

both-chats need these · operator provides HC values (account setup) · devs set in SPA/VRL env

| var | provided-by | consumer | required? | purpose |
| --- | --- | --- | --- | --- |
| HEALTHCHECKS_PING_URL | operator (healthchecks.io) | backend (master-ORC ping at run-end) | no (noop if unset) | outbound success heartbeat |
| HEALTHCHECKS_CHECK_UUID | operator (UUID part of ping URL) | frontend (HeartbeatBanner reads status) | no (banner shows "not configured") | identifies check for read API |
| HEALTHCHECKS_READ_API_KEY | operator (read-only API key) | frontend (HeartbeatBanner) | no | auth for hc read API |
| MASTER_ORCHESTRATOR_URL | backend (post-deploy) | frontend (dashboard retry proxy) | yes (post-button-ship) | base URL for master-ORC EF |
| SUPABASE_SERVICE_ROLE_KEY | already exists | both | already exists | RPC + admin reads |

SFTP-credentials: per-establishment from establishment_settings.soviet_config.sftp_credentials_key → SPA Vault
!! no hardcoding · no env vars

### retry-endpoint-contract

backend-chat exposes:
  ```
  POST /functions/v1/master_orchestrator/retry
  Authorization: Bearer <user JWT with admin/superadmin/dev role>
  Body: { "pipeline_run_id": "uuid", "from_phase_id": "<phase_id>" | null }
  Response: { "new_pipeline_run_id": "uuid", "status": "pending" }
  ```

behavior: create NEW PP row · triggered_by='retry' · link via metadata.retried_from
original row untouched · frontend builds button · calls endpoint · updates dashboard

### concurrency-rules

[ALWAYS]
  !! one in-flight PP row per (establishment_id · run_date · mode) (UNIQUE constraint enforces)
  !! master-ORC checks before starting
  stuck-run-timeout: running > 6 hours old → marked failed · error='timeout'
  cron-fires-while-previous-running: master-ORC detects existing running row → logs · returns no-op
  onboarding-doesn't-block-daily: distinct rows (UNIQUE includes mode) → can run concurrently

### shadow-mode-strategy

[REFERENCE] phase-B: no flag · no shadow schema
run new ORC vs settled dates · prove zero-diff
frontend: no UI gates on shadow flag (doesn't exist) · dashboard shows whatever's in PP

### phase-ids-stable

[ALWAYS]
  id field in pipeline.yml (e.g. data_sync · menu_group_registry) is contract
  both chats reference phases by id
  !! renaming id = breaking change (coordinated update required)
  adding phase = non-breaking

## open-questions-and-decisions

all-dated 2026-04-21 unless-noted

1. ~~**Soviet SFTP IP allowlisting**~~ **RESOLVED** (operator): SSH-key auth only · Vercel-as-host confirmed
2. ~~**Email delivery**~~ **DEFERRED** (operator): HC native sufficient v1 · Resend post-cutover
3. ~~**HC plan**~~ **RESOLVED — FREE TIER** (operator): 20-check ceiling · abundant · SMS deferred
4. ~~**PP retention**~~ **RESOLVED — KEEP FOREVER** (operator): ~365 rows/year/est trivial
5. ~~**Per-establishment runtime budget**~~ **RESOLVED — 06:00 ET** (operator): 4-hour window post-02:00 trigger · HC grace period
6. ~~**Onboarding throttling**~~ **RESOLVED — 1 VRL INVOCATION EVERY 30 SECONDS** (operator): conservative · tune up if Soviet tolerates
7. ~~**Alert distribution**~~ **RESOLVED — OPERATOR ONLY v1** (operator): single recipient · add second post-cutover
8. **Future: Soviet API** — when granted · entire VRL SFTP service replaced with HTTPS · zero non-SPA compute
   build modular (single-responsibility WKR · SFTP details don't leak to master-ORC) so swap is clean

## healthchecks.io-setup (operator-once)

~5 min · operator account so alerts go directly to inbox

1. sign up <https://healthchecks.io/> with admin email
2. create check: **"Production data pipeline"**
3. schedule:
   - type: **Simple**
   - period: **24 hours** (ping once per successful daily run)
   - grace: **4 hours** (alert if no ping by 06:00 ET · given 02:00 trigger)
4. save · copy **ping URL** (https://hc-ping.com/<uuid>)
5. Settings → API Access · create **read-only API key**
6. provide to dev chats:
   - HEALTHCHECKS_PING_URL = full URL → backend
   - HEALTHCHECKS_CHECK_UUID = <uuid> part → frontend
   - HEALTHCHECKS_READ_API_KEY = key → frontend

until values provided: both ping + HeartbeatBanner noop gracefully (no errors · no broken UI)

post-cutover optional:
  add second recipient
  consider Hobbyist ($5/mo) if SMS escalation needed

## reference-links

[REFERENCE] existing-docs (feed this plan):
  DAILY_AND_ONBOARDING_OVERVIEW.md
  PIPELINE_DIAGRAMS.md
  DAY_BASED_WORKER_PIPELINE.md
  README_MENU_REGISTRY_AND_BACKFILL.md
  README_ORCHESTRATOR.md
  README_DATA_SYNC.md
  soviet_sync_v02.json
  01_daily_establishment_orchestrator.json

[REFERENCE] external:
  https://vercel.com/docs/functions/limitations
  https://vercel.com/docs/cron-jobs
  https://healthchecks.io/
  https://supabase.com/docs/guides/database/extensions/pg_cron
  https://www.npmjs.com/package/ssh2-sftp-client

## appendices

### why-not-inngest-trigger-dev-temporal

pipeline = 15-step linear DAG · not branching complex-conditional workflows
PGMQ + pg_cron + WKR already handles fan-out · retries · resumability for heavy phases
cost: another vendor · auth model · deploy pipeline · billing · AI-learning overhead
custom PP state machine = ~200 lines SQL + ~300 lines EF (boring · maintainable by one person)
revisit if: grow to dozens branching workflows · complex retry semantics

### why-not-stay-on-n8n-with-better-monitoring

HC heartbeat (phase-A) closes silent-failure hole regardless-of-platform
if silent-failure only problem · could stop there
reasons to migrate anyway:
  1. maintainer-ergonomics: code-first > visual-editor for AI-assisted dev
  2. reliability: N8N multi-year track of breaking releases (TaskRunner latest)
  3. vendor-consolidation: remove N8N · stay SPA + VRL only (two vendors · not three)
  4. cost: N8N subscription disappears
  5. learning-curve: contributors know SQL + TS already (don't need N8N quirks)
migration-cost (3–4 weeks) recouped within months in maintenance time
