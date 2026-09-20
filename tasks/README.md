# Tasks — The Project Lifecycle Skills

> ⚠ **Feature drift (1):** EPIC-001, EPIC-002, EPIC-003 DV5 — tasks tracked in one tree only, with no `feature:` link. `docs/features/` now holds FEATURE-001 and FEATURE-002 (EPIC-004 is linked to the latter) — run `/roadmap --check`.

_Generated 2026-09-20. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 5       | —     |
| todo         | —     | —       | 61    |
| in-progress  | 4     | 9       | 0     |
| review       | —     | —       | 1     |
| blocked      | —     | —       | 0     |
| done         | 0     | 5       | 96    |
| cancelled    | 0     | 0       | 1     |

`todo` by priority: 1× P1 · 44× P2 · 16× P3.

## In progress now

_None_

## In review (awaiting sign-off)

- [TASK-141](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-141.md) — Adopt the comment rule in this repo, with the lint-script measurement that protects it (P1, unassigned) · FEATURE-002

## Tree

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set — in-progress (30/48 tasks done)
  - STORY-001 Bootstrap the universal layer on this repo — (done) (1/1)
  - STORY-002 `adopt-project` — the brownfield front door — (done) (15/15)
  - STORY-003 `domain` — glossary and decision records — (done) (7/7)
  - STORY-004 The durable question ledger — make `/feature new` survive a session reset — planned (0/6)
    - [ ] [TASK-114](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-114.md) The question table — the shape every other task in this story reads
    - [ ] [TASK-115](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-115.md) `/feature new` writes the frontier it could not reach, instead of losing it
    - [ ] [TASK-116](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-116.md) `/feature pick` gains one branch: open questions outstanding, resume at the frontier
    - [ ] [TASK-117](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-117.md) `grill-me` switches from one question at a time to frontier rounds
    - [ ] [TASK-118](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-118.md) `research` becomes a question type that dispatches a sub-agent, not a skill of its own
    - [ ] [TASK-119](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-119.md) `feature` reconciles an `idea.md` written before the question table existed
  - STORY-005 The merge gate's third axis — `verify-intent` and the smell baseline — (done) (4/4)
  - STORY-006 Slicing doctrine and the state-model prototype branch — planned (0/4)
    - [ ] [TASK-122](EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-122.md) The slicing doctrine — what "atomic and independently completable" actually means
    - [ ] [TASK-123](EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-123.md) Wide refactors — the case no vertical slice can cover, sequenced expand → migrate → contract
    - [ ] [TASK-124](EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-124.md) `/feature prototype` gains a fourth form — "does this state model feel right?"
    - [ ] [TASK-125](EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-125.md) A prototype-derived snippet may enter a decision — the one exception to "no code in decisions"
  - STORY-007 `improve-architecture` — make the codebase itself a subject of the lifecycle — planned (0/4)
    - [ ] [TASK-075](EPIC-001-adopt-yolobox-ideas/STORY-007-improve-architecture/TASK-075.md) Backfill the four ideas `improve-architecture` will need into `tdd`'s existing files
    - [ ] [TASK-076](EPIC-001-adopt-yolobox-ideas/STORY-007-improve-architecture/TASK-076.md) `improve-architecture` — the skill, its scoping pass, and the candidate filter
    - [ ] [TASK-077](EPIC-001-adopt-yolobox-ideas/STORY-007-improve-architecture/TASK-077.md) The report surface — an Artifact, a fallback, and what each candidate must carry
    - [ ] [TASK-078](EPIC-001-adopt-yolobox-ideas/STORY-007-improve-architecture/TASK-078.md) Findings end at `/tasks intake`, and the skill is actually installed
  - STORY-008 Harvest the skill set's own specs — in-progress (3/6)
    - [x] TASK-079 `/specs init` — build the area map, and turn the spec layer on
    - [ ] [TASK-080](EPIC-001-adopt-yolobox-ideas/STORY-008-specs-regen/TASK-080.md) `/specs regen` — generate the specs, and review the diff as the deliverable ⚠ waits on STORY-004/006/007
    - [x] TASK-103 Four capability areas are named for the product's shape rather than a consumer's need
    - [x] TASK-104 Merge the three diff-review areas into one, because that is how they are used
    - [ ] [TASK-105](EPIC-001-adopt-yolobox-ideas/STORY-008-specs-regen/TASK-105.md) `change-review` and `work-tracking` describe the same gate in near-identical words
    - [ ] [TASK-113](EPIC-001-adopt-yolobox-ideas/STORY-008-specs-regen/TASK-113.md) Five capabilities a consumer would expect have no area, and one of them is writing the code
  - STORY-009 Multi-repo adoption — one layer over many repositories — planned (0/1)
    - [ ] [TASK-059](EPIC-001-adopt-yolobox-ideas/STORY-009-multi-repo-adoption/TASK-059.md) Reconcile the already-adopted repos against the grown layer

