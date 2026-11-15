---
id: TASK-381
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
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
picked-by: fix-next
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

- [x] DRILL-REFRESH-1 … 4 each have one stated answer in the verb that renders it — 1 and 2 in `feature/verbs/status.md` step 4 (and step 6's pointer), 3 and 4 in `tasks/verbs/triage.md` steps 8b and 4b
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- **Whether FEATURE-003's playground still stands.** Both runs also read its `## Prototype` line as **Built** while the
  line says to delete the page once D1–D3 are stamped, which they are. That is a fact about the repo, not a rendering
  rule, and it waits on the owner (TASK-374, behind TASK-124)
- The single-runner readings of the same runs (the quiet drift line spelled with and without backticks in the two
  files; DV9 checked against `decisions.md` as a whole rather than its `→ Tasks` column)

## Human test plan

- [x] Re-run the refresh on a fresh clone with a cold runner, twice, `skills/` at the fix (the brief is
      `%LOCALAPPDATA%/Temp/drefresh/brief.txt`). Expected: the two runs differ only in timestamps, and none of
      DRILL-REFRESH-1 … 4 is in either "left undecided" section
  - **Passed 2026-11-15**, cold runners: `claude -p --disable-slash-commands --permission-mode acceptEdits`, the
    drefresh brief, a fresh clone and `skill/` at the fix; each report lists no skills. `%LOCALAPPDATA%/Temp/d381`
    ran it twice: the runs differed only in timestamp lines, and neither raised DRILL-REFRESH-1 … 4. It also showed
    the fix's first prototype rule (*opens with a bold state word*) was too narrow: FEATURE-003, 004 and 005 open
    with a plain `Built —` / `Skipped —` and rendered "none yet". Corrected to *bold or plain*, then
    `%LOCALAPPDATA%/Temp/d381b` (a clone in a folder named for the project, so the title derives right) rendered
    `1 / 1 task done.`, the digest's `(1/1 task, …)`, all five prototype lines including FEATURE-003's playground
    link, and the drift line above `_Generated …_`; none of the four in its undecided points.

## Implementation plan

Not planned (step 3b): two verb files, two criteria.

## Outcome

**What was fixed:** four rendering choices both refresh runners had to make for themselves now have one answer each.
- **Counts (`/feature status`):** the singular-for-1 rule covers every count the verb prints, including the template's
  `tasks done.` (`1 / 1 task done.`) and the digest.
- **Prototype line:** the state is the section's first paragraph opening with a state word, bold or plain, rendered
  alone on one line; the placeholder hint and later notes are not rendered.
- **Drift callout (`/tasks triage` 8b):** under the title, above the `_Generated …_` line.
- **Parents callout fix text (4b):** everything before the ` — `, whole, with the first row's text spelled out.

**Step 6, as a split:** the old text, 4 of 4 readings raised by 2 of 2 runners (drefresh, drefresh2); the fixed text,
0 of 4 by 3 runners (d381 twice, d381b). No automated test: prose, so the cold drill is the instrument.

**Judgement calls:**
- The callout goes **above** `_Generated …_`, matching what every runner had already done, so no dashboard moves.
- The fix text includes "or keep it open": dropping it would print `/tasks close` as the only fix, which `close`
  step 11 contradicts. The stricter option, the command alone, was rejected for that reason.
- **A regression the drill caught in this fix:** the first prototype rule required a bold state word, and three
  features write it plain. Caught by d381's second runner and corrected before close.

**Flagged, not fixed:** single-runner readings from d381/d381b: signed-off features still list "Ready to test";
the digest's short example title against the full `# Heading`; FEATURE-003's playground still standing (TASK-374,
out of scope here). TASK-073's "second status line" a runner noticed is a quoted template in its body, not a defect.

**Close gate (inline; two verb files, two specs):** standards and intent met; correctness by d381/d381b; layer
parity, security, comments not applicable; local lint passes; feature-lifecycle and work-tracking respecced.

## Progress log

- step 2 — picked; ranked above TASK-382 because keys 1–3 tie (an instruction runners read differently; reachable on every run; silent) and key 4 separates: four rendering rules with no open design question, against three readings one of which (DRILL-024-3) is a design question
- step 3 — verified: held — all four still read as filed (status.md step 4's count sentence sits under the next-step table; {{PROTOTYPE_LINK}} assumes one line; triage 8b says "directly under the title" beside the _Generated_ line; step 4b's "the dash" is unnamed); the d380-era refresh (drefresh2) raised all four again
- step 3b — not planned: two files and a template, 2 criteria, no feature:, no unknowns
- step 4 — layer: local
- step 5 — fix in skills/feature/verbs/status.md (steps 4, 6) and skills/tasks/verbs/triage.md (4b, 8b); no test file (prose)
- step 6 — old text 4/4 raised by 2/2 runners; fixed 0/4 by 3 runners; the bold-only prototype rule regressed three features and was corrected (d381 → d381b)
- step 7 — respecced feature-lifecycle (count rule, prototype line), work-tracking (callout position, fix text)
- step 8 — closed inline; outcome in status:, commit in git log
