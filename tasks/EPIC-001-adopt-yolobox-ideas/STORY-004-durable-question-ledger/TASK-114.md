---
id: TASK-114
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-115]
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `feature` reconciles an `idea.md` written before the question table existed

## Context

**Re-cut 2026-10-04 by TASK-195** under `skills/tasks/slicing.md`. This task used to be "The question table — the
shape every other task in this story reads", carrying the table *and* (merged 2026-09-26) TASK-119's reconcile.
The table alone fails H3 (a shape no verb writes or reads), so its shape criteria moved to TASK-115, which lands
the table with its writer and reader. This task keeps the reconcile half. Its priority moved with the
foundational work: TASK-115 is now P1, this one P2. **Edge:** TASK-115 defines the shape this task upgrades
older files to, so TASK-115 `blocks` it. TASK-115 also *recognises* a pre-table file and says so; this task
upgrades one.

### Merged in 2026-09-26: TASK-119 — `feature` reconciles an `idea.md` written before the question table existed

_Merged because the table and the reconcile of older idea.md files ship together; the table alone makes /feature pick report "no open questions" on every existing feature. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-119.md`._

**Derived from a convention, not from STORY-004's text** — recorded that way deliberately, so a reader
does not go looking for the sentence that asked for it.

`AGENTS.md` § *An owner verb reconciles; it does not assume*: a verb owning a file shape must answer
*"is this instance current?"*, not only *"does it exist?"* — because **existing is not current**. The
shape gains fields, and an instance written before one existed looks complete from outside.

TASK-115 gives `idea.md` a field it never had. Every `idea.md` already on disk therefore becomes an
older instance of a shape whose owner is `[[feature]]`. Without this task, such a feature stays on the
old shape forever: TASK-115 makes `/feature pick` say so rather than report *"no open questions"*, but
nothing brings the file up to date. **A caller still cannot get from "this file is old" to "this file is
current" except by hand.**

#### The population is real, not hypothetical

Consumer repos already carry the old shape at scale — one has 94 features, another 18, a third 6. This
is the same class of problem as TASK-059 (repos on an older layer), one level down: not a missing
artifact, a **stale shape inside a present one**.

#### Scope note

The layer inventory's `docs/features/` row is owned by `[[feature]]`, so this is **not** a
`new-project` / `adopt-project` parity change. Checked rather than assumed — the parity rule is about
rows in `LAYER.md`, and this changes a file's interior, not the inventory.

## Acceptance criteria

*From TASK-119:*

- [ ] An older instance is reconciled **in place**: add what is missing, never re-decide what is there.
      Existing prose questions are carried into rows or left as fog **with the rule applied**, not
      silently dropped
- [ ] The verb reports **already current** distinctly from **brought up to date** — the two must not
      print the same line
- [ ] Reconciliation is offered, not imposed: a user who declines gets a recorded declination rather
      than a silent skip that repeats next run
- [ ] Nothing restates TASK-115's shape or states
- [ ] `bash .github/workflows/skills-lint.sh` passes

(TASK-119's first criterion, telling a pre-table `idea.md` from a current one, moved to TASK-115 at the re-cut,
because `pick` must not misread an older file the moment the table exists.)

## Out of scope

- **The table, `/feature new` writing it and `/feature pick` reading it** — TASK-115.
- **`claimed-by`** — TASK-257.
- **`grill-me` frontier rounds and the `research` type** — TASK-117.

*From TASK-119:*

- **Reconciling repos on an older universal layer** — TASK-059 owns that, one level up.
- Bulk-migrating a consumer's features unattended. Whether a 94-feature repo is done in one pass is a
  decision for whoever runs it, and if it needs machinery that is its own task.
- Changing `decisions.md`, which is unaffected by the table.

## Human test plan

*From TASK-119:*

- [ ] Take a real `idea.md` written before this story — a consumer repo has many — and run the reconcile.
      Expected: existing prose questions survive, the report distinguishes *already current* from
      *brought up to date*, and a second run reports the first. Withhold all three expectations from any
      cold runner's brief.

## Implementation plan

_Populated by `/tasks plan TASK-114` — leave empty until then._
