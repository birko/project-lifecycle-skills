---
id: TASK-199
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: `fix-next` reads the new form and skips a blocked task it ranks first

## Context

A migrate batch of FEATURE-003 (owner group: `skills/fix-next/`). Step 0 resumes only `in-progress`
branch copies, step 1 excludes `status: blocked` from the pool, and step 8 closes through `close`.
FEATURE-003 D6 keeps a blocked task in the offered work, and D9 decides what an unattended drain does
with one: **skip it, report it, and take the next unblocked task**, never unblocking it itself.

## Acceptance criteria

- [x] Step 0 treats a flagged `in-progress` branch copy as an active run only when it is unflagged. A flagged run is reported and not resumed
- [x] Step 1 ranks a flagged task in the pool, then skips it with a report line naming the task and the reason (D9); legacy `status: blocked` is skipped the same way
- [x] `verify` and legacy `review` are both non-active in step 0
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Unblocking anything — a human decision

## Human test plan

- [x] Cold drill: a pool whose top-ranked defect carries `blocked: waiting on TASK-X`. `/fix-next` names the skip and the reason, then picks the runner-up.
  - **Run 2026-09-30, passed on the second fixture.** Fixture: `%TEMP%/d199`, a `kind: review-intake` epic with three defects: TASK-001 `todo` + `blocked:`, TASK-002 `todo`, TASK-003 old-form `status: blocked`. Runner: `claude -p --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief.txt`, run from the fixture. It had the installed skills, and the brief was a read-only rehearsal that did not state the expected pick. **First fixture, inconclusive:** its TASK-001 (a zip path traversal) was ranked below data loss on key 1, so the blocked task never ranked first. The pick was right (TASK-002), but only the old-form skip was exercised. That was a fault in the fixture; the run still found three wording gaps, fixed in place. **Second fixture:** TASK-001 became an authorization bypass, the top of key 1, and a fresh runner was used. Result: `skipped: TASK-001 — blocked: waiting on the identity team to expose the partner-to-tenant mapping` and `skipped: TASK-003 — blocked: reason unknown`, the pick was TASK-002, and nothing was unblocked. One further gap was fixed in place: the runner-up line when no other task can be started.

## Implementation plan

Planned inline at pick (2026-09-30). One owner, `skills/fix-next/SKILL.md`:
- Step 0: a run counts only when it is unblocked, read in both forms, and this skill's own blocked run is reported, not resumed.
- Step 1: blocked tasks in both forms stay in the pool (D6), but the skill never starts or unblocks one.
- Step 2: walk past blocked tasks to the first startable one, with a `skipped:` line each (D9).
- Step 9: the report lists every blocked task in the pool.

## Progress log

- 2026-09-30 — Picked; planned inline.
- 2026-09-30 — Steps 0, 1, 2 and 9 edited as planned. Lint OK.
- 2026-09-30 — Drill 1 was inconclusive on the main case and found three wording gaps, fixed in place: step 1's opening sentence excluded old-form blocked tasks; blocked tasks below the pick went unreported; the runner-up was undefined. Drill 2 passed; one more gap fixed (no startable runner-up).
- 2026-09-30 — Close review. **Standards:** pass. It points at [[tasks]] § *Lifecycle* for the two forms and does not restate them. **Intent:** pass, all 4 criteria met; D9 is built as decided (skip, report, never unblock). **Correctness:** pass. The pool membership sentence and the blocked paragraph now agree, and an all-blocked pool is handled as an empty pool. **Security:** not applicable. **Comments:** not applicable.
- 2026-09-30 — Out of scope, recorded rather than filed: the runners raised pre-existing points that predate FEATURE-003 — theme slugs off the ladder, a tie that includes a blocked task, key 3 judged on the filed text, and the known commit-trailer conflict. None changes this story's behaviour.
