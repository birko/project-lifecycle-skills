---
id: TASK-173
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: ai
created: 2026-09-24
depends-on: []
blocks: [TASK-174, TASK-177, TASK-178]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Declare `workspace:` and `worktree-root:` in the tasks config

## Context

FEATURE-001 D2 and D5. Where a task's work happens gets its **own** declaration, separate from
`integration:` (which answers how work *lands*): `workspace: in-place | worktree`. Where worktrees
live is a second declaration, `worktree-root:`, because nothing in a repository determines it — the
same reasoning `siblings.root` already carries in `skills/tasks/templates/config.yml`.

Both are declarations, so both follow AGENTS.md § *A template ships nothing a render cannot make
true*: the template ships them **commented out**, carrying a choice (`<in-place|worktree>`) and never
a value, and the line's absence means undeclared. Absent `workspace:` means `in-place` — today's
behaviour, unchanged. `/tasks init` reconciles an older config by adding the commented block, never by
filling a value (`skills/tasks/verbs/init.md` step 3).

D2's rationale names one incoherent pair: `integration: single-branch` with `workspace: worktree`
(there is no task branch to put in a worktree). What the verbs *do* with that pair is not decided
yet — settle it in the plan and record it with `/feature decide FEATURE-001`, since it is observable
behaviour.

## Acceptance criteria

- [ ] `skills/tasks/templates/config.yml` carries a commented `workspace:` and `worktree-root:` block, each saying what absence means, in the style of the `integration:` and `siblings:` blocks.
- [ ] `skills/tasks/verbs/init.md` reconciles a config lacking the block (adds it commented, never a live value) and reports it as **brought up to date**.
- [ ] `skills/tasks/SKILL.md` names the two fields next to *Declare the integration model, don't infer it*, and states that `workspace:` is read, never inferred from whether worktrees happen to exist (`git worktree list`).
- [ ] The `single-branch` + `worktree` pair has a defined behaviour, recorded as a new decision row on FEATURE-001.
- [ ] AGENTS.md § Conventions records the new cross-cutting declaration (register-on-introduce), as a pointer where the skill owns the detail.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- What `pick` does with the fields — TASK-174, TASK-175.
- Front-door parity (`new-project`, `adopt-project`, `LAYER.md`) — TASK-177.

## Human test plan

- [ ] On a scratch copy of a consumer repo whose `tasks/.config.yml` predates the fields, run `/tasks init`. Expected: the commented block is added, no live `workspace:` or `worktree-root:` key appears, and the report says *brought up to date* naming both.
- [ ] Re-run it. Expected: *already current*, file unchanged.

## Implementation plan

_Populated by `/tasks plan TASK-173` — leave empty until then._
