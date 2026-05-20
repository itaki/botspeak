#!/usr/bin/env python3
"""Parity check for BOTSPEAK game eval HTML pairs.

For each game (Flappy Bird, Snake, Pong, Breakout) this script extracts every
numeric `const` / `let` / `var` declaration from the prose-built and
BOTSPEAK-built HTML files, normalizes the values, and compares the resulting
identifier → value maps.

The script's strongest claim is detection of *mismatches*: an identifier that
appears in BOTH files with the SAME exact name but a DIFFERENT numeric value.
Those are real parity failures. Identifiers present in only one file are
reported too, but are often just naming differences (e.g. `CANVAS_WIDTH` vs
`CW`) and don't cause the script to fail.

Usage (from repo root):
    python3 evals/scripts/parity_check.py

Exit code:
    0 -> no name-level mismatches across all four games
    1 -> at least one identifier with the same name has a different value
"""

from __future__ import annotations

import ast
import re
import sys
from pathlib import Path
from typing import Iterator

REPO = Path(__file__).resolve().parents[2]

GAMES: list[tuple[str, str]] = [
    ("game-prompt", "Flappy Bird"),
    ("snake-prompt", "Snake"),
    ("pong-prompt", "Pong"),
    ("breakout-prompt", "Breakout"),
]

PROSE_FILE = "prose-sonnet.html"
BOTSPEAK_FILE = "botspeak-sonnet-v22.html"

# Identifiers we always treat as throwaways (loop counters, scratch coords).
# Single-letter names are skipped automatically; this set is for short
# multi-letter names that are clearly local scratch state.
THROWAWAY: set[str] = {
    "dx", "dy", "dz",
    "cx", "cy", "cz",
    "rx", "ry", "rw", "rh",
    "sx", "sy", "sw", "sh",
    "tx", "ty", "tw", "th",
    "nx", "ny",
    "ox", "oy",
    "px", "py",
}

_IDENT_RE = re.compile(r"[A-Za-z_$][A-Za-z0-9_$]*")
_KEYWORD_RE = re.compile(r"\b(?:const|let|var)\b")


def strip_js_comments(src: str) -> str:
    """Remove /* ... */ and // ... comments. Naive about string literals,
    which is fine for the eval HTML files (no // inside JS strings)."""
    src = re.sub(r"/\*.*?\*/", "", src, flags=re.DOTALL)
    src = re.sub(r"//[^\n]*", "", src)
    return src


def find_declarations(src: str) -> Iterator[tuple[str, str]]:
    """Yield (name, value_expr) for each `const`/`let`/`var` assignment.

    Walks the source one statement at a time. The statement terminator is a
    top-level `;` (depth 0 outside (), [], {}, and quoted strings). Multi-
    declarations like `const A = 1, B = 2;` are split on top-level commas.
    """
    pos = 0
    while True:
        m = _KEYWORD_RE.search(src, pos)
        if m is None:
            return
        start = m.end()
        end = _find_statement_end(src, start)
        body = src[start:end]
        pos = end + 1
        for part in _split_top_level(body, ","):
            eq = _find_top_level_eq(part)
            if eq < 0:
                continue
            name = part[:eq].strip()
            expr = part[eq + 1:].strip()
            if not _IDENT_RE.fullmatch(name):
                # Destructuring patterns, qualified names, etc.
                continue
            yield name, expr


def _find_statement_end(src: str, start: int) -> int:
    depth = 0
    in_str: str | None = None
    i = start
    while i < len(src):
        ch = src[i]
        if in_str is not None:
            if ch == "\\":
                i += 2
                continue
            if ch == in_str:
                in_str = None
        else:
            if ch in ("'", '"', "`"):
                in_str = ch
            elif ch in "([{":
                depth += 1
            elif ch in ")]}":
                depth -= 1
            elif ch == ";" and depth == 0:
                return i
        i += 1
    return len(src)


def _split_top_level(text: str, sep: str) -> list[str]:
    parts: list[str] = []
    depth = 0
    in_str: str | None = None
    buf: list[str] = []
    i = 0
    while i < len(text):
        ch = text[i]
        if in_str is not None:
            buf.append(ch)
            if ch == "\\" and i + 1 < len(text):
                buf.append(text[i + 1])
                i += 2
                continue
            if ch == in_str:
                in_str = None
            i += 1
            continue
        if ch in ("'", '"', "`"):
            in_str = ch
            buf.append(ch)
            i += 1
            continue
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if depth == 0 and ch == sep:
            parts.append("".join(buf))
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1
    parts.append("".join(buf))
    return parts


