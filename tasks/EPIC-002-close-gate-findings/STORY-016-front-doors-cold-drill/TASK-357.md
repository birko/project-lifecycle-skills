---
id: TASK-357
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
findings: [DRILL-102-8, DRILL-102-9, DRILL-102-10, DRILL-102-11, DRILL-102-12, DRILL-102-13]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# A full adoption's fills leave six readings that several cold runners each settled differently

## Context

Filed 2026-11-13 from the same cross-drill comparison as TASK-356, which lists the six drills. Each drill recorded its
one-runner readings on its own task as "not filed". Compared across drills, these five were raised by **two or more
runners independently**, the agreement bar FEATURE-002 D10 sets. They are a group because all are about what a full
adoption writes during its fill (step 3) and its regeneration (step 3c), and the owner verbs it chains.

| Id | Reading | Raised by |
|---|---|---|
| DRILL-102-8 | step 3c re-runs a generator unless the result would be "a pure no-op". Whether a re-render that differs only in its `_Generated …_` timestamp counts is unstated | d065b/full, d354, d102, d102b |
| DRILL-102-9 | `/tasks init` reconciles "every field the template declares and the file lacks". Whether the template's commented blocks (`external:`, `siblings:`) count as declared fields, and whether a present field gains its missing comment block, is unstated | d354, d102, d102b |
| DRILL-102-10 | LAYER.md's `docs/features/` row says "Create the folder + index if absent" and names no verb, while `/feature status` owns the index. Runners each picked a route | d354, d102b |
| DRILL-102-11 | rendering an empty generated section: an empty tree in `tasks/README.md`, a features index with no rows, and whether the template's hint comments stay. Runners wrote `_No tasks yet._`, `_None_`, or dropped the section | d065b/full, d102, d102b |
| DRILL-102-12 | "check for the negation wherever that row applies": whether the `.gitignore` offer includes `!.env.example` when the `.env.example` row is `not applicable`. One runner left it out, one put it in | d354, d102b |
| DRILL-102-13 | the CI row offers "a minimal install→build→test workflow" to a repo with no tests yet. Its first run fails (`pytest` exits 5 when it collects nothing), so the offer would land a red gate. Nothing says whether to offer it, say so, or offer it without the test step (added 2026-11-13) | d072/a, d356/s |

## Acceptance criteria

- [x] DRILL-102-8 … 13 each have one stated answer, in the file that owns the rule (`adopt-project` step 3c,
      `tasks` `init` and `triage`, `feature` `status`, `LAYER.md`)
- [x] A rendered empty section reads the same in every generator that has one, or each states its own form
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Survey and report readings: TASK-356
- Pinning a test runner with no manifest: TASK-072
- Where offers are asked: TASK-102 (done)

## Human test plan

- [x] Re-run the `d065b` full brief on a fresh copy of `d065/adopted` and of `skills/` with a cold runner. Expected:
      none of DRILL-102-8 … 13 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d357`: a fresh copy of `d065/adopted`, `skills/` at this fix, and the
    d065b full brief, run with d065b/full's runner command.
    - **Coldness:** no skills listed and no Skill tool.
    - **Writes:** none committed. `CLAUDE.md` and `.gitignore` were untouched.
    - **What the run did:**
      - `docs/features/README.md` was "rendered by /feature status (created … it was absent)";
      - `/tasks init` added `external` and `siblings` "commented, undeclared", leaving the existing lines untouched;
      - neither the `_None_` renders nor the negation came up as undecided.
    - **Two points needed wording at the close, and are fixed (not re-drilled):**
      - **102-8:** the runner found the 3c no-op rule against `/tasks init` rewriting its dashboard every run. The
        row now says it governs 3c's own re-runs, and that an owner verb's write is reported as the verb's;
      - **102-13:** "nothing to build" was read as intended, but had to be interpreted. It is now defined: no compile
        or package step, as with an interpreted script with no manifest.
    - **Folded in:** its point 1, that a full run had no verdict wording. Every run now ends with one verdict line
      in one form, generalising TASK-356's scoped-only wording.
    - **Cross-drill:**
      - four of its points match an earlier runner's and are filed as TASK-362 (UI/UX for printed output, the
        specs harvest offer, `.gitattributes`/`.editorconfig` shape, the `tasks/` row before its owner answers);
      - its specs-scan point is TASK-361's.
    - **Recorded here, one runner each:**
      - `amended` claiming consent for an owner verb's reconciliation;
      - 3c's edge list missing new-map → drift callouts;
      - spec drift in the features index;
      - showing `## Commands` in an offer before it can be rendered;
      - the re-run prefix on `missing, not offered`;
      - whether one setup question plus the fill item is a round of one.

