---
id: TASK-203
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204, TASK-205]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: a one-time migration that rewrites old-form task files

## Context

A migrate batch of FEATURE-003 (owner group: `skills/tasks/`, the migration tool). D5: existing files are
rewritten once. `review` becomes `verify`. A `blocked` task becomes its **prior state** plus
`blocked: <reason>`, and the prior state is read from the file's git history: the last `status:` value
before `blocked`. It asks only where the history cannot tell (no git, or the file was created blocked).
The reason comes from the task's own `> Blocked <date> — <reason>` note when there is one.

**Design question this task settles, not assumes:** which verb owns the migration. The candidates are
`/tasks audit --fix`, which already applies safe fixes, and `/tasks init`'s reconcile path, which
already upgrades an older tree in place. Per AGENTS.md, an owner verb reconciles an older instance and
reports *already current* distinctly from *brought up to date*.

## Acceptance criteria

- [ ] The owning verb is chosen and the reason recorded
- [ ] `review` → `verify` and `blocked` → prior state + `blocked:` field, with the prior state read from `git log -p` of the file, never guessed
- [ ] An undeterminable prior state is asked with a stated question and an answer-less path (AGENTS.md § *An ask-step carries the question*)
- [ ] The run reports per file: already current, brought up to date, or asked. A re-run on a migrated tree changes nothing
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Running it on the consumer repos: TASK-205

## Human test plan

- [ ] Run it on a throwaway copy of a consumer repo holding real `blocked` tasks (DraCode has 24): every prior state matches the file history, and a second run reports all files already current.
