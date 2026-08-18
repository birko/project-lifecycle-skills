---
id: TASK-024
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The other owner verbs still cannot say whether an artifact is current

## Context

Spawned from TASK-023's close gate. `AGENTS.md § Conventions` now carries the rule that produced
that task:

> **An owner verb reconciles; it does not assume.** … reports **already current** distinctly from
> **brought up to date** … Applies to every row of `LAYER.md` with an **Owner**, not just the one
> that exposed it.

Only `/tasks init` was taught it. The other owners named in `LAYER.md`'s Owner column still answer a
present artifact with a single undifferentiated "nothing to do":

- **`/specs init`** — re-discovers the area map and proposes a delta, which is most of the way there; what it does not do is report *already current* distinctly from *declined to look*.
- **`populate-tests` `adopt`** — the test-harness row says a working runner is already adopted; nothing checks whether the harness matches the shape that mode now writes.
- **`roll-changelog`** — the changelog row is present-or-absent only; a `CHANGELOG.md` that predates the Keep-a-Changelog shape reads as fine.
- **`[[feature]]`'s index** — owned by `/feature status`, and its row is a prohibition rather than a delegation, so it may not belong in scope at all; decide that explicitly rather than by omission.

The consequence is asymmetric and quiet: [[adopt-project]] now maps an owner's answer onto a survey
state, and a verb that cannot distinguish those two cases leaves its row `unknown` — honest, but it
means an adoption pass over a fully-adopted repo reports several rows as *"present, and `<verb>`
could not tell me whether it is current"*. That is the correct output for the code as it stands, and
it is noise that will train people to skim the report.

**Not one task per verb, deliberately.** They share one contract and the fix is the same shape in
each; splitting buries what makes them cheap together. Whether each verb needs *reconciliation* or
only the *three-outcome report* differs though, and that judgement per verb is the work.

## Acceptance criteria

- [ ] Each owner verb reached from `LAYER.md`'s Owner column either reports the three outcomes (**created** / **already current** / **brought up to date**) or records why the distinction does not apply to it — decided per verb, in that verb's file
- [ ] Where a verb owns a *shape* that has grown (a template, a required section, a file format), it reconciles an older instance in place: add what is missing, never re-decide what is there
- [ ] `/feature status`'s row is settled explicitly — delegation or prohibition — since `LAYER.md` § *Delegation follows the row* keys on that distinction
- [ ] `adopt-project` needs no change: it already maps an owner's answer onto a state. Confirm that holds for each verb rather than assuming it, and if a verb's vocabulary does not fit the mapping, that is a finding worth reporting
- [ ] An adoption pass over a fully-adopted repo reports **no** `unknown` rows caused by a verb's silence
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- `/tasks init` — done in TASK-023, and it is the reference implementation for the rest.
- Reconciling task/epic/story **frontmatter** against its templates; still its own decision, still unfiled.
- Changing what any of these verbs generates; this is about what they can *say* about an existing instance.

## Human test plan

- [ ] Re-drill `adopt-project` on a fully-adopted repo (WorkoutTracker is the candidate — every row present) and confirm no row reports `unknown` because a verb stayed silent
- [ ] For each verb changed, run it twice on a current artifact: *already current*, then no write
- [ ] For each verb that gained reconciliation, run it on a deliberately old instance and confirm the delta is added and reported
- [ ] Confirm a verb that legitimately has no currency question says so in its own file rather than being silently skipped

## Implementation plan

_Populated by `/tasks plan TASK-024` — leave empty until then._
