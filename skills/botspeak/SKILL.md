---
name: botspeak
description: Compress an existing AI-facing document (rule, skill, CLAUDE.md, memory page, handoff) — or an entire directory of them — into BOTSPEAK notation. Use when the user says "botspeak this", "compress this rule", "make this shorter for the bot", or invokes /botspeak.
triggers: ["botspeak this", "compress this", "make this shorter for the bot", "/botspeak", "convert to botspeak", "optimize this for tokens"]
---

@defs
  BT  = BOTSPEAK
  HP  = human prose
  TKN = token
@end

## core tenets (from SPEC §0 · in priority order)

[ALWAYS] tenet-1: clarity > compression · any compression that sacrifices meaning, polarity, or constraint strength -> revert that part to prose
[ALWAYS] tenet-2: any modern LLM must read BT without the spec · borrow only notation AIs already know
[ALWAYS] tenet-3: prefer regex · markdown · common programming notation · universal emoji · over invented syntax
[ALWAYS] tenet-4: ASCII when ASCII does the same job (`->` beats `→`) · emoji when it genuinely compresses meaning (📊 replaces "bar chart of")
[ALWAYS] tenet-5: one-shot reliability > brevity · output must be unambiguous when read by ANY model (Haiku · Sonnet · Opus · GPT-4o-mini · etc.) without conversation · if a phrase could be interpreted two ways -> expand it

## role and inviolable rules

[ALWAYS] role: compressor · input: AI-facing doc · output: semantically identical BT doc
[ALWAYS] every word USER reads (classification · questions · summary) = full HP · zero BT in chat
[ALWAYS] USER explicitly targets a file -> execute immediately · !! no second-guessing file choice · !! no clarifying questions about file type or audience
!! never compress: YAML frontmatter · description fields · trigger phrases · code blocks · URLs · file paths

## metadata header (REQUIRED)

[ALWAYS] every BT output MUST begin with a metadata comment as the first non-frontmatter line:
  format: `<!-- BOTSPEAK v0.2.0 · compressed by [model] · YYYY-MM-DD -->`
  if file has YAML frontmatter -> place metadata comment immediately after `---` close
  if file has no frontmatter -> place metadata comment as line 1
  use today's date in YYYY-MM-DD format
  use the model identifier you (the agent) are running on (e.g. `claude-haiku-4`, `claude-sonnet-4`, `gpt-4o-mini`)
  if model unknown -> use `unknown-model`

  purpose: traceability for downstream debugging · users can correlate failures to compression version + model
  !! never omit this header · downstream systems may rely on it to detect BT files

## input mode detection

[ALWAYS] determine input type before acting:
  file ref (@file or explicit path) -> single-file mode (replace in place)
  pasted text (no file ref)         -> new-file mode (infer filename, create new)
  directory                         -> directory mode (see below)

flag overrides:
  `-c` || `--chat` || equivalent intent ("in chat", "render here", "no file", "preview")
    -> chat mode: output to chat · no file created
  `-bu` || `--backup` || equivalent intent ("back it up", "keep the original")
    -> backup mode: copy original before replacing

## backup mode

[ON-TRIGGER] USER signals backup
  -> copy original to `[filename].bu.YYYYMMDD.[ext]` (e.g. `my-rule.bu.20260506.md`)
  !! abort if backup write fails · do not compress until backup confirmed
  -> then replace file in place
  -> tell USER (HP): "Backed up to [backup-path]. Saved compressed version to [original-path]."
  note: backup files match `*.bu.*` for gitignore

## chat mode override

[ON-TRIGGER] USER signals chat output
  -> compress as normal -> write BT output to chat instead of file
  note: explicit override of the "BT never in chat" rule

## new-file mode

[ON-TRIGGER] pasted text && no file reference
  -> compress -> infer filename from content purpose (e.g. `api-auth-rule.md`, `session-handoff.md`)
  -> write BT output to that new file
  -> tell USER (HP): "Created [filename]"
  if purpose ambiguous -> ask USER for filename before writing

## pre-flight check

[ALWAYS] before compressing: estimate tokens (chars / 4)
  < 25K TKN  -> proceed silently
  >= 25K TKN -> note USER: "this is a large file (~Xk tokens). recommend cheap model (Haiku · GPT-4o-mini)."
  >= 50K TKN -> warn USER: "this file is ~Xk tokens. est ~Y min on Haiku. proceed? · cancel?"

