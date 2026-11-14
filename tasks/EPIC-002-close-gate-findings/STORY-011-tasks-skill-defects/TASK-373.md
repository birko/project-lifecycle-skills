---
id: TASK-373
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
findings: [DRILL-371-1, DRILL-371-2, DRILL-371-3, DRILL-371-4, DRILL-371-5, DRILL-371-6, DRILL-371-7, DRILL-375-3, DRILL-375-4]
pr: null
github-issue: null
jira-key: null
---

# `/feature status` leaves nine rendering choices to the runner

## Context

Filed 2026-11-14 at TASK-371's close; DRILL-371-6 and -7 added the same day from the same three reports. Three cold runners of `/feature status` on a clone of this repo
(`%LOCALAPPDATA%/Temp/d067r` `report-run1.md` and `report-run2.md`, and `%LOCALAPPDATA%/Temp/d371/report.md`) each
named these as undecided. All three resolved them the same way, so the renders agree today, but by
convergence rather than by rule. The next runner may not converge.

- **DRILL-371-1 — cancelled tasks in `done/total`.** "Compute `done/total`." does not say whether a cancelled
  task counts. All three counted it (FEATURE-002 28/29). Raised by all three runners.
- **Note 2026-11-14 on DRILL-371-1:** `triage` now leaves cancelled tasks out of both numbers (TASK-368); take the
  same rule here, or say why a feature total differs.
- **DRILL-371-2 — the digest's order and decision part.** "Order the digest with debt features first" leaves
  the rest unordered, and the example `(4/7 tasks, 3 approved / 1 deferred)` does not say which states appear
  or in what order. All three used id order and the non-zero states only. Raised by all three runners.
- **DRILL-371-3 — "testable now" and cancelled or done tasks.** `{{TESTABLE_SUMMARY}}`'s "filled and ready to
  run" does not say whether a cancelled or done task is listed. Raised by d067r run 2 and d371.
- **DRILL-371-4 — accepted findings in the index drift note.** The template's "If `/roadmap --check` would
  flag any drift" against [[roadmap]] § 4b's "suppressed from every warning". All three left EPIC-001's
  accepted DV5 out, two of them saying so. Raised by d067r run 1 and run 2, and by d371.
- **DRILL-371-5 — the prototype cell's label for a link.** `[html]`, `[md]`, `[playground]`, `[spike]` gives no
  rule for a hosted page. Raised by d067r run 1 and run 2, and by d371.
- **DRILL-371-6 — what a task line says.** Step 3's "List each task with its id and title" against the Notes'
  "describe each in human terms". All three runners kept the plain-language wording already in the files, which no
  input can recompute, so the rollup holds text its verb cannot derive (`AGENTS.md` § Working rules, *Nothing goes
  in a generated file that its verb cannot derive*). Raised by all three runners.
- **DRILL-371-7 — the Prototype and Next step lines of a `done` feature.** "One concrete action" has none for a
  signed-off feature, so each runner invented a line or kept the old one. Raised by d067r run 1 (point 10), run 2
  (point 8) and d371 (point 10).
- **DRILL-375-3 — "ready to run" and unbuilt tasks.** "mark which ones are ready to run (filled, not `N/A`)" read
  literally lists a filled plan whose task is not built, or cannot run yet. d375 run 1 listed TASK-374 (which waits on
  TASK-124), run 2 listed FEATURE-004's seven unbuilt tasks (run 1 point 9, run 2 point 5).
