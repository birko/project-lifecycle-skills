---
id: TASK-349
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-238-2, DRILL-238-3, DRILL-238-4]
pr: null
github-issue: null
jira-key: null
---

# `/specs verify` and `show` leave three rendering details to the reader

## Context

Spawned 2026-11-12 from TASK-238's Human test plan drill: one cold run of `/specs verify` and `/specs show core` on an
invented fixture (`%LOCALAPPDATA%/Temp/d238`, report kept there as `report.md`). **Raised by one runner only**, so each
is a candidate to confirm, not a measured defect. The drill's one substantive reading, DRILL-238-1 (equal committer
dates, no tie rule), was fixed inside TASK-238. It is a group: three small rendering readings from one drill.

- **DRILL-238-2:** `verify`'s render template fixes the nouns (`<A> areas`, `<k> changed sources`), so one area prints
  `1 areas` and one file `1 sources`. Nothing says whether to inflect.
- **DRILL-238-3:** `show` step 3 says "Suggest `/specs regen <area>` to fill it" for a never-derived `shaped-by`, with
  no wording and no place (header line, footer, or a line of its own).
- **DRILL-238-4:** `show`'s footer `<anchor short sha>` gives no length. git's default abbreviation varies with the size
  of the repository, so two runs can print different lengths for one sha.

## Acceptance criteria

- [ ] Each of DRILL-238-2 … 4 is either confirmed by a second cold runner and then answered in `verify.md` or `show.md`, or recorded here as not reproduced
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-map message, the unmapped scan set, the footer's anchor, uncommitted edits, the unknown-baseline line and the equal-date tie — TASK-238

## Human test plan

- [ ] Re-run TASK-238's brief (in `%LOCALAPPDATA%/Temp/d238/brief.txt`, fixture recipe on TASK-238) with a cold runner. Expected: none of the confirmed findings in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-349` — leave empty until then._
