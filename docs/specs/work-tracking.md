---
area: work-tracking
generated-at: 668f6d5d3473b11f09cf31d26e10e506d7c4d3bd
generated-on: 2026-11-15
sources:
  - skills/tasks/SKILL.md
  - skills/tasks/slicing.md
  - skills/tasks/templates/EPIC.md
  - skills/tasks/templates/README.md.tmpl
  - skills/tasks/templates/STORY.md
  - skills/tasks/templates/TASK.md
  - skills/tasks/templates/config.yml
  - skills/tasks/verbs/audit.md
  - skills/tasks/verbs/block.md
  - skills/tasks/verbs/cancel.md
  - skills/tasks/verbs/close.md
  - skills/tasks/verbs/export.md
  - skills/tasks/verbs/import.md
  - skills/tasks/verbs/init.md
  - skills/tasks/verbs/intake.md
  - skills/tasks/verbs/migrate.md
  - skills/tasks/verbs/move.md
  - skills/tasks/verbs/new.md
  - skills/tasks/verbs/pick.md
  - skills/tasks/verbs/plan.md
  - skills/tasks/verbs/show.md
  - skills/tasks/verbs/spawn.md
  - skills/tasks/verbs/triage.md
shaped-by: [FEATURE-001, FEATURE-002, FEATURE-003]
shaped-by-derived: true
shaped-by-unresolved: 12
---

# The developer-facing backlog — epics, stories and tasks, from picking one up to closing it

## Purpose

Keeps a project's work as a tree of markdown files — epics (areas of concern), stories (user behaviours) and tasks (the only atomic, completable unit) — so that a human or an agent can pick any task without re-discovery. It owns the task lifecycle from creation through planning, picking, blocking, and a close that is also the review and merge gate, so that `done` means reviewed and integrated. It also turns review passes and discovered work into ranked tasks, keeps a generated dashboard current, and syncs with GitHub Issues or Jira in hybrid mode. Other skills depend on it: the feature lifecycle decomposes decisions into its tasks, the defect drain picks from its review-intake pools and closes through its gate, and spec harvesting reads the commits its close writes.

## Requirements

### Requirement: Three-level tree with self-contained tasks

The system SHALL keep work as EPIC, STORY and TASK markdown files with YAML frontmatter under a project-local task root, where a story lives inside an epic folder, a task lives inside a story folder, directly inside an epic folder, or in a loose folder when it has no parent, and every task carries `## Context`, `## Acceptance criteria`, `## Out of scope`, `## Human test plan` and `## Implementation plan` sections. Nothing is archived or deleted; completion is recorded by status alone.

#### Scenario: A task with no parent

- **Given** a user creates a task and answers "none" for its parent
- **When** the file is written
- **Then** it is placed in the loose folder, which is created only at that moment if it did not exist

#### Scenario: Finished work stays in the tree

- **Given** an epic whose every task is `done`
- **When** any verb runs over the tree
- **Then** the epic and its task files remain where they are, and only their status records completion

### Requirement: Status vocabulary read in both forms

The system SHALL write task statuses from `todo`, `in-progress`, `verify`, `done` and `cancelled`, plus an optional `blocked:` field carrying a reason, and story and epic statuses from `planned`, `in-progress`, `done` and `cancelled`. Every reader SHALL also accept the old forms permanently: `status: review` reads as `verify`, and `status: blocked` reads as blocked with the prior state unknown, counted as blocked only and never guessed into a state. A `blocked:` field on a `done` or `cancelled` task is a contradiction. Containers are never blocked.

#### Scenario: Old review form

- **Given** a task file reading `status: review`
- **When** the collection pass buckets it
- **Then** it is counted as awaiting verification, exactly as `status: verify` would be

#### Scenario: Blocked field keeps the state

- **Given** a task with `status: in-progress` and `blocked: waiting on vendor`
- **When** the counts are built
- **Then** it is counted under `in-progress` and also under `blocked`, and the output says the `blocked` row overlaps another row

#### Scenario: Old blocked form

- **Given** a task with `status: blocked` and no history consulted
- **When** it is read
- **Then** it is counted as blocked only, with its prior state reported as unknown

### Requirement: Writing a blocked reason

The system SHALL write every `blocked:` value — from `block`, a deferred merge, `import`, or `init`'s migration — as one non-empty line (`reason unknown` when there is none), single-quoted with inner quotes doubled whenever it contains `: ` or ` #`, ends with `:`, opens with a YAML indicator character, or would otherwise parse as a boolean, null, number or date. Readers SHALL use the parsed value, never the raw line.

#### Scenario: Reason containing a colon

- **Given** a deferred merge with reason `waiting on review`
- **When** the field is written
- **Then** it reads `blocked: 'merge deferred: waiting on review; code complete on task/TASK-042'`

#### Scenario: Round trip through a tracker

- **Given** a quoted `blocked:` value
- **When** the task is exported and later imported
- **Then** the reason carries no extra layer of quotes

### Requirement: Globally unique ids across every copy of the tree

The system SHALL mint `EPIC-NNN`, `STORY-NNN` and `TASK-NNN` ids from one counter per type for the whole project, zero-padded to three digits, by taking the maximum id over this tree's files (including uncommitted ones), over every local branch, and over every other registered worktree's task tree, with the id pattern tolerant of trailing whitespace and carriage returns. The scan SHALL be recomputed on every mint, the file written immediately after it, and any copy the scan could not read named in the confirmation, or in the report of a verb that prints in its place. `FIELD-NNN` finding ids SHALL be minted the same way over every copy's `findings:` lists.

#### Scenario: Parallel task on another branch

- **Given** this tree's highest task id is `TASK-030` and a local branch carries a committed `TASK-031`
- **When** a new task is created
- **Then** it is given `TASK-032`

#### Scenario: Windows line endings

- **Given** some task files end their `id:` line with a carriage return
- **When** the next id is computed
- **Then** those ids are still counted, so no number is reused

#### Scenario: Unreadable copy

- **Given** a registered worktree whose folder is gone
- **When** a task is minted
- **Then** the confirmation names that worktree as unseen, since an id minted there may still collide

### Requirement: Locating the task root

The system SHALL find the task root by walking up from the working directory: a directory holding the task configuration file wins; otherwise the project root is found by a solution file, then by `.git`, and the task root is its `tasks/` folder. When none of the three signals exists, it SHALL ask where the tree should live; with no answer it SHALL use the current folder, report the root as inferred and name the missing signals, and SHALL NOT write the configuration marker that would make the guess permanent. A project's own guide may override placement.

#### Scenario: No signals and nobody to ask

- **Given** a folder with no task configuration, no solution file and no `.git` above it
- **When** a verb runs unattended
- **Then** it uses `tasks/` under the current folder, reports the root as inferred, and writes no configuration marker

### Requirement: Tracking mode

The system SHALL record the mode (`local` or `hybrid` with a GitHub repo or Jira project) in the task configuration file. When the file is missing on a verb's first run it SHALL suggest a mode from signals (an issue-template folder suggests GitHub, a Jira-shaped URL in the guide or README suggests Jira, otherwise local) and ask; with no answer it SHALL write `mode: local` annotated as defaulted and nobody asked, and say so. A Jira project key with no answer falls back to `local`. An external, files-free mode is never offered.

#### Scenario: Mode defaulted unattended

- **Given** no configuration file and nobody to answer the mode question
- **When** the first verb runs
- **Then** the file is written with `mode: local` and a comment saying it was defaulted, and the confirmation says the mode was not chosen

### Requirement: Collection pass

The system SHALL enumerate every epic, story and task file in one pass, read each file's frontmatter (id, parent, feature, status, priority, assignee, findings, affects, kind, theme, created, depends-on, blocks and the parsed `blocked:` value) and its first heading as the title, and build status counts, a per-priority breakdown of `todo` tasks containing one bucket per priority actually present, lists of in-progress tasks, tasks awaiting verification and next-up tasks, and a by-parent map. Every list of tasks SHALL use one total order: priority (every value present, in its natural order, with no priority last), then creation date, oldest first, then the id's number, lowest first, with the repository name breaking the last tie across sibling projects. A view read as a ranking SHALL print one line naming the shown tasks that tie on priority and date, counting the cut tasks that tie with a shown one, and saying nobody ranked them. Under worktree workspace a task whose own task branch reads `verify` or `review` SHALL also count as awaiting verification.

#### Scenario: Unusual priority value

- **Given** todo tasks at P1, P2 and P3
- **When** the priority breakdown is built
- **Then** it shows three buckets ordered P1, P2, P3 and drops none

#### Scenario: Next-up tasks that tie on every declared key

- **Given** five `todo` tasks, all `P2` and all created on one date: `TASK-010`, `TASK-002`, `TASK-011`, `TASK-009`, `TASK-004`
- **When** the snapshot renders "Next up"
- **Then** it shows `TASK-002`, `TASK-004`, `TASK-009` on every run, and under them `ordered by id where priority and created tie: TASK-002, TASK-004, TASK-009 (+2 not shown) — nobody ranked them`

#### Scenario: Verify parked on a task branch

- **Given** workspace `worktree`, and a task whose default-branch copy reads `in-progress` while its task branch copy reads `verify`
- **When** the collection pass runs
- **Then** the task is listed as awaiting verification

### Requirement: Taken tasks derived from branches

The system SHALL treat a `todo` task as taken when a `task/TASK-NNN` branch exists locally or on a remote, count it in the in-progress bucket rather than `todo` (and so outside the `todo` priority breakdown), list it among the in-progress tasks once, marked `taken: <branch>` with the branch as found, render it the same way in the snapshot and the dashboard, and never offer it as next work. This SHALL be recomputed from the branches on every run and never written into the task file, and skipped where there is no git.

#### Scenario: Another clone picked the task

- **Given** the default branch's copy of `TASK-017` reads `todo` and `origin/task/TASK-017` exists
- **When** the snapshot or `pick` runs
- **Then** `TASK-017` is not offered as next work and is shown as taken

#### Scenario: A taken task is counted once, as in progress

- **Given** `TASK-002` reads `todo` in its file and `origin/task/TASK-002` exists, beside one task whose file reads `in-progress`
- **When** the snapshot or the dashboard is rendered
- **Then** the in-progress count is 2 and the `todo` count leaves `TASK-002` out, and `TASK-002` is listed under in progress once, marked `taken: origin/task/TASK-002`

### Requirement: Status snapshot and help

