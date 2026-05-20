# evals/scripts

Automated checks used by the BOTSPEAK eval suite. Both scripts are pure Python
3.10+ and live next to the data they verify.

## `count_tokens.py`

Counts `o200k_base` tokens for every before/after example pair (`examples/01-*`
through `examples/09-*`) and for every game prompt pair under `evals/`. Prints
a markdown table and writes machine-readable counts to `token-counts.json`.

Requires the `tiktoken` package.

How to run (from the repo root):

```bash
python3 evals/scripts/count_tokens.py
```

## `parity_check.py`

Verifies the parity-report claims in each game folder by extracting numeric
constants from the JavaScript inside both HTML files, normalizing them, and
diffing the two identifier → value maps. This ends the "self-graded homework"
problem — anyone can re-run the check.

For each game (`game-prompt`, `snake-prompt`, `pong-prompt`, `breakout-prompt`)
it reads `results/prose-sonnet.html` and `results/botspeak-sonnet-v22.html`,
extracts every `const` / `let` / `var` whose right-hand side evaluates to a
pure number, and reports:

- identifiers in each file
- `shared + match` — same name, same value
- `shared + mismatch` — same name, different value (real failure)
- `only in prose` / `only in BOTSPEAK` — usually just renames

Only `shared + mismatch` flips the exit code. Stdlib-only, no third-party
deps.

How to run (from the repo root):

```bash
python3 evals/scripts/parity_check.py
```

Exit code: `0` if no shared-name mismatches across all four games, `1`
otherwise.
