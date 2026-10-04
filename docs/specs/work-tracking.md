---
area: work-tracking
generated-at: eebeb6e79631d115bc4ae1831c6e92792b594311
generated-on: 2026-10-04
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
  - skills/tasks/verbs/help.md
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
shaped-by-unresolved: 7
---

# The developer-facing backlog — epics, stories and tasks, with a gate before done

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

The system SHALL mint `EPIC-NNN`, `STORY-NNN` and `TASK-NNN` ids from one counter per type for the whole project, zero-padded to three digits, by taking the maximum id over this tree's files (including uncommitted ones), over every local branch, and over every other registered worktree's task tree, with the id pattern tolerant of trailing whitespace and carriage returns. The scan SHALL be recomputed on every mint, the file written immediately after it, and any copy the scan could not read named in the confirmation. `FIELD-NNN` finding ids SHALL be minted the same way over every copy's `findings:` lists.

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

The system SHALL enumerate every epic, story and task file in one pass, read each file's frontmatter (id, parent, feature, status, priority, assignee, findings, affects, kind, theme, created, depends-on, blocks and the parsed `blocked:` value) and its first heading as the title, and build status counts, a per-priority breakdown of `todo` tasks containing one bucket per priority actually present, lists of in-progress tasks, tasks awaiting verification and next-up tasks, and a by-parent map. Under worktree workspace a task whose own task branch reads `verify` or `review` SHALL also count as awaiting verification.

#### Scenario: Unusual priority value

- **Given** todo tasks at P1, P2 and P3
- **When** the priority breakdown is built
- **Then** it shows three buckets ordered P1, P2, P3 and drops none

#### Scenario: Verify parked on a task branch

- **Given** workspace `worktree`, and a task whose default-branch copy reads `in-progress` while its task branch copy reads `verify`
- **When** the collection pass runs
- **Then** the task is listed as awaiting verification

### Requirement: Taken tasks derived from branches

The system SHALL treat a `todo` task as taken when a `task/TASK-NNN` branch exists locally or on a remote, show it as in progress, and never offer it as next work. This SHALL be recomputed from the branches on every run and never written into the task file, and skipped where there is no git.

#### Scenario: Another clone picked the task

- **Given** the default branch's copy of `TASK-017` reads `todo` and `origin/task/TASK-017` exists
- **When** the snapshot or `pick` runs
- **Then** `TASK-017` is not offered as next work and is shown as taken

### Requirement: Status snapshot and help

The system SHALL render, for a bare `/tasks`, a stdout-only snapshot with the mode in the header, epic, story and task counts by status (with zero priorities suppressed), the in-progress list with blocked tasks marked by reason, an "Awaiting verification" list, the top three next-up tasks by priority excluding blocked ones, and the features slice whose shape another skill owns. It SHALL omit the verify line and section when nothing awaits verification and the features block when no features folder exists. It SHALL NOT write the dashboard. `/tasks help` SHALL print the verb table and a one-line hint, with no file I/O.

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

The system SHALL regenerate the dashboard file only through `triage` (chained by the verbs that change the tree), rebuilding it entirely from the collection pass with counts, a todo-by-priority line, "In progress now", an "Awaiting verification" section, a tree with per-story done counts and status markers (blocked tasks marked with their reason, cancelled ones struck through, feature links tagged), a loose section and a collapsed completed section, and a feature-drift callout when the roadmap divergence rules find any. It SHALL never write the dashboard inside a task's linked worktree, saying so in one line, and SHALL refuse `--across`, pointing at the read-only snapshot.

#### Scenario: Chained from a worktree

- **Given** a session inside the linked worktree of `TASK-020`
- **When** `block` chains `triage`
- **Then** the dashboard is not written and one line says why

#### Scenario: Drift found

- **Given** a feature whose phase contradicts its tasks
- **When** `triage` runs
- **Then** a feature-drift callout naming the divergence is placed under the dashboard title

### Requirement: Creating epics, stories and tasks

