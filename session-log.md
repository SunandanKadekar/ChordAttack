# Session Log — Guitar Chord App

## 2026-07-21

**What got done:**
- Stood up the PM agent and ran full requirements discovery across two rounds of Q&A (chord shapes/variety/capo, offline support, the progression-generator idea, Azure budget, accessibility) — produced and iterated `requirements.md`.
- Decided to track all project work as GitHub Issues (not Azure DevOps Boards). Created a GitHub account, connected the local project folder to a new repo (`git init`, `.gitignore`, fixed commit identity to a personal email instead of a work email), and pushed the first commit.
- Learned GitHub Issues basics (what a ticket is, what makes a good one) and used that to draft, review, and create the first batch of 14 tickets: 8 for v1 MVP (#1–8, in dependency order) and 6 for the future backlog (#9–14, including Android and Windows clients).
- Caught a gap: the work of building the AI team itself wasn't being tracked. Added an `ai-team` label, backfilled two closed tickets for work already done (#15 PM agent standup, #16 GitHub ticketing setup), and opened #17 as the next organizational milestone (defining the architecture/backend agent).
- Set up a GitHub wiki with three pages: Home, Project Vision and Requirements, and AI Team Structure.
- Expanded the PM agent from "requirements discovery only" to five jobs: discovery, project planning, status reporting, backlog prioritization, and feature spec writing — deliberately keeping user research, competitive analysis, KPIs, and go-to-market out of scope for now, and deliberately not giving it direct GitHub access yet.
- Updated the wiki's AI Team Structure page to reflect the expanded PM scope and added a section explaining how the founder, main assistant, and subagents divide work.
- Built and published a scrollable "founder briefing" web deck (vision → product scope → operating model → PM agent → current status → what's next) as a shareable Claude Artifact.

**Where things stand against the overall plan:**
- Requirements discovery — **done**.
- Initial process/tooling setup (ticketing, wiki, org-work tracking) — **done**.
- Next step: standing up the architecture/backend agent to turn `requirements.md` into a real data model and API design (tracked as #1 and #17) — **not started**.
- No product code has been written yet — the project is still fully in the planning/setup phase.

**Open decisions / blockers:**
- Azure budget ceiling — undecided.
- Whether/when offline support becomes a real requirement — undecided.
- Build order between the progression generator and quiz mode — undecided.
- Concrete accessibility/performance targets — intent locked, specific numbers not set.
- Whether to give the PM agent direct GitHub access — deferred; founder may revisit later.

## 2026-07-22

**What got done:**
- Gave the PM agent its own GitHub identity: created bot account `pm-agent-chordattack` (dedicated email, added as a Write — not Admin — collaborator), worked through a real platform limitation (fine-grained PATs don't yet support outside collaborators picking a specific repo on someone else's personal account), and fell back to a classic PAT scoped to `public_repo` only, 180-day expiration, stored in a gitignored local file.
- Built `scripts/pm-agent-gh.sh`, restricting the PM agent to only `gh issue` subcommands, authenticated as the bot. Updated `.claude/agents/pm.md` accordingly. Verified end-to-end via GitHub's activity log and edit-history API — the bot shows as a distinct actor from the founder on real ticket actions.
- Created `status:new`/`status:in-progress`/`status:done` labels. PM agent used its new access to move a ticket's status and to fix a missing link in a closed ticket (#15).
- Established a standing rule — later broadened — that GitHub writes go through the PM agent's identity, not the assistant's.
- Set up a weekly automated status report: a claude.ai scheduled cloud routine (Fridays ~11:30am PDT) that reads the PM agent's own Job 3 criteria, gathers live ticket/log state, and drafts a Gmail email. Required connecting a Gmail MCP connector and the Claude GitHub App.
- Created a new wiki page, "Team and Processes" — an org chart plus a living table of standing team processes, meant as onboarding reference for future teammates, human or AI.
- Gave the PM agent wiki-write access (`scripts/pm-agent-wiki.sh`), a new Job 6 (review/update the team page when a process changes), and a skill that triggers that review automatically. Live-tested it successfully — the PM agent documented its own new capability under its own identity, and correctly left an unaffected row untouched.
- Caught and corrected a scoping gap: wiki-write access was initially usage-scoped to just the Team & Processes page; broadened the standing rule to cover all wiki writes, any page.
- Updated the founder deck twice (PM agent's GitHub identity track, then an "institutional memory" track), added a cover "last updated" date, and linked the deck from the wiki homepage.

**Where things stand against the overall plan:**
- AI-team process/tooling has moved from "set up" to "operating with real accountability infrastructure" — attribution, scoped credentials, and self-maintaining documentation are now real, tested mechanisms, not just descriptions.
- Still no product code written. Architecture/backend design (#1, #17) remains the next real milestone — #17 is now marked in progress.
- The weekly status report hasn't had its first live run yet (first fire: Friday, July 24) — worth checking in on then.

**Open decisions / blockers:**
- Resend (full email auto-send, no draft/review step) — deferred; Gmail-draft-and-review is the interim approach.
- Architecture/backend agent — still not started; now the clear next step for actual product progress.
- The Gmail connector's visibility to the scheduling backend was inconsistent during setup (repeatedly showed "not connected" even after confirmed connected in the UI, then worked anyway at creation time) — worth knowing if similar connector-sync issues recur.
