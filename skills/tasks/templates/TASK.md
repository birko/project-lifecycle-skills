---
id: {{ID}}
parent: {{PARENT}}
feature: {{FEATURE}}
status: {{STATUS}}  # todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
priority: {{PRIORITY}}
assignee: {{ASSIGNEE}}
created: {{CREATED}}
depends-on: []
blocks: []
pr: null
github-issue: null
jira-key: null
---

# {{TITLE}}

## Context

What this task does and why it exists. Include enough background that an AI agent or new contributor can pick this up without re-discovery — what code is involved, what constraints apply, what prior work this builds on.

## Acceptance criteria

- [ ] Concrete, verifiable done-when item
- [ ] Each item independently checkable
- [ ] Tests added/updated where applicable

## Out of scope

- Explicit non-goals
- Reference future TASK-NNN if scope was deferred (`/tasks spawn` writes these lines when work
  discovered mid-flight becomes its own task)

## Human test plan

_For behaviour that unit/AI tests can't fully cover (UI/UX, edge cases, system integrations, manual verification). A human or agent runs these steps at `/tasks close` time and when `/feature review` checks the feature._

- [ ] Step a tester can follow without re-discovery — exact action + expected result
- [ ] Edge case / boundary to exercise by hand
- [ ] Integration touchpoint to verify against the real external system

_Write `N/A — fully covered by automated tests` here if no manual testing is needed, so reviewers know it was a deliberate choice, not an omission._

## Implementation plan

_Populated by `/tasks plan {{ID}}` — leave empty until then._
