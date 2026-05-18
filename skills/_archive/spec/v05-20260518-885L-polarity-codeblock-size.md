# BOTSPEAK SPEC v2.2.0

<!-- botspeak-version: 2.2.0 · published: 2026-05-18 · repo: https://github.com/itaki/botspeak -->

> Human-maintainer specification. This document is intentionally human-readable and may use prose, markdown tables, and visual symbols for clarity.
>
> Runtime artifacts (`rules/*.mdc`, `skills/botspeak/SKILL.md`) are distilled from this spec and must follow the Core Philosophy below.
>
> **Version protocol:** every edit to this file bumps the version number. When the spec version reaches a milestone worth publishing, copy it into the skill (see §6 for the full protocol).

[REFERENCE] load when writing/auditing BOTSPEAK · skip on routine session load
the language for AI-to-AI documents · designed to be parsed by LLMs, not enjoyed by humans

---

## 0. Core Philosophy

The four tenets that govern every BOTSPEAK decision. Conflicts between them resolve top-down: clarity wins over universality, universality wins over compression, compression wins over personal taste.

### Tenet 1 — Clarity over compression

If a compression sacrifices meaning, polarity, nuance, or constraint strength, **revert it**. A doc that loses fidelity is worse than verbose prose. Compression is a means; correctness is the goal.

When in doubt, write it long.

### Tenet 2 — Universal AI readability

Any modern LLM must be able to read a BOTSPEAK file *without ever having seen the spec*. Borrow only from notation that AIs already know:

- Standard programming syntax (`->`, `&&`, `||`, `!=`, `=`, `:`, `?`)
- Regex idioms (`?`, `+`, `*`, `{n}`) for cardinality
- Universal emoji semantics (🚫 forbidden, ⚠️ warn, ✅ approved) when they genuinely compress meaning
- Markdown structural conventions (XML tags, code blocks, headings)

Never invent a symbol whose meaning has to be taught. If your BOTSPEAK file would confuse Claude, GPT, Gemini, or Llama on first read, the notation is wrong.

### Tenet 3 — Borrow from established systems

Decades of work have already happened on regex, markdown, common programming notation, and emoji semantics. Reuse rather than reinvent. When BOTSPEAK needs a new operator, look first at:

1. Common programming languages (C/JS/Rust/Python conventions)
2. Regex
3. Shell / Unix conventions
4. Universal emoji
5. Logic notation

Only invent novel syntax if none of the above fit.

### Tenet 4 — ASCII when an ASCII form does the same job; emoji/Unicode when it genuinely compresses

There is no hard ban on emoji or Unicode. The rule is:

- **ASCII wins** when an ASCII form expresses the same meaning at equal or lower token cost (`->` beats `→`, `!=` beats `≠`).
- **Emoji wins** when one symbol replaces a phrase or several words and is universally understood (🪤 for "subtle trap · bites later", 🔑 for "secret · do not log · do not commit"). See §1 for the full earns/loses table.
- **Don't use two different symbols for the same meaning in one file.** Pick one form and stay consistent — e.g. don't use both `→` and `->`, or both `!!` and 🚫. (This is the only "one dialect" rule. Mixing ASCII operators and emojis that mean different things is fine and expected.)

The single Unicode symbol BOTSPEAK adopts unconditionally is `·` as the **list separator** — it's used so heavily across the language that a one-token visual separator pays for itself.

---

## 1. Symbol Vocabulary

Defined here once, applied everywhere, no re-explanation in document body. Every symbol is borrowed from notation any modern LLM already knows (Tenet 2). Organized by source, not by "ASCII vs symbol" — that distinction is replaced by the rule in Tenet 4.

### Logical operators (from common programming languages)

```
&&   AND
||   OR
!=   not-equal
=    equals / defined-as
:    binding / labeling / type-of  (universal — works for state, alias, type, value)
?    unknown / verify / ask-user
```

### Flow operators

```
->   causes / leads-to / triggers / results-in    (causal arrow)
<-   derived-from / sourced-from                  (reverse derivation)
|>   data-flow / pipe / transforms-into          (functional pipe — distinct from causal ->)
```

`->` is causal ("X causes Y"). `|>` is functional ("X is transformed into Y"). Both are well-known to LLMs from Pascal/Rust/F#/Elixir.

### Constraint markers

```
!!   forbidden / never / hard-stop                (read as emphasis; AIs infer "important + negative")
ok   allowed / correct / approved                 (natural English word, 1 token)
~~   warn / check-first / conditional             (use sparingly; see note)
```

**Note on `~~`:** in markdown `~~text~~` means strikethrough. To avoid confusion, use `~~` only as a *prefix* (not wrapping). When clearer, prefer `?` (uncertain) or the emoji ⚠️.

