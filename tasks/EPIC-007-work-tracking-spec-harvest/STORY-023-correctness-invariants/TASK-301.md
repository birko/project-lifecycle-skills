---
id: TASK-301
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: unassigned
created: 2026-10-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-012]
pr: null
github-issue: null
jira-key: null
---

# `improve-architecture`'s `since <commit>` lines never say which commit they name

## Context

Found by the cold runner in TASK-280's drill (2026-10-12). Five report lines in
`skills/improve-architecture/SKILL.md` end in `since <commit>`: `rejected file gone`, `rejected member gone`,
`previously rejected, unchanged`, `hold released` and `not carried forward`, plus their copies in the page and
stdout templates. Step 5 defines `<commit>` only for a rejection record (`at <commit>`, HEAD when the test ran).
For `since`, three readings fit: the commit recorded on the earlier entry, the commit that removed the file or
retired the ADR, or this run's HEAD. Two runs can print different commits for one event, and a reader comparing
reports sees a difference that is not real.

The skill already implies the first reading in one place: Step 5 item 3 runs `git log <commit>..HEAD` from the
recorded commit, which is what `unchanged since <commit>` reports.

## Acceptance criteria

- [x] One sentence in Step 5 defines `<commit>` in every `since <commit>` line (Steps 5, 6 and 7 and both
      templates) as the commit recorded on the earlier entry, and says why not the others
- [x] `docs/specs/code-shape-review.md` states the same
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing any line's wording other than the definition

## Human test plan

N/A — a one-sentence definition, checked by reading every `since <commit>` line against it.

## Implementation plan

_Populated by `/tasks plan TASK-301` — leave empty until then._

## Outcome

**What changed.** Step 5 now has one paragraph defining `since <commit>` as the commit recorded on the earlier
entry, covering all five line shapes and both templates. It gives two reasons: that is the commit item 3 already
reads the log from, and finding the removing commit would be a search the verdict does not turn on. No line's
wording changed. `code-shape-review` was respecced: the re-check requirement now carries the definition.

**Evidence.** I read every `since <commit>` line (SKILL.md lines 299, 300, 308, 336, 395, 523, 524, 545 and 548)
against the definition. Each one is about an earlier entry that carries an `at <commit>`. No drill was run: the
change adds a definition and moves no behaviour, and TASK-280's runner had already chosen this reading unaided.

**Merge gate (close step 5b, run inline, each verdict on its own):**
- *Standards*: pass. One definition with one owner (Step 5), which the other steps rely on rather than repeat.
- *Fidelity*: pass. Criteria 1–3 met, and no line's wording changed.
- *Correctness*: no finding.
- *Security* and *Comments*: not applicable.
