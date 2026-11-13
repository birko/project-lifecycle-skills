---
id: TASK-356
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-102-1, DRILL-102-2, DRILL-102-3, DRILL-102-4, DRILL-102-5, DRILL-102-6, DRILL-102-7]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `adopt-project`'s survey and report leave seven readings that several cold runners each settled differently

## Context

Filed 2026-11-13 from a cross-drill comparison. Six cold drills of `adopt-project` ran that day, each a fresh copy of
the `d065` fixture under `%LOCALAPPDATA%/Temp/`, with briefs and reports kept there:
- `d065b/scoped` and `d065b/full`, for TASK-065;
- `d353`, for TASK-353;
- `d354`, for TASK-354;
- `d102` and `d102b`, for TASK-102.

Each drill recorded its one-runner readings on its own task as "not filed". Compared across drills, these seven
were raised by **two or more runners independently**, the agreement bar FEATURE-002 D10 sets. They are a group
because all of them are about what the survey decides or where the report puts it, in
`skills/adopt-project/SKILL.md`, `INFER.md` and `skills/new-project/LAYER.md`.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-102-1 | `INFER.md` says to "record that they are empty pending a real decision" for Conventions subsections it could not infer, but not **where**. Writing it into the guide would amend it unasked, so every runner put it in the report only | d065b/full, d354, d102, d102b |
| DRILL-102-2 | `docs/architecture.md`'s row says "Leave it; report if absent". Nothing says whether that absence is `missing` or `missing, not offered` | d354, d102, d102b |
| DRILL-102-3 | the licence question and the guide-choice question have no stated wording, unlike the tasks questions. "Each in the words step 2 would use" has no words to point at | d065b/scoped, d353, d102b |
| DRILL-102-4 | the Dockerfile row: "a CLI shipped as a hosted container job is a Yes" against "run mode is settled by what the entry point does". Is a run-once script with no deploy evidence a derived No or `unknown`? | d065b/scoped, d353, d354 |
| DRILL-102-5 | step 1 detects facts that are not rows (stack, remote, ancestor repo, uncommitted state, kind). Only the `run:` line and the table have a stated place | d065b/scoped, d353 |
| DRILL-102-6 | a scoped run prints "one line per step that did not run". Whether 3b and 3c count as steps is unstated | d065b/scoped, d353 |
| DRILL-102-7 | the `.gitignore` row says to offer the lines. A scoped run writes nothing, and whether it still names the offer is unstated | d065b/scoped, d353 |

**Added 2026-11-13 from TASK-360's drill (`%LOCALAPPDATA%/Temp/d360`, point 1):** DRILL-102-3's missing wording
covers the **task mode** question too, when adoption puts it in its own round. Its runner borrowed wording from
`tasks`' mode-detection flow and from `new-project`'s intake.

## Acceptance criteria

- [x] DRILL-102-1 … 7 each have one stated answer, in the file that owns the rule (`LAYER.md` for a row's state,
      `adopt-project` for the run and its report, `INFER.md` for the inference round)
- [x] Nothing that LAYER.md owns is restated in `adopt-project`; it is pointed at
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where questions and offers are put: TASK-102 (done)
- Pinning a test runner with no manifest: TASK-072
- The fill-side readings (regeneration, template fields, `docs/features/`, empty renders, the negation): TASK-357

## Human test plan

