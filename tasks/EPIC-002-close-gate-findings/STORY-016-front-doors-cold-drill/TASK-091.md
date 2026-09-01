---
id: TASK-091
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
findings: [DRILL-063-2, DRILL-063-3, DRILL-035-5, DRILL-094-1, DRILL-096-2]
pr: null
github-issue: null
jira-key: null
---

# Two artifact shapes the row definitions do not cover

> **Priority raised P3 → P2 on 2026-09-01**, on evidence rather than opinion. Filed as a tidiness gap in
> row wording; it is now a **measured reproducibility failure** — two independent runners assigned opposite
> states to one unchanged file (DRILL-096-2), and the instance count reached five findings across three
> row kinds, one of them a plain row rather than a conditional one. A survey whose state depends on which
> agent ran it is not a survey, and P3 no longer describes that.

## Context

**From the 2026-09-01 cold drill of `adopt-project`'s survey.** Two rows the drill had to resolve by
inference, grouped because both are the same omission — a state or a shape the row cells never discuss.

### `present, elsewhere` on a conditional row

`Symbio` has `deploy/Dockerfile` and `deploy/Dockerfile.dockerignore`, not root-level ones. The state
exists generically — *"found in another location or form. **Say where.**"* — but the conditional rows added
2026-09-01 only ever discuss `missing` / `not applicable` / `unknown` / *leave it*. The drill used
`present, elsewhere` anyway and flagged that nothing confirms it applies: *"no other label fit a Dockerfile
that plainly exists just not at the canonical path; the text doesn't confirm that's the intended use."*

It is almost certainly right — a conditional row's condition decides **whether the row applies**, and the
location states are orthogonal to that, exactly as `present, uncommitted` composes with any row. But
"almost certainly right by analogy" is what a rule is for.

### A guide split across several files

The agent-guide row names two shapes: `CLAUDE.md`, or `AGENTS.md` plus a one-line bridge. `Symbio` carries
`CLAUDE.md` **and** `CLAUDE-module-checklist.md`, `CLAUDE-project-status.md`, `CLAUDE-ui-prompt.md`,
`CLAUDE-ui-rules.md`. The drill left them unclassified and said so: nothing states whether they are part of
the one graded artifact, `present, elsewhere` content, or out of scope.

This matters more than a tidy-up because the guide is the artifact the whole layer is built to feed. A
survey that silently ignores four sibling guide files is not reporting on the thing it says it is.

### Second instance of the same gap, from the 2026-09-01 `Birko.Framework` drill (DRILL-035-5)

Independent corroboration on a **different conditional row**, which is why it is appended here rather than
filed separately: this task already owns the rule, and a second task would re-litigate it.

That repo's licence is `License.md`, not `LICENSE`. The row's branches are binary — *"Open posture and no
`LICENSE` file → **missing**"* / *"Present → **leave it**"* — and neither covers a licence file under a
different name. The runner reached the same conclusion by the same route as the Dockerfile case:

> *"The row's binary … does not say which side a differently-named licence file lands on. I chose
> `present, elsewhere`, naming `License.md` — because § *Detect what the repo has* is emphatic that
> detection is by evidence and not by path, and reporting `missing` here would have been exactly the
> false-`missing` that section calls the dangerous direction."*

**Two conditional rows, two independent runners, the same missing state.** The Dockerfile case was a
canonical artifact at a non-canonical *path*; this one is a canonical artifact under a non-canonical
*name*. Both resolve correctly under `present, elsewhere` and neither row says so, which sharpens the fix:
whatever lands must cover name as well as location, or the next differently-named artifact reopens it.

### Third instance, from the 2026-09-01 `BardStudio` drill (DRILL-094-1)

A **plain** row this time, not a conditional one, which widens the rule the fix owes.

`docs/architecture.md`'s cell reads only *"Leave it; report if absent"* — which taken alone yields
`missing`. But § *Detect what the repo has* says architecture notes *"may live in the README, a `wiki/`, or
`Documentation/`"*. The runner:

> *"The two do not resolve each other, and the row names no verb to defer to. **I chose
> `present, elsewhere`**, because the false-`missing` direction is the one the file calls dangerous … and
> because the row's own instruction — *report if absent* — is satisfied by naming where it actually is.
> Reporting `missing` would invite creating a second architecture document beside `CLAUDE.md`
> § Architecture."*

It is right, and it had to derive it. **So the gap is not specific to conditional rows:** a `Dockerfile` at
a non-canonical path, a licence under a non-canonical name, and now architecture notes in a different
*file* are three shapes of one omission — the location states exist generically and no row cell mentions
them. Whatever lands should therefore say once, where the states are defined, that the location states
compose with **every** row rather than being enumerated per row.

### Two runners, opposite states, one file — the sharpest evidence yet (DRILL-096-2)

The `Birko.Framework` drill of 2026-09-01 met the **same `License.md`** as the run recorded above and
reached the **other** answer:

> *"The row names `LICENSE`; the file is `License.md`. **Chosen: `present`**, naming the actual path — on
> the 'solved it differently' rule. I specifically did **not** use `present, elsewhere`, on the reasoning
> that the file is in the expected *location* and differs only in name and extension. **That distinction
> between 'another location' and 'another name' is mine; the text does not draw it**, and a reader could
> defensibly report `present, elsewhere` instead."*

So one runner reported `present, elsewhere` and another reported `present`, on one unchanged file, each
with sound reasoning. That is no longer an argument that the rule is *missing* — it is a measured
demonstration that the survey is **not reproducible** on this row today, which is the property this repo
removes everywhere else by declaring rather than deriving.

**It also names the axis the fix must cover:** *location* and *name* are different, and the state list
mentions only the first (*"found in another location or form"* — where "form" is doing unexamined work).
With DRILL-094-1's plain-row instance, the fix now owes three axes — another path, another name, another
file — stated once where the states are defined rather than per row.

## Acceptance criteria

- [ ] Whether the location/tracking states compose with a conditional row is stated once, where a reader of either will find it — not repeated on each row
- [ ] The agent-guide row says what a companion file is: part of the artifact, a separate finding, or out of scope, with the reason
- [ ] Whatever is decided holds for the measured cases: `Symbio`'s `deploy/Dockerfile` and its four `CLAUDE-*.md` companions
- [ ] Neither answer reintroduces judging content — a companion file is classified by **existence and role**, never by whether its prose is any good ([[new-project]] `LAYER.md` § *A guide's vintage is not surveyable*)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Whether the guide's rules are current — settled as a limitation by **TASK-063**, and this task must not reopen it.
- Adding more conditional rows. This is about how the existing ones compose with states that already exist.

## Human test plan

- [ ] Survey `Symbio` and confirm both shapes land in a stated outcome rather than in the surveyor's judgement

## Implementation plan

_Populated by `/tasks plan TASK-091` — leave empty until then._
