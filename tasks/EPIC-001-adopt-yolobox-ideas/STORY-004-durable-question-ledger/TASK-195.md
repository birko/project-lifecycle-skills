---
id: TASK-195
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] STORY-004's open tasks (TASK-114, TASK-115, TASK-117) are checked against `skills/tasks/slicing.md` — H1–H3, the size signals, and the edge rule for a shape one owner writes and another reads.
- [x] Each task that fails is re-cut: its criteria are moved into the task that realises them, or a task is cancelled with a pointer to its successor. `depends-on`/`blocks` are written on both sides.
- [x] Every rejected cut names the rule that rejected it, in this task's progress log.
- [x] No acceptance criterion from the original tasks is lost. Each one lives in exactly one surviving task.

## Out of scope

- Implementing any STORY-004 task.
- Re-slicing other stories. Do STORY-007 when it is picked, since its link-ordering question is the worked pair in the doctrine.

## Human test plan

- [x] N/A — this is backlog restructuring. `/tasks audit` over STORY-004 afterwards reports no `broken-links` or `cycles`, and no `splittable` without the one-line reason the doctrine requires.

## Progress log

- 2026-10-04 — Picked to unblock TASK-114 (P1). Each open task was checked against `skills/tasks/slicing.md`.
  - **Rejected: TASK-114 as cut** (the table, its states, query, fog rule and claim, plus the reconcile merged from TASK-119). **H3**: it lands a shape that no verb writes and none reads until TASK-115. The reconcile half writes rows that nothing acts on either. A drill runner rejected the same cut under *Vertical, not horizontal* (TASK-122).
  - **Rejected: TASK-115 as cut** (`new` writes, plus `pick` resumes, merged from TASK-116). It depends on TASK-114's shape, so on its own it is the second half of the horizontal cut above. Every criterion is sound, so it became the vertical slice instead of being cut.
  - **Rejected: keeping `claimed-by` inside the vertical slice.** It trips the size signal, and **spawn's scope test turned around**: a reviewer could approve resuming at the frontier and reject the claim policy. The resume path is verifiable without it (**H2** holds), and it extends the shape, so it is an edge. Hence its own task.
  - **Considered and kept: TASK-117 with TASK-118's `research` type merged in.** The size signal trips, but splitting fails the doctrine's purpose: rounds without the dispatch rule stall on the first lookup. The one-line reason is now in its Context.
  - **Result:**
    - **TASK-115** (now **P1**) is slice A: the five-column table, states, frontier query and fog rule (from TASK-114), plus telling a pre-table file from a current one (from TASK-119), plus `new` writing and `pick` resuming. It `blocks` TASK-114, TASK-117 and TASK-257.
    - **TASK-114** (now P2) is the reconcile of pre-table files (TASK-119's other criteria) and `depends-on` TASK-115.
    - **TASK-257** (new) is `claimed-by` and `depends-on` TASK-115.
    - **TASK-117**'s edge is now TASK-115 only.
  - **Every original criterion is accounted for:**
    - TASK-114's 6 and TASK-119's 5: the six-column criterion is split, five columns to TASK-115 and `claimed-by` to TASK-257. The claim rules went to TASK-257. TASK-119's first criterion went to TASK-115 and its other four to TASK-114.
    - TASK-115's 5: all to TASK-115. Its "nothing restates TASK-114's states or query" merged into the shape's own "nothing else in `skills/` restates the states or the query", since the owner is now the same task.
    - TASK-116's 5: claiming on resume went to TASK-257, and the other four to TASK-115.
  - **Audit check (the human test plan):** over STORY-004's open tasks, every `depends-on` and `blocks` resolves and is recorded on both sides, there is no cycle, and the two tasks with ≥6 criteria each carry their one-line reason. → **done**.
