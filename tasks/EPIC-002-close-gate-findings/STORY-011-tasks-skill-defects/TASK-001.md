---
id: TASK-001
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# STORY.md cannot express dependency edges

## Context

Discovered while seeding EPIC-001 (STORY-001). `templates/TASK.md` carries `depends-on: []` and
`blocks: []` in its frontmatter, but `templates/STORY.md` carries neither — its frontmatter is
`id / parent / status / created` only. `templates/EPIC.md` has no edge fields either.

So a story that genuinely gates another story has nowhere to record it. In EPIC-001 the whole
eight-story sequence had to be written as a prose table in the EPIC body, which no verb reads:
`/tasks pick` cannot tell that STORY-004 is blocked by STORY-003, `/tasks triage` renders no edge
in the tree, and `/roadmap` cannot audit an ordering it cannot see. The dependency information
exists but is invisible to every consumer of it.

Filed rather than fixed inline because this is a defect in the `tasks` skill itself, not part of
EPIC-001's scope — hence `_loose`, not a story under that epic.

**A reader that must change with this task:** `skills/tasks/slicing.md` § *Where the edges live*
(TASK-122) states that `STORY.md` has no edge fields and puts a wide refactor's order on task
frontmatter. When STORY.md gains edges, update that section in the same change.

## Decision (2026-11-15, the user)

Accepted as the smaller version, on the condition that it covers every criterion; each is answered below.
- **A task's `depends-on:` may name a story**: the task waits until that story is `done` or `cancelled`. This is how
  one story waits on another. The rule is in `skills/tasks/slicing.md` § *Where the edges live*, and every reader of
  the field points there.
- **Stories and epics get no edge fields.** Order matters only where there is work to pick, and that is always a
  task: a story with no tasks has nothing to start out of turn. In three months and some 380 tasks since this was
  filed, no story needed an edge of its own; the task-edge rule in `slicing.md` carried every sequence.
- **Rejected:** the full build (the fields on `STORY.md` and `EPIC.md`, plus six verbs and the lint), since it is a
  second edge vocabulary for a case the task edges already reach; and *won't fix*, since a task under one story
  could not otherwise wait on another story at all.

## Acceptance criteria

- [x] `templates/STORY.md` carries `depends-on: []` and `blocks: []`, matching `TASK.md`'s shape and field names exactly — no new vocabulary for the same concept — **answered by the decision, not built as written:** the edge stays in the existing field, `depends-on:`, on the waiting story's tasks; `TASK.md`'s comment names that a story id is allowed. No new vocabulary
- [x] Decide and document whether `EPIC.md` needs them too (epics may legitimately gate each other), or record why it deliberately does not — decided: no edge fields, and an epic id in `depends-on:` is a broken link (`slicing.md`, `audit.md`)
- [x] `verbs/block.md` works at story level, not tasks only — `--on` takes story ids; a story itself is still not blockable (containers never carry `blocked:`), and `block.md` says so and names `--on` as the way
- [x] `verbs/triage.md` renders story edges in the tree view — **answered by the decision:** the dashboard renders no edges at all, task or story, so adding story edges alone would be a second rule; out-of-order work is reported by `/tasks audit` instead (below)
- [x] `verbs/new.md` sets the fields when a story is created with a stated blocker — a task created with a stated wait writes `depends-on:` (and `blocks:` on a task named); a story records it as a line under its heading and the confirmation says its first task carries the edge
- [x] `roadmap`'s cross-tree pass reads story edges, so an out-of-order story is auditable drift — **met in `/tasks audit`, not `/roadmap`:** a new `out-of-order` check reports a task started or finished while a task or story it depends on is open. `roadmap`'s divergence engine compares features with tasks, and an edge inside the task tree is the task audit's job
- [x] EPIC-001's prose sequence table is replaced by real frontmatter edges on its eight stories, and the table either goes or is explicitly kept as human-readable narrative — kept, explicitly as narrative, with the reason in place of the old line
- [x] `skills-lint` or a verb rejects an edge pointing at a non-existent id — `/tasks audit` `broken-links` (an unknown story id, an epic id); `block --on` validates its ids

## Out of scope

- Cross-epic edges (a story in one epic gating a story in another) — decide only if it falls out naturally; do not design for it here.
- Any change to `TASK.md`'s existing fields, which already work.

## Human test plan

- [x] Create a two-story epic where a task of story B declares `depends-on: [STORY-A]` and is started; run `/tasks audit` and confirm the edge is reported out of order
      _(rewritten 2026-11-15 by the Decision: the dashboard renders no edges, so the audit is where an edge is checked)_
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in `%LOCALAPPDATA%/Temp/d001`, the cwd
    holding only `brief.txt`, a copy of `skills/tasks` and an invented checkout repo; the coldness probe listed no skills.
    `TASK-002 "Card form" is in-progress, but depends-on STORY-001 (story, in-progress)` under 🟡 Out of order; the
    same run reported the planted own-story cycle, the epic id and the unknown `STORY-009`.
- [x] Run `/tasks pick` with only the blocked story available and confirm it declines or warns rather than offering blocked work
  - **Passed 2026-11-15**, same run: `⚠ dependencies not met: STORY-001 (story, in-progress)` before the plan
    question. And `/tasks new` with a stated wait wrote `depends-on: [STORY-001]` and nothing on the story.
- [x] Run `/tasks audit` and confirm out-of-order work across stories is reported
      _(rewritten 2026-11-15 by the Decision: `/tasks audit` owns it, not `/roadmap`)_
  - **Passed 2026-11-15**, as the first step. The run's one reading on this change (an epic id listed as both a
    broken link and a cycle) was settled in the same change: broken link only.

## Outcome

- **`slicing.md` § *Where the edges live*** owns the rule: a story id in a task's `depends-on:`, one side only, never
  an epic, never the task's own parent story.
- **Readers:** `pick` warns on an open story; `audit` adds `out-of-order`, treats an epic id as a broken link and a
  task naming its own story as a cycle, and prunes a finished story like a finished task; `block --on` takes story
  ids; `new` writes a stated wait; `fix-next` excludes a task waiting on an open story; `TASK.md`'s comment names
  the rule.
- **EPIC-001's sequence table** stays as narrative.

**Close gate (inline; the tasks skill, fix-next, EPIC-001, two specs):**
- **Standards:** one owner (`slicing.md`), every reader pointing at it.
- **Intent:** each criterion answered; three by the decision, as written beside them.
- **Correctness:** d001.
- **Layer parity, security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.
- **Specs:** work-tracking (the story edge, pick's warning, `block --on`, the audit's checks, two scenarios),
  defect-draining (the pool exclusion).

## Implementation plan

Inline, from the decision above.

## Progress log

- step 2 — picked; a decision task, in the user's order (TASK-024, TASK-074, TASK-105, then this)
- step 4 — decided by the user 2026-11-15: the smaller version, provided every criterion is answered
- step 5 — the rule in slicing.md; pick, audit, block, new, fix-next, the TASK template, EPIC-001
- step 6 — behavioural: d001 (the epic-id double listing settled after it)
- step 7 — respecced work-tracking, defect-draining
- step 8 — closed inline; commit in git log
