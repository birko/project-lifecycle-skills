---
id: TASK-233
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
findings: [SH-19]
pr: null
github-issue: null
jira-key: null
---

# `/roadmap --across` does not say how it combines with an epic scope, or what it prints when nothing is found

## Context

Found by the project-roadmap spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-19.** `skills/roadmap/SKILL.md` § *Verbs / args* defines `--across` and says `--fix` is refused with it. Two
  combinations are left open:
  - **`/roadmap EPIC-NNN --across`.** Across-mode qualifies ids as `<repo>/TASK-NNN` because ids collide between sibling
    projects (AGENTS.md § Code structure records 343 colliding ids across seven trees). A bare `EPIC-NNN` then names
    several epics, and nothing says whether the scope matches all of them, takes a qualified `<repo>/EPIC-NNN`, or is
    refused.
  - **No tree anywhere.** "If neither tree exists, print one line … and exit" is written for one repo. Under `--across`
    it is not said whether the line is about this repo, any sibling, or none of them, and what happens when this repo
    has neither tree but siblings do.

## Acceptance criteria

- [ ] `EPIC-NNN` with `--across` has a stated behaviour (accept a qualified id, match every repo, or refuse by name, as
      § Conventions requires for a switch that cannot apply)
- [ ] The empty-tree line states its scope under `--across`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The Collection pass's walk itself — owned by [[tasks]] step 1b
- A feature with no `status.md` — linked to TASK-207 (SH-20)

## Human test plan

N/A — two argument rules, checked by reading § Verbs / args against [[tasks]]' across-mode.

## Implementation plan

_Populated by `/tasks plan TASK-233` — leave empty until then._
