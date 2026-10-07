# Tasks — project-lifecycle-skills

> ⚠ **Feature drift (2):** EPIC-001, EPIC-002, EPIC-003, EPIC-007 DV5 — tasks tracked in one tree only, with no feature folder and no `feature:` link; docs/specs DV7 — 6 of 14 mapped areas never generated (test-authoring, glossary-and-adrs, changelog-maintenance, session-handoff, installation, skill-authoring-rules; the 8 generated areas are fresh) — run `/roadmap --check`.

_Generated 2026-10-07 08:28. Run `/tasks triage` to refresh. **Do not hand-edit** — changes will be overwritten._

## Counts

| Status       | Epics              | Stories            | Tasks               |
|--------------|--------------------|--------------------|---------------------|
| planned      | 1                  | 3                  | —                   |
| todo         | —                  | —                  | 84                  |
| in-progress  | 4                  | 10                 | 0                   |
| verify       | —                  | —                  | 1                   |
| blocked      | —                  | —                  | 1 (1 also counted in its own state) |
| done         | 3                  | 12                 | 177                 |
| cancelled    | 0                  | 0                  | 20                  |

`todo` by priority: 1× P1 · 73× P2 · 10× P3.

## In progress now


## Awaiting verification

- [TASK-124](EPIC-001-adopt-yolobox-ideas/STORY-006-slicing-doctrine/TASK-124.md) — `/feature prototype` gains a fourth form — "does this state model feel right?" (P2, agent) ⚠ blocked: deferred by the owner — waiting for a tester who does not know this codebase

## Tree