def _find_top_level_eq(text: str) -> int:
    """Return index of first top-level `=` that is not part of `==`, `===`,
    `!=`, `<=`, `>=`, or `=>`."""
    depth = 0
    in_str: str | None = None
    i = 0
    while i < len(text):
        ch = text[i]
        if in_str is not None:
            if ch == "\\":
                i += 2
                continue
            if ch == in_str:
                in_str = None
            i += 1
            continue
        if ch in ("'", '"', "`"):
            in_str = ch
        elif ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        elif depth == 0 and ch == "=":
            prev = text[i - 1] if i > 0 else ""
            nxt = text[i + 1] if i + 1 < len(text) else ""
            if nxt == "=" or prev in ("=", "!", "<", ">"):
                i += 1
                continue
            if nxt == ">":
                # arrow function in default value; treat as not-assignment here
                i += 2
                continue
            return i
        i += 1
    return -1


class _SafeEval(ast.NodeVisitor):
    """Evaluate a tiny subset of Python AST: numeric literals, unary +/-,
    binary +/-/* / // % **, and previously-bound identifier names."""

    def __init__(self, scope: dict[str, float]) -> None:
        self.scope = scope

    def visit_Expression(self, node: ast.Expression) -> float:
        return self.visit(node.body)

    def visit_Constant(self, node: ast.Constant) -> float:
        if isinstance(node.value, bool) or not isinstance(node.value, (int, float)):
            raise ValueError("non-numeric constant")
        return float(node.value)

    def visit_UnaryOp(self, node: ast.UnaryOp) -> float:
        v = self.visit(node.operand)
        if isinstance(node.op, ast.USub):
            return -v
        if isinstance(node.op, ast.UAdd):
            return +v
        raise ValueError("unsupported unary op")

    def visit_BinOp(self, node: ast.BinOp) -> float:
        left = self.visit(node.left)
        right = self.visit(node.right)
        op = node.op
        if isinstance(op, ast.Add):
            return left + right
        if isinstance(op, ast.Sub):
            return left - right
        if isinstance(op, ast.Mult):
            return left * right
        if isinstance(op, ast.Div):
            return left / right
        if isinstance(op, ast.FloorDiv):
            return left // right
        if isinstance(op, ast.Mod):
            return left % right
        if isinstance(op, ast.Pow):
            return left ** right
        raise ValueError("unsupported binop")

    def visit_Name(self, node: ast.Name) -> float:
        if node.id in self.scope:
            return self.scope[node.id]
        raise ValueError(f"unknown name {node.id}")

    def generic_visit(self, node: ast.AST) -> float:
        raise ValueError(f"unsupported node {type(node).__name__}")


def try_eval_numeric(expr: str, scope: dict[str, float]) -> float | None:
    """Return a float if `expr` is a pure numeric expression using only
    literals, simple arithmetic, and names already in `scope`. Otherwise
    return None (which means "skip this declaration")."""
    expr = expr.strip()
    if not expr:
        return None
    # Reject anything with function calls, object/array literals, strings,
    # ternaries, logical/comparison/bitwise ops, etc.
    bad_chars = set("(){}[]'\"`?<>&|^~!:,")
    if any(c in bad_chars for c in expr):
        return None
    try:
        tree = ast.parse(expr, mode="eval")
    except SyntaxError:
        return None
    try:
        return _SafeEval(scope).visit(tree)
    except (ValueError, ZeroDivisionError):
        return None


def _is_throwaway(name: str) -> bool:
    return len(name) == 1 or name in THROWAWAY


