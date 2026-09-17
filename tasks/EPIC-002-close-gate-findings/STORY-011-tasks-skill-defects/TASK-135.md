---
id: TASK-135
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-127]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/fix-next` picks a task without ever offering the plan `/tasks pick` would have offered

## Context

Found 2026-09-17 by the `/verify-conventions` pass at [[TASK-127]]'s close gate, against this repo's own
rulebook.

`AGENTS.md` § Working rules is unconditional:

> **Plan before implementing.** A non-trivial task gets its `## Implementation plan` before work starts.

[[tasks]] SKILL.md § Lifecycle says who enforces that:

> `new` auto-runs [plan](verbs/plan.md) for tasks, and `pick` offers it for any task that reached work
> without one (default **yes**; decline only for genuine one-liners).

**`/fix-next` does its own picking and inherits neither.** Its step 2 writes `status: in-progress`,
`picked-by:` and the first `## Progress log` line directly, then goes to step 3 (re-verify) and step 5
(fix). No step drafts or offers a plan, and `/tasks plan` is named nowhere in the skill. So every
`fix-next` run on a task filed by `/tasks intake` — which does **not** auto-run `plan` the way
`/tasks new` does — implements a non-trivial task with the placeholder still in the file.

### Observed

TASK-127 closed with `## Implementation plan` reading *"Populated by `/tasks plan TASK-127` — leave empty
until then."* after a full nine-site change across five files. The gate caught it at close, which is the
wrong end: by then a plan can only be a transcript of the work, and backfilling one is the
"acceptance list becomes a transcript" defect arriving through a different section.

**Measured**: of the 33 `todo` tasks in the pool at that run, **spot-check how many carry an unpopulated
plan placeholder** — the answer is the size of this defect, and it should be in the fix's record.

## Acceptance criteria

- [ ] `/fix-next` step 2 either drafts the plan or states, per task, why the task is small enough not to
      need one — matching what `/tasks pick` already does rather than inventing a second policy
- [ ] The decision is **recorded in the `## Progress log`**, so a reset session can tell "planned" from
      "nobody looked"
- [ ] Unattended behaviour is defined, per `AGENTS.md` § *An ask-step carries the question it puts and the
      answer-less path* — `fix-next` runs with nobody present by construction, so "offer it" is not an
      available answer here and the skill must say what it does instead
- [ ] Whether `/tasks intake` should auto-run `plan` the way `/tasks new` does is **answered either way**,
      in writing — it is the upstream half of the same gap and leaving it unstated just moves the question
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing what a plan contains, or `/tasks plan` itself — only who invokes it and when.
- [[TASK-127]]'s own missing plan; it is recorded there as a gap rather than backfilled, deliberately.

## Human test plan

N/A pending AC1's shape — if the fix is prose in `fix-next` step 2, this is a reviewer check against the
two quoted rules. If it changes what `intake` generates, that is a drill-worthy change and this line is
replaced with one per `AGENTS.md` § Testing.

## Implementation plan

_Populated by `/tasks plan TASK-135` — leave empty until then._
