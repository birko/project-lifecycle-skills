---
id: TASK-376
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
picked-by: fix-next
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-368-1, DRILL-368-2, DRILL-368-3]
pr: null
github-issue: null
jira-key: null
---

# `triage` leaves three dashboard sections to the runner: the verification heading, the Loose section's contents, and the summary with only accepted drift

## Context

Filed 2026-11-14 at TASK-368's close. The five cold `triage` runs of `%LOCALAPPDATA%/Temp/d368` (`report-run1.md` to
`report-run5.md`) and the second run of `d375` each named some of these undecided. Every runner resolved them the
same way, so the dashboard does not vary today, but by convergence rather than by rule.

- **DRILL-368-1 — the "Awaiting verification" heading.** Step 3b names the section and `{{INREVIEW_SECTION}}` gives
  no heading text. All used `## Awaiting verification`. Raised by d368 runs 1, 2, 4 and 5.
- **DRILL-368-2 — what the Loose section lists.** Step 5's example shows an open task only, and `SKILL.md` says the
  dashboard "hides done items by default". All listed every loose task, done ones included. Raised by d368 runs 1,
  4 and 5, and d375 run 2.
- **DRILL-368-3 — the summary line when the only finding is accepted.** "Append `; <n> feature divergence(s)` when
  step 8b found any" does not say whether an accepted finding counts. All appended nothing. Raised by d368 runs 1
  and 5, and d375 run 2. TASK-369 owns the same line's singular form, so take the two together.

## Acceptance criteria

- [x] `triage.md` states each of the three, in one sentence each
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The tree's own shape: TASK-368 (done)
- Parents that contradict their children: TASK-375

## Human test plan

- [x] Run `/tasks triage` with a cold runner on a fresh clone of this repo with `skills/` at the fix. Expected: none
      of the three is reported undecided
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d376`: `/tasks triage` on a fresh clone of this repo,
    `skills/` at the fix, the runner listing no skills. None of the three came back: the file has
    `## Awaiting verification`, a Loose section listing every loose task with its markers, and the summary
    `Dashboard refreshed: 10 epics, 28 stories, 377 tasks (0 in progress); 4 parents out of step`, with no divergence
    suffix for the accepted-only drift.

## Outcome

**The fix (`triage.md`).** Step 3b names the heading `## Awaiting verification` and carries step 3's blocked suffix;
step 5 lists every loose task, closed ones included, in the task order with step 4's markers, because a loose task has
no Completed entry to fall into; step 9 counts open divergences only, an accepted one already having the file's quiet
line.

**Two readings on this session's own text, fixed before the close:**
- **Where the suffixes go** on the summary line: before the closing period. Raised by d376 point 1 and d375b point 3.
- **What an epic's children are** in step 4b: its stories and any task parented to it directly, each by its own
  status. Raised by d376 point 2.

**Step-6 split.** Behavioural: d376. Text: the stated heading and the Loose rule absent at HEAD, present at the fix.

**Close gate (inline, worked with its sibling task; two skill files plus two specs):**
- **Standards:** each choice is stated in the verb that renders it; the singular rule points at the snapshot's.
- **Intent:** all criteria met.
- **Correctness:** checked by d369 and d376; the readings they raised on this change are fixed (below).
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

## Progress log

- step 2 — picked together with TASK-369, as its Context asks: both settle `triage`'s remaining rendering choices in one file
- step 5 — fix in skills/tasks/verbs/triage.md (steps 3b, 5, 9) and skills/roadmap/SKILL.md (DV10 step 4, render step 3)
- step 6 — behavioural: d376 (none of the three returned). Text: heading and Loose rule 0 → 1
- step 7 — respecced work-tracking (the dashboard requirement states the heading, the Loose contents and the summary line), restamped
- step 8 — closed inline; commit in git log
