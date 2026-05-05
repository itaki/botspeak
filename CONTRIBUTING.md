# Contributing to BOTSPEAK

Thanks for considering a contribution. BOTSPEAK is a small, focused project — please keep contributions in the same spirit.

## What we want

- **More before/after examples** in `examples/`. Real-world rules, skills, and memory pages from your own projects (with anything sensitive redacted) are the best teaching material we can ship.
- **Tokenizer benchmarks** showing exact token counts for symbols, aliases, and example files across `tiktoken` (o200k, cl100k), Llama BPE, and Gemini SentencePiece. Help us replace estimates with measurements.
- **Translation quality reports** — run `/botspeak` then `/translate-botspeak` round-trip on a doc and report any semantic drift you find. These are bugs.
- **Host-tool compatibility fixes** — the install script tries to support Claude Code, Cursor, Codex, Gemini CLI, and the AGENTS.md ecosystem. If your tool isn't supported, a one-line addition to `install.sh` is welcome.
- **SPEC clarifications** when the rules are ambiguous in practice. PRs that fix unclear language are valuable.

## What we don't want

- New symbols added to the vocabulary without a published token-cost justification.
- New phase tags. The five we have ([NEW-CHAT], [ALWAYS], [ON-TRIGGER], [REFERENCE], [HANDOFF]) cover the cases. More tags = more cognitive load.
- Forks of the SPEC into incompatible dialects. If the SPEC is wrong, propose a fix.
- Compression-tool features (auto-compress on save, IDE plugins, etc.) — those belong in separate repos that depend on this one.
- Marketing PRs that don't include a working code or doc change.

## How to propose a change

1. Open an issue first if the change is non-trivial. Discussion saves rework.
2. For doc-only changes, a PR with a clear summary is fine.
3. Include a real before/after example for any spec change. If you can't show the change improves a real document, the spec change probably isn't needed.

## Style

- Code and configs: standard formatting for the language. No bikeshedding.
- Markdown: BOTSPEAK for AI-facing docs (per the SPEC), human prose for user-facing docs.
- Examples: include token counts and reduction percentages in PR descriptions.

## License

By contributing, you agree your contributions are licensed under MIT.
