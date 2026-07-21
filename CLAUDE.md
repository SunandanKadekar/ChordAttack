# Project: Guitar Chord App

## What this project is
A personal project to take an idea from concept to a **fully shipped product**, built the way a real software company would — and to document the process as a learning journey / portfolio piece for a resume.

The builder is a **total beginner at coding**. Explanations, pacing, and decisions should account for that — don't assume prior software engineering background.

## The product
An app that captures different guitar chords and how to play each one.

- **Platforms:** Windows desktop app, Android app, and a web app — all three, similar to how Uber or Claude ship across platforms.
- **Architecture:** A real backend — a shared API serving all three clients — following actual industry practice. Not a minimal/fewest-moving-parts setup. The point of this project is to demonstrate real practices, so don't simplify away the backend.
- **Hosting:** Azure.
- **Known future feature:** users should be able to hear audio of what a selected chord sounds like.

## Process principles
- Capture the **full product vision and requirements — including future features — before locking in architecture**, so the design isn't built around an incomplete picture.
- Use a mix of Claude chat and Claude Code as needed throughout.
- This is a learning exercise as much as a build — explain the "why" behind engineering decisions along the way, not just the "what."

## The AI "team" concept
The builder wants to run this project like a startup where AI agents are teammates alongside humans. Scope, as agreed:
1. **Internal use** — AI teammates that help build/run the project itself (e.g., an AI "engineer" or "designer" persona to chat with to get work done).
2. **Org design as a showcase** — designing the roles/structure of an AI+human team as a demonstration piece, not necessarily every role being fully functional.

Agreed approach:
- Start with **Claude Code subagents** (shared agent role definitions humans interact with directly through Claude Code) rather than building a dedicated chat app first.
- Future feature (not yet started): ability to chat with these subagents via something like Slack or Teams.
- **Immediate next step:** stand up just a **PM agent** first to run requirements discovery. Define the rest of the AI team's roles based on what that discovery actually produces — don't pre-design the full team before that.

## End-of-session routine (do this every session, unmodified — no need to be asked)
At the end of every working session in this project, produce three things:

1. **Progress log** — what actually got done this session, and where things stand against the overall plan (what step we're on, what's left).
2. **Build documentation** — how we went about building what we built this session, written with an eye toward eventually becoming a presentation for recruiters about the learning journey.
3. **Prompt/question review** — analyze the prompts and questions asked this session: what was done well, what it reveals about learning style, and what could be improved. Be honest and specific, not just complimentary.

Append these to a running log in this project folder (suggest: `session-log.md`, `build-journal.md`, and `prompt-reviews.md`, or similar — keep format consistent once started).

## Notes for whoever (human or AI) picks this up
- Don't assume the reader has coding background — this file and the docs it produces may end up in a portfolio presentation.
- If architecture or scope decisions come up that touch the principles above, flag the tension explicitly rather than silently deciding.
