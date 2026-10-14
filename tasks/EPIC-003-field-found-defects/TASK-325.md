---
id: TASK-325
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-317-4, CR-317-5]
pr: null
github-issue: null
jira-key: null
---

# Batch verbs that run `/tasks new` drop its reopen and record lines, and repeat them per item

## Context

Found by TASK-317's close review (2026-10-14). This is a group: both findings sit on the same output, for batch creators. TASK-317 made `new.md` step 13 report every container step 10 reopened and every unlanded `record/<ID>` line, and made `spawn.md` step 8 relay them. Three other verbs chain `new` and print their own summary in its place, without those lines:

- `skills/tasks/verbs/intake.md` step 8
- `skills/tasks/verbs/import.md` step 7
- `skills/feature/verbs/decompose.md`

Two smaller defects on the same output:

- **Duplicates.** Nothing says to print each line once. A multi-id `move`, a `decide` that reverts two tasks under one story, or a batch `new` prints the same `record/<ID>` or `not checked` line once per child.
- **A flood of `not checked` lines.** `new.md` step 10 runs `git ls-remote` for every item a batch creates. That includes items under containers created in the same run, which cannot have a record branch. With the remote unreachable, every one of them prints a `not checked` line.

## Acceptance criteria

- [ ] `intake`, `import` and `decompose` relay every reopened container and every `record/<ID>` line their `new` runs produced
- [ ] Each distinct `record/<ID>` line is printed once per run, whatever the number of children behind it
- [ ] A container created in the same run is not checked, and one unreachable remote yields one `not checked` line, not one per item
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `close`'s re-close park (TASK-324)

## Human test plan

- [ ] On an upstream fixture with `record/STORY-001` pushed and unlanded, `/tasks intake` a pass that files three findings under STORY-001. Expected: one record line in intake's report.

## Implementation plan

_Populated by `/tasks plan TASK-325` — leave empty until then._
