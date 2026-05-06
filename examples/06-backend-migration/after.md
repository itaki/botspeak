# Backend Migration: Replace n8n with `data_acquisition_and_processing`

@defs
  N8N = n8n Cloud orchestration platform (being replaced)
  EF = Supabase Edge Function
  CRN = pg_cron Postgres job scheduler
  PQ = PGMQ queue + worker pattern
  SB = Supabase (compute, storage, database)
  VRL = Vercel serverless cron + functions
  EST = establishment (per-tenant entity)
  DPS = data_processing_status table (existing; tracks per-phase completion)
  HC = Healthchecks.io (independent heartbeat monitor)
  SFTP = SSH file transfer (only constraint: needs non-SB compute due to no TCP/SSH from EF)
@end

---

[NEW-CHAT] **Status**: Draft v1 — pending review
[NEW-CHAT] **Branch**: `feat/replace-n8n` | **Author**: Architecture | **Last updated**: 2026-04-21
[NEW-CHAT] **Target folder**: `backend/workflows/data_acquisition_and_processing/` (new)
[NEW-CHAT] **Decommission**: `backend/workflows/menu_registry_and_backfill/` (end of migration)

---

## 1. Executive Summary

[NEW-CHAT] Replacing N8N orchestration with: CRN daily trigger → EF master_orchestrator → CRN advance loop (every 1 min) → existing SB EF/PQ workers (phases 02–20 already off N8N) + VRL SFTP worker (only non-SB piece).

[NEW-CHAT] Migration is ~90% glue replacement, not algorithm. Heavy lifting already in SB EF/RPC/PQ. N8N = fancy UI for calling EF; replacing with CRN + state machine.

[NEW-CHAT] Build alongside running system in new folder, decommission cleanly at end. Build w/ zero production impact.

---

## 2. The Trigger Event & Why Silent Failure Is Architectural

[ON-TRIGGER] ~2026-04-13: N8N "Establishment Orchestrator" failed at first node ("Filter Nightly Sync" Code node — trivial JS) with `Task request timed out after 60 seconds` from N8N Cloud TaskRunner subprocess. **Pipeline silently produced zero data for entire week.** Weekly report meeting (2026-04-21) surfaced failure.

[NEW-CHAT] **The failure path** (architectural problem):
```
N8N Code node fails to start
  ↓
nothing downstream runs
  ↓
nothing reaches "send error email" node (also in N8N)
  ↓
no alert
```

!! System depends on itself to report its own failure. **Critical invariant: need independent heartbeat outside pipeline it monitors.** → HC (external service).

[NEW-CHAT] **Why move off N8N anyway** (even after code-node bug fixed in 2.17.3):

1. One operator maintains all; visual editor ↔ Claude/Cursor = friction; code-first = diff/review/AI-editable
2. N8N Cloud: compounding reliability (TaskRunner beta, MCP gaps, frequent breaking releases)
3. About to onboard new EST; better to migrate _before_ multiple tenants depend on current system
4. N8N's actual job: cron trigger → sequence phases → poll "done" → email. Very small surface. ~few hundred lines in CRN + state machine.
5. Dashboard we want = genuinely useful anyway (system health, multi-tenant view)

[NEW-CHAT] **What stays in N8N during migration**: nothing. Full replacement on new branch, shadow-mode parity validation, cutover. N8N stays running in prod until cutover day, then archived.

---

## 3. Current State: Hybrid n8n + Supabase

[REFERENCE] **Existing pipeline layers**:

- Cron: N8N Schedule Trigger (daily 2am EST)
- Orchestration: N8N Establishment Orchestrator + Data Ingest workflows
- SFTP: N8N SFTP nodes → Supabase Storage
- Heavy lifting: EF orchestrators + PQ workers + CRN (phases 02–20 already off N8N)
- Database: Postgres (sales_data, registries, etc.)
- Alerting: N8N Email node (broken during failure)

