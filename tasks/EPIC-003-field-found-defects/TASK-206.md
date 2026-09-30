---
id: TASK-206
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: unassigned
created: 2026-09-30
depends-on: []
blocks: []
findings: [FIELD-006]
pr: null
github-issue: null
jira-key: null
---

# The id scan misses task files with Windows line endings, so a new task can reuse a number

## Context

Found by the TASK-203 drill (2026-09-30). `skills/tasks/SKILL.md` § *ID generation* says to take the max
of `^id: (EPIC|STORY|TASK)-(\d+)$`. In a file with CRLF line endings, `$` does not match before the `\r`
in ripgrep, which is what an agent's Grep tool uses. Measured on DraCode, which has mixed line endings:
the Grep tool found **35 of 75** task ids with that pattern. GNU `grep` found all 75, and so did `git grep` on a
branch, which reads blobs normalised to LF.

So the result depends on which tool the agent reaches for. When the highest id sits in a CRLF file, the
next task reuses its number. This is the exact defect the section exists to prevent. `FEATURE-NNN` and
`FIELD-NNN` are minted the same way.

## Acceptance criteria

- [ ] Every id pattern the id-generation rule states tolerates a trailing `\r` (for example `\r?$`), or the rule says to read ids in a way that is line-ending independent
- [ ] `feature/SKILL.md` § *ID generation* and `intake.md`'s `FIELD-NNN` rule are checked and fixed the same way
- [ ] A lint test, or a scripted check recorded here, shows the corrected pattern finding every id in a fixture with mixed line endings, where the old pattern misses the CRLF ones
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Normalising line endings in consumer repos. That is each repo's own choice.

## Human test plan

- [ ] N/A — a scripted check proves it: run the corrected and the old pattern over a fixture with mixed line endings with ripgrep, and record both counts.
