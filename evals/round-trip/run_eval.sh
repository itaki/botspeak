#!/usr/bin/env bash
# Direct runner — avoids quoting issues by writing prompts to temp files.
set -e

CLAUDE=/Users/michaelmcreynolds/.nvm/versions/node/v24.12.0/bin/claude

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$SCRIPT_DIR/source.md"
RESULTS="$SCRIPT_DIR/results"
ITERATIONS=5

mkdir -p "$RESULTS"

word_count() { wc -w < "$1" | tr -d ' '; }

LOG="$RESULTS/source-word-counts.csv"
echo "iteration,stage,file,words" > "$LOG"

cp "$SOURCE" "$RESULTS/source-iter-00-prose.md"
SEED=$(word_count "$SOURCE")
echo "0,prose,source-iter-00-prose.md,$SEED" >> "$LOG"
echo "Source: $SEED words"

PREV="$RESULTS/source-iter-00-prose.md"

for i in $(seq 1 $ITERATIONS); do
  ITER=$(printf "%02d" $i)
  BOTSPEAK_FILE="$RESULTS/source-iter-${ITER}-botspeak.md"
  PROSE_FILE="$RESULTS/source-iter-${ITER}-prose.md"

  echo "=== Iter $i / $ITERATIONS: compressing..."

  # Write compress prompt to temp file to avoid shell quoting of operators
  COMPRESS_PROMPT=$(mktemp)
  cat > "$COMPRESS_PROMPT" <<'PROMPT'
You are a BOTSPEAK compressor. Compress the following document into BOTSPEAK notation.

Rules:
- Build @defs block: identifiers used 3+ times get a mnemonic abbreviation
- Use ASCII operators: -> (leads-to), !! (never/forbidden), ok (allowed), && (AND), || (OR), ~~ (warn)
- Add phase tags to blocks: [ALWAYS] [ON-TRIGGER] [REFERENCE]
- Drop: articles, filler, hedging, duplicate restatements
- Keep byte-for-byte: exact values (numbers, px, Hz, colors), constraint polarity, cause chains
- Wrap sections in XML if doc >10 lines: <context> <rules> <reference>
- Never compress code blocks or URLs

Output only the compressed document, no commentary.

---
PROMPT
  cat "$PREV" >> "$COMPRESS_PROMPT"

  $CLAUDE -p "$(cat "$COMPRESS_PROMPT")" > "$BOTSPEAK_FILE"
  rm "$COMPRESS_PROMPT"

  C_WORDS=$(word_count "$BOTSPEAK_FILE")
  echo "$i,botspeak,source-iter-${ITER}-botspeak.md,$C_WORDS" >> "$LOG"
  echo "  botspeak: $C_WORDS words"

  echo "=== Iter $i / $ITERATIONS: translating..."

  TRANSLATE_PROMPT=$(mktemp)
  cat > "$TRANSLATE_PROMPT" <<'PROMPT'
You are a BOTSPEAK translator. Expand the following BOTSPEAK document into clear human prose.

Rules:
- Expand @defs: replace every alias with its full form
- Expand operators: -> "leads to", !! "never", ok "allowed", && "and", || "or", ~~ "check first"
- Expand phase tags: [ALWAYS] = "In every turn:", [ON-TRIGGER] = "When triggered:", [REFERENCE] = "For reference:"
- Write full sentences with proper grammar
- Preserve all exact values verbatim (numbers, px, Hz, colors)
- Add no interpretation beyond what the BOTSPEAK states

Output only the translated prose document, no commentary.

---
PROMPT
  cat "$BOTSPEAK_FILE" >> "$TRANSLATE_PROMPT"

  $CLAUDE -p "$(cat "$TRANSLATE_PROMPT")" > "$PROSE_FILE"
  rm "$TRANSLATE_PROMPT"

  T_WORDS=$(word_count "$PROSE_FILE")
  echo "$i,prose,source-iter-${ITER}-prose.md,$T_WORDS" >> "$LOG"
  echo "  prose: $T_WORDS words"
  echo ""

  PREV="$PROSE_FILE"
done

echo "=== DONE ==="
echo ""
cat "$LOG"
echo ""
echo "Run analysis:"
echo "  python3 $SCRIPT_DIR/analyze.py $LOG $RESULTS"