### Cardinality (from regex)

Used as *suffix* on identifiers — distinguishes from logical operators above:

```
flag?       optional / 0-or-1            (e.g. `flag?` = optional flag)
arg+        one-or-more                  (e.g. `arg+` = one or more args)
tag*        zero-or-more                 (e.g. `tag*` = any number of tags)
step{3}     exactly n                    (e.g. `step{3}` = exactly three steps)
retry{1,3}  between n and m              (e.g. `retry{1,3}` = retry 1 to 3 times)
```

Regex idioms every LLM knows. **Disambiguation:** `?` as a *suffix on a token* (`flag?`) means optional; `?` *standalone* (`status: ?`) means unknown / verify. Context disambiguates cleanly.

### List separator

```
·    list separator               (the only Unicode symbol BOTSPEAK adopts unconditionally)
```

Used so heavily that a one-token visual separator pays for itself. AIs universally read `·` as a delimiter.

### Comments

```
//  line comment              (from C/C++/Java/JS/Rust — universal, 1 token, no markdown conflict)
<!-- ... -->  block comment   (markdown-native HTML comment; stripped by renderers)
```

Avoid `#` for comments — collides with markdown headings at line start.

### Emoji decisions (illustrative, not exhaustive)

Two reference tables. Both are *guidance*, not bans — costs are measured in single-digit tokens per use, so an "out of budget" emoji is rarely worth a fight. The point is to give an AI authoring BOTSPEAK a clear default so it doesn't reach for emoji out of training-data habit.

**Earns its tokens — reach for these freely:**

These bundle a multi-word concept into one symbol that AIs (and humans) recognize on first sight. There is no equally-clear ASCII shorthand.

| Emoji | ASCII alternative | Bundles / when to reach for it |
|---|---|---|
| 🪤 | none (would need 5+ words) | "subtle trap · looks fine but bites later" — handoffs, gotcha lists, footguns |
| 💥 | `BREAKING:` (loses urgency) | "breaking change · downstream consumers will break" — changelogs, migration notes |
| 🔑 | none (would need 6+ words) | "secret · credential · do not log · do not commit" — security rules, env-var docs |
| 🧪 | none (would need 5+ words) | "experimental · unstable · may change or disappear" — feature flags, alpha APIs |
| ⚓ | none (would need 5+ words) | "pinned · do not upgrade · locked to exact version" — dependency notes, version freezes |
| 🔥 | `URGENT:` (loses urgency) | "incident-priority · drop everything · production down" — hotfix rules, on-call docs |
| 📊 | multiple words | "chart · graph · visualization of" — replaces "bar chart of", "graph showing", etc. |

**Loses on tokens — prefer the ASCII form unless you have a specific reason:**

AIs reach for these emojis constantly because they're heavily reinforced in training data. In BOTSPEAK they cost more tokens than the ASCII operator they duplicate, and BOTSPEAK already has a one-token symbol that means the same thing. Use the emoji only when the visual marker matters more than the few extra tokens (e.g. rendering in a UI that emphasizes emoji glyphs).

| Emoji | ASCII equivalent | Why prefer ASCII |
|---|---|---|
| ✅ | `ok` (1 token) | `ok` already means approved/passed — emoji adds tokens, no semantic gain |
| ❌ | `!!` or `no` (1 token) | `!!` already means forbidden — emoji is redundant |
| ⚠️ | `~~` (1 token) | `~~` already means warn — exception: when `~~` would render as markdown strikethrough |
| 🚫 | `!!` (1 token) | redundant with `!!` — both mean "do not / forbidden" |
| 🐛 | `bug` (1 token) | `bug` is already 1 token and unambiguous |
| 🚧 | `WIP` (1 token) | `WIP` is already 1 token and the universal abbreviation |
| 🔒 | `[locked]` or `readonly` | usually clearer to spell out the constraint |
| ⏰ | `cron:` or explicit schedule | the schedule is the information; the clock is decoration |
| 🔁 | `retry` or `loop` | the verb is the information; the arrow is decoration |

The decision rule, applied to any emoji not on either list: **if you can replace the emoji with a 1-token ASCII form without losing meaning, do.** If the emoji bundles 3+ words and no ASCII operator exists, keep it.

### Directives (not operators — keyword prefixes)

```
@defs ... @end       alias-binding block (see §2)
@defs: a=x · b=y     one-line alias form (see §2)
[PHASE-TAG]          block phase classifier (see §3)
default-phase: TAG   declare the default phase for untagged blocks (see §3)
<tag>...</tag>       structural section (see §5)
```

