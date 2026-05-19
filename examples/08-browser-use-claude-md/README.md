# Example 08 — Real-world `CLAUDE.md` from a 94K-star repo

This is the live `CLAUDE.md` file from [`browser-use/browser-use`](https://github.com/browser-use/browser-use) at the time of capture (May 2026). The repo has **94,540 stars** and is a leading AI browser automation library.

| File | Tokens (o200k_base) | Words | Fenced code blocks |
|---|---:|---:|---:|
| `before.md` (verbatim from GitHub) | 2,495 | 1,574 | 2 |
| `after.md` (BOTSPEAK-compressed) | 2,179 | 1,278 | 2 |
| **Reduction** | **12.7%** | **18.8%** | unchanged |

## What BOTSPEAK actually did here

- **Aliases**: `browser_use/` (used 13 times) → `bu`, `BrowserSession` (6 uses) → `BS`, `DomService` (3 uses) → `DS`, `Chrome DevTools Protocol` (2 uses) → `CDP`. Together that saves ~60 tokens on path repetition alone.
- **Phase tags**: declared `default-phase: ALWAYS` at the top, so the dozens of behavioral rules don't each need an `[ALWAYS]` tag. Only the conditional rules (massive refactor strategy, in-place edit fallback) get explicit `[ON-TRIGGER]` markers.
- **Polarity markers**: every "never" / "don't" gets a `!!` so the polarity is unambiguous to the agent (e.g. `!! mock anything in tests`, `!! real remote URLs in tests`).
- **Code blocks**: both fenced blocks (`uv venv` setup, `uvx browser-use[cli] --mcp` MCP server mode) preserved byte-for-byte.

The Personality section keeps all of its quirky lines verbatim — those are constraints on the agent's voice, not prose to be polished.

## Provenance

Fetched from `https://raw.githubusercontent.com/browser-use/browser-use/HEAD/CLAUDE.md` on 2026-05-19. The compression was performed by Claude (Opus 4.7) following SPEC.md v2.2.0.

## Verify

```bash
python3 -c "
import tiktoken
enc = tiktoken.get_encoding('o200k_base')
for p in ['before.md','after.md']:
    print(p, len(enc.encode(open(p).read())))
"
```
