---
id: TASK-241
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-48, SH-49, SH-50]
pr: null
github-issue: null
jira-key: null
---

# Three stale words in `feature`: a count, a citation and a list of forms

## Context

Found by the feature-lifecycle spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). Each is a phrase that
no longer matches what it describes.

- **SH-48.** `skills/feature/SKILL.md` § *The feature list is a living artifact* says "Two standing obligations" and
  lists three (Completeness, Currency, Keep the companion docs in sync).
- **SH-49.** `verbs/pick.md`, edge case *Feature is `done`*, cites "per SKILL.md" for the rule that a change to a
  human-verifiable surface sends the implementing task back to `verify`. That rule lives in `verbs/decide.md`
  § *Changing a closed feature*, and `SKILL.md` does not carry it.
- **SH-50.** `verbs/help.md`'s `prototype` line lists "HTML / wireframe / spike". It is missing the fourth form, the
  state-model playground, which TASK-124 (at `verify`) added to `prototype.md` without updating the help table.

## Acceptance criteria

- [ ] The count matches the list
- [ ] `pick.md` cites `decide.md` § *Changing a closed feature*
- [ ] `help.md` names all four prototype forms
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other content of TASK-124

## Human test plan

N/A — three wording fixes, checked by following each to its target.

## Implementation plan

_Populated by `/tasks plan TASK-241` — leave empty until then._
