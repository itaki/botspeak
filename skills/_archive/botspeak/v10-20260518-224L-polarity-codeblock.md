---
name: botspeak
description: Compress an existing AI-facing document (rule, skill, CLAUDE.md, memory page, handoff) — or an entire directory of them — into BOTSPEAK notation. Use when the user says "botspeak this", "compress this rule", "make this shorter for the bot", or invokes /botspeak.
triggers: ["botspeak this", "compress this", "make this shorter for the bot", "/botspeak", "convert to botspeak", "optimize this for tokens"]
---
<!-- botspeak-version: 2.2.0 · published: 2026-05-18 · repo: https://github.com/itaki/botspeak -->

[ALWAYS] role = compressor · input = verbose AI-facing doc · output = semantically identical BOTSPEAK doc
[ALWAYS] every word the USER reads (classification, questions, summary) = full human prose · zero BOTSPEAK
[ALWAYS] one-shot reliability > brevity · if a phrase could be read two ways -> expand it
!! never compress: YAML frontmatter · description fields · trigger phrases · code blocks · URLs · file paths

# step 0: detect input mode + pre-flight

input type:
  file ref (@file or path)  -> single-file mode (replace in place)
  pasted text               -> new-file mode (infer filename · create new file)
  directory                 -> directory mode (see "directory mode" below)

flag overrides (catch in user phrasing):
  `-c` || `--chat` || "in chat" || "preview"   -> chat mode: output to chat · no file written
  `-bu` || `--backup` || "back it up"          -> backup mode: copy original before replacing

pre-flight (file & directory modes):
  estimate tokens = chars / 4
  >= 25K TKN -> note USER (prose): "Large file (~Xk tokens). Recommend running on a cheap model (Haiku, GPT-4o-mini)."
  >= 50K TKN -> warn USER (prose) and ask to confirm before continuing.

!! if USER specifies a target file ("compress X into Y" || "replace Y with compressed X"):
  read source only · never read target · target will be overwritten · prior content irrelevant

# step 1: inventory the doc

scan source for:
  invariants ("never", "always", "must", "required", "critical")
  triggers ("when X", "if Y", "after Z")
  constraints (allowed values, forbidden values, exact numbers)
  cause chains (A leads to B, B causes C) -> use `->`
  data-flow chains (A becomes B, B transforms to C) -> use `|>`
  repeated identifiers (used >=3 times -> alias candidates)
  phase context (session-start vs always-active vs reference vs handoff)
  conflicts (see "conflicts and issues" below)

prioritize alias candidates by `(token_len - 1) × repeats` · long-and-repeated > short-and-repeated

# step 2: build @defs

for each identifier used >=3 times:
  pick mnemonic abbreviation (E for establishment_id · MV for materialized-view · WR for wine-report)
  add to @defs block at top of output
  replace every occurrence with the short form

doc > 4K TKN -> use section-scope `<defs>` per section instead of one doc-scope @defs (see SPEC §2)
doc > 10 lines && has clear sections -> wrap in XML structure: `<context>` `<defs>` `<rules>` `<reference>`

# step 3: tag every block

every content block gets a phase tag:
  [NEW-CHAT]    session-init context · agent may skip once established
  [ALWAYS]      every turn · no exceptions
  [ON-TRIGGER]  conditional · attach the trigger condition explicitly
  [UNLESS]      negative gate · applies every turn UNLESS the condition holds
  [REFERENCE]   look-up only · skip during normal load
  [HANDOFF]     cross-session context · new agent reads first turn only

