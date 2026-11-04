---
id: TASK-339
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-325-1, DRILL-325-2, DRILL-325-3, DRILL-325-4]
pr: null
github-issue: null
jira-key: null
---

# `/tasks intake --epic` leaves story reuse, the epic update, titles and group priority to the reader

## Context

Found by TASK-325's two drill runs (2026-11-04, recorded on TASK-325). Both runners raised 1, 2 and 4
independently, in `skills/tasks/verbs/intake.md`:

- **DRILL-325-1:** under `--epic`, step 5 says "STORY per theme" and "chain new.md (`epic`) … write the pass into
  `## Area of concern`", but not whether an existing story with the same `theme:` is reused, nor what happens
  to the existing epic's `source:` and Area of concern. The only sentence near it ("A list is fine when a second
  pass is adopted") is about `--adopt`. Both runners reused the story and appended to the epic, by guessing.
- **DRILL-325-2:** intake chains `new` without a title or assignee, so `new` asks both questions per task and
  every task intake files carries `> Filed with nobody to answer — inferred, not chosen: title, assignee, body
  sections`. Yet a title derived from the finding is intake's own rule-set output, not a guess. This is the
  same family as TASK-331's DRILL-318-1, which covers a value the user stated, but this case is a calling verb's.
- **DRILL-325-3:** "Priority from severity" covers one severity per task, not a group holding a blocker and a
  warning.
- **DRILL-325-4:** step 8's report relays reopen and `record/` lines. SKILL.md also says "the verb's confirmation
  names the unreadable copies", and step 8 does not mention that line. Both runners added it by their own choice.

## Acceptance criteria

- [ ] Step 5 states, for `--epic`, whether a story with a matching `theme:` is reused and how the epic's `source:` and Area of concern are updated
- [ ] Intake passes a title (and the assignee) to `new`, so a filed task's inferred-values line names only what intake did not set
- [ ] The priority of a mixed-severity group is stated
- [ ] Step 8 relays the unreadable-copies line, or says why not
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The record-line relay itself, which TASK-325 fixed and its drill passed

## Human test plan

- [ ] Re-run TASK-325's second drill brief (on its Progress log) on a freshly built `d325b` fixture with a cold runner. Expected: none of the four appears in its "left open" section

## Implementation plan

_Populated by `/tasks plan TASK-339` — leave empty until then._
