---
area: defect-draining
generated-at: eebeb6e79631d115bc4ae1831c6e92792b594311
generated-on: 2026-10-04
sources:
  - skills/fix-next/SKILL.md
shaped-by: [FEATURE-001, FEATURE-003]
shaped-by-derived: true
shaped-by-unresolved: 7
---

# Working a filed review backlog down, one defect per run, without supervision

## Purpose

Defect draining is the second half of a find → file → drain pipeline: once a review pass has been filed as tracked tasks, an agent takes the worst outstanding defect, confirms it is real, fixes its root cause, proves the regression test can fail, regenerates the affected spec and closes the task through the merge gate — with no one watching. Every piece of run state is written to the task file and to git as it happens, so the session can be reset at any point and the next run resumes exactly where the last one stopped. Anyone relying on an audit backlog getting worked down without holding context across sessions depends on it.

## Requirements

### Requirement: Resume an interrupted run before picking new work

The system SHALL, before selecting any new work, look for in-flight runs in two independent places — task files reading `in-progress` in the task tree, and, when the project declares worktree workspaces, the task file on each local task branch — and SHALL resume a run only when its task carries `picked-by: fix-next` and a progress log, counts a branch copy only when it reads `in-progress` and is not blocked, and otherwise leaves in-progress work alone without counting or reporting it.

#### Scenario: A run of this skill was interrupted

- **Given** TASK-901 reads `in-progress`, carries `picked-by: fix-next`, and its progress log ends at the step 5 line
- **When** the skill is invoked
- **Then** it reconciles the log against git, continues from the first genuinely incomplete step, and does not pick a second task

#### Scenario: A human's task is in progress

- **Given** TASK-902 reads `in-progress` with no `picked-by: fix-next`
- **When** the skill is invoked
- **Then** it ignores TASK-902 entirely — it neither resumes it, counts it, nor reports it as blocking — and builds the pool

#### Scenario: The in-progress copy exists only on a task branch

- **Given** the project declares worktree workspaces with an upstream, and the default branch's copy of TASK-903 reads `todo` while branch `task/TASK-903` holds a copy reading `in-progress` with `picked-by: fix-next`
- **When** the skill is invoked
- **Then** it treats TASK-903 as an in-flight run and resumes it from the branch copy rather than picking new work

#### Scenario: A branch copy parked at verify is not a run

- **Given** branch `task/TASK-904` holds a copy reading `verify`
- **When** the skill looks for in-flight runs
- **Then** that copy is not treated as an active run

### Requirement: Git outranks the progress log on resume

The system SHALL, when resuming, first enter the task's worktree under worktree workspaces (stopping this run if that entry stops), then compare the progress log with the working-tree status and recent history of every repository the log names, and where they disagree SHALL correct the log to match git and continue from the first genuinely incomplete step.

#### Scenario: The log claims a step that never landed

- **Given** the last log line says step 5 is done but git shows the fix uncommitted and the test file absent
- **When** the run resumes
- **Then** the log is corrected to match git and work continues from step 5

#### Scenario: Entering the worktree fails

- **Given** a skill-owned in-progress task under worktree workspaces whose worktree cannot be located and proved
- **When** the run tries to resume it
- **Then** the run reports the stop line and ends without picking any other task

### Requirement: A blocked run of this skill is not resumed

The system SHALL NOT resume a skill-owned in-progress task that has since been blocked; it SHALL report `not resumed: TASK-NNN (this skill's run) is blocked: <reason>`, leave that task's log and branch untouched, and go on to build the pool.

#### Scenario: Someone blocked the skill's own run

- **Given** TASK-905 carries `picked-by: fix-next`, reads `in-progress`, and has been blocked with reason "waiting on vendor"
- **When** the skill is invoked
- **Then** it reports `not resumed: TASK-905 (this skill's run) is blocked: waiting on vendor` and proceeds to build the pool without touching TASK-905

### Requirement: The pool is explicit, never inferred

