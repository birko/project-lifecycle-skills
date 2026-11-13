---
id: TASK-360
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-072-1]
pr: null
github-issue: null
jira-key: null
---

# Adoption's one round can need more than five questions, and one of them depends on another's answer

## Context

Filed 2026-11-13 from TASK-072's drill C (`%LOCALAPPDATA%/Temp/d072/c`, `report.md`, point 6). The same dependency
was raised by TASK-353's drill (`%LOCALAPPDATA%/Temp/d353`, point 2), which makes **two runners**, FEATURE-002 D10's
bar.

TASK-102 put every fill offer into step 2's round as one item, so the fills never crowd out an inference or a
declaration. It assumed the declarations themselves fit in grill-me's "**At most five questions in a round.**" A
first adoption of a repo with no task tree, no guide and no licence evidence does not fit:
- task mode;
- integration model;
- task workspace;
- canonical guide file;
- licence posture;
- the fill item.

That is six, before any `unknown` row's question. **And the workspace question depends on another answer in the
same round:** `tasks init` skips it "when the integration model is already `single-branch`", so it is not on the
first frontier until integration is answered. One runner listed all six; the other added a conditional note.

## Acceptance criteria

- [ ] `adopt-project` step 2 states what happens when the round's questions exceed grill-me's five. Options include
      exempting the declaration round from the cap with a reason, ordering and deferring the rest, or merging
      dependent questions. Whatever is chosen does not reintroduce a second round, or states why one is accepted
- [ ] A question that depends on another answer in the same round has a stated form. One way: put the workspace
      question conditionally ("if you chose pr-per-task: …"), and with no answer to integration, workspace is not
      asked
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where fill offers go: TASK-102 (done)
- Wording of the licence and guide-choice questions: TASK-356

## Human test plan

- [ ] Run a cold full adoption of a repo with no `tasks/`, no guide and no licence evidence (`%LOCALAPPDATA%/Temp/d072/c/dotnetrepo`
      is one). Expected: the run states how it handled more than five questions and the workspace dependency, and
      neither is in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-360` — leave empty until then._