- EPIC-001 Adopt the yolobox skill ideas into the lifecycle set — in-progress (48/57 tasks done)
  - STORY-001 Bootstrap the universal layer on this repo — 1/1 done (done)
    - [x] TASK-002 Scaffold the universal layer onto this repo
  - STORY-002 `adopt-project` — the brownfield front door — 15/15 done (done)
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
  - STORY-003 `domain` — glossary and decision records — 7/7 done (done)
    - [x] TASK-051 `domain` — the skill and its glossary half
    - [x] TASK-052 `domain`'s decision-record half — the three-part bar and where records live
    - [x] TASK-053 Layer parity — both front doors learn the glossary and the ADR home
    - [x] TASK-054 Backfill the decision records this repo already owes
    - [x] TASK-055 `tdd` still says nothing creates `docs/adr/`
    - [x] TASK-056 The seeded rulebook never learns where a term or a decision goes
    - [x] TASK-070 The decline clauses the rulebook owes — and one record it actually does
  - STORY-004 The durable question ledger — make `/feature new` survive a session reset — 5/8 done (done)
    - [x] TASK-114 `feature` reconciles an `idea.md` written before the question table existed
    - [x] TASK-115 Open questions survive a session reset — the question table, written by `/feature new`, resumed by `/feature pick`
    - ~~TASK-116 `/feature pick` gains one branch: open questions outstanding, resume at the frontier~~
    - [x] TASK-117 `grill-me` switches from one question at a time to frontier rounds
    - ~~TASK-118 `research` becomes a question type that dispatches a sub-agent, not a skill of its own~~
    - ~~TASK-119 `feature` reconciles an `idea.md` written before the question table existed~~
    - [x] TASK-195 Re-slice STORY-004 by the slicing doctrine before any of its tasks is picked
    - [x] TASK-257 Two sessions never answer the same open question — `claimed-by`
  - STORY-005 The merge gate's third axis — `verify-intent` and the smell baseline — 4/4 done (done)
    - [x] TASK-046 `verify-intent` — the fidelity axis, grounded in the task's acceptance criteria
    - [x] TASK-047 `verify-intent` reads the feature ledger and the specs, not just the task
    - [x] TASK-048 The smell baseline — `verify-conventions` has something to say about a repo that documented nothing
    - [x] TASK-049 Two axes at the gate, reported side by side and never reranked into one list
  - STORY-006 Slicing doctrine and the state-model prototype branch — in-progress (2/4 done)
    - [x] TASK-122 The slicing doctrine — what "atomic and independently completable" actually means
    - ~~TASK-123 Wide refactors — the case no vertical slice can cover, sequenced expand → migrate → contract~~
    - [ ] TASK-124 `/feature prototype` gains a fourth form — "does this state model feel right?" 🔍 verify ⚠ blocked: deferred by the owner — waiting for a tester who does not know this codebase
    - [x] TASK-125 A prototype-derived snippet may enter a decision — the one exception to "no code in decisions"
  - STORY-007 `improve-architecture` — make the codebase itself a subject of the lifecycle — 10/10 done (done)
    - [x] TASK-075 Backfill the four ideas `improve-architecture` will need into `tdd`'s existing files
    - [x] TASK-076 `improve-architecture` — the skill, its scoping pass, and the candidate filter
    - [x] TASK-077 The report surface — an Artifact, a fallback, and what each candidate must carry
    - [x] TASK-078 Findings end at `/tasks intake`, and the skill is actually installed
    - [x] TASK-262 `intake` states the shape of a "Findings dropped at intake" entry, because another skill now reads it
    - [x] TASK-263 `improve-architecture`'s candidate key is unstable, and most rejections can never be re-checked
    - [x] TASK-265 Rung 2 does not say whether a candidate outside the hot spots is raised, so two runs of one repo differ
    - [x] TASK-266 Classes 1 and 4 both fire on co-change across modules, so one finding gets two different keys
    - [x] TASK-267 Whether a candidate "concerns one member" is a judgement, so two runs key one finding differently
    - [x] TASK-270 `intake` cannot file an epic for a small architecture run, or a new epic for its re-run
  - STORY-008 Harvest the skill set's own specs — in-progress (4/7 done)
    - [x] TASK-079 `/specs init` — build the area map, and turn the spec layer on
    - [x] TASK-080 `/specs regen` — generate the specs, and review the diff as the deliverable
    - [x] TASK-103 Four capability areas are named for the product's shape rather than a consumer's need
    - [x] TASK-104 Merge the three diff-review areas into one, because that is how they are used
    - [ ] TASK-105 `change-review` and `work-tracking` describe the same gate in near-identical words
    - ~~TASK-113 Five capabilities a consumer would expect have no area, and one of them is writing the code~~
    - [ ] TASK-281 Three specs omit behaviour their sources state
  - STORY-009 Multi-repo adoption — one layer over many repositories — planned (0/1 done)
    - [ ] TASK-059 Reconcile the already-adopted repos against the grown layer

