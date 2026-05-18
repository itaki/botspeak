# BOTSPEAK Philosophy

BOTSPEAK exists to give AIs a way to talk to other AIs in something closer to their native voice.

This project is not a demo. It is not a Flappy Bird game generator. It is not a compression tool, though compression happens as a side effect. The Flappy Bird and other code-synthesis evals in this repo are stress tests for the language's fidelity. They are diagnostic instruments. They are not the product.

## The actual thesis

When two humans communicate, language is full of scaffolding. Articles like "the" and "a." Prepositions like "of" and "in" in positions where the relationship is already obvious. Transitional phrases like "as mentioned above" and "in order to ensure." Hedging like "typically" and "generally." Restatements that say the same thing three different ways so a tired reader catches it on at least one pass.

Humans need that scaffolding. Human cognition is sequential, distractible, and emotional. The scaffolding gives us time to process, signals tone, prevents misreading, and softens hard ideas.

When a modern language model reads, almost none of that scaffolding earns its place. The model does not need "Please note that" before a rule. It does not need "In order to" before a goal. It does not need most articles, most prepositions, most transitions, most hedges. The model already carries the priors that scaffolding exists to install.

But agents have spent their entire training reading documents written for humans, so they generate the same scaffolding back at each other by default. CLAUDE.md files, rule files, system prompts, agent handoffs, memory pages, skill instructions all get written in full human prose because that is what the training distribution looks like. Every agent session then pays the parse tax on that scaffolding, on every turn, forever.

BOTSPEAK is the proposal that AIs writing to other AIs should drop that scaffolding and use notation the model already knows fluently from training. The vocabulary is not invented. It is borrowed:

- Regex idioms for cardinality and optionality (`?`, `+`, `*`, `{n}`, `{n,m}`)
- Programming operators for logic and flow (`->`, `&&`, `||`, `!=`, `=`, `|>`)
- Math operators for relations and comparison (`<`, `>=`, ranges)
- Markdown and XML for structural boundaries
- Emoji where one symbol genuinely bundles a multi-word concept (`shape`, `secret`, `experimental`)

None of this has to be taught. Any modern LLM can read these on first sight without a cheat sheet. That is the whole point: communication that is natural for the audience, where the audience is another AI.

## What BOTSPEAK is not

**Not a compression algorithm.** Documents in BOTSPEAK do come out shorter, often by 40 to 60 percent. That is a measurable side effect of removing what only humans needed. It is not the goal. A doc that compresses by 80 percent but loses a constraint is worse than the original. The SPEC says clarity wins over compression, and that ordering is intentional.

**Not a replacement for prose when prose is the right tool.** Irreducibly complex or nuanced ideas should be written long. The SPEC pitfall list explicitly says: when in doubt, write it long. This philosophy document itself is written in prose for exactly that reason.

**Not for human-facing output.** Anything a human will read - questions to the user, error messages, status updates, explanations, choices, warnings - is full prose in the human's language. This is the one inviolable rule of the project. If you BOTSPEAK at a human, they will hate you, and they will be right.

**Not a single canonical dialect.** BOTSPEAK borrows from systems AIs already know and lets the author pick the symbols that fit a given document. The constraint is consistency within a file (do not mix `->` and the Unicode arrow in the same doc), not uniformity across files.

## What it is

A practical proposal for what AI-to-AI internal documents should look like once we stop pretending the second reader is a human.

The documents in scope: Cursor rules, Claude skills, CLAUDE.md, AGENTS.md, agent handoffs between sessions, memory or wiki pages an agent maintains for itself, system prompts, and any other artifact where the audience is a model rather than a person.

The documents out of scope: anything a human will read directly. README files. User-facing error messages. Marketing copy. Anything that gets displayed in a chat surface to an end user. Those stay in prose, in the user's language.

## What is in this repo

- `SPEC.md` - the language specification, currently at v2.1.0
- `skills/botspeak/SKILL.md` - the skill that compresses a prose AI-facing doc into BOTSPEAK
- `skills/botspeak-translate/SKILL.md` - the skill that translates BOTSPEAK back into prose for human audit
- `.cursor/rules/` - operational rules (when to use BOTSPEAK, README sync protocol, versioning protocol)
- `examples/` - six before-and-after pairs across different document types
- `evals/` - the eval suite, including round-trip evals on real AI-facing docs and stress-test evals on game synthesis

The eval suite includes game-synthesis stress tests (Flappy Bird, Tetris, Snake) because those expose failures in the language's fidelity faster than round-trip evals do. They are diagnostic. They are not what the language is for.

## How to know if BOTSPEAK is working

Two signals, in order of weight.

**Signal one: round-trip fidelity.** A document compressed into BOTSPEAK and then translated back into prose should mean the same thing as the original. No inverted polarity. No lost constraint. No hallucinated rule. No drift on numeric thresholds or named entities. This is the canonical eval because it tests the language on its actual design target: AI-facing internal documents.

**Signal two: downstream task parity.** An AI given the BOTSPEAK form of a prompt should perform the downstream task as well as one given the prose form. Same physics in the generated game. Same behavior under the rule. Same conclusion from the handoff. When parity breaks, the language lost something the prose carried.

A green Flappy Bird is one data point on signal two. A green round-trip eval across nine real AI-facing documents is the data that actually tells you the language works for its intended purpose. Both matter, but the order of weight matters too. If round-trip evals start failing on real docs, the language is broken. If a game eval fails but round-trips pass, the failure is at the edge of the language's envelope and is interesting, not fatal.

## A note on framing

It is tempting to talk about BOTSPEAK as "a compressed notation" or "a way to save tokens." That framing is technically accurate and almost always misleading. It puts the spotlight on the side effect and hides what is actually going on.

The accurate framing is that BOTSPEAK is what AI-to-AI documents look like when you remove what was only there for humans. The shorter token count is the measurement, not the motive.
