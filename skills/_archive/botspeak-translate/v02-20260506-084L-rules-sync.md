---
name: botspeak-translate
description: Translate a BOTSPEAK document into clear human prose with all @defs aliases expanded. Use when a human needs to audit or review a BOTSPEAK file (rules, skills, CLAUDE.md, memory pages, handoffs).
triggers: ["translate botspeak", "explain this botspeak", "/botspeak-translate", "what does this rule say in english"]
---

[ALWAYS] output = full sentences · professional tone · zero BOTSPEAK
[ALWAYS] every word the USER reads = full human prose

# input mode detection
determine input type before acting:
  A. file reference (@file or explicit path) -> translate and write to [filename].bst.md next to original
  B. pasted text (no file ref) -> translate and write to [inferred-name].bst.md (AI names from content purpose)
  + `-c` or `--chat` (or equivalent intent: "in chat", "render here", "no file", "preview", "just show me") -> chat mode: output prose to chat · no file created

# output file naming
translated files use the `.bst.md` double-extension convention:
  `rules/my-rule.md`      -> `rules/my-rule.bst.md`
  `CLAUDE.md`             -> `CLAUDE.bst.md`
  `README-FOR-AI.md`      -> `README-FOR-AI.bst.md`
  pasted text (no source) -> `[inferred-name].bst.md` (e.g., `api-auth-rule.bst.md`)
  ambiguous content       -> ask user for filename before writing

note: `.bst.md` files are derived artifacts. to exclude from version control: add `*.bst.md` to `.gitignore`.

# chat mode override (`-c` / `--chat`)
[ON-TRIGGER] USER signals chat output
  -> run translation as normal
  -> write prose output to chat · no file created

# reverse symbol map (ASCII dialect)
!!  -> "never" / "is forbidden" / "must not"
ok  -> "is allowed" / "the correct approach is"
->  -> "leads to" / "causes" / "which results in"
<-  -> "is derived from" / "is sourced from"
&&  -> "and"
||  -> "or" / "alternatively"
~~  -> "use caution" / "check first"
!=  -> "does not equal" / "differs from"
=   -> "is defined as" / "equals"
·   -> "and" / list separator

# reverse symbol map (emoji/unicode dialect)
🔴  -> "never" / "is forbidden" / "must not"
✅  -> "is allowed" / "the correct approach is"
⚠️  -> "use caution" / "check first"
↔   -> "syncs with" / "is bidirectional with"

# phase-tag expansion
[NEW-CHAT]    -> "At the start of each session:"
[ALWAYS]      -> "In every turn:"
[ON-TRIGGER]  -> "When [condition] is detected:"
[REFERENCE]   -> "For reference (lookup as needed, not on load):"
[HANDOFF]     -> "Context from the previous session:"

# alias resolution (CRITICAL — do not skip)
1. find @defs ... @end block · or section-scope <defs>
2. build alias->full-form table
3. EXPAND every alias to its full form in the prose output
   -> reader sees "establishment_id" not "E"
   -> reader sees "wine-report" not "WR"
4. note any alias that is undefined (BOTSPEAK doc bug; flag it)

# translation steps
1. read full BOTSPEAK doc · resolve aliases first
2. expand all symbol notation -> natural language phrases
3. expand all phase tags -> labeled section headers
4. write full prose: complete sentences, context, explanation
5. add "What this means in practice" paragraph for complex rules
6. flag ambiguities found during translation
7. do NOT add interpretation beyond what BOTSPEAK content states

# output format
## [Document Title]

**[Phase tag expanded as section header]**

[Full prose expansion of each block, with all aliases expanded inline]

**What this means in practice:**
[One paragraph: how should an agent — or person — actually behave given these rules?]

**Ambiguities or gaps noted:**
[Any points where the BOTSPEAK was unclear or could be interpreted multiple ways. Skip section if none.]
