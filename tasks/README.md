# Tasks — The Project Lifecycle Skills

> ⚠ **Feature drift (3):** EPIC-001, EPIC-002, EPIC-003 DV5 — tasks tracked in one tree only, with no `feature:` link; TASK-191 DV3 — under EPIC-004 (slug-matches FEATURE-002) with `feature: null`; docs/specs DV7 — all 14 mapped areas never generated (no `docs/specs/<area>.md` exists) — run `/roadmap --check`.

_Generated 2026-09-26. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics | Stories | Tasks |
|--------------|-------|---------|-------|
| planned      | 0     | 4       | —     |
| todo         | —     | —       | 39    |
| in-progress  | 5     | 9       | 0     |
| review       | —     | —       | 2     |
| blocked      | —     | —       | 0     |
| done         | 0     | 8       | 130   |
| cancelled    | 0     | 0       | 20    |

`todo` by priority: 1× P1 · 33× P2 · 5× P3.

## In progress now

_None_

## In review

_Code complete, sign-off pending — verification debt; close these before new scope._

- [TASK-186](EPIC-005-task-worktrees/STORY-021-task-in-own-checkout/TASK-186.md) Remote mode hides a session's own in-progress task from `fix-next` step 0 and from the `pick` list (P1) — manual step unrun
- [TASK-188](EPIC-005-task-worktrees/STORY-021-task-in-own-checkout/TASK-188.md) A worktree-parked `review` task is invisible to verification-debt surfacing; a remote-mode in-place fallback leaves its remote branch (P2) — manual step unrun

## Tree

- **EPIC-001** Adopt the yolobox skill ideas into the lifecycle set — in-progress (30/48 tasks done)
  - STORY-001 Bootstrap the universal layer on this repo — (done) (1/1)
  - STORY-002 `adopt-project` — the brownfield front door — (done) (15/15)
  - STORY-003 `domain` — glossary and decision records — (done) (7/7)
  - STORY-004 The durable question ledger — make `/feature new` survive a session reset — planned (0/6)
    - [ ] [TASK-114](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-114.md) The question table — the shape every other task in this story reads
    - [ ] [TASK-115](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-115.md) `/feature new` writes the frontier it could not reach, instead of losing it
    - ~~TASK-116 `/feature pick` gains one branch: open questions outstanding, resume at the frontier~~ → merged into TASK-115
    - [ ] [TASK-117](EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-117.md) `grill-me` switches from one question at a time to frontier rounds
    - ~~TASK-118 `research` becomes a question type that dispatches a sub-agent, not a skill of its own~~ → merged into TASK-117
    - ~~TASK-119 `feature` reconciles an `idea.md` written before the question table existed~~ → merged into TASK-114
  - STORY-005 The merge gate's third axis — `verify-intent` and the smell baseline — (done) (4/4)
  - STORY-006 Slicing doctrine and the state-model prototype branch — planned (0/4)
    - [ ] [TASK-122](EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-122.md) The slicing doctrine — what "atomic and independently completable" actually means
    - ~~TASK-123 Wide refactors — the case no vertical slice can cover, sequenced expand → migrate → contract~~ → merged into TASK-122
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
    - ~~TASK-113 Five capabilities a consumer would expect have no area, and one of them is writing the code~~ → merged into TASK-105
  - STORY-009 Multi-repo adoption — one layer over many repositories — planned (0/1)
    - [ ] [TASK-059](EPIC-001-adopt-yolobox-ideas/STORY-009-multi-repo-adoption/TASK-059.md) Reconcile the already-adopted repos against the grown layer

