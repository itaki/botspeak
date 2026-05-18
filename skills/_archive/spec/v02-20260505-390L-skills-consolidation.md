# BOTSPEAK SPEC v1

[REFERENCE] load when writing/auditing BOTSPEAK · skip on routine session load
the language for AI-to-AI documents · designed to be parsed by LLMs, not enjoyed by humans

---

## 1. Symbol Vocabulary

defined here once · applied everywhere · no re-explanation in document body

### Primary (ASCII) — recommended default

```
->   causes / leads-to / therefore / results-in
=>   strong implication / triggers / fires
<-   derived-from / sourced-from
&&   AND  (inline; precise binary)
||   OR   (alternatives)
!=   not-equal / does-not-match
=    equals / defined-as
:    type-of / labeled-as
?    unknown / verify / ask-user
!!   block / never / forbidden / hard-stop
ok   allowed / correct / proceed / approved
~~   warn / check-first / conditional
@    addresses / at-location
```

**Why ASCII:** every modern BPE tokenizer (`tiktoken`/o200k, `cl100k`, Llama BPE, Gemini SentencePiece) merges these into **1 token guaranteed** because the code corpus they were trained on saturates these merges. There is no Unicode equivalent that beats this baseline.

### Optional (Symbol) — for human-audited docs

```
🔴 = !!     ✅ = ok      ⚠️ = ~~
→  = ->     ⇒  = =>      ←  = <-
·  = &&     /  = ||      ≠  = !=
```

**Use when:** the doc will be read by humans regularly and visual scanning matters more than the 1-2 extra tokens per symbol. Emojis cost 3-15 tokens depending on the tokenizer (more in older ones, more for compound emoji like ⚠️ which encodes as two codepoints joined). Unicode arrows (`→`) cost 2-3 tokens.

**Use ASCII when:** the doc is loaded every session and the agent is the only reader. The savings compound across hundreds of sessions.

### Cost reference (o200k_base, GPT/Claude family)

| Symbol form | Token cost | Replaces |
|---|---|---|
| `->` | 1 | "leads to", "causes" (1-2 tokens) |
| `→` | 2-3 | same |
| `&&` | 1 | "and" (1) |
| `·` | 2 | "and" (1) — **net loss** |
| `!!` | 1 | "never" (1) |
| `🔴` | 3-4 | "never" (1) — **net loss in raw count, gain in attention salience** |

Honest assessment: emojis don't win on raw token count, but they win on attention salience for both humans and LLMs. If your doc is short and read often, prefer ASCII. If your doc benefits from visual landmarks for human audit, emojis pay for themselves.

---

## 2. Aliases (`@defs`) — the killer feature

**Define once at the top. Use the short form everywhere after.** Repeated identifiers are the largest single source of token waste in real CLAUDE.md and rule files.

### Document-scope (most common)

```
@defs
  E   = establishment_id
  S   = establishment.settings.toast_config
  WR  = wine-report
  CSR = customer-satisfaction-report
  MV  = materialized-view
@end

[ALWAYS] all queries → filter by E
[ALWAYS] WR + CSR generation → reads S.account_id · S.sftp_base_path
[ON-TRIGGER] MV stale → refresh-concurrently · log to obs_mv_refresh
🔴 never hardcode E · S · any per-establishment value
```

Without aliases, that block is ~80 tokens of repeated `establishment_id`, `settings.toast_config`, `wine-report`, `customer-satisfaction-report`. With aliases: ~40 tokens. **50% off, zero loss.**

### Section-scope (long docs, narrow concept)

```
<section name="payments">
@defs
  TX = stripe-transaction
  RC = refund-claim
@end
TX → webhooks/stripe.ts handles · RC → workers/refund.ts processes
</section>
```

Section-scope `@defs` only bind inside their `<section>` wrapper. Use when concept is local.

### Inline first-use binding (single-use docs)

```
[X:wine-report] first reference establishes X = wine-report
later: X due daily 06:00 → upload to S3
```

Use only when alias appears 3+ times in a short doc and a `@defs` block feels heavy.

### Alias naming conventions

```
✅ mnemonic letters: E (establishment) · S (settings) · MV (materialized-view)
✅ short upper:      WR · CSR · RBAC · API
🔴 arbitrary:        A · B · C (no semantic anchor → LLM more likely to lose binding)
🔴 collisions:       reusing E for "establishment" then "error" in same doc
🔴 too clever:       Σ · Ω · Π (Unicode that tokenizes badly)
```

### Reliability bounds (grounded in 2025 long-context benchmarks)