The system SHALL admit a task to the pool only when it is `todo` (or an old-form blocked task) and either carries a non-empty `findings:` list or sits under an epic stamped `kind: review-intake`; it SHALL never infer a defect from an epic title or task prose, and SHALL drop any task whose task branch already exists locally or on a remote.

#### Scenario: A task carries a finding id outside any review epic

- **Given** TASK-910 is `todo` in the loose tree with `findings: [FIELD-007]`
- **When** the pool is built
- **Then** TASK-910 is in the pool

#### Scenario: A defect-looking task without a stamp or finding

- **Given** TASK-911 is `todo`, titled "Fix crash on save", under an epic with no `kind: review-intake` and with no `findings:`
- **When** the pool is built
- **Then** TASK-911 is not in the pool

#### Scenario: Another clone already took the task

- **Given** TASK-912 is `todo` under a review-intake epic and branch `task/TASK-912` exists on the remote
- **When** the pool is built
- **Then** TASK-912 is excluded as taken

### Requirement: Blocked tasks stay ranked but are never started

The system SHALL keep a blocked task in the pool — whether `todo` with a `blocked:` field or old-form `status: blocked` — so its rank stays visible, SHALL never start or unblock one, and SHALL treat a pool in which every task is blocked as empty, reporting the blocked tasks and stopping.

#### Scenario: Every pool task is blocked

- **Given** the pool holds TASK-920 and TASK-921, both blocked
- **When** the ranking is walked
- **Then** the run reports both blocked tasks with their reasons and stops without starting either

### Requirement: Unmet dependencies and decision tasks are excluded

The system SHALL exclude from the pool any task with an unmet `depends-on`, except a blocked task, which stays even when its block is one of those dependencies; and SHALL exclude any task whose acceptance is to decide something, surfacing such decision tasks in the closing report instead.

#### Scenario: A plain unmet dependency

- **Given** TASK-930 is `todo`, unblocked, and depends on TASK-929 which is not done
- **When** the pool is built
- **Then** TASK-930 is excluded

#### Scenario: Blocked on its own dependency

- **Given** TASK-931 carries `blocked:` and its blocking task TASK-929 also appears in its unmet `depends-on`
- **When** the pool is built
- **Then** TASK-931 stays in the pool as a blocked task

#### Scenario: A decide-X task

- **Given** TASK-932's acceptance is "decide whether retries are capped"
- **When** the pool is built
- **Then** TASK-932 is excluded and named in the closing report

### Requirement: Filed-but-unscheduled findings are reported, not worked

The system SHALL, while walking review-intake epics, flag every story that has unticked checklist lines but no open task, unless the story declares its findings are extracted on demand; it SHALL report those stories in the closing report with an offer to file them, and SHALL NOT work the unscheduled lines itself.

#### Scenario: A story with an unscheduled finding

- **Given** STORY-940 under a review-intake epic has one unticked line and no open task, and declares nothing about on-demand extraction
- **When** the pool is built
- **Then** the closing report names STORY-940 and offers to file its line as a task, and the line is not worked

#### Scenario: A story that extracts on demand

- **Given** STORY-941 has unticked lines, no open task, and states its findings are extracted on demand one task at a time
- **When** the pool is built
- **Then** STORY-941 is not reported

### Requirement: Verification debt surfaces before new scope

The system SHALL treat tasks at `verify` (or the older `review`) as outside the pool but as debt, and SHALL offer to clear them — by running their human test plans and closing them to `done` — before new work.

#### Scenario: A task awaits verification

- **Given** TASK-950 is at `verify` and the pool holds TASK-951
- **When** the run reaches pool building
- **Then** it offers to run TASK-950's human test plan and close it before taking TASK-951

### Requirement: An empty pool stops the run without inventing scope

The system SHALL, when the pool is empty, say so and stop without inventing defects; where review-looking epics exist that lack the `kind: review-intake` stamp it SHALL say exactly that and offer to adopt them with the intake verb rather than start working their tasks, and otherwise SHALL direct the user to run a review pass and file it first.

#### Scenario: No review was ever filed

