---
id: TASK-345
parent: STORY-014
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: [TASK-128]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-128-1]
pr: null
github-issue: null
jira-key: null
---

# `/specs init` stamps a repo with no code `unverified` because nobody blessed its empty map

## Context

Found by TASK-128's drill (2026-11-05, recorded on TASK-128, fixture `%LOCALAPPDATA%/Temp/d128z`).

**DRILL-128-1.** A repo whose five tracked files are all non-source (README, docs, `Makefile`, `pyproject.toml`, a
deploy script) wrote `areas: []` and `coverage: unverified # areas proposed but never blessed`.
`skills/specs/verbs/init.md` step 4's verdict table gives `not-applicable` for an empty scan set in a repo
with no behavioural code, and asks for no blessing; blessing is a precondition of `verified` only. But step 6
writes "the areas as § *Blessing* left them — blessed, or written unblessed and stamped `unverified`". That
applies to every map, so it overrides the table even when there are no areas to bless.

**A regression.** TASK-089's docs-only fixture reached `not-applicable` before the blessing rule (TASK-127)
existed. The runner also asked whether the scan set is measured before or after `ignore`, which the
`not-applicable` row needs.

## Acceptance criteria

- [ ] A map with no areas in a repo with no behavioural code is written `not-applicable` with no blessing asked, and step 6 says so
- [ ] The `not-applicable` row says whether its empty scan set is measured after `ignore`
- [ ] `verified` still requires blessing
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- When step 4's reconciliation "needs the user" — TASK-127

## Human test plan

- [ ] Re-run TASK-128's `d128z` drill (brief on its Progress log) with a cold runner. Expected: `coverage: not-applicable`, no blessing question. Then re-run TASK-128's last test-plan step and close it

## Implementation plan

_Populated by `/tasks plan TASK-345` — leave empty until then._