The `@` in `@defs` is a directive sigil, not an operator — same role as `@decorator` in Python or `@interface` in TypeScript.

**Conventional structural tag names** (used in long-doc XML structure, see §5):

```
<context>     project / phase / scope orientation
<defs>        document-scope alias bindings
<rules>       behavioral rules and constraints
<reference>   pointers to files / docs / external material
<section name="X">   named scope wrapper (for section-scope @defs)
```

Tag names other than these are allowed; these are the convention so that AIs encountering BOTSPEAK files recognize the structure on first sight.

### Cost reference (o200k_base, GPT/Claude family)

| Form | Token cost | Notes |
|---|---|---|
| `->` | 1 | universal causal arrow |
| `→` | 2-3 | Unicode equivalent — avoid when ASCII fits |
| `&&` | 1 | universal AND |
| `·` | 1-2 | adopted as the BOTSPEAK separator |
| `!!` | 1 | reads as emphasis |
| `🪤` | 3-4 | earns it — bundles "subtle trap · bites later" (5+ words) |
| `🔑` | 3-4 | earns it — bundles "secret · do not log · do not commit" |
| `🚫` | 3-4 | does not earn it — `!!` is 1 token and means the same thing |
| `✅` | 3-4 | does not earn it — `ok` is 1 token and means the same thing |

**Rule of thumb:** if the emoji costs N tokens and replaces fewer than N words, prefer words. If it replaces a phrase or carries semantic weight ASCII can't, use the emoji.

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

[ALWAYS] all queries -> filter by E
[ALWAYS] WR + CSR generation -> reads S.account_id · S.sftp_base_path
[ON-TRIGGER] MV stale -> refresh-concurrently · log to obs_mv_refresh
!! never hardcode E · S · any per-establishment value
```

Without aliases, that block is ~80 tokens of repeated `establishment_id`, `settings.toast_config`, `wine-report`, `customer-satisfaction-report`. With aliases: ~40 tokens. **50% off, zero loss.**

### Section-scope (long docs, narrow concept)

```
<section name="payments">
@defs
  TX = stripe-transaction
  RC = refund-claim
@end
TX -> webhooks/stripe.ts handles · RC -> workers/refund.ts processes
</section>
```

Section-scope `@defs` only bind inside their `<section>` wrapper. Use when concept is local.

### One-line `@defs` (short docs, 2–4 aliases)

For docs short enough that a multi-line `@defs` block feels heavy:

```
@defs: E=establishment_id · S=settings · MV=mat-view
```

Roughly 60% smaller than the block form. Same parse semantics.

### Inline first-use binding (single-use docs)

```
[X:wine-report] first reference establishes X = wine-report
later: X due daily 06:00 -> upload to S3
```

Use only when alias appears 3+ times in a short doc and even the one-line `@defs` feels heavy.

### Alias naming conventions

```
ok mnemonic letters: E (establishment) · S (settings) · MV (materialized-view)
ok short upper:      WR · CSR · RBAC · API
!! arbitrary:        A · B · C (no semantic anchor -> LLM more likely to lose binding)
!! collisions:       reusing E for "establishment" then "error" in same doc
!! too clever:       Σ · Ω · Π (Unicode that tokenizes badly)
```

### Reliability bounds (grounded in 2025 long-context benchmarks)

LLMs reliably resolve `@defs` aliases via **literal-key recall** (the use site contains the exact alias key — which is BOTSPEAK's design):

| Body size | Alias reliability | Recommended strategy |
|---|---|---|
| < 2K tokens | near-perfect | doc-scope `@defs` |
| 2K – 4K tokens | reliable | doc-scope `@defs` |
| 4K – 8K tokens | drift begins | re-declare `@defs` per major section |
| > 8K tokens | unsafe | section-scope `<defs>` mandatory |

**Other constraints:**

- `@defs` must appear in the **first 200 tokens** of the document (or section)
- **≤ 15 aliases** per `@defs` block (more = collisions, harder to scan)
- Use **mnemonic** keys (`E` for establishment, `WR` for wine-report) — never `A`/`B`/`C`
- **No alias collisions** within scope (don't use `E` for both "establishment" and "error")

Grounded in NoLiMa (2025) and binding-ID research: literal recall stays strong well past where associative recall fails.

### Alias generation workflow (for compressor implementations)

A top-down writer does not know optimal aliases until it has seen the full document distribution.

Use a **two-pass flow**:

1. **Pass A — inventory**
   - Read the full source.
   - Count repeated identifiers and estimate token cost per identifier.
   - Select alias candidates by savings potential and clarity.
2. **Pass B — render**
   - Emit `@defs` at the top of the output (or section-scope `<defs>` for long docs).
   - Write/rewrite body using chosen aliases consistently.
3. **Pass C — verify**
   - Check for collisions, undefined aliases, and missed substitutions.

If a streaming implementation must write top-down, it should buffer output until alias selection is complete, then finalize in one write.

---

## 3. Phase Tags

Every content block gets a tag · agents use tags to skip irrelevant context.

```
[NEW-CHAT]    load at session start · agent may skip after context established
[ALWAYS]      every turn · no exceptions
[ON-TRIGGER]  condition-gated · read only when pattern fires
[UNLESS]      applies every turn UNLESS the condition holds (negative gate)
[REFERENCE]   look-up only · skip during normal session load
[HANDOFF]     cross-session context · new-agent reads first-turn only
```

`[ON-TRIGGER]` and `[UNLESS]` are inverses. Pick whichever reads more naturally:

```
[ON-TRIGGER] file-size > 50K -> warn-user-and-confirm
[UNLESS]     user-passed -y-flag -> ask-for-confirmation
```

A 1500-token rule file fully tagged lets agents process maybe 600 tokens on turn 5 (skipping `[NEW-CHAT]` and `[REFERENCE]` blocks). Compounds across every session.

### Default-phase declaration (token saver for phase-heavy docs)

When 80%+ of a document's blocks share one phase, declare a default at the top and only tag exceptions:

```
default-phase: ALWAYS