The system SHALL create a node by asking its level (with a decision test when unsure), title, parent (an existing epic for a story; a story, an epic or none for a task), and for tasks priority and assignee (defaults P1 and ai); it SHALL mint the id, compute the path from the parent chain, render the level's template with `planned` for containers and `todo` for tasks, offer to draft the task body (writing `N/A — fully covered by automated tests` for a plainly unit-testable task rather than filler steps), regenerate the dashboard, and auto-run `plan` for a task unless `--no-plan` was passed. Template fields with no value for this node (an epic's `kind:`/`source:`, a story's `theme:`) SHALL be omitted rather than rendered empty. Whenever the new task carries a `feature:` link, by any route, it SHALL be written into the owning decision row's task column, and if no approved or changed row covers it a new `proposed` row SHALL be appended instead.

#### Scenario: Task inheriting a feature

- **Given** a new task created under a story whose tasks carry `feature: FEATURE-005`, with the feature written by hand
- **When** the task is written
- **Then** its id is added to the matching decision row of FEATURE-005, even though `--from-feature` was not passed

#### Scenario: Batch creation

- **Given** `/tasks new task --no-plan`
- **When** the task is created
- **Then** no plan is drafted and the confirmation says to run `plan` later

### Requirement: Tasks born from findings

The system SHALL, on `new --from-review <ids>`, set `findings:` to those ids and write each finding's evidence into the task's Context so it stands alone, drafting acceptance criteria from what must hold once fixed. On `new --from-field` it SHALL mint the next tree-wide `FIELD-NNN`, set it as the task's only finding, write the field evidence into Context, and report the minted id and that the task is now in the defect drain's pool.

#### Scenario: Field-found defect

- **Given** the highest field finding anywhere in the tree is `FIELD-006`
- **When** the user runs `/tasks new task --from-field`
- **Then** the task carries `findings: [FIELD-007]` and the confirmation says it is now in the drain's pool

### Requirement: Implementation plans

The system SHALL draft a task's `## Implementation plan` by handing its title, Context, acceptance criteria and out-of-scope to a planning agent that must not change the criteria (raising doubts as a flagged note at the top), refuse to overwrite a non-empty plan without `--replan` (with an extra confirmation on an in-progress task), leave the file untouched when planning fails, offer `spawn` for plan steps that are separately completable, and then offer a grilling pass. Plans apply to tasks only.

#### Scenario: Existing plan

- **Given** `TASK-014` already has a non-empty plan
- **When** the user runs `/tasks plan TASK-014`
- **Then** it refuses and says to re-run with `--replan`

#### Scenario: Plan on a container

- **Given** an id that resolves to a story
- **When** `plan` is invoked on it
- **Then** it errors that plans only apply to tasks

### Requirement: Cutting work into slices

The system SHALL cut work into vertical tasks that each pass three hard checks — Context stands alone, every criterion is verifiable inside the task beyond its `depends-on`, and the gate cannot go red after it lands — with a prefactor as its own task that `blocks` the change, a one-line reason in Context for any tripped size signal kept as one task, and the rule or check named for every rejected slice. A change whose readers span more owners than one slice may touch SHALL be sequenced expand → migrate (batches by fan-out) → contract, with ordering recorded as `blocks:`/`depends-on:` on both task files rather than by blocking. When batches cannot stay green under `single-branch`, it SHALL collapse them into one task or widen the expand and report which in a fixed line, never changing `integration:` to fit.

#### Scenario: Horizontal cut rejected

- **Given** a proposal to link every mention of a new skill first and write the skill second
- **When** the slicing is checked
- **Then** the first slice is rejected, naming the hard check that the gate would fail before the folder exists

#### Scenario: Single-branch fallback

- **Given** `integration: single-branch` and migration batches that cannot coexist with the old form
- **When** the sequence is planned
- **Then** the report reads `integration fallback unavailable under single-branch — non-green batches collapsed into TASK-077` or names the alias that widened the expand

### Requirement: Picking a task

