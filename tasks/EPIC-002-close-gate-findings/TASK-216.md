---
id: TASK-216
parent: EPIC-002
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
findings: [VC-059, VC-060]
pr: null
github-issue: null
jira-key: null
---

# Two cross-skill rules in use are missing from AGENTS.md § Conventions

## Context

Found by the register-on-introduce confirmation in `/feature review FEATURE-003` (2026-10-03). AGENTS.md
§ *Keeping conventions current* says a new cross-skill protocol is recorded in § Conventions in the same change.
Two are not:

- **VC-059 — readers accept both forms of a renamed value permanently; only writers switch.** Applied by
  FEATURE-003 across 5 skills and 14 files (`tasks`, `feature`, `fix-next`, `roadmap`, `specs`). The doctrine
  predates the feature (`skills/tasks/slicing.md` § *Wide refactors*), and the forms are tabled once in
  `skills/tasks/SKILL.md` § Lifecycle → *Reading a task's status* — but § Conventions names neither, so a
  future rename has no standing rule to follow.
- **VC-060 — every `^id:` pattern ends `[[:space:]]*$`, never a bare `$`.** Introduced by TASK-206 and
  enforced by lint check 7 (four cases in `skills-lint-test.sh`). § Conventions mentions checks 1, 4, 5 and 6
  and not 7, and § Testing's description of the lint still lists only frontmatter, links and referenced files.

## Acceptance criteria

- [ ] § Conventions has a one-line-plus-reason entry for each rule, each a **pointer** to its owner
      (`slicing.md` § *Wide refactors* and `tasks/SKILL.md` § *Reading a task's status*; `tasks/SKILL.md`
      § *ID generation*), not a second copy
- [ ] § Testing's description of what the lint checks names check 7
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Moving the anchored `^status:` read, now restated in `specs` regen and `init` 3b, to a single owner — a
  separate refactor if wanted

## Human test plan

N/A — rulebook text, checked by reading; `/verify-conventions` reads it on every later change.

## Implementation plan

_Populated by `/tasks plan TASK-216` — leave empty until then._
