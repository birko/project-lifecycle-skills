---
id: TASK-203
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204, TASK-205]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: a one-time migration that rewrites old-form task files

## Context

A migrate batch of FEATURE-003 (owner group: `skills/tasks/`, the migration tool). D5: existing files are
rewritten once. `review` becomes `verify`. A `blocked` task becomes its **prior state** plus
`blocked: <reason>`, and the prior state is read from the file's git history: the last `status:` value
before `blocked`. It asks only where the history cannot tell (no git, or the file was created blocked).
The reason comes from the task's own `> Blocked <date> — <reason>` note when there is one.

**Design question this task settles, not assumes:** which verb owns the migration. The candidates are
`/tasks audit --fix`, which already applies safe fixes, and `/tasks init`'s reconcile path, which
already upgrades an older tree in place. Per AGENTS.md, an owner verb reconciles an older instance and
reports *already current* distinctly from *brought up to date*.

## Acceptance criteria

- [x] The owning verb is chosen and the reason recorded
- [x] `review` → `verify` and `blocked` → prior state + `blocked:` field, with the prior state read from `git log -p` of the file, never guessed
- [x] An undeterminable prior state is asked with a stated question and an answer-less path (AGENTS.md § *An ask-step carries the question*)
- [x] The run reports per file: already current, brought up to date, or asked. A re-run on a migrated tree changes nothing
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Running it on the consumer repos: TASK-205

## Human test plan

- [x] Run it on a throwaway copy of a consumer repo holding real `blocked` tasks (DraCode has 24): every prior state matches the file history, and a second run reports all files already current.
  - **Run 2026-09-30, passed.** Fixture: a bundle of DraCode's `main` (`45952f3`) cloned into `%TEMP%/d203/dracode`, with no remote. It held 75 tasks: 24 `blocked`, 8 `review`. DraCode is used because its tree is the largest real set of blocked tasks; nothing in this change was justified by it, so it is not disqualified. **Independent oracle, computed before the run:** for each blocked file, the latest non-`blocked` status in `git log --follow`. All 24 were `todo`, and none had a `> Blocked` note. Runner: `claude -p --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Edit Write Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief.txt`, run from the clone. It had the installed skills, and the brief said nobody answers. **Run 1:** 24 × `blocked → todo + blocked: waiting on <unmet depends-on>`, 8 × `review → verify`, no fallback needed. The oracle check found 24/24 correct and no old-form status left, and no task file changed by more than 2 lines. **Run 2** (run 1 committed, fresh runner): task files *already current*, and `git status` showed 0 task files changed.
  - **Found before the run, fixed in place:** DraCode records every blocked task's reason only through `depends-on`, with no note. As first written, step 3b would have given all 24 `reason unknown`. Unmet `depends-on` is now the second reason source.

## Implementation plan

Planned inline at pick (2026-09-30).

**Owner decision: `/tasks init` step 3b.**
- `init` already owns reconciling an older tree in place and reports *already current* / *brought up to date*, as AGENTS.md § *An owner verb reconciles* asks.
- [[adopt-project]] chains `init` on every re-run, the documented upgrade path, so consumer repos receive the migration without a new command.
- `audit --fix` was rejected. It applies findings one confirmation at a time (24 prompts on DraCode), and a migration is not a finding.
- `audit` instead reports old-form files as an `old-form` ⚪ row pointing at `init`.

## Progress log

- 2026-09-30 — Picked; planned inline; owner decided as above.
- 2026-09-30 — `init.md` step 3b written: `review → verify`; `blocked →` prior state from history plus a `blocked:` field; reason from the block note, else unmet `depends-on`, else `reason unknown`. It asks when history cannot tell, with a stated question, and without an answer writes `todo` with a note that nobody chose it. It is idempotent and reports per file. Step 5 reports it. `audit.md` gains the `old-form` row. Lint OK.
- 2026-09-30 — Drill passed (record above). Two details from run 1 fixed in place: where the `blocked:` field is written, and a single-command history read where a per-file loop is unavailable.
- 2026-09-30 — Close review. **Standards:** pass. The ask-step carries its question text and its answer-less path, and the fallback is written with the note that nobody chose it (AGENTS.md § *An ask-step*). Prior state is read, never inferred (§ *Read the declaration*: history determines it). **Intent:** pass, all 5 criteria met. **Correctness:** pass. The oracle agreed 24/24, and run 2 was byte-idle on task files. **Security:** not applicable. **Comments:** not applicable.
- 2026-09-30 — Out of scope, **work** → TASK-206: run 1 reported that the id-generation pattern `^id: TASK-[0-9]+$` misses CRLF files. Measured with ripgrep on DraCode, it found 35 of 75 ids, so a mint could reuse a number. Other runner notes (mode detection on an existing config, a header comment that differs from the template, the dashboard rewriting only its timestamp, drift-rule gaps) predate FEATURE-003 and are recorded here rather than filed.
