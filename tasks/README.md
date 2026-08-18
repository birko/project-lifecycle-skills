# Tasks — The Project Lifecycle Skills

_Generated 2026-08-18. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 7       | —     |
| todo         | —     | —       | 12    |
| in-progress  | 1     | 2       | 0     |
| review       | —     | —       | 11    |
| blocked      | —     | —       | 0     |
| done         | 0     | 0       | 0     |
| cancelled    | 0     | 0       | 0     |

`todo` by priority: 3× P1 · 7× P2 · 2× P3.

## In progress now

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set
  - **STORY-001** Bootstrap the universal layer on this repo
  - **STORY-002** adopt-project — the brownfield front door

_No task is currently in-progress — the whole epic is parked on verification debt (below)._

## In review

⚠ **Verification debt (11).** Every task below is code-complete with unrun checks. The repo's own
rule is to clear this before taking new scope.

- **TASK-002** Scaffold the universal layer onto this repo (STORY-001) — only the `@AGENTS.md` bridge check remains; needs a fresh session
- **TASK-003** adopt-project: survey and fill (STORY-002) — fill now exercised on Presenter (no agent guide at all), the target its plan named; the remaining lines are the pre-junction re-runs
- **TASK-004** adopt-project: infer conventions (STORY-002) — Presenter confirmed the evidence-shown and mixed-pattern lines; the WorkoutTracker attempt produced nothing (step 2 skipped, see TASK-017), and **declining** an inferred rule has still never been tested
- **TASK-005** Layer parity (STORY-002) — merge drill on a repo with an existing README unrun
- **TASK-006** verify-conventions finds the rulebook (loose) — verified on Symbio; a findings pass on a hand-written diff there is still owed
- **TASK-007** Never offer CI a repo cannot pass (STORY-002) — verified on Latent/Presenter/flappy-dragon, and on WorkoutTracker 2026-08-18 via the installed skill
- **TASK-008** Survey must detect, not assume (STORY-002) — re-surveyed 6 repos; Framework (multi-repo) excluded. WorkoutTracker re-verified 2026-08-18 through the installed skill
- **TASK-011** adopt-project installed in both runtimes (STORY-002) — junctions verified live; only the fresh-session description-match check remains
- **TASK-012** Router now teaches LAYER.md's four survey states (STORY-002) — all three drills need real repos: a .NET repo with sibling `*.Tests`, and one with a genuinely undeterminable row
- **TASK-018** Survey states and report buckets miss a re-run's cases (STORY-002) — 2 of 4 drills run: the scratch-clone fixture proves both new states (and that the old probe would have lost `tasks/.config.yml`); the WorkoutTracker re-drill and flappy-dragon remain
- **TASK-021** Survey infers what the layer records as a declaration (STORY-002) — rule written and gate-checked, but **ships ahead of TASK-023**: the Presenter re-drill cannot run until `/tasks init` can reconcile an old config

> The STORY-002 drills above predate TASK-011's junction, so — with one exception — none of
> them invoked the *installed* skill; the checked lines say so explicitly. They are evidence of
> behaviour, not of discovery; re-run each at its own close now that `adopt-project` resolves in
> both runtimes. The exception is the **WorkoutTracker drill of 2026-08-18**, the first run through
> the junction: it corroborated TASK-007 and TASK-008 and filed TASK-017 / TASK-018.

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
    TASK-011   adopt-project is not installed in either runtime         [review]
    TASK-012   Router teaches three survey states, LAYER.md four        [review]
    TASK-016   Installers only add — no missing/stale junction check    [todo] P2
    TASK-017   Step 2's inference round has no skip condition           [todo] P1
    TASK-018   Survey states and report buckets miss a re-run's cases   [review]
    TASK-019   new-project offers a CI stub a consumer cannot pass      [todo] P2
    TASK-020   Found defects get fixed but never get an id              [todo] P1
    TASK-021   Survey infers what the layer records as a declaration    [review]
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
- **TASK-023** `/tasks init` cannot reconcile an older config shape — `todo`, P1 (blocks TASK-021)

_No completed work yet. Story ordering lives in `EPIC-001/EPIC.md` § Sequence until TASK-001 gives stories real edge fields._
