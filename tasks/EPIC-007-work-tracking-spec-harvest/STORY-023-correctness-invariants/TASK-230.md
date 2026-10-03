---
id: TASK-230
parent: STORY-023
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
findings: [SH-39]
pr: null
github-issue: null
jira-key: null
---

# `/specs regen`'s two ask-steps carry no question and no answer-less path

## Context

Found by the specs-from-code spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b). AGENTS.md § Output /
prose rules requires an ask-step to state its question and its unattended outcome. `regen` is chained from
`/tasks close` at story close and from `/fix-next` step 7, and both can run with nobody present.

- **SH-39.** `skills/specs/verbs/regen.md`:
  - Args, `--story`: "Missing references → fall back to asking which areas". No question, and no outcome when nobody
    answers;
  - step 4, **Intended anyway**: "user confirms it's expected". No question, and no path for an unattended run, where
    the only other classes are *matches an approved decision* and *unexplained*.

## Acceptance criteria

- [ ] Each site states the question actually put and its unattended outcome as a reported unresolved state (for
      step 4, for example: classify as unexplained and say nobody confirmed it), never an area list or a confirmation
      the run supplied itself
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `/specs init`'s questions (TASK-128, and the DRILL-109 record in AGENTS.md)
- The other specs findings from this pass — TASK-238, TASK-239

## Human test plan

N/A — two prose edits, checked against the AGENTS.md rule by reading both halves at each site.

## Implementation plan

_Populated by `/tasks plan TASK-230` — leave empty until then._
