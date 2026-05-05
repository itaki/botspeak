---
name: capture-botspeak
description: Capture rambling human chat input as a focused BOTSPEAK document (rule, handoff, memory page, or skill). Use when the user has talked through a problem and you need to save the durable signal.
triggers: ["capture this", "save this as a rule", "make this a handoff", "/capture-botspeak", "turn this into a memory page", "save this for next session"]
---

[ALWAYS] role = listener -> distiller -> structured BOTSPEAK doc writer
input = unfocused human chat (rambling, repeats, side-tangents, mixed concerns)
output = ONE focused BOTSPEAK doc + ONE clarifying question if intent is ambiguous

# step 1: classify intent (ask user if unclear)
listen for cues to pick the right doc type:
  "make this a rule"          -> [ALWAYS] rule (.cursor/rules/, CLAUDE.md addition)
  "save for next session"     -> [HANDOFF] context handoff doc
  "remember this pattern"     -> wiki/memory page (Karpathy LLM-wiki style)
  "turn this into a skill"    -> SKILL.md with frontmatter
  ambiguous                   -> ask user: "rule, handoff, memory, or skill?"

# step 2: extract signal from noise
walk through the chat input and pull out:
  invariants ("never", "always", "must", "critical")
  triggers  ("when X", "if Y", "after Z")
  constraints (allowed values, forbidden values, ranges)
  decisions made + rationale
  state ("done", "todo", "broken", "pending")
  open questions
  identifiers used >=3 times -> alias candidates

drop:
  meta-talk about the conversation itself ("as I was saying", "let me think")
  abandoned hypotheses (user said X, then said no actually Y)
  social filler (pleasantries, apologies, hedging)
  duplicate restatements (user said the same thing 3 ways)

# step 3: structure
build the doc per the chosen type:
  rule -> see SPEC.md "Short doc" or "Long doc with sections"
  handoff -> see SPEC.md "Context handoff"
  memory -> see SPEC.md "Memory/wiki page"
  skill -> standard YAML frontmatter + BOTSPEAK body

apply BOTSPEAK conventions:
  @defs for repeated identifiers (>=3 uses)
  phase tags ([NEW-CHAT], [ALWAYS], [ON-TRIGGER], [REFERENCE], [HANDOFF])
  ASCII operators by default (->, &&, ||, !=, !!, ok, ~~)
  symbol dialect (🔴 ✅ ⚠️) only if user explicitly asked

# step 4: present + verify (user-facing -> use full prose)
show the user:
  1. classification you chose ("I captured this as a [type]")
  2. the BOTSPEAK doc itself
  3. summary in plain prose: "This rule says: [2-3 sentences in user's language]"
  4. file path you'd save it to (if user wants it persisted)
  5. open clarifications: anything the user input was ambiguous about

# step 5: confirm scope
ask: "Did I capture what you meant? Anything missing? Anything to drop?"
on user "yes" -> offer to write the file (use Write tool)
on user feedback -> revise + re-show -> ask again

# the scope discipline
[ALWAYS] capture ONE doc per invocation
  user dumped notes about 3 unrelated things -> ask: "I see rule + handoff + memory; which one first?"
  do NOT silently produce 3 docs from one capture session

# the inviolable rule
[ALWAYS] every word the USER reads from this skill = full human prose, in their language
  the BOTSPEAK doc itself is the only BOTSPEAK output
  all your commentary, classification, summary, questions = prose