if 80%+ of blocks share one phase -> declare `default-phase: TAG` at top · tag only the exceptions

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
  every distinct timing concept — interval, first, duration, delay are SEPARATE variables, not one
  per-entity mutable state vs ambient/offset state — label and form MUST differ (see entity-state rule below)
  all fenced code blocks (``` or ~~~) — verbatim, no exceptions (Mermaid · YAML · code samples · config snippets stay byte-for-byte)

## entity-state vs ambient/offset rule

[ALWAYS] when a spec contains objects with independent per-instance position (enemies · bullets · particles · pipes):
  use the three-part form:
    obj.x_init     = <spawn position>
    obj.x:         -= <speed> each FR   (per-instance mutation — NOT an offset)
    obj.remove-when: obj.x + obj.w < 0
  label: `← entity: per-instance x`

[ALWAYS] when a spec contains ambient/parallax effects (scrolling backgrounds · parallax layers):
  use the offset form:
    layer_offset: += <speed> each FR
    render: draw at (base_x - layer_offset % canvas_w)
  label: `← ambient: single offset`

!! use same motion language for both entity and ambient objects (build models will apply ambient pattern to all)
!! compress entity motion to "moves left" or "scrolls" without the three-part form

## strict `=` operator rule (one-shot reliability fence)

[ALWAYS] after `=`, the right-hand side MUST be a value, not a description.

  ok RHS:  numeric (`= 90`) · typed value (`= 90 FR`) · aliased reference (`= CV.h * 0.5`) · literal (`= 'flappyBirdBest'`)
  !! RHS:  adverbs ("every"), prepositions ("at"), verbs ("starts"), or any descriptive phrase

  !! `X = every 90 FR`        ok `X_interval = 90 FR`        (variable name carries the "every")
  !! `Y = first at 120`       ok `Y_first = 120`             (variable name carries the "first at")
  !! `Z starts 0`             ok `Z_start = 0`               (verb-noun assignment must use `=`)

if a name + value cannot answer "what does this number represent?" -> rename:
  !! `PP_spawn = 90`               (frequency? duration? threshold?)
  ok `PP_spawn_interval = 90 FR`   (clearly an interval in frames)

# step 5: choose dialect

ASCII (default · 1 token per symbol guaranteed):
  ->   leads-to     !!   never/forbidden    ok   allowed
  &&   AND          ||   OR                ~~   warn/check-first
  !=   not-equal    =    defined-as        |>   data-flow / pipe

emoji/symbol (only when bundled meaning >= 3 words and no 1-token ASCII equivalent):
  see SPEC §1 emoji decisions — emojis cost 3-15 tokens each · ASCII is almost always cheaper

!! do NOT mix dialects within a single file (one symbol per meaning per file — pick `->` or `→`, not both)

# step 6: verify (pass C)

  no alias collisions (one key, one binding, one scope)
  no undefined aliases used in body
  all original constraints preserved · polarity intact (`!! never` did not become `ok`)
  every >=3x identifier swapped for its alias
  every `=` line: RHS is a value, not a description (per strict rule above)
  per-entity objects: three-part form present (x_init · per-FR mutation · remove-when)
  ambient objects: offset form · no per-instance x
  @defs hygiene: every alias defined in @defs appears in body · every alias used in body is defined in @defs · !! no alias for concept absent from source
  !! polarity check: for every `!!` in output, confirm the source statement is an actual prohibition — NOT an opt-out ("to disable X, do Y"), NOT a conditional ("only do X if Y"), NOT a recommended alternative ("prefer X over Z"). Decision test: substitute the literal word "forbidden" for `!!` — if the result is false, the `!!` is wrong; use [ON-TRIGGER] / default-fallback / inline note instead.
  code-block parity: count fenced blocks (``` or ~~~) in source · count in output · counts MUST match · if mismatch -> embed missing blocks verbatim before continuing · !! never summarize or paraphrase a code block
  any meaning lost? -> revert that part to prose
  can a different model read this two ways? -> expand

# step 7: present + write

every BT output MUST begin with a metadata header:
  format: `<!-- BOTSPEAK v2.2.0 · compressed by [model] · YYYY-MM-DD -->`
  YAML frontmatter present -> place immediately after the `---` close
  no frontmatter           -> place as line 1
  use today's date and the agent's own model slug (e.g. `claude-haiku-4`, `gpt-4o-mini`); if unknown -> `unknown-model`
  !! never omit · downstream systems detect BT files by this header

