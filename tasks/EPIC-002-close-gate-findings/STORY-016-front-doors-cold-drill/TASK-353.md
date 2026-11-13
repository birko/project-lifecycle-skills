---
id: TASK-353
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-12
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-065-1, DRILL-065-2, DRILL-065-3]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# `adopt-project`'s report has no stated place for a derived "not applicable", and two more readings are open

## Context

Spawned 2026-11-12 from TASK-065's Human test plan drill: one cold scoped survey of two invented repos
(`%LOCALAPPDATA%/Temp/d065`, report kept there as `report.md`). Raised by one runner. These predate TASK-065, which
did not touch them. A group: three readings in the survey and report.

- **DRILL-065-1 — the two files disagree on reporting a derived No.** `skills/new-project/LAYER.md` says `adopt-project`
  "has no `not applicable` entry in its per-state report list at all … a derived No is currently still silent".
  `adopt-project/SKILL.md` step 4 says "a state added there that no outcome bucket absorbs gets a bucket here named
  after it". The runner followed step 4 and printed a `not applicable` bucket. One of the two sentences is wrong.
- **DRILL-065-2 — an undeclared `workspace:` under `single-branch`.** LAYER.md says an absent `workspace:` is asked with
  `tasks init`'s question. `init` skips that question under `integration: single-branch`. Neither says what the survey
  row reports, an outstanding declaration or a settled one.
- **DRILL-065-3 — the closing next step on a repo with no `tasks/`.** Step 4 ends with `/tasks new` as a next step,
  printed on a repo where `tasks/` is `missing` and there is nothing for it to write into.

## Acceptance criteria

- [x] LAYER.md and `adopt-project` step 4 agree on whether, and where, a derived `not applicable` is reported
- [x] The survey states what an absent `workspace:` reports under `integration: single-branch`
- [x] Step 4's next step fits a repo with no `tasks/`, or says why it does not need to
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Scoped runs and the run line — TASK-065

## Human test plan

- [x] Re-run TASK-065's brief (`%LOCALAPPDATA%/Temp/d065/brief.txt`, fixture recipe on TASK-065) with a cold runner. Expected: none of DRILL-065-1 … 3 in its "left undecided" section
  - **Passed 2026-11-13.** `%LOCALAPPDATA%/Temp/d353`: fresh copies of `d065/adopted` and `d065/fresh`, `skills/` at
    this fix, and the 11-12 brief unchanged, run with TASK-065's runner command.
    - **Coldness:** no skills listed and no Skill tool.
    - **Repo state:** both repos unchanged afterwards.
    - **065-1:** both reports print a `not applicable:` bucket with the derived-No lines, and the runner raised no
      conflict.
    - **065-2:** the `tasks/` row reads `workspace undeclared — tasks work in place (not asked: single-branch)`, and
      the runner listed it as settled.
    - **065-3:** `fresh/` ended `Next: /adopt-project to fill the layer, beginning with tasks/.`
    - **One reading came from this task's own wording.** The runner read "(a scoped run, or a fill the user declined)"
      as "every scoped run". It was reworded at the close to key on whether `tasks/` exists when the run ends, and
      was not re-drilled.
    - **New readings, recorded here and not filed:**
      - fresh/'s workspace question when `integration:` is answered in the same round;
      - no stated wording for the licence and guide-choice questions;
      - "three buckets" heading a list of four;
      - whether a scoped run still offers the `.gitignore` line;
      - where unfilled `missing` rows go.
      Its point 9, whether a scoped run lists a missing row's fill offer, is TASK-102's open question.

## Implementation plan

Drafted 2026-11-13 by `/fix-next`, as `/tasks plan --no-grill` would write it (triggers: two files, four criteria).

| Reading | Answer | Where |
|---|---|---|
| 065-1 | step 4 gains a `not applicable` entry: a **derived** No gets one line naming what carried it, while a stated or declared No stays silent, as LAYER § *Conditional rows* already rules. LAYER's paragraph stops calling the adopter silent and drops its pointer to the cancelled TASK-112 | `adopt-project/SKILL.md` step 4; `LAYER.md` § *Conditional rows* |
| 065-2 | under `integration: single-branch` an absent `workspace:` is **settled**, never outstanding: `init` skips the question there. The row reports it undeclared, with the reason | `LAYER.md`'s `tasks/` row |
| 065-3 | a run that ends with no `tasks/` (a scoped run, or a declined fill) names the adoption, not `/tasks new`, as the next step | `adopt-project/SKILL.md` step 4 |