- **EPIC-002** Close-gate findings on the skill set — in-progress (49/83 tasks done) · `kind: review-intake`
  - STORY-010 `verify-conventions` — what the lint skips and what it fails to say — (done) (2/2)
  - STORY-011 The `tasks` skill's own defects — templates, pick, close, triage, intake — in-progress (10/17)
    - [ ] [TASK-001](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-001.md) STORY.md cannot express dependency edges
    - [x] TASK-010 /tasks pick walks past verification debt without mentioning it
    - [x] TASK-015 `close` step 5d needs an unattended path — fix-next drives close with no user to take the offer
    - [x] TASK-030 `close`'s single-branch SHA backfill instructs an impossible amend
    - [x] TASK-039 The dashboard template has no slot for the todo-by-priority breakdown
    - [x] TASK-041 `intake --adopt` cannot adopt a loose backlog — it assumes the epic already owns its tasks
    - [x] TASK-042 Nothing says where a new task is filed, so findings land where nothing can rank them
    - [x] TASK-044 EPIC-002 groups by subject, so `fix-next`'s theme tie-breaker has nothing to read
    - [x] TASK-050 `--unattended` promises what it does not deliver — `close` still stops to ask in three other places
    - [x] TASK-057 Four summaries that contradict the body they summarise
    - [x] TASK-073 Should the task template stop carrying an enum comment that shadows its own field?
    - ~~TASK-083 `fix-next` step 8 states two different counts of the same event, one sentence apart~~ → merged into TASK-135
    - [ ] [TASK-107](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-107.md) The acquisition-line rule will have no enforcement point, so a drill record can omit it silently
    - [ ] [TASK-120](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-120.md) `pick`'s handoff branches on an `assignee:` value no task in the tree has
    - [ ] [TASK-135](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-135.md) `/fix-next` picks a task without ever offering the plan `/tasks pick` would have offered
    - ~~TASK-180 `/tasks init` contradicts two sibling verbs — when mode detection runs, and whether a re-run writes~~ → merged into TASK-092
    - [ ] [TASK-182](EPIC-002-close-gate-findings/STORY-011-tasks-skill-defects/TASK-182.md) `/tasks pick` step 7's two questions carry no wording and no answer-less path
  - STORY-012 The universal layer — declarations that nobody owns, owner verbs that cannot reconcile — in-progress (6/12)
    - [ ] [TASK-024](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-024.md) The other owner verbs still cannot say whether an artifact is current
    - [x] TASK-027 `present, uncommitted` is blind to work that was staged but never committed
    - [ ] [TASK-028](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-028.md) The inference skip rule counts five subsections when one of them is conditional
    - [x] TASK-035 Nothing owns the `integration:` question — three rules each hand it to another
    - [ ] [TASK-085](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-085.md) `LAYER.md`'s survey-state list has outgrown the shape it is written in
    - [x] TASK-086 Adoption cannot tell its own unlanded writes from the user's work in progress
    - [ ] [TASK-092](EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-092.md) `/tasks init` cannot reach its own unresolved path, and cannot record a declination
    - [x] TASK-110 The scaffolder still gates two conditional rows on a kind list the inventory replaced with a question
    - ~~TASK-136 Three files state the `.env.example` condition as *reads*, two as *requires* — and the two answer differently~~ → merged into TASK-099
    - [x] TASK-138 A conditional row says what settles **Yes** and never what settles **No** — and a wrong No is the one state nothing reports
    - [x] TASK-149 Row 3 has no admission test — a plausible classification is taken for a determined one
    - ~~TASK-150 The `docs/architecture.md` row names a state but no fill action, and the two doors disagree~~ → merged into TASK-099
  - STORY-013 The drift audit — a check that cannot see prose, and a finding that cannot be accepted — in-progress (1/2)
    - [x] TASK-025 DV10's "real code" test cannot see a repo whose code is prose
    - [ ] [TASK-032](EPIC-002-close-gate-findings/STORY-013-roadmap-drift-audit/TASK-032.md) A divergence cannot be recorded as accepted, so triage nags about a decision already made
  - STORY-014 `specs` — two gates that pass without checking — in-progress (3/9)
    - [x] TASK-033 `/specs init`'s coverage check can pass vacuously
    - [x] TASK-036 `/specs regen`'s state gate can read the commented enum instead of the status
    - [x] TASK-087 A re-discovery rewrites `.map.yml` and nothing says the human's prose survives
    - ~~TASK-088 Nothing says whether one source file may belong to two capability areas~~ → merged into TASK-128
    - [ ] [TASK-089](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-089.md) `coverage: unverified` has never once been produced, across three drills
    - ~~TASK-111 regen.md quotes a status-comment format the task template no longer emits~~ → merged into TASK-105
    - [ ] [TASK-128](EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-128.md) Step 4 offers two exits for an unmapped file and the paragraph below it defines a third
    - ~~TASK-129 A project with fewer capabilities than the floor has no stated answer, so the guidance invites padding~~ → merged into TASK-128
    - ~~TASK-134 `/specs init` step 1's meta-root ask has no question text and no unattended path~~ → merged into TASK-182
  - STORY-015 CI lint and install integrity — the repo's only gate, and what it cannot see — in-progress (9/12)
    - [ ] [TASK-029](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-029.md) The lint's own coverage grew 16 to 25 cases with nothing recording what the nine pin
    - [x] TASK-037 Nothing detects a `skills-pi/` stub shadowing a real built-in
    - [x] TASK-043 The wikilink contract is only enforced inside `skills/`, and cannot naively be widened
    - [x] TASK-045 A flag one skill passes is never checked to exist in the receiving verb
    - [x] TASK-058 STORY-015's theme ranks the repo's only gate last
    - [x] TASK-071 The wikilink contract says "CI resolves it", and in `docs/` that is false
    - [ ] [TASK-074](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-074.md) A skill cannot reference a skill that does not exist yet
    - [x] TASK-081 One number now names two different lint checks
    - [x] TASK-082 Check 4 enforces something weaker than the contract it states
    - [ ] [TASK-084](EPIC-002-close-gate-findings/STORY-015-ci-lint-install-integrity/TASK-084.md) A documented probe-and-read rule has nothing that can pin it, and this one has been wrong twice
    - [x] TASK-108 Check 4 only sees a flag that immediately follows the verb, so a fifth of real invocations are unchecked
    - [x] TASK-171 `docs/architecture.md` still calls install-root drift "check 4"
  - STORY-016 The front doors under a cold drill — what the prose says versus what it does — in-progress (12/22)
    - [x] TASK-061 `LAYER.md` calls itself the whole layer while `new-project` creates three artifacts it never lists
    - [x] TASK-062 The test-harness ladder reports `missing` on the repo that ships it
    - [x] TASK-063 The upgrade path's headline case has no state and no remedy
    - [x] TASK-064 What a minimal repo gets: step 3 and the templates disagree, and one token has no source
    - [ ] [TASK-065](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-065.md) `adopt-project` assumes every run is a full run
    - [x] TASK-066 Land it or regenerate it: two rules point opposite ways at the same file
    - [ ] [TASK-067](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-067.md) Nobody says what the empty case looks like, so every agent invents one
    - [x] TASK-069 The ADR bar contradicts the split rule, and `close.md` contradicts the axis rule
    - [ ] [TASK-072](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-072.md) `populate-tests adopt` cannot wire a harness for a project with no package manager
    - ~~TASK-090 The survey cannot say whether this is a first adoption or a re-run~~ → merged into TASK-065
    - [x] TASK-091 Two artifact shapes the row definitions do not cover
    - [x] TASK-093 The guide row demands a diff against a section list no surveyed file carries
    - [x] TASK-094 Two survey instructions whose literal reading diverges from their intent
    - ~~TASK-095 "Thinly answered" has one calibration point, and two drills split on it~~ → merged into TASK-028
    - [x] TASK-096 A conditional row cannot say what "here" means, or which kind of env var counts
    - [x] TASK-097 `unknown` is the only container for two different situations, and one of them is not ignorance
    - [x] TASK-098 A row prescribes an action and is silent on the case where it is already done
    - [ ] [TASK-099](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-099.md) A row that names two artifacts never says whether the second carries its own state
    - [ ] [TASK-100](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-100.md) Step 3c derives its set from what a run *created*, and landing is the one act that invalidates without creating
    - ~~TASK-101 Two rows read one fact in opposite directions, because "a working runner" names no bar~~ → merged into TASK-072
    - [ ] [TASK-102](EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-102.md) Nothing says whether a step-3 fill offer joins step 2's round or comes after it
    - ~~TASK-112 The adopter's report list gained no entry for the `not applicable` state~~ → merged into TASK-085
  - **(epic level)**
    - [x] TASK-060 Triage the cold-drill findings on both front doors
    - [x] TASK-068 The cold drill — write down the one test method that works on prose
    - [x] TASK-106 A subagent spawned in this repo is never a cold reader, so the drill method cannot be run as written
    - [x] TASK-109 Two templates ship a live value their own rules say must be chosen, so a faithful render mints it
    - [x] TASK-126 Sweep every template for a shipped value its own skill says must be declared or derived
    - [x] TASK-127 Four steps say "ask the user" and none of them says what to ask, or what happens when nobody answers
    - [ ] [TASK-132](EPIC-002-close-gate-findings/TASK-132.md) Cold-drill the two render instructions TASK-126 wrote, because a faithful renderer is exactly what they address

