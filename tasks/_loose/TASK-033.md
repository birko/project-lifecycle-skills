---
id: TASK-033
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs init`'s coverage check can pass vacuously

## Context

Filed by TASK-020's `close` step 5d sweep (2026-08-19). It had been sitting in that task's
`## Out of scope` as *"`/specs init`'s vacuous coverage check from the same run — a specs-skill
defect, not filed here"* — unowned work wearing a boundary's clothing, which is exactly what the sweep
exists to catch. Confirmed unowned before filing: nothing else in `tasks/` covers it (TASK-002's
"vacuous pass" fix is a different defect, in `skills-lint.sh`).

**Observed** during the `adopt-project` drill on `Presenter`, 2026-08-18, in the same run that produced
TASK-020 and TASK-021.

`/specs init` step 4 checks coverage: *"any source file matching neither an area nor `ignore` → list as
unmapped and either extend an area or add one."* That check has no floor. If the scan set comes back
empty — no area glob matches anything, or the source discovery finds nothing — then "no unmapped files"
is trivially true and the step reports full coverage having verified nothing. It is the same shape as
the vacuous-pass defect already fixed in `skills-lint.sh` under TASK-002, which is grounds for
believing the fix shape is known even though this instance is not yet reproduced.

**What is not known, and must not be guessed:** the specifics of the Presenter instance were never
written down — only that a defect was seen here. So step one of this task is to **reproduce it**, not
to fix from this description. If reproduction shows the check is sound and something else misfired,
that finding closes the task just as well; do not bend the repro to fit this write-up.

## Acceptance criteria

- [ ] The Presenter-run behaviour is reproduced against a repo where the area globs match nothing, and what actually happens is recorded — including "the check is fine" if that is the answer
- [ ] If confirmed: an empty scan set is a **failure**, not a pass — `/specs init` says it could not establish coverage rather than reporting coverage it did not verify
- [ ] The distinction between *nothing to map* (a genuinely code-free repo) and *the mapping matched nothing* (a broken map) is stated, since the first is legitimate and the second is the defect
- [ ] Whatever the outcome, the `.map.yml` written by a run that could not verify coverage does not read as validated
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- DV10's blind spot on repos whose code is prose — TASK-025 owns that; a repo with no detectable source is that task's subject, not this one's.
- The empty-`areas:` seed in this repo's own `.map.yml` — STORY-008 fills it.
- `/specs regen`'s provenance attribution — TASK-026, already done.

## Human test plan

- [ ] Run `/specs init` against a repo whose sources exist but whose proposed globs match none of them, and confirm the run refuses to claim coverage
- [ ] Run it against a genuinely code-free repo and confirm that case is still allowed through, distinctly reported
