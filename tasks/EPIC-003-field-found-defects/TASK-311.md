---
id: TASK-311
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [CR-310-1, CR-310-2]
pr: null
github-issue: null
jira-key: null
---

# The "inferred, not chosen" mark reaches no reader through `/fix-next`, nor on an epic or story

## Context

Grouped: two gaps the correctness pass raised at TASK-310's close (2026-10-13). TASK-310 made `/tasks pick`
step 9 print the mark `new.md` § *Unanswered questions* writes. Two paths still never show it:

- **CR-310-1.** `/fix-next` marks its task in-progress itself (`skills/fix-next/SKILL.md` step 2) and never
  reaches `pick` step 9. A defect filed unattended, with an inferred parent and priority, is exactly what it
  drains, and it fixes and closes such a task without the guess ever being shown. It cannot ask, so it
  should report: the step 2 log line and the step 9 report name the inferred fields.
- **CR-310-2.** `pick` handles tasks only. A mark on an epic or story (`level`, `title`, `affects`) is shown
  once, at `new` step 13, and never again; `show.md` even hides an empty `affects:` list.

## Acceptance criteria

- [x] `/fix-next` records a picked task's inferred fields in its Progress log and its final report
- [x] A marked epic or story is surfaced by a reader (`show`, or `audit`)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The mark's wording ("inferred" for a fallback like `affects: []`; accepted at TASK-310)

## Human test plan

- [x] A cold runner runs `/fix-next` on a fixture whose only defect carries the mark, then `show`s a
      marked epic. Expected: both reports name the inferred fields.
  - **Passed 2026-10-13:** the step-2 log line ended `; inferred, not chosen: parent, priority`, and the
    stopped run's report named both under *Flagged, not fixed*; `show EPIC-002` printed
    `⚠ inferred, not chosen: title — confirm them, then delete the line` under the header.

## Implementation plan

Drafted inline at pick: `/fix-next` appends the inferred fields to its step-2 log line and names them in
step 9's report (it cannot ask, so it records); `show` prints the mark under the header at every level and
stops hiding a marked `affects:`.

## Outcome

**The fix.** `/fix-next` step 2 ends its first log line with `; inferred, not chosen: <fields>` when the
task carries the mark, after any tie note, and step 9's report repeats it under *Flagged, not fixed*.
`show` prints the mark once, under the header, for every level, and shows a marked `affects:` with
`(inferred)` instead of hiding an empty list. `new.md` no longer lists the mark's readers; each cites the
section instead.

**Drill.** The d308 fixture reset to its initial commit, plus a TASK-004 with `findings: [FIELD-001]` and
the mark (`parent, priority`), and a mark on EPIC-002 (`title`). Same runner command as TASK-308. The brief
asked for `/fix-next` through step 2 and its report, then `/tasks show EPIC-002`, nobody to answer, and did
not mention the mark. **Coldness check:** no skills listed. The drill showed the mark printed twice by
`show` (as the warning and again in the body), now fixed. Its `�` came from the fixture file being written
without UTF-8, not from the skill.

**Review passes.**
- Standards: pass. Fidelity: pass, nothing unasked-for.
- Correctness: four low findings, all fixed. They were: `new.md` listed the mark's readers (now a pointer
  to the section); the order of the tie note and the inferred suffix was unstated; `show` printed the mark
  twice; and the `affects:` wording could force `[]` over a filled list.
- Security, comments: not applicable.

**Spec.** `docs/specs/defect-draining.md` quotes the old step-2 log line; a scoped `/specs regen` picks it up.
