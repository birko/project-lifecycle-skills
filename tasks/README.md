# Tasks — The Project Lifecycle Skills

_Generated 2026-08-18. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 7       | —     |
| todo         | —     | —       | 12    |
| in-progress  | 1     | 2       | 0     |
| review       | —     | —       | 5     |
| blocked      | —     | —       | 0     |
| done         | 0     | 0       | 7     |
| cancelled    | 0     | 0       | 0     |

`todo` by priority: 2× P1 · 8× P2 · 2× P3.

## In progress now

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set
  - **STORY-001** Bootstrap the universal layer on this repo
  - **STORY-002** adopt-project — the brownfield front door

_No task is currently in-progress — the whole epic is parked on verification debt (below)._

## In review

⚠ **Verification debt (5)**, down from 10. Every task below is code-complete with unrun checks.

- **TASK-002** Scaffold the universal layer onto this repo (STORY-001) — `/roadmap` render and the adopt-project zero-gap pass are runnable here; the `@AGENTS.md` bridge check needs a session that isn't this one
- **TASK-004** adopt-project: infer conventions (STORY-002) — Presenter confirmed the evidence-shown and mixed-pattern lines. What is left needs **you**: the Symbio drill's whole value is an owner catching a plausible-but-wrong rule, and the WorkoutTracker half is gated on TASK-017
- **TASK-005** Layer parity (STORY-002) — the merge drill against an existing rich README is runnable as a fixture
- **TASK-006** verify-conventions finds the rulebook (loose) — a findings pass on a real Symbio diff, quoting its Slovak rule headings, is runnable
- **TASK-011** adopt-project installed in both runtimes (STORY-002) — junctions verified live; the fresh-session description match needs a new session

> **Where the pre-junction caveat now stands.** The STORY-002 drills that predate TASK-011's junction
> have been superseded rather than re-run from memory: the 2026-08-18 sweep re-surveyed six real repos
> through the *installed* skill and closed TASK-003, TASK-007, TASK-008, TASK-012 and TASK-018 on that
> evidence. What remains in review is there because it needs a fresh session or a human judgement, not
> because a drill is owed.

## Tree

```
EPIC-001  Adopt the yolobox skill ideas into the lifecycle set          [in-progress]
  STORY-001  Bootstrap the universal layer on this repo                 [in-progress]
    TASK-002   Scaffold the universal layer onto this repo              [review]
  STORY-002  adopt-project — the brownfield front door                  [in-progress]
    TASK-003   adopt-project: survey and fill                           [done]
    TASK-004   adopt-project: infer conventions, then grill             [review]
    TASK-005   Layer parity: LAYER.md shared by both front doors        [review]
    TASK-007   Do not offer CI a repo cannot pass                       [done]
    TASK-008   Survey must detect, not assume the seed layout           [done]
    TASK-011   adopt-project is not installed in either runtime         [review]
    TASK-012   Router teaches three survey states, LAYER.md four        [done]
    TASK-016   Installers only add — no missing/stale junction check    [todo] P2
    TASK-017   Step 2's inference round has no skip condition           [todo] P1
    TASK-018   Survey states and report buckets miss a re-run's cases   [done]
    TASK-019   new-project offers a CI stub a consumer cannot pass      [todo] P2
    TASK-020   Found defects get fixed but never get an id              [todo] P1
    TASK-021   Survey infers what the layer records as a declaration    [done]
    TASK-022   Adoption leaves generated files it invalidated           [todo] P2
  STORY-003  domain — glossary and decision records                     [planned]
  STORY-004  The durable question ledger                                [planned]
  STORY-005  The merge gate's third axis — verify-intent                [planned]
  STORY-006  Slicing doctrine and the state-model prototype branch      [planned]
  STORY-007  improve-architecture                                       [planned]
  STORY-008  Harvest the skill set's own specs                          [planned]
  STORY-009  Multi-repo adoption — one layer over many repositories     [planned]
```

## Loose tasks

- **TASK-001** STORY.md cannot express dependency edges — `todo`, P2
- **TASK-006** verify-conventions finds the rulebook — `review`, P1
- **TASK-009** verify-conventions has no rule about generated/vendored files — `todo`, P3
- **TASK-010** `/tasks pick` walks past verification debt without mentioning it — `todo`, P2
- **TASK-013** verify-conventions must say which sections it read — `todo`, P2
- **TASK-014** Architecture doc and changelog don't reflect the day's shipped skills — `todo`, P2
- **TASK-015** `close` step 5d needs an unattended path for fix-next — `todo`, P3
- **TASK-023** `/tasks init` reconciles an older config shape — **`done`** (drilled on Presenter's real config)
- **TASK-021**'s Presenter drill also landed in that repo: `86f24bf` on `main`, branch deleted only after being asked about
- **TASK-024** The other owner verbs can't say whether an artifact is current — `todo`, P2

_Seven tasks complete: the survey-behaviour set (TASK-003, 007, 008, 012, 018) closed on the 2026-08-18 six-repo sweep, plus TASK-021 and TASK-023. Story ordering lives in `EPIC-001/EPIC.md` § Sequence until TASK-001 gives stories real edge fields._
