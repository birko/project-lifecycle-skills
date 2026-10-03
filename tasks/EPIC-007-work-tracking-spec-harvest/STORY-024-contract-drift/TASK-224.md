---
id: TASK-224
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-1, SH-7]
pr: null
github-issue: null
jira-key: null
---

# Two restated lists of verbs have drifted from the verbs

## Context

Found by the work-tracking spec harvest (2026-10-03, EPIC-007). Same root cause twice: a list of verbs written
out by hand, which went wrong the moment a verb was added — the failure AGENTS.md § *Defer to a shared inventory*
names.

- **SH-1 — `--across` refusals.** `tasks/SKILL.md` says "Every other verb rejects it", calls that a blanket rule
  needing no list, and then lists eleven verbs — leaving out `plan`, `init`, `help` and `unblock`. Whether those
  four refuse depends on which half a reader follows.
- **SH-7 — who chains `triage`.** `triage.md` says it is chained by `new, pick, close, import, export,
  migrate`; `block`, `cancel`, `move`, `spawn`, `intake` and `audit --fix` chain it too.

## Acceptance criteria

- [ ] The `--across` rule is stated once as a blanket rule — every verb not named as accepting it refuses it — with
      no list that can go stale, and `pick` and `triage`'s own reasons kept
- [ ] `triage.md` says it is chained by every verb that changes the tree, without a list, or with one that is
      complete and pointed at rather than restated
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Adding a lint check for verb lists

## Human test plan

N/A — prose consistency, checked by reading every verb file against the two rules.

## Implementation plan

_Populated by `/tasks plan TASK-224` — leave empty until then._
