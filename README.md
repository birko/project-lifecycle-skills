# The Project Lifecycle Skills — `new-project` · `tasks` · `feature` · `roadmap` · `populate-tests` · `specs`

> How a handful of Claude Code skills form a single pipeline that carries a raw idea all the
> way to shipped, reviewed, **tested** code — without ever losing the paper trail.

Three skills are **one pipeline, not separate tools** — and three more keep that pipeline
honest. They are layered: `new-project` lays the ground, `tasks` is the tracking backbone,
`feature` rides on top of `tasks`; `roadmap` is the read-only lens that reads *both* work
trees at once and audits them for drift; `populate-tests` is the testing backbone that
turns each tracked unit of work into verified coverage and keeps a per-surface coverage
ledger; and `specs` keeps the behavioral map honest — capability specs harvested from the
code itself, their regen diff reviewed at story close as an intended-change check. The whole point: **a raw idea can travel all the way to shipped, reviewed, tested code
without losing its paper trail** — and that trail serves two audiences at once:

- **Developers** — what to build, how to test it.
- **Stakeholders / PMs / stocktakers** — what was decided, why, and where it stands.

---

## 1. The skills at a glance

| Skill | Scope | Entry command | Produces |
|---|---|---|---|
| **new-project** | Once, at repo birth | `/new-project` ("new project", "novy projekt") | The universal layer: `README`, `CLAUDE.md`, `.gitignore`, `docs/features/`, `docs/specs/`, `tasks/` — a repo *pre-wired* for the rest of the lifecycle |
| **tasks** | The backbone, forever | `/tasks new\|pick\|close\|triage…` | `tasks/` tree of EPIC → STORY → TASK markdown files + auto dashboard |
| **feature** | Per idea/initiative | `/feature new\|prototype\|decide\|decompose\|status\|review` | `docs/features/FEATURE-NNN/` — idea, decision ledger, prototype, stakeholder status |
| **roadmap** | On demand, read-only | `/roadmap` (`--check`, `--fix`, `EPIC-NNN`) | Nothing — a stdout-only unified view of **both** trees joined by epic, plus a divergence audit. The cross-tree engine the other two delegate to |
| **populate-tests** | The test backbone, alongside the work | `/populate-tests adopt\|survey\|populate\|verify\|ledger` | Automated tests (generated smoke → authored flows) under `tests/` + a per-surface `[auto]`/`[manual]` **coverage ledger**; bugs found filed back as tasks |
| **specs** | Per capability, regenerated from code | `/specs init\|regen\|verify\|show` | `docs/specs/` — a hand-editable **area map** (`.map.yml`) + one generated spec per capability (SHALL requirements + Given/When/Then scenarios), stamped with commit + feature provenance; the regen **diff review** doubles as an unintended-behavior-change detector |

---

## 2. How they stack

```
                 ┌──────────────────────────────────────────────┐
   /new-project  │  scaffolds the repo ONCE                      │
                 │  ├─ creates  tasks/         (chains → tasks)   │
                 │  ├─ creates  docs/features/ (home for feature) │
                 │  └─ seeds    CLAUDE.md: lifecycle + conventions │
                 └───────────────────┬──────────────────────────┘
                                     │ leaves the repo "ready"
                                     ▼
   /feature  new → prototype → decide → decompose ───────────┐
   (stakeholder-facing,                                       │ calls
    docs/features/)                                           │ /tasks new --from-feature
                                     ┌─────────────────────────▼────────────┐
   /tasks   ◀── decompose feeds it ──│  EPIC / STORY / TASK  (dev-facing)    │
   (dev-facing, tasks/)              │  each TASK carries  feature: FEATURE-NNN
                                     └─────────────────────────┬────────────┘
                                                               │ task status flows back
   /feature  status  ◀── reads tasks via `feature:` frontmatter┘
   /feature  review  ── completeness gate: all decisions decomposed + every task merged,
                         walks the TASK ## Human test plans, optional /security-review, + sign-off

   /roadmap  ◀── reads BOTH trees, joins by epic, audits drift ──▶  (read-only)
             owns the cross-tree engine that `/feature status` and bare `/tasks`
             render slices of — one join/divergence routine, many renderers

   /populate-tests  ◀── reads CLAUDE.md § Testing (seeded by new-project)
             sweeps every surface → generated smoke + authored flows,
             keeps the [auto]/[manual] coverage ledger, files bugs as tasks
             ──▶ feeds the /tasks done-gate ("tests green") + /feature acceptance

   /specs  ◀── harvested from the CODE (docs/specs/, area map in .map.yml)
             story close offers a scoped regen; the spec DIFF is the review:
             "was this behavioral change intended?" — unexplained diff = finding
             ──▶ /feature review checks each approved decision LANDED in a spec
                 (shaped-by provenance); /roadmap audits stale specs (DV7/DV8)

   field signal (bug / incident / demand) ──▶ triage ──▶ {task | feature | reopened decision}
             the loop: "done" is not the end — production feeds back into the pipeline
```