- **EPIC-003** Defects found by using the skills, not by reviewing them — in-progress (3/7 tasks done) · `kind: review-intake`
  - STORY-017 Work that is filed correctly and reachable by nothing — in-progress (2/5)
    - [x] TASK-130 `/tasks` prescribes a polyrepo split it cannot then collect — sub-repo tasks are invisible from the aggregator
    - [x] TASK-131 `fix-next` names an opt-in for hand-filed defects that has no key — a field-found bug cannot mint a finding id
    - [ ] [TASK-133](EPIC-003-field-found-defects/STORY-017-reachability-across-repos/TASK-133.md) `spawn`'s pool rescue fires only for a review finding, so a field-shaped discovery still lands loose
    - ~~TASK-137 The `--from-field` door opens, but two of its edges are undefined — a cold runner reached both by inference~~ → merged into TASK-133
    - [ ] [TASK-139](EPIC-003-field-found-defects/STORY-017-reachability-across-repos/TASK-139.md) `nextUpTasks[]` sorts on two keys that routinely tie, and says nothing about the third
  - **(epic level)**
    - [ ] [TASK-161](EPIC-003-field-found-defects/TASK-161.md) A human test plan that ran and failed cannot be told from one that never ran
    - [x] TASK-190 pi refuses six skills: descriptions that are invalid YAML or over 1024 characters

