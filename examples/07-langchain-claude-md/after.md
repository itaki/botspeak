<!-- BOTSPEAK v2.2.0 · compressed by claude-opus-4.7 · 2026-05-19 -->
# Global development guidelines for the LangChain monorepo

[NEW-CHAT] context for the LangChain Python project · use to assist with development
default-phase: ALWAYS

@defs
  LC   = langchain
  WF   = .github/workflows
  LCP  = langchain-profiles
  NE   = named entity (class · function · method · parameter · variable name)
@end

## Project architecture and context

### Monorepo structure

Python monorepo · multiple independently-versioned packages · uses `uv`.

```txt
langchain/
├── libs/
│   ├── core/             # `langchain-core` primitives and base abstractions
│   ├── langchain/        # `langchain-classic` (legacy, no new features)
│   ├── langchain_v1/     # Actively maintained `langchain` package
│   ├── partners/         # Third-party integrations
│   │   ├── openai/       # OpenAI models and embeddings
│   │   ├── anthropic/    # Anthropic (Claude) integration
│   │   ├── ollama/       # Local model support
│   │   └── ... (other integrations maintained by the LangChain team)
│   ├── text-splitters/   # Document chunking utilities
│   ├── standard-tests/   # Shared test suite for integrations
│   ├── model-profiles/   # Model configuration profiles
├── .github/              # CI/CD workflows and templates
├── .vscode/              # VSCode IDE standard settings and recommended extensions
└── README.md             # Information about LangChain
```

- **Core layer** (`langchain-core`): base abstractions · interfaces · protocols. users should not need to know about this layer directly.
- **Implementation layer** (`langchain`): concrete implementations + high-level public utilities.
- **Integration layer** (`partners/`): third-party service integrations. monorepo is not exhaustive · some integrations maintained in separate repos (e.g. `langchain-ai/langchain-google` · `langchain-ai/langchain-aws`) usually cloned at the same level so you can navigate via `../langchain-google/`.
- **Testing layer** (`standard-tests/`): standardized integration tests for partner integrations.

### Development tools & commands

- `uv` – fast Python package installer + resolver (replaces pip/poetry)
- `make` – task runner · see `Makefile` for commands
- `ruff` – fast Python linter + formatter
- `mypy` – static type checking
- `pytest` – testing framework

monorepo uses `uv` for dependency management. local dev = editable installs: `[tool.uv.sources]`. each package in `libs/` has its own `pyproject.toml` + `uv.lock`.

before running tests · set up all packages:

```bash
# For all groups
uv sync --all-groups

# or, to install a specific group only:
uv sync --group test
```

```bash
# Run unit tests (no network)
make test

# Run specific test file
uv run --group test pytest tests/unit_tests/test_specific.py
```

```bash
# Lint code
make lint

# Format code
make format

# Type checking
uv run --group lint mypy .
```

#### Key config files

- `pyproject.toml`: main workspace config + dependency groups
- `uv.lock`: locked dependencies for reproducible builds
- `Makefile`: dev tasks

#### PR and commit titles

follow Conventional Commits. see `WF/pr_lint.yml` for allowed types + scopes. all titles MUST include a scope · no exceptions · even for main `langchain` package.

- start text after `type(scope):` with lowercase letter · unless first word is proper noun (`Azure` · `GitHub` · `OpenAI`) or NE
- wrap NEs in backticks (render as code) · proper nouns left unadorned
- keep titles short + descriptive · save detail for body

Examples:

```txt
feat(langchain): add new chat completion feature
fix(core): resolve type hinting issue in vector store
chore(anthropic): update infrastructure dependencies
feat(langchain): `ls_agent_type` tag on `create_agent` calls
fix(openai): infer Azure chat profiles from model name
```

#### PR descriptions

description *is* the summary · !! `# Summary` header.

- [ON-TRIGGER] PR closes an issue -> lead with closing keyword on its own line at top · then horizontal rule · then body:

  ```txt
  Closes #123

  ---

  <rest of description>
  ```

  only `Closes` · `Fixes` · `Resolves` auto-close on merge. `Related:` etc. = informational only.

- explain the *why*: motivation + why this solution is right. limit prose.
- write for readers unfamiliar with this area · avoid insider shorthand · prefer language friendly to public viewers · aids interpretability.
- !! cite line numbers (go stale on file change)
- rarely include full file paths or filenames · reference affected symbol · class · or subsystem by name
- wrap NEs in backticks
- skip dedicated "Test plan" / "Testing" sections in most cases · mention tests only when coverage is non-obvious · risky · or notable
- call out areas requiring careful review
- add brief disclaimer noting AI-agent involvement in contribution

## Core development principles

### Maintain stable public interfaces

!! INVARIANT: preserve function signatures · argument positions · names for exported/public methods. !! breaking changes.
[ON-TRIGGER] function signature change -> warn developer · regardless of whether it looks breaking.

before making ANY changes to public APIs:

- check if function/class is exported in `__init__.py`
- look for existing usage patterns in tests + examples
- use keyword-only arguments for new parameters: `*, new_param: str = "default"`
- mark experimental features clearly in docstrings (MkDocs Material admonitions e.g. `!!! warning`)

ask: "would this change break someone's code if they used it last week?"

### Code quality standards

all Python code MUST include type hints + return types.

```python title="Example"
def filter_unknown_users(users: list[str], known_users: set[str]) -> list[str]:
    """Single line description of the function.

    Any additional context about the function can go here.

    Args:
        users: List of user identifiers to filter.
        known_users: Set of known/valid user identifiers.

    Returns:
        List of users that are not in the `known_users` set.
    """
```

