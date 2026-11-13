---
id: TASK-366
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-358-1, DRILL-358-2]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The dashboard template leaves its column padding and its timestamp's time zone to the reader

## Context

Filed 2026-11-13 at TASK-358's close. Two cold runners rendered `tasks/README.md` through `/tasks block` → `triage`
on fresh copies of `d212/repo`: `%LOCALAPPDATA%/Temp/d348b` and `d358`, with reports kept there. Both raised these,
which meets FEATURE-002 D10's bar. Each was recorded as one-runner on TASK-348 before the second report existed.

- **DRILL-358-1 — column padding.** `templates/README.md.tmpl` pads its counts table for the width of the placeholder
  names (`| planned      | {{EP_PLANNED}}     |`). Nothing says whether to re-pad once the values are filled, so both
  runners left the columns ragged. (The bare `/tasks` snapshot settled the same question for itself in TASK-355:
  fields are never padded into columns.)
- **DRILL-358-2 — the timestamp's time zone.** `{{TIMESTAMP}}` is "current date/time, e.g. `2026-05-28 14:32`", with
  no zone. Both runners used local time from `date`, and neither could say whether that was intended.

## Acceptance criteria

- [x] `triage` states whether the counts table is re-padded after filling, consistent with or explicitly different
      from the snapshot's TASK-355 rule
- [x] `triage` states the timestamp's time zone (local, UTC, or with an offset), and `/feature status`'s index, which
      reuses the format, agrees
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Blank lines and tree-row fields: TASK-358 (done)

## Human test plan

- [x] Re-run TASK-212's brief on a fresh copy of `d212/repo` with `skills/` at the fix, using a cold runner. Expected:
      neither DRILL-358-1 nor 2 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d366`: a fresh copy of `d212/repo`, `skills/` at this fix, and
    TASK-212's brief, run with TASK-212's runner command plus `Write` and `Edit`.
    - **Coldness:** no skills listed and no Skill tool.
    - **The dashboard it wrote:** counts cells padded to the template's widths, the long `blocked` cell running past
      without realigning the others, and the timestamp `2026-11-13 18:45`.
    - **Neither padding nor the time zone is among its undecided points.** It noted that it took "the template's
      column width" to mean the header row's, which is right.
    - **Cross-drill:** its `uncommitted: <files>` form (d358 too) and `{{PROJECT_NAME}}` against the README title
      (d358, and d360 for the features index) are filed as TASK-367.
    - **Recorded here, one runner each:** which of step 7's parts the fallback replaces; a two-way reading of
      `block`'s "Neither direction commits" sentence; step 5b's no-link line under `local`; the frontmatter's blank
      line; the overlap note's two homes.

## Implementation plan

_Populated by `/tasks plan TASK-366` — leave empty until then._

## Outcome

**The fix.** `/tasks triage` now states two things about `tasks/README.md`:
- **The timestamp is the machine's local time, with no zone.** It is for a person and nothing compares it.
  `/feature status`'s index takes the same form.
- **Each counts-table cell is padded to the template's column width.** A longer value runs past, and no other row is
  realigned, so a diff shows only the cells that moved.

**Step-6 split.**
- **Text assertions:** 2 of 2 fail on `HEAD`'s copies and pass on the fix, both fix-dependent. The script is
  `task366-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** the d348b and d358 runners both raised these.
  - **After:** d366 did not, and it padded the table as stated.
- **Contract pin, not evidence:** skills-lint.

**Judgement calls.**
- **Padding differs from the snapshot on purpose.** The snapshot is stdout and never pads (TASK-355). This is a file
  people diff, where fixed widths keep a change to the cells that changed. The rule names the difference, so neither
  reads as a mistake beside the other.
- **Local time, not UTC, because that is what this repo's own dashboard has always carried**, and a zone adds width
  to a line nobody compares.
- **A task id was kept out of the skill text.** The draft cited TASK-355, which means nothing in a consumer install,
  and now points at § *Status snapshot*.

**Close gate (inline, about 8 lines over two files):**
- **Standards:** each rule sits in its owner, and `/feature status` points at `triage`.
- **Intent:** criteria met.
- **Correctness:** the task-id citation was fixed.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-367**, filed.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; follows TASK-358 in the same template (correctness-invariants, key 6 inert), two two-runner readings, no open question (keys 4–5)
- step 3 — verified: held; triage step 7 names `{{TIMESTAMP}}` "current date/time" with no zone and says nothing about padding
- step 3b — not planned: two short answers, two files
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/triage.md step 7 (timestamp local, no zone; counts cells padded to template width, overflow allowed, no realignment) and skills/feature/verbs/status.md (timestamp takes triage's form)
- step 6 — reverted fix (HEAD copies): 2/2 assertions failed; fix-dependent = P1, P2; contract pins = skills-lint
- step 7 — respecced work-tracking (Generated dashboard), surgical, restamped (also corrects TASK-358's blank-line phrase to the wording it shipped). feature-lifecycle not edited: it does not state the timestamp form
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