- **EPIC-004** Comment discipline in agent-written code — in-progress (28/30 tasks done)
  - STORY-018 Seed the comment-discipline rule into both rulebooks — (done) (17/18)
  - STORY-019 `review-comments` — find comments that belong elsewhere, and move them there — (done) (6/6)
  - STORY-020 What FEATURE-002's review gate found unfinished — (done) (5/5)
  - **(epic level)**
    - [ ] [TASK-191](EPIC-004-comment-discipline/TASK-191.md) Re-measure the § Comments table for the two lint scripts TASK-190 changed

- **EPIC-005** Task worktrees — in-progress (13/15 tasks done)
  - STORY-021 Run a task in its own checkout — in-progress (13/15)
    - [x] TASK-173 Declare `workspace:` and `worktree-root:` in the tasks config · FEATURE-001
    - [x] TASK-174 `/tasks pick` creates the task worktree, asking for the root when undeclared · FEATURE-001
    - [x] TASK-175 `/tasks pick` proves the move into the worktree, and falls back when it cannot · FEATURE-001
    - [x] TASK-176 `/tasks close` merges from the worktree and removes it in a fixed order · FEATURE-001
    - [x] TASK-177 Ship `workspace:` / `worktree-root:` through both front doors · FEATURE-001
    - [x] TASK-178 Give drill checkouts a declared home and a cleanup rule · FEATURE-001
    - [x] TASK-179 End-to-end drill: pick → work → close in a worktree on a real consumer · FEATURE-001
    - [x] TASK-181 Resuming a task re-enters the worktree that holds its branch · FEATURE-001
    - [x] TASK-183 Worktree mode for projects whose default branch tracks a remote · FEATURE-001
    - [x] TASK-184 Tasks created in parallel worktrees can mint the same id · FEATURE-001
    - [x] TASK-185 `FEATURE-NNN` minted in parallel worktrees can collide too · FEATURE-001
    - [ ] [TASK-186](EPIC-005-task-worktrees/STORY-021-task-in-own-checkout/TASK-186.md) Remote mode hides a session's own in-progress task from `fix-next` step 0 and from the `pick` list 🔍 review · FEATURE-001
    - [x] TASK-187 The linked-worktree probe differs across verbs and gives a false positive from a subfolder; one report line is orphaned · FEATURE-001
    - [ ] [TASK-188](EPIC-005-task-worktrees/STORY-021-task-in-own-checkout/TASK-188.md) A worktree-parked `review` task is invisible to verification-debt surfacing; a remote-mode in-place fallback leaves its remote branch 🔍 review · FEATURE-001
    - [x] TASK-189 Register what FEATURE-001 introduced, and point the copied id-scope list at its owner · FEATURE-001

## Loose tasks

- ~~TASK-121 `/tasks pick` should offer to run the task in a subagent, and say when that is the wrong choice~~ → merged into TASK-120

