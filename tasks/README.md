# Tasks — The Project Lifecycle Skills

> ⚠ **Feature drift (1):** EPIC-001 + EPIC-002 DV5 — tasks tracked in one tree only, `docs/features/` holds no feature folders — run `/roadmap --check`.

_Generated 2026-08-23. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 9       | —     |
| todo         | —     | —       | 29    |
| in-progress  | 2     | 5       | 0     |
| review       | —     | —       | 0     |
| blocked      | —     | —       | 0     |
| done         | 0     | 4       | 44    |
| cancelled    | 0     | 0       | 0     |

## In progress now

_None_

## Tree

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set — in-progress (25/29 tasks done)
  - STORY-001 Bootstrap the universal layer on this repo — (done) (1/1)
  - STORY-002 `adopt-project` — the brownfield front door — (done) (15/15)
  - STORY-003 `domain` — glossary and decision records — in-progress (5/8)
    - [x] TASK-051 `domain` — the skill and its glossary half
    - [x] TASK-052 `domain`'s decision-record half — the three-part bar and where records live
    - [x] TASK-053 Layer parity — both front doors learn the glossary and the ADR home
    - [x] TASK-054 Backfill the decision records this repo already owes
    - [x] TASK-055 `tdd` still says nothing creates `docs/adr/`
    - [ ] [TASK-056](EPIC-001-adopt-yolobox-ideas/STORY-003-domain-skill/TASK-056.md) The seeded rulebook never learns where a term or a decision goes
    - [ ] [TASK-070](EPIC-001-adopt-yolobox-ideas/STORY-003-domain-skill/TASK-070.md) The decline clauses the rulebook owes — and one record it actually does
  - STORY-004 The durable question ledger — make `/feature new` survive a session reset — planned (0/0)
  - STORY-005 The merge gate's third axis — `verify-intent` and the smell baseline — (done) (4/4)
  - STORY-006 Slicing doctrine and the state-model prototype branch — planned (0/0)
  - STORY-007 `improve-architecture` — make the codebase itself a subject of the lifecycle — planned (0/0)
  - STORY-008 Harvest the skill set's own specs — planned (0/0)
  - STORY-009 Multi-repo adoption — one layer over many repositories — planned (0/1)
    - [ ] [TASK-059](EPIC-001-adopt-yolobox-ideas/STORY-009-multi-repo-adoption/TASK-059.md) Reconcile the already-adopted repos against the grown layer

