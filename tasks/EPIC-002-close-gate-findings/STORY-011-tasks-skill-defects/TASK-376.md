---
id: TASK-376
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
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

- [ ] `triage.md` states each of the three, in one sentence each
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The tree's own shape: TASK-368 (done)
- Parents that contradict their children: TASK-375

## Human test plan

- [ ] Run `/tasks triage` with a cold runner on a fresh clone of this repo with `skills/` at the fix. Expected: none
      of the three is reported undecided
