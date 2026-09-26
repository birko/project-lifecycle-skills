---
id: TASK-191
parent: EPIC-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-26
depends-on: []
blocks: []
pr: null
github-issue: null
jira-key: null
---

# Re-measure the § Comments table for the two lint scripts TASK-190 changed

## Context

Spawned from TASK-190's close. `AGENTS.md` § Comments carries a table recording, per script, a
verdict under the destination search plus line and comment counts, last measured after TASK-166.
TASK-190 edited both `.github/workflows/skills-lint.sh` and `skills-lint-test.sh`. It added a
pointer comment above the frontmatter checks, a one-line note on `${#desc}` counting bytes under a
C locale, and one comment line above the new test cases. So the counts are stale, and the verdict
column now describes files that no longer exist in that form.

The table's own rule: re-run it, don't re-quote it. A verdict needs two cold readers (the block
states the method).

## Acceptance criteria

- [ ] Both scripts re-read under the destination search by two cold readers, and any finding raised by both is fixed or filed.
- [ ] The `Lines`, `Comment lines` and `Longest run` columns re-measured with the table's stated command, and the re-measure count and date line updated.
- [ ] Both copies of the block stay byte-identical (`skills-lint.sh` check 5).

## Out of scope

- Any change to the comment rule itself. That is a wording change, and it invalidates the whole table rather than two rows.

## Human test plan

N/A — the cold-reader drill is the verification, and it is an acceptance criterion; check 5 asserts the two copies match.
