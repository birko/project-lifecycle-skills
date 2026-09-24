---
id: TASK-171
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: agent
created: 2026-09-24
depends-on: []
blocks: []
findings: [VC-F002-2]
pr: null
github-issue: null
jira-key: null
---

# `docs/architecture.md` still calls install-root drift "check 4"

## Context

Found in passing by `/feature review FEATURE-002` Gate A, 2026-09-24 — **not a FEATURE-002 defect**, hence
`feature: null` and filed with the lint's other integrity work. `docs/architecture.md:15` says
*"`skills-lint.sh`'s check 4 compares both…"* about install-root drift; the lint prints it as **check 6**.
It went stale when check 4 (cross-skill flags) was inserted, and again when TASK-146 inserted check 5.
TASK-081 fixed `AGENTS.md` for the same renumbering — by naming the check — and never touched this file.

## Acceptance criteria

- [x] `docs/architecture.md` refers to the install-roots check by **name**, as TASK-081 did in `AGENTS.md` — a number is what went stale twice.
- [x] No other ordinal reference to a lint check in `docs/` is wrong (`grep -n "check [0-9]" docs/`).

## Out of scope

- `AGENTS.md` — done by TASK-081.

## Human test plan

N/A — a wording fix; criterion 2's grep is the check, and there is no behaviour to exercise.

## Implementation plan

Name the check, as TASK-081 did.

**Outcome (2026-09-24).** `docs/architecture.md` now says *"`skills-lint.sh`'s install-roots check"*. The
only other ordinal in `docs/` — *"`skills-lint` (check 3)"* — was correct (check 3 is file references) and
was converted to *"the file-references check"* anyway, for the reason this task exists. `grep -n "check
[0-9]" docs/` (ledgers aside, which record history) now returns nothing. **Gate, inline:** two words of
prose; lint unaffected.
