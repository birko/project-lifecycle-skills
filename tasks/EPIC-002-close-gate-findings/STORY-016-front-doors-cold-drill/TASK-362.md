---
id: TASK-362
parent: STORY-016
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
findings: [DRILL-357-1, DRILL-357-2, DRILL-357-3, DRILL-357-4, DRILL-357-5]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Five more adoption readings that a second cold runner has now raised

## Context

Filed 2026-11-13 at TASK-357's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d357`, `report.md`, § 7)
against the session's other adoption drills under `%LOCALAPPDATA%/Temp/`. Each reading below was recorded as a
one-runner reading on an earlier task, and d357 raised it again, which meets FEATURE-002 D10's bar. They are a
group because each is a small gap in what a full adoption writes or reports.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-357-1 | INFER's UI / UX subsection: whether a program whose only output is `print` lines counts as "output formatted for a reader". Every runner fell back to "evidence that settles neither way → count it as applicable", and two flagged it as undecided | d356/f, d357 |
| DRILL-357-2 | `/specs init`'s "Offer the first harvest" comes up inside the delegation. Whether it is an offer "found after the round" (reported, not asked) is unstated, because adopt's exception names only `populate-tests`' `.gitignore` lines | d360, d357 |
| DRILL-357-3 | `.gitattributes` and `.editorconfig`: the row says "Create if absent" and gives no shape, owner or template, so each runner wrote its own content | d102b, d357 |
| DRILL-357-4 | the `tasks/` row's state in a **full** run's table, printed before `/tasks init` answers. `present, owner not asked` is scoped-only, so runners printed `present` with an ad-hoc note | d065b/full, d357 |
| DRILL-357-5 | `/specs init`'s unmapped files: "which of the three is a judgement" and "where that reconciliation needs the user, put this question" never say when the user is needed. Runners sent the docs, `tasks/` and `*.md` to `ignore` without asking. Asking, with no answer, would leave them unmapped and change what `verify` reports (added at TASK-361's close) | d356/f, d361 |

## Acceptance criteria

- [x] DRILL-357-1 … 5 each have one stated answer, in the file that owns the rule (`INFER.md`, `adopt-project`,
      `LAYER.md`)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The specs scan set and adoption's own files: TASK-361
- Everything TASK-356 and TASK-357 settled

## Human test plan

- [x] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-357-1 … 5 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d362`: a fresh copy of `d065/adopted`, `skills/` at this fix, and the
    d065b full brief, run with d065b/full's runner command.
    - **Coldness:** no skills listed and no Skill tool.
    - **What the run did:**
      - the `tasks/` row read `present — /tasks init answers in step 3`;
      - the inference round named "Output / UX applies — print() output read by a person";
      - the next steps ended with `/specs regen --all`;
      - housekeeping files went to `ignore` without a question;
      - neither the dotfile content nor the harvest offer came up as undecided.
    - **None of DRILL-357-1 … 5 is in its undecided list.**
    - **Cross-drill:** its re-run prefix on `missing, not offered` (d357 too), the § Testing `<path>` with no tests
      (d072/b too) and spec findings in the features index (d357 too) now have two runners each, and are filed as
      TASK-363.
    - **Recorded here, one runner each:**
      - whether `## Commands` gets its own fill letter;
      - an absent owner row's table form;
      - `coverage-drift` on a first discovery;
      - the order of two delegation-time questions;
      - optional template blocks making the row `amended`, which TASK-357 settled and the runner read correctly.

## Implementation plan

_Populated by `/tasks plan TASK-362` — leave empty until then._

## Outcome

**The fix.** Five more adoption readings now have one stated answer each:
- **A program that prints for a person to read has an Output / UX surface**, however plain its lines, the same test
  `new-project` uses.
- **`/specs init` chained from an adoption hands its first-harvest offer back**, and the adoption names
  `/specs regen --all` in its next steps.
- **`.gitattributes` and `.editorconfig`** take `new-project`'s step-3 content.
- **A row whose owner verb answers later reads `present — <verb> answers in step 3`** in a full run's table.
- **`/specs init` sends a file that was never project source to `ignore` without asking.** Only a file that may be
  behaviour gets the question.

**Step-6 split.**
- **Text assertions:** 5 of 5 fail on `HEAD`'s copies and pass on the fix, all fix-dependent. The script is
  `task362-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** the readings were raised by the two runners each in Context.
  - **After:** d362 settled all five.
- **Contract pin, not evidence:** skills-lint.

**Judgement calls.**
- **The first draft of 357-1 was reversed before the drill.** It said plain `print` lines are not a surface. But
  INFER says it uses "the same test `new-project` uses", and `new-project` keeps Output / UX for any CLI humans read.
  Dropping it here would have broken layer parity, so the rule matches `new-project` and the runners' own reading.
- **Housekeeping goes to `ignore` unasked, because the classification already names those categories** as "never
  project source". Asking about each file would put a question with one sensible answer in front of every adoption,
  and with no answer leave them unmapped, a worse map than the judgement it avoids.
- **The harvest offer is handed back rather than asked late**, to keep adoption's one round. It is a token-spend
  suggestion, so a next-step line loses nothing.

**Close gate (inline, about 20 lines over four files):**
- **Standards:** layer parity holds (the parity break was caught before the drill), and each rule sits in its owner.
- **Intent:** criteria met.
- **Correctness:** none left.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-363**, filed: three readings that now have two runners.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; last of the 2026-11-13 adoption groups in STORY-016 (correctness-invariants, key 6 inert), each reading raised by two runners (key 5); ranked above TASK-099, which needs a rule designed (key 4)
- step 3 — verified: held, all five open in the text
- step 3b — planned inline (four files): one answer per reading in its owning file
- step 4 — layer: local
- step 5 — fix in adopt-project/INFER.md (printing for a person is a surface, matching new-project), specs/verbs/init.md (non-source to ignore unasked; harvest handed back when chained), new-project/LAYER.md (.gitattributes/.editorconfig content), adopt-project/SKILL.md (owner row in a full run; /specs regen in next steps). First draft of 357-1 said plain print lines are not a surface; reversed before the drill because new-project keeps Output / UX for any CLI humans read, and INFER claims the same test
- step 7 — respecced project-baseline and specs-from-code, surgical, restamped
- step 6 — reverted fix (HEAD copies): 5/5 assertions failed; fix-dependent = L1–L5; contract pins = skills-lint
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
