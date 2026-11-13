---
id: TASK-372
parent: null
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
findings: []
pr: null
github-issue: null
jira-key: null
---

# Respec four spec areas whose sources changed without a respec

## Context

Found 2026-11-13 at TASK-067's close, by counting, for each spec area, the source commits since its `generated-at`
that did **not** also change the spec:

| Area | Unspecced source commit |
|---|---|
| `feature-lifecycle` | af904eb (TASK-366: `/feature status` takes `triage`'s timestamp form) |
| `specs-from-code` | eaefe24 (TASK-210: `verify` and `regen` examples renamed to invented paths) |
| `idea-interrogation` | 1648d29 (TASK-260: `grill-me`'s description) |
| `glossary-and-adrs` | be3e932 (TASK-275: `domain`'s scope pointer and record history) |

`test-authoring` is the fifth, and is TASK-359's.

Some of these changes are wording the spec may not state at all, so the regen may produce no diff. That is a valid
outcome, and it moves the stamp honestly.

**Loose on purpose:** tree maintenance, not a review finding (`AGENTS.md` § Working rules, *A task outside a pool*).

## Acceptance criteria

- [ ] `/specs regen` has run for each of the four areas, each diff reviewed as "was this change intended?", and each
      stamp names the commit it was regenerated at
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `test-authoring`: TASK-359
- DV7's baseline disagreement: TASK-371

## Human test plan

N/A — the regen's own diff review is the check.

## Implementation plan

_Populated by `/tasks plan TASK-372` — leave empty until then._
