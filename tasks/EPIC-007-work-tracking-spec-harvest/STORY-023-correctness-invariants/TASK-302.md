---
id: TASK-302
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-300-1]
pr: null
github-issue: null
jira-key: null
---

# A Jira priority someone edits after export is lost on re-import, because the export label still wins

## Context

Found by the correctness pass at TASK-300's close (2026-10-12). `skills/tasks/verbs/import.md` step 3 (`--jira`) reads a `priority/P<n>` label before the priority field. TASK-300 made `export --to jira` set that field as well (`skills/tasks/verbs/export.md` step 5). The field is the value people in Jira see and edit. If a P3 task is exported with its field at Low and a PM then raises the field to Highest, a re-import still reads the stale `priority/P3` label, writes P3 and says nothing. The PM's change is gone.

This was already possible before TASK-300, when the field held only the project's default: a PM who changed it was overruled the same way. TASK-300 makes it likelier, because the field now shows a real value that invites editing. TASK-300's criteria kept import's label-first rule unchanged on purpose, so the precedence question is this task's.

## Acceptance criteria

- [ ] `import --jira` states what it does when the label and the field disagree, read through export's inverse mapping (`export.md` step 5): which one wins, and that the disagreement is reported in step 7's confirmation, never resolved silently
- [ ] The rule keeps TASK-299's round trip: a ticket whose field is the project default, or was never set by export, still imports with the label's value
- [ ] `docs/specs/work-tracking.md` is respecced for *Importing work*
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Export's mapping itself (TASK-300)
- Case-insensitive matching of Jira priority names: neither verb defines it, and no drill has met a project whose names differ only in case

## Human test plan

N/A unless the rule changes behaviour beyond reporting; then a cold reader given `import.md` and a label/field disagreement replaces this line.

## Implementation plan

_Populated by `/tasks plan TASK-302` — leave empty until then._
