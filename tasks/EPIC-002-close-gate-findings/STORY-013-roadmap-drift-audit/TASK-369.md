---
id: TASK-369
parent: STORY-013
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-032-1, DRILL-032-2]
pr: null
github-issue: null
jira-key: null
---

# DV10's "could not decide" has no output line, and triage's summary has no singular

## Context

Filed 2026-11-13 at TASK-032's close. Two cold runners ran `/roadmap --check` and then `/tasks triage` on one
two-epic fixture (`%LOCALAPPDATA%/Temp/d032` and `d032b`, reports kept there). Both raised these two, which predate
TASK-032 and meet FEATURE-002 D10's bar.

- **DRILL-032-1 — DV10's undecided case.** [[roadmap]]'s DV10 says "Nothing answered ⇒ stay silent, and say the check
  could not decide." Both runners read "stay silent" and "say" as pulling against each other, and both invented a
  line (`DV10: could not decide — …`) and a place for it. Nothing gives its wording or says whether `triage`'s callout
  carries it.
- **DRILL-032-2 — triage's summary line.** `triage` step 9 prints `Dashboard refreshed: <E> epics, <S> stories, <T>
  tasks …` with no singular rule, so both runners printed "1 stories". The `/tasks` snapshot settled the same case for
  itself in TASK-355 (singular for exactly 1), and its `<n> feature divergence(s)` leaves the `(s)` unresolved too.

## Acceptance criteria

- [x] DV10's undecided case has stated wording and a stated place in `--check` and the full render, and `triage`
      says whether its callout carries it
- [x] `triage` step 9's summary states its singular forms, consistent with the snapshot's rule
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Accepted divergences: TASK-032 (done)

## Human test plan

- [x] Re-run the `d032` brief on a fresh clone of `%LOCALAPPDATA%/Temp/d032/repo` with `skills/` at the fix, using a
      cold runner. Expected: neither reading in its "left undecided" section
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d369`: the `d032` brief on a fresh clone of its fixture,
    `skills/` at the fix, the runner listing no skills. Neither reading came back. `--check` ended with the stated
    `Not checked: DV10 — nothing here says what the source is …; /specs init settles it`, and `triage` printed
    `Dashboard refreshed: 2 epics, 1 story, 2 tasks (0 in progress); 1 feature divergence — see /roadmap`.

## Implementation plan

Inline, together with its sibling task: state each rendering choice in the verb that renders it.

## Outcome

**The fix.**
- **DV10's undecided case** ([[roadmap]] § *DV10: what counts as code*, step 4) is never a finding: it is in neither
  the divergence list, the compact slice nor `triage`'s callout. The full render and `--check` print one stated line
  after the divergence and accepted blocks, `Not checked: DV10 — …; /specs init settles it`.
- **`triage`'s summary line** takes the snapshot's singular rule for every count noun, counts open divergences only,
  and puts each suffix before the closing period.
- **`--check`'s first line** takes the same singular (`1 open divergence`); d369's runner raised it.

**Found in passing, fixed:** the full render's `Accepted` example quoted this repo's own EPIC-001 and EPIC-010 with
the "task-only on purpose" reason corrected in ae020d1, a copy of a drill target that TASK-210's rule forbids. It now
uses invented ids and an invented reason.

**Step-6 split.** Behavioural: d369 (the original brief, at the fix). Text: the `Not checked` line absent at HEAD,
present at the fix.

**Close gate (inline, worked with its sibling task; two skill files plus two specs):**
- **Standards:** each choice is stated in the verb that renders it; the singular rule points at the snapshot's.
- **Intent:** all criteria met.
- **Correctness:** checked by d369 and d376; the readings they raised on this change are fixed (below).
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

**One-runner readings, recorded:** d369 — whether `--check` includes the "Tracked in one tree only" section, whether
an epic's acceptance folds its stories into one accepted entry in the count, and no rule for the file when open and
accepted findings mix.

## Progress log

- step 2 — picked together with TASK-376, as its Context asks: both settle `triage`'s remaining rendering choices in one file
- step 5 — fix in skills/tasks/verbs/triage.md (steps 3b, 5, 9) and skills/roadmap/SKILL.md (DV10 step 4, render step 3)
- step 6 — behavioural: d369 (the d032 brief at the fix; neither reading returned). Text: `Not checked` 0 → 1
- step 7 — respecced project-roadmap (DV10's undecided output, the outcome line's singular) and work-tracking (the summary line), restamped
- step 8 — closed inline; commit in git log
