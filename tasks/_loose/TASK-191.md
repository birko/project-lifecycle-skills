---
id: TASK-191
parent: null
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] Both scripts re-read under the destination search by two cold readers, and any finding raised by both is fixed or filed.
- [x] The `Lines`, `Comment lines` and `Longest run` columns re-measured with the table's stated command, and the re-measure count and date line updated.
- [x] Both copies of the block stay byte-identical (`skills-lint.sh` check 5).

## Out of scope

- Any change to the comment rule itself. That is a wording change, and it invalidates the whole table rather than two rows.

## Human test plan

N/A — the cold-reader drill is the verification, and it is an acceptance criterion; check 5 asserts the two copies match.

## Implementation plan

1. Build the readers' brief exactly as § Comments' measurement method states: this guide (`AGENTS.md`) minus the whole measurement block (from *"This repo's own scripts have been walked"* to the record line), plus all six scripts, and nothing else. Ask each reader to apply § Comments to `skills-lint.sh` and `skills-lint-test.sh` and report findings with the destination searched, or *could not find* where the destination is outside what they were given.
2. Run two readers that are actually cold: `claude -p --disable-slash-commands` from a guide-free folder outside every repo, with the files copied in. Confirm coldness from each report, and record the command, the working directory and the coldness check.
3. A finding raised by both readers is fixed (if the fix is a comment edit inside these two scripts) or filed. A finding from only one reader is recorded here, not held against the file.
4. Re-measure with the table's stated commands (`wc -l`, `grep -cE '^[[:space:]]*#'`, longest unbroken run of that pattern) for every row, update the verdict cells for the two scripts and the re-measure line, in `AGENTS.md` and `skills/new-project/templates/CONVENTIONS-universal.md` alike, and run the lint (check 5).
5. Then decide this task's placement: both pass → move it out of EPIC-004 as repo upkeep; either fails → link it to FEATURE-002 with a `changed` D10.

## Progress log

- 2026-10-04 — Picked; planned inline (one measurement, two files).
- 2026-10-04 — **Drill, first pair** (on `616b689`'s scripts). Runners: `claude -p --disable-slash-commands < brief.txt`, two in parallel, cwd `%LOCALAPPDATA%\Temp\d191`, a folder outside every repo with no git, holding `GUIDE.md` (= `AGENTS.md` minus lines 451–507, the measurement block through its record line) and the six scripts. The brief named only the two scripts to judge and withheld TASK-190 and what it changed. **Coldness:** each was asked to list its skills and slash commands; both answered "none". **Agreed by both (4), all fixed as comment edits:** `skills-lint.sh:209-210` (why roots are overridable → § Commands/§ Testing) and `:217-219` (which trees each root holds → § Architecture, ADR 0010), both cut to one-line pointers; `skills-lint-test.sh:4-5` (what each case does → the helpers) deleted; `:48-50` (advisory tested on output → § Testing) cut to a pointer. **One reader only (not held against the file):** `skills-lint.sh:166-168`, `skills-lint-test.sh:359`. All four agreed findings predate TASK-190 (blame: 2026-09-19 to 09-24), so they were in the files when the table last said *passes*. That earlier verdict was reader variance, which the two-reader rule absorbs, not an error in it.
- 2026-10-04 — **Drill, second pair**, on the fixed scripts, same brief and recipe, cwd `%LOCALAPPDATA%\Temp\d191b`, `GUIDE.md` confirmed byte-identical to a fresh cut. **Coldness:** both listed no skills. **Agreed findings: none → both scripts pass.** One reader only: `skills-lint.sh:153`, `:207`. That reader also noted that `skills-lint.sh:134`'s "lives nowhere else" is not strictly true (the test file's comment at `:156-157` describes the same mechanic). Recorded, not filed: a single-reader observation.
- 2026-10-04 — Table re-measured (fourteenth time): `skills-lint.sh` 332 / 116 (34%) / 22, `skills-lint-test.sh` 411 / 70 (17%) / 7, the other four unchanged; without the shebang, 115 / 69 / 4 / 4. Lint OK, lint suite 67/67, check 5 agrees.
- 2026-10-04 — **Placement settled:** both scripts pass, so FEATURE-002's D10 still holds as recorded, and this was upkeep, not a change to the feature. Moved EPIC-004 → `_loose` (`/tasks move`), which clears the dashboard's DV3 for a true reason. EPIC-004 then had every child `done`/`cancelled` and rolled up to `done`.
- 2026-10-04 — **Found in passing, filed as TASK-252 (FIELD-008, P1):** CI on Linux has been red since 2026-09-19 (39 of 67 lint tests fail) because `3c7a837` committed `skills-lint.sh` with CRLF endings, while everything passes under Git Bash. This task's edit leaves those line endings exactly as they were.
- 2026-10-04 — Close review. Intent: all three criteria met. Correctness: comment and table edits only; lint and suite green locally (see TASK-252 for Linux). Comments: the drill above is this axis. Conventions: the table follows its re-run rule; nothing new to register. Human test plan `N/A` with its reason → **done**.