The system SHALL list `todo` tasks matching the filters (priority, assignee, epic, story, feature), ordered by priority then creation date, including blocked ones marked with their reason and excluding taken ones, which are named in a separate line; it SHALL report verification debt before the list, asking whether to clear it first when there are three or more such tasks but never blocking the pick. After the choice it SHALL offer to plan first when no plan exists (default yes, naming what triggered the recommendation), flip the status to `in-progress`, regenerate the dashboard and hand off by assignee. A blocked task SHALL NOT be started without an explicit yes to unblocking it; unmet dependencies only warn.

#### Scenario: Debt nudge

- **Given** three tasks awaiting verification
- **When** the user runs `/tasks pick`
- **Then** the ids are listed and the user is asked whether to clear verification debt first, with yes as default

#### Scenario: Blocked task with nobody to answer

- **Given** `TASK-009` carries `blocked: waiting on vendor`
- **When** it is picked with no answer to the unblock question
- **Then** it reports `not started: TASK-009 is blocked: waiting on vendor` and changes nothing

#### Scenario: Unplanned task

- **Given** a task with four acceptance criteria and an empty plan
- **When** it is picked
- **Then** the user is offered `/tasks plan` first, with the number of criteria named as the reason

### Requirement: Task branch per integration policy

The system SHALL read `integration:` from the configuration and never infer it from history. Under `pr-per-task` (also the default when the field is absent) `pick` SHALL offer to cut `task/TASK-NNN` from the default branch, making an initial commit first on an unborn repository; under `single-branch` it SHALL offer no branch. The field is written only from a passed argument or a user's answer.

#### Scenario: Single-branch repo

- **Given** `integration: single-branch`
- **When** a task is picked
- **Then** no task branch is offered and work continues on the default branch

### Requirement: Worktree workspace

The system SHALL, when `workspace: worktree` is declared under `pr-per-task`, give each picked task its own worktree at `<worktree-root>/<repo-name>-TASK-NNN` outside the repository: asking for the root once when undeclared and writing it only after every check passes; refusing a root inside the repository; requiring the pick to run from the main copy, on the default branch and clean apart from this task's tree files; refusing when a branch, folder or registration is left from an earlier pick; committing the pick as `TASK-NNN: pick` on the default branch before creating the worktree (no upstream); then entering the worktree and proving the move with a separate later top-level check in every shell. A failed proof SHALL remove the new worktree and branch without force and continue in place. An in-progress task that already has a worktree SHALL be resumed into it, never given a second one. `workspace:` absent means in place; under `single-branch` the setting has no effect and says so on every run. Every outcome prints its own fixed line.

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

The system SHALL treat a worktree workspace as having an upstream whenever the default branch tracks one, recomputed every run: fetch with prune first; refuse when the local default branch has commits the upstream lacks; refuse when the task branch exists on the remote but not locally (another clone has it); fast-forward a behind default branch; cut the task branch from the upstream; commit nothing on the local default branch; carry the new task's files into the worktree and restore the main copy; commit the pick on the task branch and push it, so the pushed branch marks the task taken in every clone.

#### Scenario: Another clone holds the task

- **Given** an upstream and `origin/task/TASK-044` exists with no local branch of that name
- **When** `TASK-044` is picked
- **Then** a taken-elsewhere line is printed and nothing is changed

#### Scenario: Local commits not pushed

- **Given** an upstream and two local commits on the default branch the upstream lacks
- **When** a task is picked
- **Then** the local-ahead line asks for them to reach the upstream through a PR first, and nothing is changed

### Requirement: Read-only view of a node

The system SHALL print a task, story or epic by id — header with parent chain, a metadata line (status with any blocked reason, priority, assignee, created, links and dependencies) and its body sections, or a container's children, recursing with `--tree` — without changing status, writing the dashboard or spawning agents, and SHALL end with a level-appropriate next-step hint.

#### Scenario: Unplanned task shown

