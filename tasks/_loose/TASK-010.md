---
id: TASK-010
parent: null
feature: null
status: todo
priority: P2
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# /tasks pick walks past verification debt without mentioning it

## Context

Found while writing a session handoff: asked "will the unfinished things resurface when I run
`/tasks pick`?", the honest answer turned out to be **no**.

The bare `/tasks` snapshot handles this well. `SKILL.md` renders a `review:` count and an
`In review:` list, and states the intent outright: *"In-review tasks are verification debt —
surface them, don't bury them."*

`verbs/pick.md` does not. It defaults to `--status todo` (correctly — a task awaiting sign-off is
not work to start), collects candidates, and offers one. Nothing in the verb mentions `review` at
all. So a session that opens with `/tasks pick` — the natural resume command, and the one this
repo's own handoff advice recommended — is handed fresh work while seven code-complete tasks sit
unverified, and never learns they exist.

The failure is quiet in the worst way: picking new work over unverified work is exactly what the
verification-debt rule exists to prevent, and the verb that starts work is the one place the rule
is never stated.

## Acceptance criteria

- [ ] `pick` reports outstanding `review`-state tasks **before** offering a candidate — count plus ids, not a full listing
- [ ] Above a threshold (start at 3, tune with use) it **asks** whether to clear debt first rather than merely mentioning it; the user can still say no
- [ ] `review` tasks stay out of the candidate list — the fix is to *surface* the debt, not to offer unfinished work as new work
- [ ] The wording matches the bare snapshot's, so the two verbs describe the same state the same way
- [ ] `fix-next` gets the same check, or a recorded reason why a defect-draining loop should ignore it
- [ ] Reconsider the handoff advice this repo gives: `/tasks` (which surfaces debt) reads better as a resume command than `/tasks pick` (which does not)

## Out of scope

- Changing what `review` means, or how a task leaves it — `close` already owns that.
- Blocking `pick` outright when debt exists. Debt is a judgement call; the user may have a good
  reason to push on, and a gate that cannot be overridden gets worked around.

## Human test plan

- [ ] With 7 tasks in `review` (this repo, today), run `/tasks pick` and confirm the debt is stated before any candidate is offered
- [ ] With none in review, confirm the output is unchanged — no noise on a clean tree
- [ ] Confirm a `review` task is still never offered as a candidate

## Implementation plan

_Populated by `/tasks plan TASK-010`._
