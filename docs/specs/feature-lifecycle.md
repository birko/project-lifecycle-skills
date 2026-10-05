---
area: feature-lifecycle
generated-at: 7ed24786acac1c12e1acd2c3f7a3cf699afe0fc8
generated-on: 2026-10-04
sources:
  - skills/feature/SKILL.md
  - skills/feature/questions.md
  - skills/feature/templates/README.md.tmpl
  - skills/feature/templates/decisions.md
  - skills/feature/templates/idea.md
  - skills/feature/templates/status.md
  - skills/feature/verbs/decide.md
  - skills/feature/verbs/decompose.md
  - skills/feature/verbs/help.md
  - skills/feature/verbs/new.md
  - skills/feature/verbs/pick.md
  - skills/feature/verbs/prototype.md
  - skills/feature/verbs/review.md
  - skills/feature/verbs/show.md
  - skills/feature/verbs/status.md
shaped-by: [FEATURE-001, FEATURE-003]
shaped-by-derived: true
shaped-by-unresolved: 5
---

# The stakeholder-facing half — an idea to shipped, with every decision recorded

## Purpose

The feature lifecycle carries a raw idea through capture, interrogation, prototyping, stakeholder verdicts, decomposition into tracked tasks, a plain-language status rollup and a closing review gate, leaving a decision ledger that both developers and non-technical stakeholders can read. Each feature is a folder in the project's stakeholder-facing feature tree, separate from the developer task tree; the two are joined by a back-link each task carries to its feature. The task tracker, the roadmap's cross-tree engine, the spec harvester and the project scaffolder all depend on the shapes and states it maintains.

## Requirements

### Requirement: Verb routing and the bare listing

The system SHALL accept `/feature <verb>` for the verbs `new`, `prototype`, `decide`, `decompose`, `status`, `review`, `pick`, `show` and `help`, reading only the instructions of the verb requested, and SHALL treat a bare `/feature` with no verb as a request to list every feature with its decision counts and task progress, rendered from the shared cross-tree collection and optionally marking any feature the divergence audit flags.

#### Scenario: Bare invocation lists features

- **Given** a project with three feature folders
- **When** the user types `/feature` with no verb
- **Then** one line per feature is printed with its phase, decision counts by state and done/total task progress, and nothing is written

#### Scenario: Drift is marked on the listing

- **Given** the cross-tree audit reports a divergence on FEATURE-021
- **When** the bare listing is rendered
- **Then** FEATURE-021's line may carry one divergence mark naming the rule that fired

### Requirement: Help prints the verb table and nothing else

The system SHALL, on `/feature help`, print the verb table, the one-line lifecycle, the meaning of bare `/feature`, and a pointer that `/feature pick` is the entry for an existing feature, and then exit without doing anything else.

#### Scenario: Help is inert

- **Given** any project state
- **When** the user types `/feature help`
- **Then** the verb table and lifecycle line are printed and no file is read for state or written

### Requirement: Feature folders live under the project root, each with its own counter

The system SHALL place features in a `docs/features/` folder under the project root (found by walking up to a solution file, then a git root), creating that folder without disturbing other documentation when absent, placing a cross-cutting feature in a polyrepo family's aggregator repo and a sub-project feature in that sub-project's own repo, and SHALL mint `FEATURE-NNN` ids from their own global counter — separate from epic, story and task ids — by taking the highest id over every copy of the tree that can mint one, incrementing it and zero-padding to three digits, naming any copy it could not read.

#### Scenario: Next id is taken over every copy

- **Given** the main checkout holds FEATURE-004 and a parallel working copy holds FEATURE-006
- **When** a new feature is created
- **Then** it is numbered FEATURE-007

#### Scenario: An unreadable copy is reported

- **Given** one working copy of the tree cannot be read
- **When** `/feature new` mints an id
- **Then** its confirmation names that copy as unseen

#### Scenario: No docs folder yet

- **Given** a project with no `docs/` folder
- **When** a feature is created
- **Then** only `docs/features/` is created, not a full documentation tree

### Requirement: New captures an idea and grills it into proposed decisions