- EPIC-002 Close-gate findings on the skill set — in-progress (50/94 tasks done)
  - STORY-010 `verify-conventions` — what the lint skips and what it fails to say — 2/2 done (done)
    - [x] TASK-009 verify-conventions has no rule about generated and vendored files
    - [x] TASK-013 verify-conventions must say which sections it read — the output format has no slot for it
  - STORY-011 The `tasks` skill's own defects — templates, pick, close, triage, intake — in-progress (10/21 done)
    - [ ] TASK-001 STORY.md cannot express dependency edges
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
    - ~~TASK-083 `fix-next` step 8 states two different counts of the same event, one sentence apart~~
    - [ ] TASK-107 The acquisition-line rule will have no enforcement point, so a drill record can omit it silently
    - [ ] TASK-120 `pick`'s handoff branches on an `assignee:` value no task in the tree has
    - [ ] TASK-135 `/fix-next` picks a task without ever offering the plan `/tasks pick` would have offered
    - ~~TASK-180 `/tasks init` contradicts two sibling verbs — when mode detection runs, and whether a re-run writes~~
    - [ ] TASK-182 `/tasks pick` step 7's two questions carry no wording and no answer-less path
    - [ ] TASK-212 Six older gaps in `block`, `close`, `init` 3b and the task template, found at the TASK-209, -214 and -215 closes
    - [ ] TASK-218 `/tasks migrate` leaves its dry run, its confirmation and its hand-off to `export` undefined
    - [ ] TASK-254 `pick`'s in-place fallback with an upstream never says where the status flip is committed
    - [ ] TASK-255 `pick`'s list output leaves five rendering details for each reader to settle
  - STORY-012 The universal layer — declarations that nobody owns, owner verbs that cannot reconcile — in-progress (6/12 done)
    - [ ] TASK-024 The other owner verbs still cannot say whether an artifact is current
    - [x] TASK-027 `present, uncommitted` is blind to work that was staged but never committed
    - [ ] TASK-028 The inference skip rule counts five subsections when one of them is conditional
    - [x] TASK-035 Nothing owns the `integration:` question — three rules each hand it to another
    - [ ] TASK-085 `LAYER.md`'s survey-state list has outgrown the shape it is written in
    - [x] TASK-086 Adoption cannot tell its own unlanded writes from the user's work in progress
    - [ ] TASK-092 `/tasks init` cannot reach its own unresolved path, and cannot record a declination
    - [x] TASK-110 The scaffolder still gates two conditional rows on a kind list the inventory replaced with a question
    - ~~TASK-136 Three files state the `.env.example` condition as *reads*, two as *requires* — and the two answer differently~~
    - [x] TASK-138 A conditional row says what settles **Yes** and never what settles **No** — and a wrong No is the one state nothing reports
    - [x] TASK-149 Row 3 has no admission test — a plausible classification is taken for a determined one
    - ~~TASK-150 The `docs/architecture.md` row names a state but no fill action, and the two doors disagree~~
  - STORY-013 The drift audit — a check that cannot see prose, and a finding that cannot be accepted — in-progress (1/3 done)
    - [x] TASK-025 DV10's "real code" test cannot see a repo whose code is prose
    - [ ] TASK-032 A divergence cannot be recorded as accepted, so triage nags about a decision already made
    - [ ] TASK-207 DV1 cannot fire on a feature with no `status.md`, and its condition reads two ways
  - STORY-014 `specs` — two gates that pass without checking — in-progress (3/9 done)
    - [x] TASK-033 `/specs init`'s coverage check can pass vacuously
    - [x] TASK-036 `/specs regen`'s state gate can read the commented enum instead of the status
    - [x] TASK-087 A re-discovery rewrites `.map.yml` and nothing says the human's prose survives
    - ~~TASK-088 Nothing says whether one source file may belong to two capability areas~~
    - [ ] TASK-089 `coverage: unverified` has never once been produced, across three drills
    - ~~TASK-111 regen.md quotes a status-comment format the task template no longer emits~~
    - [ ] TASK-128 Step 4 offers two exits for an unmapped file and the paragraph below it defines a third
    - ~~TASK-129 A project with fewer capabilities than the floor has no stated answer, so the guidance invites padding~~
    - ~~TASK-134 `/specs init` step 1's meta-root ask has no question text and no unattended path~~
  - STORY-015 CI lint and install integrity — the repo's only gate, and what it cannot see — in-progress (10/15 done)
    - [ ] TASK-029 The lint's own coverage grew 16 to 25 cases with nothing recording what the nine pin
    - [x] TASK-037 Nothing detects a `skills-pi/` stub shadowing a real built-in
    - [x] TASK-043 The wikilink contract is only enforced inside `skills/`, and cannot naively be widened
    - [x] TASK-045 A flag one skill passes is never checked to exist in the receiving verb
    - [x] TASK-058 STORY-015's theme ranks the repo's only gate last
    - [x] TASK-071 The wikilink contract says "CI resolves it", and in `docs/` that is false
    - [ ] TASK-074 A skill cannot reference a skill that does not exist yet
    - [x] TASK-081 One number now names two different lint checks
    - [x] TASK-082 Check 4 enforces something weaker than the contract it states
    - [ ] TASK-084 A documented probe-and-read rule has nothing that can pin it, and this one has been wrong twice
    - [x] TASK-108 Check 4 only sees a flag that immediately follows the verb, so a fifth of real invocations are unchecked
    - [x] TASK-171 `docs/architecture.md` still calls install-root drift "check 4"
    - [x] TASK-252 CI has been red on Linux since 2026-09-19 while the lint suite passes locally
    - [ ] TASK-253 `/tasks close` trusts a local test run where the project's CI runs elsewhere
    - [ ] TASK-282 The `.ps1` installers do not parse under Windows PowerShell 5.1, the default `.ps1` host on Windows
  - STORY-016 The front doors under a cold drill — what the prose says versus what it does — in-progress (12/22 done)
    - [x] TASK-061 `LAYER.md` calls itself the whole layer while `new-project` creates three artifacts it never lists
    - [x] TASK-062 The test-harness ladder reports `missing` on the repo that ships it
    - [x] TASK-063 The upgrade path's headline case has no state and no remedy
    - [x] TASK-064 What a minimal repo gets: step 3 and the templates disagree, and one token has no source
    - [ ] TASK-065 `adopt-project` assumes every run is a full run
    - [x] TASK-066 Land it or regenerate it: two rules point opposite ways at the same file
    - [ ] TASK-067 Nobody says what the empty case looks like, so every agent invents one
    - [x] TASK-069 The ADR bar contradicts the split rule, and `close.md` contradicts the axis rule
    - [ ] TASK-072 `populate-tests adopt` cannot wire a harness for a project with no package manager
    - ~~TASK-090 The survey cannot say whether this is a first adoption or a re-run~~
    - [x] TASK-091 Two artifact shapes the row definitions do not cover
    - [x] TASK-093 The guide row demands a diff against a section list no surveyed file carries
    - [x] TASK-094 Two survey instructions whose literal reading diverges from their intent
    - ~~TASK-095 "Thinly answered" has one calibration point, and two drills split on it~~
    - [x] TASK-096 A conditional row cannot say what "here" means, or which kind of env var counts
    - [x] TASK-097 `unknown` is the only container for two different situations, and one of them is not ignorance
    - [x] TASK-098 A row prescribes an action and is silent on the case where it is already done
    - [ ] TASK-099 A row that names two artifacts never says whether the second carries its own state
    - [ ] TASK-100 Step 3c derives its set from what a run *created*, and landing is the one act that invalidates without creating
    - ~~TASK-101 Two rows read one fact in opposite directions, because "a working runner" names no bar~~
    - [ ] TASK-102 Nothing says whether a step-3 fill offer joins step 2's round or comes after it
    - ~~TASK-112 The adopter's report list gained no entry for the `not applicable` state~~
  - (epic level) — 6/9 done
    - [x] TASK-060 Triage the cold-drill findings on both front doors
    - [x] TASK-068 The cold drill — write down the one test method that works on prose
    - [x] TASK-106 A subagent spawned in this repo is never a cold reader, so the drill method cannot be run as written
    - [x] TASK-109 Two templates ship a live value their own rules say must be chosen, so a faithful render mints it
    - [x] TASK-126 Sweep every template for a shipped value its own skill says must be declared or derived
    - [x] TASK-127 Four steps say "ask the user" and none of them says what to ask, or what happens when nobody answers
    - [ ] TASK-132 Cold-drill the two render instructions TASK-126 wrote, because a faithful renderer is exactly what they address
    - [ ] TASK-210 Examples in skill text are invented, never lifted from a repo the skill is drilled on
    - [ ] TASK-216 Two cross-skill rules in use are missing from AGENTS.md § Conventions
    - [ ] TASK-264 `feature prototype` decides whether it can publish from "the runtime", not from the session's tools

