---
id: TASK-381
parent: STORY-024
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
findings: [DRILL-REFRESH-1, DRILL-REFRESH-2, DRILL-REFRESH-3, DRILL-REFRESH-4]
pr: null
github-issue: null
jira-key: null
---

# Four rendering choices `/feature status` and `/tasks triage` still leave to the reader

## Context

Filed 2026-11-14 from the dashboard refresh committed as `753687d`: two cold runs of `/feature status` (all features)
then `/tasks triage` on a clone of this repo (`%LOCALAPPDATA%/Temp/drefresh`, `report1.md` and `report2.md`, § 3). Both
runs raised each reading below, so each meets FEATURE-002 D10's two-runner bar. Their outputs agreed, so the choices
happened to coincide; the text still does not make them.

| Id | Reading | Where |
|---|---|---|
| DRILL-REFRESH-1 | **The count rule stops at the next-step table.** "Every count noun is singular for a count of exactly 1" sits under `{{NEXT_STEP}}`, so both runs left the template's fixed `1 / 1 tasks done.` and the digest's `(1/1 tasks, …)` plural | `skills/feature/verbs/status.md` step 4, and step 6's digest |
| DRILL-REFRESH-2 | **A prototype section holding several paragraphs.** "renders as the `idea.md` line says, reason included" assumes one line; FEATURE-001's and FEATURE-002's `## Prototype` sections hold a placeholder hint, the **Skipped** paragraph and, on FEATURE-001, a further note. Both runs rendered the **Skipped** paragraph alone | `skills/feature/verbs/status.md` step 4, `{{PROTOTYPE_LINK}}` |
| DRILL-REFRESH-3 | **The drift callout's position.** triage step 8b: "prepend a callout to `tasks/README.md` directly under the title". Whether it goes above or below the template's `_Generated …_` line. d365 (TASK-365's drill) raised it too | `skills/tasks/verbs/triage.md` step 8b |
| DRILL-REFRESH-4 | **How much of the fix the parents callout prints.** Step 4b's table heads its last column "Fix (the callout prints the text before the dash)", and the cells read `` `/tasks close <ID>`, or keep it open — … ``. Whether "or keep it open" is part of "the text before the dash" | `skills/tasks/verbs/triage.md` step 4b |

## Acceptance criteria

- [ ] DRILL-REFRESH-1 … 4 each have one stated answer in the verb that renders it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Whether FEATURE-003's playground still stands.** Both runs also read its `## Prototype` line as **Built** while the
  line says to delete the page once D1–D3 are stamped, which they are. That is a fact about the repo, not a rendering
  rule, and it waits on the owner (TASK-374, behind TASK-124)
- The single-runner readings of the same runs (the quiet drift line spelled with and without backticks in the two
  files; DV9 checked against `decisions.md` as a whole rather than its `→ Tasks` column)

## Human test plan

- [ ] Re-run the refresh on a fresh clone with a cold runner, twice, `skills/` at the fix (the brief is
      `%LOCALAPPDATA%/Temp/drefresh/brief.txt`). Expected: the two runs differ only in timestamps, and none of
      DRILL-REFRESH-1 … 4 is in either "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-381` — leave empty until then._
