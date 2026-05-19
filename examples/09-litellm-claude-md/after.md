<!-- BOTSPEAK v2.2.0 · compressed by claude-opus-4.7 · 2026-05-19 -->
# CLAUDE.md

[NEW-CHAT] guidance for Claude Code (claude.ai/code) when working on this repo
default-phase: ALWAYS

@defs
  LL   = LiteLLM
  PROX = litellm/proxy/
  MCP  = Model Context Protocol
@end

## Documentation

docs live in separate repo: [BerriAI/litellm-docs](https://github.com/BerriAI/litellm-docs) · served at [docs.litellm.ai](https://docs.litellm.ai). !! create/edit docs in this repo · open doc PRs against `BerriAI/litellm-docs` instead.

## Development Commands

### Installation
- `make install-dev` – core dev deps
- `make install-proxy-dev` – proxy dev deps · full feature set
- `make install-test-deps` – full local test env + generate Prisma client

### Testing
- `make test` – all tests
- `make test-unit` – unit tests (`tests/test_litellm`) · 4 parallel workers
- `make test-integration` – integration tests (excludes unit tests)
- `pytest tests/` – direct pytest execution

### Code Quality
- `make lint` – all linting (Ruff · MyPy · Black · circular imports · import safety)
- `make format` – Black formatting
- `make lint-ruff` – Ruff only
- `make lint-mypy` – MyPy only
- before committing -> `uv run black .` (Black enforced in CI)

### Single Test Files
- `uv run pytest tests/path/to/test_file.py -v` – specific test file
- `uv run pytest tests/path/to/test_file.py::test_function -v` – specific test

### Running Scripts
- `uv run python script.py` – non-test Python scripts

### GitHub Issue & PR Templates

contributing -> use appropriate templates:

**Bug Reports** (`.github/ISSUE_TEMPLATE/bug_report.yml`):
- what happened vs. what you expected
- relevant log output
- LL version

**Feature Requests** (`.github/ISSUE_TEMPLATE/feature_request.yml`):
- describe feature clearly
- motivation + use case

**Pull Requests** (`.github/pull_request_template.md`):
- add ≥1 test in `tests/litellm/`
- `make test-unit` passes

## Architecture Overview

LL = unified interface for 100+ LLM providers · 2 main components.

### Core Library (`litellm/`)
- **main entry**: `litellm/main.py` – core `completion()` function
- **provider implementations**: `litellm/llms/` – each provider has its own subdir
- **router system**: `litellm/router.py` + `litellm/router_utils/` – load balancing + fallback logic
- **type definitions**: `litellm/types/` – Pydantic models + type hints
- **integrations**: `litellm/integrations/` – third-party observability · caching · logging
- **caching**: `litellm/caching/` – multiple backends (Redis · in-memory · S3 · etc.)

### Proxy Server (`PROX`)
- **main server**: `proxy_server.py` – FastAPI application
- **auth**: `auth/` – API key management · JWT · OAuth2
- **database**: `db/` – Prisma ORM · PostgreSQL/SQLite support
- **management endpoints**: `management_endpoints/` – admin APIs for keys · teams · models
- **pass-through endpoints**: `pass_through_endpoints/` – provider-specific API forwarding
- **guardrails**: `guardrails/` – safety + content filtering hooks
- **UI dashboard**: served from `_experimental/out/` (Next.js build)

## Key Patterns

### Provider Implementation
- providers inherit from base classes in `litellm/llms/base.py`
- each provider has transformation functions for input/output formatting
- support both sync + async ops
- handle streaming responses + function calling

### Error Handling
- provider-specific exceptions mapped to OpenAI-compatible errors
- fallback logic = Router system
- comprehensive logging via `litellm/_logging.py`

### Configuration
- YAML config files for proxy server (see `proxy/example_config_yaml/`)
- env vars for API keys + settings
- DB schema via Prisma (`proxy/schema.prisma`)

## Development Notes

### Code Style
- Black formatter · Ruff linter · MyPy type checker
- Pydantic v2 for data validation
- async/await patterns throughout
- type hints required for all public APIs
- !! imports within methods · all imports at top of file (module-level). inline imports inside functions/methods make deps harder to trace + hurt readability. ONLY exception = avoiding circular imports where absolutely necessary.
- dict spread for immutable copies -> prefer `{**original, "key": new_value}` over `dict(obj)` + mutation. spread produces final dict in one step · intent clear.
- guard at resolution time -> resolving optional via fallback chain (`a or b or ""`) -> raise immediately if resolved-empty is an error. !! pass empty strings || sentinel values downstream for callee to deal with.
- complex comprehensions -> extract to named helpers. set/dict comprehension calling DB/manager (e.g. "which of these server IDs are OAuth2?") belongs in named helper · !! inline in caller.
- FastAPI param declarations -> mark required query/form params with `= Query(...)` / `= Form(...)` explicitly when other params in same handler are optional. mixing `str` (required) with `Optional[str] = None` in same signature -> silent 422s when required param missing.

### Testing Strategy
- unit tests: `tests/test_litellm/`
- integration tests per provider: `tests/llm_translation/`
- proxy tests: `tests/proxy_unit_tests/`
- load tests: `tests/load_tests/`
- adding new entity types/features -> always add tests. if existing test file covers other entity types · add corresponding tests for new one.
- keep monkeypatch stubs in sync with real signatures -> function gains new optional param -> update every `fake_*` / `stub_*` in tests that patch it to also accept that kwarg (even as `**kwargs`). stale stubs fail with `unexpected keyword argument` + mask real bugs.
- test all branches of name→ID resolution -> adding server/resource lookup resolving names to UUIDs · test: (1) name resolves + UUID allowed · (2) name resolves but UUID not allowed · (3) name does not resolve. silent-fallback path = where access-control bugs hide.

### UI / Backend Consistency
- wiring new UI entity type to existing backend endpoint -> verify backend API contract (single value vs. array · required vs. optional params) + ensure UI controls match. e.g. single-select dropdown when backend accepts single value · !! multi-select.

### UI Component Library
- always use `antd` for new UI components · migrating off `@tremor/react`. !! introduce new `Badge` · `Text` · `Card` · `Grid` · `Title` · or other imports from `@tremor/react` in any new/modified file. use `antd` equivalents: `Tag` for labels · `Typography.Text` / `Typography.Title` / `Typography.Paragraph` for textual content (avoid plain text-only `<span>` · `<p>` · `<h*>` when Typography fits) · `Card` from `antd`. note: `antd` has no `"yellow"` Tag color · use `"gold"` for amber/yellow.

### MCP OAuth / OpenAPI Transport Mapping
- `available_on_public_internet: false` with `delegate_auth_to_upstream: true` (oauth2 · interactive · !! `client_credentials`) -> LL still allows anonymous upstream PKCE path (no proxy API key for `/authorize` + matching MCP routes). internal-only flag mainly affects other surfaces (e.g. IP-based discovery). rely on upstream IdP + network policy. dashboard shows warning when both set · proxy logs warning when server loaded from config or database.
- `TRANSPORT.OPENAPI` = UI-only concept. backend only accepts `"http"` · `"sse"` · `"stdio"`. always map to `"http"` before any API call (including pre-OAuth temp-session calls).
- FastAPI validation errors return `detail` as array of `{loc, msg, type}` objects. error extractors must handle: array (map `.msg`) · string · nested `{error: string}` · fallback.
- MCP server already has `authorization_url` stored -> skip OAuth discovery (`_discovery_metadata`). server URL for OpenAPI MCPs = spec file · not API base · fetching causes timeouts.
- `client_id` SHOULD be optional in `/authorize` endpoint. server has stored `client_id` in credentials -> use that. !! require callers to re-supply it.

### MCP Credential Storage
- OAuth creds + BYOK creds share `litellm_mcpusercredentials` table · distinguished by `"type"` field in JSON payload (`"oauth2"` vs plain string).
- deleting OAuth credentials -> check type before deleting · avoid accidentally deleting BYOK credential for same `(user_id, server_id)` pair.
- always pass raw `expires_at` timestamp to client · !! set to `None` for expired credentials. let frontend compute "Expired" display state from timestamp.
- use `RecordNotFoundError` (!! bare `except Exception`) when catching "already deleted" in credential delete endpoints.

### Browser Storage Safety (UI)
- !! write LL access tokens || API keys to `localStorage` · use `sessionStorage` only. `localStorage` survives browser close + is readable by any injected script (XSS).
- shared utility functions (e.g. `extractErrorMessage`) belong in `src/utils/` · !! inline in hooks · !! duplicated across files.

### Database Migrations
- Prisma handles schema migrations
- migration files auto-generated via `prisma migrate dev`
- always test migrations against both PostgreSQL + SQLite

### Proxy database access
- !! raw SQL for proxy DB ops · use Prisma model methods (!! `execute_raw` / `query_raw`).
- use generated client: `prisma_client.db.<model>` (e.g. `litellm_tooltable` · `litellm_usertable`) with `.upsert()` · `.find_many()` · `.find_unique()` · `.update()` · `.update_many()` as appropriate. avoids schema/client drift · keeps code testable with simple mocks · matches patterns in spend logs + other proxy code.
- !! N+1 queries · !! query DB inside loop. batch-fetch with `{"in": ids}` + distribute in-memory.
- batch writes -> use `create_many` / `update_many` / `delete_many` instead of individual calls. these return counts only · `update_many` / `delete_many` no-op silently on missing rows. multiple separate writes target same table (e.g. in `batch_()`) -> order by primary key to avoid deadlocks.
- push work to DB -> filter · sort · group · aggregate in SQL · !! Python. verify Prisma generates expected SQL · prefer `group_by` over `find_many(distinct=...)` (does client-side processing).
- bound large result sets -> Prisma materializes full results in memory. results > ~10 MB -> paginate with `take`/`skip` or `cursor`/`take` · always explicit `order`. prefer cursor-based pagination (`skip` = O(n)). !! paginate naturally small result sets.
- limit fetched columns on wide tables -> use `select` to fetch only needed fields · returns partial object · downstream code !! access unselected fields.
- check index coverage -> new/modified queries · check `schema.prisma` for supporting index. prefer extending existing index (e.g. `@@index([a])` → `@@index([a, b])`) over adding new one · unless it's `@@unique`. only add indexes for large/frequent queries.
- keep schema files in sync -> apply schema changes to all `schema.prisma` copies (`schema.prisma` · `PROX` · `litellm-proxy-extras/`) with migration under `litellm-proxy-extras/litellm_proxy_extras/migrations/`.

### Setup Wizard (`litellm/setup_wizard.py`)
- wizard implemented as single `SetupWizard` class with `@staticmethod` methods · keep it that way. !! module-level functions except `run_setup_wizard()` (public entrypoint) + pure helpers (color · ANSI).
- use `litellm.utils.check_valid_key(model, api_key)` for credential validation · !! roll custom completion call.
- !! hardcode provider env-key names || model lists that already exist in codebase. add `test_model` field to each provider entry to drive `check_valid_key` · set to `None` for providers that can't be validated with single API key (Azure · Bedrock · Ollama).

### Enterprise Features
- enterprise-specific code in `enterprise/` directory
- optional features enabled via env vars
- separate licensing + auth for enterprise features

### CI Supply-Chain Safety
- !! pipe remote script into shell (`curl ... | bash` · `wget ... | sh`). download artifact to file · verify SHA-256 checksum · then install.
- pin every external tool to specific version with full URL (!! `latest` / `stable`). unversioned downloads silently change under you.
- verify checksums for all downloaded binaries · use provider's official `.sha256` / `.sha256sum` sidecar when available · otherwise compute + hardcode digest.
- prefer reusable CircleCI commands (`commands:` section) -> tool installed + verified in exactly one place · referenced everywhere with `- install_<tool>` or `- wait_for_service`.
- !! add tools just because they were there before · audit whether external dependency still needed. replaceable with shell one-liner or tool already in image -> remove.
- rules apply to every download in CI: binaries · install scripts · language version managers · package repos. no exceptions.

### HTTP Client Cache Safety
- !! close HTTP/SDK clients on cache eviction. `LLMClientCache._remove_key()` MUST NOT call `close()` / `aclose()` on evicted clients · still used by in-flight requests. -> `RuntimeError: Cannot send a request, as the client has been closed.` after 1-hour TTL expires. cleanup happens at shutdown via `close_litellm_async_clients()`.

### Troubleshooting: DB schema out of sync after proxy restart
`litellm-proxy-extras` runs `prisma migrate deploy` on startup using **its own** bundled migration files · may lag behind schema changes in current worktree. symptoms: `Unknown column` · `Invalid prisma invocation` · or missing data on new fields.

**Diagnose:** `\d "TableName"` in psql · compare against `schema.prisma`. missing columns confirm the issue.

**Fix options:**
1. **create Prisma migration** (permanent) -> `prisma migrate dev --name <description>` in worktree. generated file picked up by `prisma migrate deploy` on next startup.
2. **apply manually for local dev** -> `psql -d litellm -c "ALTER TABLE ... ADD COLUMN IF NOT EXISTS ..."` after each proxy start. fine for dev · !! production.
3. **update litellm-proxy-extras** -> package installed from PyPI · its migration directory must include new file. either update package or run migration manually until next release ships it.
