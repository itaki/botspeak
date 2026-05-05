#!/usr/bin/env bash
# BOTSPEAK round-trip fidelity eval
# Tests whether compress → translate cycles converge or drift.
#
# Usage:
#   ./run.sh <source.md> [iterations]
#
# Requires: claude CLI (claude.ai/code) with /botspeak and /translate-botspeak skills installed.
# Output: evals/round-trip/results/ — one file per iteration, word-count log.

set -e

SOURCE="${1:-}"
ITERATIONS="${2:-10}"
RESULTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/results"

if [ -z "$SOURCE" ]; then
  echo "Usage: $0 <source.md> [iterations=10]"
  echo "Example: $0 ../../evals/game-prompt/source.md 10"
  exit 1
fi

if [ ! -f "$SOURCE" ]; then
  echo "Error: source file not found: $SOURCE"
  exit 1
fi

mkdir -p "$RESULTS_DIR"

word_count() { wc -w < "$1" | tr -d ' '; }

SOURCE_ABS="$(cd "$(dirname "$SOURCE")" && pwd)/$(basename "$SOURCE")"
BASENAME="$(basename "$SOURCE" .md)"
LOG="$RESULTS_DIR/${BASENAME}-word-counts.csv"

echo "iteration,file,words,change_from_prev" > "$LOG"
echo "0,source,$(word_count "$SOURCE_ABS")," >> "$LOG"
echo "source: $(word_count "$SOURCE_ABS") words"

cp "$SOURCE_ABS" "$RESULTS_DIR/${BASENAME}-iter-00-prose.md"

PREV_COUNT=$(word_count "$SOURCE_ABS")
PREV_FILE="$RESULTS_DIR/${BASENAME}-iter-00-prose.md"

for i in $(seq 1 "$ITERATIONS"); do
  ITER=$(printf "%02d" "$i")
  COMPRESSED="$RESULTS_DIR/${BASENAME}-iter-${ITER}-botspeak.md"
  TRANSLATED="$RESULTS_DIR/${BASENAME}-iter-${ITER}-prose.md"

  echo ""
  echo "=== Iteration $i / $ITERATIONS ==="

  # Compress: prose → BOTSPEAK
  echo "  compressing..."
  claude --print "$(cat <<PROMPT
/botspeak

$(cat "$PREV_FILE")
PROMPT
)" > "$COMPRESSED"

  C_COUNT=$(word_count "$COMPRESSED")
  CHANGE=$(( C_COUNT - PREV_COUNT ))
  echo "  compressed: $C_COUNT words (${CHANGE} from prev)"
  echo "$i,${BASENAME}-iter-${ITER}-botspeak,$C_COUNT,$CHANGE" >> "$LOG"
  PREV_COUNT=$C_COUNT
  PREV_FILE="$COMPRESSED"

  # Translate: BOTSPEAK → prose
  echo "  translating..."
  claude --print "$(cat <<PROMPT
/translate-botspeak

$(cat "$COMPRESSED")
PROMPT
)" > "$TRANSLATED"

  T_COUNT=$(word_count "$TRANSLATED")
  CHANGE=$(( T_COUNT - PREV_COUNT ))
  echo "  translated: $T_COUNT words (${CHANGE} from prev)"
  echo "$i,${BASENAME}-iter-${ITER}-prose,$T_COUNT,$CHANGE" >> "$LOG"
  PREV_COUNT=$T_COUNT
  PREV_FILE="$TRANSLATED"
done

echo ""
echo "=== Done ==="
echo "Results in: $RESULTS_DIR"
echo "Word count log: $LOG"
echo ""
echo "Quick summary:"
cat "$LOG"
echo ""
echo "Compare first and last:"
echo "  diff $RESULTS_DIR/${BASENAME}-iter-00-prose.md $RESULTS_DIR/${BASENAME}-iter-$(printf "%02d" "$ITERATIONS")-prose.md | head -40"