The system SHALL render, for a bare `/tasks`, a stdout-only snapshot with the mode in the header, epic, story and task counts by status (each noun singular for a count of one; every status row printed with its count, zero included, except `verify:`; no `cancelled` row; the `todo` breakdown naming only priorities that have a task, and absent when `todo` is 0), the in-progress list with blocked tasks marked by reason, an "Awaiting verification" list, the top three next-up tasks in the collection pass's task order excluding blocked ones, with its tie line when the id decided their order, and the features slice whose shape another skill owns. It SHALL omit the verify line and section when nothing awaits verification and the features block when no features folder exists. It SHALL NOT write the dashboard. The template's `←` notes SHALL NOT be printed, and the "Next up" heading SHALL be printed whole. `/tasks help` SHALL print the verb table and a one-line hint, with no file I/O.

#### Scenario: Nothing awaiting verification

- **Given** no task at `verify` or `review`
- **When** the snapshot is rendered
- **Then** neither the `verify:` count line nor the "Awaiting verification" section appears

#### Scenario: Help

- **Given** any project
- **When** the user runs `/tasks help`
- **Then** the verb table is printed with a hint that bare `/tasks` shows the snapshot, and no file is read

### Requirement: Widening reads across sibling projects

The system SHALL accept `--across` only on the bare snapshot, `audit` and the roadmap view, and SHALL then read `siblings.root` from the configuration (relative to the repo root), probe each immediate child of that root for a task folder on every run, always include the invoking repo, run the collection per project, and print every id as `<repo>/TASK-NNN` without renumbering any file. An undeclared root or one that does not resolve SHALL be reported in a fixed line and the run continues single-repo; the root is never inferred from the directory layout. Without the switch the output SHALL be unchanged, with no hint about siblings. `pick` and `triage` SHALL refuse the switch with their own reason, and every other verb SHALL refuse it with a fixed line and do nothing.

#### Scenario: Root undeclared

- **Given** a configuration with no `siblings.root`
- **When** the user runs `/tasks --across`
- **Then** the first line says the root is not declared and `--across` did not widen, and the single-repo snapshot follows

#### Scenario: Colliding ids

- **Given** two sibling projects that both contain `TASK-012`
- **When** the across snapshot renders
- **Then** they appear as `alpha/TASK-012` and `beta/TASK-012`, and neither file is changed

#### Scenario: Write verb refuses

- **Given** any project
- **When** the user runs `/tasks close TASK-004 --across`
- **Then** the verb prints that `--across` is not supported by this verb and does nothing else

### Requirement: Generated dashboard owned by triage

