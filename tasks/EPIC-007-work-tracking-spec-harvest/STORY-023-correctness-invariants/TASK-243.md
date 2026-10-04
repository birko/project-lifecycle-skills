---
id: TASK-243
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P1
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-54, SH-56]
pr: null
github-issue: null
jira-key: null
---

# Two `LAYER.md` rows disagree with the front door that implements them

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`. In both, a row of the shared inventory `skills/new-project/LAYER.md` says one
thing while a front door does another. That is layer parity failing in a direction nothing lints for.

- **SH-56 — the scaffolder's `.gitignore` fails the adopter's own check.** LAYER.md's `.gitignore` row has the
  adopter check that `.env` / `.env.*` are covered **and** that agent-tool local state is
  (`.claude/settings.local.json` at minimum). `new-project/SKILL.md` step 3 writes stack ignores, `.env`, `.env.*`
  and `!.env.example`, and no agent-state line. So the first adoption survey of a fresh scaffold reports a gap the
  scaffolder created. TASK-094 decided "new-project needs no edit", but that was about which file carries the line,
  not whether the scaffolder writes it.
- **SH-54 — `worktree-root:` is both outstanding and settled.** LAYER.md's `tasks/` row lists `worktree-root:` as a
  declaration to probe in the survey once `workspace: worktree` is answered. `adopt-project/SKILL.md` § 2 says the
  root question is asked "not … on this pass or any re-run", and that a worktree with no root is "a settled state
  here, never an outstanding one". `tasks/verbs/init.md` makes the question optional. On a re-run over
  `workspace: worktree` with no root, the two files give opposite instructions. `docs/specs/project-baseline.md`
  records both sides.

## Acceptance criteria

- [ ] A freshly scaffolded repo passes the adopter's `.gitignore` coverage check, and the scaffolder line and the LAYER row's "Absent → create" clause name the same entries
- [ ] LAYER.md's `tasks/` row and the adopter agree on whether a missing `worktree-root:` is probed and asked during adoption
- [ ] On the next regen, `docs/specs/project-baseline.md`'s worktree-root requirement no longer needs its "the two files disagree" clause
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- LAYER.md's survey-state list (TASK-085)
- `new-project`'s token and remote ordering (TASK-242)

## Human test plan

- [ ] Scaffold a project with `/new-project`, then run `/adopt-project` on it from a cold runner. Expected: the `.gitignore` row reports present and covered
- [ ] Re-run `/adopt-project` on a repo with `workspace: worktree` and no root. Expected: the outcome matches what both files now say

## Implementation plan

_Populated by `/tasks plan TASK-243` — leave empty until then._