file mode (default):
  write BT to the file (replace in place for file refs · new file for pasted text)
  tell USER (prose): "Saved to [path]." · if `-bu`: "Backed up to [bu-path]. Saved to [path]."
  prose summary: "This document now says: [2-3 sentences]"
  token savings estimate: word count before vs after
  conflict report (if any) — see "conflicts and issues" below
  ask USER (prose): "Does this match what the original said? Run /botspeak-translate to verify."

chat mode (`-c` / `--chat`):
  write BT to chat · same prose summary + token savings + conflict report + verify-prompt

# operational modes

## new-file mode (pasted text, no file reference)

  compress -> infer filename from content purpose (e.g. `api-auth-rule.md`, `session-handoff.md`)
  write BT to that new file · tell USER (prose): "Created [filename]."
  filename ambiguous -> ask USER for one before writing

## backup mode (`-bu` / `--backup`)

  copy original to `[filename].bu.YYYYMMDD.[ext]` (e.g. `my-rule.bu.20260506.md`)
  !! abort if backup write fails · do not compress until backup confirmed
  then replace file in place
  note: backup files match `*.bu.*` for gitignore

## directory mode

  D1. scan: enumerate `.md` && `.mdc` files · per file: name · KB · est TKN · flag (>5K = significant, >10K = alert, >25K = enormous) · totals
  D2. report + ask USER (prose): backup-and-convert (recommended) · convert-no-backup · cancel
  D3. if backup chosen: copy `<dir>` -> `<dir>_backup_<YYYYMMDD>/` · !! abort if backup fails
  D4. per file: apply step 1-7 flow · log `[i/N] · before/after est TKN · savings %`
  D5. summary (prose): converted · skipped · errors · total TKN before/after · est TKN saved per future session · backup path

  note: for individual files inside a directory, instruct USER to pass them via IDE @ syntax instead of using directory mode

# conflicts and issues

[ALWAYS] role: surface conflicts to USER · !! never silently resolve · !! never delete contradictory text to "clean up"
[ALWAYS] preserve all conflicting statements verbatim · USER decides what's correct
[ALWAYS] always continue compression unless logic is catastrophically broken (see severity below)

scan in step 1 for:
  type contradiction      X declared as type A · used as type B elsewhere
  polarity contradiction  X required && forbidden · same scope · same conditions
  value contradiction     X = N1 in one place · X = N2 in another · no override rule
  undefined reference     alias / identifier used in body · never declared
  circular dependency     A defined as B · B defined as A
  logical impossibility   mutually exclusive conditions presented as compatible
  scope ambiguity         same identifier means different things in different sections · no scoping signal

severity:
  minor         1-2 issues · narrow scope · non-blocking
                  -> note in closing summary · proceed with compression
  moderate      3+ issues || one issue spans core domain
                  -> note prominently in closing summary · proceed with compression
  catastrophic  document logic is fundamentally inconsistent · cannot be compressed coherently
                  -> STOP · ask USER (prose): "This document has [N] catastrophic logic issues that make compression unsafe. Top issues: [list 2-3]. Recommend resolving these before compression. Continue anyway?"
                  if USER says continue -> compress as-is · flag every issue in closing report

closing report (prose, after compression):
  no issues:    "Saved to [path]. ~X% reduction. No conflicts detected."
  with issues:  "Saved to [path]. ~X% reduction. Found [N] issue(s): [list 2-3 with section / line refs]. Recommend reviewing the original. Re-run /botspeak after fixes."

!! never: silently merge conflicting values · pick one interpretation when two exist · delete contradictory text · stop mid-compression for minor issues

# the inviolable rules

[ALWAYS] user reads it -> human prose · agent reads it -> BOTSPEAK
!! if compression changes the meaning or strength of any constraint -> revert that constraint to its original form
