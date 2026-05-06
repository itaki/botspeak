---
name: botspeak
description: Compress an existing AI-facing document (rule, skill, CLAUDE.md, memory page, handoff) — or an entire directory of them — into BOTSPEAK notation. Use when the user says "botspeak this", "compress this rule", "make this shorter for the bot", or invokes /botspeak.
triggers: ["botspeak this", "compress this", "make this shorter for the bot", "/botspeak", "convert to botspeak", "optimize this for tokens"]
---

[ALWAYS] role = compressor · input = AI-facing doc (file ref || pasted text || directory) · output = semantically identical BOTSPEAK
[ALWAYS] every word the USER reads (classification, questions, summary) = full human prose · zero BOTSPEAK in chat
[ALWAYS] user explicitly targets a file -> execute immediately · !! do not second-guess file choice · !! do not ask clarifying questions about file type or audience
!! do not compress: YAML frontmatter · description fields · trigger phrases · code blocks · URLs · file paths

# input mode detection
determine input type before acting:
  A. file reference (@file or explicit path) -> single-file mode: replace file in place
  B. pasted text (no file ref) -> new-file mode: infer filename from content, create new file
  C. directory -> directory mode (see below)
  + `-c` || `--chat` (|| equivalent intent: "in chat", "render here", "no file", "preview") -> chat mode: output to chat · no file created
  + `-bu` || `--backup` (|| equivalent intent: "back it up", "keep the original") -> backup mode: copy original before replacing

# backup mode (`-bu` / `--backup`)
[ON-TRIGGER] USER signals backup
  -> copy original -> `[filename].bu.YYYYMMDD.[ext]` (e.g., `my-rule.bu.20260506.md`)
  !! abort if backup write fails · do not compress until backup confirmed
  -> then replace file in place as normal
  -> tell user: "Backed up to [backup path]. Saved compressed version to [original path]."
  note: backup files are gitignore-able via `*.bu.*.md`

# chat mode override (`-c` / `--chat`)
[ON-TRIGGER] USER signals chat output
  -> run compression as normal
  -> write BOTSPEAK output to chat instead of file
  note: explicit override of "BOTSPEAK never in chat" rule — user requested it

# new-file mode (pasted text, no file reference)
[ON-TRIGGER] input = pasted text && no file reference
  -> compress the text
  -> infer filename from content purpose (e.g., `api-auth-rule.md`, `session-handoff.md`, `deploy-checklist.md`)
  -> write BOTSPEAK output to that new file
  -> tell user: "Created [filename]"
  if content purpose is ambiguous -> ask user for filename before writing

# pre-flight check (any input)
[ALWAYS] before compressing: estimate tokens (chars / 4)
  < 25K tokens -> proceed silently
  >= 25K tokens -> note USER: "this is a large file (~Xk tokens). recommend cheap model (Haiku · GPT-4o-mini)."
  >= 50K tokens -> warn USER: "this file is ~Xk tokens. est ~Y min on Haiku. proceed? · cancel"

# token math (reference)
plain UTF-8 English:
  1 KB ≈ 256 tokens (chars / 4 rule)
  50 KB ≈ 12.5K tokens
  100 KB ≈ 25K tokens
  400 KB ≈ 100K tokens

# measured timing (Haiku, May 2026)
  ~2 min per 50 KB · scales roughly linearly
  -> 100 KB ≈ 4 min · 200 KB ≈ 8 min · 400 KB ≈ 16 min
  Opus / Sonnet thinking models: 3-5x slower

# directory mode
[ON-TRIGGER] input = directory != file

step D1: scan
  enumerate .md && .mdc files in dir
  per file: name · size (KB) · est tokens (chars / 4)
  flags: > 5K tok = "significant" · > 10K tok = "alert" · > 25K tok = "enormous"
  totals: file count · total KB · total est input tokens

step D2: report + offer choice
  show numbered file table with token counts && flags
  show totals
  note: "for batches > 25K tokens, switch to cheap model (Haiku · GPT-4o-mini) before running"
  ask USER:
    1. backup all && convert (recommended for large batches)
    2. convert · no backup
    3. cancel

  for specific files: instruct USER to pass them via IDE @ syntax instead of directory

step D3: backup if chosen
  copy <dir> -> <dir>_backup_<YYYYMMDD>/
  !! abort if backup fails

step D4: convert
  per file in dir:
    apply single-file flow below (steps 1-6)
    log: [i/N] · before/after token est · savings %

step D5: summary
  converted · skipped · errors
  total tokens before -> total tokens after
  est tokens saved per future session (the real value prop)
  backup path (if backup was made)

# ─── single-file compression flow ───

# step 1: inventory the doc
scan for:
  invariants ("never", "always", "must", "required", "critical")
  triggers ("when X", "if Y", "after Z")
  constraints (allowed values, forbidden values, exact numbers)
  cause chains (A leads to B, B causes C)
  repeated identifiers (used >=3 times -> alias candidates)
  phase context (session-start vs always-active vs reference vs handoff)

# step 2: build @defs
for each identifier used >=3 times in the doc:
  pick mnemonic abbreviation (E for establishment_id · MV for materialized-view · WR for wine-report)
  add to @defs block at top of output
  replace every occurrence with the short form

if doc >10 lines && has clear sections -> use XML macro-structure: <context> <defs> <rules> <reference>

# step 3: tag every block
every content block gets a phase tag:
  [NEW-CHAT]   session-init context; agent may skip once established
  [ALWAYS]     must fire every turn; no exceptions
  [ON-TRIGGER] conditional; attach the trigger condition explicitly
  [REFERENCE]  lookup-only; skip during normal load
  [HANDOFF]    cross-session context; new agent reads first turn only

# step 4: compress prose
drop:
  articles (a, the, an)
  filler ("in order to", "please note that", "it is important to")
  hedging ("you might want to", "generally speaking", "typically")
  throat-clearing ("as mentioned above", "to summarize")
  duplicate restatements (same constraint said 3 ways -> keep the clearest)

keep byte-for-byte:
  exact values (version numbers, IDs, limits, timeouts)
  constraint polarity (!! never vs ok allowed — wrong polarity = bug)
  cause chains (A -> B; don't collapse)
  conditional logic (if/then; don't merge into a list)

# step 5: choose dialect
ASCII (default — 1 token/symbol guaranteed):
  ->   leads-to     !!   never/forbidden    ok   allowed
  &&   AND          ||   OR                ~~   warn/check-first
  !=   not-equal    =    defined-as

Symbol (only if user asked, or doc will be read by humans regularly):
  see SPEC.md symbol table — emojis/unicode cost 3-15 tokens each; ASCII is always cheaper

!! do NOT mix dialects within a single file

# step 6: output

for file mode (default):
  write BOTSPEAK to file (replace in place for file refs · new file for pasted text)
  tell user: "Saved to [path]" (if -bu: "Backed up to [backup path]. Saved to [path].")
  plain-prose summary: "This document now says: [2-3 sentences]"
  token savings estimate: before vs after
  ask: "Does this match what the original said? Run /botspeak-translate to verify."

for chat mode (-c / --chat):
  write BOTSPEAK output to chat
  plain-prose summary: "This document now says: [2-3 sentences]"
  token savings estimate: before vs after

# the inviolable rule
[ALWAYS] user reads it -> prose · agent reads it -> BOTSPEAK
!! if compression changes the meaning or strength of any constraint, revert that constraint to its original form
