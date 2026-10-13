---
id: TASK-309
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-308-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks new`'s title, parent, priority and draft questions carry no question text and no answer-less path

## Context

Found by TASK-308's cold drill (2026-10-13). The runner, told nobody would answer, reported that
`skills/tasks/verbs/new.md` step 3 (*Ask the title*), step 4 (*Ask for parent*), step 5 (*Ask priority
and assignee*) and step 9 (*offer to draft body sections*) each describe a question without stating
it, and none says what the run does with no answer. It invented the wording and chose for itself each
time. That breaks AGENTS.md § Output/prose rules, *An ask-step carries the question it puts and the
answer-less path*. Step 4's new cancelled-parent question (TASK-308) already has both; the rest of the
step does not.

Unattended callers reach these steps: `spawn` from `close --unattended` step 5d, and `intake`.

## Acceptance criteria

- [ ] Steps 3, 4, 5 and 9 each state the exact question put
- [ ] Each states its answer-less outcome, and where the field must exist (title, parent, priority) a
      fallback written **with a record that nothing chose it**, per the convention's two shapes
- [ ] A step already pre-filled by a caller (`spawn`'s defaults, `--from-feature`, `intake`) says it
      asks nothing
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Ask-steps in other verbs (each is its own finding if a drill raises it)
- The cancelled-parent question (TASK-308)

## Human test plan

- [ ] A cold runner files a task with nobody to answer. Expected: it quotes each question verbatim
      from `new.md`, and the report names every value that was defaulted rather than chosen.

## Implementation plan

_Populated by `/tasks plan TASK-309` — leave empty until then._
