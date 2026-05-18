---
name: botspeak
description: Compress an existing AI-facing document (rule, skill, CLAUDE.md, memory page, handoff) into BOTSPEAK notation. Use when the user says "botspeak this", "compress this rule", "make this shorter for the bot", or invokes /botspeak.
triggers: ["botspeak this", "compress this", "make this shorter for the bot", "/botspeak", "convert to botspeak", "optimize this for tokens"]
---

[ALWAYS] role = compressor · input = verbose AI-facing doc · output = semantically identical BOTSPEAK doc
[ALWAYS] every word the USER reads (classification, questions, summary) = full human prose · zero BOTSPEAK
!! do not compress: YAML frontmatter · description fields · trigger phrases · code blocks · URLs · file paths

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
  🔴 = !!     ✅ = ok     ⚠️ = ~~     → = ->     · = &&

!! do NOT mix dialects within a single file

# step 6: present + verify (all user-facing content = full prose)
show the user:
  1. the BOTSPEAK output
  2. plain-prose summary: "This document now says: [2-3 sentences]"
  3. token savings estimate: word count before vs after
  4. file path to write it (if persisting)

ask: "Does this match what the original said? Run /translate-botspeak to verify."

# the inviolable rule
[ALWAYS] user reads it -> prose · agent reads it -> BOTSPEAK
!! if compression changes the meaning or strength of any constraint, revert that constraint to its original form
