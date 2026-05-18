---
name: botspeak
description: Compress an AI-facing document into BOTSPEAK — symbols, @defs aliases, phase tags. Use when rewriting rules, skills, CLAUDE.md, AGENTS.md, memory pages, or context handoffs where AI is the primary reader.
triggers: ["botspeak this", "compress to botspeak", "optimize for AI", "/botspeak", "shrink this for the bot"]
---

[ALWAYS] target = docs where AI = primary reader · human = secondary or never
apply-to: rules · skills · CLAUDE.md · AGENTS.md · wiki/memory pages · context handoffs

@defs
  ST = symbol-table (🔴 ✅ ⚠️ → · / ≠ =)
  PT = phase-tag ([NEW-CHAT] [ALWAYS] [ON-TRIGGER] [REFERENCE] [HANDOFF])
  AL = @defs alias block
@end

# core symbol contracts (two dialects -- pick per use)
ASCII (default, 1 tok each):  ->  =>  &&  ||  !=  =  !!  ok  ~~
Symbol (human-audited docs):  ->/→  &&/·  ||// !!/🔴 ok/✅ ~~/⚠️
choose ASCII when doc loaded every session && agent is only reader
choose Symbol when humans audit regularly && visual landmarks help

# phase tags (assign one to every content block)
[NEW-CHAT]    critical at session-start; skip mid-session
[ALWAYS]      every turn
[ON-TRIGGER]  only when condition fires
[REFERENCE]   look-up only; skip during load
[HANDOFF]     cross-session; new-agent first-turn only

# the killer feature: aliases
@defs block at top of doc -> bind short forms to repeated identifiers
  count repeated multi-token terms -> if any term used >=3 times -> make it an alias
  use mnemonic letters (E for establishment, S for settings) not arbitrary (A, B, C)
  <=15 aliases per @defs block, keep block in first 200 tokens
  reliable up to ~2K body tokens, drift starts ~4K
  long docs (>4K): re-declare @defs at top of each major section, or use <defs> inside <section>

# compression order (apply in sequence)
1. read full doc → identify: invariants · triggers · constraints · allowed · forbidden · repeated terms
2. count repeated multi-token terms · build @defs block for terms used ≥3×
3. assign PT to each content block
4. compress prose → symbol+fragment notation:
     drop articles · filler verbs · hedging · transitional phrases · throat-clearing
     keep all behavioral constraints · invariants · cause chains · exact values
5. for long docs (>10 lines): wrap sections in XML tags
     <context> <defs> <rules> <reference>
6. verify: every constraint preserved · nothing invented · no behavioral meaning lost
7. measure: original token count → compressed token count → % reduction
8. output compressed doc + summary line

# compression patterns (highest savings first)
prose-paragraph → cause-chain (A → B → C)
prohibition-list → 🔴 NEVER X · Y · Z (inline with ·)
allowed-list    → ✅ allowed: X · Y · Z
state-listing   → state: thing-1 ✅ · thing-2 ⚠️ pending · thing-3 🔴 broken
nested-bullets  → inline with · or →

# frontmatter is sacred (never compress)
YAML frontmatter (name, description, triggers, globs, alwaysApply, tools, model) is how host tools route
description stays plain prose with "Use when..." idiom -- compressed description = skill never fires
BOTSPEAK compresses the markdown BODY only, never the YAML

# the inviolable rule
[ALWAYS] any content the USER will read (questions, choices, warnings, errors) -> full human prose -> no BOTSPEAK -> in user's language

# reference
SPEC.md = full grammar, examples/ = before-after pairs across 5 doc types
