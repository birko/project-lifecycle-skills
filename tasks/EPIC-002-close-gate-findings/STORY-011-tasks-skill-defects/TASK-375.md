---
id: TASK-375
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
findings: [DRILL-375-5]
pr: null
github-issue: null
jira-key: null
---

# `triage` is told to flag a parent that contradicts its children, and its verb file has no step for it

## Context

Filed 2026-11-14 from the dashboard refresh (`%LOCALAPPDATA%/Temp/d375`, `report-run1.md` point 5 and
`report-run2.md` point 1). `skills/tasks/SKILL.md` says "`triage` / `audit`: flag any parent whose status contradicts
its children (e.g. all-children-done under an `in-progress` story, or a story listed in an EPIC body that no longer
exists), and offer to reconcile." `skills/tasks/verbs/triage.md` has no step for it, no question text, no
answer-less path and no slot in the dashboard. Both runners therefore handled it on their own: run 1 rendered the
parents as stored and wrote its own question, run 2 printed flags and a question to stdout and left the file silent.

**The live case:** STORY-023 reads `in-progress` with 36 of 36 tasks done, and STORY-017 has only a cancelled task
open. Neither is flagged anywhere a reader of `tasks/README.md` would see.

## Acceptance criteria

- [x] `triage.md` owns the check as a step: what counts as a contradiction, the question it puts (verbatim), and what
      the run does with no answer, per `AGENTS.md` § *An ask-step carries the question it puts and the answer-less path*
      — met by asking nothing: the step reports and names the verb, so there is no question and no answer-less path to state
- [x] Whether and where a flagged parent appears in `tasks/README.md` is stated
- [x] `SKILL.md`'s line becomes a pointer to that step rather than a second statement of it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Closing STORY-023 itself: the owner's call (`/tasks close STORY-023`)
- `audit`'s side of the same line, unless the fix shows it shares the step

## Human test plan

- [x] Run `/tasks triage` with a cold runner on a fresh clone of this repo with `skills/` at the fix. Expected:
      STORY-023 is flagged in the stated place, the question is the stated text, and with no answer nothing is
      reconciled and the report says so
  - **Passed 2026-11-14, with the expected question removed by design.** Cold drill `%LOCALAPPDATA%/Temp/d375b`
    (`claude -p --disable-slash-commands`, the runner listing no skills), `/tasks triage` on a fresh clone, the brief
    saying nothing about parents. The callout under `## Tree` read `Parents out of step (4)`: STORY-014, STORY-017 and
    STORY-023 `in-progress, every child closed`, and STORY-024 `planned, 17 of 21 children started`. No status
    changed. The step puts no question (see Outcome), so the plan's "the question is the stated text" has nothing to
    check; the report naming each fix is what replaces it.
  - **Two drill points fixed before the close:** the runner copied each table cell whole into the callout, making one
    long line, so the callout now prints only the fix text before the dash; and it could not tell whether `<t>` counts
    cancelled children, so the step now says step 4's rule applies. Not re-drilled after these two wording changes.

## Outcome

**The fix.** `triage.md` step 4b checks every epic and story against its children, Completed ones included, and
reports four cases in one callout above the tree, each with the verb that fixes it; the summary line gains a count:
- open with every child closed → `/tasks close <ID>`, or keep it open on purpose;
- `planned` with work started → no verb yet (TASK-377);
- `done` or `cancelled` with an open child → file it, since a verb skipped the reopen;
- an epic body naming a story that does not exist → edit the body.
`SKILL.md`'s line now points at the step.

**Judgement calls.**
- **Report, never reconcile, and so ask nothing.** A status changes only through its verb, and `close` carries the
  container gates (record branches, the children-done check). `close` step 11 also keeps containers open by default,
  so an all-closed open story is a choice as often as a defect: the report names both options rather than offering to
  act. With no question there is no answer-less path to define, which is how criterion 1 is met.
- **`audit` dropped from the line.** `SKILL.md` promised the check in `audit` too, and `audit.md` never had it. The line
  now names `triage` alone; adding it to `audit` is not asked for by anything here.
- **The `planned`-with-work-started case has no fixing verb**, because nothing moves a container to `in-progress` when
  its first child starts. Filed as TASK-377 rather than widened into this task.

**Step-6 split.** Text: step 4b absent at HEAD, present at the fix. Behavioural: d375b.

**Close gate (inline, two skill files plus one spec):**
- **Standards:** the rule lives in the verb that renders it, and `SKILL.md` points at it.
- **Intent:** all four criteria met, the first by asking nothing.
- **Correctness:** checked by the drill; two wording points fixed.
- **Security, comments:** not applicable.
- **CI:** local lint passes; main is unpushed.

**Flagged.** TASK-377, filed: no verb moves a `planned` container to `in-progress`.

## Progress log

- step 2 — picked; a silent wrong state (STORY-023 reads in-progress at 36/36) that no dashboard surfaces, and fixable in triage.md; ranked above TASK-376 and 369 (wording) and TASK-268/269 (refactors)
- step 3 — verified: `triage.md` has no step for SKILL.md's parent check; SKILL.md also names `audit`, whose verb file has no such step either; and `close` step 11 keeps containers open by default, so an all-closed open story is a choice as often as a defect
- step 3b — planned inline: triage step 4b reports four cases with the verb that fixes each and changes nothing (so no ask-step), as a callout above the tree and a summary-line count; SKILL.md's line becomes a pointer; the `planned`-with-started-work case has no fixing verb, filed as TASK-377
- step 4 — layer: local (tasks skill)
- step 5 — fix in skills/tasks/verbs/triage.md (step 4b, step 7's tree token, step 9) and skills/tasks/SKILL.md; TASK-377 filed
- step 6 — behavioural: d375b (callout named STORY-014, 017, 023, 024; nothing changed). Text: step 4b 0 → 1
- step 7 — respecced work-tracking (the dashboard requirement states the parent check, with a scenario), restamped
- step 8 — closed inline; commit in git log
