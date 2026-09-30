---
id: TASK-202
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: tracker sync maps the blocked flag to a GitHub label and Jira's Flagged field

## Context

A migrate batch of FEATURE-003 (owner group: the hybrid-mode verbs `export`, `import`, `migrate` and the
remote step of `close`/`cancel`). D8: the flag maps to the GitHub label `blocked` or Jira's "Flagged" field,
the reason travels as a comment, and the issue's open/closed state does not change, because a blocked
task is still open.

## Acceptance criteria

- [ ] Exporting a flagged task adds the tracker's marker and a comment carrying the reason; removing the flag removes the marker
- [ ] Importing an issue carrying the marker writes the `blocked:` field with the comment's reason, or `reason unknown` when there is none
- [ ] No verb changes a remote issue's open/closed state because of the flag
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Jira transitions or custom workflows beyond the Flagged field

## Human test plan

- [ ] On a throwaway GitHub repo: export a flagged task, check that the label and comment appear, unflag it, and check the label is removed.
