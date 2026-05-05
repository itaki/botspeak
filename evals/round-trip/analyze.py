#!/usr/bin/env python3
"""
BOTSPEAK round-trip convergence analyzer.

Usage:
  python3 analyze.py <word-counts.csv> <results-dir>

Reads the CSV log and all iteration files, then reports:
  - Word count at each step (compress vs translate)
  - Similarity between consecutive iterations (difflib ratio)
  - Similarity between iter-0 prose and final prose (semantic drift)
  - Convergence table: when does it stabilize?
"""

import csv
import sys
import os
import difflib
from pathlib import Path


def read_file(path):
    try:
        return Path(path).read_text(encoding="utf-8")
    except FileNotFoundError:
        return None


def similarity(a, b):
    """difflib sequence similarity ratio 0.0–1.0."""
    if not a or not b:
        return 0.0
    return difflib.SequenceMatcher(None, a, b).ratio()


def word_count(text):
    return len(text.split()) if text else 0


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 analyze.py <word-counts.csv> <results-dir>")
        sys.exit(1)

    csv_path = sys.argv[1]
    results_dir = sys.argv[2]

    # Read CSV
    rows = []
    with open(csv_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)

    # Read all files
    files = {}
    for row in rows:
        fname = os.path.join(results_dir, row["file"])
        files[row["file"]] = read_file(fname)

    # ── Word Count Table ──────────────────────────────────────────────────────
    print("\n" + "=" * 70)
    print("WORD COUNT PER ITERATION")
    print("=" * 70)
    print(f"{'Iter':<6} {'Stage':<10} {'Words':>7}  {'Δ from prev':>12}")
    print("-" * 70)

    prev_words = None
    for row in rows:
        w = int(row["words"])
        delta = f"{w - prev_words:+d}" if prev_words is not None else "—"
        print(f"{row['iteration']:<6} {row['stage']:<10} {w:>7}  {delta:>12}")
        prev_words = w

    # ── Similarity Between Consecutive Prose Versions ─────────────────────────
    print("\n" + "=" * 70)
    print("PROSE→PROSE SIMILARITY (consecutive iterations)")
    print("=" * 70)
    print(f"{'Comparison':<35} {'Similarity':>10}  {'Drift':>8}")
    print("-" * 70)

    prose_rows = [r for r in rows if r["stage"] == "prose"]
    for i in range(1, len(prose_rows)):
        a_key = prose_rows[i - 1]["file"]
        b_key = prose_rows[i]["file"]
        a = files.get(a_key, "")
        b = files.get(b_key, "")
        ratio = similarity(a, b)
        drift = 1.0 - ratio
        label = f"iter {prose_rows[i-1]['iteration']} → iter {prose_rows[i]['iteration']}"
        print(f"{label:<35} {ratio:>10.4f}  {drift:>8.4f}")

    # ── First vs Last Prose ───────────────────────────────────────────────────
    if len(prose_rows) >= 2:
        first_key = prose_rows[0]["file"]
        last_key  = prose_rows[-1]["file"]
        first = files.get(first_key, "")
        last  = files.get(last_key, "")
        ratio = similarity(first, last)
        print()
        print(f"First prose → Last prose:  {ratio:.4f} similarity  ({(1-ratio):.4f} total drift)")

    # ── Convergence Detection ─────────────────────────────────────────────────
    print("\n" + "=" * 70)
    print("CONVERGENCE ANALYSIS")
    print("=" * 70)

    # Look at botspeak word counts — when do they stabilize?
    bs_rows = [r for r in rows if r["stage"] == "botspeak"]
    if len(bs_rows) >= 2:
        print(f"{'Iter':<6} {'BOTSPEAK words':>15}  {'Δ':>8}  {'Stable?':>8}")
        print("-" * 70)
        prev = None
        stable_at = None
        STABLE_THRESHOLD = 20  # words
        for r in bs_rows:
            w = int(r["words"])
            delta = abs(w - prev) if prev is not None else None
            stable = "YES" if (delta is not None and delta <= STABLE_THRESHOLD) else ("—" if delta is None else "")
            if stable == "YES" and stable_at is None:
                stable_at = int(r["iteration"])
            print(f"{r['iteration']:<6} {w:>15}  {('+'+str(delta) if delta else '—'):>8}  {stable:>8}")
        if stable_at:
            print(f"\n→ Converges at iteration {stable_at} (Δ ≤ {STABLE_THRESHOLD} words)")
        else:
            print(f"\n→ Did not converge within {len(bs_rows)} iterations")

    # ── Summary ───────────────────────────────────────────────────────────────
    if rows:
        source_words = int(rows[0]["words"])
        bs_first = next((int(r["words"]) for r in rows if r["stage"] == "botspeak"), None)
        bs_last  = next((int(r["words"]) for r in reversed(rows) if r["stage"] == "botspeak"), None)
        if bs_first and bs_last:
            print("\n" + "=" * 70)
            print("SUMMARY")
            print("=" * 70)
            print(f"  Source:              {source_words:>6} words")
            print(f"  First BOTSPEAK:      {bs_first:>6} words  ({100*(source_words-bs_first)/source_words:.1f}% reduction)")
            print(f"  Final BOTSPEAK:      {bs_last:>6} words  ({100*(source_words-bs_last)/source_words:.1f}% reduction)")
            print(f"  Compression floor:   {100*(source_words-bs_last)/source_words:.1f}%  (stable minimum)")


if __name__ == "__main__":
    main()
