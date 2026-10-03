---
id: TASK-214
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [VI-003]
pr: null
github-issue: null
jira-key: null
---

# `/tasks close` finishes a blocked task, against FEATURE-003 D7

## Context

Found by `/feature review FEATURE-003` (2026-10-03), Gate A's feature-level fidelity pass. D7 says a blocked
task cannot be started **or finished** while it carries the flag. The start half is built: `pick` asks
"Unblock and start?", and `fix-next` refuses to resume a blocked run. The finish half is not.
`skills/tasks/verbs/close.md` step 4 checks for `done` and `cancelled` only, so `/tasks close` on a task
carrying `blocked:` goes on to write `status: done` with the field still present — the contradiction `audit`
reports (`skills/tasks/SKILL.md` § *Reading a task's status*). No task's criteria covered this half;
TASK-204's D7 criterion named only `pick`.

`close`'s own deferred-merge path *writes* `blocked: merge deferred: …` and re-closes after `/tasks unblock`.
That re-close starts from an unblocked task, so a refusal does not break it.

## Acceptance criteria

- [x] `close` step 4 refuses a task blocked in either form, with its exact question (unblock and close, or
      stop) and an answer-less path — `--unattended` included — that refuses and reports, never closes
- [x] The `--unattended` contract table gains the row for it
- [x] The deferred-merge re-close path still works, shown by walking it in the progress log
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The wording sweep — TASK-213

## Human test plan

- [x] A cold run of `/tasks close` on an invented blocked task with nobody to answer: it refuses, says why,
      and writes nothing

## Implementation plan

_Drafted at pick, 2026-10-03; one file, grill skipped._

1. `close.md` step 4: after the unmerged-close exception (which concerns a branch copy reading `done`, never a
   blocked one) and before the `done`/`cancelled` checks, add the blocked refusal — either form, per
   [[tasks]] § *Reading a task's status*. Question, in `pick`'s shape:
   **"TASK-NNN is blocked: "<reason>". Unblock it and close?"** · **Yes** — run `unblock`, then continue
   this close · **No** — leave it blocked; nothing is written. No answer, or `--unattended`: refuse, print
   `not closed: TASK-NNN is blocked: <reason>`, write nothing.
2. `--unattended` table: a row for it.
3. Deferred-merge re-close: the path is `/tasks unblock` then `close` (close.md § Edge cases, and the worktree
   "kept" line), so the task arrives unblocked — walk it in the progress log.
4. Lint; drill: two cold runners, an invented task tree, `/tasks close` on a blocked task with nobody to answer.

## Progress log

- 2026-10-03 — Picked (in place; single-branch). Plan drafted at pick. `close.md` step 4 gains the blocked refusal (either form; question, Yes runs `unblock` then continues, No / no answer / `--unattended` refuses and writes nothing), placed after the unmerged-close exception and before the done/cancelled checks; the `--unattended` table gains its row. Deferred-merge re-close walked: close step 6 writes `blocked: merge deferred`; § Edge cases and the worktree "kept" line resume with `/tasks unblock` first, then `close` re-enters at step 8 — the task arrives unblocked, so step 4 never refuses it. Lint OK.
- 2026-10-03 — Drill: invented tree `%TEMP%\d214base` (TASK-001 new-form blocked, TASK-002 old-form), oracle written first; two cold runners, `d214a` / `d214b`.
- 2026-10-03 — Drill: **both runners match the oracle and agree** (cold: no skills listed, no prior exposure): each refused TASK-001 and TASK-002 at step 4, put the question verbatim, printed `not closed: … is blocked: <reason>` (`prior state unknown` for the old form), and changed nothing (`git status` clean, no commit). Both flagged `close` step 1 "Find task root" as giving no method — older text, added to TASK-212 (DRILL-214-1) before it started. Raised by one: how to put the question (AskUserQuestion is named only at 5c); a missing task branch at the unmerged-close check. Close review, inline (one step and one table row): **standards** — removed a "(FEATURE-003 D7)" reference I had added, which points at this repo's records from shipped prose (the TASK-212 defect); ask-step carries its words and its no-answer path; **intent** — 4/4 criteria met; **correctness** — placed after the unmerged-close exception (which concerns a `done` branch copy, never a blocked one), so it cannot shadow it; **security / comments** — not applicable. Out-of-scope sweep: 1 boundary (TASK-213). Closed `done`.
