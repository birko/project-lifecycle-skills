---
id: TASK-257
parent: STORY-004
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-04
depends-on: [TASK-115]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Two sessions never answer the same open question — `claimed-by`

## Context

**Cut out 2026-10-04 by TASK-195** under `skills/tasks/slicing.md`, from criteria that used to sit on
TASK-114 (the column and its claim rules) and TASK-115 / TASK-116 (claiming on resume). Separated because
a reviewer could approve resuming at the frontier and reject the claim policy (spawn's scope test,
turned around), and because the resume path is verifiable without it. **Edge:** this task *extends* the
shape TASK-115 defines (a sixth column), so TASK-115 `blocks` it.

The story's sixth column: `claimed-by` stops two parallel sessions answering the same question. It is the
same problem the pushed task branch solves for tasks in FEATURE-001 (D25): *taken* must be visible to
another session, and a claim must be able to end.

## Acceptance criteria

- [ ] The question table in `skills/feature/templates/idea.md` gains its sixth column, `claimed-by`. (This is the
      part of TASK-114's six-column criterion split off at the re-cut; the other five columns are TASK-115's.)
- [ ] `claimed-by` states what claims it, when a claim is released, and what a reader does with a stale
      claim — a claim that cannot expire is a deadlock *(from TASK-114)*
- [ ] Resuming marks the question `claimed-by` per the shape, and releases the claim when the session
      ends or the question resolves *(from TASK-116)*
- [ ] Nothing restates TASK-115's states or frontier query
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The table's other five columns, `/feature new` writing it and `/feature pick` resuming — TASK-115.
- Reconciling older `idea.md` files — TASK-114.

## Human test plan

- [ ] Resume the same feature in two sessions at once. Expected: the second sees the first's claim on the
      question it is working and offers a different one. Then abandon the first session without resolving
      its question, and confirm a later session can tell the claim is stale and proceed as the rules say.

## Implementation plan

_Populated by `/tasks plan TASK-257` — leave empty until then._
