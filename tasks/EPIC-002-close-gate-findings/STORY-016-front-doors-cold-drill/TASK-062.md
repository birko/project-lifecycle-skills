---
id: TASK-062
parent: STORY-016
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-2]
pr: null
github-issue: null
jira-key: null
---

# The test-harness ladder reports `missing` on the repo that ships it

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance).

`LAYER.md:111` gives the evidence order for the test-harness row: *"a test runner in the manifest
(xunit, vitest, pytest, `go test`); then `*.Tests`/`*_test.*`/`*.spec.*`/`*Test*.cs` files **anywhere**;
then a runner config."*

**This repo has no manifest and matches none of those globs.** Its suite is
`.github/workflows/skills-lint-test.sh` — hyphen-`test`, not underscore; `.sh`, not a recognised test
extension. Applied literally, the ladder returns **`missing`** for the test harness of the repo that
defines the ladder.

That is the exact **false-`missing`** the whole § *Detect what the repo has* section exists to prevent,
and the section names why it is the dangerous direction: *"Fill acts on the survey, so 'missing' invites
writing."* Here it would invite `populate-tests` to wire a runner over a working 36-case suite.

**What actually saved the drill was the prose**, not the ladder: `LAYER.md:107`'s *"detect by
**evidence**, not by path"*. The agent followed the preamble over the table and reported `present`. So
the mechanism is one sentence of judgement standing between the table and a wrong answer — fine for an
attentive reader, and exactly the kind of thing that fails under time pressure or on a less careful pass.

**Sibling, not duplicate: TASK-025.** That task is DV10's *"real code"* test failing to see a repo whose
code is prose, in `roadmap`. This is the same blind spot in `LAYER.md`'s ladder. Same root idea, two
different files and two different consumers — **cross-reference, do not merge**, and check the other
direction while here: are there further detection rules that assume a compiled language?

## Acceptance criteria

- [ ] The ladder's evidence recognises a script-based suite invoked by CI — this repo's own is the test case, and it must come out `present`
- [ ] The generalisation is deliberate, not a glob bolted on for `.sh`: state what class of evidence the new entry covers, so the next non-compiled stack is not another special case
- [ ] The "detect by evidence, not by path" preamble is still the governing rule — the table gets closer to it rather than replacing it
- [ ] TASK-025 is cross-referenced from this task and this task from TASK-025, with a line on why they stay separate
- [ ] Other detection rules in `LAYER.md` are checked for the same compiled-language assumption; each is either fixed here or spawned, and the sweep's outcome is stated either way
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `roadmap`'s DV10 — **TASK-025** owns it.
- Widening `populate-tests`' own stack detection. If it shares the assumption, spawn it.
- The other drill findings — separate tasks under STORY-016.

## Human test plan

- [ ] Run `adopt-project`'s survey against **this repo** and confirm the test-harness row reports `present`, reached from the ladder rather than from the preamble rescuing it
- [ ] Run it against a repo with a conventional suite (`Birko/Consumers/WorkoutTracker` has xUnit + Playwright) and confirm the generalisation did not break the ordinary case

## Implementation plan

_Populated by `/tasks plan TASK-062` — leave empty until then._
