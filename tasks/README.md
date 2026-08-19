# Tasks — The Project Lifecycle Skills

_Generated 2026-08-19. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 7       | —     |
| todo         | —     | —       | 16    |
| in-progress  | 1     | 1       | 0     |
| review       | —     | —       | 0     |
| blocked      | —     | —       | 0     |
| done         | 0     | 1       | 14    |
| cancelled    | 0     | 0       | 0     |

`todo` by priority: 1× P1 · 12× P2 · 3× P3.

## In progress now

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set
  - **STORY-002** adopt-project — the brownfield front door

_No task is currently in-progress — the whole epic is parked on verification debt (below)._

## In review

**Verification debt: none.** It ran 9 at the start of 2026-08-18 and cleared the same day — the
six-repo sweep, the Presenter drill and the fixture rounds closed thirteen tasks on evidence rather
than on assertion. Two closes are worth reading before trusting the number:

- **TASK-004** was closed on **Presenter's** evidence, not on the Symbio/WorkoutTracker drill its plan named. With TASK-017's skip rule in place those repos correctly produce no inference round at all, so drilling them would prove the skip rather than the inference. The thing the line existed for — an owner catching a plausible-but-wrong proposal — did happen on Presenter, twice. The next genuinely unadopted repo is the better subject and does not exist yet.
- **TASK-018** stayed `done` while its deliverable changed: its untracked probe was blind to a tracked-but-uncommitted amendment, which is the commonest case on the upgrade path. Fixed and drilled in the same pass, recorded on the task as a follow-up drill rather than by reopening it.

## Tree

```
EPIC-001  Adopt the yolobox skill ideas into the lifecycle set          [in-progress]
  STORY-001  Bootstrap the universal layer on this repo                 [done]
    TASK-002   Scaffold the universal layer onto this repo              [done]
  STORY-002  adopt-project — the brownfield front door                  [in-progress]
    TASK-003   adopt-project: survey and fill                           [done]
    TASK-004   adopt-project: infer conventions, then grill             [done]
    TASK-005   Layer parity: LAYER.md shared by both front doors        [done]
    TASK-007   Do not offer CI a repo cannot pass                       [done]
    TASK-008   Survey must detect, not assume the seed layout           [done]
    TASK-011   adopt-project is not installed in either runtime         [done]
    TASK-012   Router teaches three survey states, LAYER.md four        [done]
    TASK-016   Installers only add — no missing/stale junction check    [todo] P2
    TASK-017   Step 2's inference round has no skip condition           [done]
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
- **TASK-026** `/specs regen` attributed provenance on a mention, not authorship — **`done`** (measured on Symbio: both known false positives gone, 96 of 246 attributions kept, `shaped-by-unresolved` 135 → 169)
- **TASK-027** `present, uncommitted` is blind to staged-but-uncommitted work — `todo`, P2
- **TASK-028** The inference skip rule counts an inapplicable subsection — `todo`, P2
- **TASK-029** The lint's own 16 → 25 case growth is unrecorded — `todo`, P3
- **TASK-030** `close`'s single-branch SHA backfill instructs an impossible amend — `todo`, P2

_Fourteen tasks complete and STORY-001 closed. The survey-behaviour set (TASK-003, 007, 008, 012,
018) closed on the 2026-08-18 six-repo sweep; TASK-002, 005 and 006 on the fixture round; TASK-021
and TASK-023 on the Presenter drill; TASK-026 on a scripted re-derivation over Symbio's 213
feature-linked tasks. TASK-027 to 029 are that task's `/code-review` findings from outside its own
diff, and TASK-030 is what its own close turned up — all four filed rather than folded in. Story ordering lives in `EPIC-001/EPIC.md` § Sequence until
TASK-001 gives stories real edge fields._
