---
id: TASK-346
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-255-1, DRILL-255-2, DRILL-255-3, DRILL-255-4]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick`'s choice question has no answer-less path, and three more readings are left open

## Context

Raised by TASK-255's drill (2026-11-05, recorded on TASK-255), in `skills/tasks/verbs/pick.md`:

- **DRILL-255-1:** step 4 says only "Ask user to pick by number (or accept a TASK-NNN ID directly)". It has no
  question text and no answer-less path, against AGENTS.md's ask-step rule.
- **DRILL-255-2:** "With an upstream, fetch first (`git fetch --prune <remote>`), as 6b does" sits in the
  bullet for a named task, so whether a bare pick fetches before building the list (and its `taken (hidden)`
  line) reads two ways.
- **DRILL-255-3:** step 6's plan prompt has "the default set to yes", which leaves open whether silence takes
  the default and hands off to plan.md, or does nothing.
- **DRILL-255-4:** on the worktree path, 6b's "Match → print the in-a-worktree line and go to step 9" skips
  step 7, while 9b's contract table says step 7's `pr:` question is "asked here, before the offer".

## Acceptance criteria

- [ ] Step 4 states its question and what happens with no answer
- [ ] Whether a bare pick fetches before building the list is stated once
- [ ] Step 6's plan prompt states its no-answer outcome
- [ ] The worktree path and 9b's table agree on whether, and where, the `pr:` question is put
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The five readings TASK-255 settled

## Human test plan

- [ ] Re-run TASK-255's brief (on its Progress log) on a freshly built `d255` fixture with a cold runner. Expected: none of the four in its "left open" section

## Implementation plan

_Populated by `/tasks plan TASK-346` — leave empty until then._