- **Given** a `todo` task with an empty plan
- **When** the user runs `/tasks show TASK-021`
- **Then** the task is printed with a hint to run `plan` and a hint to pick it, and no file changes

### Requirement: Spawning discovered work

The system SHALL, when work outside the current task's acceptance criteria surfaces, offer to spawn it unprompted after a scope test (in scope or a one-line incidental is just done; torn spawns). It SHALL route a new capability to the feature lifecycle and an overturned decision to a decision change rather than mint a task; otherwise create the task under the origin's story, else its epic, else loose — stopping to place a review finding in a pool instead of loose — inheriting feature and assignee, with Context naming what, where and the origin. It SHALL then add a `Deferred to TASK-NNN` line to the origin's out-of-scope, rewrite a displaced plan step in place to point at the new id, wire dependencies, reconcile the feature ledger (a new `proposed` row when no decision covers it), regenerate the dashboard, and return to the origin.

#### Scenario: Refactor exposed mid-work

- **Given** `TASK-050` under `STORY-012` is in progress with a plan step that is really its own unit
- **When** the work is spawned
- **Then** `TASK-061` is created under `STORY-012`, the plan step reads `→ deferred to TASK-061`, the out-of-scope gains a deferred line, and work resumes on `TASK-050`

#### Scenario: Uncovered scope on a feature task

- **Given** the origin carries `feature: FEATURE-003` and no decision covers the discovery
- **When** it is spawned
- **Then** a new `proposed` row is appended to FEATURE-003's ledger and the user is told it needs a decision

### Requirement: Scope escalation of the task in hand

The system SHALL, when a task's own subject measures larger than filed, sweep without asking when it is a wider population or a higher altitude of the same fix, and stop and ask when it is a different problem — after finishing every covered part, recording the measurement as numbers in the task, filing the residue as its own task, and leaving the unmet criterion unticked as `⚠ NOT MET — split to TASK-NNN`.

#### Scenario: Different problem underneath

- **Given** a task about two colliding counts that turns out to be fixture ownership across many files
- **When** the measurement is complete
- **Then** the residue is filed as its own task, the criterion stays unticked with a split note, and the user is asked to choose among three options

### Requirement: Filing a review pass

The system SHALL turn a review pass's findings into one epic stamped `kind: review-intake` with its `source:`, one story per theme that received findings (each stamped with its ladder slug in `theme:`), and one task per group of findings sharing a root cause, each created through `new --from-review --no-plan` and prioritised by severity. Each finding SHALL get a source-prefixed id (`CR`, `SEC`, `SH`, `VC`, `VI`, `DRILL`; `FIELD` belongs to `new`), numbered within the pass or continuing an existing intake epic's numbering under `--epic`. Not-a-defect findings SHALL be dropped with the reason recorded on the epic; findings needing a decision go to the feature lifecycle; duplicates link to the existing task. A finding SHALL never be filed as a bare checklist line. One or two findings SHALL be redirected to `spawn` or `new`.

#### Scenario: Pass with a false positive

- **Given** eleven findings, two of which misread the code
- **When** the pass is filed
- **Then** nine findings become tasks under theme stories, and the two dropped ones are listed with reasons on the epic

#### Scenario: Tiny pass

- **Given** a pass with one finding
- **When** intake is invoked
- **Then** no epic is scaffolded and the user is pointed at `spawn` or `new`

### Requirement: Adopting an existing review backlog

The system SHALL, on `intake --adopt <EPIC>`, stamp `kind: review-intake` on an epic that already owns its tasks, best-effort backfill `findings:` from ids named in task bodies, report how many tasks got ids and how many did not without inventing ids, and offer (never guess) a `theme:` slug per story. Loose findings SHALL first be re-homed with `move`; adoption does not move tasks.

#### Scenario: Hand-built backlog

- **Given** an epic of eight hand-filed review tasks, five of which name finding ids in their bodies
- **When** it is adopted
- **Then** the epic is stamped, five tasks gain `findings:`, and the report says three got none

