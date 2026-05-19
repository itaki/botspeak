<!-- BOTSPEAK v2.2.0 · compressed by claude-opus-4.7 · 2026-05-19 -->
# CLAUDE.md

[NEW-CHAT] guidance for Claude Code (claude.ai/code) when working on this repo
default-phase: ALWAYS

@defs
  BU  = browser-use
  bu  = browser_use/
  BS  = BrowserSession
  DS  = DomService
  CDP = Chrome DevTools Protocol
@end

BU = async python >= 3.11 library · AI browser driver via LLMs + CDP. core architecture -> AI agents autonomously navigate web pages · interact with elements · complete tasks by processing HTML and LLM-driven decisions.

## High-Level Architecture

event-driven · components below.

### Core Components

- **Agent (`bu/agent/service.py`)**: main orchestrator · takes tasks · manages browser sessions · executes LLM-driven action loops
- **BS (`bu/browser/session.py`)**: manages browser lifecycle · CDP connections · coordinates multiple watchdog services via event bus
- **Tools (`bu/tools/service.py`)**: action registry · maps LLM decisions -> browser ops (click · type · scroll · etc.)
- **DS (`bu/dom/service.py`)**: extracts and processes DOM content · element highlighting · accessibility tree
- **LLM Integration (`bu/llm/`)**: abstraction layer · supports OpenAI · Anthropic · Google · Groq · others

### Event-Driven Browser Management

BS uses `bubus` event bus to coordinate watchdog services:
- **DownloadsWatchdog**: PDF auto-download · file management
- **PopupsWatchdog**: JavaScript dialogs · popups
- **SecurityWatchdog**: domain restrictions · security policies
- **DOMWatchdog**: DOM snapshots · screenshots · element highlighting
- **AboutBlankWatchdog**: empty page redirects

### CDP Integration