LLMs reliably resolve `@defs` aliases via **literal-key recall** (the use site contains the exact alias key — which is BOTSPEAK's design):
- **<2K tokens of body**: near-perfect resolution
- **2K-4K tokens**: still reliable; alias keys remain in attention
- **4K-8K tokens**: drift begins; **re-declare `@defs` at the top of each major section**
- **>8K tokens**: section-scope `<defs>` blocks are mandatory; document-scope unsafe

**Other rules:**
- Block in **first 200 tokens** of document (or section)
- **≤15 aliases** per `@defs` block (more = collisions, harder to scan)
- **Mnemonic** keys: `E` for establishment, `WR` for wine-report — never `A`/`B`/`C`
- **No alias collisions** within scope: don't use `E` for both "establishment" and "error"

This is grounded in NoLiMa (2025) and binding-ID research showing literal recall stays strong well past where associative recall fails.

---

## 3. Phase Tags

every content block gets a tag · agents use tags to skip irrelevant context

```
[NEW-CHAT]    load at session start · agent may skip after context established
[ALWAYS]      every turn · no exceptions
[ON-TRIGGER]  condition-gated · read only when pattern fires
[REFERENCE]   look-up only · skip during normal session load
[HANDOFF]     cross-session context · new-agent reads first-turn only
```

A 1500-token rule file fully tagged lets agents process maybe 600 tokens on turn 5 (skipping `[NEW-CHAT]` and `[REFERENCE]` blocks). Compounds across every session.

---

## 4. Grammar Rules

### Drop ruthlessly

```
articles:         a · an · the
filler verbs:     is · are · has · have (when replaceable by = or :)
throat-clearing:  "Please note that" · "It is important to" · "In order to ensure"
hedging:          "typically" · "generally" · "usually" (unless precision-critical)
transitional:     "Additionally," · "Furthermore," · "As mentioned"
passive voice:    "it should be noted" → just state the thing
restated obvious: "as I mentioned above" · "to recap"
```

### Keep absolutely

```
technical terms · identifiers · file paths · exact values
all behavioral constraints (🔴 and ✅)
all invariants (🔴 INVARIANT: ...)
cause-chains (A → B → C)
exact numbers · thresholds · limits
```

### Compression patterns

**Cause chains** (highest savings, most common)
```
❌ "If the user's request does not belong to the current branch, that
    represents a scope separation concern and should be treated as such,
    and the agent should stop before proceeding."
✅ request ≠ branch → scope-split → stop
```

**Prohibition lists**
```
❌ "Never hard-code establishment IDs. Do not hard-code establishment names.
    Avoid hard-coding SFTP folder paths. Do not use Toast account IDs."
✅ 🔴 NEVER hardcode: E · name · SFTP-path · Toast-account-id
```

**State declarations**
```
❌ "The migration system is mostly complete. We've implemented the core
    migration engine that reads from the source database and writes..."
✅ state: migration-engine ✅ · field-mapping ✅ · rollback-test ⚠️ pending
```

**Decision trees**
```
❌ Three paragraphs of nested conditionals
✅ stale-in-setState → use functional-form
   stale-in-listener + need-stable-cb → ref pattern
   stale-in-effect + ok-to-rerun → add to dep-array
```

---

## 5. Document Structure

### Short doc (≤10 lines)

```
[phase-tag] title
@defs (if 3+ repeated terms)
  E = establishment_id
@end

invariant or main constraint on first line
details as cause-chains or ✅/🔴 blocks
triggers: condition-that-fires-this
```

### Long doc (>10 lines, multiple concerns)

Wrap sections in XML tags. Claude parses XML semantic boundaries more reliably than markdown headings in long context. Tags add ~6 tokens per section but prevent attention bleed.

```xml
<context>
  project: DishData · phase: build · not: ops
  branch-policy: one-tree = one-feature
</context>

<defs>
  E   = establishment_id
  S   = establishment.settings.toast_config
  MV  = materialized-view
</defs>

<rules>
  [ALWAYS] 🔴 INVARIANT: BUILD system / DO NOT do-the-work
  [ALWAYS] all queries → filter by E (no exceptions)
  [ON-TRIGGER] request ≠ branch → stop → A/B/C choice
</rules>

<reference>
  [REFERENCE] db-schema: src/schema.sql
  [REFERENCE] field-mapping: src/migrate/mapping.py
  [REFERENCE] MV refresh policy: docs/mv-refresh.md
</reference>
```

### Context handoff (session → session)

```
[HANDOFF] project · branch · date

@defs (if multi-concept handoff)
  TX = stripe-transaction
@end

done: item ✅ · item ✅ · item ✅
bugs (fix first): 🔴 description → root-cause · 🔴 description → root-cause
todo: step1 → step2 → step3
[ALWAYS] invariant-reminder
```

### Memory/wiki page (Karpathy LLM-wiki pattern)

```
---
topic: [slug]
tags: [tag1, tag2]
updated: [date]
source: [origin]
summary: [one-line for index scans]
---

[brief] one-line summary the index uses to avoid opening this page

@defs (if domain-specific terms)
  X = domain-term
@end

key: value
key: A → B → C (cause chain)
🔴 anti-pattern: description · why-it-fails
✅ pattern: description · when-to-use
ref: [[linked-topic]]
```

---

## 6. Versioning

include version stamp when symbol contracts may differ across projects

```
# BOTSPEAK v1
@defs
  E = establishment_id
@end
```

agents reading a versioned doc know which contract applies.

---

## 7. Frontmatter Is Sacred — Never Compress It

YAML frontmatter is how host tools (Claude Code, Cursor, Codex, Gemini CLI, Copilot, ~25 others via the agentskills.io spec) **discover and route** your file. If you compress the wrong field, the host can't find or trigger your skill.

**Never BOTSPEAK-ify these fields:**

```yaml
---
name: my-skill                    # routing key — must match expected pattern
description: Use when ...         # trigger pattern — must be plain prose
triggers: ["..."]                 # invocation phrases — match against user input
globs: "*.ts,*.tsx"               # file matching — must be standard glob syntax
alwaysApply: true                 # boolean — host parses literal `true`/`false`
tools: [Read, Write, Bash]        # tool whitelist — exact name match required
model: claude-opus-4-7            # model slug — exact match required
---
```

**Specifically `description`:** keep as plain prose with the "Use when..." idiom. Anthropic explicitly recommends slightly "pushy" descriptions because Claude under-triggers skills. A compressed description is a skill that never fires.

**Recommended frontmatter limits** (ecosystem norms):
- `description`: ~200 chars max
- Total frontmatter: ~10 lines
- Body: <500 words / ~50 lines (move long reference material to `references/*.md`)

BOTSPEAK compresses the **markdown body**, not the YAML.

---

## 8. What BOTSPEAK Is Not

```
!! not a compression tool — write natively, no CLI required
!! not Caveman — Caveman = output to humans, BOTSPEAK = AI-to-AI internal docs
!! not for human-facing content — questions, choices, errors -> full prose, no BOTSPEAK
!! not a hard requirement — works alongside prose; mix freely; agents parse both
!! not the frontmatter — frontmatter stays as plain YAML for host-tool discovery
```

---

## 9. Pitfalls — what to watch for

### Common mistakes when writing BOTSPEAK

**1. Inventing meaning the original didn't have**
The compressor's job is preservation, not improvement. If the prose says "consider doing X", BOTSPEAK should say `consider X`, not `must X`. Run `/botspeak-translate` after compressing to verify nothing strengthened or weakened.

**2. Compressing the YAML frontmatter**
Frontmatter is routing metadata. `description: Use when...` must stay as plain prose with the "Use when" idiom or your skill won't fire. BOTSPEAK applies to the markdown body only.

**3. Aliases that aren't mnemonic**
`A = wine-report`, `B = customer-satisfaction-report`, `C = establishment_id` — these will drift. The LLM's literal-recall is reliable but it helps to have semantic anchoring. Use `WR`, `CSR`, `E`.

**4. Mixing dialects within one file**
Pick ASCII (`->`, `&&`, `!!`) or Symbol (`→`, `·`, `🔴`) for a given file. Mixing makes the file harder to scan for both humans and LLMs. The botspeak skill should pick one based on user preference and stick to it.

**5. Phase-tagging inconsistently**
If you tag *some* blocks with `[ALWAYS]` and leave others untagged, the agent has to infer phase for the untagged blocks. Either tag every content block or none. Half-tagged is worst.

**6. Aliases defined far from use**
A `@defs` block in the middle of a 5K-token doc with uses 4K tokens later will drift. Either keep `@defs` in the first 200 tokens of the document, or use section-scope `<defs>` inside the relevant section.

**7. Ambiguous abbreviations**
`MV = materialized-view` and later in same doc `MV = minimum-viable` — collision. The LLM will pick one, often wrong. One scope, one binding, no collisions.

**8. Forgetting humans exist**
Anything the user reads from the agent (questions, error messages, status updates, explanations) must be full prose in the user's language. BOTSPEAK is for AI-to-AI documents only. If you BOTSPEAK at the user, they will hate you.

### How to debug a BOTSPEAK file that "isn't working"

1. **Run `/botspeak-translate` on it.** Compare the output to what you intended. Drift means the BOTSPEAK is wrong, not the agent.
2. **Check `@defs` proximity.** If the file is long and aliases are at the top, move them or duplicate them per section.
3. **Check phase-tag accuracy.** A `[REFERENCE]` block the agent needs every turn won't fire. A `[ALWAYS]` block that's actually situational wastes tokens.
4. **Check description prose.** If your skill isn't triggering, the description is too terse. Add "Use when..." with concrete invocation examples.
5. **Check for collisions.** Grep for any alias key used twice in different bindings.

---

## 10. The One Inviolable Rule

**[ALWAYS]** any content the USER will read (questions, concerns, choices, warnings, error messages, explanations) -> full clear prose in their language -> zero BOTSPEAK

The user is not the audience for BOTSPEAK. The agent is.
