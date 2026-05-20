#!/usr/bin/env python3
"""
Count o200k_base tokens for all BOTSPEAK before/after example pairs and the
game prompt pairs. Produces a markdown table and JSON suitable for embedding
in README.md, showcase/index.html, evals/round-trip-results.md, and the
per-example folder READMEs.

Usage:
  cd <repo-root>
  python3 evals/scripts/count_tokens.py
"""

from __future__ import annotations

import json
from pathlib import Path

import tiktoken

ENC = tiktoken.get_encoding("o200k_base")
REPO = Path(__file__).resolve().parents[2]


def count(path: Path) -> int:
    return len(ENC.encode(path.read_text()))


def words(path: Path) -> int:
    return len(path.read_text().split())


def pct_reduction(before: int, after: int) -> float:
    if before == 0:
        return 0.0
    return 100.0 * (before - after) / before


SYNTHETIC = [
    ("01-short-rule", "short rule (branch guard)"),
    ("02-context-handoff", "context handoff"),
    ("03-memory-page", "memory page (wiki)"),
    ("04-philosophy-rule", "project philosophy rule"),
    ("05-aliased-claude-md", "long CLAUDE.md (restaurant ops)"),
    ("06-backend-migration", "architecture migration plan"),
]

REAL_WORLD = [
    ("07-langchain-claude-md", "langchain-ai/langchain"),
    ("08-browser-use-claude-md", "browser-use/browser-use"),
    ("09-litellm-claude-md", "BerriAI/litellm"),
]

GAMES = [
    ("game-prompt", "Flappy Bird"),
    ("snake-prompt", "Snake"),
    ("pong-prompt", "Pong"),
    ("breakout-prompt", "Breakout"),
]


def main() -> None:
    rows = []

    print("# Synthetic examples (01-06)\n")
    print("| # | name | before tok | after tok | reduction |")
    print("|---|---|---:|---:|---:|")
    for folder, name in SYNTHETIC:
        before = REPO / "examples" / folder / "before.md"
        after = REPO / "examples" / folder / "after.md"
        b, a = count(before), count(after)
        rows.append({
            "category": "synthetic",
            "id": folder,
            "name": name,
            "before_tokens": b,
            "after_tokens": a,
            "reduction_pct": round(pct_reduction(b, a), 1),
        })
        print(f"| {folder[:2]} | {name} | {b:,} | {a:,} | **{pct_reduction(b, a):.0f}%** |")

    print("\n# Real-world CLAUDE.md (07-09)\n")
    print("| # | repo | before tok | after tok | reduction |")
    print("|---|---|---:|---:|---:|")
    for folder, name in REAL_WORLD:
        before = REPO / "examples" / folder / "before.md"
        after = REPO / "examples" / folder / "after.md"
        b, a = count(before), count(after)
        rows.append({
            "category": "real-world",
            "id": folder,
            "name": name,
            "before_tokens": b,
            "after_tokens": a,
            "reduction_pct": round(pct_reduction(b, a), 1),
        })
        print(f"| {folder[:2]} | {name} | {b:,} | {a:,} | **{pct_reduction(b, a):.0f}%** |")

    print("\n# Game synthesis prompts\n")
    print("| game | prose words | BOTSPEAK words | prose tok | BOTSPEAK tok | reduction |")
    print("|---|---:|---:|---:|---:|---:|")
    for folder, name in GAMES:
        prose = REPO / "evals" / folder / "source.md"
        bspeak = REPO / "evals" / folder / "source-botspeak-v22.md"
        pw, bw = words(prose), words(bspeak)
        pt, bt = count(prose), count(bspeak)
        rows.append({
            "category": "game",
            "id": folder,
            "name": name,
            "before_words": pw,
            "after_words": bw,
            "before_tokens": pt,
            "after_tokens": bt,
            "reduction_pct_words": round(pct_reduction(pw, bw), 1),
            "reduction_pct_tokens": round(pct_reduction(pt, bt), 1),
        })
        print(f"| {name} | {pw:,} | {bw:,} | {pt:,} | {bt:,} | **{pct_reduction(pt, bt):.0f}%** |")

    out = REPO / "evals" / "scripts" / "token-counts.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(rows, indent=2) + "\n")
    print(f"\nWrote JSON: {out.relative_to(REPO)}")


if __name__ == "__main__":
    main()