- EPIC-003 Defects found by using the skills, not by reviewing them — in-progress (5/9 tasks done)
  - STORY-017 Work that is filed correctly and reachable by nothing — in-progress (2/5 done)
    - [x] TASK-130 `/tasks` prescribes a polyrepo split it cannot then collect — sub-repo tasks are invisible from the aggregator
    - [x] TASK-131 `fix-next` names an opt-in for hand-filed defects that has no key — a field-found bug cannot mint a finding id
    - [ ] TASK-133 `spawn`'s pool rescue fires only for a review finding, so a field-shaped discovery still lands loose
    - ~~TASK-137 The `--from-field` door opens, but two of its edges are undefined — a cold runner reached both by inference~~
    - [ ] TASK-139 `nextUpTasks[]` sorts on two keys that routinely tie, and says nothing about the third
  - (epic level) — 3/4 done
    - [ ] TASK-161 A human test plan that ran and failed cannot be told from one that never ran
    - [x] TASK-190 pi refuses six skills: descriptions that are invalid YAML or over 1024 characters
    - [x] TASK-192 `export` and `pick` take a task's title from a `#` comment inside its frontmatter
    - [x] TASK-206 The id scan misses task files with Windows line endings, so a new task can reuse a number

- EPIC-007 First spec harvest review 2026-10 — in-progress (3/46 tasks done)
  - STORY-023 Behaviour that leaves the task tree contradicting itself — in-progress (3/28 done)
    - [ ] TASK-220 Two verbs leave a `blocked:` field behind that `audit` then reports
    - [ ] TASK-221 `cancel` and container close disagree about cancelled work
    - [ ] TASK-222 `new` and Jira import offer only P0–P2
    - [ ] TASK-223 A taken task is "shown as in progress", but no index says where it is counted
    - [ ] TASK-227 `fix-next` step 8 writes a log line after `close` has committed, so the run never ends clean
    - [ ] TASK-228 `fix-next` does not say where a run goes after an outcome that is not a fix
    - [ ] TASK-229 `fix-next`'s ask-steps carry no question and no answer-less path, in a skill built to run unattended
    - [ ] TASK-230 `/specs regen`'s two ask-steps carry no question and no answer-less path
    - [ ] TASK-231 `roadmap` states DV10's trigger twice, and the two statements contradict
    - [ ] TASK-232 DV5 flags every story that has no feature behind it, including the ones that should not have one
    - [ ] TASK-233 `/roadmap --across` does not say how it combines with an epic scope, or what it prints when nothing is found
    - [ ] TASK-234 `/feature status` re-collects what it was told to consume, and its phase rules leave ledgers with no phase
    - [ ] TASK-235 `/feature review` closes open tasks after a gate that stops on open tasks
    - [x] TASK-242 `new-project`'s fill steps can ship unrendered tokens, and run a remote command before the repo exists
    - [x] TASK-243 Two `LAYER.md` rows disagree with the front door that implements them
    - [ ] TASK-244 The adopter's inference rules leave one case unruled, and write where they say to write nothing
    - [ ] TASK-245 `verify-conventions` contradicts itself on the empty rulebook, drift severity, and where to register a pattern
    - [ ] TASK-246 `verify-intent` never maps its classes to severities, and leaves "which task" open
    - [ ] TASK-247 The review axes ask the user things with no question text and no unanswered path
    - [ ] TASK-256 `adopt-project` adds the seed's missing sections with their tokens unrendered
    - [ ] TASK-258 A question the grill drops or defers during `/feature new` has nowhere to land in the table
    - [ ] TASK-259 `grill-me` has no answer-less path: with nobody to answer, it neither ends nor reports
    - [ ] TASK-272 `/populate-tests survey` promises no edits, but chains `adopt`, which writes files
    - [ ] TASK-273 Ask-steps in `tdd`, `populate-tests`, `domain` and `roll-changelog` state no question or no answer-less path
    - [x] TASK-277 The installers report success for links they did not make, and the bash and PowerShell versions fail differently
    - [ ] TASK-278 Lint check 1 passes descriptions pi will not load, and AGENTS.md overclaims checks 1 and 4
    - [ ] TASK-279 `improve-architecture`'s records line cannot say what happened when filing fails or nothing is found
    - [ ] TASK-280 `improve-architecture`: the item 4 gate maps no result, and a held move whose ADR is gone has no outcome
  - STORY-024 Lists, labels and references that no longer match what they describe — planned (0/18 done)
    - [ ] TASK-224 Two restated lists of verbs have drifted from the verbs
    - [ ] TASK-225 Two sentences still describe the task states before FEATURE-003
    - [ ] TASK-226 Three references point at things that do not exist
    - [ ] TASK-236 `roadmap`'s renders and output model have drifted from the collection they describe
    - [ ] TASK-237 Three skills still advise a project-local skill that shadows them, which does not work
    - [ ] TASK-238 `/specs verify` and `show` restate the router's and `regen`'s rules, and the copies have drifted
    - [ ] TASK-239 The spec template emits a key `regen` says to omit, and `regen`'s steps run out of order
    - [ ] TASK-240 Three `feature` records name no writer, or several: the prototype line, `superseded`, and the index row
    - [ ] TASK-241 Three stale words in `feature`: a count, a citation and a list of forms
    - [ ] TASK-248 The seed templates describe a project that `new-project` does not build
    - [ ] TASK-249 The adopter's files cite rules a consumer does not have, and miscount their own buckets
    - [ ] TASK-250 The pi review fallbacks have drifted from the axes they stand in for
    - [ ] TASK-251 `review-comments` miscounts its PATH rules and offers a range it has no syntax for
    - [ ] TASK-260 `grill-me`'s description has no Slovak triggers and predates the skill it describes
    - [ ] TASK-271 Three shipped skills point at things a consumer install does not have
    - [ ] TASK-274 `roll-changelog`: a dangling skeleton link, two definitions of its boundary, an undeclared flag, and an empty release
    - [ ] TASK-275 `domain` is told it audits ADR drift but has no pass for it, and two of its pointers are wrong
    - [ ] TASK-276 `handoff` has no trigger phrases, and never says where its document went

