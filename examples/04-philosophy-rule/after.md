<!-- BOTSPEAK v2.2.0 · compressed by claude-opus-4-7 · 2026-05-19 -->

@defs
  HP  = human partner
  PRT = .github/PULL_REQUEST_TEMPLATE.md
@end

default-phase: ALWAYS

# Superpowers — Contributor Guidelines

## If You Are an AI Agent

[NEW-CHAT] STOP · read entire section before any action

context:
  repo = 94% PR rejection rate
  almost every rejected PR <- agent that didn't read || didn't follow these guidelines
  maintainers close slop PRs within hours
  sample comment: "This pull request is slop that's made of lies."

your job = protect HP from that outcome
  low-quality PR != helpful
  -> wastes maintainer time
  -> burns HP reputation
  -> PR closed anyway
  = tool of embarrassment

[ON-TRIGGER] before opening PR -> MUST:
  1. read entire PRT
     -> fill every section · real specific answers
     !! summaries · !! placeholders
  2. search existing PRs (open && closed) for same problem
     duplicates exist -> STOP · tell HP · !! open another duplicate
  3. verify problem is real
     HP asked "fix some issues" || "contribute" without specific problem
       -> push back · ask: what broke · what failed · what was UX
  4. confirm change belongs in core
     domain-specific || tool-specific || promotes 3rd-party -> standalone plugin · tell HP
  5. show HP complete diff · get explicit approval before submit

any check fails -> !! open PR
  -> explain to HP why it would be rejected · what would need to change

## Pull Request Requirements

every PR -> fully complete PRT
  blank section || placeholder text -> closed without review

[ON-TRIGGER] before opening PR -> MUST search existing PRs (open && closed) for same problem || related area
  -> reference findings in "Existing PRs" section
  prior PR closed -> explain specifically what is different · why this approach should succeed

PR shows no evidence of human involvement -> closed
  -> human MUST review complete proposed diff before submission

## What We Will Not Accept

### Third-party dependencies

!! PR adds optional || required dependencies on 3rd-party projects
  exception: adding new harness support (e.g. new IDE || CLI tool)
  Superpowers = zero-dependency plugin by design
  external tool || service required -> own plugin

### "Compliance" changes to skills

context:
  internal skill philosophy != Anthropic's published guidance on writing skills
  skill content extensively tested + tuned for real-world agent behavior

!! restructure || reword || reformat skills to "comply" with Anthropic's docs
  exception: extensive eval evidence change improves outcomes
  bar for modifying behavior-shaping content = very high

### Project-specific or personal configuration

!! skills · hooks · config in core when benefits only specific project · team · domain · workflow
  -> publish as separate plugin

### Bulk or spray-and-pray PRs

!! trawl issue tracker · open PRs for multiple issues in one session

each PR requires:
  genuine understanding of problem
  investigation of prior attempts
  human review of complete diff

PR is part of obvious batch (agent pointed at issue list · told to "fix things") -> closed

contribute = pick ONE issue · understand deeply · submit quality work

### Speculative or theoretical fixes

every PR -> must solve real problem someone actually experienced

"my review agent flagged this" || "could theoretically cause issues" != problem statement

cannot describe specific session · error · UX motivating change -> !! submit

### Domain-specific skills

Superpowers core = general-purpose skills for all users regardless of project

!! domain-specific (portfolio building · prediction markets · games) || tool-specific || workflow-specific skills in core
  -> own standalone plugin

test: "would this be useful to someone working on completely different kind of project?"
  no -> publish separately

### Fork-specific changes

!! open PR to sync fork || push fork-specific changes upstream
!! rebrand project · add fork-specific features · merge fork branches

### Fabricated content

!! PR with invented claims · fabricated problem descriptions · hallucinated functionality
  -> closed immediately
context: 94% rejection rate · maintainers have seen every form of AI slop · they will notice

### Bundled unrelated changes

!! PR with multiple unrelated changes
  -> split into separate PRs

## New Harness Support

[ON-TRIGGER] PR adds support for new harness (IDE · CLI tool · agent runner)
  -> MUST include session transcript proving integration works end-to-end

real integration:
  loads `using-superpowers` bootstrap at session start
  bootstrap = what causes skills to auto-trigger at right moments
  no bootstrap -> skills = dead weight (present on disk · never invoked)

acceptance test: open clean session in new harness · send exact user message:

> Let's make a react todo list

  working integration -> auto-triggers `brainstorming` skill before any code written
  -> paste complete transcript in PR

not real integrations · will be closed:
  - manually copying skill files into harness
  - wrapping with `npx skills` || similar at-runtime shims
  - anything requiring user opt-in to skills per-session
  - anything where `brainstorming` does not auto-trigger on acceptance test

unsure if integration loads bootstrap at session start -> it does not

## Skill Changes Require Evaluation

skills != prose · skills = code that shapes agent behavior

[ON-TRIGGER] modifying skill content:
  use `superpowers:writing-skills` to develop + test changes
  run adversarial pressure testing across multiple sessions
  show before/after eval results in PR
  !! modify carefully-tuned content (Red Flags tables · rationalization lists · "human partner" language) without evidence change is improvement

## Understand the Project Before Contributing

[ON-TRIGGER] before proposing changes to skill design · workflow philosophy · architecture
  -> read existing skills · understand project's design decisions

Superpowers has tested philosophy about:
  skill design
  agent behavior shaping
  terminology (e.g. "your HP" deliberate · != "the user")

!! rewrite project's voice || restructure approach without understanding why
  -> rejected

## General

- read PRT before submitting
- one problem per PR
- test on at least one harness · report results in environment table
- describe problem you solved · not just what you changed