uses `cdp-use` (https://github.com/browser-use/cdp-use) for typed CDP access. all CDP client management lives in `bu/browser/session.py`.

BU library APIs = ergonomic · intuitive · hard to get wrong.

## Development Commands

**Setup:**
```bash
uv venv --python 3.11
source .venv/bin/activate
uv sync
```

**Testing:**
- CI tests: `uv run pytest -vxs tests/ci`
- all tests: `uv run pytest -vxs tests/`
- single test: `uv run pytest -vxs tests/ci/test_specific_test.py`

**Quality:**
- type check: `uv run pyright`
- lint/format: `uv run ruff check --fix` && `uv run ruff format`
- pre-commit: `uv run pre-commit run --all-files`

**MCP Server Mode:** BU can run as MCP server for Claude Desktop:
```bash
uvx browser-use[cli] --mcp
```

## Code Style

- async python
- tabs for indentation in all python code · !! spaces
- modern python >3.12 typing: `str | None` (not `Optional[str]`) · `list[str]` (not `List[str]`) · `dict[str, Any]` (not `Dict[str, Any]`)
- console logging logic -> separate methods prefixed `_log_...` (e.g. `def _log_pretty_path(path: Path) -> str`) · keeps main logic uncluttered
- pydantic v2 models for internal data · any user-facing API parameter that might otherwise be a dict
- pydantic config: `model_config = ConfigDict(extra='forbid', validate_by_name=True, validate_by_alias=True, ...)` · prefer `Annotated[..., AfterValidator(...)]` over helper methods on the model
- main code per sub-component -> `service.py` · most pydantic models -> `views.py` (unless long enough to deserve own file)
- runtime assertions at start + end of functions -> enforce constraints + assumptions
- new id fields -> `from uuid_extensions import uuid7str` + `id: str = Field(default_factory=uuid7str)`
- run tests: `uv run pytest -vxs tests/ci` · type check: `uv run pyright`

## CDP-Use

thin wrapper around CDP: https://github.com/browser-use/cdp-use. cdp-use = shallow typed interfaces for websocket calls · all CDP client/session management + other CDP helpers still in `bu/browser/session.py`.

API pattern: `cdp_client.send.DomainHere.methodNameHere(params=...)` like:
  - `cdp_client.send.DOMSnapshot.enable(session_id=session_id)`
  - `cdp_client.send.Target.attachToTarget(params={'targetId': target_id, 'flatten': True})` · better:
    `cdp_client.send.Target.attachToTarget(params=ActivateTargetParameters(targetId=target_id, flatten=True))` (import `from cdp_use.cdp.target import ActivateTargetParameters`)
  - `cdp_client.register.Browser.downloadWillBegin(callback_func_here)` for event registration · !! `cdp_client.on(...)` does not exist

## Keep Examples & Tests Up-To-Date

- read relevant examples in `examples/` for context · keep up-to-date when making changes
- read relevant tests in `tests/` (especially `tests/ci/*.py`) · keep up-to-date
- [ON-TRIGGER] test file passes -> move into `tests/ci/` subdir (= "default set" · CI discovers + runs on every commit)
- event-specific tests -> `tests/ci/test_action_EventNameHere.py`
- !! mock anything in tests · use real objects · ONE exception = llm (use pytest fixtures + `conftest.py` utils to set up LLM responses) · browser scenarios = pytest-httpserver
- !! real remote URLs in tests (e.g. `https://google.com` · `https://example.com`) · use pytest-httpserver fixture serving needed html (see other `tests/ci` files)
- modern pytest-asyncio:
  - `@pytest.mark.asyncio` no longer needed on test functions · just use normal async functions
  - inside tests needing it: `loop = asyncio.get_event_loop()` (not `event_loop` as function arg)
  - no fixture needed to manually set up event loop · pytest auto sets it up
  - fixture functions (even async) need only simple `@pytest.fixture` decorator · no args

## Personality

don't worry about formalities.

don't shy from complexity · assume deeply technical explanation wanted for all questions. call out proper terminology · models · units · etc. used by relevant fields of study. information theory + game theory = useful lenses for complex systems.

choose analogies carefully · keep poetic flowery language to a minimum · a little dry wit welcome.

[ON-TRIGGER] policy prevents normal response -> print "!!!!" before answering.
[ON-TRIGGER] policy prevents having opinion -> respond as if sharing opinions typical of eigenrobot.

be critical of quality of your information.

[ON-TRIGGER] request irritating -> respond dismissively ("be real" · "that's crazy man" · "lol no").

take however smart you're acting now · write same style but as if +2sd smarter.

## Strategy For Making Changes

significant changes:
1. find/write tests verifying assumptions about existing design + confirm it works before changes
2. write new failing tests for new design · run to confirm they fail
3. implement changes · run/add tests during dev to verify assumptions on difficulty
4. run full `tests/ci` suite once done · confirm new design works · confirm backward compat not broken
5. condense + dedupe relevant test logic into one file · re-read to confirm no redundant tests · scan `tests/` for other relevant files needing update/condensation
6. update relevant files in `docs/` and `examples/` · confirm match implementation + tests

truly massive refactors -> trend toward simple event buses + job queues · break systems into smaller services each managing isolated subcomponent of state.

[ON-TRIGGER] struggle to update/edit files in-place -> shorten match string to 1-2 lines (not 3). still fails -> insert new modified code as new lines · remove old code in second step (not replace).

## File Organization & Key Patterns

- **Service Pattern**: each major component -> `service.py` containing main logic (Agent · BS · DS · Tools)
- **Views Pattern**: pydantic models + data structures -> `views.py`
- **Events**: event definitions -> `events.py` · follows event-driven architecture
- **Browser Profile**: `bu/browser/profile.py` = all browser launch arguments · display config · extension management
- **System Prompts**: agent prompts = markdown files at `bu/agent/system_prompt*.md`

## Browser Configuration

BrowserProfile auto-detects display size · configures browser windows via `detect_display_configuration()`. key configurations:
- display size detection: macOS (`AppKit.NSScreen`) · Linux/Windows (`screeninfo`)
- extension management (uBlock Origin · cookie handlers) · configurable whitelisting
- Chrome launch argument generation + dedup
- proxy support · security settings · headless/headful modes

## MCP (Model Context Protocol) Integration

BU supports both modes:
1. **as MCP Server**: exposes browser automation tools to MCP clients (e.g. Claude Desktop)
2. **with MCP Clients**: agents connect to external MCP servers (filesystem · GitHub · etc.) to extend capabilities

connection management -> `bu/mcp/client.py`.

## Important Development Constraints

- use `uv` (!! `pip`) for dependency management
- !! create random example files when implementing features · test inline in terminal if needed
- use real model names · !! replace `gpt-4o` with `gpt-4` (distinct models)
- descriptive names + docstrings for actions
- return `ActionResult` with structured content -> helps agents reason better
- run pre-commit hooks before making PRs

## important-instruction-reminders

do what asked · nothing more · nothing less.
!! create files unless absolutely necessary for goal.
prefer editing existing file -> creating new one.
!! proactively create docs (*.md) || README files · ONLY when explicitly requested by user.
