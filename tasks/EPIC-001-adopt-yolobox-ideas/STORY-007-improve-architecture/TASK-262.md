---
id: TASK-262
parent: STORY-007
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-06
depends-on: []
blocks: [TASK-078]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `intake` states the shape of a "Findings dropped at intake" entry, because another skill now reads it

## Context

Found while planning **TASK-076**. The `improve-architecture` skill reads an earlier run's
`### Findings dropped at intake` list (written by `skills/tasks/verbs/intake.md` step 3) so that a candidate the
deletion test rejected is not raised again on the next run.

`intake.md` says what goes in that list ("drop it, with the reason recorded") but never what an entry looks like.
Today's entries in this repo's EPIC-007 are a four-column table (finding, claim, why dropped). That shape works for a
review pass, but it carries nothing a later run can re-check against: no path, no callers, no commit.

AGENTS.md § *Code structure & patterns*: **"A format one skill reads is a contract the writing skill must state
too."** If only the reader records the shape, the writer can change it without ever seeing the consequence, and the
reader then degrades silently.

The owner decided on 2026-10-06 to file this as its own task rather than fold it into TASK-078. TASK-078's own Out
of scope already routes any change to `intake` to a separate task.

## Acceptance criteria

- [ ] `intake.md` step 3 states the shape of a dropped entry: what was dropped, why, and, where the finding names code, the path, the callers checked and the commit it was judged at
- [ ] The existing table shape stays valid for passes whose findings name no code (review findings like EPIC-007's), so no filed epic becomes malformed
- [ ] `intake.md` names the reader: a later pass reads this list so it does not re-raise what was dropped
- [ ] The prefix table gains a row for the architecture pass, so its findings get ids of their own rather than a borrowed prefix (added 2026-10-06 from TASK-076's correctness review)
- [ ] `{{SOURCE}}` is stated to name the pass that produced the epic, whatever else it carries (a report path, a PR, a date), because a later run finds its earlier runs by that name (TASK-076's conventions review, W2)
- [ ] A pass whose findings include rejections is filed into an epic even when it has only one or two candidates, so the rejections have a home. Today the one-or-two-findings edge case files no epic at all (TASK-076's correctness review)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- How `improve-architecture` reads the list (TASK-076) and how its handoff writes it (TASK-078)

## Human test plan

N/A: a wording change to one verb file. The reader side is drilled by TASK-076 and TASK-078, which consume this shape, so a human adds nothing here beyond reading the diff at the close gate.

## Implementation plan

_Populated by `/tasks plan TASK-262` — leave empty until then._