### The two-tree split (the central idea)

- `docs/features/` = **stakeholder tree** — plain language, decisions, "why", prototypes.
  A PM/stocktaker reads this.
- `tasks/` = **developer tree** — atomic, self-contained units of work with acceptance
  criteria and test plans. An AI agent or dev picks these up.

They're bridged by **one piece of frontmatter**: every task born from a feature carries
`feature: FEATURE-NNN`. `feature status` greps for that to roll dev progress back up into a
stakeholder report. **One link, both directions.**

### Feature or task? — the router

When a new thing lands on you, **nothing auto-classifies it** — *you* pick the entry command,
and that pick is the routing. The deciding question is one line:

> **A feature is a question; a task is an answer.**
> Still has questions a stakeholder should settle → `/feature`.
> Already an answer that just needs building and testing → `/tasks` directly.

| Reach for **`/feature`** when… | Reach for **`/tasks` (task-only)** when… |
|---|---|
| There are **open branches** worth interrogating (grill-me yields a real decision tree) | The work is **already well-defined** — one obvious way to do it |
| **Stakeholders** must react / see a prototype / sign off | Nobody outside the dev needs to weigh in |
| It's a **time-boxed initiative** that may fan out into *several* tasks | It's **one self-contained unit** of work |
| You want an **auditable "why"** (approved / deferred / dropped) | The "why" is obvious — a bug is a bug |

**The practical test:** a feature only earns its weight if you'd actually use its stages —
*prototype, decision ledger, sign-off at `/feature review`*. Skip all three and the feature
scaffolding is pure ceremony; use a task. *"Fix the login redirect"* → `tasks/_loose/TASK-NNN`.
*"Offline stock count on mobile"* (barcode? voice? multi-warehouse? — stocktakers must react)
→ `/feature`.

Two things that take the pressure off the call: **feature is not an alternative to tasks** — it's
the front end that *produces* them (`decompose` → `/tasks new --from-feature`), so "feature"
never means "not tasks," it means "tasks **plus** a decision trail above them." And it's
**reversible** — a loose task that grows real scope can be promoted; a feature whose decisions
all collapse to "obvious" just decomposes into a single task. Don't agonize; guessing wrong is cheap.

### Closing the loop — feedback from the field

The pipeline so far reads one-way: idea → done. The one backflow that already exists is
`populate-tests` → a quarantined `task` for a test-found bug. A **production** signal — a user
report, an incident, a monitoring alert — earns the same right to re-enter, through three
defined edges:

- **Signal → triage → {task | feature | reopened decision}.** Same router as above, one lane
  wider: a regression in shipped behavior → a `task` (loose or under its epic); a missing
  capability the field exposed → a `feature` (it has open questions again); evidence that a
  `deferred`/`removed` decision was wrong → **reopen that decision** (§3.3).
- **A fix for shipped behavior isn't `done` until it has a regression test.** Part of the
  done-gate: every bug that escaped to the field earns a `populate-tests` spec so it can't
  recur — the same "quarantine becomes a permanent spec" discipline, applied to prod bugs, not
  just test-found ones.
- **Decisions can be reopened.** The ledger is append-only, so reopening is *re-deciding*: a
  **new `proposed` row** that links and supersedes the old `deferred`/`removed` one — you keep
  the original "why", plus the field evidence that overturned it. A `deferred` row's unblock
  condition is exactly this trigger.

This turns the line into a loop: **field → triage → {task | feature | decision} → … → done →
field.** Nothing dead-ends.

---

## 3. What each skill produces

### 3.1 `new-project` — the universal layer

Runs an intake (name, location, kind, stack, task mode, license), optionally offers a scope
grill, then writes a **consistent layer regardless of language**:

```
my-app/
  README.md              ← purpose + "How we work" lifecycle section
  CLAUDE.md              ← agent guide: feature→tasks convention + the § Conventions rulebook
  CHANGELOG.md           ← Keep-a-Changelog stub (code changes)
  .gitignore .gitattributes .editorconfig
  docs/
    BRIEF.md             ← the user's ask, verbatim (append-only ground truth)
    features/            ← empty; the feature skill writes here
    specs/               ← .map.yml seed; the specs skill harvests here later
    architecture.md      ← short but real overview; a living doc, not a stub
  tasks/                 ← initialized by chaining the tasks skill
    .config.yml
    README.md
  src/ tests/            ← stack-idiomatic source root + tests
  .github/workflows/ci.yml  ← install→build→test gate
```

