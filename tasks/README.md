# Tasks — The Project Lifecycle Skills

_Generated 2026-08-18. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 7       | —     |
| todo         | —     | —       | 3     |
| in-progress  | 1     | 2       | 0     |
| review       | —     | —       | 6     |
| blocked      | —     | —       | 0     |
| done         | 0     | 0       | 0     |
| cancelled    | 0     | 0       | 0     |

## In progress now

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set
  - **STORY-001** Bootstrap the universal layer on this repo
  - **STORY-002** adopt-project — the brownfield front door

## In review

- **TASK-002** Scaffold the universal layer onto this repo (STORY-001) — CI has not run on Linux
- **TASK-003** adopt-project: survey and fill (STORY-002) — drill on other repos unrun
- **TASK-004** adopt-project: infer conventions, then grill (STORY-002) — needs a real codebase
- **TASK-005** Layer parity: LAYER.md shared by both front doors (STORY-002) — merge drill unrun
- **TASK-007** Do not offer CI a repo cannot pass (STORY-002) — found by the Latent drill

## Tree

```
EPIC-001  Adopt the yolobox skill ideas into the lifecycle set          [in-progress]
  STORY-001  Bootstrap the universal layer on this repo                 [in-progress]
    TASK-002   Scaffold the universal layer onto this repo              [review]
  STORY-002  adopt-project — the brownfield front door                  [in-progress]
    TASK-003   adopt-project: survey and fill                           [review]
    TASK-004   adopt-project: infer conventions, then grill             [review]
    TASK-005   Layer parity: backport brownfield rules to new-project   [review]
    TASK-007   Do not offer CI a repo cannot pass                       [review]
    TASK-008   Survey must detect, not assume the seed layout           [todo]
  STORY-003  domain — glossary and decision records                     [planned]
  STORY-004  The durable question ledger                                [planned]
  STORY-005  The merge gate's third axis — verify-intent                [planned]
  STORY-006  Slicing doctrine and the state-model prototype branch      [planned]
  STORY-007  improve-architecture                                       [planned]
  STORY-008  Harvest the skill set's own specs                          [planned]
```

## Loose tasks

- **TASK-001** STORY.md cannot express dependency edges — `todo`, P2
- **TASK-006** verify-conventions reports "no conventions" on repos full of conventions — `review`, P1
- **TASK-009** verify-conventions has no rule about generated/vendored files — `todo`, P3

_No completed work yet. Story ordering is recorded in `EPIC-001/EPIC.md` § Sequence until TASK-001 gives stories real edge fields._
