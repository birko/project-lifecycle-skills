---
id: TASK-256
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
findings: []
pr: null
github-issue: null
jira-key: null
---

# `adopt-project` adds the seed's missing sections with their tokens unrendered

## Context

Spawned from TASK-242 (2026-10-04), which fixed this defect in [[new-project]] (SH-70) and found the same one
through the other door.

`skills/new-project/LAYER.md`'s agent-guide row tells the adopter to **"Merge by section. Add missing `##`
sections"**, and § *Matching a guide's sections* takes the inventory from `templates/CLAUDE.seed.md`'s own headings.
Two of those sections carry a token as their whole body: `## Architecture` (`{{ARCHITECTURE_NOTES}}`) and
`## Commands` (`{{BUILD_RUN_COMMANDS}}`), each with an `<!-- e.g. … -->` hint under it. Nothing in
`skills/adopt-project/` (SKILL.md, INFER.md) says how to fill a section it adds, so a repo whose guide lacks either
section gets the token and the hint verbatim. An adopted repo already *has* code, so both have a real source, its
build files and structure, which makes leaving them unrendered the less excusable case.

TASK-242's fix is in `new-project/SKILL.md` step 5 (a table of each token's source and its no-source outcome, then a
grep for `{{`). That is the scaffolder's own step, so the adopter does not inherit it.

## Acceptance criteria

- [ ] When the adopter adds a seed section carrying a token, the token is filled from evidence in the repo or the section states plainly that nothing was found — never shipped unrendered, and never filled by a guess
- [ ] The hint comments under those tokens never reach an adopted repo
- [ ] The rule is stated once and shared, not copied: either the token table moves where both front doors read it (`LAYER.md`), or the adopter points at the scaffolder's
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The scaffolder's side (TASK-242)
- The `## Conventions` block, which the adopter fills through `INFER.md`

## Human test plan

- [ ] Run `/adopt-project` from a cold runner on a repo whose guide has neither `## Architecture` nor `## Commands`, then grep the guide for `{{`. Expected: none, and both sections say something true about the repo or say plainly that nothing was found

## Implementation plan

_Populated by `/tasks plan TASK-256` — leave empty until then._