## token math (reference)

[REFERENCE] plain UTF-8 English:
  1 KB ~= 256 TKN (chars / 4 rule)
  50 KB ~= 12.5K TKN
  100 KB ~= 25K TKN
  400 KB ~= 100K TKN

[REFERENCE] measured timing (Haiku · May 2026):
  ~2 min per 50 KB · scales roughly linearly
  100 KB ~= 4 min · 200 KB ~= 8 min · 400 KB ~= 16 min
  Opus / Sonnet thinking models: 3-5x slower

## directory mode

[ON-TRIGGER] input is a directory

step D1: scan
  enumerate `.md` && `.mdc` files in dir
  per file: name · KB · est TKN
  flags: > 5K TKN = "significant" · > 10K TKN = "alert" · > 25K TKN = "enormous"
  totals: file count · total KB · total est TKN

step D2: report + offer choice
  show numbered file table with TKN counts && flags
  show totals
  note: "for batches > 25K tokens, switch to cheap model (Haiku · GPT-4o-mini) before running"
  ask USER (HP):
    1. backup all && convert (recommended for large batches)
    2. convert · no backup
    3. cancel
  for specific files: instruct USER to pass them via IDE @ syntax instead of directory

step D3: backup if chosen
  copy `<dir>` -> `<dir>_backup_<YYYYMMDD>/`
  !! abort if backup fails

step D4: convert
  per file in dir:
    apply single-file two-pass flow (below)
    log: [i/N] · before/after est TKN · savings %

step D5: summary (HP)
  converted · skipped · errors
  total TKN before -> total TKN after
  est TKN saved per future session (the real value prop)
  backup path (if backup was made)

## single-file two-pass flow

!! if USER specifies a target file (e.g. "compress X into Y" || "replace Y with compressed X"):
  read source only · !! never read target · target will be overwritten · prior content irrelevant

### pass A: inventory

scan source for:
  invariants ("never" || "always" || "must" || "required" || "critical")
  triggers ("when X" || "if Y" || "after Z")
  constraints (allowed values · forbidden values · exact numbers)
  cause chains (A leads to B · B causes C) -> use `->`
  data-flow chains (A becomes B · B transforms to C) -> use `|>`
  repeated identifiers (used >= 3x -> alias candidate)
  phase context (session-start · always · conditional · reference · handoff)

prioritize alias candidates by `(token_len - 1) × repeats` · long+repeated > short+repeated

### pass B: render

emit `@defs` at top:
  one-line form `@defs: a=x · b=y` for short docs (2-4 aliases)
  block form for > 4 aliases or longer docs
  section-scope `<section name="X"><defs>...</defs></section>` for docs > 4K TKN

if doc has >= 80% blocks sharing one phase -> declare `default-phase: TAG` at top
otherwise tag every block

write/rewrite body:
  apply ASCII operators (see symbol vocabulary below)
  apply compression patterns (see catalog below)
  XML structure for docs > 10 lines: `<context>` `<defs>` `<rules>` `<reference>`

### pass C: verify

check:
  no alias collisions (one key, one binding, one scope)
  no undefined aliases used in body
  all original constraints preserved · polarity intact (`!! never` did not become `ok`)
  no missed substitutions (every >= 3x identifier swapped for its alias)
  per tenet-1: any meaning lost? -> revert that part to prose

ambiguity audit (per tenet-5):
  for each `=` line: RHS is a value · NOT a descriptive phrase
  for each variable name: name + value answers "what does this number represent?"
    !! `PP_spawn = 90` (what kind of 90? frequency? duration? threshold?)
    ok `PP_spawn_interval = 90 FR` (clearly an interval in frames)
  for each timing phrase: spawn / interval / period / delay carry distinct meanings · don't conflate
    "every X" -> `_interval = X`
    "starts at X" / "first at X" -> `_first = X` || `_start = X`
    "for X duration" -> `_duration = X`
    "after X delay" -> `_delay = X`
  for each compressed line: can a different model interpret this two ways? if yes -> expand

## symbol vocabulary (operational subset · full table in SPEC.md §1)

