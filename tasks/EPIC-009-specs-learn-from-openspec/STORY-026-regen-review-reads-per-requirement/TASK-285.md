---
id: TASK-285
parent: STORY-026
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen`'s review lists changes per requirement, with renames shown FROM → TO

## Context

FEATURE-004 D2. `skills/specs/verbs/regen.md` step 4 shows the spec diff as a whole-file `git diff`. A renamed or reworded requirement then reads as a large change, which hides the question the review exists to answer. OpenSpec v1.11.0 added `show --diff`: a diff per requirement, with the full text of an added requirement, the reason for a removed one, and FROM/TO for a rename.

## Acceptance criteria

- [ ] Step 4 presents the diff per `### Requirement:` block, each classed as added, removed, renamed or changed, and shows only the changed lines of a changed one
- [ ] A rename is detected and shown FROM → TO, not as one removal plus one addition, and the verb states how a rename is recognised
- [ ] Each change is still classified (matches a decision, intended anyway, or unexplained), now per requirement
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Lost scenarios (TASK-286) and requirement length (TASK-287)

## Human test plan

- [ ] Drill: install the changed skill and run `/specs regen <area>` on a real area of this repo, or on a fixture spec staged to exercise the change. Record how the runner was obtained (AGENTS.md § Testing); a renamed and a reworded requirement are each shown as such

## Implementation plan

_Populated by `/tasks plan TASK-285` — leave empty until then._