[REFERENCE] **Phases already off N8N** (EF + PQ + CRN pattern, proven in prod for months):
- 02: import_csv_to_database
- 06: backfill_menu_group_ids
- 09: backfill_wine_ids
- 10: backfill_menu_item_ids
- 11: daily_loss_items
- 12: sales_data_aggregated
- 13: order_rounds

Pattern: [Day-Based Worker Pipeline](../../backend/workflows/menu_registry_and_backfill/DAY_BASED_WORKER_PIPELINE.md) — resumable, observable, fault-tolerant, production-proven.

[REFERENCE] **Small N8N surface**:

| Responsibility | Old (N8N) | New |
|---|---|---|
| Daily 2am EST trigger | N8N Schedule Trigger | CRN job |
| Per-EST fan-out | "Filter Nightly Sync" Code node | Master orchestrator EF (SQL query) |
| Phase sequencing | "Data Ingest & Table Building" nodes | `pipeline_runs` state machine, advanced by CRN |
| Polling "done" | N8N loop + httpRequest | `pipeline_runs` advance loop (CRN every 1 min) |
| SFTP → SB Storage | N8N SFTP nodes | VRL cron + serverless SFTP worker |
| Failure email | N8N Email node | HC + dashboard alerts |

[REFERENCE] **Existing system docs** (read in this order):

1. DAILY_AND_ONBOARDING_OVERVIEW.md (hybrid orchestration, daily vs onboarding, error handling)
2. PIPELINE_DIAGRAMS.md (6 Mermaid diagrams: full pipeline, registry/dedupe, companions, settings→phase routing, PQ orchestrator pattern, lineage)
3. DAY_BASED_WORKER_PIPELINE.md (PQ + CRN + EF pattern; **preserved in new system**)
4. README_MENU_REGISTRY_AND_BACKFILL.md (index of 21 phases)

---

## 4. Target Architecture

[NEW-CHAT] **Components**:

- CRN daily trigger (02:00 ET) → master_orchestrator EF
- CRN advance loop (every 1 min) → poll phase orchestrators, advance `pipeline_runs` state machine
- `pipeline_runs` table: one row per (EST_id, run_date, mode); tracks current phase, status, timestamps, error
- VRL SFTP worker (01:00, 02:00, parallel during onboarding): idempotent, chunked (default 100 files ~100s per invocation)
- HC: independent heartbeat ping after each successful run (4-hour grace window → alert if no ping by 06:00 ET)
- Existing EF orchestrators (phases 02–20): unchanged
- Existing PQ workers: unchanged
- Admin dashboard: `/admin/pipeline` (live status, drill-down, retry button)

[NEW-CHAT] **Daily run sequence**:

1. CRN fires → master_orchestrator
2. Master queries EST WHERE nightly_sync=true → INSERT `pipeline_runs` row (per EST) with status='pending', current_phase='01_sftp'
3. Master POST to VRL SFTP worker (per EST)
4. SFTP worker uploads missing CSVs → returns { synced: N, pending: 0 }
5. Master UPDATE `pipeline_runs`: current_phase='02_import_csv', status='running'
6. CRN advance loop (every 1 min): SELECT `pipeline_runs` WHERE status='running' → check phase status → if complete, invoke next phase; if failed, UPDATE status='failed'
7. When all phases done: UPDATE status='completed' → POST HC ping

[NEW-CHAT] **Why this design**:

- No long-running processes. Everything returns within seconds; advancement = polling. Same as existing PQ pipeline.
- Recovery automatic. Stuck `running` row past expected window picked up by next advance loop. Failed phase retried without rerunning earlier phases.
- HC heartbeat independent. Can't be silenced by pipeline failure.
- Per-EST isolation. One EST failure ≠ block others.
- Multi-tenant from day one. Queries EST list; respects `processing_config.nightly_sync`.

[NEW-CHAT] **Heavy-phase performance** (preserved unchanged):

Phases like backfill_menu_item_id (millions of rows) use internal fan-out: phase orchestrator fires CRN chunk job (~60 days) → PQ jobs per day → workers process concurrently → phase "done" when count matches.