### Requirement: Human test plan decides verify or done

The system SHALL, at task close, require the `## Human test plan` to be resolved: an absent section or untouched placeholder must be filled with steps or with `N/A` and a reason before any status is chosen, and is never defaulted to `verify`. A step stays manual only when it needs human judgement or hardware; otherwise it is automated and proven able to fail. Unchecked real manual steps SHALL close the task to `verify`, never `done`, committing the finished work on the task branch, offering a PR marked awaiting sign-off, running the out-of-scope sweep, skipping the remote-tracker close, and still regenerating the dashboard. An explicit `N/A` plan closes straight to `done`.

#### Scenario: Unrun manual step

- **Given** a task whose test plan has an unchecked visual check
- **When** it is closed and the user has not run the check
- **Then** the status becomes `verify`, the work is committed, and the linked issue stays open

#### Scenario: Missing section

- **Given** a task with no `## Human test plan` heading
- **When** it is closed
- **Then** the closer must write steps or `N/A` with a reason before choosing between `done` and `verify`

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

The system SHALL, on a `pr-per-task` close on a task branch, ask whether to merge as part of the close — stating every pass's verdict in the question, default yes — before writing frontmatter. On yes the status SHALL be written `done`; on no the task SHALL stay `in-progress` and gain `blocked: 'merge deferred: <reason>; code complete on task/TASK-NNN'` (plus a dependency when waiting on another task's merge), the branch pushed and the PR opened or updated, and the task resumes later through `unblock` and a re-close. The decision is skipped for `--no-pr`, non-git, `single-branch`, or a close not on a task branch.

#### Scenario: Stacked PR

- **Given** a finished task whose PR must wait for `TASK-070` to merge
- **When** the user declines the merge
- **Then** the task stays `in-progress` with a quoted merge-deferred `blocked:` field and `TASK-070` in `depends-on`, and its issue stays open

### Requirement: A blocked task cannot be closed

The system SHALL ask, when closing a task blocked in either form, whether to unblock and close; with no answer, nobody present, or `--unattended`, it SHALL print `not closed: TASK-NNN is blocked: <reason>` and write nothing. An already `done` or `cancelled` task SHALL prompt to reopen interactively and be refused under `--unattended`, except an unmerged close (task branch reads `done`, the default branch does not), which resumes the merge without asking.

#### Scenario: Unattended close of a blocked task

- **Given** `TASK-033` carries a `blocked:` field
- **When** it is closed with `--unattended`
- **Then** the output is `not closed: TASK-033 is blocked: <reason>` and no file changes

#### Scenario: Interrupted merge

- **Given** a previous close committed `done` on `task/TASK-033` and then failed to merge
- **When** the task is closed again
- **Then** the close goes straight to the merge step without asking to reopen

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

The system SHALL, under `close --unattended`, ask nothing at any step: refuse a closed or blocked task, resolve an unfilled test plan itself, push and open the PR when parking at `verify`, merge at the merge decision, spawn every work bullet (treating unclassifiable bullets as work, with "decided not to do" unavailable), commit with explicit staging, skip the clean-tree reference prompt, skip the spec regen when references are missing, and skip an unauthenticated Jira step and report it. Every step that could ask SHALL have a defined unattended row.

#### Scenario: Drain-driven close

- **Given** an unattended close on a `pr-per-task` project with all gates passing
- **When** the close runs
- **Then** the task is committed, merged and set `done` with no question asked, and every spawned id is listed in the report

### Requirement: Post-close tracker sync and hints

The system SHALL close the linked GitHub issue or transition the Jira ticket only when the task reached `done`, never for `verify` or a deferred merge. It SHALL regenerate the dashboard and chain the feature status refresh for any feature-linked task whose status changed, but fire last-open-task suggestions, the feature review prompt and the changelog nudge only on `done`. A story close SHALL offer a scoped spec regen (or report that no usable spec map exists). With an upstream nothing is written on the default branch; the new status is printed with the verbs to run through a PR. A worktree close with no upstream SHALL commit only the regenerated files with a subject that does not lead with the task id.

