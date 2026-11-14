---
id: TASK-377
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-375-6]
pr: null
github-issue: null
jira-key: null
---

# No verb moves a `planned` story or epic to `in-progress` when its first child starts

## Context

Found 2026-11-14 while fixing TASK-375. `SKILL.md` § *Roll status up to parents* rolls a parent up when its children
finish and reopens it when one leaves `done`, but nothing moves a `planned` container to `in-progress` when a child
starts: `pick` sets the task alone, and no other verb touches the parent. So a story can read `planned` with most of
its tasks done. This repo's STORY-024 reads `planned` at 17 of 21.

Two cold `triage` runners flagged STORY-024 on their own (`%LOCALAPPDATA%/Temp/d368` `report-run1.md` point 3 and
`report-run2.md` point 2), and TASK-375's step 4b now reports the case with no verb to fix it. Hand-editing the
status is the defect `AGENTS.md` § Working rules forbids, so the report can only be cleared by a verb that does not
exist yet.

## Acceptance criteria

- [ ] The verb that moves a task out of `todo` (`pick`, and any other that does) moves its `planned` parent story to
      `in-progress`, and the epic above it the same way, reporting each move in one line
- [ ] `SKILL.md` § *Roll status up to parents* states the starting direction beside the other two
- [ ] `triage.md` step 4b's `planned` row names that verb as its fix
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Backfilling this repo's `planned` containers that already have started children: run the fixed verb's rule once,
  through whatever the fix provides

## Human test plan

- [ ] On a fixture with a `planned` story and a `todo` task under it, run `/tasks pick` on that task with a cold
      runner. Expected: the story and its epic read `in-progress`, and the run says so