- **EPIC-002** Close-gate findings on the skill set — in-progress (45/79 tasks done) · `kind: review-intake`
  - STORY-010 `verify-conventions` — what the lint skips and what it fails to say — (done) (2/2)
  - STORY-011 The `tasks` skill's own defects — templates, pick, close, triage, intake — in-progress (10/15)
    - [x] TASK-015 `close` step 5d needs an unattended path — fix-next drives close with no user to take the offer
    - [x] TASK-044 EPIC-002 groups by subject, so `fix-next`'s theme tie-breaker has nothing to read
    - [x] TASK-050 `--unattended` promises what it does not deliver — `close` still stops to ask in three other places
    - [ ] [TASK-001](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-001.md) STORY.md cannot express dependency edges
    - [ ] [TASK-135](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-135.md) `/fix-next` picks a task without ever offering the plan `/tasks pick` would have offered
    - [x] TASK-010 /tasks pick walks past verification debt without mentioning it
    - [x] TASK-030 `close`'s single-branch SHA backfill instructs an impossible amend
    - [x] TASK-039 The dashboard template has no slot for the todo-by-priority breakdown
    - [x] TASK-041 `intake --adopt` cannot adopt a loose backlog — it assumes the epic already owns its tasks
    - [x] TASK-042 Nothing says where a new task is filed, so findings land where nothing can rank them
    - [x] TASK-057 Four summaries that contradict the body they summarise
    - [x] TASK-073 Should the task template stop carrying an enum comment that shadows its own field?
    - [ ] [TASK-083](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-083.md) `fix-next` step 8 states two different counts of the same event, one sentence apart
    - [ ] [TASK-107](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-107.md) The acquisition-line rule will have no enforcement point, so a drill record can omit it silently
    - [ ] [TASK-120](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-120.md) `pick`'s handoff branches on an `assignee:` value no task in the tree has
  - STORY-012 The universal layer — declarations that nobody owns, owner verbs that cannot reconcile — in-progress (6/12)
    - [ ] [TASK-024](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-024.md) The other owner verbs still cannot say whether an artifact is current
    - [x] TASK-027 `present, uncommitted` is blind to work that was staged but never committed
    - [ ] [TASK-028](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-028.md) The inference skip rule counts five subsections when one of them is conditional
    - [x] TASK-035 Nothing owns the `integration:` question — three rules each hand it to another
    - [ ] [TASK-085](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-085.md) `LAYER.md`'s survey-state list has outgrown the shape it is written in
    - [x] TASK-086 Adoption cannot tell its own unlanded writes from the user's work in progress
    - [ ] [TASK-092](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-092.md) `/tasks init` cannot reach its own unresolved path, and cannot record a declination
    - [x] TASK-110 The scaffolder still gates two conditional rows on a kind list the inventory replaced
    - [ ] [TASK-136](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-136.md) Three files state the `.env.example` condition as *reads*, two as *requires* — and the two answer differently
    - [x] TASK-138 A conditional row says what settles **Yes** and never what settles **No** — and a wrong No is the one state nothing reports
    - [x] TASK-149 Row 3 has no admission test — a plausible classification is taken for a determined one
    - [ ] [TASK-150](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-150.md) The `docs/architecture.md` row names a state but no fill action, and the two doors disagree
  - STORY-013 The drift audit — a check that cannot see prose, and a finding that cannot be accepted — in-progress (1/2)
    - [x] TASK-025 DV10's "real code" test cannot see a repo whose code is prose
    - [ ] [TASK-032](EPIC-002-close-gate-findings/STORY-013-roadmap-drift-audit/TASK-032.md) A divergence cannot be recorded as accepted, so triage nags about a decision already made
  - STORY-014 `specs` — two gates that pass without checking — in-progress (3/9)
    - [x] TASK-033 `/specs init`'s coverage check can pass vacuously
    - [x] TASK-087 A re-discovery rewrites `.map.yml` and nothing says the human's prose survives
    - [ ] [TASK-088](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-088.md) Nothing says whether one source file may belong to two capability areas
    - [ ] [TASK-089](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-089.md) `coverage: unverified` has never once been produced, across three drills
    - [ ] [TASK-111](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-111.md) `regen.md` quotes a status-comment format the task template no longer emits
    - [ ] [TASK-128](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-128.md) Step 4 offers two exits for an unmapped file and the paragraph below it defines a third
    - [ ] [TASK-129](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-129.md) A project with fewer capabilities than the floor has no stated answer, so the guidance invites padding
    - [ ] [TASK-134](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-134.md) `/specs init` step 1's meta-root ask has no question text and no unattended path
    - [x] TASK-036 `/specs regen`'s state gate can read the commented enum instead of the status
  - STORY-015 CI lint and install integrity — the repo's only gate, and what it cannot see — in-progress (7/11)
    - [x] TASK-037 Nothing detects a `skills-pi/` stub shadowing a real built-in
    - [ ] [TASK-029](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-029.md) The lint's own coverage grew 16 to 25 cases with nothing recording what the nine pin
    - [x] TASK-043 The wikilink contract is only enforced inside `skills/`, and cannot naively be widened
    - [x] TASK-045 A flag one skill passes is never checked to exist in the receiving verb
    - [x] TASK-058 STORY-015's theme ranks the repo's only gate last
    - [x] TASK-071 The wikilink contract says "CI resolves it", and in `docs/` that is false — folded into TASK-043
    - [ ] [TASK-074](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-074.md) A skill cannot reference a skill that does not exist yet
    - [ ] [TASK-081](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-081.md) One number now names two different lint checks
    - [x] TASK-082 Check 4 enforces something weaker than the contract it states
    - [ ] [TASK-084](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-084.md) A documented probe-and-read rule has nothing that can pin it
    - [x] [TASK-108](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-108.md) Check 4 only sees a flag that immediately follows the verb, so a fifth of real invocations are unchecked
  - STORY-016 The front doors under a cold drill — what the prose says versus what it does — in-progress (12/22)
    - [x] TASK-061 `LAYER.md` calls itself the whole layer while `new-project` creates three artifacts it never lists
    - [x] TASK-062 The test-harness ladder reports `missing` on the repo that ships it
    - [x] TASK-063 The upgrade path's headline case has no state and no remedy
    - [ ] [TASK-090](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-090.md) The survey cannot say whether this is a first adoption or a re-run
    - [x] TASK-091 Two artifact shapes the row definitions do not cover
    - [x] TASK-093 The guide row demands a diff against a section list no surveyed file carries
    - [x] TASK-094 Two survey instructions whose literal reading diverges from their intent
    - [ ] [TASK-095](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-095.md) "Thinly answered" has one calibration point, and two drills split on it
    - [x] TASK-096 A conditional row cannot say what "here" means, or which kind of env var counts
    - [x] TASK-097 `unknown` is the only container for two different situations, and one of them is not ignorance
    - [x] TASK-098 A row prescribes an action and is silent on the case where it is already done
    - [ ] [TASK-099](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-099.md) A row that names two artifacts never says whether the second carries its own state
    - [ ] [TASK-100](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-100.md) Step 3c derives its set from what a run *created*, and landing invalidates without creating
    - [ ] [TASK-101](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-101.md) Two rows read one fact in opposite directions, because "a working runner" names no bar
    - [ ] [TASK-102](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-102.md) Nothing says whether a step-3 fill offer joins step 2's round or comes after it
    - [ ] [TASK-112](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-112.md) The adopter's report list gained no entry for the `not applicable` state
    - [x] TASK-064 What a minimal repo gets: step 3 and the templates disagree, and one token has no source
    - [ ] [TASK-065](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-065.md) `adopt-project` assumes every run is a full run
    - [x] TASK-066 Land it or regenerate it: two rules point opposite ways at the same file
    - [ ] [TASK-067](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-067.md) Nobody says what the empty case looks like, so every agent invents one
    - [ ] [TASK-072](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-072.md) `populate-tests adopt` cannot wire a harness for a project with no package manager
    - [x] TASK-069 The ADR bar contradicts the split rule, and `close.md` contradicts the axis rule
  - **(epic level)**
    - [x] TASK-060 Triage the cold-drill findings on both front doors
    - [x] TASK-068 The cold drill — write down the one test method that works on prose
    - [x] TASK-106 A subagent spawned in this repo is never a cold reader, so the drill method cannot be run as written
    - [x] [TASK-109](EPIC-002-close-gate-findings/TASK-109.md) Two templates ship a live value their own rules say must be chosen, so a faithful render mints it
    - [x] [TASK-126](EPIC-002-close-gate-findings/TASK-126.md) Sweep every template for a shipped value its own skill says must be declared or derived
    - [x] TASK-127 Four steps say "ask the user" and none of them says what to ask, or what happens when nobody answers
    - [ ] [TASK-132](EPIC-002-close-gate-findings/TASK-132.md) Cold-drill the two render instructions TASK-126 wrote, because a faithful renderer is exactly what they address

