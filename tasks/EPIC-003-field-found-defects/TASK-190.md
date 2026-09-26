---
id: TASK-190
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: unassigned
created: 2026-09-26
depends-on: []
blocks: []
findings: [FIELD-004]
pr: null
github-issue: null
jira-key: null
---

# pi refuses six skills: descriptions that are invalid YAML or over 1024 characters

## Context

Reported from real use on 2026-09-26: pi's loader prints `[Skill conflicts]` for six skills.

| Skill | pi's error | Cause |
|---|---|---|
| `adopt-project`, `fix-next`, `verify-intent` | `Nested mappings are not allowed in compact mappings` | unquoted `description:` contains `: ` — a plain YAML scalar cannot |
| `new-project` (1105), `review-comments` (1209), `verify-conventions` (1534) | `description exceeds 1024 characters` | the Agent Skills limit on `description` |

Also found while measuring: `skills-pi/review`'s description contains ` #N`, which YAML reads as the
start of a comment — the description is silently truncated there. No error, so pi did not report it.

The lint never parsed the frontmatter as YAML; check 1 only greps for `^description:`. So all
seven passed CI.

## Acceptance criteria

- [ ] Check 1 fails on an unquoted single-line `description:` containing `: ` or ` #`, and on a description over 1024 characters.
- [ ] Test cases in `skills-lint-test.sh` fail without the new checks.
- [ ] All seven descriptions fixed; trigger phrases kept (the long three trimmed, not stripped of triggers).
- [ ] `bash .github/workflows/skills-lint.sh` and the test suite pass.

## Human test plan

- [ ] Start pi (`pi --provider finstat --model finstat`) and confirm `[Skill conflicts]` no longer lists any of the six skills.