The system SHALL, on `/feature new`, interrogate the idea with the grill skill by default (skipping it only on `--no-grill` or when the user calls the feature trivial, falling back to a couple of clarifying questions), then write a stakeholder-readable idea file (problem, proposed shape, the grill's questions as an open-questions table, out of scope) with coarse status `idea`, and a decision ledger with one row per resolved branch — including any non-goal the user already named — every row in state `proposed` with date and decider left blank, plus a dated History seed line.

#### Scenario: Grilled idea seeds proposed rows

- **Given** a grill that resolves four branches, one of which the user called a non-goal
- **When** `/feature new` finishes
- **Then** the ledger has four rows, all `proposed`, with date and decider shown as `—`, and the History log has one creation line

#### Scenario: New never pre-stamps a verdict

- **Given** the user said during the grill "we definitely want offline mode"
- **When** the ledger is seeded
- **Then** that row is still `proposed`, awaiting `/feature decide`

#### Scenario: Confirmation offers the next verbs

- **Given** a feature just created with five proposed rows
- **When** `/feature new` confirms
- **Then** it prints the folder path, offers `/feature prototype` or `/feature decide`, and says five decisions await a verdict

### Requirement: Open questions survive the session as a table with a computed frontier

The system SHALL keep a feature's open questions as a table in its idea file — id, question, type (`decision` or `research`), blocked-by, state — defined in one owner file that every other reader points at. States SHALL be `open`, `resolved → Dn` (or `resolved — <fact>` for research that decides nothing) and `dropped — <reason>`, each set by a named step; dropping a question SHALL remove it from every blocked-by. The frontier SHALL be every open row whose blockers are all resolved, computed fresh and never stored; a blocker id missing from the table is a broken edge. A row SHALL hold only a question stated precisely as one sentence ending in `?`; vaguer concerns stay in a Fog list, and ruled-out scope is neither. On `/feature new` the system SHALL give each question its id and edges when raised, write unreached ones as `open`, write one of two explicit lines when none remain (all resolved, or `--no-grill`), and name the frontier in its closing output.

#### Scenario: A session cut short leaves its frontier on disk

- **Given** a grill that resolves Q1–Q3 and raises Q4 (waiting on Q1), Q5 (waiting on Q4) and Q7 (waiting on nothing) before the user leaves
- **When** `/feature new` finishes
- **Then** the table shows Q1–Q3 `resolved → D1`–`D3`, Q4, Q5 and Q7 `open` with those edges, and the closing output names Q4 and Q7 as the frontier

#### Scenario: Nothing left open is still written down

- **Given** a grill that resolved every question it raised
- **When** the idea file is written
- **Then** the section says the grill resolved every question it raised, and is never an empty table

#### Scenario: A vague worry is not a row

- **Given** the concern "something about making sure handover happens properly"
- **When** it is recorded
- **Then** it goes in the Fog list, not the table

### Requirement: New adopts a seeded stub instead of minting a duplicate

The system SHALL, when the idea being captured matches an existing stub feature — the user passed its id, or the title or slug clearly matches — adopt that folder in place, keeping its id and filling its idea and ledger, and SHALL ask when the match is plausible but not certain; it SHALL never mint a second id for a requirement that already has a tracked home.

#### Scenario: Explicit id adopts the stub

- **Given** a stub FEATURE-009 with status `idea` and near-empty sections
- **When** the user runs `/feature new FEATURE-009`
- **Then** FEATURE-009's files are filled in place and no new id is minted

#### Scenario: Uncertain match is asked

- **Given** a stub titled "Bulk export" and an idea titled "Export many records"
- **When** `/feature new` runs
- **Then** the user is asked whether this is the same requirement before any id is chosen

### Requirement: New redirects bugs and handles collisions

The system SHALL, when the captured idea is really a bug, say so and suggest filing a task instead of a feature; SHALL suffix a colliding slug with `-2`, `-3`; and SHALL, when the user pastes a large spec, extract the decisions it already implies into `proposed` rows before grilling the gaps.

#### Scenario: A one-line bugfix is not a feature

- **Given** the user describes "the save button crashes on empty input"
- **When** `/feature new` runs
- **Then** the agent says it is a bug and suggests `/tasks new task`

#### Scenario: Slug collision

- **Given** a folder already named with slug `bulk-import`
- **When** a new feature slugs to `bulk-import`
- **Then** the new folder uses `bulk-import-2`

### Requirement: The prototype decision is always recorded

The system SHALL keep a `## Prototype` line in every feature's idea file stating `Built` with a link, `Built, then deleted` with the decisions it answered and the last commit that held it, `Skipped` with a reason, or `Pending`/`N/A`; `new` SHALL write the pending form, and a missing line SHALL be treated as a defect rather than as a decision to skip.

#### Scenario: New writes pending

- **Given** a freshly created feature
- **When** its idea file is written
- **Then** its Prototype line reads pending

#### Scenario: A skipped prototype carries its reason

- **Given** a headless feature where the user declines a prototype
- **When** the choice is recorded
- **Then** the line reads `Skipped — <reason>`, never blank

### Requirement: Prototype builds a stakeholder artifact in a form chosen per feature

The system SHALL, on `/feature prototype`, ask which form to build unless the user named one — an HTML mockup, a markdown wireframe, a code spike on an unmerged flagged branch, or a state-model playground — and build it from the current proposed and approved decisions; an HTML mockup or playground SHALL be one self-contained file that opens in a browser with nothing installed and is labelled as a prototype; a playground SHALL carry both free play over the transitions and guided walkthroughs chosen for difficulty, each naming the decision row it exercises; and every form a stakeholder drives SHALL open by saying what it models, what to do and what answer is wanted.

#### Scenario: Form is asked each time

- **Given** a feature and no form named by the user
- **When** `/feature prototype FEATURE-014` runs
- **Then** the user is asked to choose among the four forms before anything is built

#### Scenario: Playground walkthrough targets a hard case

- **Given** a feature that adds a reopen transition to a terminal state
- **When** a state-model playground is built
- **Then** one walkthrough steps through reopening, names the decision row it tests, and ends with a question to the stakeholder

#### Scenario: Spike is never merged

- **Given** the risk is technical feasibility
- **When** a code spike is chosen
- **Then** a `spike/` branch is created behind a flag, a short note pointing at it is left in the feature folder, and the branch is not merged

### Requirement: Prototype records reactions and its own outcome

The system SHALL record each stakeholder reaction as a History line in the ledger naming the row it bears on, quoting the reaction and naming the form that produced it; SHALL flag new or newly-wrong branches as `proposed` rows with a History note; SHALL rewrite the idea file's Prototype line to `Built` with a link; and SHALL update the feature's index row to show the prototype link and phase `prototyping`.

#### Scenario: Reaction lands in the ledger

- **Given** a stakeholder says "the hold state should not allow edits" while viewing the mockup
- **When** the reaction is recorded
- **Then** a History line names the affected row, quotes the reaction and says it came from the HTML mockup

#### Scenario: Index never shows a missing prototype

- **Given** a prototype file was just built
- **When** the verb finishes
- **Then** the feature's index row links the prototype and reads phase `prototyping`

### Requirement: A prototype is deleted once it has answered its question

The system SHALL, once `/feature decide` has stamped every row a prototype was built to test, delete the prototype file or spike branch (non-forcibly, including a pushed remote copy) in that change, rewrite the Prototype line to `Built, then deleted` naming the answered decisions and the last commit holding it, note in History when a shared copy could not be recalled, and build any later re-prototype afresh from current decisions rather than restoring the old one; regenerating after a `changed` decision MAY keep the earlier artifact side by side when the stakeholder wants to compare.

#### Scenario: Deletion after decide

- **Given** a mockup built to test D2 and D3, both now stamped
- **When** the decide change is made
- **Then** the mockup file is removed and the Prototype line reads `Built, then deleted — answered D2, D3; last version at <commit>`

#### Scenario: Published copy cannot be unpublished

- **Given** the mockup was sent to a stakeholder as a file
- **When** it is deleted from the repo
- **Then** a History line says the shared copy cannot be recalled, so a later reaction to it is recognised as stale

### Requirement: Decision states and their meaning

The system SHALL give every decision row exactly one of five states — `proposed` (fresh, awaiting a verdict), `approved` (build as proposed), `changed` (build, but altered), `deferred` (not now) or `removed` (rejected or out of scope) — and SHALL generate tasks only from `approved` and `changed` rows.

#### Scenario: Only approved and changed generate work

- **Given** a ledger with one row in each of the five states
- **When** the feature is decomposed
- **Then** tasks are created for the approved row and the changed row only

### Requirement: Decide stamps verdicts with their required context

The system SHALL, on `/feature decide`, walk every `proposed` row and any `deferred` row up for revisit, obtain a verdict for each (one at a time or as a dictated batch), and record state, rationale, date and decider, where `changed` additionally captures the delta from the original, `deferred` captures the unblock condition, and the decider is the stakeholder or role who decided rather than the agent; a decision with no clear owner SHALL be left with decider `—` and flagged in History as needing confirmation.

#### Scenario: Changed captures the delta

- **Given** a proposed row "Export as CSV"
- **When** the product owner says "build it, but as spreadsheet format instead"
- **Then** the row becomes `changed`, its text states the new shape and why, and the decider is the product owner

#### Scenario: No owner is not fabricated

- **Given** a verdict whose decider nobody can name
- **When** it is recorded
- **Then** the decider is `—` and a History line says stakeholder confirmation is needed

#### Scenario: Confirmation summarises and chains the rollup

- **Given** a decide session that stamps 3 approved, 1 deferred, 1 proposed remaining
- **When** it confirms
- **Then** it prints the counts, offers `/feature decompose`, notes one row still needs a verdict, and runs `/feature status` for that feature automatically

### Requirement: The ledger is never pruned and its history is append-only

The system SHALL never delete a decision row — `removed` is a state — SHALL append a dated History line for every state change and never rewrite earlier History lines, SHALL keep each row's text rewritten to the current form of the decision, and SHALL reopen an overturned `deferred` or `removed` decision by adding a new `proposed` row that references the superseded one rather than editing the old row.

#### Scenario: State change appends history

- **Given** D3 is `proposed`
- **When** the PM removes it as out of budget
- **Then** D3 reads `removed` and a new dated History line records `D3 proposed → removed` with the reason

#### Scenario: Reopening from field evidence

- **Given** D4 was `removed` months ago and customers now keep asking for it
- **When** the decision is reopened
- **Then** D4 stays as written, a new `proposed` row references it as superseded, and a History line records the reopening and its reason

### Requirement: Decisions are tracked by impact, regardless of who made them

The system SHALL record in the ledger any choice that changes the feature's observable behaviour, scope, contract or an already-recorded decision — including a choice the agent makes mid-implementation — while keeping pure implementation detail out, SHALL record only the settled value of a tuned parameter, SHALL treat an unclear case as a decision, and SHALL reconcile row text with one summarising History line before committing and before the review gate.

#### Scenario: Agent-discovered change is logged

- **Given** an approved approach that turns out unworkable during coding
- **When** the agent switches to a different approach with a visible effect
- **Then** the row is rewritten to the new form and a History line records the change

#### Scenario: Tuning records only the final value

- **Given** a timeout adjusted three times before settling
- **When** the ledger is reconciled
- **Then** only the settled value appears

### Requirement: Decisions carry no paths or code except a marked prototype-derived snippet

The system SHALL state each decision in plain words with no file paths or code, admitting a code snippet only when it came from this feature's prototype, encodes the decision itself, captures precision the row's one-sentence statement would lose, and is trimmed to the decision-rich lines and headed as prototype-derived with its form and date; such a snippet SHALL sit in a per-decision block below the table, the row SHALL still state the decision and say "see snippet", and a later disagreement between snippet and product SHALL be treated as a question for `decide`, not a bug.

#### Scenario: Snippet copied from product code is refused

- **Given** a state table copied from the shipped source
- **When** it is proposed as a decision attachment
- **Then** it is rejected because it did not come from a prototype

#### Scenario: Marked prototype snippet is admitted

- **Given** a trimmed transition table from the state-model playground that captures an edge the row's sentence omits
- **When** it is attached under its marker
- **Then** it appears in the snippet section and the row says "see snippet"

### Requirement: A feature whose every decision is removed is dropped

The system SHALL, when every decision ends `removed`, set the feature's coarse status to `dropped`, append a History line, and generate no tasks.

#### Scenario: Killed feature

- **Given** a ledger whose three rows are all stamped `removed`
- **When** decide finishes
- **Then** the idea file's status is `dropped` and no tasks exist for the feature

### Requirement: Changing a signed-off feature reverts it by surface

The system SHALL treat a later change to a `done` feature as a recorded decision change in the feature that owns the affected behaviour, previewing options with the user before touching a human-verifiable surface, tracing the ripple through other artifacts, and — when the change has a human-verifiable surface — reverting the owning feature `done → review` and its implementing tasks `done → verify`, then re-running the status rollup until the idea file, task files, rollup and index agree; a change fully covered by automated tests SHALL leave the feature `done`.

#### Scenario: Visual tweak reopens sign-off

- **Given** FEATURE-030 is `done`
- **When** a colour change to its screen is agreed
- **Then** a `changed` row and History line are recorded in FEATURE-030, its status becomes `review`, its implementing task becomes `verify`, and the rollup is regenerated

#### Scenario: Test-covered change stays done

- **Given** FEATURE-030 is `done`
- **When** a calculation fix fully covered by automated tests is recorded
- **Then** the feature stays `done`

### Requirement: Decompose turns approved and changed decisions into tasks

The system SHALL, on `/feature decompose`, collect `approved` and `changed` rows (only a named subset when called with one), ignore `proposed`, `deferred` and `removed` rows, ask whether to place the tasks under an existing or new epic or story or leave them loose, create one or more small tasks per decision through the task tracker's from-feature batch creation so each task carries the feature back-link, context from the decision and a human test plan, decompose a `changed` row in its changed shape, create tasks only for the uncovered part of an already-decomposed row, verify each row's task column is filled, append one History line per decision naming its tasks, and run the status rollup for that feature automatically.

#### Scenario: Two tasks from one decision

- **Given** D1 `approved` with no tasks
- **When** decompose splits it into two tasks
- **Then** both tasks carry the feature back-link, D1's task column lists both, and a History line records `D1 (approved) decomposed → TASK-…, TASK-…`

#### Scenario: Nothing approved

- **Given** a ledger with only `proposed` rows
- **When** decompose runs
- **Then** no tasks are created and the user is pointed at `/feature decide`

#### Scenario: Re-decompose does not duplicate

- **Given** D2 already lists one task covering half its scope
- **When** decompose runs again
- **Then** only the unaddressed part becomes new tasks

### Requirement: Task-first gate — implementation never precedes decomposition

The system SHALL require that the tasks for a feature exist before any implementation code is written, and SHALL, when code was already written first, stop implementing, backfill the tasks with an honest `in-progress` status (never straight to `verify` or `done`), note the backfill in History, and then continue.

#### Scenario: Backfilling code written early

- **Given** code for D3 was written before any task existed
- **When** the gap is noticed
- **Then** implementation stops, a task is created as `in-progress`, the History log notes the backfill, and work resumes

### Requirement: Pick enters a feature at the stage that unblocks it

The system SHALL, on `/feature pick`, resolve the feature by id (or short number when unambiguous) or else list non-done, non-dropped features with verification debt first, then walk readiness gates in order and stop at the first failure, offering the verb that clears it and chaining into it on acceptance before re-checking: an open-question frontier → offer to resume the grill there, first of all gates and outranked only by sign-off, looking up `research` questions rather than asking them, and on no answer changing nothing and reporting the frontier; open rows with no frontier → report what each waits on; a pre-table questions section → never "no open questions": offer to bring it into the table, on `n` record the choice so it is not offered again, and on no answer change nothing and offer again next run; no real decision rows → re-grill with `new`; `proposed` rows remain → `decide`; a UI- or state-shaped feature with approved rows whose Prototype line records none → suggest `prototype` once, never blocking; an approved or changed row with no tasks or with tasks missing on disk → `decompose`; phase `review` → `review`. Only when every gate clears SHALL it hand off to the task tracker's pick for that feature, surfacing in-progress and awaiting-verification tasks first, and it SHALL never implement anything itself.

#### Scenario: Most common stall offers decompose

- **Given** FEATURE-012 with two approved rows and empty task columns
- **When** `/feature pick FEATURE-012` runs
- **Then** the uncovered rows are listed by id and the user is asked "Decompose these 2 decisions into tasks now? [Y/n]"

#### Scenario: Declining decompose stops the handoff

- **Given** the same feature
- **When** the user answers `n`
- **Then** the task-first gate is printed and pick stops without handing off to work

#### Scenario: Dangling task link counts as uncovered

- **Given** a row whose task column names a task that no longer exists
- **When** pick checks readiness
- **Then** the row is treated as not decomposed and the dangling id is flagged

#### Scenario: One pick advances several stages

- **Given** a feature with proposed rows and nothing decomposed
- **When** the user accepts each offer
- **Then** pick chains decide, then decompose, then hands off to task picking

#### Scenario: Open questions are resumed before decisions

- **Given** a feature at phase `idea` whose table has Q4, Q6, Q7 and Q8 on the frontier and Q5 waiting on Q4
- **When** `/feature pick` runs
- **Then** it first offers "FEATURE-NNN has 4 open question(s) on the frontier: … Resume the grill there? [Y/n]", ahead of any decide offer

#### Scenario: A pre-table file is not an empty frontier

- **Given** a feature whose open-questions section is a bulleted list written before the table existed
- **When** pick reads it
- **Then** it says the questions are in the earlier format and offers to bring them into the table, never reporting no open questions

### Requirement: A pre-table questions section is upgraded in place, on offer

The system SHALL find the section by a heading starting `## Open questions`, and SHALL upgrade it only when the user accepts. It SHALL turn every old item into a row or a Fog bullet and drop none: an item naming a decision becomes `resolved → Dn`; an answer with no decision becomes `resolved — <the answer, as written>`; a precise unanswered question becomes `open`, with no edge it does not name; anything vaguer becomes Fog verbatim; and the template's own placeholder lines are removed and counted. It SHALL keep each question's wording and the heading, SHALL keep the old list itself verbatim in a collapsed block under the table, and SHALL leave the decision ledger untouched. It SHALL report `brought up to date` with its counts, distinct from `current` on a file that already had the table. A refusal SHALL write a dated line under the heading that stops the offer recurring; no answer SHALL write nothing.

#### Scenario: Every old item lands somewhere

- **Given** a section with twelve items, each ending `→ **Dn**`
- **When** the upgrade runs
- **Then** the table has twelve rows `resolved → D1`…`D12` with the questions as written, no decision row changes, and the report reads `brought up to date — 12 rows (12 resolved → D, 0 resolved with an answer, 0 open), 0 fog, 0 placeholder line(s) removed`

#### Scenario: The second run reports the first

- **Given** a section upgraded in an earlier run
- **When** pick reads it again
- **Then** it reports `open questions: current` and offers nothing

#### Scenario: Prototype gate reads the line, not the folder

- **Given** a UI feature whose Prototype line reads "Built, then deleted"
- **When** pick checks readiness
- **Then** no prototype is suggested

### Requirement: Pick refuses or redirects terminal features

The system SHALL refuse to pick a `dropped` feature and suggest `/feature new` or reopening a row via `decide`; redirect a `superseded` feature to its successor; confirm intent before working on a `done` feature, requiring a `changed` decision first; stop on a feature whose only live rows are `deferred`, showing their unblock conditions; and point at `/feature new` or the project scaffolder when the project has no feature tree.

#### Scenario: Superseded redirects

- **Given** FEATURE-005 is `superseded` by FEATURE-018
- **When** the user picks FEATURE-005
- **Then** they are redirected to FEATURE-018 and no work starts on FEATURE-005

#### Scenario: Deferred-only feature

- **Given** a feature whose rows are all `deferred`
- **When** it is picked
- **Then** the unblock conditions are shown and decompose is not offered

### Requirement: Show is a read-only report with a suggested next verb

The system SHALL, on `/feature show`, print the feature's title, phase, owner, decision table with task links, per-task progress and prototype form, suggest the next verb in the same order pick uses — naming uncovered decision ids when the gap is decomposition and pointing at `/feature pick` to act — and write nothing.

#### Scenario: Show names the decomposition gap

- **Given** D2 and D4 are approved with no tasks
- **When** `/feature show 012` runs
- **Then** it suggests `/feature decompose`, names D2 and D4, points at `/feature pick FEATURE-012`, and modifies no file

### Requirement: Coarse status is stored, phase is derived

The system SHALL store exactly one coarse status per feature with the values `idea`, `review`, `done`, `dropped` and `superseded` (a superseded feature also naming its successor and keeping its folder), and SHALL compute a displayed phase from the decisions, task progress and coarse status — `idea`, `prototyping`, `deciding`, `building`, `review`, `done` — with `dropped` and `superseded` shown as mirrors of the coarse status; phase SHALL never be stored or hand-maintained. A feature with approved decisions and no tasks yet SHALL show phase `building` with `0/0` tasks and a next step of decompose; a feature whose existing tasks are all done or awaiting verification, with at least one task, SHALL show phase `review` until signed off.

#### Scenario: Freshly decided feature

- **Given** a feature with three approved rows and no tasks
- **When** the rollup is generated
- **Then** the phase is `building`, progress is `0/0`, and the next step points at `/feature decompose`

#### Scenario: All tasks done but unsigned

- **Given** a feature with coarse status `idea` and five tasks, all `done`
- **When** the phase is computed
- **Then** it is `review`, not `done`

#### Scenario: Re-homed feature

- **Given** a feature whose scope moved into FEATURE-018
- **When** it is rendered
- **Then** its phase reads `superseded` with a pointer to FEATURE-018

### Requirement: Done means signed off

The system SHALL call a feature `done` only after the review gate passes including stakeholder sign-off, and SHALL render a built-but-unsigned feature as `review` or "awaiting sign-off" in every artifact and reply, never as `done` and never as a hybrid such as "done (sign-off pending)".

#### Scenario: Green tests are not done

- **Given** all code merged and tests passing, sign-off not recorded
- **When** any verb reports the feature
- **Then** it reads "review (awaiting sign-off)"

### Requirement: Verification debt is listed first

The system SHALL order every feature listing — the bare listing, show, pick's list, the status digest and the index — and any "what's next" answer with phase-`review` features first, ahead of building and idea-stage ones, and SHALL never headline that everything has shipped while a `review`-phase feature exists.

#### Scenario: Digest ordering

- **Given** FEATURE-003 in `building` and FEATURE-007 in `review`
- **When** the all-features digest prints
- **Then** FEATURE-007 is listed first as awaiting sign-off

#### Scenario: Index leads with the debt note

- **Given** two features in `review`
- **When** the index is regenerated
- **Then** it opens its notes with an "Awaiting sign-off (2)" warning naming them

### Requirement: Feature and task status vocabularies stay separate

The system SHALL keep the feature's own coarse `review` marker distinct from task statuses, bucketing a feature's tasks by task status (todo, in-progress, review, blocked, done, cancelled), counting a task in `verify` — or in the older `review` form — as awaiting verification, letting a blocked task keep its own state, and parking a feature's tasks awaiting sign-off at the task status `verify`, never at the feature's marker.

#### Scenario: Verify task feeds the review bucket

- **Given** a feature with tasks in `done`, `verify` and an older-form `review`
- **When** the tasks are bucketed
- **Then** the `verify` and older `review` tasks both count as awaiting verification

#### Scenario: Parking at review

- **Given** a feature is built but the stakeholder is unavailable
- **When** review parks it
- **Then** the feature's status is `review` and its unsigned tasks are `verify`

### Requirement: Status regenerates the rollup and the index, read-only on everything else

The system SHALL, on `/feature status`, collect features and tasks through the roadmap's shared cross-tree pass, derive each phase, overwrite each target feature's plain-language rollup (phase, decision counts by state, build progress with tasks described in human terms, which tasks have a filled human test plan ready to run, the prototype link — or for a deleted prototype the recorded "built, then deleted" text — and one concrete next step), and change no decision or task. In all-features mode it SHALL also print a one-line-per-feature digest and overwrite the features index with one row per feature plus the verification-debt and drift notes; a single-feature run SHALL update only that feature's rollup and its index row.

#### Scenario: Single-feature run

- **Given** FEATURE-012 and FEATURE-013 both exist
- **When** `/feature status FEATURE-012` runs
- **Then** only FEATURE-012's rollup and its index row change

#### Scenario: Deleted prototype is not linked

- **Given** a prototype recorded as built then deleted, answering D1
- **When** the rollup renders
- **Then** the prototype section says it was built then deleted, answering D1, and links no file

### Requirement: Generated files are owned by status and are not hand-edited

The system SHALL treat each feature's rollup and the features index as generated output owned by `/feature status`, marked as not to be hand-edited, and SHALL keep them current by re-running that verb automatically after decide, after decompose, after a task close that changes a feature-linked task, and after a surface-dependent revert; `new` and `prototype` SHALL also update their own feature's single index row so the index never lags a newly created feature or a newly built prototype.

#### Scenario: Decompose refreshes the rollup

- **Given** decompose has just created three tasks
- **When** it finishes
- **Then** the feature's rollup and index row are regenerated without the user asking

#### Scenario: New adds its row

- **Given** an existing index with four rows
- **When** a fifth feature is created
- **Then** the index gains its row with phase `idea`, `0/0` tasks and prototype pending

### Requirement: Review is a three-gate completeness check

The system SHALL, on `/feature review`, run Gate A (completeness: every approved or changed decision decomposed and every linked task `done`, stopping with a list of open tasks otherwise; a confirmation that any new cross-cutting pattern was recorded; a fidelity check of the cumulative change against the approved and changed decisions, reported separately from the completeness findings and never merged or reranked with them; a spec-landing check; and optional cumulative correctness and security passes for cross-task seams, done inline when the runtime lacks them, with any blocker routed back to a task rather than fixed in place), Gate B (every linked task's human test plan fully checked or explicitly marked not applicable, unchecked steps listed for the user to run, and the result recorded in History) and Gate C (a stakeholder summary and explicit sign-off recorded as a History line), and SHALL print a per-gate pass/fail and the final state.

#### Scenario: Open task fails completeness

- **Given** one of the feature's four tasks is still `in-progress`
- **When** review runs
- **Then** Gate A fails, the open task is listed, and the review stops

#### Scenario: Unchecked test steps

- **Given** a linked task whose human test plan has two unchecked steps
- **When** Gate B runs
- **Then** the steps are listed and the user is asked to run them or confirm not applicable

#### Scenario: Stakeholder requests changes

- **Given** Gates A and B pass
- **When** the stakeholder asks for a change at Gate C
- **Then** the decision is added or flipped through `/feature decide` and the feature is not done

### Requirement: Review's spec-landing check distinguishes unknown from missing

The system SHALL, in Gate A, require a usable spec map (one with at least one area) and, when it is missing or still the empty seed, say so and require spec initialisation and a harvest — or an explicit "no spec surface" record — before sign-off; it SHALL treat a spec that does not list the feature in its provenance as unknown rather than a miss when that provenance was never derived, regenerating the candidate areas first; it SHALL treat a derived provenance that still omits the feature as a finding, checking the count of unresolved tasks and running a feature-scoped regeneration whose expected-but-missing outcome fails completeness; and it SHALL accept a docs-only feature only via a History line containing the literal phrase `no spec surface`, used only after provenance was derived.

#### Scenario: Underived provenance is not a failure

- **Given** a spec whose provenance-derived flag is absent and whose provenance list is empty
- **When** the landing check runs
- **Then** the candidate areas are regenerated before any verdict, and the empty list is not reported as a miss

#### Scenario: Empty spec map

- **Given** a spec map with no areas
- **When** the landing check runs
- **Then** the agent says the check cannot run and requires spec setup and a harvest, or a `no spec surface` record, before sign-off

#### Scenario: Docs-only carve-out

- **Given** a docs-only feature with derived provenance that lists no spec
- **When** the reviewer confirms it has no behaviour
- **Then** a dated History line containing `no spec surface` is recorded

### Requirement: Review sets the coarse status honestly

The system SHALL set the coarse status to `done` only when all three gates pass, then regenerate the rollup and, when the project has a changelog, print a one-line nudge to record the ship without running it; and SHALL set the status to `review` — recording sign-off as pending — when completeness passes but test verification or sign-off has not happened, re-running review later to close it.

#### Scenario: All gates pass

- **Given** Gates A, B and C pass in a project with a changelog
- **When** review finishes
- **Then** the status is `done`, the rollup shows phase `done`, and one line suggests updating the changelog

#### Scenario: Stakeholder unavailable

- **Given** Gate A passes and the stakeholder cannot be reached
- **When** review finishes
- **Then** the status is `review`, History records sign-off as pending, and nothing reads `done`

### Requirement: Every requirement has a tracked feature and scope is never silently displaced

The system SHALL treat the set of feature folders as the project's feature list, requiring every committed requirement — including soft or qualitative ones — to have its own folder (at least a stub), and SHALL, when a planned slot is reused or a feature is renamed or re-scoped, re-home the original scope into its own tracked feature or story rather than overwriting it, marking a re-homed feature `superseded` with its successor while keeping the folder.

#### Scenario: Soft requirement gets its own feature

- **Given** a user asks that the app "feel fast"
- **When** the requirement is committed
- **Then** it gets its own feature folder rather than a bullet inside another feature

#### Scenario: Reused slot re-homes the original

- **Given** a planned feature slot is about to be repurposed for new scope
- **When** the change is made
- **Then** the original requirement is moved to its own tracked feature first and nothing is lost

### Requirement: Stakeholder-facing files avoid technical jargon

The system SHALL write the idea file, the decision ledger and the rollup in plain language a non-technical stakeholder can read, with no code identifiers in prose; task ids may be cited in the rollup but each task SHALL be described in human terms.

#### Scenario: Rollup task list

- **Given** a task with a code-heavy title
- **When** it appears in the rollup
- **Then** it is listed with its id and a plain-language description