_The other 7 loose tasks are `done` — listed under Completed._

<details>
<summary><strong>Completed</strong> — 8 done stories, 7 done loose tasks</summary>

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
- STORY-018 Seed the comment-discipline rule into both rulebooks — 17/18
  - [x] TASK-140 Add the comment-discipline rule to the seeded project rulebook · FEATURE-002
  - [x] TASK-141 Adopt the comment rule in this repo, with the lint-script measurement that protects it · FEATURE-002
  - ~~TASK-145 Stop the scaffolder's "leave as-is" list going one short~~ · FEATURE-002
  - [x] TASK-146 Lint check: the rule's two copies must match · FEATURE-002
  - [x] TASK-147 The scaffolder paraphrases the seed's universal rules instead of copying them · FEATURE-002
  - [x] TASK-148 `pi-install.sh`'s header reproduces two ADRs instead of pointing at them · FEATURE-002
  - [x] TASK-151 The `AGENTS.md` comment measurement was under-evidenced, and this repo has real findings · FEATURE-002
  - [x] TASK-153 The 8-of-39 measurement has a fifth copy, in the test that pins it · FEATURE-002
  - [x] TASK-154 Two check headers in `skills-lint.sh` argue a case the rulebook already settled · FEATURE-002
  - [x] TASK-157 Six more comment findings in `skills-lint.sh`, one of them introduced by the task that was fixing them · FEATURE-002
  - [x] TASK-158 Four more restatements in `skills-lint.sh`, and two comments that should exist and don't · FEATURE-002
  - [x] TASK-159 The destination table has no row for the project's own guide · FEATURE-002
  - [x] TASK-160 The eight sites D15 made reportable · FEATURE-002
  - [x] TASK-162 `skills-lint-test.sh` was never swept, and it holds nine findings · FEATURE-002
  - [x] TASK-163 Comment findings the TASK-162 drill surfaced outside its nine · FEATURE-002
  - [x] TASK-164 Two single-reader comment findings from TASK-163's drill — borderline, grouped · FEATURE-002
  - [x] TASK-165 Three comments that restate the line beside them · FEATURE-002
  - [x] TASK-166 Clear the three findings every reader pair agrees on, before TASK-141's re-run · FEATURE-002
- STORY-019 `review-comments` — find comments that belong elsewhere, and move them there — 6/6
  - [x] TASK-142 Create the `review-comments` skill — the check and its two scopes · FEATURE-002
  - [x] TASK-143 The only-copy rule — relocate before deleting, never destroy the last record · FEATURE-002
  - [x] TASK-144 Wire `review-comments` into `/tasks close` as its own reported axis · FEATURE-002
  - [x] TASK-152 `review-comments` promises a `PATH` argument and never defines it · FEATURE-002
  - [x] TASK-155 One reader in six renders ⚠ where the severity table says 🛑 · FEATURE-002
  - [x] TASK-156 Two loose ends on the path scope: a header that varies, and a refusal nobody ran · FEATURE-002
- STORY-020 What FEATURE-002's review gate found unfinished — 5/5
  - [x] TASK-167 The close gate's own text still counts three axes after the fourth shipped · FEATURE-002
  - [x] TASK-168 `review-comments` shipped, and nothing that lists the skills mentions it · FEATURE-002
  - [x] TASK-169 The measurement table cannot be re-run from what AGENTS.md says · FEATURE-002
  - [x] TASK-170 An only-copy that belongs in the project's guide has no relocation target · FEATURE-002
  - [x] TASK-172 Three things Gate A's second run found in this story's own fixes · FEATURE-002

**Loose tasks** (`_loose/`, no parent epic):

- [x] TASK-006 verify-conventions reports "no conventions" on repos full of conventions
- [x] TASK-014 The repo's own records don't reflect the day's shipped skills (architecture doc + changelog)
- [x] TASK-023 `/tasks init` cannot reconcile a config written by an older version of itself
- [x] TASK-026 `/specs regen` attributes provenance on a mention, not on authorship
- [x] TASK-034 `tasks/README.md` holds narrative its own template cannot regenerate
- [x] TASK-038 The CI isolation check over-reports on any real .NET repo
- [x] TASK-040 The loose defect backlog is filed but unschedulable — nothing can drain 15 of its 17 tasks

</details>
