---
id: TASK-020
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# A defect found mid-adoption gets fixed and never gets an id

## Context

Found in the `adopt-project` drill on `C:\Source\Birko\Consumers\Presenter` (2026-08-18).

The survey turned up two real defects that were not layer gaps:

1. `src/Presenter.Web/tsconfig.json` still pointed its four Birko paths at a directory that does
   not exist — `build.js` had been migrated to the bucket layout in `6182687` and `tsconfig.json`
   was not, so `npm run typecheck` could not resolve anything downstream of `BaseComponent`.
2. `dotnet build` / `dotnet test` were broken outright: a version-less `PackageReference` in an
   imported `.projitems` with no matching `PackageVersion` under central package management
   (NU1010), cascading into a NuGet crash, plus duplicate references the shared projects now
   declare themselves (NU1504).

The run said the right thing — *"I'd file this as a task rather than fix it silently"* — the user
chose *fix it now*, both were fixed and verified (143 tests passing), and **nothing was ever
filed**. Confirmed after the fact: nothing under `Presenter/tasks/` mentions NU1010, NU1504,
tsconfig, CPM or PackageVersion. Two real defects shipped in `4bee0ea` with no tracked record and no
regression check.

The gap is in this skill, not in the choice. `adopt-project` has no rule about defects it finds
while surveying, so "fix it now" reads as *instead of filing* rather than *as well as*. Meanwhile
[[tasks]] § *Findings become tasks, or they evaporate* is unambiguous — and adoption is the one pass
that reads a whole unfamiliar codebase, so it is **the** highest-yield finder of exactly this kind
of defect. It is also, by construction, running in a repo that either has a `tasks/` tree or is
about to get one, so there is nowhere for "we had nothing to file it into" to hide.

A fix that ships with no task is worse here than elsewhere: the fixed repo now has a rulebook and a
lifecycle, so the *next* agent will assume anything untracked was never a problem.

## Acceptance criteria

- [ ] `adopt-project` states that a defect found during the survey or fill is **filed as a task**, not just reported — and that this holds whatever the user decides about fixing it now, later, or never
- [ ] The two paths are spelled out: **fix now → the task is filed too**, recording the fix and its verification; **not now → the task is the whole outcome**. Never "fixed, mentioned in the report, untracked"
- [ ] Ordering is stated: the layer fill is what adoption is *for*, so a found defect never silently displaces it — fill, then defects, unless the defect blocks the fill (a broken build blocking `populate-tests adopt` is the standing example)
- [ ] A fix to shipped behaviour carries a regression check per [[tasks]]'s standing rule, or the task records why one is impossible — the Presenter build fix had neither
- [ ] Filing goes through the owning verb (`/tasks new`, or `spawn` when adoption is itself running under a task), never a hand-written file — and in a repo whose `tasks/` this same run just created, the task lands after the tree exists
- [ ] The report's buckets say where found-defect work shows up, so it is not confused with layer work: a defect fix is neither `created` nor `amended` in the layer sense
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Backfilling the two Presenter tasks retroactively — that is Presenter's own tracker's business, and the fixes are already merged and verified there.
- Whether adoption should fix defects at all; it should offer, and the user decides. This task is only about the record.
- `/specs init`'s vacuous coverage check from the same run — a specs-skill defect, not filed here.

## Human test plan

- [ ] Drill a repo with a known, obvious defect outside the layer (a dead path, a broken script) and confirm the run offers a task, and that accepting "fix it now" produces **both** the fix and the task
- [ ] Confirm declining the fix still leaves a filed task rather than a paragraph in the report
- [ ] Confirm a defect that blocks the fill is handled first and says why it jumped the queue
- [ ] Re-read the Presenter report against the new rule and confirm it would have produced two tasks

## Implementation plan

_Populated by `/tasks plan TASK-020` — leave empty until then._
