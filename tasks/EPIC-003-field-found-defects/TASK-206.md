---
id: TASK-206
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] Every id pattern the id-generation rule states tolerates a trailing `\r` (for example `\r?$`), or the rule says to read ids in a way that is line-ending independent
- [x] `feature/SKILL.md` § *ID generation* and `intake.md`'s `FIELD-NNN` rule are checked and fixed the same way
- [x] A lint test, or a scripted check recorded here, shows the corrected pattern finding every id in a fixture with mixed line endings, where the old pattern misses the CRLF ones
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Normalising line endings in consumer repos. That is each repo's own choice.

## Human test plan

- [x] N/A — a scripted check proves it: run the corrected and the old pattern over a fixture with mixed line endings with ripgrep, and record both counts.
  - **Run 2026-10-01.** Three tools against a two-file fixture (one LF file, one CRLF file stored with `core.autocrlf false`): the old pattern found 2 with GNU grep, **1** with `git grep` on the blob and **1** with ripgrep (the Grep tool); `[[:space:]]*$` found 2 in all three. On DraCode's real mixed-ending tree, the Grep tool found **35 of 75** with the old pattern and **75 of 75** with the new one.

## Implementation plan

Planned inline at pick (2026-10-01). The defect was wider than filed: besides the id scan, every by-id lookup in `block`, `cancel`, `close`, `move`, `plan` and `show` used `^id: TASK-NNN$`, so on a CRLF file they report "not found". `\r?$` was rejected because POSIX ERE (GNU grep, `git grep -E`) has no `\r` escape; `[[:space:]]*$` works in all three tools. The rule and its measurement are stated once, in `tasks/SKILL.md` § *ID generation*; every site carries the corrected pattern; lint check 7 makes a regression fail CI.

## Progress log

- 2026-10-01 — Picked; the scope measured: 9 patterns in 8 files.
- 2026-10-01 — All 9 patterns end `[[:space:]]*$`, and the rule is stated in § *ID generation*. `skills-lint.sh` gains fatal check 7 (`^id:` pattern ending in a bare `$` in `skills/` or `skills-pi/`), with 3 new suite cases: bare in backticks, bare in quotes, the tolerant form. Suite 66/66; lint OK. Against the pre-change lint the two bare cases **fail** and the other 64 pass, so check 7 is what catches them. A first attempt at that proof was invalid (the old lint was copied under the wrong file name, so every case failed with exit 127) and was re-run correctly. `AGENTS.md` § *Testing* count updated to 66.
- 2026-10-01 — Close review. **Standards:** pass. The rule is stated once with its measurement, the sites carry the pattern, and the lint enforces it, as AGENTS.md § *Testing* asks for a lint change. **Intent:** pass, all 4 criteria met; `feature/SKILL.md` is fixed, and `intake.md`'s `FIELD-NNN` rule uses no anchored pattern, so it needed none. **Correctness:** pass. The regex was proved in three tools and on a real tree. **Security:** not applicable. **Comments:** pass. Check 7's header comment is the mechanism plus a pointer to § *ID generation*, not a copy of it.
- 2026-10-01 — Out of scope, boundary: the AGENTS.md § *Comments* measurement table now understates `skills-lint.sh` and `skills-lint-test.sh`; re-measuring it is TASK-191's job.
- 2026-10-01 — **Defect in this task's own fix, found while closing TASK-197:** check 7 had been inserted after the summary line, so a failing check 7 printed `skills-lint: OK` and then its errors (the exit code was still non-zero). Moved before the summary. A fourth suite case, `bare $ id pattern ends the run FAILED`, asserts the summary says FAILED. It **failed** against the misordered lint and passes now. Suite 67/67; `AGENTS.md` count updated.
