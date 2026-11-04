---
id: TASK-318
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
picked-by: fix-next
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-014]
pr: null
github-issue: null
jira-key: null
---

# `/tasks plan` asks whether to grill the plan and never says what happens when nobody answers

## Context

Found by TASK-313's cold drill (2026-10-14). `skills/tasks/verbs/plan.md` step 7 says only: *Print: "Draft plan written. Grill it via `grill-me`? [y/N]"*. It states no answer-less path, which AGENTS.md § Output/prose rules requires of every ask-step. The runner, with nobody present, took the capitalised `N` as a default and said it had inferred it. `new` chains `plan` on every task it files, so every unattended `/tasks new task` reaches this question.

## Acceptance criteria

> Rescoped 2026-11-04 by /fix-next step 3, before any edit: the same file carries two more ask-steps with the same defect — step 5b's spawn offer (no question text, no answer-less path) and the edge case's `--replan` confirm on an in-progress task (no answer-less path). Same root cause, same verb, so they are in scope; the first criterion is the original.

- [x] `plan.md` step 7 states its answer-less path, and what the run reports when nobody answers
- [x] Step 5b's split offer states the question it puts and its answer-less path
- [x] The `--replan`-on-in-progress confirm states its answer-less path
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The grill itself ([[grill-me]])

## Human test plan

- [x] A cold runner files a task with nobody to answer. Expected: it quotes the grill question, takes the stated answer-less path, and reports it without calling it inferred.
  - **Passed 2026-11-04:** the runner put plan step 7's question verbatim ("Draft plan written to TASK-002. Grill it via `grill-me` now? [y/N]"), quoted the step's no-answer rule, and printed `grilling: not run — nobody answered`; the task's inferred-values line lists title, parent, priority, assignee and body sections, not the grill.

## Outcome

**What was fixed.** `/tasks plan` had three questions that said nothing about what happens when nobody answers. `/tasks new` chains `plan` on every task it files, so every unattended task creation reached at least the grill question, and a runner left with a bare `[y/N]` had to treat the capital `N` as an answer nobody gave. Each of the three now states the exact question and its outcome when no answer comes:

- **Step 7, the grill offer:** no grilling runs, the draft is kept, and step 8 reports `grilling: not run — nobody answered`, never `declined`.
- **Step 5b, the split offer:** this step had no question text either and now carries one. With no answer nothing is spawned; the step stays in the plan marked `⚠ split signal — not spawned: nobody answered` and is listed in step 8.
- **`--replan` on an in-progress task:** the existing plan is kept, nothing is written, and the run reports `plan kept — … nobody confirmed overwriting its plan`.

**Step-6 split: 0/0.** The change is prose only. `skills-lint.sh` passes (20 skills): a contract pin on link resolution, not evidence. The cold-runner drill in the Human test plan is the evidence and has not been run.

**Judgement calls.**
- **Grill: `not run`, not `declined`.** Reporting a skipped grill as declined would turn the runner's fallback into a decision nobody made, the exact defect AGENTS.md § Output/prose rules names. It is also not marked as an inferred field: nothing is written to the task, so the inferred-values line has no field to name.
- **5b: spawn nothing.** The stricter-looking option was to spawn, as `close` 5d does unattended. I rejected it because 5d spawns to stop a bullet from evaporating, while here the step stays in the plan with a visible marker, so nothing evaporates, and a spawned task would be a placement nobody chose.
- **Replan: keep the plan.** `--replan` asks for a new plan, but the in-progress confirm exists precisely because that flag is not consent to replace a plan work is running against.

**Respec.** `work-tracking`, requirement *Implementation plans*: it now states all three answer-less outcomes, plus one scenario for the grill offer with nobody present. The `shaped-by` fields were carried forward, not re-derived.

**Flagged, not fixed.** None.

## Implementation plan

_Not drafted: a /fix-next run, whose fix is recorded in § Outcome._

## Progress log

- step 2 — picked; ranked above TASK-182 because it is reached by every unattended `/tasks new` (new chains plan), the widest reachability of the remaining ask-step gaps (key 2), and an unanswered [y/N] read as a decision is a silent wrong result (key 3); TASK-323 still loses on key 4; key 6 inert — TASK-318 sits under its EPIC with no theme
- step 3 — verified: rescoped: step 7 holds as written (`[y/N]`, no answer-less path); also step 5b's spawn offer and the in-progress `--replan` confirm, same defect in the same file — criteria extended before any edit
- step 4 — layer: local (skills/tasks/verbs/plan.md)
- step 5 — fix in skills/tasks/verbs/plan.md (steps 5b, 7, 8 and the --replan edge case); tests: skills-lint.sh (20 skills) green
- step 6 — reverted fix: 0/0 failed — prose only, nothing executable; fix-dependent = none; contract pins = skills-lint.sh link resolution; evidence = the Human test plan cold drill, not run
- step 7 — respecced work-tracking; requirements changed: Implementation plans (+1 scenario); intended anyway — TASK-318's criteria, answered by /fix-next; shaped-by carried forward, not re-derived
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
- 2026-11-04 — **Human test plan — cold drill, passed.** Fixture: `repo/` with `tasks/.config.yml` (`mode: local`, `integration: single-branch`), EPIC-001 → STORY-001 and one done task; skill `tasks`. Runner: `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`, cwd `%LOCALAPPDATA%\Temp\d318`, which holds the committed fixture `repo/` and copies of the named skill folders under `skill/`. The brief told the runner it was a drill, barred history and planning docs, told it to write any question verbatim and continue unanswered, and asked for: the output, the questions, what was left undecided, what was settled, what was inferred, what it read unsent, and its skill list. It never stated an expected outcome. Task-specific ask: "Run /tasks new task. The task you are filing: \"Rename the export command's --out flag to --output\", under STORY-001. Nothing else is supplied. Give the file it wrote, whole." **Coldness:** it listed no skills. **Result:** the runner put plan step 7's question verbatim ("Draft plan written to TASK-002. Grill it via `grill-me` now? [y/N]"), quoted the step's no-answer rule, and printed `grilling: not run — nobody answered`; the task's inferred-values line lists title, parent, priority, assignee and body sections, not the grill. Also raised, outside this task and offered as follow-ups: **DRILL-318-1:** a parent and title the user named in the request (not as an argument) were treated as unanswered, so the file says "inferred, not chosen" about a parent the user gave — `new` steps 3–4 carve out only a caller-set value; **DRILL-318-2:** `plan` step 6 inserts the plan agent's output whole; its `##` headings end `## Implementation plan` early, and the runner demoted them unlicensed; **DRILL-318-3:** `new` step 13 and `plan` step 8 each print a "Start work with `/tasks pick`" line, in no stated order. → `verify` → **done**.
