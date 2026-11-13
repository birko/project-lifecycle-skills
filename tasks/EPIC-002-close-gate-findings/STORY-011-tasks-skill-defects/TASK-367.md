---
id: TASK-367
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-366-1, DRILL-366-2]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `block`'s uncommitted line and the generated files' project name leave their form to the reader

## Context

Filed 2026-11-13 at TASK-366's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d366`, `report.md`, § 3)
against d358 and d360. Both readings meet FEATURE-002 D10's two-runner bar.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-366-1 | `block`'s confirmation ends `uncommitted: <files>` (added by TASK-348). Whether paths are relative to the repo or to `tasks/`, and how they are separated, is unstated. Both runners chose repo-relative and comma-separated | d358, d366 |
| DRILL-366-2 | `{{PROJECT_NAME}}` is "the name of the directory containing `tasks/`" (`triage`), or containing `docs/` (`/feature status`). On a repo whose README or guide names the project differently ("Fixture CLI", "Ledger"), runners asked whether the folder name is really meant. Both generators already state the folder name, so the gap is the *why*, which is missing | d358, d360, d366 |

## Acceptance criteria

- [x] `block` and `unblock` state the `uncommitted:` line's path form and separator
- [x] `triage` and `/feature status` say why `{{PROJECT_NAME}}` is the folder name and not a title read from a file
      (`/feature status` already argues it: "a path any run derives the same way"), so a reader with a differently
      titled README does not re-decide it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Column padding and the timestamp: TASK-366 (done)

## Human test plan

- [x] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      neither DRILL-366-1 nor 2 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d367`: a fresh copy of `d212/repo`, `skills/` at this fix, and
    TASK-212's brief, run with TASK-212's runner command plus `Write` and `Edit`.
    - **Coldness:** no skills listed and no Skill tool.
    - **What it printed:** `uncommitted: tasks/EPIC-001-cli/STORY-001-export/TASK-002.md, tasks/README.md`, and it
      titled the dashboard `# Tasks — repo`.
    - **Neither reading is in its undecided list.**
    - **It also exposed a defect in this task's own example**, fixed at the close. The runner said the
      `uncommitted:` example "even matched this repo's path". The draft had lifted the `d212` fixture's real path into
      the skill, which hands the expected answer to every cold drill on that fixture. That is the failure TASK-210
      exists to rule out. It now reads `tasks/EPIC-004-billing/STORY-009-invoices/TASK-031.md`, and no other fixture
      path appears in `skills/`.
    - **Cross-drill:** the order of tasks in the tree (d358 too) is filed as TASK-368.
    - **Recorded here, one runner each:**
      - how an overflowing cell closes;
      - whether `block`'s confirmation prints the note (`unblock`'s does);
      - the timestamp being write time, not block time;
      - filling epic and story `cancelled` cells;
      - what "Find task root" involves.

## Implementation plan

_Populated by `/tasks plan TASK-367` — leave empty until then._

## Outcome

**The fix.**
- **`block` and `unblock`'s `uncommitted:` line** lists repo-relative paths separated by `, `, with an invented
  example.
- **`triage`'s `{{PROJECT_NAME}}`** says why it is the folder name even where a README titles the project
  differently: every run derives the folder name the same way, while a title read from a file can be missing or
  change.

**Step-6 split.**
- **Text assertions:** 2 of 2 fail on `HEAD`'s copies and pass on the fix, both fix-dependent. The script is
  `task367-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** the d358 and d366 runners both raised these.
  - **After:** d367 did not.
- **Contract pin, not evidence:** skills-lint.

**Judgement calls.**
- **The example path was invented after the drill caught a lifted one.** A skill's example that matches a drill
  fixture puts the answer back into a cold drill (TASK-210, still open, would make this a written rule).
- **The tree-order reading is filed as TASK-368 and not folded in.** It is outside this task's criteria, and the
  session agreed to stop chaining one-reading tasks onto each other.

**Close gate (inline, about 6 lines over two files):**
- **Standards:** both rules sit in their owning verbs.
- **Intent:** criteria met.
- **Correctness:** the fixture-derived example was replaced.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-368**, filed.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked by the user's go-ahead after TASK-366 named it next; correctness-invariants, two two-runner readings, no open question
- step 3 — verified: held; `block`'s `uncommitted: <files>` has no stated form, and triage's `{{PROJECT_NAME}}` gives no reason
- step 3b — not planned: two short answers
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/block.md (the uncommitted line's form, with an example) and skills/tasks/verbs/triage.md (`{{PROJECT_NAME}}` is the folder name, and why)
- step 6 — reverted fix (HEAD copies): 2/2 assertions failed; fix-dependent = Q1, Q2; contract pins = skills-lint
- step 7 — respecced work-tracking (blocking), surgical, restamped. The project-name rule was already in the spec's feature side; its reason is prose, not a requirement
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
