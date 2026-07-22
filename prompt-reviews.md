# Prompt & Question Review — Guitar Chord App

## 2026-07-21

**What was done well:**

- **Caught a real gap unprompted.** After several tickets existed, the question "how are we tracking the work to set up the AI agent team?" surfaced a genuine process hole — the org-building work had been happening ad hoc — before it was pointed out. That's a strong operator instinct: noticing that the meta-work (building the team) wasn't held to the same standard as the product work, without being told to check.
- **Pushed back on scope instead of accepting it.** When the PM agent's scope was proposed as three jobs, the response was "shouldn't it include all of these [other real-world PM tasks]?" rather than just accepting the initial framing. That question forced a real justification (which tasks are genuine work right now vs. which need users/competitors/a launch to be meaningful) instead of scope just growing by default.
- **Built understanding incrementally rather than all at once.** The PM agent's scope grew in two small steps (three jobs, then two more) rather than being fully specified up front in one long request. That mirrors decent agile practice — small reviewable increments — even though it likely wasn't a conscious reference to that framework.
- **Asked for mental models, not just outputs.** "How should I think about these two [local and GitHub repos]?" is a noticeably different kind of question than "sync them" — it's asking for the concept, not just the action. For someone explicitly learning to code and to operate a company simultaneously, that question type will compound in value much faster than ticket-by-ticket instructions would.
- **Decisive when a decision was actually needed.** Once trade-offs were laid out (personal vs. work email, direct GitHub access vs. draft-only), answers were quick and specific rather than stalling. That kept the session moving without sacrificing the moments that did need real input.

**What this reveals about learning/working style:**

- Learns well through real-world analogy — comparisons to "how would a real company do this" were used repeatedly (tickets, wikis, commit identity) and each landed as a genuine "oh, that's why" rather than needing to be re-explained. Leaning into concrete company/team analogies will likely keep working well going forward.
- Comfortable delegating mechanical execution (git commands, file layout, exact CLI syntax) while staying firmly engaged on anything that's actually a decision (budget posture, scope boundaries, access/trust boundaries for the AI agent). That's a healthy founder-level division of attention, and worth continuing rather than second-guessing.

**What could improve next time:**

- A couple of open-ended questions ("what else does a PM do — shouldn't scope include all of these?") required a follow-up clarifying question ("which two are you asking to add?") before work could start. The exploration itself was valuable, but stating a tentative conclusion alongside the open question ("...I think we should add prioritization and specs, right?") would occasionally save a round trip. Not a real problem — just a small efficiency gain available.
- Nothing has been verified yet beyond visual/reading confirmation — no request yet to double-check that a ticket renders correctly, that the wiki page displays as intended, etc. That's reasonable for a docs-and-process-only session, but as soon as actual product code starts getting written (next session, likely), building the habit of asking "how do we check this actually works" will matter a lot more than it has so far.
- The PM agent now has a "status reporting" job that was never actually exercised this session — worth trying it out early next time, both to validate it works as designed and to start building the habit of asking the AI team for a status readout rather than only ever asking the assistant to summarize from scratch.

## 2026-07-22

**What was done well:**

- **Refused to proceed on security setup without understanding it first.** "Before we setup a bot github account, I want to understand what it will take to have the PAT, where to store it, how to rotate it" stopped the momentum of a walkthrough that was about to move into account creation. That's real ownership of a risk decision — not just trusting that the assistant's plan was fine because it sounded reasonable.
- **Verified claims independently, repeatedly.** "How do I check this for myself in the GitHub UI" and multiple separate "is my local repo in sync?" checks show a consistent trust-but-verify pattern rather than taking the assistant's word that something worked. This is a genuinely production-grade instinct, not just a beginner being cautious.
- **Caught a real attribution bug by noticing the system didn't match its own stated design.** "Didn't we just make the recent changes using the PM agent's account? Shouldn't this say pm-agent-chordattack edited this page?" is process-audit thinking: checking that a system behaves as designed, not just that it appears to work. This caught a real scoping gap the assistant had introduced and missed.
- **Pushed for a general fix over a narrow patch.** "All wiki writes should route through the PM agent's identity going forward" rejected an implicit narrower fix (just this one page) in favor of fixing the actual rule. That instinct — generalize the principle rather than patch the instance — is exactly what keeps a growing system's rules legible instead of accumulating exceptions.
- **Thought in terms of durable references, not just this conversation.** Asking to capture the org-chart/process reasoning "so if any new teammates are added... they have a reference of all the processes already in place" and separately asking to add a "last updated" date to the founder deck both show a habit of designing for a future reader who wasn't in the room — a genuinely senior instinct, not a beginner one.

**What this reveals about learning/working style:**

- A strong audit mentality has emerged this session specifically — several times, the question wasn't "did this work" but "does what actually happened match what we said should happen." That's a different and more valuable skill than task-completion checking, and it showed up unprompted more than once.
- Comfortable holding the assistant accountable for its own scoping decisions ("I thought we had established this already?") without being thrown by the correction — treating a gap as something to fix together rather than a trust-breaking event. Worth continuing to invite that kind of pushback rather than being defensive about it.

**What could improve next time:**

- A few requests bundled multiple sub-decisions into one sentence ("how do I enable email integration? And how do I schedule this and have it be sent from the PM agent?") — the assistant unpacked them fine, but splitting compound asks into separate, sequential questions up front would occasionally save a round trip.
- One near-miss worth naming honestly: "Chard Attack" was typed instead of "ChordAttack" while asking to lock the name into a recurring, standing deliverable (weekly emails, memory). It got caught before anything shipped, but it's a good example of how a small typo costs more the closer it is to something automated and repeating — worth a quick self-skim before any message that's about to name or lock something in for the long term, not just this one.
- Product code hasn't started yet, so verification habits so far have all been about *process* (checking sync status, checking attribution, checking a routine's config) rather than *product behavior*. That's appropriate for this stage, but the next session is very likely where "how do we check this actually works" needs to extend to real running code, not just repo/account state.