Crucially it **doesn't reimplement** the other skills — it *chains* `tasks` to make `tasks/`,
creates `docs/features/` for `feature`, and seeds `CLAUDE.md` so any future agent knows the
convention. When the chosen stack has its own scaffolder skill, it further chains that skill
for the platform-specific code wiring rather than reimplementing it.

It also seeds the **`## Conventions` rulebook** inside that `CLAUDE.md` — see §6. Because
`CLAUDE.md` is auto-loaded into every task's context, the project's framework/UI/structure
rules ride along automatically, which is what makes "the next task follows the same pattern"
true rather than aspirational.

### 3.2 `tasks` — hierarchical tracking

Three levels as markdown files. **Epics and Stories are open-ended areas of concern; only
TASKs are atomic completable units** (no archiving — status-only).

```
tasks/
  README.md                          ← auto-generated dashboard (/tasks triage)
  .config.yml                        ← mode: local | hybrid (github/jira)
  EPIC-001-stock-mobile/
    EPIC.md
    STORY-001-offline-count/
      STORY.md
      TASK-001-barcode-scanner.md
  _loose/                            ← orphan tasks with no parent epic
    TASK-007-fix-login-redirect.md
```

Every TASK file is **self-contained** — `## Context`, `## Acceptance criteria`,
`## Out of scope`, `## Human test plan`, `## Implementation plan` — so it can be picked
without re-discovery. Supports **local** (files only) or **hybrid** (synced to GitHub Issues
/ Jira). Verbs: `new`, `pick`, `close`, `cancel`, `block`/`unblock`, `triage`, `audit`,
`plan`, `import`, `export`, `migrate`. **Every status in the vocabulary has a verb that sets
it** — `cancel` (won't-do, never deletes — mirrors a `removed` decision) and `block`/`unblock`
(hold out of / return to the ready pool) close the loop so no transition needs hand-editing.

**Integration model — PR-per-task, `/tasks close` is the merge gate.** The atomic unit is the
task, so the **branch and PR are too**: `/tasks pick` cuts `task/TASK-NNN` from main, and
`/tasks close` is where code actually integrates — `/code-review` on the working tree, `/review`
on the PR diff, then **merge**, close the linked issue, flip to `done`. This gives `done` a
single precise meaning: **merged to main**, not "reviewed somewhere." Small diffs, fast review,
one review per task at the right altitude. (A tightly-coupled cluster *may* share a feature
branch and defer the single merge to `/feature review` — but PR-per-task is the default, and
the rest of this doc assumes it.)

### 3.3 `feature` — the idea→shipped lifecycle

```
docs/features/
  README.md          ← features INDEX (human entry point); templated, regenerated by /feature status
  FEATURE-001-slug/
    idea.md          ← problem + distilled grill-me interview (incl. the ## Prototype decision line)
    decisions.md     ← the decision LEDGER (approved/deferred/changed/removed)
    prototype.html   ← interactive prototype for stakeholders (or .md / spike link)
    status.md        ← auto-generated rollup for PMs (phase + progress)
```

The heart of it is the **decision ledger** — every idea-branch is a row with exactly one
state, and **rows are never deleted** (`removed` is a state, so it stays auditable):

| State | Meaning | Generates tasks? |
|---|---|---|
| `proposed` | fresh from grill, awaiting decision | not yet |
| `approved` | stakeholder said build it | ✅ at `decompose` |
| `changed` | approved but altered — record the delta | ✅ (changed form) |
| `deferred` | good idea, not now (note unblock condition) | ❌ |
| `removed` | rejected / out of scope | ❌ |

Only `approved` + `changed` rows become tasks. Every state change is **append-logged** in
`decisions.md` — you keep *why and when it changed*, not just the current value. **No row is
deleted, and none is terminal:** field evidence can **reopen** a `deferred`/`removed` branch by
*re-deciding* it (a fresh `proposed` row that links the superseded one, then stamped `approved`/
`changed`) — so the original rationale *and* the reversal both stay auditable. That reopen path
is how production feedback re-enters the decision tree (§2 *Closing the loop*). The state set
stays a tight five — reopening is a transition, not a sixth state.

### 3.4 `roadmap` — the cross-tree lens (keeps the two trees honest)

The two-tree split (§2) buys clean separation — but separation lets the trees **drift**: a
feature still reads `idea` while its tasks already shipped; a task carries `feature: null`
though its feature is decided; work gets tracked in one tree and never mirrored in the other.
`roadmap` is the **read-only** view that joins both trees by epic and audits exactly that
drift. It produces no files — it's invoked on demand and prints to stdout, because anything
it committed would silently lag the moment a tree changed.

```
EPIC-012 Backend consolidation — in-progress (8/24 tasks)
  FEATURE-019 OAuth/identity      building  2/7   ✓ synced
  FEATURE-016 Retire old stack    done      2/2   ✓ synced
  FEATURE-031 …                   idea      0/1   ⚠ DV4 tasks exist, decisions proposed

Divergences (1):
  FEATURE-031  DV4  tasks decomposed but D1–D2 still proposed → run /feature decide FEATURE-031
```

It is the **single source of truth for the cross-tree pass** — the join + divergence rules
(DV1–DV9: "feature frozen while work moved on", "shipped work never closed out", "broken
back-link", … the spec-drift checks DV7/DV8, and the ledger-backfill check DV9 — a task
back-linking a feature whose `→ Tasks` column doesn't list it). It doesn't re-implement `tasks` or `feature`; instead those two **delegate
into it**: the bare `/tasks` snapshot renders a compact slice of this engine, and `/feature
status` reuses its divergence rules. *One engine, many renderers.* Verbs: `/roadmap` (full
render), `--check` (audit only — fastest "are we in sync?"), `EPIC-NNN` (scope to one epic),
`--fix` (*proposes* reconciliation edits but applies nothing — drift fixes are judgment calls
handed back to `/feature decide` or `/tasks`).

### 3.5 `populate-tests` — the test coverage backbone

The lifecycle tracks *what to build* (`tasks`) and *why* (`feature`); `populate-tests` tracks
**what's verified**. It's the sibling that turns each surface — route, screen, endpoint,
entity — into automated coverage, and keeps an honest per-surface ledger of what's machine-
checked vs. what still needs a human eye. Like the other core skills it's **verb-driven** and
reads a `CLAUDE.md` convention rather than inventing one: it reads **§ Testing** (the layered
model `new-project` seeds), exactly as `verify-conventions` reads § Conventions.

**The layered model it populates** (highest ROI first):

| Layer | What | Upkeep |
|---|---|---|
| **Generated smoke** | every surface swept for "it loads, no errors" — derived from the app's *own* manifest/router so the list self-maintains | ~zero |
| **Authored happy-path flows** | a few hand-written E2E/integration flows per important entity (create → … → delete), reusing the project's test toolkit + page objects | low |
| **Manual-judgement ledger** | only what a human must eye — copy reads naturally, layout/feel, visual polish | per surface |

```
tests/                         ← stack-idiomatic; reuses the project's own toolkit
  smoke/route-smoke.spec.ts    ← generated from the router manifest
  flows/stock-count.spec.ts    ← authored happy-path
COVERAGE.md  (or per-surface)  ← the [auto]/[manual] ledger:
  Stock count screen
    [auto]   renders, no console errors      → smoke/route-smoke
    [auto]   scan → tally → submit           → flows/stock-count
    [manual] count feels fast on a real phone
```

Verbs — `/populate-tests [adopt|survey|populate|verify|ledger]` (bare = survey):

- **adopt** — wire the test harness if the repo has none yet (idempotent): test dir, runner
  config, pinned runner dev-dep. `survey`/`populate` call it first when no harness is found.
- **survey** — list surfaces (from the manifest) vs. what's tested; report gaps as a table.
  No edits.
- **populate** — per untested surface: ground in real source (page model, filters, schema,
  delete pattern), author a spec from the project's pattern. Refresh the generated route-smoke
  from the manifest. For scale, **fans out via the `Workflow` tool** — one agent per surface —
  but only with explicit opt-in (many agents, real token spend).
- **verify** — run the suite and triage each result: **pass** / graceful **skip** (missing
  seed data — never hang or red) / **quarantine + file a bug `task`** (real app bug). *Never
  loosen an assertion to fake green* — the bugs it surfaces are the payoff.
- **ledger** — collapse generic "renders / CRUD / no errors" items to `[auto]` (naming the
  spec), keep only human-judgement items as `[manual]`.

**How it stitches into the two trees.** It reads § Testing (← `new-project`), satisfies the
`tasks` **done-gate** ("tests green AND manual checks run"), and fills each
`docs/features/FEATURE-*/` acceptance section as coverage lands (← `feature`). Bugs it finds
don't vanish into a report — they become `tasks/` items, so a discovered defect re-enters the
same pipeline as planned work.

### 3.6 `specs` — the harvested behavioral map

The lifecycle tracks *what to build*, *why*, and *what's verified*; `specs` tracks **what the
system actually does now**. The direction is deliberately inverted from spec-first tooling:
the **code is the source of truth** and specs are *harvested* from it, so a spec can never rot
— it can only be stale, and staleness is machine-checkable.

```
docs/specs/
  .map.yml        ← hand-editable AREA MAP: capability → source globs (the only human-owned file)
  <area>.md       ← generated per capability: Purpose → SHALL requirements → Given/When/Then scenarios
                    frontmatter stamp: generated-at (commit) · sources · shaped-by (FEATURE-NNN)
```

The trick that makes harvesting more than documentation: **regeneration is never a silent
overwrite — the spec diff is the review.** Closing a story offers a scoped
`/specs regen --story STORY-NNN`, and every behavioral change in the resulting diff gets
classified: *matches an approved decision* / *intended anyway* / **unexplained → a finding**
(an unintended behavior change, routed back as a task). The stable-wording rule keeps diffs
meaningful: untouched behavior keeps its exact wording, so a diff always means "behavior
changed", never "the harvester rephrased".

Cross-links are **computed, never hand-maintained**: a regen triggered by a story/feature
appends `shaped-by: FEATURE-NNN` to the spec's frontmatter. Backward, that answers "why does
this behave so?" (open the feature's `decisions.md`); forward, `/feature review` Gate A checks
each approved decision actually **landed** in a spec — a decision with no spec landing means
the feature isn't done. `roadmap` audits the drift (DV7 stale spec, DV8 shipped feature with
no spec landing). Verbs: `init` (discovery pass — propose + bless the area map), `regen`
(harvest → diff review → stamp), `verify` (read-only staleness), `show`. Scenarios are
mandatory — they're the future join point for `populate-tests` (scenario ↔ covering test).

---

## 4. Worked example — watch the files appear

Building a stocktake mobile feature. The repo at each step:

**Step 1 — `/new-project`** (kind: web app, stack: TS, mode: hybrid-github):
```
stock-app/
  README.md  CLAUDE.md  CHANGELOG.md  .gitignore
  docs/BRIEF.md           ← the ask, verbatim
  docs/features/          ← empty, waiting
  docs/specs/.map.yml     ← empty area map, waiting
  tasks/.config.yml  tasks/README.md
  src/index.ts  tests/
```

**Step 2 — `/feature new "offline stock count on mobile"`** (grill-me interviews you):
```
docs/features/FEATURE-001-offline-stock-count/
  idea.md         ← problem: counters lose data with no signal
  decisions.md    ← D1 barcode scan [proposed], D2 offline queue [proposed],
                    D3 voice entry [proposed], D4 multi-warehouse [proposed]
```

**Step 3 — `/feature prototype`** → `prototype.html` (clickable mock for the stocktakers to
react to).

**Step 4 — `/feature decide`** (after the demo, stakeholders weigh in):
```
decisions.md  (states stamped + history logged)
  D1 barcode scan      → approved
  D2 offline queue     → approved
  D3 voice entry       → deferred   (revisit after v1, needs mic permissions research)
  D4 multi-warehouse   → removed    (out of budget this quarter)
```

**Step 5 — `/feature decompose`** — only D1 + D2 generate work. This *calls*
`/tasks new --from-feature FEATURE-001`:
```
tasks/EPIC-001-stock-mobile/
  EPIC.md
  STORY-001-offline-count/
    STORY.md
    TASK-001-barcode-scanner.md     ← feature: FEATURE-001
    TASK-002-offline-sync-queue.md  ← feature: FEATURE-001
```
Each `TASK-*.md` has `feature: FEATURE-001` in its frontmatter — that's the bridge.

**Step 6 — work happens in `/tasks`.** A task is self-contained (Context + Acceptance +
test plan), so it can be picked up by **either a human developer or an AI agent** — the file
is the shared contract. Two ways the same `TASK-001` gets done:

*Path A — a developer codes it:*
```
/tasks pick TASK-001
  → frontmatter flips:  status: todo → in-progress,  assignee: jana
  → branch task/TASK-001 cut from main
  → dev reads ## Context + ## Acceptance criteria (no re-discovery needed)
  → writes the barcode scanner in src/, adds tests/
  → ticks the ## Acceptance criteria checkboxes as each is met
/tasks close TASK-001            ← the merge gate
  → /verify-conventions + /code-review on the working diff (adherence + correctness)
  → opens the PR; /review on the PR diff; walks ## Human test plan: "scan a real EAN-13" ✓
  → merge → status: in-progress → done   (+ closes the linked GitHub issue in hybrid mode)
```

*Path B — an AI agent picks it up and does it:*
```
/tasks pick TASK-001
  → agent reads the whole TASK file as its brief
  → /tasks plan TASK-001 drafts ## Implementation plan (atomic steps)
  → optionally built test-first via /tdd (red → green → refactor)
  → agent writes code + tests, ticks acceptance boxes
  → /run or /verify launches the app to confirm it actually works
/tasks close TASK-001
  → ## Human test plan run (by agent, or handed to a human for the UI steps)
  → status → done
```

Either way the **frontmatter and checklists are the record** — `status`, `assignee`, the
ticked acceptance boxes, and the verified test plan — so whoever (or whatever) did the work,
the next reader sees exactly what was done.

**Step 6½ — `/populate-tests`** turns that work into standing coverage (it reads
`CLAUDE.md § Testing` to learn the stack + toolkit):
```
/populate-tests survey
  → table: "stock-count screen → untested", "scan endpoint → smoke only"
/populate-tests populate stock-count
  → grounds in src/ (the real scan form, fields, submit), then writes:
      tests/smoke/route-smoke.spec.ts   ← refreshed from the router manifest
      tests/flows/stock-count.spec.ts   ← scan → tally → submit happy path
/populate-tests verify
  → suite runs: 11 pass, 1 skip (no seeded Building), 1 quarantined
  → the quarantine files tasks/_loose/TASK-009-duplicate-tally-off-by-one.md
/populate-tests ledger
  → COVERAGE.md: scan/tally/submit → [auto]; "feels fast on a real phone" → [manual]
```
The off-by-one the suite surfaced re-enters the pipeline as a normal task — *the bugs it
finds are the payoff, not a side effect.*

**Step 7 — `/feature status`** greps `tasks/` for `feature: FEATURE-001`, rolls it up:
```
status.md
  Phase: building
  Decisions: 2 approved · 1 deferred · 1 removed
  Build progress: 1 / 2 tasks done
  Next step: TASK-002 in progress
```
(That roll-up is the `roadmap` cross-tree engine under the hood — `/roadmap --check` would
print the same join plus a divergence line if, say, both tasks were `done` but the feature
still read `building`.)

**Step 7½ — `/roadmap`** (any time, by anyone) — zoom out from the one feature to the whole
repo: every epic with its features, per-feature sync state, and a divergence audit. This is
the view a PM or lead opens to ask "where does *everything* stand, and have the two trees
drifted?" — answered without editing a thing.

**Step 8 — `/feature review`** — the **completeness gate**, *not* a code re-review (every task
was already reviewed + merged at its own `/tasks close`, §3.2). It checks the feature is
*whole*: Gate A — every `approved`/`changed` decision decomposed and every task merged (`done`),
the register-on-introduce check (any new pattern recorded in `## Conventions`), and *optional*
cumulative passes for a big feature (`/code-review` for cross-task integration bugs,
`/security-review` if warranted); Gate B — each task's `## Human test plan` walked end-to-end
across the feature; Gate C — stakeholder sign-off → flips `idea.md` to `done`. Code correctness
already cleared once per task, at the right altitude.

**Step 9 — the loop closes** (weeks later, in the field). A counter reports the app
double-counts when two phones scan the same shelf; ops also notes customers keep asking for
multi-warehouse — the `D4` you `removed` for budget. Both re-enter the *same* pipeline:
```
field signal → triage
  double-count bug (regression in shipped behavior)
    → tasks/_loose/TASK-014-concurrent-scan-dedupe.md
    → done-gate: ships WITH a populate-tests regression spec, so it can't recur
  multi-warehouse demand (a removed decision, overturned by evidence)
    → /feature decide FEATURE-001:  reopen D4 multi-warehouse  (removed → proposed → approved)
       (a new ledger row links the old — the budget "why" stays, the reversal is logged)
```
idea → done was never the terminus; **done → field → triage → … is the cycle.**

---

## 5. Satellite skills — by where they plug in

The core skills don't operate alone; they explicitly **call** or **hand off to** a ring
of satellite skills. Each slots into a named stage.

```
/new-project ──┬─ grill-me ............ optional scope interrogation at intake
               └─ <stack scaffolder> .. platform-specific code-wiring (chained when the stack has one)

/feature new ──── grill-me ............ THE engine — the interview output IS the decision tree

/feature decompose → /tasks new ─┐
                                 │  ← work happens here; the build loop runs:
   ┌─────────────────────────────┘
   ├─ tdd ............ red-green-refactor loop for building a task
   ├─ run / verify ... launch the app, confirm the change works for real
   └─ simplify ....... quality cleanup pass on the diff

/tasks close ────┬─ code-review ........ correctness on the working tree (pre-PR)
   (the MERGE     ├─ verify-conventions . adherence to CLAUDE.md § Conventions
    gate)         ├─ review ............. the PR diff on GitHub
                  └─ (merge → status done)   ← code is reviewed ONCE, here, per task

/feature review ─┬─ (completeness) ..... all decisions decomposed + every task merged
                 ├─ security-review .... OPTIONAL cumulative-diff security pass
                 └─ (stakeholder sign-off → idea.md done)   ← no code re-review

cross-cutting:
   handoff .......... compact context for another agent (same "pickable context" principle)
   roll-changelog ... maintains the CHANGELOG.md that new-project seeds (currency of *what shipped*)
                      NUDGED (not auto-run) at the ship moments: /feature review when a feature
                      → done, and /tasks close for feature-less user-facing work
   verify-conventions reads the § Conventions rulebook; roll-changelog keeps CHANGELOG.md current
   — the two generic "keep-honest" maintainers
```

**Three that carry the most weight:**

1. **`grill-me` — the engine behind the front end.** Not optional decoration: `feature new`'s
   interview output *literally becomes* the proposed decision tree in `decisions.md`. Also
   powers the optional scope grill in `new-project` and `/tasks plan`. *Every downstream
   artifact is only as good as how hard the idea got interrogated.*

2. **`code-review` + `review` + `security-review` — the teeth of the gates.** Code correctness
   is reviewed **once per task**, at `/tasks close` (the merge gate): `/code-review` on the
   working tree, `/review` on the PR diff. `/feature review` then adds an optional
   `security-review` on the cumulative diff and leans on each task's `## Human test plan` — so a
   feature clears several independent checks, with code review at the right altitude (the task)
   rather than re-run wholesale at the end.

3. **`tdd` + `verify` + `run` — the inner build loop.** Between "pick a task" and "close a
   task," this is how a task gets built test-first and confirmed working in the real app —
   which is what makes the `## Human test plan` and `/feature review` honest rather than
   ceremonial.

> **`populate-tests` vs. `tdd` — different altitudes, not rivals.** `tdd` drives *one task*
> red-green-refactor while you build it; `populate-tests` is a **core lifecycle skill** (§3.5),
> not a satellite — it sweeps *every surface* for standing coverage and keeps the `[auto]`/
> `[manual]` ledger. `tdd` proves the unit you're writing now; `populate-tests` proves the
> whole app stays covered and feeds the `tasks` done-gate ("tests green") + `feature`
> acceptance. Use `tdd` inside a task; run `populate-tests` across the work.

> *The lifecycle skills own the **process and the paper trail**; the satellites own the
> **interrogation, the building, and the verification** — each slots into a named stage, so
> nothing in the pipeline is hand-waved.*

---

## 6. Project rules — a living, enforced rulebook

The lifecycle keeps *intent* honest (the decision ledger), *what-shipped* honest (the
changelog), and *what's-verified* honest (the coverage ledger — §3.5). The next thing worth
keeping honest is **how the code is built** — the framework, the UI/UX rules, the structure
and naming — so every new task produces code that looks like the rest of the codebase instead
of reinventing a style each time.

**Where the rules live: `CLAUDE.md § Conventions`.** Not a side doc — the agent guide, because
that's the one file *auto-loaded into every task's context*. If the rules lived in
`docs/CONVENTIONS.md`, a task would only follow them when something remembered to open it.
`new-project` seeds the section structured into the parts a codebase actually drifts on:

```
CLAUDE.md
  ## Conventions
    ### Framework / stack            ← approved foundation + libs; no new dep without a decision
    ### UI / UX rules                ← design tokens, component lib, spacing/type, a11y bar
    ### Code structure & patterns    ← layering, folder layout, patterns / anti-patterns
    ### Naming                       ← file / type / symbol conventions
    ### Testing                      ← framework, what must be tested, where tests live
    ### Keeping conventions current  ← the register-on-introduce rule (below)
  ## Architecture  (living)          ← updated whenever a change alters structure
```

**Keeping it complete: register-on-introduce.** A rulebook rots the moment a new pattern
lands in code but not in the list — the next task copies the *old* rule and the two diverge.
So the standing rule (baked into `/tasks close` and `/feature review`): when a change
**introduces a new cross-cutting pattern** — a new framework/major dependency, a UI pattern,
a new architectural layer, a naming or testing convention — recording it in `## Conventions`
(and `## Architecture` if structure changed) is **part of "done"**, exactly like logging a
decision in `decisions.md`. This is the same discipline the feature ledger uses, applied to
*how we build* instead of *what we decided*.

**Keeping it followed: `verify-conventions`.** A tech-agnostic adherence lint that reads
*this project's own* `CLAUDE.md § Conventions` and checks the current diff against it —
quoting the rule it came from, so findings are traceable, never invented. It also flags a
diff that introduced a new pattern **without** recording it (the register-on-introduce
catch). It runs at `/tasks close` — the per-task merge gate — **alongside `code-review`**, so
both fire once per task at the right altitude (not re-run wholesale at `/feature review`, which
only *confirms* a new pattern got recorded). The two answer different questions:

> **`code-review` asks "is this correct?" · `verify-conventions` asks "does this match how we build?"**

The closed loop: rules in `CLAUDE.md` (auto-loaded) → followed by every task → linted at
the close/review gate → a new pattern forces a rulebook update → the next task sees it.

**The same pattern, applied to tests.** `new-project` seeds a **§ Testing** convention next to
§ Conventions — the layered model (generated smoke → authored flows → manual ledger), the
stack/toolkit, the done-gate. `populate-tests` is to § Testing what `verify-conventions` is to
§ Conventions: the skill that reads *this project's own* convention and acts on it, rather than
inventing one. Seed-once, act-many — one for *how we build*, one for *how we verify*.

### Skill layering — global vs. project-local

These skills live at two scopes, and a skill **lives where it's invoked from**:

| Scope | Holds | Examples |
|---|---|---|
| **Global** (`~/.claude/skills/`) | the generic, cross-project lifecycle (incl. the stack-agnostic `populate-tests` + `specs`) + the generic "keep-honest" maintainers + any stack scaffolders that run in arbitrary repos | `new-project`, `tasks`, `feature`, `roadmap`, `populate-tests`, `specs`, `roll-changelog`, `verify-conventions`, `grill-me`, `tdd`, `handoff` |
| **Project-local** (`<repo>/.claude/skills/`) | skills that only make sense *inside* one repo — internal scaffolders and project-specific **variants** of global skills | a framework repo's own subproject scaffolder, a project-tuned `verify-conventions` or `roll-changelog` |

Project-local skills **shadow** same-named global ones inside their repo, so a project-specific
variant wins when you're working there, while the generic version runs everywhere else. A
`[[link]]` to a project-local skill that doesn't resolve from the global set is *correct*, not
broken — it resolves inside its home repo, which is its source of truth.

---

## 7. The ideas worth landing

1. **Pre-wired from birth.** `new-project` doesn't just make a folder — it leaves the repo
   *ready* for the lifecycle (the `tasks/` folder, the `docs/features/` folder, and a
   `CLAUDE.md` that tells every future agent the convention). Day-one discipline, zero setup
   later.

2. **Two trees, one link.** Stakeholder docs (`docs/features/`) and dev work (`tasks/`) are
   deliberately separate because they have different audiences and lifecycles — but a single
   `feature: FEATURE-NNN` frontmatter field stitches them so progress flows back up
   automatically. The human test plan lives *in the task*, not the feature, because a test
   must travel with the unit of work. And because two trees *can* drift, `roadmap` is the
   read-only auditor that joins them by epic and flags when they've fallen out of sync — so
   the link is enforced, not just declared.

3. **An auditable ledger of intent, not just code.** The decision table records *why* things
   were built, deferred, or killed — and never deletes a row. Six months later a PM can see
   that multi-warehouse was `removed` for budget, not forgotten.

4. **Rules that ride along and stay current.** The project's conventions live in the
   auto-loaded `CLAUDE.md`, so every task inherits them without being told; introducing a new
   pattern *requires* recording it (register-on-introduce); and `verify-conventions` lints the
   diff against that list at the close/review gate. Five forces — decision ledger, changelog,
   convention rulebook, **coverage ledger**, **behavioral specs** — each kept honest by a verb
   in the lifecycle rather than by goodwill.

5. **Coverage is a ledger, not a vibe.** `populate-tests` makes "is it tested?" answerable per
   surface — `[auto]` (and which spec) vs. `[manual]` (and why a human must still look) — read
   from the app's own manifest so the list can't silently fall behind the routes. Tests are
   generated/authored from *real source*, never faked green: a failure becomes a quarantined
   `task`, so the defects testing surfaces re-enter the same pipeline as planned work. The
   fourth keep-honest force, sitting beside intent, what-shipped, and how-we-build.

6. **The pipeline is a loop, not a line.** Work doesn't only flow idea → done; signal flows
   back. Both test-found bugs (`populate-tests`) and field-found bugs re-enter as tasks, a
   shipped fix isn't `done` without a regression test, and a `removed`/`deferred` decision can
   be **reopened** (re-decided) when the field overturns it — append-logged, so the original
   "why" and its reversal both survive. And `done` itself is precise — **merged**, because the task is the
   unit of work, the PR, *and* the merge gate. Nothing dead-ends; nothing is left ambiguous.

7. **The spec is harvested; the diff is the review.** Specs generated from code can't rot —
   but harvested-and-overwritten specs are just churn. `specs` splits the difference: the code
   stays the source of truth, and every regeneration is reviewed *as a diff* against the
   decision ledger — intent (`feature`) meets actuality (`specs`) at exactly the moment a
   mismatch is cheapest to catch. An unexpected spec change at story close is an unintended
   behavior change caught before anyone ships on top of it.