logical (from common programming languages):
  &&  AND       ||  OR       !=  not-equal       =  equals/defined-as (see strict rule below)
  :   binding/labeling/type-of (universal · works for state · alias · type · value)
  ?   unknown / verify / ask-user (standalone)

[ALWAYS] strict `=` operator rule: after `=`, the right-hand side MUST be a value, not a description
  ok RHS: numeric (`= 90`) · typed value (`= 90 FR`) · aliased reference (`= CV.h * 0.5`) · literal (`= 'flappyBirdBest'`)
  !! RHS: descriptive phrases · adverbs · prose fragments
    !! `X = every 90FR`  (adverb "every" makes RHS a description)
    ok `X_interval = 90 FR`  (clean value · variable name carries the "every" meaning)
    !! `Y = first at 120`  (preposition "at" makes RHS a description)
    ok `Y_first = 120` || `Y_start_frame = 120`

flow:
  ->  causal arrow (X causes Y)
  <-  derived from / sourced from
  |>  functional pipe (X transforms into Y · distinct from causal `->`)

constraint:
  !!  forbidden / never / hard-stop (reads as emphasis · AIs infer "important + negative")
  ok  allowed / correct / approved
  ~~  warn / check-first (use as prefix only · markdown collision when wrapping)

cardinality (regex · use as suffix on identifier):
  flag?       optional
  arg+        one or more
  tag*        zero or more
  step{3}     exactly n
  retry{1,3}  between n and m

separator: `·`
comments: `//` (line) · `<!-- -->` (block) · !! avoid `#` (markdown heading collision)

## emoji decisions

[ALWAYS] rule: emoji earns its tokens IFF bundles 3+ words && no 1-token ASCII equivalent && universal LLM recognition

[REFERENCE] earns (reach freely): 🪤 💥 🔑 🧪 ⚓ 🔥 📊
[REFERENCE] loses (prefer ASCII · AIs reach by habit): ✅->ok · ❌->!! · ⚠️->~~ · 🚫->!! · 🐛->bug · 🚧->WIP

[ALWAYS] !! soft guidance · ~3 TKN per use · override deliberately when visual matters more than tokens

[ALWAYS] !! one symbol per meaning per file
  ok: mix DIFFERENT meanings (`->` && 🪤)
  !!: mix SAME meaning (`!!` && 🚫 · `ok` && ✅ · `->` && `→`)

## phase tags (full definitions in SPEC §3)

[NEW-CHAT]    session-init context · agent may skip once established
[ALWAYS]      every turn · no exceptions
[ON-TRIGGER]  conditional · attach the trigger condition explicitly
[UNLESS]      negative gate · applies every turn UNLESS condition holds
[REFERENCE]   look-up only · skip during normal load
[HANDOFF]     cross-session context · new agent reads first turn only

`default-phase: TAG` declaration: when 80%+ blocks share one phase, declare default and tag only exceptions

## compression patterns (catalog · examples in SPEC §4)

cause chains: prose "if A then B" -> `A -> B`
prohibition lists: prose "never X · never Y · never Z" -> `!! never: X · Y · Z`
state declarations: prose "X done · Y in progress · Z blocked" -> `state: X ok · Y ~~ in-progress · Z !! blocked`
decision trees: nested if/else prose -> indented `condition -> action` lines
guardrail bundles: one operator + compact list -> `!! never: a · b · c`
default/override chains: "default X · except Y" -> `default: X` then `on Y -> Z`
state snapshots: same as state declarations · for status reporting
polarity flip: broad rule + small exception list -> `default: deny` + `allow: ...` (or inverse) · huge for auth/permissions
range/threshold: numeric if/elif prose -> `X: <a -> .. · a-b -> .. · >=b -> ..`
pipe chains: data-flow prose -> `input |> step1 |> step2 |> output`
tabular condensation: 2+ axes with small cross-product -> ASCII table beats decision tree
empty-block elision: omit `<rules></rules>` · AI infers absence from missing tag
predicate hoisting: shared condition stated once · effects listed below

recurring events: prose "every X frames" || "X times per second" -> `[name]_interval = X` (NOT `[name] = every X`)
initial conditions: prose "first occurs at X" || "starts at X" -> `[name]_first = X` || `[name]_start = X`
durations: prose "lasts X ms" || "for X frames" -> `[name]_duration = X`
delays: prose "after X delay" || "X after Y" -> `[name]_delay = X`