**065-1 overlaps TASK-085**, which absorbed TASK-112's criteria for this entry. This task does the narrow half, the
entry and the paragraph. TASK-085 keeps its restructure of the state list. Its *From TASK-112* criteria and its
SH-55 line are ticked there with a pointer here.

**Evidence the readings hold:**
- 065-1 was raised again by the TASK-065 scoped runner (d065b, 5e). It printed the bucket by following step 4's
  general rule against LAYER's sentence.
- 065-2 was raised again by both d065b runners (scoped 5a, full 7).
- 065-3 is one runner (d065). Neither d065b fixture lacked `tasks/`.

## Outcome

**The fix.**
- **Derived No in the report.** `adopt-project`'s report now has a `not applicable` entry: a No the run derived gets
  one line naming what carried it, and a No the user stated or the repo declares stays silent. LAYER.md no longer
  says the adopter is silent there, and no longer points at the cancelled TASK-112.
- **`workspace:` under `single-branch`.** An absent `workspace:` is settled, not outstanding, because `init` skips
  the question there. The row says so.
- **The closing next step.** When `tasks/` does not exist at the end of a run, the report sends the user to
  `/adopt-project`, not to `/tasks new`.

**Step-6 split.**
- **Text assertions:** 4 of 4 fail on `HEAD`'s copies and pass on the fix, all fix-dependent: the entry, the LAYER
  paragraph, the single-branch rule and the next step. The script is `task353-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** 065-1 and 065-2 were raised by the 11-12 runner and again by both 11-13 TASK-065 runners. 065-3 was
    raised by the 11-12 runner.
  - **After:** the d353 runner settled all three.
- **Contract pin, not evidence:** skills-lint.

**Judgement calls.**
- **TASK-085's overlap.** TASK-112, which TASK-085 absorbed, asked for exactly 065-1's entry. Doing it here and
  ticking those criteria on TASK-085 with a pointer avoids two tasks owning one line. TASK-085's actual subject, the
  restructure of the state list, is untouched and stays open.
- **Single-branch `workspace:` is settled, not asked.** Asking would put a question whose answer can change nothing
  into the one round. Leaving it outstanding is what made both runners invent a state for it.
- **Spec stamps.** Both `project-baseline` and `work-tracking` were restamped to `118e7f8`, the commit before this
  one. The `work-tracking` stamp had been left at `b36aaf0` through TASK-355, 347 and 348, whose surgical respecs
  edited it without restamping.

**Close gate (inline, about 20 lines of prose over two files):**
- **Standards:** layer parity holds. The rule is in LAYER.md, the one inventory, and `new-project`'s step-6 checklist
  already prints its own derived-No line. The step-4 entry points at LAYER, never copies it.
- **Intent:** criteria 1–4 met.
- **Correctness:** the runner's ambiguity in the new next-step wording was fixed before the close.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged, not fixed.** Five one-runner readings, listed under the Human test plan.

Filed 2026-11-13, after comparing all six adoption drills: the readings here that a second runner also raised are TASK-356 (licence and guide-choice wording, the scoped `.gitignore` offer, step 1 facts, not-run lines).

## Progress log

- step 2 — picked; ranked above TASK-354, TASK-099 and TASK-102 (all correctness-invariants in STORY-016, key 6 inert) because two of its three readings were raised again by the TASK-065 full-pass drill runners on 2026-11-13, so they meet the two-runner bar (key 5), and each has a short stated answer (key 4). TASK-099 and TASK-102 each ask for a rule to be designed
- step 3 — verified: held. 065-1 and 065-2 re-raised by the d065b runners (2026-11-13); 065-3 one runner, still literally true of step 4's last line. 065-1 overlaps TASK-085's From-TASK-112 criteria
- step 3b — planned: drafted inline as /tasks plan --no-grill (two files, four criteria)
- step 4 — layer: local
- step 5 — fix in skills/adopt-project/SKILL.md step 4 (`not applicable` entry; next step with no tasks/) and skills/new-project/LAYER.md (§ Conditional rows: both doors print a derived No, TASK-112 pointer gone; tasks/ row: single-branch workspace settled); TASK-085 criteria met here ticked there with a pointer; assertions in scratchpad task353-check.sh
- step 6 — reverted fix (HEAD copies): 4/4 assertions failed; fix-dependent = D1 entry, D2 LAYER paragraph, D3 single-branch workspace, D4 next step; contract pins = skills-lint. Behaviour: d065 and d065b runners raised 065-1/2/3 on the old text; re-drill of the d065 brief on fixed text running (d353)
- step 7 — respecced project-baseline (surgical); requirements changed: Named declarations (single-branch workspace), The adoption report (derived not applicable; next step without tasks/); intended — TASK-353 criteria 1–3
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