all queries -> filter by E
!! never hardcode establishment values

[ON-TRIGGER] MV stale -> refresh-concurrently
[REFERENCE] field-mapping: src/migrate/mapping.py
```

In this example two of the four blocks needed no tag — saving the `[ALWAYS]` repetition. Use only when the default-phase blocks dominate; mixed-phase docs should tag every block.

---

## 4. Grammar Rules

### Drop ruthlessly

```
articles:         a · an · the
filler verbs:     is · are · has · have (when replaceable by = or :)
throat-clearing:  "Please note that" · "It is important to" · "In order to ensure"
hedging:          "typically" · "generally" · "usually" (unless precision-critical)
transitional:     "Additionally," · "Furthermore," · "As mentioned"
passive voice:    "it should be noted" -> just state the thing
restated obvious: "as I mentioned above" · "to recap"
```

### Keep absolutely

```
technical terms · identifiers · file paths · exact values
all behavioral constraints (!! and ok)
all invariants (!! INVARIANT: ...)
cause-chains (A -> B -> C)
conditional logic (if/then -- do NOT merge into a flat list)
exact numbers · thresholds · limits
constraint polarity (!! never vs ok allowed -- wrong polarity = bug)
every distinct timing concept (interval, first, duration, delay are SEPARATE variables, not one)
per-entity mutable state (each instance has its own copy of a variable) vs ambient/offset state (single shared scalar)
all fenced code blocks (``` or ~~~) — verbatim, no exceptions (Mermaid, YAML, code samples, config snippets all stay byte-for-byte)
```

**Per-entity state vs ambient/offset state.** When a spec describes objects that each carry independent position or other state (enemies, projectiles, particles), each instance requires an explicit `x_init`, per-frame mutation (`x: -= speed each FR`), and removal condition. When a spec describes ambient effects driven by a single shared scalar (scrolling background, parallax layer), use the offset form (`layer_offset: += speed each FR`). Using the same motion language for both causes build models to apply one abstraction to all — usually the ambient/offset pattern, which silently breaks per-entity physics while visually appearing correct. If the two kinds of motion coexist in one spec, label them explicitly (e.g. `← entity: per-instance x` vs `← ambient: single offset`).

**Conditional logic must stay conditional.** If the prose says "every 90 frames, with the first one at frame 120", that is *two* state variables. Merging them into a single descriptive assignment (`spawn = every 90, first at 120`) loses the structural distinction and downstream models will reverse-engineer one combined behavior — usually wrong. Keep them as named variables: `spawn_interval = 90` · `spawn_first = 120`.

### The strict `=` operator rule

This rule is grounded in observed failures: cheaper/smaller models read `=` as literal assignment. When the right-hand side contains adverbs ("every"), prepositions ("at"), or verb phrases ("starts"), models treat the whole line as ambient context rather than a named variable, and infer implementation from the description rather than the named state. Larger models tolerate the ambiguity better, but all models prefer the explicit form. Write for the smallest reasonable model.

**After `=`, the right-hand side must be a value, not a description.**

```
ok RHS:  numeric (`= 90`) · typed value (`= 90 FR`) · aliased reference (`= CV.h * 0.5`) · literal (`= 'flappyBirdBest'`)
!! RHS:  adverbs ("every"), prepositions ("at"), verbs ("starts"), or any descriptive phrase
```

Concrete examples:

```
!! X = every 90 FR          ok X_interval = 90 FR        (variable name carries the "every")
!! Y = first at 120          ok Y_first = 120              (variable name carries the "first at")
!! Z starts 0                ok Z_start = 0                (verb-noun assignment must use `=`)
!! retries = up to 3         ok max_retries = 3            (cap belongs in the name, not the value)
```

**The disambiguation test:** if a name + value cannot answer the question *"what does this number represent?"*, rename the variable until it can.

```
!! PP_spawn = 90              (frequency? duration? threshold? cooldown?)
ok PP_spawn_interval = 90 FR  (clearly an interval, in frames)
```

### Compression patterns

**Cause chains** (highest savings, most common)
```
❌ "If the user's request does not belong to the current branch, that
    represents a scope separation concern and should be treated as such,
    and the agent should stop before proceeding."
✅ request != branch -> scope-split -> stop
```

**Prohibition lists**
```
❌ "Never hard-code establishment IDs. Do not hard-code establishment names.
    Avoid hard-coding SFTP folder paths. Do not use Toast account IDs."
✅ !! NEVER hardcode: E · name · SFTP-path · Toast-account-id
```

**State declarations**
```
❌ "The migration system is mostly complete. We've implemented the core
    migration engine that reads from the source database and writes..."
✅ state: migration-engine ok · field-mapping ok · rollback-test ~~ pending
```

**Decision trees**
```
❌ Three paragraphs of nested conditionals
✅ stale-in-setState -> use functional-form
   stale-in-listener + need-stable-cb -> ref pattern
   stale-in-effect + ok-to-rerun -> add to dep-array
```

**Guardrail bundles** (one operator + compact list)
```
❌ "Never mix dialects. Never compress frontmatter. Never invent stronger constraints."
✅ !! never: mix-dialects · compress-frontmatter · strengthen-constraint
```

**Default/override chains**
```
❌ "By default use ASCII. If user asks for prose, output prose. If user asks preview, show chat output."
✅ default: ASCII
   on user-asks-prose -> prose
   on user-asks-preview -> chat-output
```

**State snapshots**
```
❌ "The parser is done, serializer is in progress, validation is blocked."
✅ state: parser ok · serializer ~~ in-progress · validation !! blocked
```

**Polarity flip (default-deny / default-allow)**

Huge savings on auth, permissions, allowlists, and any "small set of exceptions to a broad rule" doc. Instead of listing 50 forbidden things, declare the default and list only the exceptions:

```
❌ "Users may not access X. Users may not access Y. ... [50 lines] ... Users may access read-public, health-check, and login."
✅ default: deny
   allow: read-public · health-check · login
```

The inverse works too:

```
✅ default: allow
   deny: admin/* · /internal/* · payments-mutate
```

**Range / threshold notation**

Numeric conditions written as inline ranges, not nested if/else prose:

```
❌ "If retry count is below 3, try again. If between 3 and 5, alert. If 5 or more, fail the job."
✅ retries: <3 -> try-again · 3-5 -> alert · >=5 -> fail
```

**Pipe chains (functional data flow, distinct from causal `->`)**

Use `|>` when the relationship is "X transforms into Y", not "X causes Y":

```
❌ "Parse the input, then validate it, then enrich it, then write it to the database."
✅ input |> parse |> validate |> enrich |> write
```

Reserve `->` for causation (`stale -> refresh`); use `|>` for data flow. The distinction matters: causal chains describe rules; pipe chains describe pipelines.

**Tabular condensation (when matrix beats tree)**

When a decision depends on two or more inputs and the cross-product is small, a table is denser than a decision tree:

```
❌ Decision tree:
   if size = small && speed = fast -> A
   if size = small && speed = slow -> C
   if size = large && speed = fast -> B
   if size = large && speed = slow -> D

✅ Decision table:
        | small | large
   fast | A     | B
   slow | C     | D
```

Use the table when: two or more axes, ≤4 outcomes per cell, and every combination is meaningful. Use the tree when most combinations don't apply.

### Authoring guidelines (decision rules for skill authors)

Distinct from compression patterns above (which are syntactic templates). These are decision rules for *how* to compress, not *what* to write:

1. **Alias by savings, not just frequency.** Prioritize terms with high `(token_len - 1) × repeats`. A long identifier repeated 4× may beat a short identifier repeated 8×.

2. **Scope-local aliasing in long docs.** Keep global `@defs` small; use section `<defs>` for local concepts to reduce collision risk and keep alias keys close to their use sites.

3. **Predicate hoisting.** If multiple lines share the same condition, state it once then list the effects:
   ```
   on stale:
     refresh MV
     log to obs_mv_refresh
     notify ops-channel
   ```

4. **Canonical block ordering for scanability.** Preferred order: invariants -> triggers -> actions -> constraints -> references. AIs scan in document order; lead with what matters most.

5. **One symbol per meaning per file.** Don't use two different symbols that mean the same thing in one doc — e.g. don't mix `->` and `→`, or `!!` and 🚫 (Tenet 4). Mixing ASCII and emoji that carry *different* meanings (e.g. `->` and 🪤) is fine.

6. **Empty-block elision.** If a section has no content, omit the tag entirely. Don't write `<rules></rules>` — the AI infers absence from the missing tag.

---

## 5. Document Structure

### Short doc (≤10 lines)

```
[phase-tag] title
@defs (if 3+ repeated terms)
  E = establishment_id
@end

invariant or main constraint on first line
details as cause-chains or ok/!! blocks
triggers: condition-that-fires-this
```

### Long doc (>10 lines, multiple concerns)

Wrap sections in XML tags. Claude parses XML semantic boundaries more reliably than markdown headings in long context. Tags add ~6 tokens per section but prevent attention bleed.

```xml
<context>
  project: MyProject · phase: build · not: ops
  branch-policy: one-tree = one-feature
</context>

<defs>
  E   = establishment_id
  S   = establishment.settings.toast_config
  MV  = materialized-view
</defs>

<rules>
  [ALWAYS] !! INVARIANT: BUILD system / DO NOT do-the-work
  [ALWAYS] all queries -> filter by E (no exceptions)
  [ON-TRIGGER] request != branch -> stop -> A/B/C choice
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

done: item ok · item ok · item ok
bugs (fix first): !! description -> root-cause · !! description -> root-cause
todo: step1 -> step2 -> step3
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
key: A -> B -> C (cause chain)
!! anti-pattern: description · why-it-fails
ok pattern: description · when-to-use
ref: [[linked-topic]]
```

---

## 6. Versioning and provenance

### BOTSPEAK version number

BOTSPEAK uses semver (`MAJOR.MINOR.PATCH`):

| Bump | When |
|---|---|
| **PATCH** (`2.0.0 → 2.0.1`) | Clarifications, wording fixes, examples added, no new rules or symbols |
| **MINOR** (`2.0.x → 2.1.0`) | New section added, new symbol introduced, new phase tag, or backward-compatible rule change |
| **MAJOR** (`2.x.x → 3.0.0`) | Complete overhaul, breaking symbol contract change, new paradigm |

**Where the version lives:**

1. **SPEC.md** — the H1 heading (`# BOTSPEAK SPEC v2.0.0`) and the `<!-- botspeak-version: ... -->` metadata comment on line 3.
2. **skills/botspeak/SKILL.md** — a `<!-- botspeak-version: ... -->` comment immediately after the YAML frontmatter's closing `---`, and hardcoded in step 7's output header format string.

**The publish protocol** (spec edits → skill release):

```
1. Edit SPEC.md → bump version in H1 + metadata comment (every change, even small)
2. When the spec is stable and tested → publish a new skill:
   a. Update skills/botspeak/SKILL.md version comment (after frontmatter ---)
   b. Update the hardcoded version string in step 7 of SKILL.md
   c. Copy skills/botspeak/SKILL.md → ~/.cursor/skills-cursor/botspeak/SKILL.md
   d. Archive the old skill in skills/_archive/botspeak/ with naming:
      v<seq>-<YYYYMMDD>-<lines>L-<short-tag>.md
   e. Update skills/_archive/README.md table
3. Spec version == Skill version at publish time (!! never mismatch)
```

Include a version stamp when symbol contracts may differ across projects. The version stamp doubles as the document's H1 heading — that's intentional, not a conflict with the comment guidance in §1.

```
# BOTSPEAK v2.0.0
@defs
  E = establishment_id
@end
```

Agents reading a versioned doc know which contract applies.

### Compression provenance header

Any document produced by `/botspeak` (or by any compressor following this spec) **must** begin with a one-line metadata comment that records what produced it:

```
<!-- BOTSPEAK v2.0.0 · compressed by claude-haiku-4 · 2026-05-07 -->
```

Placement:

- If the file has YAML frontmatter, place the comment immediately after the closing `---`.
- If the file has no frontmatter, place it as line 1.

Required fields:

- BOTSPEAK version (the contract used — must match the skill version that ran the compression)
- Model slug that performed the compression (`claude-haiku-4`, `claude-sonnet-4`, `gpt-4o-mini`, etc.; `unknown-model` if not detectable)
- Compression date in `YYYY-MM-DD`

This header is the trace that lets a maintainer correlate downstream failures back to a specific compressor version + model. When a compressed doc misbehaves, the first question is always *"which compressor produced this, on which model?"* — and the header answers it without git archaeology.

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

## 7a. Source documents may be inconsistent — surface, never silently fix

The compressor's job is *preservation*. When the source document contains its own contradictions, the compressor must **surface them to the human, not silently resolve them**. A compressor that quietly picks one of two contradictory rules and emits a clean output looks like it succeeded — until the rule that got dropped fires in production.

The classes of issue worth scanning for during compression:

```
type contradiction      X declared as type A · used as type B elsewhere
polarity contradiction  X required && forbidden in same scope
value contradiction     X = N1 in one place · X = N2 in another · no override rule
undefined reference     alias / identifier used in body · never declared
circular dependency     A defined as B · B defined as A
logical impossibility   mutually exclusive conditions presented as compatible
scope ambiguity         same identifier means different things in different sections
```

**Severity tiers:**

- **Minor** (1-2 issues, narrow scope) — note in the closing summary, proceed with compression.
- **Moderate** (3+ issues, or one issue spans the core domain) — note prominently, proceed with compression.
- **Catastrophic** (document logic is fundamentally inconsistent) — stop, ask the human whether to continue.

```
!! never: silently merge conflicting values
!! never: pick one interpretation when two exist
!! never: delete contradictory text to "clean up" the output
ok:       preserve all conflicting statements verbatim · let the human decide
```

The output of a compressor with detected conflicts is two artifacts: the compressed file, and a closing prose summary that tells the human *what was contradictory in the source*. The compression itself is faithful to the source — including the contradictions.

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

**4. Phase-tagging inconsistently**
If you tag *some* blocks with `[ALWAYS]` and leave others untagged (without using `default-phase:`), the agent has to infer phase for the untagged blocks. Either tag every content block, declare a `default-phase:`, or accept the risk.

**5. Aliases defined far from use**
A `@defs` block in the middle of a 5K-token doc with uses 4K tokens later will drift. Either keep `@defs` in the first 200 tokens of the document, or use section-scope `<defs>` inside the relevant section.

**6. Ambiguous abbreviations**
`MV = materialized-view` and later in same doc `MV = minimum-viable` — collision. The LLM will pick one, often wrong. One scope, one binding, no collisions.

**7. Forgetting humans exist**
Anything the user reads from the agent (questions, error messages, status updates, explanations) must be full prose in the user's language. BOTSPEAK is for AI-to-AI documents only. If you BOTSPEAK at the user, they will hate you.

**8. Complex and nuanced ideas**
If the idea is complex or nuanced, write it in prose so as not to lose nuance (Tenet 1: clarity over compression). BOTSPEAK is not suited for irreducibly complex ideas.

**9. Mixing `->` and `|>` arbitrarily**
`->` is causal ("X causes Y"); `|>` is functional ("X transforms into Y"). Mixing them in the same chain confuses the reader about what kind of relationship is being described. Pick the right operator for the relationship type.

**10. Ambiguous `=` assignments (one-shot reliability hazard)**
The right-hand side of `=` must be a value, not a description. `X = every 90` reads to smaller models as ambient prose, not as an assignment, and they will infer behavior from the description instead of treating `X` as a named state variable. Write `X_interval = 90` instead — the variable name carries the qualifier, the value stays clean. See §4 "The strict `=` operator rule" for the full set of examples.

**11. Bundling distinct state variables into one assignment**
"Spawns every 90 frames with the first one at frame 120" is *two* variables: an interval and a first-occurrence offset. Compressing it as one descriptive line (`spawn = every 90, first at 120`) loses the structural distinction and produces broken downstream code. Each distinct timing concept (interval, first, duration, delay, cooldown) is a separate named variable.

**12. Hallucinated `@defs` aliases**
Every alias in `@defs` must satisfy two conditions: (a) it appears in the source document — do not invent aliases for concepts the source doesn't mention; (b) it is actually used in the body at least once — unused aliases are dead weight and can mislead downstream readers about what concepts exist. At the end of step 1 (inventory), cross-check your alias candidates against the source. At step 6 (verify), confirm every defined alias appears in the body and every alias in the body is defined.

```
!! define alias for concept not present in source
!! define alias never used in body
ok  define alias for concept repeated >=3 times in source
```

**13. Conflating per-entity mutable state with ambient/offset state**
When multiple objects each carry their own position that mutates independently each frame, compressing their motion as "moves left" or "scrolls" is ambiguous — it matches both per-instance mutation (`obj.x -= speed`) and the ambient/offset pattern (`layer_offset += speed`). Build models default to the simpler pattern, breaking per-entity physics while visually appearing correct. Use the explicit three-part form for all per-entity moving objects:
```
obj.x_init     = <spawn position>
obj.x:         -= <speed> each FR   ← per-instance mutation, NOT an offset
obj.remove-when: obj.x + obj.w < 0
```
Reserve the `layer_offset += speed each FR` form for ambient/parallax effects with no per-instance state. Label both forms explicitly when they coexist in one document.

**14. Applying `!!` to correct-but-cautionary statements (polarity inversion)**

`!!` means "forbidden / never do this." Before emitting `!!`, verify the underlying claim is actually a prohibition. Source language that *sounds* cautionary is not always a prohibition:

```
source: "To opt out of auto-update, set DISABLE_AUTOUPDATER=1"
  wrong: !! DISABLE_AUTOUPDATER=1                    (reads as: forbidden setting)
  right: [ON-TRIGGER] opt-out auto-update -> set DISABLE_AUTOUPDATER=1

source: "Only run X if Y holds"
  wrong: !! run X                                    (reads as: forbidden)
  right: [ON-TRIGGER] Y holds -> run X

source: "Prefer X over Z when possible"
  wrong: !! use Z                                    (reads as: forbidden)
  right: default X · fallback Z (when X unavailable)
```

The decompressed `!!` reads as "forbidden / warning" without context. A polarity-inverted `!!` is dangerous because it travels cleanly through the round-trip and produces an actively wrong constraint — an agent following it will do the opposite of what the source said.

**Decision test:** can you replace `!!` with the literal word "forbidden" or "never" and have the statement still be true? If not, `!!` is wrong; use a phase tag, an `[ON-TRIGGER]` form, or an inline note instead.

**15. Dropping fenced code blocks on long docs**

Code blocks are often the highest-value content in a technical spec — they're the concrete artifact the rule is about. The skill is supposed to preserve them verbatim, but on long/complex docs (4000+ words) the rule gets crowded out and Mermaid diagrams, YAML configs, and code snippets get summarized or dropped.

The fix is procedural, not notational: count fenced code blocks (``` or ~~~) in the source, count them in the compressed output, and fail compression if the counts disagree. If the doc is too large for single-pass preservation of all its code blocks, see §10 (size guidance) — split the doc or keep code blocks as appendices.

### How to debug a BOTSPEAK file that "isn't working"

1. **Run `/botspeak-translate` on it.** Compare the output to what you intended. Drift means the BOTSPEAK is wrong, not the agent.
2. **Check `@defs` proximity.** If the file exceeds 4K tokens, document-scope `@defs` at the top isn't enough — duplicate them per section using `<section name="X">` scope (see §2 reliability bounds table).
3. **Check phase-tag accuracy.** A `[REFERENCE]` block the agent needs every turn won't fire. A `[ALWAYS]` block that's actually situational wastes tokens.
4. **Check description prose.** If your skill isn't triggering, the description is too terse. Add "Use when..." with concrete invocation examples.
5. **Check for collisions.** Grep for any alias key used twice in different bindings.

---

## 10. Document Size Guidance

BOTSPEAK works best on documents under ~1500 words. Above that, three problems compound:

- **Code blocks, diagrams, and inline examples become disproportionately large** relative to compressible prose. They cannot be compressed (see §4 and §9 pitfall 15), so the achievable ratio on the *body* falls fast while the *output* keeps growing.
- **Compression ratio falls below 0.25.** Below that threshold, most content is already dense and further compression risks dropping signal.
- **`@defs` proximity reliability degrades.** Per §2, alias resolution becomes unreliable past 4K tokens of body unless `<section>`-scoped `<defs>` blocks are used at section boundaries.

**Recommended strategy by source size:**

```
< 1500 words    -> single-pass compression, doc-scope @defs
1500-4000 words -> single-pass compression, but verify code-block count + polarity carefully
4000-8000 words -> section-scope <defs> mandatory · re-declare aliases per major section
> 8000 words    -> split the doc · compress each section separately · or keep code blocks as appendices and compress only the prose
```

When in doubt, split. A 6000-word migration spec is better expressed as four 1500-word sections each compressed independently than as one giant pass where the verify checks struggle to keep up.

---

## 11. The One Inviolable Rule

**[ALWAYS]** any content the USER will read (questions, concerns, choices, warnings, error messages, explanations) -> full clear prose in their language -> zero BOTSPEAK

The user is not the audience for BOTSPEAK. The agent is.