New master orchestrator doesn't care _how_ phase completes; calls orchestrator, polls status checker. Heavy phases continue internal fan-out; light phases run inline.

Polling interval (1 min CRN advance) must be _faster_ than heavy-phase completion granularity. Current polling fine. If chunks shrink <1 min, increase advance-loop frequency.

[NEW-CHAT] **New components inventory**:

| Component | Lives in | Replaces |
|---|---|---|
| CRN daily trigger | `shared/database/migrations/<date>_pipeline_cron.sql` | N8N Schedule Trigger |
| master_orchestrator EF | `supabase/functions/master_orchestrator/` | N8N Establishment Orchestrator + Data Ingest |
| `pipeline_runs` table | `shared/database/migrations/<date>_pipeline_runs.sql` | N8N execution history |
| CRN advance loop | same migration | N8N's "wait + poll" nodes |
| SFTP worker | `frontend/app/api/cron/sftp-sync/route.ts` (VRL) | N8N SFTP nodes + Soviet Sync |
| vercel.json cron entry | `frontend/vercel.json` | N8N Schedule Trigger for SFTP |
| HC check | external service | (net new) |
| Admin dashboard | `frontend/app/admin/pipeline/` | Manual N8N UI inspection |

---

## 5. SFTP Decision

[NEW-CHAT] **Constraint**: SB Edge Functions = Deno-on-Cloudflare runtimes; no outbound TCP/SSH. SFTP needs non-SB compute.

[NEW-CHAT] **Options evaluated**:

| Option | Cost | Pros | Cons | Verdict |
|---|---|---|---|---|
| A. VRL cron + serverless EF | $0 added (Pro) | Same project as frontend; cron to 1 min; 800s duration (Pro Fluid Compute); Node + ssh2-sftp-client native | Onboarding (1400+ days) needs chunking; ~1s cold start | **PRIMARY** |
| B. Small VPS (Fly/Railway/Hetzner) | $5/mo | No timeout; persistent SSH; always-on for HC | One more thing to monitor; CI/CD overhead | Backup |
| C–G. DreamHost / MFT-as-service / GitHub Actions / Lambda / Cloudflare | – | – | Overkill, spotty, unfit, drift, unsupported | Skip |

[NEW-CHAT] **Recommended: VRL cron + chunked SFTP worker**.

Endpoint: `POST /api/cron/sftp-sync`

Inputs: `{ establishment_id, mode: "daily" | "onboarding", max_files?: 100 }`

Behavior:
1. Read EST SFTP config from `establishment_settings` (no hardcoding)
2. List remote SFTP for date range: daily mode = yesterday + 3-day catch-up; onboarding = data_start_date → today
3. Compare vs `data_processing_status` for missing files
4. Process up to max_files per invocation (default 100 → ~100s)
5. For each: download → SB Storage → INSERT `data_processing_status` with phase_01_status='completed'
6. Return `{ synced: N, pending: M, has_more: bool }`

Daily mode: VRL fires 02:00 ET per EST. Master also calls as part of pipeline_run start. Both idempotent.

Onboarding mode: Master calls in loop w/ `mode=onboarding, max_files=100`. Each handles ~100 files in ~100s → `has_more`. For 2800 files: ~28 invocations over ~50 min (well within VRL precision).

Why it fits: chunked-worker model as existing PQ pipeline. SFTP worker = "phase 01 worker" on VRL.

[NEW-CHAT] **SFTP-specific risks & mitigations**:

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Soviet SFTP IP allowlisting | High | Low | ✓ Verified (operator, 2026-04-21): SSH key auth, no IP restriction. Proceed. |
| Long onboarding hammers Soviet | Medium | Low | Rate-limit VRL concurrency (~1 invocation per 30 sec) |
| VRL cold start | Medium | Low | ~1s, negligible for daily, fine for onboarding |
| VRL + SB outage same day | High | Very Low | HC independent; alert within hours |

> **Future**: Soviet API access (when granted) replaces entire SFTP path with HTTPS calls, zero non-SB compute. Build SFTP service modular so swap is clean.

