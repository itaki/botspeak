#!/usr/bin/env bash
# BOTSPEAK round-trip fidelity eval
# Runs N compress→translate cycles and logs word count at each step.
#
# Usage:
#   ./run.sh <source.md> [iterations=10]
#
# Requires: claude CLI (claude.ai/code)
# Output: round-trip/results/ — one file per half-iteration, word-count CSV

set -e

# Requires claude CLI to be available in your shell.
# Run this from a terminal where `claude` is already authenticated and working.
if ! command -v claude &>/dev/null; then
  echo "Error: claude CLI not found. Run this from a terminal where 'claude' works."
  exit 1
fi
CLAUDE=claude

SOURCE="${1:-}"
ITERATIONS="${2:-10}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"

if [ -z "$SOURCE" ]; then
  echo "Usage: $0 <source.md> [iterations=10]"
  echo "Example: $0 ../../evals/game-prompt/source.md 10"
  exit 1
fi

[ -f "$SOURCE" ] || { echo "Error: source file not found: $SOURCE"; exit 1; }

mkdir -p "$RESULTS_DIR"

word_count() { wc -w < "$1" | tr -d ' '; }

SOURCE_ABS="$(cd "$(dirname "$SOURCE")" && pwd)/$(basename "$SOURCE")"
BASENAME="$(basename "$SOURCE" .md)"
LOG="$RESULTS_DIR/${BASENAME}-word-counts.csv"

echo "iteration,stage,file,words" > "$LOG"

# Seed: copy source as iter-00-prose
cp "$SOURCE_ABS" "$RESULTS_DIR/${BASENAME}-iter-00-prose.md"
SEED_WORDS=$(word_count "$SOURCE_ABS")
echo "0,prose,${BASENAME}-iter-00-prose.md,${SEED_WORDS}" >> "$LOG"
echo "source: $SEED_WORDS words → $RESULTS_DIR"
echo ""

PREV_FILE="$RESULTS_DIR/${BASENAME}-iter-00-prose.md"

# Inline BOTSPEAK compress instructions (no skill invocation needed)
COMPRESS_INSTRUCTIONS='You are a BOTSPEAK compressor. BOTSPEAK is a compressed notation for AI-facing documents.

Rules:
- Build @defs block: identifiers used >=3x get a mnemonic abbreviation (E=establishment_id, MV=materialized-view, etc)
- Use ASCII operators: -> (leads-to), !! (never/forbidden), ok (allowed), && (AND), || (OR), ~~ (warn), != (not-equal)
- Add phase tags to every block: [NEW-CHAT] [ALWAYS] [ON-TRIGGER] [REFERENCE] [HANDOFF]
- Drop: articles, filler, hedging, throat-clearing, duplicate restatements
- Keep byte-for-byte: exact values (numbers, colors, Hz, px), constraint polarity, cause chains
- Long docs (>10 lines): wrap sections in XML: <context> <rules> <reference>
- Never compress YAML frontmatter, code blocks, URLs, or file paths

Compress the following document into BOTSPEAK. Output only the compressed document, no commentary.'

# Inline BOTSPEAK translate instructions
TRANSLATE_INSTRUCTIONS='You are a BOTSPEAK translator. Expand the following BOTSPEAK document into clear human prose.

Rules:
- Expand @defs: replace every alias with its full form (E -> establishment_id, etc)
- Expand operators: -> becomes "leads to", !! becomes "never", ok becomes "allowed", && becomes "and", || becomes "or", ~~ becomes "check first / warn"
- Expand phase tags: [ALWAYS] -> "In every turn:", [NEW-CHAT] -> "At session start:", [ON-TRIGGER] -> "When triggered:", [REFERENCE] -> "For reference:", [HANDOFF] -> "From the previous session:"
- Write full sentences with proper grammar
- Preserve all exact values verbatim (numbers, colors, Hz, px)
- Do not add interpretation beyond what the BOTSPEAK states

Output only the translated prose document, no commentary.'

for i in $(seq 1 "$ITERATIONS"); do
  ITER=$(printf "%02d" "$i")
  COMPRESSED="$RESULTS_DIR/${BASENAME}-iter-${ITER}-botspeak.md"
  TRANSLATED="$RESULTS_DIR/${BASENAME}-iter-${ITER}-prose.md"

  echo "=== Iteration $i / $ITERATIONS ==="

  # Compress: prose → BOTSPEAK
  echo "  compressing..."
  claude -p "$COMPRESS_INSTRUCTIONS

---

$(cat "$PREV_FILE")" > "$COMPRESSED"

  C_WORDS=$(word_count "$COMPRESSED")
  echo "$i,botspeak,${BASENAME}-iter-${ITER}-botspeak.md,$C_WORDS" >> "$LOG"
  echo "  botspeak: $C_WORDS words"

  # Translate: BOTSPEAK → prose
  echo "  translating..."
  claude -p "$TRANSLATE_INSTRUCTIONS

---

$(cat "$COMPRESSED")" > "$TRANSLATED"

  T_WORDS=$(word_count "$TRANSLATED")
  echo "$i,prose,${BASENAME}-iter-${ITER}-prose.md,$T_WORDS" >> "$LOG"
  echo "  prose:    $T_WORDS words"
  echo ""

  PREV_FILE="$TRANSLATED"
done

echo "=== Complete ==="
echo "Results: $RESULTS_DIR"
echo "Log: $LOG"
echo ""
echo "Run the analysis:"
echo "  python3 $SCRIPT_DIR/analyze.py $LOG $RESULTS_DIR"
