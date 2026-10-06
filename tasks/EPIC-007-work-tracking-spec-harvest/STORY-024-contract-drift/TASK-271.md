---
id: TASK-271
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
findings: [SH-88, SH-91, SH-92]
pr: null
github-issue: null
jira-key: null
---

# Three shipped skills point at things a consumer install does not have

## Context

Found by the TASK-080 stage 2 spec harvests (2026-10-06, EPIC-007's fifth pass) at `20c038b`, and checked against the files by a second reader before intake.

- **SH-88:** `skills/populate-tests/SKILL.md:219` cites "`AGENTS.md` § *An owner verb reconciles; it does not assume*". No seed template carries that section, and AGENTS.md itself says a skill file cannot point back at it.
- **SH-91:** `skills/tdd/SKILL.md:32-33` sends the reader to "the built-in `verify`/`run` skills". There is no built-in `verify` (Claude Code lists only `run`), and pi has neither.
- **SH-92 (partly confirmed):** `skills/domain/SKILL.md:79` (§ *The five records*) and `:174` (§ *Output / prose rules*) cite sections a seeded guide does not have. `:155`'s § Conventions does exist in the seed, but in `CLAUDE.md` by default, so only the file name is wrong.

The same root cause as TASK-249 (adopt-project and LAYER.md citations), in other skills; that task's scope does not reach these.

## Acceptance criteria

- [ ] No citation in `skills/populate-tests/`, `skills/tdd/` or `skills/domain/` names a guide section or a skill a consumer install lacks. Each either carries its one-clause rationale inline, or names the project's own guide generically (§ Conventions in whichever file holds it)
- [ ] `tdd` names only skills that exist in both runtimes, or says which runtime a named built-in belongs to
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The same defect in `adopt-project` and `new-project/LAYER.md` (TASK-249)

## Human test plan

N/A: citation wording, checked by grepping the three skills for `AGENTS.md` and for skill names absent from `skills/`.

## Implementation plan

_Populated by `/tasks plan TASK-271` — leave empty until then._
