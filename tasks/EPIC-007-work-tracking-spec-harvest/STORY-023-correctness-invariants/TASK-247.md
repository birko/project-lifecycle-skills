---
id: TASK-247
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-76]
pr: null
github-issue: null
jira-key: null
---

# The review axes ask the user things with no question text and no unanswered path

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. AGENTS.md § Output/prose rules requires an ask-step to carry the question it
actually puts, and what the run does when no answer comes. Two kinds of ask-step in the change-review skills carry
neither:

- **No intent source.** `skills/verify-intent/SKILL.md`'s intent table says "Nothing, and no task in flight → ask
  the user what the change was meant to do, in one line". `close.md` says that branch cannot fire inside `close`, but
  that leaves standalone and `/fix-next` runs uncovered.
- **Not git-tracked.** "Not git-tracked → ask which files to judge" appears in `verify-intent` step 1,
  `verify-conventions` step 1, `review-comments` step 2 and `skills-pi/code-review` step 1.

## Acceptance criteria

- [ ] Each ask-step quotes the question it puts
- [ ] Each states its answer-less outcome as a reported unresolved state (e.g. "no intent source — nothing judged"), never a guessed scope
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Other skills' ask-steps

## Human test plan

- [ ] Run `/verify-intent` from a cold runner in a folder that is not a git repo, with no task in flight, and say nothing. Expected: the run reports the unresolved state rather than choosing files or an intent

## Implementation plan

_Populated by `/tasks plan TASK-247` — leave empty until then._