- descriptive · self-explanatory variable names
- follow existing patterns in codebase you're modifying
- break up complex functions (>20 lines) into smaller focused functions where it makes sense

### Testing requirements

every new feature || bugfix MUST be covered by unit tests.

- unit tests: `tests/unit_tests/` · no network calls allowed
- integration tests: `tests/integration_tests/` · network calls permitted
- testing framework = `pytest` · check existing tests for examples on doubt
- testing file structure mirrors source code structure

**Checklist:**

- [ ] tests fail when your new logic is broken
- [ ] happy path covered
- [ ] edge cases + error conditions tested
- [ ] use fixtures/mocks for external dependencies
- [ ] tests are deterministic · no flaky tests
- [ ] does test suite fail if your new logic is broken?

### Security and risk assessment

- !! `eval()` · `exec()` · `pickle` on user-controlled input
- proper exception handling · !! bare `except:` · use `msg` variable for error messages
- remove unreachable/commented code before committing
- race conditions || resource leaks (file handles · sockets · threads)
- ensure proper resource cleanup (file handles · connections)

### Documentation standards

Google-style docstrings with Args section for all public functions.

```python title="Example"
def send_email(to: str, msg: str, *, priority: str = "normal") -> bool:
    """Send an email to a recipient with specified priority.

    Any additional context about the function can go here.

    Args:
        to: The email address of the recipient.
        msg: The message body to send.
        priority: Email priority level.

    Returns:
        `True` if email was sent successfully, `False` otherwise.

    Raises:
        InvalidEmailError: If the email address format is invalid.
        SMTPConnectionError: If unable to connect to email server.
    """
```

- types -> function signatures · !! docstrings
  - default present -> !! repeat in docstring unless there is post-processing or it is set conditionally
- focus on "why" rather than "what" in descriptions
- document all parameters · return values · exceptions
- keep descriptions concise but clear
- American English spelling (e.g. "behavior" · !! "behaviour")
- !! Sphinx-style double backtick formatting (` ``code`` `). use single backticks (`` `code` ``) for inline code in docstrings + comments.

#### Model references in docs and examples

always use latest GA (generally available) models when referencing LLMs in docstrings + illustrative snippets. !! preview/beta identifiers unless no GA equivalent exists. outdated model names signal stale code + confuse users.

before writing/updating model references · verify current model IDs against provider's official docs. !! rely on memorized/cached model names · they go stale quickly.

[ON-TRIGGER] changing **shipped default parameter values** in code (e.g. `model=` kwarg default in class constructor) -> may constitute breaking change · see "Maintain stable public interfaces" above. guidance applies to documentation + examples · not code defaults.

for model *profile data* (capability flags · context windows) -> use `LCP` CLI described below.

## Model profiles

model profiles are generated using `LCP` CLI in `libs/model-profiles`. `--data-dir` MUST point to the directory containing `profile_augmentations.toml` · !! top-level package directory.

```bash
# Run from libs/model-profiles
cd libs/model-profiles

# Refresh profiles for a partner in this repo
uv run langchain-profiles refresh --provider openai --data-dir ../partners/openai/langchain_openai/data

# Refresh profiles for a partner in an external repo (requires echo y to confirm)
echo y | uv run langchain-profiles refresh --provider google --data-dir /path/to/langchain-google/libs/genai/langchain_google_genai/data
```

Example partners with profiles in this repo:

- `libs/partners/openai/langchain_openai/data/` (provider: `openai`)
- `libs/partners/anthropic/langchain_anthropic/data/` (provider: `anthropic`)
- `libs/partners/perplexity/langchain_perplexity/data/` (provider: `perplexity`)

`echo y |` pipe required when `--data-dir` is outside `libs/model-profiles` working directory.

## CI/CD infrastructure

### Release process

releases triggered manually via `WF/_release.yml` with `working-directory` + `release-version` inputs.

### PR labeling and linting

**Title linting** (`WF/pr_lint.yml`)

**Auto-labeling:**

- `WF/pr_labeler.yml` – unified PR labeler (size · file · title · external/internal · contributor tier)
- `WF/pr_labeler_backfill.yml` – manual backfill of PR labels on open PRs
- `WF/auto-label-by-package.yml` – issue labeling by package
- `WF/tag-external-issues.yml` – issue external/internal classification

### Adding a new partner to CI

[ON-TRIGGER] adding new partner package -> update these files:

- `.github/ISSUE_TEMPLATE/*.yml` – add to package dropdown
- `.github/dependabot.yml` – add dependency update entry
- `.github/scripts/pr-labeler-config.json` – add file rule + scope-to-label mapping
- `WF/_release.yml` – add API key secrets if needed
- `WF/auto-label-by-package.yml` – add package label
- `WF/check_diffs.yml` – add to change detection
- `WF/integration_tests.yml` – add integration test config
- `WF/pr_lint.yml` – add to allowed scopes

## GitHub Actions & Workflows

repo requires actions pinned to full-length commit SHA · using a tag will fail. use `gh` cli to query. verify tags are not annotated tag objects (would need dereferencing).

## Additional resources

- **Documentation:** https://docs.langchain.com/oss/python/langchain/overview · source at https://github.com/langchain-ai/docs or `../docs/`. prefer local install + use file search tools for best results. on need use the docs MCP server defined in `.mcp.json` for programmatic access.
- **Contributing Guide:** [Contributing Guide](https://docs.langchain.com/oss/python/contributing/overview)
