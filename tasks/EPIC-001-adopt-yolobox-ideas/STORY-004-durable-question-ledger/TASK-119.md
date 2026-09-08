---
id: TASK-119
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-114]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `feature` reconciles an `idea.md` written before the question table existed

## Context

**Derived from a convention, not from STORY-004's text** — recorded that way deliberately, so a reader
does not go looking for the sentence that asked for it.

`AGENTS.md` § *An owner verb reconciles; it does not assume*: a verb owning a file shape must answer
*"is this instance current?"*, not only *"does it exist?"* — because **existing is not current**. The
shape gains fields, and an instance written before one existed looks complete from outside.

TASK-114 gives `idea.md` a field it never had. Every `idea.md` already on disk therefore becomes an
older instance of a shape whose owner is `[[feature]]`. Without this task, `/feature pick` on such a
feature finds a prose bullet list, computes an empty frontier, and reports *"no open questions"* — which
is indistinguishable from a feature whose questions are genuinely all resolved. **That is the exact
failure mode the convention names: a caller cannot tell "your file is fine" from "I declined to look".**

### The population is real, not hypothetical

Consumer repos already carry the old shape at scale — one has 94 features, another 18, a third 6. This
is the same class of problem as TASK-059 (repos on an older layer), one level down: not a missing
artifact, a **stale shape inside a present one**.

### Scope note

The layer inventory's `docs/features/` row is owned by `[[feature]]`, so this is **not** a
`new-project` / `adopt-project` parity change. Checked rather than assumed — the parity rule is about
rows in `LAYER.md`, and this changes a file's interior, not the inventory.

## Acceptance criteria

- [ ] `feature` can tell a pre-table `idea.md` from a current one, and says which — never treating the
      absence of a table as an empty frontier
- [ ] An older instance is reconciled **in place**: add what is missing, never re-decide what is there.
      Existing prose questions are carried into rows or left as fog **with the rule applied**, not
      silently dropped
- [ ] The verb reports **already current** distinctly from **brought up to date** — the two must not
      print the same line
- [ ] Reconciliation is offered, not imposed: a user who declines gets a recorded declination rather
      than a silent skip that repeats next run
- [ ] Nothing restates TASK-114's shape or states
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Reconciling repos on an older universal layer** — TASK-059 owns that, one level up.
- Bulk-migrating a consumer's features unattended. Whether a 94-feature repo is done in one pass is a
  decision for whoever runs it, and if it needs machinery that is its own task.
- Changing `decisions.md`, which is unaffected by TASK-114.

## Human test plan

- [ ] Take a real `idea.md` written before this story — a consumer repo has many — and run the reconcile.
      Expected: existing prose questions survive, the report distinguishes *already current* from
      *brought up to date*, and a second run reports the first. Withhold all three expectations from any
      cold runner's brief.
