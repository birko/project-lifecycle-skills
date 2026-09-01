---
id: TASK-099
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-091-2, DRILL-097-2]
pr: null
github-issue: null
jira-key: null
---

# A row that names two artifacts never says whether the second carries its own state

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `Symbio`.**

One row in the inventory names a companion artifact parenthetically:

```
| Dockerfile (+ .dockerignore) (conditional — …) | … |
```

Nothing says whether `.dockerignore` is surveyed as part of that row or carries a state of its own. The
runner:

> *"The row is written **`Dockerfile` (+ `.dockerignore`)**, and never says whether the parenthesised
> companion carries its own state. I folded it into the same row as `present, elsewhere` (deviating in
> **both** path and name) rather than reporting a missing root `.dockerignore` beside a present-elsewhere
> `Dockerfile`."*

Its choice is almost certainly right, and the measured case shows why the question is not academic: that
repo has `deploy/Dockerfile` **and** `deploy/Dockerfile.dockerignore` — Docker's per-Dockerfile ignore
convention, so the companion deviates from the row's canonical form in **both** path and name at once. Under
the other reading the survey reports a present-elsewhere `Dockerfile` beside a missing root `.dockerignore`,
and then offers to create one — the false-`missing` this inventory calls the dangerous direction, arriving
through a parenthesis.

### The general question, which is why it is worth an id at all

This is the last unstated axis of the composition rules. § *Location is orthogonal too* now settles that
location composes with every row, and the agent-guide row settles that a linked companion is part of one
artifact. **A parenthesised companion is the third shape and nothing covers it** — and the answer is not
obviously the same as the guide's, because a guide's companion is *linked from* the entry point while a
`.dockerignore` is bound to its `Dockerfile` by a filename convention the tooling enforces.

Today `Dockerfile (+ .dockerignore)` is the only row of this shape, so the fix is small. It will not stay
the only one — `.env` / `.env.example` are already an implicit pair handled by prose rather than by a row,
and the inventory has grown steadily.

**Do not answer it by splitting the row.** Two rows for one deployment concern would report two states for
one decision, and the `(conditional)` marker would then have to be duplicated and kept in sync — the
restated-list defect at row granularity.

### A second row with the same shape, from the 2026-09-01 `WorkoutTracker` drill (DRILL-097-2)

The `tasks/` row is written `` `tasks/` (`.config.yml` + `README.md`) `` — the same parenthesised-companion
shape as the `Dockerfile` row, and it produced the same undecided question, on a row where **the answer
changes the state**:

> *"Probed as those two files it is plain **present**; probed as the directory it is **present, uncommitted**
> (`TASK-166…md` modified). I took the directory reading — the state's own text treats these as *'the layer's
> directory artifacts'* — and I am reporting both readings **because the choice changes the row**."*

Both named files were **clean**; only a third file inside the directory was modified. So the narrow reading
says `present` and the directory reading says `present, uncommitted`, and the row does not say which it is.

**This widens the task in two ways.** First, it is no longer one row: two rows carry the parenthesis, so
whatever lands must cover both rather than being written for `Dockerfile`. Second — and this is the harder
half — the two rows want **different** answers. `.dockerignore` is a *sibling artifact* the tooling pairs by
filename; `.config.yml` and `README.md` are *members of a directory the row names*. A rule that folds a
sibling into its partner's state does not obviously tell you whether a directory row is probed as its named
members or as the whole directory. The state's own prose calls these *"the layer's directory artifacts"*,
which points at the directory reading — but that phrase sits in a state definition, not in the row, and the
runner had to go find it.

## Acceptance criteria

- [ ] Whether a parenthesised companion carries its own state is stated once, where a reader of any such row will find it — not per row
- [ ] The measured case resolves without a false gap: `deploy/Dockerfile` + `deploy/Dockerfile.dockerignore` must not produce a missing root `.dockerignore`
- [ ] The answer says how a **convention-bound** companion (a filename the tooling pairs) differs from a **linked** one (an agent-guide companion), or states that they take the same treatment and why
- [ ] The row is not split into two, and the reason is recorded
- [ ] Layer parity: the rule lands in `LAYER.md`, which both front doors read
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The location states themselves — **TASK-091** settled path / name / file and their composition with every row.
- The agent-guide companion rule — also TASK-091, and this task must stay consistent with it rather than reopening it.
- Whether `Dockerfile` should be a layer row. It is, and the conditional-row design is not in question.

## Human test plan

- [ ] Cold-drill a repo whose `Dockerfile` and its ignore file both sit off the canonical path, expected answers withheld, and confirm the runner reports one state without listing the companion under what it had to decide

## Implementation plan

_Populated by `/tasks plan TASK-099` — leave empty until then._