---

## 6. Component Mapping & Phase Naming

[NEW-CHAT] **Phase mapping** (old → new):

| Old (N8N) | New |
|---|---|
| Schedule Trigger (N8N, daily 2am) | CRN job + VRL cron (belt-and-suspenders) |
| Establishment Orchestrator | master_orchestrator EF |
| Filter Nightly Sync Code node | SQL WHERE in master_orchestrator |
| Soviet Sync workflow (SFTP) | `frontend/app/api/cron/sftp-sync` (VRL) |
| Data Ingest & Table Building workflow | `pipeline_runs` state machine + advance loop |
| Per-phase httpRequest nodes | Master orchestrator HTTP calls |
| Per-phase status check loops | Advance loop (CRN every 1 min) reads phase status |
| Failure Email node | HC alert + dashboard alert + Resend |

[NEW-CHAT] **Phase naming & ordering scheme**.

Existing folder layout (`00_`, `01_`, ..., `05B_`, `06_`) mixed sort hints + execution-order contract. Hit `05B` because needed to insert between `05` and `06` (BASIC line-number problem).

Modern fix (dbt, Dagster, Airflow): separate concerns.

**Folder naming**: kebab-case w/ leading number for filesystem sort only. Numbers spaced in 10s (no rename to insert). Never referenced by number from code.

**Manifest**: `pipeline.yml` at workflow root = source of truth for execution order. Phases referenced by stable string IDs.

**Folder layout** for `backend/workflows/data_acquisition_and_processing/`:

```
00-establishment-orchestrator/        # block 0  — entry / dispatch
10-data-sync/                         # block 10 — ingestion (VRL SFTP)
12-data-import/                       #
20-setup-and-validation/              # block 20 — prep
30-menu-group-registry/               # block 30 — registries
32-mark-exceptions/
34-classify-menu-groups/
36-backfill-menu-group-ids/
40-wine-registry/                     # block 40 — wine
42-backfill-wine-ids/
50-menu-item-registry/                # block 50 — menu items
52-backfill-menu-item-ids/
60-daily-loss-items/                  # block 60 — derived data
62-sales-data-aggregated/
64-order-rounds/
66-availability-history/
68-daily-establishment-summary/
70-classify-job-titles/               # block 70 — employee
90-heartbeat-and-alerting/            # block 90 — ops
92-admin-dashboard/
```

**Manifest** `pipeline.yml`:

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
    type: external_worker         # VRL function
    next: data_import
  # ... (each phase declares successor by id)
  - id: classify_job_titles
    dir: 70-classify-job-titles
    next: null                    # terminal