## Implementation plan

_Populated by `/tasks plan TASK-357` — leave empty until then._

## Outcome

**The fix.** Six open points in what a full adoption writes and regenerates now have one stated answer each:
- **A timestamp-only re-render is a no-op** for step 3c's own re-runs. An owner verb's own regeneration is its own,
  reported as such.
- **`/tasks init` treats the optional commented blocks (`external:`, `siblings:`) as declared fields**, and a field
  already live gains no comment block.
- **`docs/features/`'s index is rendered by `/feature status`**, or by its template under the same rules, and never
  composed by hand.
- **Empty generated sections render `_None_`**, in both the tasks dashboard tree and the features index, and
  template comments are never rendered.
- **The `!.env.example` negation is offered only where that row applies.**
- **No CI step is offered that the repo cannot pass today.** With no tests, the workflow is offered without the test
  step, and the offer says so. With nothing to build and no tests, CI is `missing, not offered: nothing to run yet`.

Folded in: every run, full or scoped, ends with one verdict line in one form.

**Step-6 split.**
- **Text assertions:** 7 of 7 fail on `HEAD`'s copies and pass on the fix, all fix-dependent. The script is
  `task357-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** the readings were raised on the old text by the drills in Context.
  - **After:** d357 settled them, and two needed one more sentence at the close.
- **Contract pins, not evidence:** skills-lint, and the TASK-356 checks, which still pass.

**Judgement calls.**
- **CI without the test step, rather than CI with a test step that tolerates "no tests".** A
  `pytest || [ $? -eq 5 ]` step hides a real "collected nothing" later. Leaving the step out and saying so is honest
  and is undone by adding it with the first test. Consistent with LAYER's existing *CI a repo cannot pass* rule:
  never offer a gate that fails on arrival.
- **`_None_`** because it is the form the tasks dashboard already uses for an empty list.
- **The features-index row covers both doors.** `new-project` renders the template itself, and that is allowed as
  "the same rules".
- **Spec stamps.**
  - `project-baseline` and `work-tracking` are restamped. Nothing in their sources changed since the last stamp
    without a respec.
  - `feature-lifecycle` is restamped too. Its one later source change, TASK-350, had already respecced it
    surgically without restamping.

**Close gate (inline, about 30 lines over five files):**
- **Standards:** layer parity holds, since the rows are in LAYER and `new-project`'s own index rendering stays
  valid. Owner verbs hold their own rules (init, triage, feature status).
- **Intent:** criteria met.
- **Correctness:** three wording points from the drill were fixed before the close.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged.**
- **TASK-362**, filed: four readings that now have two runners.
- **One-runner readings**, under the Human test plan.

## Progress log

- step 2 — picked; next in STORY-016 after TASK-356 (correctness-invariants, key 6 inert): six readings raised by 2–4 runners each (key 5), all writes or regenerations a full adoption makes (key 1)
- step 3 — verified: held, all six still open in the text
- step 3b — planned inline (five files, three criteria): one stated answer per reading in its owning file
- step 4 — layer: local
- step 5 — fix in adopt-project/SKILL.md (3c: timestamp-only no-op), tasks/verbs/init.md (optional blocks count; a live field gains no comment), new-project/LAYER.md (features index via /feature status; negation only where the row applies; no CI step the repo cannot pass), tasks/verbs/triage.md and feature/verbs/status.md (empty sections `_None_`; template comments never rendered)
- step 6 — reverted fix (HEAD copies): 7/7 assertions failed; fix-dependent = J1–J7; contract pins = skills-lint. Behaviour: full drill running (d357)
- step 7 — respecced project-baseline, work-tracking, feature-lifecycle (surgical); all three restamped — work-tracking and feature-lifecycle had no unspecced source change since their stamps (TASK-350 respecced feature-lifecycle without restamping); intended — TASK-357 criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