- **EPIC-002** Close-gate findings on the skill set — in-progress (12/39 tasks done) · `kind: review-intake`
  - STORY-010 `verify-conventions` — what the lint skips and what it fails to say — (done) (2/2)
  - STORY-011 The `tasks` skill's own defects — templates, pick, close, triage, intake — in-progress (4/11)
    - [x] TASK-015 `close` step 5d needs an unattended path — fix-next drives close with no user to take the offer
    - [x] TASK-044 EPIC-002 groups by subject, so `fix-next`'s theme tie-breaker has nothing to read
    - [x] TASK-050 `--unattended` promises what it does not deliver — `close` still stops to ask in three other places
    - [ ] [TASK-001](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-001.md) STORY.md cannot express dependency edges
    - [ ] [TASK-010](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-010.md) /tasks pick walks past verification debt without mentioning it
    - [ ] [TASK-030](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-030.md) `close`'s single-branch SHA backfill instructs an impossible amend
    - [ ] [TASK-039](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-039.md) The dashboard template has no slot for the todo-by-priority breakdown
    - [ ] [TASK-041](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-041.md) `intake --adopt` cannot adopt a loose backlog — it assumes the epic already owns its tasks
    - [ ] [TASK-042](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-042.md) Nothing says where a new task is filed, so findings land where nothing can rank them
    - [x] TASK-057 Four summaries that contradict the body they summarise
    - [ ] [TASK-073](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-073.md) Should the task template stop carrying an enum comment that shadows its own field?
  - STORY-012 The universal layer — declarations that nobody owns, owner verbs that cannot reconcile — planned (0/4)
    - [ ] [TASK-024](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-024.md) The other owner verbs still cannot say whether an artifact is current
    - [ ] [TASK-027](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-027.md) `present, uncommitted` is blind to work that was staged but never committed
    - [ ] [TASK-028](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-028.md) The inference skip rule counts five subsections when one of them is conditional
    - [ ] [TASK-035](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-035.md) Nothing owns the `integration:` question — three rules each hand it to another
  - STORY-013 The drift audit — a check that cannot see prose, and a finding that cannot be accepted — planned (0/2)
    - [ ] [TASK-025](EPIC-002-close-gate-findings/STORY-013-roadmap-drift-audit/TASK-025.md) DV10's "real code" test cannot see a repo whose code is prose
    - [ ] [TASK-032](EPIC-002-close-gate-findings/STORY-013-roadmap-drift-audit/TASK-032.md) A divergence cannot be recorded as accepted, so triage nags about a decision already made
  - STORY-014 `specs` — two gates that pass without checking — in-progress (1/2)
    - [ ] [TASK-033](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-033.md) `/specs init`'s coverage check can pass vacuously
    - [x] TASK-036 `/specs regen`'s state gate can read the commented enum instead of the status
  - STORY-015 CI lint and install integrity — the repo's only gate, and what it cannot see — in-progress (2/6)
    - [x] TASK-037 Nothing detects a `skills-pi/` stub shadowing a real built-in
    - [ ] [TASK-029](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-029.md) The lint's own coverage grew 16 to 25 cases with nothing recording what the nine pin
    - [ ] [TASK-043](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-043.md) The wikilink contract is only enforced inside `skills/`, and cannot naively be widened
    - [ ] [TASK-045](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-045.md) A flag one skill passes is never checked to exist in the receiving verb
    - [x] TASK-058 STORY-015's theme ranks the repo's only gate last
    - [ ] [TASK-071](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-071.md) The wikilink contract says "CI resolves it", and in `docs/` that is false
  - STORY-016 The front doors under a cold drill — what the prose says versus what it does — in-progress (2/9)
    - [ ] [TASK-061](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-061.md) `LAYER.md` calls itself the whole layer while `new-project` creates three artifacts it never lists
    - [x] TASK-062 The test-harness ladder reports `missing` on the repo that ships it
    - [ ] [TASK-063](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-063.md) The upgrade path's headline case has no state and no remedy
    - [ ] [TASK-064](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-064.md) What a minimal repo gets: step 3 and the templates disagree, and one token has no source
    - [ ] [TASK-065](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-065.md) `adopt-project` assumes every run is a full run
    - [ ] [TASK-066](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-066.md) Land it or regenerate it: two rules point opposite ways at the same file
    - [ ] [TASK-067](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-067.md) Nobody says what the empty case looks like, so every agent invents one
    - [ ] [TASK-072](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-072.md) `populate-tests adopt` cannot wire a harness for a project with no package manager
    - [x] TASK-069 The ADR bar contradicts the split rule, and `close.md` contradicts the axis rule
  - **(epic level)**
    - [x] TASK-060 Triage the cold-drill findings on both front doors
    - [ ] [TASK-068](EPIC-002-close-gate-findings/TASK-068.md) The cold drill — write down the one test method that works on prose (P1)

## Loose tasks

_All 7 loose tasks are `done` — listed under Completed._

<details>
<summary><strong>Completed</strong> — 4 done stories, 7 done loose tasks</summary>

**Done stories in active epics** (kept in the tree above, task lists collapsed here):

- STORY-001 Bootstrap the universal layer on this repo — 1/1
  - [x] TASK-002 Scaffold the universal layer onto this repo
- STORY-002 `adopt-project` — the brownfield front door — 15/15
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
- STORY-005 The merge gate's third axis — `verify-intent` and the smell baseline — 4/4
  - [x] TASK-046 `verify-intent` — the fidelity axis, grounded in the task's acceptance criteria
  - [x] TASK-047 `verify-intent` reads the feature ledger and the specs, not just the task
  - [x] TASK-048 The smell baseline — `verify-conventions` has something to say about a repo that documented nothing
  - [x] TASK-049 Two axes at the gate, reported side by side and never reranked into one list
- STORY-010 `verify-conventions` — what the lint skips and what it fails to say — 2/2
  - [x] TASK-009 verify-conventions has no rule about generated and vendored files
  - [x] TASK-013 verify-conventions must say which sections it read — the output format has no slot for it

**Loose tasks** (`_loose/`, no parent epic):

- [x] TASK-006 verify-conventions reports "no conventions" on repos full of conventions
- [x] TASK-014 The repo's own records don't reflect the day's shipped skills (architecture doc + changelog)
- [x] TASK-023 `/tasks init` cannot reconcile a config written by an older version of itself
- [x] TASK-026 `/specs regen` attributes provenance on a mention, not on authorship
- [x] TASK-034 `tasks/README.md` holds narrative its own template cannot regenerate
- [x] TASK-038 The CI isolation check over-reports on any real .NET repo
- [x] TASK-040 The loose defect backlog is filed but unschedulable — nothing can drain 15 of its 17 tasks

</details>
