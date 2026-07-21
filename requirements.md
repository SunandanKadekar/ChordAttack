# Guitar Chord App — Requirements

Captured via PM requirements-discovery interview, 2026-07-21. This is the foundation for
architecture and build decisions — revisit and update it if the vision changes.

## 1. Users & Purpose

Primary goal: a **portfolio/demo piece first**, real usage second. The value of the project is
demonstrating the ability to take an idea from concept to a fully shipped, real-world-style
product (real backend, multiple clients, cloud hosting) — and to document that journey for
recruiters. Real-world usage by other guitarists is a nice-to-have, not the primary driver of
scope.

**Implication:** favor decisions that make the *build story* clear and demonstrable (clean
architecture, explainable choices, visible polish) over decisions that would only matter for
large-scale real-world traffic.

## 2. Content Scope (v1)

**Guitar only.** No ukulele or bass in v1. This keeps the initial data model and diagram
rendering simpler; other instruments are a possible future expansion, not a v1 commitment.

Data source: existing research already identified free, open-source chord datasets (e.g.
`chords-db` on GitHub) as the plan — import into the app's own database rather than depending on
a live third-party API, consistent with the "real backend, own your data" architecture goal.

**Chord shapes/voicings:** v1 supports **multiple shapes per chord** — e.g. an open-position
version of C major *and* an alternate position further up the neck — not just one default shape
per chord. This is deliberate v1 scope, not deferred, so the data model and diagram UI need to
support "one chord, many playable shapes" from the start.

**Chord type breadth:** v1 covers a **medium-sized set** of chord types per root note:
- Basics: major, minor, 7th (dominant 7th)
- Plus: sus2, sus4, diminished, augmented, major 7th, minor 7th

Explicitly **not** in v1: the full breadth of exotic/extended chord types available in datasets
like `chords-db` (e.g. 9ths, 11ths, 13ths, altered jazz chords). That full breadth is a possible
future expansion, not a v1 commitment.

**Capo positions:** **Deferred, not in v1.** Showing "how to play this shape with a capo on fret
X" is a real feature idea but adds complexity that isn't needed to hit the v1 bar.

## 3. Platform Priority

All three platforms (Windows desktop, Android, web) are committed per the project's core vision.
**Web ships first.** Fastest to build/demo, easiest to share a link, no app-store approval
process. Android and Windows follow once the web app and backend are proven out.

## 4. MVP Definition (v1 "shipped" bar)

v1 includes:
- Browse and search the chord library
- View chord diagrams (finger positions), including multiple shapes per chord (see Content Scope)
- **User accounts with saved/favorite chords** (chosen deliberately for v1, not deferred —
  demonstrates real auth/backend depth for the portfolio)
- **Accessibility and performance as explicit, demonstrable v1 qualities** (see Non-Functional
  Requirements) — intentionally built and shown off, not an afterthought

**Not in v1 (explicitly deferred):** audio playback, capo positions, the mood/scale-based chord
progression generator, and practice/quiz mode — see Future Features below.

## 5. Future Features (post-v1)

- **Audio playback** of chord sounds (already committed in CLAUDE.md as a known future feature —
  intentionally not in v1, so it doesn't block getting v1 shipped).
- **Mood/scale-based chord progression generator** (a more specific vision than a generic "song
  mode"): the user picks a mood (e.g. happy, dark, sad) or a musical scale (e.g. major scale,
  minor scale), and the app **generates** a chord progression that fits — implying real
  music-theory rules/logic behind it, not just displaying a fixed list of pre-written
  progressions for known songs. This has a real backend implication: it likely needs
  music-theory reference data and generation logic, worth knowing about before the data layer is
  finalized, even though it won't be built for v1.
- **Practice/quiz mode** — testing chord shape or note recognition. Wanted as its own separate
  feature alongside (not instead of) the progression generator.
- **Capo positions** — showing alternate ways to play a chord shape with a capo (deferred from
  v1, see Content Scope).
- (User accounts/favorites were originally floated as "future" but got pulled into v1 scope —
  see MVP section above.)

Both the progression generator and quiz mode are confirmed as wanted, and both come after audio
playback in sequence — but their relative order versus each other is not yet decided (see Open
Questions).

## 6. Non-Functional Requirements

- **Connectivity:** v1 is **always-online** — clients call the backend API live, no offline
  caching required. This simplifies each client significantly.
  - **Flagged for later, genuinely undecided:** the builder is not sure whether offline support
    (viewing chords without an internet connection) will become a real requirement. It should be
    kept in mind as a possible future need when the data layer is designed (so adding it later
    isn't prohibitively expensive), but it should **not** be actively designed around or built
    for in v1.
- **Accessibility and performance are explicit v1 requirements**, not deferred — the builder wants
  these called out and demonstrated as portfolio-facing engineering skills. Concretely this means
  things like: usable with a screen reader, reasonable color contrast/keyboard navigation, and
  fast page/app load times. Specific measurable targets (e.g. a formal accessibility standard, a
  load-time number) have not been set yet — treat "demonstrably accessible and fast" as the v1
  bar until more specific targets are defined during design/build.
- Expected user scale was not specified — reasonable given the portfolio-first purpose (see
  Users & Purpose); treat as low-priority/not a design driver for v1.

## 7. Constraints

- **No hard deadline.** This is a self-paced learning project — prioritize understanding and
  quality of the learning narrative over speed of delivery.
- **Azure budget:** not yet decided. The builder has no ceiling in mind yet and wants to figure
  this out as the build progresses rather than fixing a number now. Flagged as open —
  architecture choices should be mindful that no budget number exists yet, and
  cheaper/free-tier-friendly options should probably be favored by default until a real budget
  conversation happens.

## 8. Success Criteria

v1 is successful if **all three** of these are true:
1. It actually works end-to-end across all three platforms (web, Android, Windows).
2. The builder understands and can explain *why* every major decision was made — not just what
   was built.
3. It's polished enough to show in a portfolio/interview setting (this now explicitly includes
   accessibility and performance as things worth showing off, not just visual polish).

## Open Questions (explicitly unresolved — don't silently decide these later)

- **Offline support:** genuinely undecided whether/when this becomes a real requirement. Keep it
  in mind during data-layer design as a possible future need, but don't build for it in v1.
- **Progression generator vs. quiz mode ordering:** both are confirmed future features (after
  audio playback), but which gets built first is not yet decided.
- **Azure budget ceiling:** not yet decided — revisit once the build is further along and real
  cost estimates exist.
- **Specific accessibility/performance targets:** the *intent* to demonstrate these is confirmed
  for v1, but concrete measurable targets (e.g. specific load-time goals, a formal accessibility
  standard like a WCAG level) have not been set — worth defining during design.