- **EPIC-003** Defects found by using the skills, not by reviewing them — in-progress (2/5 tasks done)
  - STORY-017 Work that is filed correctly and reachable by nothing — in-progress (2/5)
    - [x] TASK-130 `/tasks` prescribes a polyrepo split it cannot then collect — sub-repo tasks are invisible from the aggregator
    - [ ] [TASK-139](EPIC-003-field-found-defects/STORY-017-reachability-across-repos/TASK-139.md) `nextUpTasks[]` sorts on two keys that routinely tie, and says nothing about the third
    - [x] TASK-131 `fix-next` names an opt-in for hand-filed defects that has no key — a field-found bug cannot mint a finding id
    - [ ] [TASK-137](EPIC-003-field-found-defects/STORY-017-reachability-across-repos/TASK-137.md) The `--from-field` door opens, but two of its edges are undefined — a cold runner reached both by inference
    - [ ] [TASK-133](EPIC-003-field-found-defects/STORY-017-reachability-across-repos/TASK-133.md) `spawn`'s pool rescue fires only for a review finding, so a field-shaped discovery still lands loose

## Loose tasks

- [ ] [TASK-121](_loose/TASK-121.md) `/tasks pick` should offer to run the task in a subagent, and say when that is the wrong choice (P2, agent)

