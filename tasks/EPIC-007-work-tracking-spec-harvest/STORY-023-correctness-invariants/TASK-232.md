---
id: TASK-232
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-15]
pr: null
github-issue: null
jira-key: null
---

# DV5 flags every story that has no feature behind it, including the ones that should not have one

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-15.** `skills/roadmap/SKILL.md` § 4, DV5's second arm: "a story/epic with tasks but no feature folder". Many
  stories legitimately have no feature: review-intake stories (this epic's own two), defect stories, chores, tree
  hygiene — everything the [[tasks]] skill tracks that carries no stakeholder decision. As written, each is reported
  under *Tracked in one tree only*, which the full render calls "the real planning holes". On a tree like this one the
  arm reports mostly correct structure, and a check that does that gets ignored (the same failure TASK-032 describes
  for divergences that cannot be accepted).

## Acceptance criteria

- [x] DV5's second arm states which stories and epics it applies to, and excludes at least `kind: review-intake`
      epics and their stories, read from a declared field rather than inferred from a title
- [x] The criterion says what a story with no feature must carry, if anything, to be recognised as feature-less on
      purpose, or why nothing is needed
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Recording a divergence as accepted — TASK-032
- DV1/DV4 — TASK-207

## Human test plan

- [x] Run `/roadmap --check` on this repo before and after: the DV5 hits that remain are each a requirement tracked in
      one tree only, by reading them
  - **Passed 2026-10-11:** on an export of this repo at `d096667` (`%TEMP%\d232`, fresh `git init`), two
    `claude -p` runs per side. Before: DV5 on **6** epics (EPIC-001, 002, 003, 007, 008, 010). One runner remarked
    that four were review pools "developer-only by design … the audit has no exception for them". After: DV5 on
    **2** in both runs (EPIC-001, EPIC-010). Read one by one, both are capability work with no feature: the
    yolobox adoption predates features, and the UX guidance was built without one. The runner sits in a copy of
    this repo, so it holds the guide and the installed skills; this is a behaviour check of the rule on real data

## Implementation plan

_Populated by `/tasks plan TASK-232` — leave empty until then._

## Outcome

**The fix.** DV5's second arm flagged every story or epic with tasks and no feature, so on this repo it listed
four defect backlogs as "the real planning holes" next to the two that are. It now exempts defect work, read from
declared fields: an epic stamped `kind: review-intake` with everything under it, and a story or epic whose every
task carries a non-empty `findings:` list. It never exempts a story by its title.

**Why nothing else needs a marker.** Defect work has no feature by design, because a finding is a defect in
behaviour something else already owns. Chores and tree hygiene stay in `tasks/_loose/`, which this arm never sees,
since a loose task has no story or epic. Anything else under a story or epic is planned work that should trace to
a feature. Adding a "feature-less on purpose" field would hand every hole a way to silence itself.

**Step 6 split.** Pre-fix, 2 runs on the same export: **6** DV5 epics each. Fixed, 2 runs: **2** each. Both
EPIC-001 and EPIC-010 are genuine. **Fix-dependent:** the four review-intake epics leaving DV5. **Contract
pins:** EPIC-001 and EPIC-010 flagged on both sides, and the feature arm unchanged.

**Judgement calls.**
- *Exempt on `findings:` for every task, not for any task.* A story mixing defects with new capability still owes
  a feature for the capability part. STORY-003 under EPIC-001 is that case and stays flagged.

**Flagged, not fixed.** EPIC-010 (UX guidance) shipped with no feature folder. That is a real hole DV5 now
surfaces, and it is the owner's call whether to backfill one. No task was filed, because this is the check
working, not a defect.

## Progress log

- step 2 — picked; ranked above TASK-233 because DV5's second arm reports correct defect backlogs as "the real planning holes" on every tree with a review-intake epic (key 2: this repo's dashboard carries it on every regen; key 3: real holes drown in the noise), fixable in one table row (key 4); TASK-233 is an unstated combination of two flags. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. DV5's row: "a story/epic with tasks but no feature folder", no exemption; the full render calls these "the real planning holes"; this repo's dashboard lists three review-intake epics under DV5
- step 4 — layer: local (`skills/roadmap/SKILL.md`)
- step 5 — fix in `skills/roadmap/SKILL.md` DV5 row: second arm exempts `kind: review-intake` epics and their descendants, and a story/epic whose every task carries `findings:`; why nothing else needs a marker; never by title. Lint green
- step 6 — reverted: pre-fix 2/2 runs flagged 6 epics, fixed 2/2 flagged 2 (EPIC-001, EPIC-010). Fix-dependent = the 4 review-intake epics dropping out; contract pins = EPIC-001, EPIC-010
- step 7 — respecced project-roadmap ("DV5 — tracked in one tree only": the defect-work exemption from declared fields, never by title; scenario "A review backlog has no feature by design"); `generated-at` restamped. Dashboard drift line updated to the DV5 set a regen now computes (EPIC-001, EPIC-010)
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