def extract_numeric_constants(html_path: Path) -> dict[str, float]:
    """Extract all numeric const/let/var declarations from the HTML's
    embedded JavaScript. Returns identifier → float."""
    src = strip_js_comments(html_path.read_text(encoding="utf-8"))
    scope: dict[str, float] = {}
    out: dict[str, float] = {}
    for name, expr in find_declarations(src):
        value = try_eval_numeric(expr, scope)
        if value is None:
            continue
        # Track the bound value so later expressions can reference it,
        # even for throwaway names that we won't surface in the report.
        scope[name] = value
        if _is_throwaway(name):
            continue
        # Last declaration of a re-declared name wins. In practice both files
        # rarely re-declare top-level constants, and the *initial* value of
        # state like `score = 0` is what we want to compare anyway.
        out.setdefault(name, value)
    return out


def _normalize(v: float) -> float:
    """Round to 6 decimal places so 9 and 9.0 (and floats with tiny drift) compare equal."""
    return round(v, 6)


def _format_value(v: float) -> str:
    if v == int(v):
        return str(int(v))
    return f"{v:g}"


def compare_maps(prose: dict[str, float], bspeak: dict[str, float]) -> dict[str, list]:
    matches: list[tuple[str, float]] = []
    mismatches: list[tuple[str, float, float]] = []
    prose_only: list[tuple[str, float]] = []
    bspeak_only: list[tuple[str, float]] = []
    for name in sorted(set(prose) | set(bspeak)):
        in_p = name in prose
        in_b = name in bspeak
        if in_p and in_b:
            if _normalize(prose[name]) == _normalize(bspeak[name]):
                matches.append((name, prose[name]))
            else:
                mismatches.append((name, prose[name], bspeak[name]))
        elif in_p:
            prose_only.append((name, prose[name]))
        else:
            bspeak_only.append((name, bspeak[name]))
    return {
        "matches": matches,
        "mismatches": mismatches,
        "prose_only": prose_only,
        "bspeak_only": bspeak_only,
    }


def main() -> int:
    summary_rows: list[tuple[str, int, int, int, int, int, int]] = []
    any_mismatch = False

    for folder, game_name in GAMES:
        prose_path = REPO / "evals" / folder / "results" / PROSE_FILE
        bspeak_path = REPO / "evals" / folder / "results" / BOTSPEAK_FILE

        prose = extract_numeric_constants(prose_path)
        bspeak = extract_numeric_constants(bspeak_path)
        res = compare_maps(prose, bspeak)

        print(f"\n## {game_name}  ({folder})")
        print(f"  prose identifiers:    {len(prose)}")
        print(f"  BOTSPEAK identifiers: {len(bspeak)}")
        print(f"  shared & matching:    {len(res['matches'])}")
        print(f"  shared & MISMATCH:    {len(res['mismatches'])}")
        print(f"  only in prose:        {len(res['prose_only'])}")
        print(f"  only in BOTSPEAK:     {len(res['bspeak_only'])}")

        if res["mismatches"]:
            any_mismatch = True
            print("\n  !! MISMATCHES (same name, different value):")
            for name, pv, bv in res["mismatches"]:
                print(f"     {name}: prose={_format_value(pv)}  botspeak={_format_value(bv)}")

        if res["matches"]:
            print("\n  shared identifiers that match:")
            for name, v in res["matches"]:
                print(f"     {name} = {_format_value(v)}")

        if res["prose_only"]:
            print("\n  only in prose (often renamed in BOTSPEAK):")
            for name, v in res["prose_only"]:
                print(f"     {name} = {_format_value(v)}")

        if res["bspeak_only"]:
            print("\n  only in BOTSPEAK (often renamed from prose):")
            for name, v in res["bspeak_only"]:
                print(f"     {name} = {_format_value(v)}")

        summary_rows.append((
            game_name,
            len(prose),
            len(bspeak),
            len(res["matches"]),
            len(res["mismatches"]),
            len(res["prose_only"]),
            len(res["bspeak_only"]),
        ))

    print("\n\n## Summary (across all four games)\n")
    print("| Game | prose ids | BOTSPEAK ids | shared+match | shared+mismatch | prose-only | BOTSPEAK-only |")
    print("|---|---:|---:|---:|---:|---:|---:|")
    for row in summary_rows:
        print(f"| {row[0]} | {row[1]} | {row[2]} | {row[3]} | {row[4]} | {row[5]} | {row[6]} |")

    print()
    if any_mismatch:
        print("RESULT: shared-name MISMATCHES found — parity NOT preserved at the identifier level.")
        return 1
    print("RESULT: no shared-name mismatches across all four games.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