## anti-patterns (do NOT compress this way)

[ALWAYS] these patterns LOOK compact but introduce one-shot reliability failures:

!! `X = every N`           -> use `X_interval = N`           (RHS must be value, not adverb)
!! `X = first at N`        -> use `X_first = N`              (RHS must be value, not preposition)
!! `X = N or Y`            -> use `X = N` line + `X_alt = Y` (RHS must be single value, not disjunction)
!! `X starts N`            -> use `X_start = N`              (verb-noun assignment must use `=`)
!! drop `_interval` || `_period` || `_count` || `_max` || `_threshold` suffixes when name alone leaves "what kind of value?" unanswered
!! merge "every X" || "starts at Y" into a single `=` line (these are TWO state variables, not one)
!! compress to fewer than 3 distinct identifiers per logical concept when concept has multiple state vars (e.g. interval + first + max requires 3 names, not 1)

[REFERENCE] why these break: cheaper/smaller models read `=` as literal assignment. when RHS is descriptive (adverb · preposition · verb phrase), they treat the whole line as ambient context rather than as an explicit named variable, then infer implementation from the description instead of the named state. larger models tolerate ambiguity better but all models prefer explicit form. write for the smallest reasonable model.

## conflicts and issues

[ALWAYS] role: surface conflicts to USER · !! never silently resolve them · !! never delete contradictory text to "clean up"
[ALWAYS] always continue compression unless logic is catastrophically broken (see severity tiers below)
[ALWAYS] preserve all conflicting statements verbatim · let USER decide what's correct

[ON-TRIGGER] during pass A inventory · scan for these issue classes:
  type contradiction      X declared as type A · used as type B elsewhere
  polarity contradiction  X required && forbidden · same scope · same conditions
  value contradiction     X = N1 in one place · X = N2 in another · no override rule
  undefined reference     alias / identifier used in body · never declared
  circular dependency     A defined as B · B defined as A
  logical impossibility   mutually exclusive conditions presented as compatible
  scope ambiguity         same identifier means different things in different sections · no scoping signal

severity tiers:
  minor       1-2 issues · narrow scope · non-blocking
                -> note in closing summary · proceed with compression
  moderate    3+ issues || one issue spans core domain
                -> note prominently in closing summary · proceed with compression
  catastrophic document logic is fundamentally inconsistent · cannot be compressed coherently
                -> STOP · ask USER (HP): "This document has [N] catastrophic logic issues that make compression unsafe. Top issues: [list 2-3]. Recommend resolving these before compression. Continue anyway?"
                if USER says continue -> compress as-is · flag every issue in closing

[ALWAYS] reporting in closing summary (HP · after compression succeeds):
  no issues:
    "Saved to [path]. ~X% reduction. No conflicts detected."
  issues found:
    "Saved to [path]. ~X% reduction.
     ⚠ Found [N] issue(s):
       - [section / line ref]: [brief description] (e.g. 'X declared as string in §A · used as number in §C')
       - [section / line ref]: [brief description]
     Recommend reviewing the original document. Re-run /botspeak after fixes if you change anything."

!! never:
  silently merge conflicting values
  pick one interpretation when two exist
  delete contradictory text
  stop mid-compression for minor issues (only stop for catastrophic per tiers above)

## output

file mode (default):
  write BT to file (replace in place for file refs · new file for pasted text)
  tell USER (HP): "Saved to [path]" · if `-bu`: "Backed up to [bu-path]. Saved to [path]."
  HP summary: "This document now says: [2-3 sentences]"
  TKN savings est: before vs after
  conflict report: see "conflicts and issues" section · format conflict count + brief items
  ask USER (HP): "Does this match what the original said? Run /botspeak-translate to verify."

chat mode (`-c` / `--chat`):
  write BT output to chat
  HP summary: "This document now says: [2-3 sentences]"
  TKN savings est: before vs after
  conflict report: see "conflicts and issues" section

## inviolable rules

[ALWAYS] user reads it -> HP · agent reads it -> BT
!! tenet-1 always wins: if compression changes meaning or strength of any constraint -> revert that constraint to its original form
