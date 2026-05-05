# Marketing TODO — Adoption, Not Money

The goal is **usage**, not revenue. People install BOTSPEAK because it makes their AI faster and cheaper, and they tell other people because it worked.

This file is a checklist for the launch and the first few weeks. Nothing here is automated; pick what you want to do and do it manually, or hand the items to someone you trust.

---

## Pre-launch (do before pushing to GitHub)

- [ ] Create the `botspeak` repo on GitHub under your account or a new org. Choose `botspeak` as the name (matches the language; `botspeak` is a legacy local folder name).
- [ ] Replace `itaki` placeholders in `README.md` and `install.sh` with the real GitHub path.
- [ ] Verify `install.sh` works on a clean macOS install. Verify it works in WSL. Note any failures and fix.
- [ ] Verify the install detects all five tools listed: Claude Code, Cursor, Codex, Gemini CLI, generic `~/.agents`. If any are missing, add them to `install.sh`.
- [ ] Run a real before/after on your own `CLAUDE.md` and add the result as `examples/06-real-claude-md/` so people see your own dogfooding.
- [ ] Set the repo description to something punchy: "A language for bots to talk to bots. Cuts ~60% of input tokens from the docs your AI reads every session."
- [ ] Pick three topics: `ai`, `claude`, `prompt-engineering`, `tokens`, or similar — the highest-trafficked tags on relevant searches.

## Launch day (sequential, lowest-risk first)

- [ ] **Hacker News** — submit with title "BOTSPEAK – A language for AI agents to talk to other AI agents". Best time: Tuesday or Wednesday morning Pacific. Be present in comments to answer questions for the first 4 hours; this is the single biggest determinant of whether a launch lands.
- [ ] **r/ClaudeAI** subreddit — post with a clear before/after table from the README.
- [ ] **r/cursor** subreddit — same, but emphasize the `.cursor/rules/botspeak.mdc` always-on rule.
- [ ] **r/LocalLLaMA** — emphasize the ASCII dialect and that BOTSPEAK works on local models too (Llama, Mistral, Qwen).
- [ ] **Twitter/X thread** — 5-tweet thread:
  1. Hook: "Your CLAUDE.md is 800 tokens. Your AI reads it every session. A human reads it once."
  2. The before/after table as an image.
  3. The `@defs` alias example.
  4. The `/translate-botspeak` round-trip safety pitch.
  5. Install one-liner + repo link.
- [ ] **Discord servers**: Cursor's, Anthropic Builders, OpenAI Codex, n8n. Post in the #showcase or #share channels with the same hook + repo link. Don't spam.

## Post-launch outreach (week 1-2)

- [ ] Email Julius Brussee (Caveman maintainer) — frame BOTSPEAK as the input-side complement to Caveman's output-side work. Ask if he wants to cross-link in the Caveman README's ecosystem section.
- [ ] Email Andrej Karpathy (LLM wiki author) via the Tesla/personal address you can find. Frame BOTSPEAK as the "denser wiki page" he hinted at being needed. Karpathy retweets things he likes. Even a non-response is fine.
- [ ] Open a PR or issue against `Ar9av/obsidian-wiki` proposing BOTSPEAK as the recommended page format for non-human-facing wiki entries.
- [ ] Open a PR against `awesome-claude-code` adding BOTSPEAK to the skills section.
- [ ] Open a PR against `awesome-cursor-rules` adding the `.cursor/rules/botspeak.mdc`.
- [ ] Open a PR against any "awesome agent skills" lists.

## Content (post-launch, weeks 2-6)

- [ ] One blog post: "I cut my Claude bill by 56% by writing my CLAUDE.md in BOTSPEAK". Real numbers from your own usage. Post on dev.to, Medium, and personal blog if you have one.
- [ ] One YouTube short or Loom video: 90-second walkthrough of the `/capture-botspeak` workflow on a real chat conversation. Show the messy input, show the clean BOTSPEAK output, show the round-trip translate.
- [ ] One short for r/ChatGPTCoding showing the cross-tool benefit (works in GPT, not just Claude).

## Maintenance / community (ongoing)

- [ ] Triage GitHub issues weekly. Most issues will be "tool X isn't supported" — easy fixes.
- [ ] Update `CHANGELOG.md` for every release.
- [ ] Tag stable releases (`v0.2.0`, `v0.3.0`) so people can pin.
- [ ] Add a `BENCHMARKS.md` once you have community-contributed token counts on more file types.

## Things NOT to do

- Don't pay for ads. The product is small and free; paid ads will look weird.
- Don't run a Substack newsletter. The repo is the product; updates go in CHANGELOG.
- Don't accept sponsorships before there's actual usage. Premature monetization kills early-stage open source.
- Don't add a Discord server until you have >100 stars. A dead Discord is worse than no Discord.
- Don't accept "rebrand" or "white-label" requests. The point is a single shared convention.

## Success metrics (be honest with yourself)

- **Week 1**: 100 stars, 5 issues, 1-2 PRs, ≥1 mention from someone with a real audience.
- **Month 1**: 500 stars, 20 issues, real adoption signals (people referencing BOTSPEAK in unrelated repos' rules).
- **Month 3**: 2,000+ stars, ecosystem cross-links from Caveman / obsidian-wiki / similar projects.
- **Month 6**: BOTSPEAK is one of the answers when someone Googles "how do I reduce CLAUDE.md tokens".

If month 1 isn't hitting these numbers, the launch didn't land. Try a different angle (different sub, different blog post, different audience) before giving up.
