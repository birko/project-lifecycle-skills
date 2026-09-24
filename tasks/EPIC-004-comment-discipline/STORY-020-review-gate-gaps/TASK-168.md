---
id: TASK-168
parent: STORY-020
feature: FEATURE-002
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-24
depends-on: []
blocks: []
findings: [VC-F002-1]
pr: null
github-issue: null
jira-key: null
---

# `review-comments` shipped, and nothing that lists the skills mentions it

## Context

Found by `/feature review FEATURE-002` Gate A (standards, register-on-introduce), 2026-09-24. The skill
folder exists, is linked into both runtimes (lint check 6 in sync), and is invoked by `/tasks close` — yet
a reader looking for it in any overview finds nothing:

| Site | Missing |
|---|---|
| `AGENTS.md` § Naming — *"Verb-noun for action skills (…)"* | `review-comments` (the list has `verify-intent`, the last axis skill added) |
| `README.md:1` title line | the skill |
| `README.md` close-gate diagram (`/tasks close ────┬─ code-review …`) | a `review-comments` branch |
| `README.md` — *"`code-review` asks … · `verify-conventions` asks … · `verify-intent` asks … — three questions"* | the fourth question |
| `docs/architecture.md` skill map — *"verify-conventions + code-review (the merge gate)"* | the merge gate's other axes |

## Acceptance criteria

- [ ] `AGENTS.md`'s verb-noun list includes `review-comments`.
- [ ] `README.md`'s close-gate diagram carries a `review-comments` branch, marked conditional (the diff carries a comment), and the questions line names what it asks — with no hard count that rots on the next axis.
- [ ] `docs/architecture.md`'s skill map shows the merge gate's axes, including `review-comments`.
- [ ] The README title line is reconciled — either lists it, or is not presented as the skill list (its current set is already partial).
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- `CHANGELOG.md` — `/roll-changelog`, offered at FEATURE-002's review.
- `docs/architecture.md`'s "check 4" for install-root drift — **TASK-171** (predates this feature).

## Human test plan

N/A — registration in overview documents: each criterion is a presence check a reviewer confirms by reading the sites, and the lint confirms links resolve. No behaviour to exercise.

## Implementation plan

_Populated by `/tasks plan TASK-168` — leave empty until then._