- EPIC-008 architecture — rung 2 review 2026-10 — planned (0/2 tasks done)
  - STORY-025 Changes that ripple across skill folders — planned (0/2 done)
    - [ ] TASK-268 A change to a cross-skill contract ripples through up to 21 files in six skill folders
    - [ ] TASK-269 `adopt-project` changes with `new-project`'s LAYER.md in 19 commits, and both keep needing fixes

## Loose tasks

- [x] TASK-006 verify-conventions reports "no conventions" on repos full of conventions (P1, unassigned)
- [x] TASK-014 The repo's own records don't reflect the day's shipped skills (architecture doc + changelog) (P2, unassigned)
- [x] TASK-023 `/tasks init` cannot reconcile a config written by an older version of itself (P1, agent)
- [x] TASK-026 `/specs regen` attributes provenance on a mention, not on authorship (P1, agent)
- [x] TASK-034 `tasks/README.md` holds narrative its own template cannot regenerate (P2, agent)
- [x] TASK-038 The CI isolation check over-reports on any real .NET repo (P1, agent)
- [x] TASK-040 The loose defect backlog is filed but unschedulable — nothing can drain 15 of its 17 tasks (P1, agent)
- ~~TASK-121 `/tasks pick` should offer to run the task in a subagent, and say when that is the wrong choice~~ (P2, agent)
- [x] TASK-191 Re-measure the § Comments table for the two lint scripts TASK-190 changed (P3, unassigned)
- [ ] TASK-261 Run the deletion test on the three `help` verb files, and keep or fold each one (P3, agent)

