# Tasks — The Project Lifecycle Skills

_Generated 2026-08-18. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 7       | —     |
| todo         | —     | —       | 13    |
| in-progress  | 1     | 1       | 0     |
| review       | —     | —       | 1     |
| blocked      | —     | —       | 0     |
| done         | 0     | 1       | 11    |
| cancelled    | 0     | 0       | 0     |

`todo` by priority: 2× P1 · 9× P2 · 2× P3.

## In progress now

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set
  - **STORY-002** adopt-project — the brownfield front door

_No task is currently in-progress — the whole epic is parked on verification debt (below)._

## In review

⚠ **Verification debt (1)**, down from 10 at the start of the day. The one remaining item is
**blocked in substance, not scheduling** — see below.

- **TASK-004** adopt-project: infer conventions (STORY-002) — **gated on TASK-017.** Its remaining line names Symbio, whose guide carries twelve `KRITICKE` rule sections in 1835 lines — the same condition that made the WorkoutTracker attempt produce nothing, since a well-behaved step 2 should skip or scope itself there. Forcing it now yields either redundant proposals or another improvised skip. Once TASK-017 lands, the valuable target is a **thin** rulebook (BardStudio: `## Key Conventions`, four rules) where a wrong proposal is both likely and catchable


> **The pre-junction caveat is retired.** The drills that predated TASK-011's junction were
> superseded, not re-run from memory: the 2026-08-18 six-repo sweep plus the fixture work closed
> TASK-002, 003, 005, 006, 007, 008, 012, 018, 021 and 023 on fresh evidence through the installed
> skills.

## Tree

```
EPIC-001  Adopt the yolobox skill ideas into the lifecycle set          [in-progress]
  STORY-001  Bootstrap the universal layer on this repo                 [done]
    TASK-002   Scaffold the universal layer onto this repo              [done]
  STORY-002  adopt-project — the brownfield front door                  [in-progress]
    TASK-003   adopt-project: survey and fill                           [done]
    TASK-004   adopt-project: infer conventions, then grill             [review]
    TASK-005   Layer parity: LAYER.md shared by both front doors        [done]
    TASK-007   Do not offer CI a repo cannot pass                       [done]
    TASK-008   Survey must detect, not assume the seed layout           [done]
    TASK-011   adopt-project is not installed in either runtime         [done]
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
- **TASK-006** verify-conventions finds the rulebook — **`done`** (Symbio's Slovak rulebook quoted back in a finding; true-negative preserved)
- **TASK-009** verify-conventions has no rule about generated/vendored files — `todo`, P3
- **TASK-010** `/tasks pick` walks past verification debt without mentioning it — `todo`, P2
- **TASK-013** verify-conventions must say which sections it read — `todo`, P2
- **TASK-014** Architecture doc and changelog don't reflect the day's shipped skills — `todo`, P2
- **TASK-015** `close` step 5d needs an unattended path for fix-next — `todo`, P3
- **TASK-023** `/tasks init` reconciles an older config shape — **`done`** (drilled on Presenter's real config)
- **TASK-021**'s Presenter drill also landed in that repo: `86f24bf` on `main`, branch deleted only after being asked about
- **TASK-024** The other owner verbs can't say whether an artifact is current — `todo`, P2
- **TASK-025** DV10 cannot see a repo whose code is prose — `todo`, P2

_Eleven tasks complete and STORY-001 closed. The survey-behaviour set (TASK-003, 007, 008, 012, 018) closed on the 2026-08-18 six-repo sweep; TASK-002, 005 and 006 on the fixture round; TASK-021 and TASK-023 on the Presenter drill. Story ordering lives in `EPIC-001/EPIC.md` § Sequence until TASK-001 gives stories real edge fields._
