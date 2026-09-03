# ChordAttack — Backend Architecture (v1)

Written by the architect agent, closing out ticket #1 (data model & API design) and ticket #17
(standing up the architect role). This document turns `requirements.md` into a concrete backend
design: what data we store, how clients talk to the server, what the server is built with, and
where it runs on Azure.

## 0. How to read this document, and a process note

Normally, several of the decisions below (REST vs. GraphQL, SQL vs. NoSQL, which backend
framework, which Azure tier) are exactly the kind of "reasonable people could disagree, the
founder's preference should decide" calls that are supposed to go back to you as a direct question
before being locked in. In this run, the interactive question tool wasn't available to me inside
this session, so instead of leaving those sections blank, I made a concrete, reasoned call on each
one so you have a complete design to react to rather than a half-finished one.

**Every decision below is a proposal, not a ruling.** Section 7 (Open Questions) lists the ones
most likely to be worth a second look — especially the backend framework choice, which has a real
learnability-vs-industry-realism tension I'm not comfortable resolving silently. Read the PR,
leave comments on anything you'd call differently, and I'll push a follow-up revision to the same
PR (that's what `architect-agent-pr-update.sh` is for) rather than you having to redo this by hand.

---

## 1. Data Model

### Why this shape

The core insight driving this model: **a chord is not one diagram, it's a family of diagrams.**
Per requirements.md §2 ("v1 supports multiple shapes per chord... this is deliberate v1 scope, not
deferred"), `ChordShape` is modeled as its own table with a foreign key back to `Chord`, not as a
repeated field on the chord itself. This is what lets "C Major, open position" and "C Major, barre
at fret 3" both exist as first-class, independently-editable records under the same chord.

### Entities

**`Chord`** — one row per (root note, chord type) combination, e.g. "C Major", "F# Diminished".

| Field | Type | Notes |
|---|---|---|
| `id` | int, PK | |
| `rootNote` | enum | A, A#, B, C, C#, D, D#, E, F, F#, G, G# — per requirements.md §2 |
| `chordType` | enum | major, minor, dominant7, sus2, sus4, diminished, augmented, major7, minor7 — the exact v1 list from requirements.md §2 |
| `displayName` | string | e.g. "C Major" — precomputed for easy display/search, avoids recomputing from the two enum fields on every request |
| `slug` | string, unique | e.g. `c-major` — human-readable URL/lookup key, useful for a future web app route like `/chords/c-major` |

Unique constraint on (`rootNote`, `chordType`) — there's exactly one "C Major" chord record; its
multiple *playable versions* live in `ChordShape` below.

**`ChordShape`** — one row per playable voicing of a chord.

| Field | Type | Notes |
|---|---|---|
| `id` | int, PK | |
| `chordId` | FK → `Chord` | |
| `label` | string | e.g. "Open Position", "Barre (A-shape), 3rd fret" — shown to the user so they can tell shapes apart |
| `displayOrder` | int | which shape shows first (open position before barre versions, generally) |
| `baseFret` | int | which fret the diagram window starts at, for shapes played up the neck |
| `frets` | string/array, 6 entries | one per guitar string, low-E to high-E; `"x"` = muted, `0` = open, else fret number. e.g. `["x", 3, 2, 0, 1, 0]` for open C |
| `fingers` | array, 6 entries, nullable | which finger plays each string, for the diagram's finger-position labels |
| `barres` | array, nullable | which fret/string-range is barred, for barre chords |
| `audioUrl` | string, nullable | **not populated in v1** — see "Future hooks" below |

Guitar-only per requirements.md §2 ("Guitar only. No ukulele or bass in v1"), so a fixed 6-string
array is fine for now; it's not modeled as a generic N-string structure because that generality
isn't needed yet and would just be speculative complexity.

**`User`**

| Field | Type | Notes |
|---|---|---|
| `id` | int, PK | |
| `email` | string, unique | login identifier |
| `passwordHash` | string | never store plaintext passwords — see API/auth section |
| `createdAt` | datetime | |

**`Favorite`** — join table between `User` and `Chord`, per requirements.md §4 ("User accounts
with saved/favorite chords").

| Field | Type | Notes |
|---|---|---|
| `id` | int, PK | |
| `userId` | FK → `User` | |
| `chordId` | FK → `Chord` | |
| `favoritedAt` | datetime | |

Unique constraint on (`userId`, `chordId`) so a user can't double-favorite the same chord.
**Design call:** favorites are on the *chord*, not a specific shape — you favorite "C Major", not
"C Major, open position specifically." This matches how requirements.md §4 talks about favorites
("saved/favorite chords") and keeps the UI simpler; a shape-level favorite would be easy to add
later (same pattern, FK to `ChordShape` instead) if that turns out to matter.

### Future hooks — deliberately not built now

Per the ticket instructions, these get a foreign key or an obvious attachment point, not their own
tables yet:

- **Capo positions** (requirements.md §5) — no field added anywhere for this. `ChordShape.id`
  already exists as a primary key, so a future `CapoVariant` table can simply add
  `chordShapeId FK → ChordShape` and store "same shape, capo on fret 2, resulting sound." Nothing
  in today's model needs to change to allow that later.
- **Audio playback** (requirements.md §5, also called out in CLAUDE.md as a known future feature)
  — `ChordShape.audioUrl` exists today as a nullable field, unpopulated in v1. When audio is
  built, it's a matter of uploading files (likely to Azure Blob Storage) and filling in that
  column — no schema change needed.
- **Mood/scale progression generator** (requirements.md §5) — this needs music-theory reference
  data (scales, moods, chord-progression rules) that is conceptually *separate* from the chord
  library itself — a scale isn't a chord. The hook is that a future `Progression` table would
  store an ordered list of `Chord.id` references (a generated progression is, in the end, a
  sequence of chords), while the music-theory rules that decide *which* chords fit a mood/scale
  live in their own new tables, not bolted onto `Chord`. Not built now.
- **Quiz mode** (requirements.md §5) — hooks off `User.id` and `Chord.id`/`ChordShape.id`, which
  already exist (a quiz question like "name this shape" or "play this chord" needs to reference
  existing chords/shapes and log attempts per user). Nothing to add today.
- **Offline support** (requirements.md §6, explicitly flagged open) — not designed for in v1 per
  requirements. Kept in mind: the model above is plain, flat, JSON-friendly data with no
  server-side session state baked into it, which is exactly what would make it *easy* to mirror
  into a local on-device cache later (e.g., a SQLite copy on Android). No decision made now beyond
  "don't paint yourself into a corner" — nothing here actively blocks it later.

---

## 2. API Contract

### REST, not GraphQL

**Decision: REST.**

Requirements.md §4 defines a v1 feature set that maps cleanly onto a small number of well-defined
resources: chords (with nested shapes), users, favorites. None of that needs GraphQL's core
selling point — letting the client ask for an arbitrary custom slice of deeply nested data in one
request. REST also has far more beginner-friendly documentation and tutorials, which matters given
CLAUDE.md's note that the builder is new to coding generally.

The counter-argument (and why this is flagged as revisitable, not closed): CLAUDE.md's vision is
three different clients (web, Android, Windows) potentially wanting slightly different shapes of
the same data, which is exactly the scenario GraphQL is good at. If that turns out to be a real
pain point once two or three clients exist side by side, GraphQL is worth revisiting then — this
isn't a one-way door, just not the right complexity to take on for v1.

### Auth: JWT bearer tokens, not server-side session cookies

Sign-up/login return a signed JSON Web Token (JWT). Every subsequent request that needs to know
who the user is (favorites) sends that token in an `Authorization: Bearer <token>` header.

**Why not cookie-based sessions** (the other common approach): sessions are a natural fit for a
single website, but this API is explicitly meant to serve a browser, an Android app, and a Windows
desktop app (CLAUDE.md, "Platforms" section) — two of those three aren't a web browser and don't
have a clean concept of "cookies." A bearer token is just a string each client stores and attaches
to requests, and it works identically regardless of platform. This is a case where the "real
practice" choice and the "works for our actual requirement" choice are the same choice, not a
trade-off.

Passwords are never stored directly — only a hash (specific hashing approach depends on the
framework decision in Section 3; both ASP.NET Core Identity and common Node/Python libraries
handle this with well-tested, secure defaults rather than something to hand-roll).

The API also needs CORS (Cross-Origin Resource Sharing) enabled, since the web client will be
running on its own domain and calling this API from browser JavaScript — a standard, small config
setting, called out here so it isn't a surprise later.

### v1 Endpoints

**Browse / search chords** (public, no auth)
```
GET /api/chords?root=C&type=major&q=&page=1&pageSize=20

200 OK
{
  "items": [
    { "id": 42, "rootNote": "C", "chordType": "major", "displayName": "C Major", "shapeCount": 2 }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 63
}
```

**Chord detail, with shapes** (public, no auth)
```
GET /api/chords/42

200 OK
{
  "id": 42,
  "rootNote": "C",
  "chordType": "major",
  "displayName": "C Major",
  "shapes": [
    {
      "id": 101,
      "label": "Open Position",
      "baseFret": 1,
      "frets": ["x", 3, 2, 0, 1, 0],
      "fingers": [null, 3, 2, null, 1, null],
      "barres": [],
      "audioUrl": null
    },
    {
      "id": 102,
      "label": "Barre (A-shape), 3rd fret",
      "baseFret": 3,
      "frets": [3, 3, 5, 5, 5, 3],
      "fingers": [1, 1, 3, 4, 2, 1],
      "barres": [{ "fret": 3, "fromString": 1, "toString": 6 }],
      "audioUrl": null
    }
  ]
}
```

**Sign up**
```
POST /api/auth/signup   { "email": "...", "password": "..." }
201 Created             { "token": "<jwt>", "user": { "id": 7, "email": "..." } }
```

**Log in**
```
POST /api/auth/login    { "email": "...", "password": "..." }
200 OK                  { "token": "<jwt>", "user": { "id": 7, "email": "..." } }
```

**List favorites** (auth required)
```
GET /api/favorites
Authorization: Bearer <jwt>

200 OK
[
  { "chordId": 42, "rootNote": "C", "chordType": "major", "displayName": "C Major", "favoritedAt": "..." }
]
```

**Add favorite** (auth required)
```
POST /api/favorites/42
Authorization: Bearer <jwt>

201 Created   { "chordId": 42, "favoritedAt": "..." }
```

**Remove favorite** (auth required)
```
DELETE /api/favorites/42
Authorization: Bearer <jwt>

204 No Content
```

This is the full v1 endpoint list per requirements.md §4's MVP definition — browse/search, chord
detail with shapes, sign up/log in, add/remove favorite, list favorites. Deliberately not a
generic CRUD sketch (e.g. no `PUT /api/chords/{id}` — end users don't edit the chord library in
v1; that's a data-seeding concern, covered in Section 4).

---

## 3. Tech Stack

**This is the one decision in this document I'm not comfortable making unilaterally**, per my own
instructions — there's a genuine, named tension here, not just a preference call, and it's flagged
prominently in Section 7 as well. I picked a working recommendation below so the rest of the
design (database pairing, hosting) has something concrete to sit on, but please treat this
specific choice as the one most worth overriding in PR review if you feel differently.

### The tension

CLAUDE.md is explicit: this project exists to demonstrate *real* industry practice for a
portfolio, and "not a minimal/fewest-moving-parts setup." At the same time, CLAUDE.md is equally
explicit that the builder is a total beginner at coding, and the ticket instructions for this job
specifically warn against letting "easiest to learn" silently win over "realistic industry
practice" — implying it's also not supposed to silently lose.

### The three options considered

| Option | Learnability | Portfolio/industry signal | Azure fit |
|---|---|---|---|
| **ASP.NET Core (C#)** | Steepest — new language + a full framework's concepts at once | Strongest — it's Microsoft's own backend framework, a very standard "real enterprise backend" choice | Best — built to run natively on Azure, first-class tooling |
| **Node.js + Express (JS/TS)** | Gentlest — especially since the web client will also use JavaScript, meaning one language across frontend and backend | Solid and genuinely widely used in industry, though perceived as a lighter-weight choice than a full framework like ASP.NET Core or Django | Good — fully supported, not Microsoft's own stack |
| **Python + FastAPI** | Middle ground — Python is a famously readable first language; FastAPI itself is modern and fairly quick to pick up | Solid, modern, well-regarded, but again not Microsoft's own stack | Good — fully supported, not Microsoft's own stack |

### Working recommendation: ASP.NET Core (C#)

Reasoning: given CLAUDE.md's explicit instruction not to simplify away the backend, and that this
specific choice is exactly the kind of thing that shows up in a portfolio interview ("why did you
pick your backend framework?"), I'm leaning toward the option with the strongest "real practice +
Azure-native" story, on the theory that the learnability gap is a real but temporary cost (one
language to learn), while the practice/portfolio signal is a permanent property of the finished
project. ASP.NET Core also comes with a secure, built-in identity/auth system (ASP.NET Core
Identity) and Entity Framework Core, which is a well-trodden, heavily documented pairing for
exactly this kind of relational data model — so "steeper learning curve" is somewhat offset by
"less you have to hand-build or hand-pick yourself."

That said, this is a judgment call about *your* learning experience, which isn't mine to make
alone. If Node.js (reusing JavaScript across the whole stack) sounds like a meaningfully better
starting experience to you, that's a legitimate, real-world-credible choice too — say so in PR
review and I'll revise this section and the database pairing in Section 4 to match.

---

## 4. Database

**Decision: relational (SQL), not NoSQL.**

This one I'm comfortable deciding outright — it's a closer-to-best-practice call than a taste
call. The data described in Section 1 is inherently relational: a chord *has many* shapes
(one-to-many), a user *has many* favorited chords (many-to-many via the `Favorite` join table).
Requirements.md itself describes this data as "fairly structured" — it's not documents that vary
wildly in shape record-to-record, and it's not data that needs to scale horizontally across huge
volumes (requirements.md §6: "expected user scale... treat as low-priority/not a design driver for
v1"). A relational database enforces these relationships automatically via foreign keys — the
database itself will refuse to let a `Favorite` point at a `User` or `Chord` that doesn't exist,
which is exactly the kind of data-integrity guarantee this app wants and NoSQL document stores
don't give you for free.

**Specific engine, contingent on the Section 3 framework decision:**
- If ASP.NET Core: **Azure SQL Database**, paired with Entity Framework Core. This is the most
  idiomatic, most heavily documented pairing for that framework, and it's Azure's own
  fully-managed SQL offering.
- If Node.js or Python instead: **Azure Database for PostgreSQL (Flexible Server)** would be the
  more natural pairing — PostgreSQL is the de facto standard relational database in both of those
  ecosystems, with more community tooling/tutorials than Azure SQL for those languages.

Either way, the entity design in Section 1 doesn't change — this decision is about which managed
Azure product hosts that same relational schema, not about the schema itself.

### Getting the chord library into the database

Requirements.md §2 already identifies the data source: importing an existing open-source chord
dataset (e.g. `chords-db`) rather than depending on a live third-party API at runtime ("import into
the app's own database... consistent with the 'real backend, own your data' architecture goal").
Practically, this means a one-time (or re-runnable) **seed/import script** that reads that
dataset's chord and shape data and writes it into the `Chord` and `ChordShape` tables described
above — filtered down to the v1 chord-type list (requirements.md §2: major, minor, 7th, sus2,
sus4, diminished, augmented, major7, minor7 — explicitly *not* the full exotic/extended set
`chords-db` also contains). This is a build-time/setup tool, not a live API endpoint — end users
never call it.

---

## 5. Azure Hosting Shape

Per requirements.md §7, there is **no fixed budget ceiling yet** ("the builder has no ceiling in
mind... cheaper/free-tier-friendly options should probably be favored by default until a real
budget conversation happens"). Everything below defaults to the free or cheapest realistic paid
tier, named explicitly, rather than an enterprise-grade default.

**API hosting: Azure App Service**
- Start on the **Free (F1)** tier while building — $0/month, shared compute, some quota limits
  (e.g. daily CPU minutes), no custom domain SSL.
- Move to **Basic (B1)** (roughly $13/month at time of writing, but *verify current pricing in the
  Azure Portal* — pricing shifts over time and this is worth confirming live rather than trusting
  a static number in this doc) once you're ready to demo this reliably to recruiters — Free tier
  can have cold-start delays and quota resets that are fine for development but awkward mid-demo.
- Why App Service over other options (e.g. Azure Functions/serverless): App Service models your
  API as one continuously-running web application, which is the simplest mental model for a
  beginner ("my API is a server that's always on") and matches the "one shared backend serving
  three clients" story in CLAUDE.md directly. Azure Functions (serverless, pay-per-execution)
  would likely be even cheaper at low traffic, but introduces event-driven concepts (cold starts,
  execution time limits, a different local dev workflow) that add learning overhead without a
  clear payoff at this project's scale — worth revisiting only if hosting cost becomes an actual
  pain point later.

**Database hosting**
- **Azure SQL Database** (if ASP.NET Core) or **Azure Database for PostgreSQL – Flexible Server**
  (if Node/Python) — see Section 4. Azure SQL currently offers a **free-tier option** (a monthly
  compute/storage allowance at no cost, intended for exactly this kind of small/dev workload);
  PostgreSQL Flexible Server's cheapest paid tier (Burstable B1ms class) is normally only a few
  dollars a month. Again, *confirm exact current free-tier terms and pricing in the Azure Portal at
  setup time* rather than trusting a fixed number here — Azure's free offers change over time and
  this document may be read well after it's written.

**Web client hosting (brief note, not the core of this backend doc)**
- Requirements.md §3: "Web ships first." When the web client exists, **Azure Static Web Apps**
  (free tier) is worth considering as its host — it's built specifically for exactly this pattern
  (a static frontend calling a separate API) and has a generous free tier. This is flagged here
  for awareness, not decided now — it's a client-hosting decision, not a backend data/API
  decision, so it's out of this ticket's scope.

**CI/CD**
- GitHub Actions deploying to Azure App Service on push to `main` is the standard, well-documented
  pairing (and the project already uses GitHub for tickets/wiki), worth setting up once the API
  has real code to deploy. Not built now — noted so it's not a surprise later.

---

## 6. Open Questions

Carried forward from requirements.md, still genuinely unresolved and deliberately not decided
here:
- **Offline support** — kept in mind in Section 1 (plain, cache-friendly data shape) but not
  designed for in v1.
- **Progression generator vs. quiz mode ordering** — both have a data hook noted in Section 1;
  which gets built first is still an open product decision, not an architecture one.
- **Azure budget ceiling** — Section 5 defaults to free/cheap tiers in the absence of a number;
  revisit tier choices once a real budget conversation happens.
- **Accessibility/performance targets** — these are primarily frontend/client concerns, but two
  backend levers are worth flagging for later: response pagination (already in the `/api/chords`
  design, Section 2) and standard HTTP caching headers, both of which directly help "fast load
  times" once there's a concrete performance target to hit.

New, from this document, worth your explicit sign-off before treated as final:
- **Backend framework (Section 3)** — ASP.NET Core (C#) is the working recommendation, but this is
  the one decision in this doc with a real, named learnability-vs-industry-practice tension. Worth
  your explicit call.
- **Database engine (Section 4)** — Azure SQL vs. Azure Database for PostgreSQL is directly
  downstream of the framework decision above; will follow whichever way that goes.
- **REST vs. GraphQL (Section 2)** — decided as REST for v1, flagged as revisitable once multiple
  clients exist side by side and their data needs might diverge.
- **Azure tier specifics (Section 5)** — Free-tier defaults proposed throughout; exact tier names
  and pricing should be double-checked in the Azure Portal at setup time rather than trusted from
  this document, since offers change over time.