#### Scenario: Verify does not close the issue

- **Given** a hybrid GitHub project and a task closed to `verify`
- **When** the close finishes
- **Then** the issue stays open, the dashboard is refreshed, and no last-open-task suggestion is printed

#### Scenario: Upstream tail

- **Given** a worktree close with an upstream that merged
- **When** the tail runs
- **Then** the dashboard is not written on the default branch and the report names `/tasks triage` and `/feature status` to run through a PR

### Requirement: Closing stories and epics

The system SHALL close a story or epic only when every child task (and, for an epic, every story) is `done` or `cancelled`, listing open children and refusing otherwise unless `--force` is passed; it then flips the container to `done`, re-evaluates its parent, regenerates the dashboard and runs the post-close hints. Containers have no test plan or merge step.

#### Scenario: Open children

- **Given** a story with two open tasks
- **When** the user runs `/tasks close --story STORY-008`
- **Then** it refuses, naming the two tasks and `--force`

### Requirement: Parents rolled up after child changes

The system SHALL, after any child status or placement change, re-evaluate the parent story and then its epic and update their files so no container asserts a state its children contradict; `triage` and `audit` SHALL flag a parent that does. Rollup hints never auto-close a container.

#### Scenario: Last task cancelled

- **Given** a story whose other tasks are `done`
- **When** its last open task is cancelled
- **Then** the story is reconciled to `done`

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

The system SHALL set a task, story or epic to `cancelled` (confirming first when it is `in-progress` or `done`), append a dated reason note, never delete the file, warn about dependents, point at the owning feature decision when the item is feature-linked without editing the ledger, close the remote issue as not planned in hybrid mode, roll up parents, and regenerate the dashboard. Cancelling a container SHALL list its open children and ask whether to cancel them, never cascading automatically.

#### Scenario: Feature-linked task cancelled

- **Given** `TASK-025` with `feature: FEATURE-002`
- **When** it is cancelled with a reason
- **Then** the status reads `cancelled`, a `> Cancelled <date> — <reason>` note is appended, and the user is told FEATURE-002's decision likely needs a change

### Requirement: Blocking and unblocking

The system SHALL add a `blocked:` reason field to a task without changing its status, refusing `done` or `cancelled` tasks and warning when already blocked; it SHALL confirm an in-progress block (blocking anyway with no answer and saying nobody confirmed), merge `--on` ids into `depends-on`, append a `> Blocked <date> — <reason>` note, mirror the block to a linked tracker as a label or flag plus a `Blocked:` comment without changing the issue's open state, and regenerate the dashboard. Unblock SHALL remove the field and leave status alone, append a `> Unblocked <date> — …` note, mirror the removal, and for an old-form blocked status recover the prior state from history or ask — falling back to `todo` with a note that nobody chose it, never leaving it blocked. Containers cannot be blocked.

#### Scenario: Block keeps state

- **Given** `TASK-012` at `todo`
- **When** the user runs `/tasks block TASK-012 --reason "waiting on API keys"`
- **Then** the file keeps `status: todo`, gains `blocked: waiting on API keys`, and the task leaves "Next up"

#### Scenario: Old-form unblock with nobody to ask

- **Given** a task reading `status: blocked` whose history does not show a prior state
- **When** it is unblocked unattended
- **Then** it becomes `status: todo` with no `blocked:` field and a note that the state was set to todo with nobody choosing it

### Requirement: Backlog audit

The system SHALL scan the backlog, read-only by default, for duplicates (wide acceptance and Context overlap, judged by meaning, reporting score and judgement), mergeable and splittable tasks, old-form statuses (counted and pointed at `init`), blocked-field contradictions, stale work, broken links (including a dependency on a finished task as an unblock candidate), dependency cycles, incomplete tasks and orphans, each with a severity and a suggested action; drift between tasks and features is left to the roadmap view. With `--fix` it SHALL apply only reversible fixes, one confirmation each — merge as cancel-with-note, removing a satisfied dependency, reparenting — then regenerate the dashboard. Under `--across` checks run within each project, and `--fix` and `--scope` are refused.

