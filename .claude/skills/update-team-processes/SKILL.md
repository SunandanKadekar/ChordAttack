---
name: update-team-processes
description: Reviews and updates the ChordAttack wiki's Team and Processes page (org chart, roles table, processes table) whenever a new team process is established or an existing one changes during a session — e.g. a new standing practice, a tool-access or scope change for an existing role, a new automation, or a new role/teammate added. Trigger this automatically whenever such a change happens in a session, without waiting to be asked, the same way the end-session routine is auto-triggered. Delegates the actual review/edit to the PM agent, which is the only one that writes to this page. If nothing about team structure or process actually changed this session, this should end in a no-op — don't force an update just to touch the file.
---

# Update Team & Processes (Guitar Chord App)

Whenever this session establishes a new team process, changes an existing one, or adds/changes a
role on the team, delegate a review of the wiki's `Team-and-Processes.md` page to the `pm` subagent
(its Job 6: Team & process documentation maintenance) — don't wait for the founder to ask.

## When to trigger

Examples of session events that should trigger this:
- A new standing practice gets established (e.g. the weekly status report routine)
- Tool access or scope changes for an existing role (e.g. granting the PM agent a new write path)
- A new role or teammate is added to the org chart
- An existing process's mechanics change (its schedule, owner, or where it's defined)

Routine day-to-day work — writing code, answering a question, editing a single ticket, a normal
status report — does **not** trigger this. This is about changes to *how the team operates*, not
the team's regular output.

## What to do

Invoke the `pm` subagent for Job 6: review `Team-and-Processes.md` against what changed this
session, update the org chart / roles table / processes table only if warranted, and commit+push
its own edit via its wiki wrapper script if it made one.

If the PM agent determines nothing needs to change, that's a valid, expected outcome for most
sessions — don't push it to make a change anyway just because this skill fired.

Report back to the founder briefly either way: what changed (if anything), or that a review
happened and no update was needed.