- **Given** no task carries `findings:` and no epic is stamped review-intake
- **When** the pool is built
- **Then** the run reports "nothing to drain — run a review pass and `/tasks intake` first." and stops

#### Scenario: An unstamped remediation backlog

- **Given** EPIC-960 holds `todo` tasks whose bodies cite findings but carries no review-intake stamp
- **When** the pool is built
- **Then** the run names EPIC-960, offers `/tasks intake --adopt EPIC-960`, and starts none of its tasks

### Requirement: Rank by blast radius, with priority demoted

The system SHALL order the pool by these keys in sequence: severity of the failure mode (authentication or authorization bypass, then cross-tenant leakage, then silent data loss or corruption, then an unbounded destructive write, then wrong results, then an unhandled exception on a hot path); reachability (untrusted input, then corrupted stored data, then internal API misuse); silence (a plausible wrong answer over a thrown error); self-containment; verified over unverified; subject theme; `priority:`; and finally oldest `created` date.

#### Scenario: Severity beats priority

- **Given** TASK-970 is P2 with an authorization bypass and TASK-971 is P0 with an unhandled exception
- **When** the pool is ranked
- **Then** TASK-970 ranks above TASK-971

#### Scenario: Silence breaks a reachability tie

- **Given** TASK-972 and TASK-973 tie on severity and reachability, and TASK-972 returns a plausible wrong total while TASK-973 throws
- **When** the pool is ranked
- **Then** TASK-972 ranks above TASK-973

### Requirement: Theme is read from the parent story, never inferred

The system SHALL resolve a candidate's theme from the `theme:` field on its parent story, ordered by the intake verb's ladder, SHALL never infer a theme from a title, SHALL treat a loose task, a task parented directly to an epic, and a slug not on the ladder as undeclared (reporting an unrecognised slug), and SHALL sort every undeclared theme after every declared one.

#### Scenario: A misspelled slug

- **Given** TASK-980's parent story declares `theme: corectness`, which is not on the ladder
- **When** the pool is ranked on theme
- **Then** TASK-980 is treated as undeclared, sorts after every declared-theme candidate, and the slug is reported

#### Scenario: A loose task

- **Given** TASK-981 sits in the loose tree with no parent story
- **When** the pool is ranked on theme
- **Then** TASK-981 sorts after every candidate whose story declares a theme

### Requirement: The ranking names the key that broke the tie

The system SHALL state the ranking in one short paragraph naming the pick and why it beat the runner-up, SHALL say which key separated them, SHALL say when the theme key was inert (no candidate declares one, all declare the same one, or earlier keys already separated the pool), and SHALL say when every key was exhausted; it SHALL NOT ask which task to take, and SHALL stop and ask only when the top two are inseparable on every key.

#### Scenario: Theme could not discriminate

- **Given** every pool candidate's story declares the same theme and the top two separate on `priority:`
- **When** the ranking paragraph is written
- **Then** it names `priority:` as the deciding key and states that the theme key was inert because every candidate declares the same theme

#### Scenario: Keys exhausted

- **Given** TASK-990 and TASK-991 tie on every key including the same `created` date
- **When** the pool is ranked
- **Then** the run says the keys were exhausted and stops to ask which to take

### Requirement: Blocked tasks above the pick produce skip lines

The system SHALL walk down the ranking to the first unblocked task, writing `skipped: TASK-NNN — blocked: <reason>` for each blocked task passed (with `reason unknown` for an old-form blocked task carrying no note) into the ranking paragraph, and SHALL name as runner-up only a task that could have been started, writing `ranked above none — every other pool task is blocked` when there is none.

#### Scenario: The top task is blocked

- **Given** the ranking is TASK-1001 (old-form blocked, no note), TASK-1002 (unblocked), TASK-1003 (unblocked)
- **When** the pick is made
- **Then** the paragraph carries `skipped: TASK-1001 — blocked: reason unknown`, TASK-1002 is picked, and TASK-1003 is the runner-up

#### Scenario: Only blocked tasks remain besides the pick

