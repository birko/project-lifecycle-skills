---
id: TASK-195
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-29
depends-on: []
blocks: [TASK-114, TASK-115, TASK-117]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Re-slice STORY-004 by the slicing doctrine before any of its tasks is picked

## Context

Found by TASK-122's first drill (2026-09-29). A cold runner was given STORY-004's `STORY.md` alone,
with the doctrine in `skills/tasks/slicing.md`. It rejected **"template/table first, then `new`, then `pick`"**
under *Vertical, not horizontal*: a format nobody writes or reads cannot be shown working on its own.

STORY-004's existing TASK-114 is exactly that cut: *"The question table — the shape every other task in
this story reads"*. The 2026-09-26 merge folded TASK-119 into it, so TASK-114 lands a format and an
upgrade for older files, and TASK-115 then makes `feature new` write the format. By the doctrine's H3
("a state nothing can act on"), TASK-114 alone leaves a shape no verb writes.

The runner's own cut was: `new` writes the table and `pick` resumes at the frontier, as one vertical path;
a claim marker; `research` as a type end to end; `grill-me` rounds; `grill-me` fact dispatch. Treat that
as input, not as the answer. It could not see the repo, and its record is on TASK-122.

## Acceptance criteria

- [ ] STORY-004's open tasks (TASK-114, TASK-115, TASK-117) are checked against `skills/tasks/slicing.md` — H1–H3, the size signals, and the edge rule for a shape one owner writes and another reads.
- [ ] Each task that fails is re-cut: its criteria are moved into the task that realises them, or a task is cancelled with a pointer to its successor. `depends-on`/`blocks` are written on both sides.
- [ ] Every rejected cut names the rule that rejected it, in this task's progress log.
- [ ] No acceptance criterion from the original tasks is lost. Each one lives in exactly one surviving task.

## Out of scope

- Implementing any STORY-004 task.
- Re-slicing other stories. Do STORY-007 when it is picked, since its link-ordering question is the worked pair in the doctrine.

## Human test plan

- [ ] N/A — this is backlog restructuring. `/tasks audit` over STORY-004 afterwards reports no `broken-links` or `cycles`, and no `splittable` without the one-line reason the doctrine requires.