- [x] Re-run the `d065b` scoped brief and the full brief, each on a fresh copy of `d065/adopted` (and `d065/fresh` for
      the scoped one) and of `skills/`, with a cold runner each. Expected: none of DRILL-102-1 … 7 in either
      "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d356`:
    - `s/`: the scoped brief on fresh copies of `d065/adopted` and `d065/fresh`;
    - `f/`: the full brief on a fresh `d065/adopted`;
    - both with `skills/` at this fix, using TASK-065's and d065b/full's runner commands.
    - **Coldness:** both runners listed no skills and had no Skill tool. The scoped repos were unchanged afterwards.
    - **None of DRILL-102-1 … 7 is in either "left undecided" list.**
      - The scoped run printed a `Detected:` block, and `step 2|3|3b|3c not run — scoped run` for both repos.
      - It listed the fill item under `asked by a full run, not this one:`.
      - The full run put the licence question verbatim ("What licence is this repo under? · MIT · Apache-2.0 ·
        proprietary · none") and left `LICENSE` `unknown` with no answer.
    - **The scoped runner's points, fixed at the close and not re-drilled:**
      - **4:** my word "plain missing" collided with the re-run wording;
      - **8:** licensing posture was missing from the `Detected:` list;
      - **2:** there was no verdict wording for a scoped run with missing rows. It is now `not complete: <n>
        missing, …`. d065b/scoped had raised it too (5f);
      - **1:** whether proposals count as unasked questions. Yes, now. d353 had raised it too (9).
    - **Cross-drill:**
      - the scoped point 9 and d072/a point 10, CI offered to a repo with nothing to test, are now DRILL-102-13 on
        TASK-357;
      - the full run's points 2, 3 and 5, and the scoped run's 3, are TASK-357's;
      - the full run's 6 is TASK-361's.
    - **Recorded here, one runner each:**
      - **scoped:** a bucket for offers a scoped run never made; an empty ladder as `missing` rather than `unknown`;
        the fill item for a repo with no `.gitignore`;
      - **full:** INFER's structural exception; UI/UX for printed output; the CI host with no remote; resolving
        unmapped files without asking; removing the features-index hint comments.

## Implementation plan

_Populated by `/tasks plan TASK-356` — leave empty until then._

## Outcome

**The fix.** Seven open points in `/adopt-project`'s survey and report, each raised by two to four runners, now
have one stated answer each:
- **Empty Conventions subsections** are recorded in the report, never written into the guide unasked.
- **`docs/architecture.md`** absent is `missing`, never created or offered.
- **The setup questions have stated words:** mode is pointed at `tasks`' own question, and guide file and licence
  are written out. The guide defaults to `CLAUDE.md`. A licence is never defaulted.
- **The Dockerfile row:** a container job is a Yes only on evidence of one, and a run-to-exit script with no deploy
  evidence is a derived No.
- **A `Detected:` block** beneath the survey table holds the facts that are no row.
- **A scoped run** prints a "not run" line for each of steps 2, 3, 3b and 3c, lists the fill item and any proposals
  as unasked, and says `not complete: …` when rows are missing.
- **The TASK-360 sentence** that claimed no setup question is answered by default is corrected. Mode and guide do
  default, and each default is now reported as nobody's choice.

**Step-6 split.**
- **Text assertions:** 8 of 8 fail on `HEAD`'s copies and pass on the fix, all fix-dependent. The script is
  `task356-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** the readings were raised by the drills listed in Context, on the old text.
  - **After:** the d356 scoped and full runners raised none of them.
- **Contract pins, not evidence:** skills-lint, and the checks for TASK-353, 354, 102, 072 and 360, which all still
  pass.

**Judgement calls.**
- **No decision was asked.** Each answer is either what every runner already converged on (report-only empty
  subsections, `missing`, a `Detected:` block, a line per step), or an existing rule applied: the run-mode rule for
  the Dockerfile, and new-project's defaults for the guide file. None changes what adoption writes into a user's
  repo.
- **A licence never defaults.** A guide-file default is reversible and harmless. A licence default is a legal
  statement nobody made.
- **The setup wording points at `tasks`' mode question and does not copy it.** The guide and licence wording is
  written here because no other skill words them.

**Close gate (inline, about 40 lines over three files):**
- **Standards:** every new ask has its question and its no-answer path. LAYER owns the row states, and
  `adopt-project` points at them.
- **Intent:** criteria met.
- **Correctness:** four follow-ups from the scoped drill were fixed before the close.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-357** gained DRILL-102-13 (CI offered to a repo with nothing to test, two runners).
- **One-runner readings** are under the Human test plan.

## Progress log

- step 2 — picked; ranked above TASK-357, TASK-361 and TASK-099 (same story, correctness-invariants, key 6 inert) because its readings were each raised by 2–4 runners (key 5) and each changes what the survey reports to the user (key 3: a silently different report per run)
- step 3 — verified: held, all seven still open in the text; DRILL-102-3 widened to the task-mode question by d360
- step 3b — planned inline (three files, three criteria): one stated answer per reading in its owning file
- step 4 — layer: local
- step 5 — fix in skills/adopt-project/SKILL.md (Detected block; scoped-run not-run lines and fill item; the setup questions' words, and the TASK-360 sentence corrected to "a stated no-answer outcome that records nobody chose it"), skills/adopt-project/INFER.md (empty subsections recorded in the report), skills/new-project/LAYER.md (architecture.md plain missing; container job needs evidence)
- step 6 — reverted fix (HEAD copies): 8/8 assertions failed; fix-dependent = I1–I8; contract pins = skills-lint and the earlier tasks' checks (all still pass). Behaviour: scoped and full drills running (d356)
- step 7 — respecced project-baseline (survey table, scoped runs, setup wording), surgical, restamped; intended — TASK-356 criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
