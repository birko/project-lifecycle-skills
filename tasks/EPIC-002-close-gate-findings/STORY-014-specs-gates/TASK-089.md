---
id: TASK-089
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-033-3]
pr: null
github-issue: null
jira-key: null
---

# `coverage: unverified` has never once been produced, across three drills

## Context

**The unclosed half of TASK-033.** That task added a three-value coverage verdict to `/specs init`, and
`unverified` is the value the whole change exists for — the state that stops a run reporting coverage it
never established. **Three cold drills over nine repositories have never produced it.**

| Drill | Repos | Verdicts reached |
|---|---|---|
| Fixtures, 2026-09-01 | A, B, C, D (+ D re-run) | `verified` ×4, `not-applicable` ×1 |
| Real repos, read-only | Latent, Presenter, WorkoutTracker, Symbio, BardStudio | `verified` ×5 (under the post-reconciliation reading TASK-033 later settled) |
| Re-drill, read-only | BardStudio, Presenter | `verified` ×2 |

**Two different reasons it never fired, and neither is reassuring.**

- **The fixture built to force it failed to.** Fixture A was a repo whose sources were `engine/*.rules`
  — an unconventional extension, no `.csproj`, no recognised stack — on the assumption that discovery
  would come back empty. The runner read the README, understood the files were the sources, and returned
  `verified` with a scan set of 3. **The assumption that an unusual extension defeats discovery is simply
  false**, and that is worth knowing on its own.
- **Every real repo is ordinary .NET.** All five have recognisable sources, so `unverified` was never
  reachable there.

**Why this is filed rather than shrugged off.** `unverified` carries the strongest consequence in the
schema — it tells a later reader, and `init`'s own step 2, that a populated map is **not** a blessed
baseline. That branch currently rests on reasoning alone. Every other rule TASK-033 added was executed
mechanically by a drill and two of them changed a real outcome; this one has never run.

**The hard part is constructing an honest case, and that is the task.** A repo where discovery genuinely
fails is not a repo with odd file extensions — the drill proved a competent agent reads the README and
recovers. Candidates worth trying, none obviously right: a repo whose sources sit outside the project
root (the polyrepo aggregator shape `regen` step 6 already measures); a monorepo where the walk resolves
to the wrong root; a repo whose behaviour lives in a database, generated code, or a submodule that is not
checked out. **If it turns out `unverified` is effectively unreachable for a careful agent, that is a
finding about the verdict's value, not a failure of this task** — say so and let the rule shrink.

## Acceptance criteria

- [ ] A repo shape is found or built where `/specs init` genuinely reaches `unverified`, and a cold drill reaches it **without being told that is the target**
- [ ] The run refuses to claim coverage, and does not write a populated map that reads as blessed
- [ ] Step 2's consequence is exercised: a later re-discovery over that map treats its areas as proposals to re-confirm, not as a baseline
- [ ] **Or**, if no honest case can be constructed, that is recorded with what was tried, and `unverified`'s definition narrows to what can actually occur
- [ ] Whatever is learned lands in `skills/specs/verbs/init.md`, not only in this task

## Out of scope

- The other two verdicts. `verified` and `not-applicable` are drill-exercised — the latter on a docs-only fixture, reported distinctly from an empty result.
- Re-testing the rules TASK-033 already validated in the wild (`:(glob)`, the tracked-files universe, dot-paths, unverified-on-absent-key). The last of those caught a real blind spot in Presenter and needs no further evidence.

## Human test plan

- [ ] Hand the constructed repo to a fresh agent with the expected verdict **withheld**, per TASK-068, and confirm it reaches `unverified` from the prose alone
- [ ] Confirm a repo that merely *looks* unusual (odd extensions, no manifest) still reaches `verified` — the failure mode this task must not create is an `init` that cries wolf on any unfamiliar stack

## Implementation plan

_Populated by `/tasks plan TASK-089` — leave empty until then._