<details>
<summary><strong>Completed</strong> — 3 epics</summary>

- EPIC-004 Comment discipline in agent-written code — done (28/29 tasks done)
  - STORY-018 Seed the comment-discipline rule into both rulebooks — 17/18 done (done)
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
  - STORY-019 `review-comments` — find comments that belong elsewhere, and move them there — 6/6 done (done)
    - [x] TASK-142 Create the `review-comments` skill — the check and its two scopes · FEATURE-002
    - [x] TASK-143 The only-copy rule — relocate before deleting, never destroy the last record · FEATURE-002
    - [x] TASK-144 Wire `review-comments` into `/tasks close` as its own reported axis · FEATURE-002
    - [x] TASK-152 `review-comments` promises a `PATH` argument and never defines it · FEATURE-002
    - [x] TASK-155 One reader in six renders ⚠ where the severity table says 🛑 · FEATURE-002
    - [x] TASK-156 Two loose ends on the path scope: a header that varies, and a refusal nobody ran · FEATURE-002
  - STORY-020 What FEATURE-002's review gate found unfinished — 5/5 done (done)
    - [x] TASK-167 The close gate's own text still counts three axes after the fourth shipped · FEATURE-002
    - [x] TASK-168 `review-comments` shipped, and nothing that lists the skills mentions it · FEATURE-002
    - [x] TASK-169 The measurement table cannot be re-run from what AGENTS.md says · FEATURE-002
    - [x] TASK-170 An only-copy that belongs in the project's guide has no relocation target · FEATURE-002
    - [x] TASK-172 Three things Gate A's second run found in this story's own fixes · FEATURE-002

