# Tasks — The Project Lifecycle Skills

_Generated 2026-08-20. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 7       | —     |
| todo         | —     | —       | 18    |
| in-progress  | 1     | 0       | 0     |
| review       | —     | —       | 0     |
| blocked      | —     | —       | 0     |
| done         | 0     | 2       | 21    |
| cancelled    | 0     | 0       | 0     |

## In progress now

_None._

## Tree

- EPIC-001 Adopt the yolobox skill ideas into the lifecycle set — in-progress (16/16 tasks done)
  - STORY-001 Bootstrap the universal layer on this repo — done (1/1 done)
    - [x] TASK-002 Scaffold the universal layer onto this repo
  - STORY-002 `adopt-project` — the brownfield front door — done (15/15 done)
    - [x] TASK-003 adopt-project: survey and fill
    - [x] TASK-004 adopt-project: infer conventions from the code, then grill
    - [x] TASK-005 Layer parity: backport the brownfield rules into new-project
    - [x] TASK-007 Do not offer a CI gate a repo cannot possibly pass
    - [x] TASK-008 The survey must detect what a repo has, not check for the seed's layout
    - [x] TASK-011 `adopt-project` is not installed in either runtime — a new skill folder needs an installer re-run
    - [x] TASK-012 The adopt-project router still teaches three survey states; LAYER.md now mandates four
    - [x] TASK-016 The installers only ever add — nothing detects a missing or stale junction
    - [x] TASK-017 Step 2's inference round has no skip condition, so the skill improvises one
    - [x] TASK-018 The survey's state list and the report's buckets don't cover what a re-run actually hits
    - [x] TASK-019 new-project still offers a CI stub a fresh consumer cannot pass
    - [x] TASK-020 A defect found mid-adoption gets fixed and never gets an id
    - [x] TASK-021 The survey reads a repo's shape and history where the layer records a declared value
    - [x] TASK-022 Adoption invalidates generated files it never re-generates
    - [x] TASK-031 `missing, not offered` never reopens, even when a filed task removes the reason
  - STORY-003 `domain` — glossary and decision records — planned (0/0 done)
  - STORY-004 The durable question ledger — make `/feature new` survive a session reset — planned (0/0 done)
  - STORY-005 The merge gate's third axis — `verify-intent` and the smell baseline — planned (0/0 done)
  - STORY-006 Slicing doctrine and the state-model prototype branch — planned (0/0 done)
  - STORY-007 `improve-architecture` — make the codebase itself a subject of the lifecycle — planned (0/0 done)
  - STORY-008 Harvest the skill set's own specs — planned (0/0 done)
  - STORY-009 Multi-repo adoption — one layer over many repositories — planned (0/0 done)

## Loose tasks

- [ ] TASK-001 STORY.md cannot express dependency edges (P2, unassigned)
- [x] TASK-006 verify-conventions reports "no conventions" on repos full of conventions (P1, unassigned)
- [ ] TASK-009 verify-conventions has no rule about generated and vendored files (P3, unassigned)
- [ ] TASK-010 /tasks pick walks past verification debt without mentioning it (P2, unassigned)
- [ ] TASK-013 verify-conventions must say which sections it read — the output format has no slot for it (P2, unassigned)
- [ ] TASK-014 The repo's own records don't reflect the day's shipped skills (architecture doc + changelog) (P2, unassigned)
- [ ] TASK-015 `close` step 5d needs an unattended path — fix-next drives close with no user to take the offer (P3, unassigned)
- [x] TASK-023 `/tasks init` cannot reconcile a config written by an older version of itself (P1, agent)
- [ ] TASK-024 The other owner verbs still cannot say whether an artifact is current (P2, agent)
- [ ] TASK-025 DV10's "real code" test cannot see a repo whose code is prose (P2, agent)
- [x] TASK-026 `/specs regen` attributes provenance on a mention, not on authorship (P1, agent)
- [ ] TASK-027 `present, uncommitted` is blind to work that was staged but never committed (P2, agent)
- [ ] TASK-028 The inference skip rule counts five subsections when one of them is conditional (P2, agent)
- [ ] TASK-029 The lint's own coverage grew 16 to 25 cases with nothing recording what the nine pin (P3, agent)
- [ ] TASK-030 `close`'s single-branch SHA backfill instructs an impossible amend (P2, agent)
- [ ] TASK-032 A divergence cannot be recorded as accepted, so triage nags about a decision already made (P2, agent)
- [ ] TASK-033 `/specs init`'s coverage check can pass vacuously (P2, agent)
- [x] TASK-034 `tasks/README.md` holds narrative its own template cannot regenerate (P2, agent)
- [ ] TASK-035 Nothing owns the `integration:` question — three rules each hand it to another (P2, agent)
- [ ] TASK-036 `/specs regen`'s state gate can read the commented enum instead of the status (P2, agent)
- [ ] TASK-037 Nothing detects a `skills-pi/` stub shadowing a real built-in (P2, agent)
- [x] TASK-038 The CI isolation check over-reports on any real .NET repo (P1, agent)
- [ ] TASK-039 The dashboard template has no slot for the todo-by-priority breakdown (P3, agent)
