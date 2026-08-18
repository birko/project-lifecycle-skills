---
id: TASK-002
parent: STORY-001
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: review
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Scaffold the universal layer onto this repo

## Context

Backfilled per the task-first gate: the work ran before this file existed, because it *is* the work
that creates the task tree. The gate's prescribed remedy is a task with honest status and criteria
reconstructed from the scaffold spec — not a task written afterwards and dropped into `done`.
This is the only task in the repo permitted that exemption (EPIC-001 § Notes).

Ran `new-project` against a repo with 36 commits, an existing README and LICENSE, and no `.gitignore`.

## Acceptance criteria

- [x] `AGENTS.md` holds the guide content; `CLAUDE.md` is exactly `@AGENTS.md` — never both carrying content
- [x] `§ Conventions` carries a real rule in every subsection; no unrendered tokens ship
- [x] `docs/BRIEF.md` stamped as adopted rather than reconstructed, with both post-adoption asks logged verbatim
- [x] `docs/architecture.md`, `docs/features/README.md`, `docs/specs/.map.yml` (empty `areas:`, treated as absent) written
- [x] `CHANGELOG.md` backfills all 36 commits, bucketed and translated to human language
- [x] `.gitignore` created (repo had none); `.editorconfig` added
- [x] `tasks/` initialized: `.config.yml`, dashboard, EPIC-001 and eight stories
- [x] `skills-lint` written and passing; CI workflow runs it plus the CLAUDE.md bridge check
- [x] Defects found by the scaffold run are fixed or filed, not swallowed
- [ ] `adopt-project` re-run on this repo reports zero gaps — **blocked on STORY-002**

## Out of scope

- Filling `docs/specs/` — deferred to STORY-008; regenerating before the skill set stabilises means reviewing a diff that is pure churn.
- Seeding `docs/features/` with stubs — this epic is deliberately task-only (no stakeholder gate).
- The story-level dependency-edge defect this work exposed → deferred to TASK-001.
- Merge guidance for files the repo already owns → deferred to STORY-002.

## Human test plan

- [x] `bash .github/workflows/skills-lint.sh` exits 0 and reports 15 skills
- [x] `tr -d '[:space:]' < CLAUDE.md` equals `@AGENTS.md`
- [ ] Push and confirm the GitHub Actions `skills-lint` job goes green on the real runner (ubuntu-latest, not Git Bash on Windows — the script has not run there yet)
- [ ] Open a fresh agent session in this repo and confirm the `@AGENTS.md` bridge auto-loads the guide, and that `§ Conventions` is what `/verify-conventions` reads
- [ ] Run `/roadmap` and confirm it renders EPIC-001 across both trees without erroring on an empty `docs/features/`
- [ ] **Blocked:** run `adopt-project` on this repo and confirm zero gaps (STORY-002)

## Implementation plan

_Executed ahead of the file, per the recorded exemption. The scaffold order followed
`new-project` steps 1–6: intake → ground truth → universal layer → task init → CI → git._