_The other 7 loose tasks are `done` — listed under Completed._

<details>
<summary><strong>Completed</strong> — 5 done stories, 7 done loose tasks</summary>

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
- STORY-003 `domain` — glossary and decision records — 7/7
  - [x] TASK-051 `domain` — the skill and its glossary half
  - [x] TASK-052 `domain`'s decision-record half — the three-part bar and where records live
  - [x] TASK-053 Layer parity — both front doors learn the glossary and the ADR home
  - [x] TASK-054 Backfill the decision records this repo already owes
  - [x] TASK-055 `tdd` still says nothing creates `docs/adr/`
  - [x] TASK-056 The seeded rulebook never learns where a term or a decision goes
  - [x] TASK-070 The decline clauses the rulebook owes — and one record it actually does
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

### EPIC-004 — Comment discipline in agent-written code `in-progress`

- **STORY-018** — Seed the comment-discipline rule into both rulebooks `in-progress`
  - [TASK-140](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-140.md) `done` — the rule into `CLAUDE.seed.md` (cold drill 4/4)
  - [TASK-141](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-141.md) `review` P1 — reopened; test plan run, the file it was to exonerate is not clean
  - [TASK-148](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-148.md) `todo` P3 — `pi-install.sh` header reproduces two ADRs instead of pointing at them
  - [TASK-145](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-145.md) `cancelled` — work shipped in 5b8c216; remaining criterion became unmeetable when TASK-147 emptied the seed of static subsections
  - [TASK-147](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-147.md) `done` P1 — universal rules now spliced verbatim, both stacks
  - [TASK-151](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-151.md) `done` P2 — the AGENTS.md measurement was under-evidenced; 4 real findings in `skills-lint.sh`
  - [TASK-153](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-153.md) `todo` P3 — a fifth copy of the 8-of-39 measurement, in the test that pins it
  - [TASK-157](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-157.md) `done` P2 — six sites cut, destinations verified; two were mis-filed
  - [TASK-158](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-158.md) `todo` P3 — four restatements, and one comment that should exist and doesn't
  - [TASK-159](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-159.md) `todo` P2 — add the sixth destination row (FEATURE-002 D15, approved)
  - [TASK-154](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-154.md) `done` P3 — both headers now fact-then-pointer; verdict proven to read off the script
  - [TASK-146](EPIC-004-comment-discipline/STORY-018-seed-the-rule/TASK-146.md) `done` P2 — lint check 5 + 9 cases; suite 47 → 56
- **STORY-019** — `review-comments`, the command `planned`
  - [TASK-142](EPIC-004-comment-discipline/STORY-019-review-comments-skill/TASK-142.md) `done` P1 — the skill, both scopes; drill 4/4 + D14 + `--all`
  - [TASK-143](EPIC-004-comment-discipline/STORY-019-review-comments-skill/TASK-143.md) `done` P1 — only-copy relocation; drill filed a task and left pointers by id
  - [TASK-152](EPIC-004-comment-discipline/STORY-019-review-comments-skill/TASK-152.md) `done` P2 — `PATH …` defined as a whole-file sweep; 8 cold runners, 4 rounds
  - [TASK-144](EPIC-004-comment-discipline/STORY-019-review-comments-skill/TASK-144.md) `done` P2 — wired into `close` step 5b as its own axis; no flag passed
  - [TASK-155](EPIC-004-comment-discipline/STORY-019-review-comments-skill/TASK-155.md) `todo` P3 — one reader in six renders ⚠ where the severity table says 🛑
  - [TASK-156](EPIC-004-comment-discipline/STORY-019-review-comments-skill/TASK-156.md) `todo` P3 — a header that varies between readers, and a refusal nobody ran