```

Why it works: master_orchestrator reads `pipeline.yml` once at startup, builds directed graph by id, never touches folder names. Add phase: pick unused number in block, create folder, add manifest entry, point predecessor's `next`. No renames, no breaks.

Per-phase folder contents:

```
NN-phase-name/
├── README.md          # what, inputs, outputs, errors
├── code/              # EF source
└── migrations/        # phase-specific migrations (rare)
```

[NEW-CHAT] **Database changes** (additive only):

- `pipeline_runs` table: one row per (EST_id, run_date, mode) with current_phase_id, status, timestamps, error
- `pg_cron` jobs: daily trigger + advance loop
- No changes to existing tables, no `sales_data` migrations

[NEW-CHAT] `pipeline.yml` loaded at function startup, cached for duration. Changes take effect on next cron tick. No DB migration when pipeline shape changes — manifest _is_ the migration.

---

## 7. Phased Rollout Plan

[NEW-CHAT] **Migration runs in shadow mode**: prove parity before cutover. N8N stays running entire time.

> Timeline predictions (2026-04-21):
> - **Engineering estimate**: 3–4 weeks focused work
> - **operator prediction**: end of day 2026-04-22 (~30 hours)
> - **Actual**: `<TBD>`

Decision: skip "stop the bleeding" HC-on-existing-N8N step. Go straight to new system. If N8N breaks before cutover, manual reruns acceptable risk for ~30 hours.

[NEW-CHAT] **Phase A — Build in shadow** (1–2 days):

- A1. Create folder skeleton + `pipeline.yml`
- A2. Migration: `pipeline_runs` table
- A3. EF: `master_orchestrator` (basic — sequence phases, no error recovery yet)
- A4. VRL: `/api/cron/sftp-sync` (daily mode only)
- A5. CRN jobs (disabled at first)
- A6. Smoke test: manually trigger master for one EST in test schema, confirm end-to-end vs n8n

Exit: master completes full per-EST run, results match N8N on same date.

[NEW-CHAT] **Phase B — Shadow mode** (1–2 days):

Goal: run new pipeline against settled historical dates, prove zero-diff parity with N8N.

Mechanism: no shadow flag, no shadow schema. Existing pipeline already idempotent on rerun (N8N reruns failed days routinely w/o corruption). New orchestrator runs against dates N8N processed days ago. If truly idempotent, diff = zero. If diff ≠ zero → bug in new orchestrator OR latent non-idempotency in existing phase (both bugs worth finding).

- B1. **Idempotency audit**: for each phase 12–70, confirm rerun on already-completed date = no row changes. Document any non-idempotent phase, fix before proceeding.
- B2. Pick settled date (e.g., 7 days ago). Snapshot relevant tables filtered to that date.
- B3. Manually trigger new master for `(Fred's Italian Bistro, settled_date)`.
- B4. Diff post vs pre. Expected: empty.
- B5. Repeat for 3 different settled dates.
- B6. Trigger new master for one fresh date _after_ N8N completes it. Diff again. Expected: empty.

Exit: 3+ settled-date reruns = zero diffs, plus 1 same-day post-N8N rerun = zero diff.

Why it works: only way to know parity is real = compare outputs. Because existing system already idempotent, shadow mode = "did new orchestrator change anything it shouldn't?" Sharper test than parallel runs w/ timestamp reconciliation.

[NEW-CHAT] **Phase C — Cutover** (1 day after shadow validates):

- C1. Disable N8N Schedule Trigger
- C2. Switch new pipeline out of shadow (write to prod tables)
- C3. Watch next 3 daily runs closely
- C4. Keep N8N workflow JSONs in repo + N8N Cloud account for 2 weeks as rollback

Exit: 3 successful prod runs from new pipeline.

[NEW-CHAT] **Phase D — Decommission** (after 2 weeks clean prod runs):

- D1. Archive N8N workflow JSONs to `_archive/<date>_n8n_workflows/`
- D2. Delete workflows in N8N Cloud
- D3. Cancel N8N Cloud subscription (or downgrade)
- D4. Delete `backend/workflows/menu_registry_and_backfill/` entirely
- D5. Update root README, CLAUDE.md, QUICK_REFERENCE.md (remove N8N refs)

Exit: no N8N refs anywhere in repo or prod.

[NEW-CHAT] **Phase E — Admin dashboard** (parallel track, simultaneous with A/B):

- E1. `/admin/pipeline` route, gated to admin/superadmin/dev roles
- E2. List recent `pipeline_runs` w/ status, current phase, timing
- E3. Drill-down per-run: phase-by-phase progress, errors, retry button
- E4. Live status of today's run across all EST
- E5. HC integration (manage check, surface alert state in UI)

Dashboard genuinely useful before cutover (shadow mode populates `pipeline_runs`) so build parallel w/ Phase A/B by separate workstream.

---

## 8. Risks & Mitigations

[NEW-CHAT] **Master orchestrator bug breaks all EST** (High impact, Medium likelihood):
- Mitigation: start w/ one EST (Fred's Italian Bistro) for 1 week before adding others

[NEW-CHAT] **Shadow-mode diffs reveal logic we missed** (High impact, Medium likelihood):
- Mitigation: Phase C explicitly catches; don't cutover until 5 clean days

[NEW-CHAT] **Soviet requires fixed source IP for SFTP** (High impact, Low likelihood):
- Mitigation: ✓ Verified (operator, 2026-04-21) — not in play. Proceed.

[NEW-CHAT] **VRL SFTP timeout during onboarding chunk** (Medium impact, Low likelihood):
- Mitigation: chunk tuned to stay well under 800s limit; default 100 files (~100s)

[NEW-CHAT] **VRL + SB outage same day** (High impact, Very low likelihood):
- Mitigation: HC independent; alert within hours

[NEW-CHAT] **CRN advance loop falls behind** (Medium impact, Low likelihood):
- Mitigation: 1 min interval; phases async anyway; minimal impact

[NEW-CHAT] **Decommission `menu_registry_and_backfill/` too early** (Medium impact, Low likelihood):
- Mitigation: don't delete until 2 weeks post-cutover; archive N8N JSONs permanently

[NEW-CHAT] **New person can't find docs (folder name changed)** (Low impact, Medium likelihood):
- Mitigation: update root README + CLAUDE.md; add forwarding pointer in `_archive/`

---

## 9. Shared Contracts Between Workstreams

Two parallel chats building this (backend: orchestrator + SFTP + HC; frontend: admin dashboard). This section = **single source of truth** for shared surface. Either side proposes changes here; change reflected before either codes.

[NEW-CHAT] **Workstream ownership**:

Backend owns (writes):
- `supabase/functions/master_orchestrator/` — master orchestrator EF
- `supabase/functions/<phase_name>/` — new phase orchestrators (porting from existing)
- `frontend/app/api/cron/sftp-sync/route.ts` — VRL SFTP worker (backend code on VRL)
- `frontend/vercel.json` — cron entries
- `shared/database/migrations/` — `pipeline_runs` table, CRN jobs
- `backend/workflows/data_acquisition_and_processing/` — entire new workflow folder + all phase READMEs + `pipeline.yml`
- HC outbound ping in master_orchestrator (env-var-gated, ~10 lines)
- "Rerun phase" EF endpoint for dashboard retry button

Frontend owns (writes):
- `frontend/app/admin/pipeline/` — entire admin dashboard
- `frontend/components/admin/` — admin UI components
- `frontend/lib/admin/` — admin client utilities
- HC account, check, alert routing (healthchecks.io, not code)
- UI for alert state, drill-downs, retry buttons
- Read-side queries against `pipeline_runs` (consume only)

Deferred / out of scope:
- Resend / email routing (HC native email sufficient for v1)
- SMS escalation
- Multi-user alert distribution list (post-cutover)
- Onboarding workflow UI (separate feature)

[NEW-CHAT] **`pipeline_runs` table contract**:

Two ledgers, two granularities:

| Table | Granularity | Owner | Purpose |
|---|---|---|---|
| `pipeline_runs` (NEW) | one row per (EST_id, run_date, mode) | master_orchestrator writes | Orchestration ledger — which phase is orchestrator currently driving |
| `data_processing_status` (EXISTING) | one row per (EST_id, date) w/ per-phase status columns | phase workers update own column | Per-phase work ledger — what work each phase completed for that date |

Master reads DPS (is current phase done?) and writes `pipeline_runs` (we're on phase X now). Dashboard shows both: `pipeline_runs` = "what is orchestrator doing right now?" + DPS = "what work completed?"

Backend creates migration for `pipeline_runs`. Frontend consumes read-only (except retry via backend endpoint). **Backend may add columns; must not rename/remove without coordinated update.**

```sql
CREATE TABLE pipeline_runs (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id    UUID NOT NULL REFERENCES establishments(establishment_id),
  run_date            DATE NOT NULL,
  mode                TEXT NOT NULL,          -- 'daily' | 'onboarding' | 'manual'
  status              TEXT NOT NULL,          -- 'pending' | 'running' | 'completed' | 'failed' | 'cancelled'
  current_phase_id    TEXT,
  started_at          TIMESTAMPTZ,
  completed_at        TIMESTAMPTZ,
  error_message       TEXT,
  error_phase_id      TEXT,
  triggered_by        TEXT NOT NULL,          -- 'pg_cron' | 'manual' | 'retry' | 'onboarding'
  metadata            JSONB DEFAULT '{}',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (establishment_id, run_date, mode)
);

CREATE INDEX idx_pipeline_runs_status ON pipeline_runs(status) WHERE status IN ('pending', 'running');
CREATE INDEX idx_pipeline_runs_recent ON pipeline_runs(created_at DESC);
```

Status machine: `pending → running → completed`; `running → failed → (retry creates new run w/ triggered_by='retry')`; `running → cancelled` (manual only).

[NEW-CHAT] **Environment variables**:

| Variable | Provided by | Consumer | Required? | Purpose |
|---|---|---|---|---|
| `HEALTHCHECKS_PING_URL` | operator (healthchecks.io) | Backend (master_orchestrator ping) | No — silent no-op if unset | Outbound success heartbeat |
| `HEALTHCHECKS_CHECK_UUID` | operator (UUID from ping URL) | Frontend (HeartbeatBanner read status) | No — shows "not configured" if unset | Identifies HC check for read API |
| `HEALTHCHECKS_READ_API_KEY` | operator (read-only API key) | Frontend (HeartbeatBanner) | No — shows "not configured" if unset | Auth for HC read API |
| `MASTER_ORCHESTRATOR_URL` | Backend (post-deploy) | Frontend (dashboard retry proxy) | Required once retry ships | Base URL for master_orchestrator EF |
| `SUPABASE_SERVICE_ROLE_KEY` | existing | both | existing | RPC + admin reads |

SFTP credentials per EST continue from `establishment_settings.soviet_config.sftp_credentials_key` → SB Vault (no env vars, no hardcoding).

[NEW-CHAT] **Retry endpoint contract**:

Backend exposes:

```
POST /functions/v1/master_orchestrator/retry
Authorization: Bearer <user JWT w/ admin/superadmin/dev role>
Body: {
  "pipeline_run_id": "uuid",
  "from_phase_id": "<phase_id>" | null    // null = restart from current_phase_id
}
Response: {
  "new_pipeline_run_id": "uuid",
  "status": "pending"
}
```

Behavior: creates NEW `pipeline_runs` row w/ `triggered_by='retry'`, links via `metadata.retried_from`. Original row untouched. Frontend builds button that calls this + updates dashboard.

[NEW-CHAT] **Concurrency rules**:

- One in-flight `pipeline_runs` per (EST_id, run_date, mode) at a time. Enforced by UNIQUE constraint. Master checks before starting.
- Stuck-run timeout: `running` row w/ `started_at` older than 6 hours = abandoned. Advance loop marks `failed` w/ `error_message='timeout'`, allows new runs.
- Cron fires while previous run in progress: master detects existing `running` row, logs and returns no-op. No duplicate.
- Onboarding ≠ block daily: distinct rows (UNIQUE includes `mode`), so onboarding can run concurrently w/ daily.

[NEW-CHAT] **Shadow mode** (restated):

See Phase B. No flag, no shadow schema. Run new orchestrator against settled past dates, prove zero-diff. Frontend should not gate UI on shadow flag — dashboard simply shows `pipeline_runs`.

[NEW-CHAT] **Phase IDs are stable**:

`id` in `pipeline.yml` (e.g., `data_sync`, `menu_group_registry`) = contract. Both chats reference by id. Renaming id = breaking change requiring coordinated update. Adding phase = non-breaking.

---

## 10. Open Questions & Decisions (all as of 2026-04-21)

[ON-TRIGGER] **RESOLVED decisions** (tracking for audit trail):

1. ✓ Soviet SFTP IP allowlisting — **NO**: SSH key auth only, no IP restriction. Vercel-as-host viable.
2. ✓ Email delivery — **HC native sufficient v1**; Resend post-cutover.
3. ✓ HC plan — **FREE TIER**: 20 checks >> need. SMS deferred. Upgrade if real need.
4. ✓ `pipeline_runs` retention — **KEEP FOREVER**: ~365 rows/year/EST = trivial. No partitioning/drop.
5. ✓ Per-EST runtime budget — **COMPLETE BY 06:00 ET**: 4 hours after 02:00 trigger = HC grace window. Miss → alert.
6. ✓ Onboarding throttling — **1 SFTP invocation every 30 sec**: conservative start. Tune up if Soviet tolerates.
7. ✓ Alert distribution v1 — **OPERATOR ONLY**: single recipient OK v1. Add second contact post-cutover.

[REFERENCE] **Future** (informational, not blocking):

8. Soviet API access (when granted): entire VRL SFTP service replaced by HTTPS calls, zero non-SB compute. Build SFTP service modular so swap is clean.

---

## 11. Healthchecks.io Setup (operator does once)

[NEW-CHAT] One-time setup, ~5 min. Operator performs under their own account (alert emails → inbox directly).

1. Sign up <https://healthchecks.io/> w/ `admin@example.com`
2. Create check: **"Production data pipeline"**
3. Schedule: Type = Simple, Period = 24 hours (ping once per successful daily run), Grace = 4 hours (alert by 06:00 ET given 02:00 trigger)
4. Save. Copy ping URL: `https://hc-ping.com/<uuid>`
5. Settings → API Access: create read-only API key
6. Provide to dev chats:
   - `HEALTHCHECKS_PING_URL` = full URL → backend (SB EF env)
   - `HEALTHCHECKS_CHECK_UUID` = just `<uuid>` part → frontend (VRL env)
   - `HEALTHCHECKS_READ_API_KEY` = key → frontend (VRL env)

Until provided: both ping + HeartbeatBanner no-op gracefully.

Post-cutover optionally:
- Add second email recipient
- Consider Hobbyist plan ($5/mo) if SMS escalation needed

---

## 12. Reference Links

[REFERENCE] **Docs that fed this plan**:

- DAILY_AND_ONBOARDING_OVERVIEW.md
- PIPELINE_DIAGRAMS.md (6 Mermaid diagrams)
- DAY_BASED_WORKER_PIPELINE.md
- README_MENU_REGISTRY_AND_BACKFILL.md
- README_ORCHESTRATOR.md
- README_DATA_SYNC.md
- soviet_sync_v02.json
- 01_daily_establishment_orchestrator.json

[REFERENCE] **External**:

- Vercel Functions duration: https://vercel.com/docs/functions/limitations
- Vercel cron: https://vercel.com/docs/cron-jobs
- Healthchecks.io: https://healthchecks.io/
- SB pg_cron: https://supabase.com/docs/guides/database/extensions/pg_cron
- ssh2-sftp-client: https://www.npmjs.com/package/ssh2-sftp-client

---

## Appendix A — Why not Inngest, Trigger.dev, Temporal?

[REFERENCE] Pipeline = essentially 15-step linear DAG, not branching workflows w/ complex parallel/conditional logic. PQ + CRN + worker pattern already handles fan-out, retries, resumability for heavy phases. Adding Inngest/Trigger.dev = new vendor, auth model, deploy pipeline, billing, learning curve. Custom state machine in `pipeline_runs` = ~200 lines SQL + ~300 lines EF code, maintainable by one person.

Revisit if ever dozens of branching workflows w/ complex retry semantics. For now, keep it boring and Postgres-native.

## Appendix B — Why not stay on N8N w/ better monitoring?

[REFERENCE] HC heartbeat closes silent-failure hole regardless of platform. If silent failure were only problem, could stop there. Reasons to migrate anyway:

1. **Ergonomics**: code-first beats visual editor for AI-assisted dev
2. **Reliability**: N8N Cloud multi-year track record of breaking releases (TaskRunner latest)
3. **Vendor consolidation**: SB + VRL only (two). Remove N8N = one fewer thing to know.
4. **Cost**: N8N subscription disappears
5. **Learning**: contributors (human/AI) know SQL + TS already; don't need N8N quirks

Migration cost (3–4 weeks focused) recouped within months in maintenance saved.