- EPIC-005 Task worktrees — done (17/17 tasks done)
  - STORY-021 Run a task in its own checkout — 17/17 done (done)
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
    - [x] TASK-186 Remote mode hides a session's own in-progress task from `fix-next` step 0 and from the `pick` list · FEATURE-001
    - [x] TASK-187 The linked-worktree probe differs across verbs and gives a false positive from a subfolder; one report line is orphaned · FEATURE-001
    - [x] TASK-188 A worktree-parked `review` task is invisible to verification-debt surfacing; a remote-mode in-place fallback leaves its remote branch · FEATURE-001
    - [x] TASK-189 Register what FEATURE-001 introduced, and point the copied id-scope list at its owner · FEATURE-001
    - [x] TASK-193 "Local mode" names two unrelated settings, and a cold runner read one as the other · FEATURE-001
    - [x] TASK-194 `pick` step 3 leaves open whether this machine's tasks also appear as `taken`, and step 9 calls `gh` in local mode · FEATURE-001

- EPIC-006 Task states follow common practice — done (18/18 tasks done)
  - STORY-022 "Blocked" becomes a flag, and "review" becomes "verify" — 18/18 done (done)
    - [x] TASK-196 Expand: the `tasks` skill reads both the old and the new status forms · FEATURE-003
    - [x] TASK-197 Migrate: the `feature` skill reads `verify` and the blocked flag · FEATURE-003
    - [x] TASK-198 Migrate: `roadmap`'s cross-tree pass reads `verify` and the blocked flag · FEATURE-003
    - [x] TASK-199 Migrate: `fix-next` reads the new form and skips a blocked task it ranks first · FEATURE-003
    - [x] TASK-200 Migrate: `specs regen`'s state gate reads `verify` · FEATURE-003
    - [x] TASK-201 Migrate: both front doors ship the new status vocabulary · FEATURE-003
    - [x] TASK-202 Migrate: tracker sync maps the blocked flag to a GitHub label and Jira's Flagged field · FEATURE-003
    - [x] TASK-203 Migrate: a one-time migration that rewrites old-form task files · FEATURE-003
    - [x] TASK-204 Contract: every writer switches to the new form · FEATURE-003
    - [x] TASK-205 Run the migration on this repo and every consumer repo · FEATURE-003
    - [x] TASK-208 The migration writes "reason unknown" over a block reason the file already states · FEATURE-003
    - [x] TASK-209 Edge cases in the blocked-field writers that predate the reason ladder · FEATURE-003
    - [x] TASK-211 Migrate Presenter's task tree once its local work reaches origin · FEATURE-003
    - [x] TASK-213 The old `review` and `blocked` wording still ships in writers, front doors and the `block` intro · FEATURE-003
    - [x] TASK-214 `/tasks close` finishes a blocked task, against FEATURE-003 D7 · FEATURE-003
    - [x] TASK-215 The `blocked:` writers do not quote their value, and two readers of the block note are undeclared · FEATURE-003
    - [x] TASK-217 `/tasks migrate` never exports a task awaiting verification · FEATURE-003
    - [x] TASK-219 A task blocked on another task drops out of `fix-next`, and a few labels still say `review` · FEATURE-003

</details>
