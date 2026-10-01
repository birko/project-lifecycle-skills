---
id: TASK-200
parent: STORY-022
feature: FEATURE-003
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P3
assignee: unassigned
created: 2026-09-30
depends-on: [TASK-196]
blocks: [TASK-204]
findings: []
pr: null
github-issue: null
jira-key: null
---

# Migrate: `specs regen`'s state gate reads `verify`

## Context

A migrate batch of FEATURE-003 (owner group: `skills/specs/`). `regen`'s inferred-evidence gate reads task
statuses, including the leading status comment the task template emits. Both must accept the new form.

## Acceptance criteria

- [x] `specs/verbs/regen.md`'s state gate accepts `verify` wherever it accepted `review`, and reads a flagged task by its state
- [x] The quoted template status comment matches what the template emits after TASK-204, and still matches older files
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing which states count as evidence

## Human test plan

- [x] N/A — the gate is a reading rule with no user-visible surface. The TASK-205 migration run on a consumer repo re-runs a regen and compares it with the pre-migration map.

## Implementation plan

Planned inline at pick (2026-10-01). The gate is already written as a test against the `tasks` vocabulary: it rejects `todo` and `cancelled`, and everything else passes. So the change is one sentence on reading both forms, plus replacing a verbatim quote of the template comment, which was already stale, with a description that holds for every template version.

## Progress log

- 2026-10-01 — Picked; planned inline. `regen.md` updated; lint OK.
- 2026-10-01 — One behaviour shift, deliberate and recorded: a migrated blocked task whose history says it never started (`todo` + `blocked:`) is now rejected by the gate, while an old `status: blocked` passed. That is correct, because the work never landed. A deferred merge (`in-progress` + `blocked:`) still passes.
- 2026-10-01 — The stale quote was TASK-111's defect (merged into TASK-105). Fixing it here is required by this task's own criterion 2, and the note is left on TASK-105.
- 2026-10-01 — Close review. **Standards:** pass. It points at the vocabulary instead of copying the list, and the text-independent comment match is the rule's own warning applied to itself. **Intent:** pass, all 3 criteria met. **Correctness:** pass. Old-form files are judged exactly as before. **Security:** not applicable. **Comments:** not applicable. Human test: N/A as planned; TASK-205's regen on a migrated consumer repo is the live check.
