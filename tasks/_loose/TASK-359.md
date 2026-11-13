---
id: TASK-359
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

# Regenerate the `test-authoring` spec, two commits behind its sources

## Context

Found at TASK-354's close (2026-11-13). `docs/specs/test-authoring.md` is stamped `generated-at: 222c36d`
(2026-10-12). Since then two commits changed the files it covers (`skills/populate-tests/**`, `skills/tdd/**`)
without a regen:
- 812b262 TASK-271;
- 6873992 TASK-283.

TASK-354 made one surgical edit to it and left the stamp alone on purpose, because a new stamp would claim a
currency nobody checked. So the spec may describe behaviour those two commits changed.

**Loose on purpose.** This is tree maintenance, not a review finding. Filing it into an intake epic would make that
pool misreport how much of a review is left (`AGENTS.md` § Working rules, *A task outside a pool*).

## Acceptance criteria

- [ ] `/specs regen test-authoring` has run, and its diff has been reviewed as "was this change intended?". Each
      requirement it changes is traced to TASK-271, TASK-283 or TASK-354, and anything else is spawned as a finding
- [ ] The spec's `generated-at` names the commit it was regenerated at
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing `populate-tests` or `tdd` themselves. A spec diff that shows a defect is spawned, not fixed here

## Human test plan

N/A — the regen's own diff review is the check, and it runs inside the task.

## Implementation plan

_Populated by `/tasks plan TASK-359` — leave empty until then._
