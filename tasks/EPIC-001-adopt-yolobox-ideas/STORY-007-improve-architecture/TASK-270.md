---
id: TASK-270
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `intake` cannot file an epic for a small architecture run, or a new epic for its re-run

## Context

Found by TASK-078's close-gate correctness and fidelity reviews (2026-10-06). `skills/improve-architecture/SKILL.md`
Step 7 files every run through `/tasks intake` as **a new epic, never `--epic`**, because each run's dropped list
is the whole standing set of rejections and Step 1 reads only the latest run's list. Two of intake's own rules
(`skills/tasks/verbs/intake.md`) stand in the way:

- **"One or two findings, none dropped" → no epic, use `/tasks spawn`.** A run with one or two candidates and no
  rejection then spawns tasks with no `kind: review-intake` parent and no `source:` naming the pass. Those
  tasks get an `IA-*` id only if intake still mints one, which this path does not, so they fall outside
  fix-next's pool and outside Step 1's `IA-*` lookup. The next run raises them again.
- **"Re-running a pass over the same scope" → `--epic` into the existing epic.** Step 7 deliberately does the
  opposite, and states that it does, but intake does not know a pass may need it.

TASK-078's own Out of scope routes any change to intake to its own task rather than a local workaround, so this
is that task.

## Acceptance criteria

- [x] `intake.md` lets a pass require an epic whatever its size (for example, any pass whose later runs read the epic back, which today is `IA-*`), and the small-pass shortcut names that exception
- [x] `intake.md`'s re-run edge case says a pass may file each run as a new epic when it carries its standing state forward, naming the `IA-*` pass as the case
- [x] `skills/improve-architecture/SKILL.md` Step 7 points at the new intake wording instead of stating the departure on its own
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Anything else in `intake` or in Step 7

## Human test plan

- [x] A scratch-clone run of `/improve-architecture` that finds one candidate and rejects nothing files it under a new `kind: review-intake` epic with an `IA-*` id, and a second run reports it as `already filed` — ⚠ NOT RUN AS WRITTEN: verified by a cold read of the procedures instead (below); a real two-run needs a task tree and a one-candidate fixture, left for the owner's call — accepted by the owner, 2026-10-06

## Implementation plan

Drafted inline at pick, 2026-10-06. Two exceptions in intake's own edge cases, each naming the `IA-*` pass and its reason:
- **the small-pass shortcut:** a pass whose later runs read its epic back always gets one;
- **the re-run advice:** a pass that carries its standing state forward files each run as a new epic, and its finding numbers restart.

Step 7 then points at them instead of stating the departure alone.

**Drill:** a cold reader gets `intake.md`, the pass's Step 1, and a one-candidate, no-rejection pass output. It answers what intake files, and what a second run reports for that candidate's key.

## Progress log

- 2026-10-06 — Picked; plan drafted inline. Intake's small-pass shortcut and re-run advice now each name the `IA-*` pass as the exception, with its reason, and Step 7 points at them. Lint OK.
- 2026-10-06 — **Cold read, not the scratch-clone run the test plan names.** `claude -p --disable-slash-commands`, run in `C:/Source/WebChecker` (no skills listed), was given `intake.md` and the pass's Steps 1 and 7, and two questions with no expected answer.
  - **Q1** (one candidate, nothing rejected, no earlier run): it filed a new `kind: review-intake` epic, its story (`reuse-dead-code` for class 2) and a task with `findings: [IA-1]` and the `Candidate key:` line. It quoted the new intake exception and Step 7 as deciding.
  - **Q2** (a week later): `already filed: TASK-NNN`, found through the `IA-*` id and the key line, not the epic.

  The step as written stays unticked; the task parks at `verify` for the owner to accept the cold read or ask for the full run.
- 2026-10-06 — **Signed off by the owner** at the `verify` park: the cold read of the procedures is accepted in place of the scratch-clone two-run. Closed `done`.
