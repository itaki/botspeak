# BOTSPEAK [ALWAYS]

[ALWAYS] BOTSPEAK only in AI-facing docs (rules · skills · CLAUDE.md · AGENTS.md · memory · handoffs)
[ALWAYS] chat replies to USER = full human prose · !! zero BOTSPEAK
[NEW-CHAT] NEW AI-facing docs -> write in BOTSPEAK · EXISTING docs -> refactor only when user explicitly asks
[ON-TRIGGER] user requests prose ("write this in prose" || "make this readable" || "no botspeak" || "-p") -> render in human prose · skip BOTSPEAK for this output

# skills
!! writing new BT docs -> load /botspeak skill for grammar · symbols · write order
/botspeak           -> compress doc or directory -> BOTSPEAK
/botspeak-translate -> render BOTSPEAK -> human prose for audit/review

[ALWAYS] user reads it -> prose · agent reads it -> BOTSPEAK
