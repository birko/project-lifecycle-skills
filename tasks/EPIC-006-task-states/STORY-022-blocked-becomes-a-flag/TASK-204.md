---
id: TASK-204
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-197, TASK-198, TASK-199, TASK-200, TASK-201, TASK-202, TASK-203, TASK-196]
blocks: [TASK-205]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Contract: every writer switches to the new form

## Context

The contract phase of FEATURE-003: it depends on every batch. Before this, nothing writes the new form.
After it, nothing writes the old one, while every reader keeps the permanent legacy reading (the
alias is not removed, because copies in consumer repos are out of reach).

The behaviour decisions land here, because they live in the writers: D2 (unblock keeps the state),
D3 (a deferred merge is `in-progress` + `blocked: merge deferred`), D6 and D7 (`pick` offers a flagged
task with a warning and asks *"Unblock and start?"* when it is chosen).

## Acceptance criteria

- [ ] `block` writes the `blocked:` field and leaves `status:` alone; `unblock` removes the field and leaves `status:` alone (D2)
- [ ] `close` writes `verify` instead of `review`, and a deferred merge is `in-progress` + `blocked: merge deferred` (D3); "done means merged" still holds
- [ ] `pick` lists a flagged task with its reason (D6), and choosing it puts *"TASK-NNN is blocked: <reason>. Unblock and start?"*, with the answer-less path stated (D7)
- [ ] The TASK template's status comment lists the new vocabulary and the `blocked:` field
- [ ] `git grep` for code that writes `status: blocked` or `status: review` in `skills/` finds none. The legacy readers remain
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Rewriting existing files: TASK-203 and TASK-205

## Human test plan

- [ ] Cold drill through a real task: pick → block → unblock → close with a manual step pending. The file never reads `blocked` or `review`, and the task returns to the state it had after unblocking.
