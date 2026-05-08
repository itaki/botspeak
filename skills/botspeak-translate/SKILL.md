---
name: botspeak-translate
description: Translate a BOTSPEAK document into clear human prose with all @defs aliases expanded. Use when a human needs to audit or review a BOTSPEAK file (rules, skills, CLAUDE.md, memory pages, handoffs).
triggers: ["translate botspeak", "explain this botspeak", "/botspeak-translate", "what does this rule say in english"]
---

@defs
  BT  = BOTSPEAK
  HP  = human prose
@end

## role and inviolable rules

[ALWAYS] role: translator (BT -> HP) · output is for human audit
[ALWAYS] output: full sentences · professional tone · zero BT in output · in user's language
[ALWAYS] every word USER reads = HP

## why this skill exists

[REFERENCE] this skill is !! required for translation · any modern LLM renders BT -> HP unaided
[REFERENCE] purpose: fidelity · 1:1 decompression contract · faithful expansion · != paraphrase

## input mode detection

[ALWAYS] determine input type before acting:
  file ref (@file or path) -> translate · write to `[filename].bst.md` next to original
  pasted text (no file ref) -> translate · write to `[inferred-name].bst.md` (infer from content purpose)

flag override:
  `-c` || `--chat` || equivalent intent ("in chat", "render here", "no file", "preview", "just show me")
    -> chat mode: output prose to chat · no file created

## output file naming

`.bst.md` double-extension convention:
  `rules/my-rule.md`      -> `rules/my-rule.bst.md`
  `CLAUDE.md`             -> `CLAUDE.bst.md`
  `README-FOR-AI.md`      -> `README-FOR-AI.bst.md`
  pasted text (no source) -> `[inferred-name].bst.md` (e.g. `api-auth-rule.bst.md`)
  ambiguous content       -> ask USER for filename before writing

note: `.bst.md` files are derived artifacts · exclude from version control via `*.bst.md` in `.gitignore`

## chat mode override

[ON-TRIGGER] USER signals chat output
  -> run translation as normal
  -> write prose output to chat · no file created

## reverse symbol map (operators -> HP)

logical:
  &&  -> "and"
  ||  -> "or" / "alternatively"
  !=  -> "does not equal" / "differs from"
  =   -> "is defined as" / "equals"
  :   -> "is" / "labeled as" / "of type" (context-dependent)
  ?   -> "unknown" / "verify" / "ask the user" (when standalone)

flow:
  ->  -> "leads to" / "causes" / "which results in" (causal)
  <-  -> "is derived from" / "is sourced from"
  |>  -> "is transformed into" / "flows into" / "feeds" (data pipeline)

constraint:
  !!  -> "never" / "is forbidden" / "must not"
  ok  -> "is allowed" / "the correct approach is" / "is approved"
  ~~  -> "use caution" / "check first" / "is conditional"

cardinality (regex suffix):
  flag?       -> "optional flag"
  arg+        -> "one or more args"
  tag*        -> "zero or more tags"
  step{3}     -> "exactly three steps"
  retry{1,3}  -> "between one and three retries"

separator: `·` -> "and" / list separator (drop in prose, use commas)
comments: `//` and `<!-- -->` -> drop entirely (comments are author notes, not content)

emoji (when present · expand any recognized emoji to its meaning):
  🪤 -> "subtle trap / gotcha / looks fine but fails later"
  💥 -> "breaking change / downstream consumers will break"
  🔑 -> "secret / credential / do not log / do not commit"
  🧪 -> "experimental / unstable / may change or disappear"
  ⚓ -> "pinned / do not upgrade / locked to exact version"
  🔥 -> "incident priority / production emergency"
  📊 -> "chart / graph / visualization of"
  ✅ -> "approved" / "verified" / "passed"
  ❌ -> "forbidden" / "not allowed"
  ⚠️  -> "warning" / "use caution"
  🚫 -> "strictly forbidden"
  🔒 -> "locked" / "immutable" / "read-only"
  ⏰ -> "time-sensitive" / "scheduled"
  🔁 -> "retry" / "loop" / "repeat"

note: BT files may use ASCII operators or emoji for the same concept · expand both to the same prose · ASCII `!!` and 🚫 both render as "must not" / "forbidden"

## phase-tag expansion

[NEW-CHAT]    -> "At the start of each session:"
[ALWAYS]      -> "In every turn:"
[ON-TRIGGER]  -> "When [condition] is detected:"
[UNLESS]      -> "In every turn UNLESS [condition] holds:"
[REFERENCE]   -> "For reference (look up as needed, not on every load):"
[HANDOFF]     -> "Context from the previous session:"

`default-phase: TAG` directive -> "Unless tagged otherwise, every block in this document applies under [expanded-tag]:"

## alias resolution (CRITICAL · do not skip)

1. find `@defs ... @end` block · or one-line `@defs:` form · or section-scope `<defs>`
2. build alias -> full-form table
3. EXPAND every alias to its full form in prose output
   -> reader sees "establishment_id", not "E"
   -> reader sees "wine-report", not "WR"
4. note any alias that is undefined or used outside its scope (BT doc bug · flag it)

## translation steps

1. read full BT doc · resolve aliases first
2. expand all symbol notation -> natural-language phrases
3. expand all phase tags -> labeled section headers
4. write full prose: complete sentences · context · explanation
5. add "What this means in practice" paragraph for complex rules
6. flag ambiguities found during translation
7. !! do NOT add interpretation beyond what the BT content states (tenet-1 mirror: faithful expansion · no invention)

## output format (HP)

```markdown
## [Document Title]

**[Phase tag expanded as section header]**

[Full prose expansion of each block, with all aliases expanded inline.]

**What this means in practice:**
[One paragraph describing how an agent — or person — should behave given these rules.]

**Ambiguities or gaps noted:**
[Any points where the BOTSPEAK was unclear or could be interpreted multiple ways. Omit this section if none found.]
```

## completion message

[ALWAYS] when translation completes · tell user (in HP):
  "I've expanded all aliases, symbols, and phase tags to full prose. The result is more exhaustive than the original BOTSPEAK — every abbreviation spelled out, every constraint stated explicitly, every connection made clear. This verbosity proves that nothing was lost in the compression; it just got restructured. Compare it to the original BOTSPEAK to see exactly how the compression works."
