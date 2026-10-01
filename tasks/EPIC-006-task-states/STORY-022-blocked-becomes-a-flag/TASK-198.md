---
id: TASK-198
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

# Migrate: `roadmap`'s cross-tree pass reads `verify` and the blocked flag

## Context

A migrate batch of FEATURE-003 (owner group: `skills/roadmap/`). The cross-tree pass joins tasks to
features and runs the divergence rules; any rule keyed on a task status must read both forms.

## Acceptance criteria

- [x] Every status the cross-tree pass and the divergence rules read accepts both forms, by pointer to `tasks/SKILL.md` § *Lifecycle*
- [x] A flagged task is never reported as a divergence merely for carrying the flag
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The feature coarse marker — unchanged

## Human test plan

- [x] `/roadmap --check` on the TASK-197 fixture reports the same divergences as on an all-old-form copy of it.
  - **Run 2026-10-01, passed on the second round.** Two copies of the TASK-197 fixture: **new form** (`verify`, `in-progress` + `blocked:`) and **old form** (`review`, `status: blocked`). Two independent runners ran `/roadmap --check` read-only on each: `claude -p --allowedTools "Bash(git:*)" "Bash(grep:*)" "Bash(ls:*)" Read Grep Glob Skill --add-dir ~/.claude/skills C:/Source/project-lifecycle-skills < brief.txt`, each from its own copy. **Round 1 was invalid.** Neither feature had a `status.md`, so neither had a phase. One runner substituted `idea.md`'s marker and fired DV1; the other said DV1 could not be checked. The difference came from that ambiguity, not from the status forms; both read every task status by the new rule. **Round 2:** a stale `status.md` (`Phase: idea`) was added to both copies. Both runners reported the **same** two divergences, DV1 on FEATURE-001 and FEATURE-002, and neither treated the blocked task as a divergence. Round 1's two ambiguities (DV1 undecidable without `status.md`; "idea / all proposed" read as either-or) predate FEATURE-003 → TASK-207.

## Implementation plan

Planned inline at pick (2026-10-01). One sentence in the Cross-tree pass's task collection, which every rule reads: statuses in both forms, by pointer to [[tasks]] § *Lifecycle*; the flag alone is never a divergence. No rule needed its own change. DV1 and DV2 name `in-progress`/`done`, which the pointer covers.

## Progress log

- 2026-10-01 — Picked; planned inline. Edit made; lint OK.
- 2026-10-01 — Drill: round 1 invalid (fixture lacked `status.md`), round 2 passed (record above). TASK-207 filed for the two pre-existing ambiguities.
- 2026-10-01 — Close review. **Standards:** pass; it is a pointer, not a copy. **Intent:** pass, all 3 criteria met. **Correctness:** pass; both forms gave identical divergences. **Security:** not applicable. **Comments:** not applicable.