- **Given** the ranking is TASK-1004 (unblocked) and TASK-1005 (blocked)
- **When** the pick is logged
- **Then** the log line says `ranked above none — every other pool task is blocked`

### Requirement: The pick is written to disk before any code is read

The system SHALL, immediately on choosing, add `picked-by: fix-next` to the task's frontmatter, append a progress log whose first line is `- step 2 — picked; ranked above <runner-up> because <reason>`, and move the task from `todo` to `in-progress`, cutting the task branch on a pull-request-per-task project; under worktree workspaces it SHALL always take the pick verb's blank-answer branch for the root question and SHALL write the two lines where they ride in the pick commit — the main copy with no upstream, the worktree with an upstream.

#### Scenario: Worktree pick with no upstream

- **Given** a project declaring worktree workspaces whose default branch tracks no remote
- **When** TASK-1010 is picked
- **Then** `picked-by` and the first log line are written in the main copy before the pick commit, and the pick commit carries them

#### Scenario: Worktree pick with an upstream

- **Given** a project declaring worktree workspaces whose default branch tracks a remote
- **When** TASK-1011 is picked
- **Then** the two lines are written in the worktree and ride in the pick commit on the task branch

### Requirement: Every step appends a progress line

The system SHALL append one line to the task's progress log after each step, in the step's stated form (verified, layer, fix and tests, revert split, respec, closed), so that a reset session can resume from the last recorded step.

#### Scenario: Step lines accumulate

- **Given** a run has completed steps 3 and 4 on TASK-1020
- **When** the session is reset
- **Then** the progress log ends with `- step 4 — layer: …` and the next run resumes at step 5

### Requirement: Re-verify the finding before fixing it

The system SHALL confirm the cited mechanism by reading the source rather than trusting the task's description; where the finding holds it SHALL log that and continue; where it is real but differently scoped it SHALL correct the task's context and acceptance criteria before writing code; where it is not a defect it SHALL record the evidence, cancel the task and return to pool building for the next candidate.

#### Scenario: The finding names the wrong trigger

- **Given** TASK-1030 says a crash occurs on empty input, but reading the source shows it occurs on a negative count
- **When** step 3 runs
- **Then** the task's context and acceptance criteria are rewritten to the real trigger before any fix, and the log reads `- step 3 — verified: rescoped: …`

#### Scenario: A false positive

- **Given** TASK-1031's described mechanism cannot occur
- **When** step 3 runs
- **Then** the context is rewritten with the evidence, the task is cancelled, the log reads `- step 3 — verified: rejected: …`, and the run returns to pool building

### Requirement: Related findings are folded in or filed, never silently widened

The system SHALL pull into the fix any defect in the same function that shares the root cause, and SHALL file any other discovered work as a separate task via the spawn verb rather than widening the task in hand.

#### Scenario: A sibling defect in another module

- **Given** fixing TASK-1040 reveals an unrelated defect in a different module
- **When** the run continues
- **Then** the second defect is filed as its own task and TASK-1040's scope is unchanged

### Requirement: Fix at the layer where the root cause lives

The system SHALL decide before writing code whether the root cause is in this repository or upstream; where it is upstream it SHALL record the root cause, the proposed upstream change and what it unblocks, flag it to the user and mark the local task blocked rather than patch locally; where the root cause is this repository's use of a dependency it SHALL fix locally.

#### Scenario: Defect in a shared library

- **Given** TASK-1050's symptom is caused by a bug in a consumed library
- **When** step 4 runs
- **Then** no local override is written, the task records the upstream change, the user is told, the task is marked blocked, and the log reads `- step 4 — layer: upstream: <where>`

#### Scenario: Misconfigured dependency

- **Given** TASK-1051's defect is a missing registration of a library's service in this repository
- **When** step 4 runs
- **Then** the fix is made locally and the log reads `- step 4 — layer: local`

### Requirement: Fix the root cause with a regression test, never by weakening a check

