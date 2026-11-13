---
id: TASK-365
parent: STORY-016
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
findings: [DRILL-364-1, DRILL-364-2, DRILL-364-3, DRILL-364-4]
pr: null
github-issue: null
jira-key: null
---

# Four more adoption readings that a second cold runner has now raised

## Context

Filed 2026-11-13 at TASK-364's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d364`, `report.md`, § 7) against
d362 and d363. Each meets FEATURE-002 D10's two-runner bar. **Filed, not worked**: the user agreed TASK-364 would end
the session's run of `adopt-project` fixes. These are small wording gaps, and a later batch is cheaper than chasing
them one drill at a time.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-364-1 | `present — <verb> answers in step 3` covers present rows only. A **missing** row whose owner verb will create it (`docs/specs/.map.yml` → `/specs init`) has no stated table form | d362, d364 |
| DRILL-364-2 | `tracked-files-at-scan` and the three dotfiles `specs` skips "without being named" (`.gitignore`, `.gitattributes`, `.editorconfig`): whether they count in the tree size | d363, d364 |
| DRILL-364-3 | two wordings for one fact: `/tasks init` reports *workspace undeclared — tasks work in place*, while `adopt-project` adds `(not asked: single-branch)`. Runners printed one, or both | d363, d364 |
| DRILL-364-4 | `/tasks init`'s "every field the template declares": whether the template's header comment lines, and the `# local \| hybrid` comment on `mode:`, are "fields" to add | d363, d364 |

## Acceptance criteria

- [ ] DRILL-364-1 … 4 each have one stated answer, in the file that owns the rule (`adopt-project`, `specs`
      SKILL.md, `tasks` `init`)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Everything TASK-356, 357 and 361 to 364 settled

## Human test plan

- [ ] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-364-1 … 4 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-365` — leave empty until then._