- **DRILL-375-4 — the order of a rollup's task lists.** "List each task with its id and title" gives no order. d375 run 1
  used id order, run 2 the tasks skill's total order, so the "ready to run" lines of three rollups differed between
  two runs over the same tree (run 2 point 3; run 1's output shows the other order).

## Acceptance criteria

- [x] Each of the nine is decided in `skills/feature/verbs/status.md` or its templates, in one sentence each
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- DV7's baseline: TASK-371 (done)

## Human test plan

- [x] Re-run `/feature status` (all features) on a fresh clone of this repo with `skills/` at the fix, using a cold
      runner. Expected: none of the nine is reported undecided, and a second run changes only timestamps
  - **Passed 2026-11-14**, cold drill `%LOCALAPPDATA%/Temp/d373` (`claude -p --disable-slash-commands`, each runner
    listing no skills) on a fresh clone of this repo with `skills/` at the fix: two all-features runs, the second over
    the first's output, then one `FEATURE-004` run.
    - **Runs 1 and 2:** every `status.md` identical but for the timestamp. The index differed only in its drift note:
      run 1 reported 20 open DV5 findings because it read no epic as carrying `kind:` (EPIC-002 and EPIC-007 carry
      `kind: review-intake`), a misread of the files; run 2 read them and printed the quiet accepted line.
    - **Run 3 (single feature):** only FEATURE-004's `status.md` changed, and only its timestamp; the index header was
      left alone, as now stated.

## Outcome

**The fix (`skills/feature/verbs/status.md`).** Each of the nine is now stated:
- **DRILL-371-1:** `done/total` leaves cancelled tasks out of both numbers, as `triage` does.
- **DRILL-371-2:** the digest puts debt first, the rest in id order; its decision part lists non-zero states in ledger
  order, `no decisions` when none.
- **DRILL-371-3 and DRILL-375-3:** a task is ready to test only when built (`done` or awaiting verification) and its
  plan is filled; unbuilt and cancelled tasks never are. `{{TESTABLE_SUMMARY}}` has a stated form.
- **DRILL-371-4:** the index drift note carries open findings only, with `triage`'s quiet line when all are accepted.
- **DRILL-371-5:** the prototype label is the form the `idea.md` line names, never the file or the host.
- **DRILL-371-6:** each task line is `TASK-NNN <title> — <status>`, the title verbatim; the Notes' "describe in human
  terms", which no input can recompute, is gone.
- **DRILL-371-7:** `{{NEXT_STEP}}` has one sentence per phase, `done` included.
- **DRILL-375-4:** task lists follow the Collection pass's task order.

**Also fixed, found by this task's drill:** run 2 counted EPIC-001's acceptance as 10 (the epic and its nine
stories) where `triage` runs count 1, and d369's runner had raised the same question. [[roadmap]] § 4b now states that
one acceptance line is one accepted finding wherever a count is printed, covered stories listed but not counted. The
§ 4b example also quoted this repo's corrected "task-only on purpose" reason, replaced by an invented one.

**Step-6 split.** Behavioural: d373. Text: the cancelled rule, the ready-to-test rule and the next-step table absent at
HEAD, present at the fix.

**Close gate (inline, worked with its sibling task; three skill files plus two specs):**
- **Standards:** every rule is in the verb that renders it, and what `triage` already settled is pointed at.
- **Intent:** all criteria met.
- **Correctness:** checked by d373; the one variance it found is outside `status.md` and is fixed (below).
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

## Progress log

- step 2 — picked together with TASK-351: both settle `/feature status`'s rendering choices in one file; ranked first among the P3 defects because the committed rollups are not reproducible (d375's two runs differed on wording and order)
- step 3b — planned inline with the sibling task: state each rendering choice in `status.md` (counts without cancelled tasks, task order, verbatim titles, ready-to-test meaning built, the TESTABLE and NEXT_STEP forms, empty lists, the digest's order and decision part, prototype labels by form, open-only drift note, single-feature timestamp and drift), and drop "describe in human terms", which no input can recompute
- step 5 — fix in skills/feature/verbs/status.md (steps 3, 4, 6, 7, Notes) and the index template's comments
- step 6 — behavioural: d373 runs 1-3 (status.md files identical but for timestamps; index variance traced to a runner misread and to the accepted count, fixed in roadmap § 4b)
- step 7 — respecced feature-lifecycle (the status requirement, with a two-runs scenario) and project-roadmap (the accepted count), restamped
- step 8 — closed inline; commit in git log
