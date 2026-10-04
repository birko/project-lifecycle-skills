---
id: TASK-248
parent: STORY-024
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
findings: [SH-57, SH-58, SH-59, SH-60, SH-61]
pr: null
github-issue: null
jira-key: null
---

# The seed templates describe a project that `new-project` does not build

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`. All five are in `skills/new-project/templates/`, the text every scaffolded
repo receives, and would be fixed in one pass over those files.

- **SH-57 — README.seed.md** says "`/feature review` gates on code review + manual-test verification + stakeholder
  sign-off". `CLAUDE.seed.md`, `CONVENTIONS-universal.md` and `feature/verbs/review.md` all say it is a
  completeness check, not a code re-review.
- **SH-58 — CLAUDE.seed.md's UI/UX comment** says "Delete this subsection for headless/library/CLI projects".
  - `new-project` step 3 deletes the subsection only for kinds with no human-facing surface. A CLI/TUI keeps it,
    retitled **Output / UX rules**.
  - The comment ships into the consumer's guide, so a kept subsection tells its reader to delete it.
- **SH-59 — CLAUDE.seed.md's Code structure comment** says "in step with ## Architecture below", but `## Architecture`
  is above it.
- **SH-60 — CLAUDE.seed.md § Testing** is untokened, so it is copied verbatim. It says "Automated tests live in
  `tests/`". But the scaffolder seeds Go `*_test.go` beside source and TS `src/**/*.test.ts`, and LAYER.md calls
  sibling `X.Tests` projects the .NET convention.
- **SH-61 — `pick` always cuts a branch.** CONVENTIONS-universal.md § Working rules says `/tasks pick` "cuts the
  task branch", with no condition.
  - `new-project/SKILL.md` makes the same claim ("`/tasks pick` cuts `task/TASK-NNN`").
  - But `single-branch` is offered at intake, and `pick` cuts no branch under it.
  - The text sits outside the comment-rule markers, so the byte-identity check (lint check 5) does not constrain it.

## Acceptance criteria

- [ ] README.seed.md describes `/feature review` as the other seeded files do
- [ ] The UI/UX comment agrees with step 3 on which kinds keep the subsection
- [ ] The Architecture pointer points the right way
- [ ] § Testing no longer states one location for every stack
- [ ] Both statements of what `pick` does are conditioned on `pr-per-task`
- [ ] `bash .github/workflows/skills-lint.sh` passes, including check 5

## Out of scope

- This repo's own AGENTS.md wording, which is not a seed
- Token fill rules (TASK-242)

## Human test plan

N/A — template text, checked by scaffolding a Go CLI and reading the generated guide's Testing, UI/UX and Working-rules sections.

## Implementation plan

_Populated by `/tasks plan TASK-248` — leave empty until then._
