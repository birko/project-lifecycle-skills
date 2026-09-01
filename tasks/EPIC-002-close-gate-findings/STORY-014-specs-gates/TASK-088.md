---
id: TASK-088
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-033-2]
pr: null
github-issue: null
jira-key: null
---

# Nothing says whether one source file may belong to two capability areas

## Context

**Raised by both 2026-09-01 cold drills of `/specs init`**, independently.

Step 4's remedy for an unmapped file is *"extend an area or add one"* — singular, and the template's
examples never test the case. But the situation is real and already shipped in two consumer maps:

- **WorkoutTracker** does it deliberately and says so: `ProgressEndpoints.cs` appears under both
  `exercise-progress` and `training-activity`, with a comment explaining that one file hosts two read
  models. The same map now also shares `plans-segments.ts` between `plan-hierarchy` and
  `exercise-library` — one segment bar rendered by two surfaces.
- **Presenter**'s drill put `appsettings.json` in **three** areas, because its `Fetch.*`, `Session.*` and
  `Database.*` sections are consumed by three different capabilities.

Both drills flagged the same gap: the practice exists, it looks correct, and no rule sanctions it.

**What has to be decided, and it is not obvious.** Sharing is right when one file genuinely hosts several
capabilities, and wrong when it means the areas are drawn around files instead of behaviour. Consequences
travel downstream: `/specs regen` harvests each area from its `sources:`, so a shared file is read once
per area and can produce two specs asserting overlapping things; `verify`'s staleness check will mark
**every** sharing area stale on one edit; and `coverage-drift`'s list may name a path already present
elsewhere.

## Acceptance criteria

- [ ] Whether a file may appear in more than one area's `sources:` is stated, with the test for when it should
- [ ] The consequence for `regen` (one file harvested into several specs) is named, not left to be discovered
- [ ] The consequence for `verify` (one edit marks several areas stale) is named
- [ ] The existing deliberate instances are consistent with whatever is decided, or are called out as needing change — `ProgressEndpoints.cs`, `plans-segments.ts`, and Presenter's `appsettings.json` if that map is ever written
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Re-drawing any consumer repo's areas. This decides the rule; applying it is that repo's own work.
- Whether config files count as behavioural source — that judgement is [[specs]]' `coverage-drift` classification, and TASK-033 settled that it is a judgement recorded as paths.

## Human test plan

N/A — the deliverable is a stated rule plus two named consequences, checkable by reading it against the
three existing instances. No run exercises "is this rule wise"; the next re-discovery of WorkoutTracker's
map is where it gets used in anger.

## Implementation plan

_Populated by `/tasks plan TASK-088` — leave empty until then._