The system SHALL regenerate the dashboard file only through `triage` (chained by the verbs that change the tree), rebuilding it entirely from the collection pass with counts (`—` for a pair that does not apply, `0` for one that applies and is empty, and the blocked count's overlap note inside its own cell, singular for one), a todo-by-priority line, "In progress now", an "Awaiting verification" section, a tree with per-story done counts and status markers (blocked tasks marked with their reason, cancelled ones struck through with no checkbox and any tag after the strike, feature links tagged), ordered epics and stories by id and tasks by the shared task order, tasks parented straight to an epic under one `(epic level)` line after its stories, every story line in one form `— <state> (<d>/<t> done)` with `todo` shown as `planned` and cancelled tasks counted in neither number, done stories keeping their tasks, a loose section, and a completed section that is one `<details>` block summarised `Completed (<n> epics)`, an empty tree rendering as `_None_`, tree rows carrying only id, title and markers, an omitted section taking the blank line before it, counts-table cells padded to the template's column width, and a local-time timestamp with no zone, and a feature-drift callout, under the title and above the generated line, when the roadmap divergence rules find an open divergence, an accepted one left out of it, and a single quiet `Feature drift: none open · <n> accepted (…)` line when every finding is accepted. It SHALL head the verification section `## Awaiting verification`, list every loose task in the Loose section, closed ones included, and end a direct run with one summary line whose count nouns are singular for one, counting open feature divergences only and parents out of step, each suffix before the closing period. It SHALL check every epic and story against its children and report, in one callout above the tree and as a count on the summary line, each that disagrees — open with every child closed, `planned` with work started, `done` or `cancelled` with an open child, or an epic body naming a story that does not exist — naming the verb that fixes it — the fix's whole text before its ` — ` — and SHALL never change a status itself. It SHALL never write the dashboard inside a task's linked worktree, saying so in one line, and SHALL refuse `--across`, pointing at the read-only snapshot.

#### Scenario: Chained from a worktree

- **Given** a session inside the linked worktree of `TASK-020`
- **When** `block` chains `triage`
- **Then** the dashboard is not written and one line says why

#### Scenario: Two runs over one tree

- **Given** a tree with a done story holding a cancelled task, and tasks parented directly to an epic
- **When** the dashboard is regenerated twice with no change in between
- **Then** the two files differ only in the timestamp, the done story reads `— done (n/n done)` with its tasks listed, and the epic's own tasks sit under its `(epic level)` line

#### Scenario: A story left open over closed tasks

- **Given** a story reading `in-progress` whose every task is `done`
- **When** the dashboard is regenerated
- **Then** a `Parents out of step` callout above the tree names the story and `/tasks close` for it, and the story's status is unchanged

#### Scenario: Drift found

- **Given** a feature whose phase contradicts its tasks
- **When** `triage` runs
- **Then** a feature-drift callout naming the divergence is placed under the dashboard title

### Requirement: Creating epics, stories and tasks

The system SHALL create a node by asking its level (with a decision test when unsure), title, parent (an existing epic for a story; a story, an epic or none for a task), and for tasks priority and assignee (defaults P1 and `agent`, the assignee drawn from the vocabulary the task template's comment states, never writing `ai`, with any `P<n>` priority written as given rather than limited to the values offered); it SHALL mint the id, compute the path from the parent chain, render the level's template with `planned` for containers and `todo` for tasks (but `done` for an epic that intake files as the record of a pass that dropped every finding), offer to draft the task body (writing `N/A — fully covered by automated tests` for a plainly unit-testable task rather than filler steps), regenerate the dashboard, and auto-run `plan` for a task unless `--no-plan` was passed. Template fields with no value for this node (an epic's `kind:`/`source:`, a story's `theme:`) SHALL be omitted rather than rendered empty. Whenever the new task carries a `feature:` link, by any route, it SHALL be written into the owning decision row's task column, and if no approved or changed row covers it a new `proposed` row SHALL be appended instead.

#### Scenario: Task inheriting a feature

- **Given** a new task created under a story whose tasks carry `feature: FEATURE-005`, with the feature written by hand
- **When** the task is written
- **Then** its id is added to the matching decision row of FEATURE-005, even though `--from-feature` was not passed

#### Scenario: Batch creation

- **Given** `/tasks new task --no-plan`
- **When** the task is created
- **Then** no plan is drafted and the confirmation says to run `plan` later

### Requirement: Creation questions and the inferred-values mark

The system SHALL, when creating a node, put a stated question for each of the level, the title, the parent, a task's priority and assignee, the offer to draft the body sections no flag drafted (no question when none is left), and an aggregator epic's `affects:` list, asking only for a field no calling verb has set and the request does not state. A value the request states — an id it names, quoted text introduced as the title or passed as the verb's argument (other quoted text being a description the title is composed from, and marked), a priority or assignee by name, the level in words — SHALL be written as given, with no question and no mark; a value read off the request's subject (the parent whose title fits, a title this run composes) remains the fallback and is marked, and a stated id that does not resolve or names the wrong level counts as not stated. With no answer, or nobody to ask, it SHALL give each field its step's fallback — the level from the decision test, a short noun phrase from the request as the title, the candidate that owns the subject as the parent (for a task, the loose folder when none clearly does), `P1` and `agent`, the body sections drafted only when the request supports it (otherwise left as placeholders and reported unfilled), and `[]` for `affects:` — and SHALL write one line directly under the new file's heading, `> Filed with nobody to answer — inferred, not chosen: <fields>.`, naming every inferred field, repeated in the confirmation and written only when something was inferred. A field a calling verb set — an argument, a value it pre-filled or derived by its own rules, one of its stated defaults, or sections a flag drafted — SHALL never be marked, and an `affects` answer of `none` writes `[]` unmarked. A story whose epic nobody chose and that no epic clearly owns SHALL NOT be created, and the run reports `not created: no epic owns "<title>"`. Whoever confirms the values deletes the line.

#### Scenario: Task filed with nobody to answer

- **Given** `/tasks new task` run with nobody to answer, for a request one existing story clearly owns
- **When** the task is written
- **Then** it is filed under that story at `P1`, assigned to `agent`, and the line under its heading names the title, parent, priority and assignee as inferred, not chosen

#### Scenario: Parent named in the request

- **Given** `/tasks new task` run with nobody to answer, for a request that says the task goes under `STORY-001`
- **When** the task is written
- **Then** it is filed under `STORY-001` without the parent question, and the inferred-values line does not name `parent`

#### Scenario: Story nobody can place

- **Given** `/tasks new story` run with nobody to answer, for a request no existing epic owns
- **When** the parent question goes unanswered
- **Then** no story is created and the run reports that no epic owns it

#### Scenario: Aggregator epic with no answer about its sub-projects

- **Given** a new epic in a polyrepo aggregator repo and nobody to answer which sub-projects it affects
- **When** the epic is written
- **Then** it reads `affects: []` and its inferred-values line names `affects`

### Requirement: New work under a closed container

The system SHALL list every candidate parent whatever its status, marking a `done` one as reopened if chosen and a `cancelled` one as won't-do, and SHALL file new work under the container that owns it even when that container is `done`, never in the loose folder because of a parent's status. When an open item is created under a `done` parent, or under a `cancelled` one the user chose to reopen, the parent SHALL be set to `in-progress` in the same change, with a dated `> Reopened` line under its heading (ending `(placement inferred — see <new id>)` when the parent was inferred), and the reopen reported; the epic above a parent story SHALL be checked the same way whether or not the story was reopened. A `cancelled` parent, chosen or inherited from a caller, SHALL be asked about first; with no answer it is not reopened, the item is filed under the nearest ancestor that is not cancelled (a `done` one taking it and reopening), else in the loose folder — where a finding gets a minted `FIELD-NNN` — and the run reports where it went and the `move` command that would reopen the cancelled parent. A story under a `cancelled` epic with no answer SHALL NOT be created. When an open item goes into an open story whose epic is `cancelled`, the system SHALL ask whether to reopen the epic; with no answer the item is still filed in its story, the epic stays `cancelled`, and the run SHALL report the cancelled epic over open work rather than leave it silent. A new item that is itself `done` or `cancelled` reopens nothing.

#### Scenario: Task filed under a done story

- **Given** `STORY-001` reads `done` and owns the subject of a new task
- **When** the task is created under it
- **Then** the task is filed in `STORY-001`, the story reads `in-progress` with a dated `> Reopened` line, its epic is checked the same way, and the confirmation reports `STORY-001 reopened: <new id> is now todo`

#### Scenario: Cancelled parent with nobody to answer

- **Given** a task spawned from an origin under `STORY-014`, which reads `cancelled`, inside the open epic `EPIC-002`
- **When** nobody answers whether to reopen `STORY-014`
- **Then** the new task is filed under `EPIC-002`, `STORY-014` stays `cancelled`, and the report names `/tasks move <new id> --to STORY-014` as the way to reopen it

#### Scenario: Open story under a cancelled epic with nobody to answer

- **Given** `STORY-020` reads `in-progress` inside `EPIC-005`, which reads `cancelled`
- **When** a task is created in `STORY-020` and nobody answers whether to reopen `EPIC-005`
- **Then** the task is filed in `STORY-020`, `EPIC-005` stays `cancelled`, and the report says `EPIC-005` is cancelled over open work and nothing chose to reopen it

#### Scenario: Closed issue imported under a done story

- **Given** a closed issue imported as a `done` task under a `done` story
- **When** the task is written
- **Then** the story stays `done`

### Requirement: Tasks born from findings

The system SHALL, on `new --from-review <ids>`, set `findings:` to those ids and write each finding's evidence into the task's Context so it stands alone, drafting acceptance criteria from what must hold once fixed. On `new --from-field` it SHALL mint the next tree-wide `FIELD-NNN` (`FIELD-001` when no copy of the tree holds one), set it as the task's only finding, write the field evidence into Context, and report the minted id and that the task is now in the defect drain's pool. For a defect already filed without an id, it SHALL run only the mint, append the id to that task's existing `findings:` and report it, and SHALL NOT create a file, redraft the task's Context or criteria, regenerate the dashboard or draft a plan.

#### Scenario: Field-found defect

- **Given** the highest field finding anywhere in the tree is `FIELD-006`
- **When** the user runs `/tasks new task --from-field`
- **Then** the task carries `findings: [FIELD-007]` and the confirmation says it is now in the drain's pool

#### Scenario: First field finding joins an already-filed task

- **Given** a hand-filed loose defect with `findings: []` and no `FIELD-NNN` anywhere in the tree
- **When** it is brought into the drain's pool
- **Then** its `findings:` reads `[FIELD-001]`, nothing else in the file or the tree changes, and the report names the id and its consequence

### Requirement: Implementation plans

The system SHALL draft a task's `## Implementation plan` by handing its title, Context, acceptance criteria and out-of-scope to a planning agent that must not change the criteria (raising doubts as a flagged note at the top), refuse to overwrite a non-empty plan without `--replan` (with an extra confirmation on an in-progress task, which keeps the existing plan and reports it kept when nobody answers), leave the file untouched when planning fails, offer `spawn` for plan steps that are separately completable (spawning nothing when nobody answers, marking each such step in the plan as an unspawned split signal and listing it in the confirmation), and then offer a grilling pass, which does not run when nobody answers and is reported as `not run — nobody answered`, never as declined, and is reported as `skipped — --no-grill` when it was never offered. Before writing, any heading in the plan at `##` or shallower SHALL be demoted, every heading by the same number of levels so the shallowest is `###`, skipping fenced code blocks, so the plan stays inside its section, and the demotion is reported. When `new` chains the plan, the plan's confirmation lines SHALL be printed inside `new`'s one confirmation, with one next-step hint, or relayed by the verb whose own summary replaces that confirmation. When `pick` chains the plan, its lines SHALL be printed in `pick`'s hand-off without the next-step hint. Plans apply to tasks only.

#### Scenario: Existing plan

- **Given** `TASK-014` already has a non-empty plan
- **When** the user runs `/tasks plan TASK-014`
- **Then** it refuses and says to re-run with `--replan`

#### Scenario: Nobody answers the grill offer

- **Given** `/tasks new task` files a task with nobody present, and chains `plan`
- **When** the plan is written and the grill question is put
- **Then** no grilling runs, the draft stays as written, and the confirmation reports `grilling: not run — nobody answered`

#### Scenario: Plan output with its own section headings

- **Given** the planning agent returns a plan whose headings are `##` and `###`
- **When** the plan is written into the task
- **Then** they become `###` and `####`, the whole plan sits inside `## Implementation plan`, and the confirmation reports `plan headings demoted by 1`

#### Scenario: Plan on a container

- **Given** an id that resolves to a story
- **When** `plan` is invoked on it
- **Then** it errors that plans only apply to tasks

### Requirement: Cutting work into slices

The system SHALL cut work into vertical tasks that each pass three hard checks — Context stands alone, every criterion is verifiable inside the task beyond its `depends-on`, and the gate cannot go red after it lands — with a prefactor as its own task that `blocks` the change, a one-line reason in Context for any tripped size signal kept as one task, and the rule or check named for every rejected slice. A change whose readers span more owners than one slice may touch SHALL be sequenced expand → migrate (batches by fan-out) → contract, with ordering recorded as `blocks:`/`depends-on:` on both task files rather than by blocking. A task's `depends-on:` MAY name a story, which it then waits on until that story is done or cancelled; stories and epics SHALL carry no edge fields, so a story that waits records it on its tasks, never names an epic and never its own parent story, and nothing is written on the story waited on. When batches cannot stay green under `single-branch`, it SHALL collapse them into one task or widen the expand and report which in a fixed line, never changing `integration:` to fit.

#### Scenario: Horizontal cut rejected

- **Given** a proposal to link every mention of a new skill first and write the skill second
- **When** the slicing is checked
- **Then** the first slice is rejected, naming the hard check that the gate would fail before the folder exists

#### Scenario: Single-branch fallback

- **Given** `integration: single-branch` and migration batches that cannot coexist with the old form
- **When** the sequence is planned
- **Then** the report reads `integration fallback unavailable under single-branch — non-green batches collapsed into TASK-077` or names the alias that widened the expand

### Requirement: Picking a task

The system SHALL list `todo` tasks matching the filters (priority, assignee, epic, story, feature), in the collection pass's task order, with its tie line when the id decided the numbering, and SHALL start nothing and write nothing, saying no task was chosen, when no choice is given; the list includes blocked ones marked with their reason and excluding taken ones, which are named in a separate line under the list, after any tie line and before the question, each with `local` or the remote's name; a task in progress in a worktree on this machine SHALL appear on its own line before the list, and one awaiting verification on its branch in the debt line, never also as taken; it SHALL report verification debt before the list with the count and the ids, for one task as for several, naming the tasks as at `verify` whichever of the two names their files carry, and asking whether to clear it first when there are three or more such tasks but never blocking the pick. With an upstream, every pick SHALL fetch once before any taken check, for the list as for a task named by id, and the worktree step SHALL NOT fetch again. A task named by id SHALL pass the same taken check: it SHALL proceed when no task branch exists, when the branch is the current checkout, or when the branch exists locally under a worktree workspace, whose resume and leftover rules then decide; and otherwise SHALL refuse with a line naming where the branch exists, writing nothing; once it proceeds it SHALL report verification debt as a listed pick does. A pick SHALL warn, never block, when the chosen task's assignee already has tasks in progress in this copy or a worktree here, counting `agent`, `unassigned` and `ai` as one assignee and never counting a taken task. After the choice it SHALL offer to plan first when no plan exists (default yes, naming what triggered the recommendation, each trigger judged from the task file alone; with no answer drafting the plan without a grill and saying nobody chose it), cut the task branch where the policy calls for one and only then flip the status to `in-progress`, so the flip is made on the branch, regenerate the dashboard only when that flip lands on a default branch with no upstream — writing none on a task branch cut in place, and with an upstream writing none and naming `/tasks triage` to run through a PR — and hand off by assignee — `agent`, `unassigned` and the older `ai` alike as work for this conversation, an installed agent type by offering to spawn it, `human` and any other value by printing the task and waiting, the last naming the value as not an agent type — fetching a linked GitHub issue's comments only when the configuration declares `mode: hybrid` with the GitHub provider and otherwise printing that the issue was not fetched. A blocked task SHALL NOT be started without an explicit yes to unblocking it; unmet dependencies only warn, a story among them named as a story with its status. A plan's age SHALL be the date of the last commit that changed its section, recomputed every run and never recorded; an uncommitted plan SHALL NOT be flagged, and a repo with no git history SHALL say the age was not checked. A path the plan names SHALL count as changed when it was modified, deleted or renamed since then, and not when it never existed. When an existing plan predates changes to the code it references, it SHALL ask whether to replan first, default no; with no answer it SHALL keep the plan and say in the hand-off that it may be stale, never replanning unasked. When the task file carries the inferred-values line, the hand-off SHALL print it first as a warning naming the inferred fields. For a generic assignee it SHALL then offer to run the task in a subagent, defaulting to yes only when a stated test passes (every acceptance criterion names, in backticks or as a `§` reference, the command or the file, section or field that decides it, and no open-decision, criteria-question, unspawned-split or block marker is present) and naming the failing item otherwise; with no reply this conversation does the work. A detached run SHALL be handed the task file, checkout and branch, record `picked-by: tasks-pick` and a progress log, answer every ask from a stated contract table, stop and keep its branch at a decision only a person can take — stopping before any work at the failing item when the detached test failed — spawn nothing and list the work it found in its report, close with `--unattended`, and report with a fixed first line; a task started detached SHALL be resumed from its log rather than re-offered.

#### Scenario: Detached offer on a mechanical task

- **Given** TASK-060, assigned `agent`, whose every acceptance criterion names the lint or a file field that decides it, with no open decision and an `N/A` test plan
- **When** `/tasks pick TASK-060` reaches the hand-off
- **Then** it offers to run the task in a subagent with `[Y/n]`, stating the test passed

#### Scenario: Detached offer on a judgement task

- **Given** TASK-061, assigned `unassigned`, with a criterion that names nothing that decides it
- **When** `/tasks pick TASK-061` reaches the hand-off with nobody to answer
- **Then** the offer reads `[y/N]` quoting that criterion and saying a detached run stops there, and this conversation does the work

#### Scenario: Detached run of a judgement task

- **Given** TASK-061 with the `[y/N]` offer accepted
- **When** the subagent runs
- **Then** it does no work, TASK-061 is blocked `decision pending: what decides "<criterion>"?` on its kept branch, the report starts `stopped: decision pending: …`, and no task is created

#### Scenario: An assignee that is not an agent type

- **Given** TASK-062 with `assignee: jana`, and no installed agent type of that name
- **When** it is picked
- **Then** the task body is printed with a line saying `jana` is not an agent type here and is treated as a person, and the run waits

#### Scenario: A task named by id that another clone holds

- **Given** an in-place PR-per-task project whose remote holds `task/TASK-001`, with no local branch
- **When** `/tasks pick TASK-001` runs
- **Then** it refuses with the taken line naming the remote, and the task still reads `todo`

#### Scenario: Debt nudge

- **Given** three tasks awaiting verification
- **When** the user runs `/tasks pick`
- **Then** the ids are listed and the user is asked whether to clear verification debt first, with yes as default

#### Scenario: Debt nudge on a task named by id

- **Given** TASK-046 at `verify` and a free TASK-050
- **When** the user runs `/tasks pick TASK-050`
- **Then** the taken check passes and the debt line naming TASK-046 is printed before TASK-050 is entered

#### Scenario: Blocked task with nobody to answer

- **Given** `TASK-009` carries `blocked: waiting on vendor`
- **When** it is picked with no answer to the unblock question
- **Then** it reports `not started: TASK-009 is blocked: waiting on vendor` and changes nothing

#### Scenario: Unplanned task

- **Given** a task with four acceptance criteria and an empty plan
- **When** it is picked
- **Then** the user is offered `/tasks plan` first, with the number of criteria named as the reason

#### Scenario: Leftover issue link in a local tracker

- **Given** `mode: local` and a task carrying `github-issue: 42` from when the repo was hybrid
- **When** the task is picked
- **Then** no `gh` command runs and the hand-off prints `github-issue: #42 not fetched — mode: local`

#### Scenario: Stale plan with nobody to answer

- **Given** a task whose plan predates changes to files it references
- **When** it is picked and nobody answers the replan question
- **Then** the plan is kept and the hand-off says `plan kept: it predates changes to <paths> — may be stale`

#### Scenario: Stale plan whose file was deleted

- **Given** TASK-014's plan, committed on 2026-10-01, names `src/old.py`, which a later commit deleted, and `src/new.py`, which never existed
- **When** TASK-014 is picked with nobody to answer
- **Then** the replan question names `src/old.py (deleted)` and not `src/new.py`, and the hand-off says the plan is kept and may be stale

#### Scenario: In-place pick with an upstream

- **Given** a project with no `workspace:` whose default branch tracks a remote
- **When** a task is picked in place
- **Then** `tasks/README.md` is not written, and the pick prints that the dashboard was not refreshed and names `/tasks triage` to run through a PR

#### Scenario: Picking a task filed with inferred values

- **Given** a task whose file carries `> Filed with nobody to answer — inferred, not chosen: parent, priority.`
- **When** it is picked
- **Then** the hand-off first prints a warning that its parent and priority were inferred, not chosen, and should be checked before relying on them

### Requirement: Task branch per integration policy

The system SHALL read `integration:` from the configuration and never infer it from history. Under `pr-per-task` (also the default when the field is absent) `pick` SHALL offer to cut `task/TASK-NNN` from the default branch, making an initial commit first on an unborn repository, and when nobody answers SHALL cut it and report that the cut was the documented default for the declared (or absent) `integration:` and that nobody chose it; under `single-branch` it SHALL offer no branch. The default branch SHALL be derived every run and never read off the checkout: from a remote's HEAD (all remotes that answer agreeing), else from the only local branch outside `task/*` and `record/*`, else from an unborn repository's HEAD; with several candidates it SHALL ask, and with no answer SHALL cut nothing, commit nothing, record nothing and report the default branch as not determined. `pick` SHALL also offer to record an existing PR or commit in `pr:` (on a worktree pick, once the worktree is entered), leaving it null and saying nothing about it when nobody answers, since close fills it. The field is written only from a passed argument or a user's answer.

#### Scenario: Default branch not determined

- **Given** a `pr-per-task` repo with no remote and local branches `main` and `dev`, and nobody present
- **When** a task is picked
- **Then** no branch is cut, nothing is committed, and `default branch: not determined` is printed

#### Scenario: Nobody answers the branch offer

- **Given** a `pr-per-task` project on its default branch, and nobody present
- **When** `/tasks pick TASK-014` reaches the branch offer
- **Then** `task/TASK-014` is cut, `pr:` stays null, and the report says the cut was the documented default for `integration: pr-per-task` and nobody chose it

#### Scenario: Single-branch repo

- **Given** `integration: single-branch`
- **When** a task is picked
- **Then** no task branch is offered and work continues on the default branch

### Requirement: Worktree workspace

The system SHALL, when `workspace: worktree` is declared under `pr-per-task`, give each picked task its own worktree at `<worktree-root>/<repo-name>-TASK-NNN` outside the repository: asking for the root once when undeclared and writing it only after every check passes; refusing a root inside the repository; requiring the pick to run from the main copy, on the default branch and clean apart from this task's tree files; refusing when a branch, folder or registration is left from an earlier pick; committing the pick as `TASK-NNN: pick` on the default branch before creating the worktree (no upstream); then entering the worktree and proving the move with a separate later top-level check in every shell. A failed proof SHALL remove the new worktree and branch without force and continue in place. An in-progress task that already has a worktree SHALL be resumed into it, never given a second one. `workspace:` absent means in place; under `single-branch` the setting has no effect and says so on every run. Every outcome prints its own fixed line, and a run meeting two outcomes prints both, in the order reached.

#### Scenario: Root left blank

- **Given** `workspace: worktree` and no `worktree-root:`
- **When** the user leaves the root question blank
- **Then** nothing is written, a fell-back line names the undeclared root, and work continues in place on a task branch cut without asking

#### Scenario: Move did not stick

- **Given** a session whose working directory was pinned at launch
- **When** the proof after entering reports the main copy instead of the worktree
- **Then** the worktree and branch are removed without force and the pick continues in place

#### Scenario: Resume

- **Given** `TASK-030` is in progress in a worktree from an earlier session
- **When** it is picked again by id
- **Then** the session enters and proves that worktree, and no new worktree or pick commit is made

#### Scenario: Folder deleted by hand

- **Given** the worktree holding `task/TASK-030` is registered but its folder is gone
- **When** the task is picked
- **Then** a prunable line is printed and the run stops without pruning

### Requirement: Upstream

The system SHALL treat a worktree workspace as having an upstream whenever the default branch tracks one, recomputed every run: fetch with prune first; refuse when the local default branch has commits the upstream lacks; refuse when the task branch exists on the remote but not locally (another clone has it); fast-forward a behind default branch; cut the task branch from the upstream; commit nothing on the local default branch; carry the new task's files into the worktree and restore the main copy; commit the pick on the task branch and push it, so the pushed branch marks the task taken in every clone. Whenever it falls back to an in-place pick — the worktree root undeclared or refused, the main copy not clean, the worktree failing to be created, or the move failing its proof — it SHALL first run any upstream check that fallback skipped (fetch, local-ahead, taken-elsewhere, fast-forward), stopping where one fails, then cut the branch from the upstream and push it, or report that it could not or that no branch was cut, leaving the status flip an uncommitted edit until close commits it with the work, since the pushed branch alone is the taken signal.

#### Scenario: Another clone holds the task

- **Given** an upstream and `origin/task/TASK-044` exists with no local branch of that name
- **When** `TASK-044` is picked
- **Then** a taken-elsewhere line is printed and nothing is changed

#### Scenario: Local commits not pushed

- **Given** an upstream and two local commits on the default branch the upstream lacks
- **When** a task is picked
- **Then** the local-ahead line asks for them to reach the upstream through a PR first, and nothing is changed

### Requirement: Read-only view of a node

The system SHALL print a task, story or epic by id — header with parent chain, a metadata line (status with any blocked reason, priority, assignee, created, links and dependencies) and its body sections, or a container's children, recursing with `--tree` — without changing status, writing the dashboard or spawning agents, and SHALL end with a level-appropriate next-step hint. At every level, a file carrying the inferred-values line SHALL have it printed once, directly under the header, as `⚠ inferred, not chosen: <fields> — confirm them, then delete the line`, and left out of the body below; an epic's `affects:` list SHALL be shown when non-empty or when the line names `affects`, with `(inferred)` appended in that case.

#### Scenario: Unplanned task shown

- **Given** a `todo` task with an empty plan
- **When** the user runs `/tasks show TASK-021`
- **Then** the task is printed with a hint to run `plan` and a hint to pick it, and no file changes

#### Scenario: Epic with an inferred empty affects list

- **Given** an epic reading `affects: []` whose inferred-values line names `affects`
- **When** it is shown
- **Then** the warning appears once under the header and the `affects:` list is printed empty with `(inferred)` appended

### Requirement: Spawning discovered work

The system SHALL, when work outside the current task's acceptance criteria surfaces, offer to spawn it unprompted after a scope test (in scope or a one-line incidental is just done; torn spawns). It SHALL route a new capability to the feature lifecycle and an overturned decision to a decision change rather than mint a task; otherwise create the task under the origin's story, else its epic, else loose — stopping, when the discovery is a defect (raised by a review pass or not), to put it in a pool instead of leaving it loose without an id: by carrying its finding id, minting one through `new --from-field` for a defect with no pass behind it, or moving it under a review-intake epic, while work that is not a defect stays loose — inheriting feature and assignee, with Context naming what, where and the origin. A `done` origin story or epic SHALL still be the parent, reopened by creation. Before creating, it SHALL ask one question naming the parent, priority and assignee it will use; with no answer, `close --unattended` included, it SHALL go ahead with those defaults, which are its own rules and never marked as inferred. It SHALL then add a `Deferred to TASK-NNN` line to the origin's out-of-scope, rewrite a displaced plan step in place to point at the new id, wire dependencies, reconcile the feature ledger (a new `proposed` row when no decision covers it), regenerate the dashboard, and return to the origin.

#### Scenario: Refactor exposed mid-work

- **Given** `TASK-050` under `STORY-012` is in progress with a plan step that is really its own unit
- **When** the work is spawned
- **Then** `TASK-061` is created under `STORY-012`, the plan step reads `→ deferred to TASK-061`, the out-of-scope gains a deferred line, and work resumes on `TASK-050`

#### Scenario: Uncovered scope on a feature task

- **Given** the origin carries `feature: FEATURE-003` and no decision covers the discovery
- **When** it is spawned
- **Then** a new `proposed` row is appended to FEATURE-003's ledger and the user is told it needs a decision

#### Scenario: Pass-less defect spawned from a loose origin

- **Given** a loose task in progress turns up a crash nobody reviewed
- **When** it is spawned
- **Then** it is created through `/tasks new task --from-field`, so it carries a `FIELD-NNN` and is in the drain's pool, while a cleanup found the same way would stay loose with no id

#### Scenario: Spawn with nobody to confirm

- **Given** a spawn during an unattended close
- **When** nobody answers the confirmation question
- **Then** the task is created with the origin's parent, the default priority and the inherited assignee, and its file carries no inferred-values line for them

### Requirement: Scope escalation of the task in hand

The system SHALL, when a task's own subject measures larger than filed, sweep without asking when it is a wider population or a higher altitude of the same fix, and stop and ask when it is a different problem — after finishing every covered part, recording the measurement as numbers in the task, filing the residue as its own task, and leaving the unmet criterion unticked as `⚠ NOT MET — split to TASK-NNN`.

#### Scenario: Different problem underneath

- **Given** a task about two colliding counts that turns out to be fixture ownership across many files
- **When** the measurement is complete
- **Then** the residue is filed as its own task, the criterion stays unticked with a split note, and the user is asked to choose among three options

### Requirement: Filing a review pass

The system SHALL turn a review pass's findings into one epic stamped `kind: review-intake` with its `source:`, one story per theme that received findings (each stamped with its ladder slug in `theme:`), and one task per group of findings sharing a root cause, each created through `new --from-review --no-plan` with a title naming the group's root cause (a single finding's claim, shortened), assignee `agent`, and a priority from severity (theme 1–2 blockers P0, other blockers P1, theme 1–2 warnings P1, other warnings P2, suggestions P2; a mixed group the highest any one finding would get), none of which `new` asks for or marks as inferred. Under `--epic`, a theme the epic already holds a story for SHALL reuse that story, matched on `theme:` (a `done` one reopening, a `cancelled` one replaced by a new story the report names), and the pass SHALL append its own `source:` entry, a paragraph in the epic's Area of concern, and its dropped findings to the existing dropped list, editing nothing already written. The epic's `source:` SHALL always name the pass — the skill that ran it, or the words naming it where no skill ran — followed by any report path, PR, commit or date, with each entry naming its own pass when several passes share the epic. Each finding SHALL get a source-prefixed id (`CR`, `SEC`, `SH`, `VC`, `VI`, `IA`, `DRILL`; `FIELD` belongs to `new`), numbered within the pass or continuing an existing intake epic's numbering under `--epic`. Not-a-defect findings SHALL be dropped with the reason recorded on the epic; findings needing a decision go to the feature lifecycle; duplicates link to the existing task. A finding SHALL never be filed as a bare checklist line. One or two findings, none dropped, SHALL be redirected to `spawn` or `new` — except from the `IA` pass, which always gets its epic. A pass that dropped any finding SHALL get its epic whatever its size, even when no task is filed; such an epic is created `done`, and a later pass filed into it with `--epic` that files tasks SHALL set it back to `in-progress` in the same change, with a dated `> Reopened` line. The `IA` pass SHALL file each re-run as a new epic rather than into the earlier one, restarting its finding numbers. The report's drain hint SHALL be omitted when no task was filed. Intake SHALL file its tasks without drafting plans; a plan is drafted when the work starts, after the finding is re-verified.

#### Scenario: Pass with a false positive

- **Given** eleven findings, two of which misread the code
- **When** the pass is filed
- **Then** nine findings become tasks under theme stories, and the two dropped ones are listed with reasons on the epic

#### Scenario: Second pass into an existing epic

- **Given** an intake epic holding a `correctness-invariants` story, and a new pass with three correctness findings
- **When** it is filed with `--epic`
- **Then** the tasks file under that story, `source:` gains a second entry naming the new pass, and each task's inferred-values line names at most `body sections`

#### Scenario: Tiny pass

- **Given** a code-review pass with one finding, which is a real defect
- **When** intake is invoked
- **Then** no epic is scaffolded and the user is pointed at `spawn` or `new`

#### Scenario: Every finding dropped

- **Given** a pass with two findings, both of which misread the code
- **When** the pass is filed
- **Then** an epic is created at `done` holding the dropped list, no task is filed, and the report has no drain hint

### Requirement: Dropped findings recorded in a re-checkable shape

The system SHALL record a dropped finding under the epic's `### Findings dropped at intake` list in one of two exact shapes, because a later pass reads the list line by line to avoid raising it again. A rejection judged against a candidate's code and the paths its verdict turned on SHALL be written `- <key> — <reason> (callers: <paths>; at <commit>)`, with the key and reason as the pass printed them, the commit as the short HEAD when the verdict was reached, and the paths separated by `, `, ending `, incomplete` when not all were found, or `none`; a move held by a decision record SHALL be written `- <key> — held by ADR NNNN — <title> (at <commit>)`. Any other rejection SHALL be a table row with Finding, Claim and Why dropped columns. Both shapes may sit under one heading.

#### Scenario: Architecture candidate rejected

- **Given** an `IA` candidate `2:src/store.ts` rejected with the printed reason `fails the deletion test`, whose verdict turned on `src/a.ts` and `src/b.ts`, at commit `a1b2c3d`
- **When** the drop is recorded
- **Then** the list gains exactly `- 2:src/store.ts — fails the deletion test (callers: src/a.ts, src/b.ts; at a1b2c3d)`, not a prose rewording

### Requirement: Adopting an existing review backlog

The system SHALL, on `intake --adopt <EPIC>`, stamp `kind: review-intake` on an epic that already owns its tasks, best-effort backfill `findings:` from ids named in task bodies, report how many tasks got ids and how many did not without inventing ids, and offer (never guess) a `theme:` slug per story. Loose findings SHALL first be re-homed with `move`; adoption does not move tasks.

#### Scenario: Hand-built backlog

- **Given** an epic of eight hand-filed review tasks, five of which name finding ids in their bodies
- **When** it is adopted
- **Then** the epic is stamped, five tasks gain `findings:`, and the report says three got none

### Requirement: Human test plan decides verify or done

The system SHALL, at task close, require the `## Human test plan` to be resolved: an absent section or untouched placeholder must be filled with steps or with `N/A` and a reason before any status is chosen, and is never defaulted to `verify`. A step stays manual only when it needs human judgement or hardware; otherwise it is automated and proven able to fail. Each manual step SHALL be read as passed (ticked), failed (unticked, its last nested line a dated `Failed` entry naming where its findings went) or not run (unticked, no such line); only a passed step counts toward `done`, and a failed step is never ticked. A step passed by a cold drill SHALL count as passed only when its record names the command, the working directory and the coldness check's result; when one is missing the close SHALL ask how the runner was obtained, and with no answer SHALL untick the step with a dated `Incomplete` line, so the task parks at `verify`, never writing a line nobody gave. The check tells a missing record from a present one, never a true one from a false one. A failed or not-run real manual step SHALL close the task to `verify`, never `done`, a failed one reported with its date and findings and a `Failed` line naming no task first having its work spawned, committing the finished work on the task branch, offering a PR marked awaiting sign-off, running the out-of-scope sweep, skipping the remote-tracker close, and still regenerating the dashboard. An explicit `N/A` plan closes straight to `done`. A `done` or `cancelled` task reopened for a re-close SHALL have every ticked step reset to not run, unticked with a dated reopened line and its earlier passes kept, once the close has settled where it runs and before the plan is read, so a re-close never reaches `done` on the earlier ticks; a reset step proven by an automated check SHALL be re-run by the close rather than asked, and a fresh pass SHALL be recorded with a dated passed line.

#### Scenario: A re-close re-asks every step

- **Given** a `done` task whose Human test plan steps are all ticked
- **When** the user reopens and re-closes it
- **Then** each step is unticked with a dated reopened line, the close asks whether each was run, and the task reaches `done` only on fresh passes

#### Scenario: Unrun manual step

- **Given** a task whose test plan has an unchecked visual check
- **When** it is closed and the user has not run the check
- **Then** the status becomes `verify`, the work is committed, and the linked issue stays open

#### Scenario: Failed manual step

- **Given** a task whose only manual step is unticked with a `Failed` line naming TASK-041
- **When** it is closed and the user says they ran it
- **Then** the step stays unticked, the status becomes `verify`, and the report names the failed step and TASK-041

#### Scenario: A drill pass with no acquisition line

- **Given** an unattended close of a task whose one drill step is ticked, its `Passed` line naming no command or working directory
- **When** the plan is read
- **Then** the step is unticked with a dated `Incomplete` line naming what is missing, and the task parks at `verify`

#### Scenario: Missing section

- **Given** a task with no `## Human test plan` heading
- **When** it is closed
- **Then** the closer must write steps or `N/A` with a reason before choosing between `done` and `verify`

### Requirement: The default branch's CI is reported at the gate, and never holds it

The system SHALL, on every task close, including one parking at `verify`, read the latest completed run of each CI workflow on the default branch with the host's CLI and print exactly one `ci:` line: green with the number of workflows read (every latest run concluded success, neutral or skipped), RED naming each workflow whose latest run concluded anything else with its conclusion, commit and run URL, or `not read` with the reason (no CI configuration, no remote, no CLI, not authenticated, offline, no completed run). It SHALL NOT wait for a run its own push triggers. A red result SHALL warn and never hold the close or the merge, SHALL be printed on its own line apart from the review verdicts, and SHALL appear in the merge question and the task confirmation. A STORY or EPIC close reads no CI.

#### Scenario: CI red on the default branch

- **Given** a task whose review passes all pass, on a repo whose last completed CI run on the default branch failed
- **When** the task is closed
- **Then** a `ci: … RED …` line names the workflow and its run, separate from the verdicts, and the close still reaches `done`

#### Scenario: No way to read CI

- **Given** a repo with no CI configuration
- **When** the task is closed
- **Then** the gate prints `ci: not read` with that reason, never nothing

### Requirement: Review axes reported side by side

The system SHALL, for a non-trivial task, run conventions adherence, intent fidelity against the acceptance criteria, and correctness on every close; security review when the diff touches a security surface; comment review when the diff carries a comment; and a PR-altitude review when a PR exists — doing a pass inline when its skill does not resolve. Each pass SHALL keep its own verdict and severity order, never merged or reranked, and a conditional pass that did not run SHALL be reported as not applicable with a reason. Blockers inside scope hold the merge; findings outside scope are spawned, not folded in; comment-review findings whose content lives nowhere else are reported held and do not hold the merge.

#### Scenario: Correct but wrong thing

- **Given** a diff that passes conventions and correctness but omits one acceptance criterion
- **When** the close reports its gate
- **Then** it shows standards pass, correctness pass and intent fail as separate verdicts

#### Scenario: No security surface

- **Given** a diff touching only formatting helpers
- **When** the gate runs
- **Then** security review is reported as not applicable with a one-line reason

### Requirement: Merge decided before the status is written

The system SHALL, on a `pr-per-task` close on a task branch, ask whether to merge as part of the close — stating every pass's verdict and the `ci:` line in the question, default yes — before writing frontmatter. On yes the status SHALL be written `done`; on no the task SHALL stay `in-progress` and gain `blocked: 'merge deferred: <reason>; code complete on task/TASK-NNN'` (plus a dependency when waiting on another task's merge), the branch pushed and the PR opened or updated, and the task resumes later through `unblock` and a re-close. The decision is skipped for `--no-pr`, non-git, `single-branch`, or a close not on a task branch.

#### Scenario: Stacked PR

- **Given** a finished task whose PR must wait for `TASK-070` to merge
- **When** the user declines the merge
- **Then** the task stays `in-progress` with a quoted merge-deferred `blocked:` field and `TASK-070` in `depends-on`, and its issue stays open

### Requirement: A blocked task cannot be closed

The system SHALL ask, when closing a task blocked in either form, whether to unblock and close; with no answer, nobody present, or `--unattended`, it SHALL print `not closed: TASK-NNN is blocked: <reason>` and write nothing. An already `done` or `cancelled` task SHALL prompt to reopen interactively and be refused under `--unattended`, except an unmerged close (task branch reads `done`, the default branch does not), which resumes the merge without asking. A `done` or `verify` in the working copy that `HEAD`'s copy does not carry SHALL NOT count as a closed record: the system SHALL read the status from `HEAD`'s copy (`todo` when it has none) and run the close again from deciding where it runs, review passes included, under `--unattended` too; an uncommitted `in-progress`, `cancelled` or `blocked:` SHALL be read as written.

#### Scenario: Unattended close of a blocked task

- **Given** `TASK-033` carries a `blocked:` field
- **When** it is closed with `--unattended`
- **Then** the output is `not closed: TASK-033 is blocked: <reason>` and no file changes

#### Scenario: Interrupted merge

- **Given** a previous close committed `done` on `task/TASK-033` and then failed to merge
- **When** the task is closed again
- **Then** the close goes straight to the merge step without asking to reopen

#### Scenario: Close interrupted before its commit

- **Given** `TASK-034`'s working copy reads `done` while `HEAD`'s copy reads `todo`
- **When** it is closed with `--unattended`
- **Then** the close is not refused as already done; it runs the review passes again, writes `done`, and commits

### Requirement: Out-of-scope sweep at close

The system SHALL, before the status flip and also before parking at `verify`, classify every out-of-scope bullet as a boundary (left as prose), work (offered to `spawn`, grouping related small bullets into one task) or a decision not to do (rewritten to say so and why). A close SHALL NOT finish with an unowned work bullet. The confirmation SHALL report the counts and name every spawned id.

#### Scenario: Unowned work bullet

- **Given** an out-of-scope bullet "the export path has the same bug" naming no owner
- **When** the task is closed
- **Then** the bullet is offered as a spawn, and the confirmation reads `out-of-scope: 0 boundary, 1 spawned, 0 declined` with the new id

### Requirement: Close commit and reference

The system SHALL, in a git repository with uncommitted changes, ask whether to commit, reference an existing commit or PR, or skip; a commit SHALL stage the work and the task file explicitly (never all files), with a subject led by the task id and no co-author trailer. Under `pr-per-task` the work commit's SHA SHALL be written into `pr:` so it rides in the merge commit; under `single-branch` `pr:` SHALL stay null. Status is written before this commit so the tracking file lands with the work.

#### Scenario: Single-branch close

- **Given** `integration: single-branch`
- **When** a task is closed and committed
- **Then** the commit subject begins with the task id and `pr:` stays null

### Requirement: Merge gate

The system SHALL, after a close commit on `task/TASK-NNN` that was decided as merge, push if needed, open the PR if none exists, merge (default `--no-ff`), delete the branch with a safe delete (and its remote copy when present), and return to the default branch before any later step. A conflict or rejected push SHALL be a failed close that leaves the task at its pre-close status. A worktree close SHALL instead check the main copy before writing, edit and commit in the worktree, leave the worktree and prove it in every shell, merge in the main copy, remove only a worktree this skill made, and delete the branch — never forcing, pruning or using a hard delete, and printing the outstanding commands for any step left undone. With an upstream the merge SHALL go through the remote's PR (queued to auto-merge when not yet mergeable), followed by a fast-forward pull and deletion of the remote task branch.

#### Scenario: Conflict on merge

- **Given** a task branch that conflicts with the default branch
- **When** the merge step runs
- **Then** the close is reported failed and the task file does not read `done` on the default branch

#### Scenario: Removal refused

- **Given** a merged worktree close where the worktree holds an uncommitted file
- **When** removal is attempted
- **Then** the task is `done`, the dirty path is named, and the outstanding `git worktree remove` and branch-delete commands are printed without forcing

#### Scenario: Checks still pending

- **Given** an upstream and a PR whose checks are pending
- **When** the close reaches the merge
- **Then** the PR is queued to auto-merge, the worktree is kept, and a later close runs only the tail

### Requirement: Unattended close contract

The system SHALL, under `close --unattended`, ask nothing at any step: refuse a closed or blocked task, print the CI line without asking, resolve an unfilled test plan itself, push and open the PR when parking at `verify`, merge at the merge decision, spawn every work bullet (treating unclassifiable bullets as work, with "decided not to do" unavailable) with each of the spawn's own questions taking its answer-less path — the spawn's defaults standing unmarked, any other field marked as inferred, and a `cancelled` parent left cancelled — commit with explicit staging, skip the clean-tree reference prompt, skip the spec regen when references are missing, and skip an unauthenticated Jira step and report it. Every step that could ask SHALL have a defined unattended row.

#### Scenario: Drain-driven close

- **Given** an unattended close on a `pr-per-task` project with all gates passing
- **When** the close runs
- **Then** the task is committed, merged and set `done` with no question asked, and every spawned id is listed in the report

### Requirement: Post-close tracker sync and hints

The system SHALL close the linked GitHub issue or transition the Jira ticket only when the task reached `done`, never for `verify` or a deferred merge. It SHALL regenerate the dashboard and chain the feature status refresh for any feature-linked task whose status changed, but fire last-open-task suggestions, the feature review prompt and the changelog nudge only on `done`. A story close SHALL offer a scoped spec regen (or report that no usable spec map exists). With an upstream nothing is written on the default branch; the new status is printed with the verbs to run through a PR. Every file the dashboard and rollup steps write SHALL be committed by a named step or named as uncommitted in the confirmation: a close whose commit lands on the default branch SHALL regenerate them first and carry them in that commit; a close merged by the merge gate with no upstream, in place or in a worktree, SHALL commit only the regenerated files with a subject that does not lead with the task id; a close left unmerged on a task branch SHALL write neither.

#### Scenario: Single-branch close leaves a clean tree

- **Given** a `single-branch` project with no upstream, and a task closed to `done` or parked at `verify`
- **When** the close finishes
- **Then** one commit carries the work, the task file and the regenerated dashboard, and `git status --short` is empty

#### Scenario: Verify does not close the issue

- **Given** a hybrid GitHub project and a task closed to `verify`
- **When** the close finishes
- **Then** the issue stays open, the dashboard is refreshed, and no last-open-task suggestion is printed

#### Scenario: Upstream tail

- **Given** a worktree close with an upstream that merged
- **When** the tail runs
- **Then** the dashboard is not written on the default branch and the report names `/tasks triage` and `/feature status` to run through a PR

### Requirement: Closing stories and epics

The system SHALL close a story or epic only when every child task (and, for an epic, every story) is `done` or `cancelled`, listing open children and refusing otherwise unless `--force` is passed; it then flips the container to `cancelled` when every child is `cancelled` (an epic counting its stories and directly parented tasks together) and to `done` otherwise, the same rule `cancel`'s rollup applies, re-evaluates its parent, regenerates the dashboard and runs the post-close hints, then, with no upstream, commits only the flipped container files and the regenerated dashboard under a subject that does not lead with the container id. With an upstream it SHALL commit the container files, under the same subject, in a temporary worktree at the upstream, push them as `record/<ID>`, then restore them in the main copy, leaving it clean and naming the branch for a person to land through a PR. It SHALL commit nothing, and name the files instead, when it is not in the main copy on the default branch, the default branch is ahead of its upstream or cannot fast-forward to it, or `record/<ID>` already exists. When the push is refused it SHALL keep the temporary worktree and name the commit. Containers have no test plan or merge step.

#### Scenario: Open children

- **Given** a story with two open tasks
- **When** the user runs `/tasks close --story STORY-008`
- **Then** it refuses, naming the two tasks and `--force`

#### Scenario: Every child cancelled

- **Given** a story whose two tasks are both `cancelled`
- **When** the user runs `/tasks close --story STORY-004`
- **Then** the story reads `cancelled`, not `done`

#### Scenario: Story closed with an upstream

- **Given** a project whose default branch tracks a remote and is level with it
- **When** the user runs `/tasks close --story STORY-001`
- **Then** `record/STORY-001` is pushed carrying `chore: close STORY-001`, the main copy is clean on the default branch, and the confirmation names the branch

### Requirement: Parents rolled up after child changes

The system SHALL, after any child status or placement change, or the creation of a child, re-evaluate the parent story and then its epic and update their files so no container asserts a state its children contradict; `triage` SHALL flag a parent that does. Starting a task SHALL move a `planned` parent story, and then its epic, to `in-progress` in the same checkout and commit as the task's own flip, reporting each move. Rollup hints never auto-close a container. When a child stops being `done` or `cancelled` and the default branch has an upstream, it SHALL check each container it would reopen for an unlanded `record/<ID>` branch on the upstream's remote, recomputed every run, and report each one found as a record that must not be landed as is, writing nothing to it; a check that cannot reach the remote SHALL be reported as not checked. The check SHALL run once per run, not once per child: each container is checked at most once and each distinct `record/<ID>` line printed once, naming every open child it found; a container created in the same run SHALL NOT be checked; and after the first failure to reach the remote the run SHALL ask it nothing more and print one not-checked line naming every container left unchecked. An open child moved in or created SHALL be checked against its parent and the epic above a parent story whatever they read, since a container closed on an unlanded record branch still reads open in the main copy. A re-close that parks a previously `done` or `cancelled` task at `verify` SHALL reopen its parent and the epic above a story parent at the park, writing them into the park commit when it lands on the default branch with no upstream, writing them uncommitted and naming them when the close commits nothing, and otherwise writing nothing and reporting each as not reopened; a re-close that ends `done` SHALL reopen nothing. Move, creation (including a spawn, an intake, an import and a feature decompose, each of which prints in its place), a decide revert, a review park and a re-close park SHALL each carry these lines, each reopened container, and each copy of the tree an id scan could not read, in their own report.

#### Scenario: Last task cancelled

- **Given** a story whose other tasks are `done`
- **When** its last open task is cancelled
- **Then** the story is reconciled to `done`

#### Scenario: Starting the first task of a planned story

- **Given** a `planned` epic and story over a `todo` task, on a single-branch project
- **When** the task is picked
- **Then** the task, the story and the epic all read `in-progress`, and the run reports `STORY-NNN started` and `EPIC-NNN started`

#### Scenario: A child leaving done reopens its story

- **Given** a story reading `done` whose task is moved from `done` to `verify`
- **When** the parent is re-evaluated
- **Then** the story reads `in-progress` with a dated reopen line, its epic is re-evaluated the same way, and the reopen is reported

#### Scenario: A story closed on an unlanded record branch

- **Given** a project whose default branch tracks a remote, and `STORY-001` closed `done` on `record/STORY-001`, which has not landed, so the main copy still reads `in-progress`
- **When** one of its tasks moves from `done` to `verify`
- **Then** the story is not changed, and the report says `record/STORY-001` is unlanded, closes `STORY-001`, and now has an open child, so it must not be landed as is

#### Scenario: A re-close whose test fails reopens the story

- **Given** a `single-branch` project with no upstream, a `done` story, and its `done` task
- **When** the task is reopened and re-closed, and its Human test plan step is reported failed
- **Then** the task reads `verify`, the story reads `in-progress` with a dated reopen line, both ride in the park commit, and the confirmation names the reopen

#### Scenario: New or moved work under a story closed on an unlanded record branch

- **Given** a project whose default branch tracks a remote, and `STORY-001` closed `done` on the unlanded `record/STORY-001`, so the main copy reads `in-progress`
- **When** an open task is moved into `STORY-001`, or a new task is created under it
- **Then** nothing is reopened, and the move's report and the creation's confirmation each name `record/STORY-001` as unlanded, closing `STORY-001` over the open child, and not to be landed as is

#### Scenario: A batch under a story closed on an unlanded record branch

- **Given** a project whose default branch tracks a remote, and `STORY-001` closed `done` on the unlanded `record/STORY-001`
- **When** `/tasks intake` files three findings as tasks under `STORY-001`
- **Then** intake's report names `record/STORY-001` once, listing all three open children, and does not repeat it per task

#### Scenario: A batch that cannot reach the remote

- **Given** a project whose default branch tracks a remote that cannot be reached
- **When** one run creates a new story and five tasks under it and two tasks under an existing story
- **Then** the new story is not checked, and the report carries one not-checked line naming the existing story and its epic

### Requirement: Moving a task or story

The system SHALL re-home one or more tasks or stories under a story, an epic or the loose folder by moving the file (with history-preserving move under git) and updating `parent:` with a frontmatter-anchored edit, after confirming a plan line per move. It SHALL refuse an unknown id, an epic as the moved item, a missing destination (never creating one), a task as destination, and a story under a story. It SHALL roll up the parents on both sides, report each parent changed and each checked and left alone, keep status and body untouched, and warn when a review finding is moved to loose. `--dry-run` writes nothing.

#### Scenario: Loose findings into an epic

- **Given** three loose defect tasks and an existing epic
- **When** the user runs `/tasks move TASK-101 TASK-102 TASK-103 --to EPIC-009`
- **Then** the files move under the epic, each `parent:` reads `EPIC-009`, and the report lists the epic as re-evaluated

#### Scenario: Typo in destination

- **Given** no `STORY-099` exists
- **When** a task is moved `--to STORY-099`
- **Then** the move is refused and no container is created

### Requirement: Cancelling work

The system SHALL set a task, story or epic to `cancelled` (confirming first when it is `in-progress` or `done`), remove any `blocked:` field (the block's reason survives in its body note), append a dated reason note, never delete the file, warn about dependents, point at the owning feature decision when the item is feature-linked without editing the ledger, close the remote issue as not planned in hybrid mode, roll up parents, and regenerate the dashboard. Cancelling a container SHALL list its open children and ask whether to cancel them, never cascading automatically. There is no uncancel: reviving cancelled work SHALL go through `/tasks new` citing the cancelled id, never a hand edit of `status:`; a cancel not yet committed MAY be discarded with `git restore` when its edits are the only changes in those files, reopening any remote issue it closed.

#### Scenario: Feature-linked task cancelled

- **Given** `TASK-025` with `feature: FEATURE-002`
- **When** it is cancelled with a reason
- **Then** the status reads `cancelled`, a `> Cancelled <date> — <reason>` note is appended, and the user is told FEATURE-002's decision likely needs a change

### Requirement: Blocking and unblocking

The system SHALL add a `blocked:` reason field to a task without changing its status, refusing `done` or `cancelled` tasks and warning and stopping when already blocked, before asking anything; it SHALL settle the reason before writing it, place the field directly below the template's `# blocked:` comment line when the file has one and otherwise after the `status:` line and its comment, confirm an in-progress block (blocking anyway with no answer and saying nobody confirmed), merge `--on` ids — tasks or stories — into `depends-on`, write a `> Blocked <date> — <reason>` note directly under the task's heading, above any earlier note — with no reason given, using `waiting on <ids>` when `--on` names them, otherwise asking a fixed question and, with no answer, blocking with `reason unknown`, a note that nobody gave one and a confirmation saying nobody chose it, each replacing the usual note and line rather than added beside them, commit nothing in either direction and name the files left uncommitted as repo-relative paths separated by `, ` — mirror the block to a linked tracker as a label or flag plus a `Blocked:` comment without changing the issue's open state, and regenerate the dashboard. Unblock SHALL remove the field and leave status alone, write a `> Unblocked <date> — …` note in the same place, mirror the removal, and for an old-form blocked status recover the prior state from history or ask — falling back to `todo` with a note that nobody chose it, never leaving it blocked. Containers cannot be blocked.

#### Scenario: Block keeps state

- **Given** `TASK-012` at `todo`
- **When** the user runs `/tasks block TASK-012 --reason "waiting on API keys"`
- **Then** the file keeps `status: todo`, gains `blocked: waiting on API keys`, and the task leaves "Next up"

#### Scenario: Old-form unblock with nobody to ask

- **Given** a task reading `status: blocked` whose history does not show a prior state
- **When** it is unblocked unattended
- **Then** it becomes `status: todo` with no `blocked:` field and a note that the state was set to todo with nobody choosing it

#### Scenario: Block with no reason and nobody to answer

- **Given** an open task TASK-050 and nobody present
- **When** `/tasks block TASK-050` runs with no `--reason` and no `--on`
- **Then** the task gains `blocked: reason unknown`, its status is unchanged, its note says nobody gave a reason, and the report says nobody chose it

#### Scenario: Block on a task with no reason

- **Given** an open task TASK-050
- **When** `/tasks block TASK-050 --on TASK-051` runs with no `--reason`
- **Then** nothing is asked and the reason reads `waiting on TASK-051`

### Requirement: Backlog audit

The system SHALL scan the backlog, read-only by default, for duplicates (wide acceptance and Context overlap, judged by meaning, reporting score and judgement), mergeable and splittable tasks, old-form statuses (counted and pointed at `init`), blocked-field contradictions, stale work, broken links (including a `depends-on` naming an epic, and a dependency on a finished task or story as an unblock candidate), dependency cycles (a task naming its own parent story among them, an epic id being a broken link only), work out of order (a task started or finished while a task or story it depends on is still open, reported and never edited), incomplete tasks and orphans, each with a severity and a suggested action; drift between tasks and features is left to the roadmap view. With `--fix` it SHALL apply only reversible fixes, one confirmation each — merge as cancel-with-note, removing a satisfied dependency (which never removes a `blocked:` field: a blocked task whose dependencies are all satisfied is named as an unblock candidate for `unblock`), reparenting — then regenerate the dashboard. Under `--across` checks run within each project, and `--fix` and `--scope` are refused.

#### Scenario: Synonym duplicate

- **Given** two tasks titled "JWT issuance on login" and "Issue JWT at sign-in" with identical acceptance criteria
- **When** audit runs
- **Then** the pair is reported as a duplicate with its low title score and a by-meaning verdict, and nothing is changed without `--fix`

#### Scenario: Qualifier-distinct pair

- **Given** two tasks with matching acceptance criteria whose titles differ by client versus server
- **When** audit runs
- **Then** they are reported as mergeable-or-distinct and cancelling one is never proposed

#### Scenario: A task started before the story it waits on

- **Given** TASK-002 is `in-progress` with `depends-on: [STORY-001]`, and STORY-001 is `in-progress`
- **When** the audit runs
- **Then** it reports TASK-002 as out of order and edits neither file

#### Scenario: A task waiting on its own story

- **Given** TASK-003, under STORY-002, with `depends-on: [STORY-002]`
- **When** the audit runs
- **Then** it reports a cycle: the story cannot finish before the task does

#### Scenario: Cross-project dependency

- **Given** `--across` and a dangling `depends-on: TASK-004` in one project while a sibling has its own `TASK-004`
- **When** the broken-links check runs
- **Then** the dangling reference is still reported

### Requirement: Importing work

The system SHALL decompose a local notes file into a proposed epic, story and task tree for review, create the approved items with default fields, preserve done items as `done`, and never modify the source file. In hybrid mode it SHALL import a GitHub issue or Jira ticket into a local file, mapping title, body sections, priority, assignee, parent, open or closed state, and a blocked label or flag to a `blocked:` field whose reason comes from the newest `Blocked:` comment (else `reason unknown`), recording the issue link and refusing an issue already linked locally. A Jira ticket with no `priority/P<n>` label SHALL take its priority from the priority field. One with a label SHALL compare the two: when they agree, that value; when they differ and the issue's changelog shows a priority change later than the change that set the label, the field's value, since someone chose it there; otherwise, or when the field is empty or unmapped, the label's value. Several priority labels with different values SHALL count as none. A disagreement SHALL always be reported in the confirmation, whichever side was written, and never resolved silently; the field SHALL map to a `P<n>` value and never into a fixed set: a name already of the form `P<n>` as given, Jira's default scheme Highest through Lowest to P0 through P4, and, on a ticket with no usable label, any other name or none to `P1` with a `## Context` line saying nobody chose it, named again in the import's confirmation.

#### Scenario: Exported priority survives a round trip

- **Given** a `P3` task exported to a Jira project that offers no priority matching P3, so its field stays at the default Medium
- **When** the ticket is imported back
- **Then** the task reads `priority: P3`, taken from the `priority/P3` label, not P2 from the Medium field, and the confirmation reports the disagreement

#### Scenario: Priority edited in Jira after export

- **Given** a ticket labelled `priority/P3` since creation, whose priority field a user later changed from Low to Highest
- **When** it is imported
- **Then** the task reads `priority: P0`, and the confirmation reports that the priority changed in Jira after the label was set

#### Scenario: Label and an untouched field disagree

- **Given** a ticket labelled `priority/P3` whose field has held the project default Medium since creation
- **When** it is imported
- **Then** the task reads `priority: P3`, and the confirmation reports the disagreement

#### Scenario: Unmapped Jira priority

- **Given** a Jira ticket whose priority reads `Blocker`
- **When** it is imported
- **Then** the task reads `priority: P1`, its Context says the priority had no mapping and nobody chose P1, and the confirmation names it

#### Scenario: Blocked GitHub issue

- **Given** an open issue labelled `blocked` with a comment `Blocked: awaiting legal`
- **When** it is imported
- **Then** the task reads `status: todo` with `blocked: awaiting legal` and the issue number recorded

### Requirement: Exporting a task

The system SHALL, in hybrid mode only (a migration runs the payload and push steps itself before the switch), push one task, story or epic to the configured tracker, linking a GitHub task to its epic's milestone by the title `<EPIC-ID> <epic title>`, found in the repo's open and closed milestones, when the repo has one and naming the task as not linked when it does not, never creating a milestone itself; under a migration the repo or project SHALL be the migration's own, since the configuration names none until the migration ends: title from the first heading after the frontmatter (never a frontmatter comment), body from the task's sections plus a footer pointing back to the local file, labels for priority (on Jira too, where the label is what carries the value back), assignee, epic, story and the configured defaults — creating any missing label first and naming it — plus a blocked marker and `Blocked:` comment for a blocked task; on Jira, a task's priority field SHALL be set by the inverse of the import mapping, to a priority named exactly the task's `P<n>` value or, where the project offers all five of Highest through Lowest, those for P0 through P4, and otherwise (no match, a value not of the form `P<n>`, unreadable metadata, no priority field) left as the project sets it, never set to a nearest name, with the confirmation naming the task and why; then write the returned id back to frontmatter. Re-exporting a linked item SHALL ask first, defaulting to abort, and a failed push SHALL leave frontmatter untouched.

#### Scenario: Exported priority sets the Jira field

- **Given** a `P0` task and a Jira project offering Highest, High, Medium, Low and Lowest, with Medium as its default
- **When** the task is exported
- **Then** the ticket's priority field is Highest and the `priority/P0` label is sent too

#### Scenario: Jira priority with no match

- **Given** a `P7` task and a Jira project offering Highest through Lowest
- **When** the task is exported
- **Then** the priority field is left at the project default, the `priority/P7` label is sent, and the confirmation names the task and says the label carries the priority

#### Scenario: Missing label

- **Given** a GitHub repo with only default labels and a P3 task
- **When** the task is exported
- **Then** `priority/P3` is created first, the issue is created, and the confirmation names the created label

### Requirement: Migrating to hybrid mode

The system SHALL, from local mode only, ask for the target repository or project when none was passed — with no answer pushing nothing, writing nothing and reporting that no target was given, never taking one from a git remote — then inventory open epics, stories and every task not `done` or `cancelled` (awaiting-verification and blocked tasks included), show the plan and require an explicit `yes` — any other answer, or none, pushes nothing, writes nothing and reports that it did not migrate — run pre-flight checks, push in order writing each remote id back as it goes (finding an epic's milestone by its `<EPIC-ID> <epic title>` title before creating it, and pushing each task through the export payload and push steps with this run's provider, bypassing export's hybrid-mode check), stop on the first failure, and only after success flip the configuration to `hybrid` with the chosen provider. A re-run SHALL skip already-linked items. `--dry-run` SHALL print the plan, the pre-flight result and every payload in push order (epics and stories as export's container payloads, tasks as export's task payload, bodies by section name), with a task whose epic is in the run previewed as `would link to "<EPIC-ID> <epic title>"` rather than looked up, ask nothing but that target question, and change no file, `.config.yml` included. The plan's API-call total SHALL count one create per planned item. Epic milestones SHALL be looked up among open and closed milestones before being created.

#### Scenario: Interrupted migration

- **Given** a migration that failed after pushing ten of twenty tasks
- **When** it is re-run with the same provider
- **Then** only the ten unlinked tasks are pushed

#### Scenario: Dry run changes nothing

- **Given** a local-mode tree with open work
- **When** `/tasks migrate --to github --repo example-org/shop --dry-run` runs with nobody present
- **Then** the plan and payloads are printed, each task under an epic in the run shows `would link to "<EPIC-ID> <epic title>"`, no question is put, and no task file or `.config.yml` changes

#### Scenario: Confirmation unanswered

- **Given** a local-mode tree with open work and nobody present
- **When** `/tasks migrate --to github --repo example-org/shop` reaches the confirmation
- **Then** nothing is pushed, the config still reads `mode: local`, and the report says the run did not migrate

### Requirement: Initialising and reconciling the configuration

The system SHALL create the task folder, configuration and initial dashboard, or reconcile an existing configuration by adding every field the template declares and the file lacks — a field being a key, live or as a commented example, never the header lines or a comment trailing a value — optional commented blocks included, while a field already live keeps its line and gains no comment (carrying the template's comment, in the template's position, never re-adding an existing comment block) while never changing existing values or unknown keys. Values passed by a caller (mode, repo, project, integration, workspace, worktree root) SHALL be written and never re-asked. `integration:` SHALL be asked, with a third option for no opinion; with no answer it SHALL be left absent and reported unresolved, never defaulted, the same for every caller; a no-opinion answer or `integration=declined` SHALL write a dated `# integration: declined` marker and no live key, and a marker already present SHALL stop the question; mode detection SHALL run only when the configuration is absent, an existing file's mode being read; a second run SHALL leave the configuration and task files unchanged and regenerate only the dashboard; workspace questions are left to the front doors, and a workspace question skipped under `single-branch` SHALL be reported in one line, `workspace undeclared — tasks work in place (not asked: single-branch)`. A mode conflict SHALL keep the existing value when unanswered. The outcome SHALL be reported as created, already current or brought up to date, naming every field added and every field left unresolved.

#### Scenario: Older config missing integration

- **Given** an existing configuration with `mode: local` and no `integration:` line, run with no arguments and no answer
- **When** `/tasks init` runs
- **Then** the commented `integration:` block is added, `mode: local` is untouched, and the report names `integration:` as unresolved

#### Scenario: Declined integration

- **Given** `/tasks init integration=declined` on a repo with no `integration:` key
- **When** the config is written
- **Then** no live `integration:` key is written, the dated declination marker sits below the commented block, and a later run does not ask

#### Scenario: Second run on a current config

- **Given** an up-to-date `tasks/.config.yml` with `mode: local`
- **When** `/tasks init` runs again with no arguments
- **Then** no mode question is put, the configuration and task files are unchanged, and only `tasks/README.md` is regenerated

#### Scenario: Caller passes the answer

- **Given** an existing configuration and `integration=single-branch` passed by the adopter
- **When** init runs
- **Then** a live `integration: single-branch` line is written

### Requirement: Migrating the old status vocabulary

The system SHALL, during init, rewrite only this tree's task files: `status: review` becomes `status: verify`; `status: blocked` becomes the prior state read from the file's git history (a prior `review` written as `verify`) plus a `blocked:` field, or keeps an existing `blocked:` field unchanged. The reason SHALL come from the first rung that answers — the newest unresolved `Blocked <date> —` note, then unfinished `depends-on` tasks as `waiting on …`, then a sentence that says why the task is held, then `reason unknown` — in the source's own words with its label dropped, cut to one unit of at most 120 characters, a pointer to where the full text lives when something was cut, and quoted last. When history cannot tell, or the prior state was finished, it SHALL ask; with no answer it SHALL write `todo` plus the `blocked:` field and a note that nobody chose it. Already-migrated files SHALL be left byte for byte, and each file's outcome reported with its state source and reason rung, quoting the source line for a judgement reason.

#### Scenario: Reason from a block note

- **Given** a task reading `status: blocked`, earlier history at `in-progress`, and a note `> Blocked 2031-02-10 — vendor contract unsigned`
- **When** init migrates it
- **Then** it reads `status: in-progress` and `blocked: vendor contract unsigned`, reported as from history with the `note` rung

#### Scenario: Created blocked, nobody to ask

- **Given** a task created at `status: blocked` with no note and no open dependencies
- **When** init runs unattended
- **Then** it reads `status: todo` with `blocked: reason unknown`, and a migrated note says nobody chose the state

#### Scenario: Second run

- **Given** a tree already in the new form
- **When** init runs again
- **Then** no task file changes and the outcome is reported as already current
