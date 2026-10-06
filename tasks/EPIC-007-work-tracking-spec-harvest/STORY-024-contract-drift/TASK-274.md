---
id: TASK-274
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-06
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-98, SH-99, SH-101, SH-102]
pr: null
github-issue: null
jira-key: null
---

# `roll-changelog`: a dangling skeleton link, two definitions of its boundary, an undeclared flag, and an empty release

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-98:** `skills/roll-changelog/SKILL.md:20` links `[Keep a Changelog](#file-shape)`; no "File shape" section exists. `new-project/SKILL.md:112` and `LAYER.md:29` only say "a stub", and no template defines the skeleton, so the three seeders can write different stubs.
- **SH-99:** `:16` says gather work "since the last recorded entry"; `:42` says "since the most recent release tag/date". `:48`'s "don't clobber" is not a de-duplication rule, so a second roll before a release re-gathers work already rolled. This repo is in that state now.
- **SH-101:** `--date` is used at `:61` and `:71`, but the args list (`:14-18`) does not declare it.
- **SH-102:** cutting a release from an empty `## [Unreleased]` has no defined outcome (`:59-64`), and version inference (`:52-55`) has no case for empty buckets.

Related to TASK-024 (reconciling an older CHANGELOG's shape), not a duplicate of it.

## Acceptance criteria

- [ ] The changelog skeleton is defined once (a section or a template) and every seeder points at it; the `#file-shape` anchor resolves
- [ ] One boundary rule: a roll gathers only work not already in `## [Unreleased]`, stated so a second roll adds nothing it already holds
- [ ] `--date` is declared in the args list
- [ ] Cutting a release from an empty Unreleased has a stated outcome (refuse and report, for example)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ask-steps (TASK-273), and the shadowing claim (TASK-237)

## Human test plan

- [ ] Roll twice in a scratch repo with no new commits between, and confirm the second roll adds nothing

## Implementation plan

_Populated by `/tasks plan TASK-274` — leave empty until then._
