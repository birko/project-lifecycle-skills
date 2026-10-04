---
id: TASK-243
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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

- [x] A freshly scaffolded repo passes the adopter's `.gitignore` coverage check, and the scaffolder line and the LAYER row's "Absent → create" clause name the same entries
- [x] LAYER.md's `tasks/` row and the adopter agree on whether a missing `worktree-root:` is probed and asked during adoption
- [x] On the next regen, `docs/specs/project-baseline.md`'s worktree-root requirement no longer needs its "the two files disagree" clause
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- LAYER.md's survey-state list (TASK-085)
- `new-project`'s token and remote ordering (TASK-242)

## Human test plan

- [x] Scaffold a project with `/new-project`, then run `/adopt-project` on it from a cold runner. Expected: the `.gitignore` row reports present and covered
- [x] Re-run `/adopt-project` on a repo with `workspace: worktree` and no root. Expected: the outcome matches what both files now say

## Implementation plan

Planned inline at pick (2026-10-04).

1. **SH-56.** `new-project` step 3's `.gitignore` bullet points at LAYER.md's `.gitignore` row for the entries, and keeps none of its own (AGENTS.md § *Defer to a shared inventory*). The row's "Absent → create" clause names the same entries its "Present" check looks for, so creation and survey read one list.
2. **SH-54.** The adopter's reading wins: `pick` asks for the root when the first task needs it, and asking at adoption would break the one-round rule. LAYER.md's `tasks/` row stops listing `worktree-root:` as a declaration to probe, and says an absent root is settled at adoption.
3. Re-harvest `project-baseline` for both rows; the "two files disagree" clause goes.
4. Drill: a cold runner scaffolds with `workspace: worktree` and no root, then a second cold runner adopts that output. Expected: `.gitignore` reported covered, and no root question asked.

## Progress log

- 2026-10-04 — Picked; planned inline. **SH-56:** `new-project` step 3's `.gitignore` bullet no longer lists entries of its own; it includes "every entry LAYER.md's `.gitignore` row checks for", per § *Defer to a shared inventory*, because the copied list was exactly what drifted. The row's "Absent → create" clause now names the same entries its "Present" check looks for. **SH-54:** the adopter's reading wins. LAYER.md's `tasks/` row no longer counts `worktree-root:` as a declaration to probe at adoption; an absent root is settled there, because `pick` asks for it when the first task needs it ([[adopt-project]] § 2). Both files now say the same thing.
- 2026-10-04 — **Spec:** `project-baseline` re-harvested for both rows. The `.gitignore` requirement names the shared entries (and the Node scenario gains `.claude/settings.local.json`). The worktree-root requirement drops its "the two files disagree" clause (criterion 3). 4 lines changed, 4 removed. Re-stamped at `18ff189`.
- 2026-10-04 — **Human test plan — one fixture, both drills, passed.** Folder `%LOCALAPPDATA%\Temp\d243`, outside every repo, holding a copy of `skills/`. **Runner 1** (`claude -p --disable-slash-commands --permission-mode acceptEdits`, git and file tools only) scaffolded `out/tally`: a Python CLI with `workspace: worktree` and the root unanswered, git yes. Its `.gitignore` carries `.env`, `.env.*`, `!.env.example` and `.claude/settings.local.json`, and `worktree-root:` stays commented. **Runner 2**, cold (it listed no skills), with read-only tools, ran `/adopt-project` on that output: the `.gitignore` row is `present`, every entry covered by the repo's own file (checked with `git check-ignore -v`). The question round asked **nothing**, and it reported "worktree-root undeclared — pick will ask", treating it as settled.
- 2026-10-04 — Close review. Intent: all three criteria plus both drills. Correctness: two inventory rows and one scaffold bullet; layer parity holds, since both front doors read the same rows. Comments: none. Conventions: the scaffold bullet now defers to the inventory instead of copying it. → **done**.
