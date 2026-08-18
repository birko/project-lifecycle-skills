# Tasks — The Project Lifecycle Skills

_Generated 2026-08-18. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 7       | —     |
| todo         | —     | —       | 8     |
| in-progress  | 1     | 2       | 0     |
| review       | —     | —       | 7     |
| blocked      | —     | —       | 0     |
| done         | 0     | 0       | 0     |
| cancelled    | 0     | 0       | 0     |

`todo` by priority: 2× P1 · 4× P2 · 2× P3.

## In progress now

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set
  - **STORY-001** Bootstrap the universal layer on this repo
  - **STORY-002** adopt-project — the brownfield front door

## In review

⚠ **Verification debt (7).** Every task below is code-complete with unrun checks. The repo's own
rule is to clear this before taking new scope.

- **TASK-002** Scaffold the universal layer onto this repo (STORY-001) — only the `@AGENTS.md` bridge check remains; needs a fresh session
- **TASK-003** adopt-project: survey and fill (STORY-002) — never run on a repo with code and **no** layer; fill exercised on one repo only
- **TASK-004** adopt-project: infer conventions (STORY-002) — drilled on BardStudio; **not** on Symbio/WorkoutTracker, where the failure mode is plausible-but-wrong rules
- **TASK-005** Layer parity (STORY-002) — merge drill on a repo with an existing README unrun
- **TASK-006** verify-conventions finds the rulebook (loose) — verified on Symbio; a findings pass on a hand-written diff there is still owed
- **TASK-007** Never offer CI a repo cannot pass (STORY-002) — verified on Latent/Presenter/flappy-dragon
- **TASK-008** Survey must detect, not assume (STORY-002) — re-surveyed 6 repos; Framework (multi-repo) excluded

> Every STORY-002 drill above predates TASK-011: none of them could have invoked the installed
> skill, because no junction for it exists yet. Read them as repo-copy drills until that is fixed.

## Tree

```
EPIC-001  Adopt the yolobox skill ideas into the lifecycle set          [in-progress]
  STORY-001  Bootstrap the universal layer on this repo                 [in-progress]
    TASK-002   Scaffold the universal layer onto this repo              [review]
  STORY-002  adopt-project — the brownfield front door                  [in-progress]
    TASK-003   adopt-project: survey and fill                           [review]
    TASK-004   adopt-project: infer conventions, then grill             [review]
    TASK-005   Layer parity: LAYER.md shared by both front doors        [review]
    TASK-007   Do not offer CI a repo cannot pass                       [review]
    TASK-008   Survey must detect, not assume the seed layout           [review]
    TASK-011   adopt-project is not installed in either runtime         [todo] P1
    TASK-012   Router teaches three survey states, LAYER.md four        [todo] P1
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

_No completed work yet. Story ordering lives in `EPIC-001/EPIC.md` § Sequence until TASK-001 gives stories real edge fields._