The system SHALL fix the general root cause rather than guard the reported input, SHALL never remove an authorization check, widen an isolation boundary or loosen an assertion to make something pass, SHALL read the project's own conventions and testing guidance for the stack, and SHALL cover every acceptance row with tests that name the finding id and state the mechanism.

#### Scenario: Guarding only the reported input

- **Given** TASK-1060 reports a failure for the input "0"
- **When** step 5 runs
- **Then** the fix addresses the general cause rather than special-casing "0", and the test documentation names the finding id and mechanism

### Requirement: Prove the regression test can fail

The system SHALL NOT skip proving the guard can fail; it SHALL run one of the populate-tests checks (revert-and-split, reintroduce-and-confirm, or a bidirectional assertion) and record the split as numbers, the fix-dependent tests by name, and every still-passing test as a contract pin rather than evidence.

#### Scenario: Reverting the fix

- **Given** the suite for TASK-1070 has 6 tests, all green with the fix
- **When** the fix is reverted and the suite re-run, and 2 tests fail
- **Then** the log reads `- step 6 — reverted fix: 2/6 failed; fix-dependent = <the 2 names>; contract pins = <the 4 names>`

### Requirement: Respec the fixed area

The system SHALL find the spec area whose map globs cover the changed files and regenerate it under the stable-wording rule, review the diff, and file anything unintended as a new task; where the project has no usable spec map it SHALL print "no usable spec map — run `/specs init` to bootstrap the spec layer" and continue.

#### Scenario: No spec map

- **Given** a project with no spec map file
- **When** step 7 runs
- **Then** the run prints the no-usable-spec-map line and continues to closing

#### Scenario: Unintended spec change

- **Given** the regen diff for area billing-rules changes a requirement the fix did not touch
- **When** the diff is reviewed
- **Then** that change is filed as a new task

### Requirement: Close through the merge gate unattended

The system SHALL, before handing over, write an outcome section into the task file stating what the fix was, the step-6 split with names, the judgement calls and why the stricter option was rejected, and anything flagged but not fixed; and SHALL then close the task with `/tasks close --unattended`, never re-implementing the review passes, merge decision, commit or rollups that close owns, and never skipping the gate because a review skill's name did not resolve.

#### Scenario: Closing a pull-request-per-task project

- **Given** TASK-1080's fix is complete on a pull-request-per-task project
- **When** step 8 runs
- **Then** the outcome section is written first, close runs with the unattended flag, and the merge decision is resolved as merge without a question

### Requirement: One defect per bare run; loop continues until a stopping point

The system SHALL stop after one defect on a bare invocation; with `--loop` it SHALL return to pool building unless context is nearly exhausted, the pool is empty, or a scope-escalation question is pending; with `--epic` it SHALL restrict the pool to that epic; and in every mode it SHALL name the next pick.

#### Scenario: Bare invocation

- **Given** TASK-1090 has just closed and TASK-1091 is next in rank
- **When** the run reaches step 9 without `--loop`
- **Then** it stops and names TASK-1091 as the next pick

#### Scenario: Loop halts on a pending escalation

- **Given** `--loop` and a scope-escalation question is awaiting an answer
- **When** step 9 is reached
- **Then** the run stops, waits for the answer, and names the next pick

### Requirement: The final report and a verified-safe reset

The system SHALL end with a short report giving what was broken in one context-free sentence, the step-6 split as numbers, everything flagged and not fixed — including every blocked pool task with its reason and every task id the close step spawned from its out-of-scope sweep, by id and subject — and the next pick; and before reporting SHALL confirm that every touched repository's working tree is clean, that the task file alone tells the whole story, and that nothing learned lives only in the conversation, fixing any failure first.

#### Scenario: Close spawned follow-ups

- **Given** close's out-of-scope sweep spawned TASK-1100 while closing TASK-1099, and TASK-1101 in the pool is blocked
- **When** the final report is written
- **Then** it lists TASK-1100 with its subject and TASK-1101 with its block reason

#### Scenario: Uncommitted work remains

- **Given** a touched repository still shows a modified file after closing
- **When** the reset-safety check runs
- **Then** the run resolves it before finishing rather than reporting done
