---
id: TASK-343
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-340-1, DRILL-340-2, DRILL-340-3]
pr: null
github-issue: null
jira-key: null
---

# `/tasks new` leaves the shortened body question, a quoted description, and the FIELD-NNN scan to the reader

## Context

Raised by TASK-340's drill (2026-11-05, recorded on TASK-340), in `skills/tasks/verbs/new.md`:

- **DRILL-340-1:** step 9 says sections a step-0 flag already drafts "are not offered", but the question names all four sections and no shortened wording is given. The runner trimmed it by its own choice, so the ask-step's text differs per run.
- **DRILL-340-2:** § *Unanswered questions* counts "a title in quotes" as stated. A request that quotes a sentence describing the defect, not a title, reads both ways.
- **DRILL-340-3:** the `FIELD-NNN` mint takes "the current max over every `findings:` list" but gives no search pattern, unlike the `^id:` scan, so two runs may scan differently.

## Acceptance criteria

- [ ] Step 9's question is stated for the case where some sections are already drafted
- [ ] § *Unanswered questions* says when quoted text counts as a stated title
- [ ] The `FIELD-NNN` max scan names its pattern
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run TASK-340's drill brief (on its Progress log) with a cold runner. Expected: none of the three in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-343` — leave empty until then._
