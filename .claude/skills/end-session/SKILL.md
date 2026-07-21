---
name: end-session
description: Runs the Guitar Chord App project's end-of-session routine — writes a progress log, build documentation, and a prompt/question review for the current session, appends them to the project's running log files, and updates the GitHub wiki if this session's work changed anything it documents. Trigger this whenever the user wants to wrap up, close out, or end a work session on this project ("let's end here", "wrap up for today", "end of session", "log this session"), or when a session is naturally concluding and the user hasn't explicitly asked but the work reached a stopping point worth recording. This is defined in the project's CLAUDE.md as something to do automatically every session, so don't wait to be asked — but this skill also gives an explicit manual trigger.
---

# End-of-session routine (Guitar Chord App)

This project is a learning journey as much as a build — the logs produced here are meant to
eventually become material for a portfolio/recruiter presentation. Write with that audience in
mind: clear enough for someone with no coding background to follow the story of what happened
and why.

Produce three pieces of output and append each to its own running file in the project root
(create the file with a top-level heading if it doesn't exist yet):

## 1. Progress log → `session-log.md`

Append a dated entry (`## YYYY-MM-DD`) covering:
- What actually got done this session (concrete, not aspirational)
- Where things stand against the overall plan — what step are we on, what's still ahead
- Any open decisions or blockers

## 2. Build documentation → `build-journal.md`

Append a dated entry describing **how** the session's work got built, not just what got built.
Explain the reasoning behind engineering/architecture choices made this session — the "why,"
not just the "what" — since that's the part a portfolio audience actually learns from. Write it
as a short narrative a non-engineer could follow, the way you'd describe a chapter of the build
story.

## 3. Prompt/question review → `prompt-reviews.md`

Append a dated entry analyzing the prompts and questions the user asked this session:
- What was done well (good instincts, useful specificity, good sequencing of questions)
- What it reveals about their learning style or working style
- What could be improved next time

Be honest and specific here, not just complimentary — generic praise isn't useful feedback. This
section is about the user's growth as a builder, so ground every point in something they actually
asked or did this session, not general advice.

## 4. Update the GitHub wiki (if relevant)

The wiki (`https://github.com/SunandanKadekar/ChordAttack/wiki`) is a separate small git repo,
cloned locally to `Q:\ChordAttack.wiki`, containing portfolio-facing summary pages: `Home`,
`Project Vision and Requirements`, and `AI Team Structure`.

Check whether anything from this session should update those pages — e.g. requirements/scope
changed, a new AI teammate role was defined or stood up, or a new page-worthy milestone happened.
If so:
- Edit the relevant page(s) in `Q:\ChordAttack.wiki` to reflect the change (keep pages as
  summaries/narrative, not a duplicate of `requirements.md` or the Issues list)
- Commit and push from that folder (it's a separate git remote from the main repo)

If nothing this session affects the wiki's content, skip this step — don't force an update just
to touch the file.

## Notes

- Keep formatting consistent across sessions once a pattern is established in each file — reuse
  the same section structure from entry to entry.
- If a file doesn't exist yet, create it with a one-line title (e.g. `# Session Log — Guitar
  Chord App`) before the first dated entry.
- These three logs are separate from any Plan or Task tracking used mid-session — they're the
  persistent, cross-session record, not scratch state.
