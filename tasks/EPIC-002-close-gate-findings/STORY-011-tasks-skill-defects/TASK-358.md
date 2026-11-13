---
id: TASK-358
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-348-1, DRILL-348-2]
pr: null
github-issue: null
jira-key: null
---

# The `tasks/README.md` dashboard template leaves two rendering details to the reader

## Context

Filed 2026-11-13 from TASK-348's two cold drills, `%LOCALAPPDATA%/Temp/d348` and `d348b`, with reports kept there.
Each ran `/tasks block` on a fresh copy of `d212/repo`, which chains `triage`. **Both runners raised these two**,
the agreement bar FEATURE-002 D10 sets. They were recorded on TASK-348 as one-runner readings before the two
reports were compared. Both are in `skills/tasks/verbs/triage.md` and its template `templates/README.md.tmpl`.

- **DRILL-348-1 — blank lines around an omitted section.** The template places `{{INREVIEW_SECTION}}`,
  `{{LOOSE_SECTION}}` and `{{COMPLETED_SECTION}}` between blank lines, and triage says "entire section omitted". It
  does not say whether the surrounding blank lines go too. Both runners collapsed them, each by its own reasoning.
- **DRILL-348-2 — tree rows and priority.** Step 3's in-progress bullet shows `(P1, ai)`, while step 4's tree
  example (`- [ ] TASK-003 Rate limit`) shows neither priority nor assignee. Both runners asked whether tree rows
  carry them, and both left them out by following the example.

## Acceptance criteria

- [ ] Triage states what happens to the blank lines around an omitted section
- [ ] Triage states which fields a tree row carries
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The bare `/tasks` snapshot's template: TASK-355 (done)
- Column padding after a placeholder fills, and the timestamp's time zone: one runner each (TASK-348's record)

## Human test plan

- [ ] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      neither DRILL-348-1 nor 2 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-358` — leave empty until then._