#### Scenario: Synonym duplicate

- **Given** two tasks titled "JWT issuance on login" and "Issue JWT at sign-in" with identical acceptance criteria
- **When** audit runs
- **Then** the pair is reported as a duplicate with its low title score and a by-meaning verdict, and nothing is changed without `--fix`

#### Scenario: Qualifier-distinct pair

- **Given** two tasks with matching acceptance criteria whose titles differ by client versus server
- **When** audit runs
- **Then** they are reported as mergeable-or-distinct and cancelling one is never proposed

#### Scenario: Cross-project dependency

- **Given** `--across` and a dangling `depends-on: TASK-004` in one project while a sibling has its own `TASK-004`
- **When** the broken-links check runs
- **Then** the dangling reference is still reported

### Requirement: Importing work

The system SHALL decompose a local notes file into a proposed epic, story and task tree for review, create the approved items with default fields, preserve done items as `done`, and never modify the source file. In hybrid mode it SHALL import a GitHub issue or Jira ticket into a local file, mapping title, body sections, priority, assignee, parent, open or closed state, and a blocked label or flag to a `blocked:` field whose reason comes from the newest `Blocked:` comment (else `reason unknown`), recording the issue link and refusing an issue already linked locally.

#### Scenario: Blocked GitHub issue

- **Given** an open issue labelled `blocked` with a comment `Blocked: awaiting legal`
- **When** it is imported
- **Then** the task reads `status: todo` with `blocked: awaiting legal` and the issue number recorded

### Requirement: Exporting a task

The system SHALL, in hybrid mode only, push one task, story or epic to the configured tracker: title from the first heading after the frontmatter (never a frontmatter comment), body from the task's sections plus a footer pointing back to the local file, labels for priority, assignee, epic, story and the configured defaults — creating any missing label first and naming it — plus a blocked marker and `Blocked:` comment for a blocked task; then write the returned id back to frontmatter. Re-exporting a linked item SHALL ask first, defaulting to abort, and a failed push SHALL leave frontmatter untouched.

#### Scenario: Missing label

- **Given** a GitHub repo with only default labels and a P3 task
- **When** the task is exported
- **Then** `priority/P3` is created first, the issue is created, and the confirmation names the created label

### Requirement: Migrating to hybrid mode

The system SHALL, from local mode only, inventory open epics, stories and every task not `done` or `cancelled` (awaiting-verification and blocked tasks included), show the plan and require confirmation, run pre-flight checks, push in order writing each remote id back as it goes, stop on the first failure, and only after success flip the configuration to `hybrid` with the chosen provider. A re-run SHALL skip already-linked items.

#### Scenario: Interrupted migration

- **Given** a migration that failed after pushing ten of twenty tasks
- **When** it is re-run with the same provider
- **Then** only the ten unlinked tasks are pushed

### Requirement: Initialising and reconciling the configuration

The system SHALL create the task folder, configuration and initial dashboard, or reconcile an existing configuration by adding every field the template declares and the file lacks (carrying the template's comment, in the template's position, never re-adding an existing comment block) while never changing existing values or unknown keys. Values passed by a caller (mode, repo, project, integration, workspace, worktree root) SHALL be written and never re-asked. `integration:` SHALL be asked when a user is present and otherwise left absent and reported unresolved, never defaulted; workspace questions are left to the front doors. A mode conflict SHALL keep the existing value when unanswered. The outcome SHALL be reported as created, already current or brought up to date, naming every field added and every field left unresolved.

#### Scenario: Older config missing integration

- **Given** an existing configuration with `mode: local` and no `integration:` line, run unattended without arguments
- **When** `/tasks init` runs
- **Then** the commented `integration:` block is added, `mode: local` is untouched, and the report names `integration:` as unresolved

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
