---
id: TASK-278
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-113, SH-114, SH-115]
pr: null
github-issue: null
jira-key: null
---

# Lint check 1 passes descriptions pi will not load, and AGENTS.md overclaims checks 1 and 4

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-113:** `.github/workflows/skills-lint.sh:75-83`: `description:` and `description: ""` both pass check 1. pi's own `yaml` package parses them to null and "", which pi rejects (`description is required`; the skill is not loaded). AGENTS.md's table says check 1 enforces "present and not empty".
- **SH-114:** `:77-81` only looks for `: ` and ` #`. pi's parser throws on a description ending `Use when:` ("Nested mappings are not allowed") and on one starting with `*` or `[` ("Unexpected scalar"), and all three pass the lint. Same outcome as the `: ` row: the skill is not loaded.
- **SH-115 (partly confirmed, wording only):** check 4 stops at a bare lowercase word, so a later flag in `/beta go --real value --nosuch` is unchecked. That is the documented ARG_RE trade-off and no real invocation hits it, but AGENTS.md:331's "every flag on the invocation" claims more than the check does.

## Acceptance criteria

- [ ] Check 1 fails an empty description, a description ending in `:`, and a description starting with a YAML indicator character, each with a test case in `skills-lint-test.sh` that fails without the change
- [ ] AGENTS.md's description of check 4 matches what it checks
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Test cases for the lint's other untested branches (TASK-029)

## Human test plan

N/A: covered by the new test cases, which must fail without the change (AGENTS.md § Testing).

## Implementation plan

_Populated by `/tasks plan TASK-278` — leave empty until then._
