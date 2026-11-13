---
id: TASK-355
parent: STORY-011
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
findings: [DRILL-139-1, DRILL-139-2, DRILL-139-3]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# The bare `/tasks` snapshot template leaves three rendering details to the reader

## Context

Spawned 2026-11-13 from TASK-139's cold drill (`%LOCALAPPDATA%/Temp/d139/{old,fix}`, briefs and reports kept there).
Two cold runners rendered the bare `/tasks` snapshot on the same five-task fixture, one with the old text and one
with TASK-139's fix. **Both independently raised these three points**, the agreement bar FEATURE-002 D10 uses. They
predate TASK-139, which did not touch them. All three are in `skills/tasks/SKILL.md` § status snapshot step 2's
template and step 3, so they are grouped.

- **DRILL-139-1 — plurals.** The template line `<E> epics · <S> stories · <T> tasks` gives no singular form. Both
  runners printed "1 epics · 1 stories".
- **DRILL-139-2 — "Suppress trailing zeros in the priority breakdown."** One runner asked whether this also drops the
  zero-count status rows (`in-progress: 0`, `blocked: 0`, `done: 0`). The other asked whether it means "omit
  zero-count terms" or "trim zeros". Only the `verify:` row has a stated omission rule.
- **DRILL-139-3 — which template text is output.** The `...` line, the `← …` notes and the `(top 3 …)` parenthetical
  in the "Next up" heading sit in one code block. Nothing marks which parts are notes to the renderer and which are
  printed. Both runners reasoned it out, and one printed the parenthetical as part of the heading.

## Acceptance criteria

- [x] The count line states its form for a count of one, or states that the plural is used regardless
- [x] "Suppress trailing zeros" says which lines it covers, and whether a status row with a zero count is printed
- [x] The template marks which of its text is printed and which is a note to the renderer
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The order of the "Next up" list and its tie line: TASK-139

## Human test plan

- [x] Re-run TASK-139's brief (`%LOCALAPPDATA%/Temp/d139/fix/brief.txt`, on a fresh copy of that fixture and of
      `skills/`) with a cold runner. Expected: none of DRILL-139-1 … 3 in its "left undecided" section
  - **Passed 2026-11-13.** Fixture `%LOCALAPPDATA%/Temp/d355/fix`: a fresh copy of `d139`'s repo and of `skills/`
    with this fix, the same brief, and TASK-065's runner command.
    - **Coldness:** no skills listed and no Skill tool.
    - **Output:** it printed `1 epic · 1 story · 5 tasks`, every zero row except `verify:`, and the "Next up" heading
      whole.
    - **None of DRILL-139-1 … 3 was left undecided.** The runner cited the singular note, "Every other status row is
      printed with its count, zero included", "`cancelled` has no row in this view" and "printed whole, parenthetical
      included".
    - **Two template details it still raised:** column padding and the connector after an omitted row. Earlier
      runners had raised them too (2 of 3 and 3 of 3, counting the `d139` pair). They were folded in at the close,
      as one sentence in the template rule, and were not re-drilled.

## Implementation plan

Drafted 2026-11-13 by `/fix-next`, as `/tasks plan --no-grill` would write it (trigger: three criteria; one file).

1. Above the template block in § *Status snapshot* step 2, add one short rule for reading it:
   - each line is printed as shown, with its `<…>` slots filled;
   - text after `←` is a note to the renderer and is never printed;
   - a `...` line stands for more rows of the same shape;
   - the "Next up" heading, parenthetical included, is printed.
2. The count line uses the singular for a count of exactly 1 (`1 epic · 1 story · 1 task`). The template says so in
   its `←` note.
3. Replace "Suppress trailing zeros in the priority breakdown" with what it means:
   - the `todo` breakdown has one term per priority with at least one task, and none at all when `todo` is 0;
   - every status row is printed, zero included, except `verify:`, whose own rule omits it;
   - `cancelled` has no row.
   The last point folds in a one-runner reading (TASK-139 fix drill, 3f).

## Outcome

**The fix.** The bare `/tasks` snapshot's template now says how to read itself. Lines are printed as shown, `←` notes
are not, and the "Next up" heading is printed whole. It also says:
- `1 epic · 1 story` for a count of one;
- every status row is printed with its count, zero included, except `verify:`, and `cancelled` has no row;
- the `todo` breakdown names only priorities that have a task, and is dropped when `todo` is 0;
- fields are separated by two spaces, unpadded, and the last printed row takes `└─`.
It replaces "Suppress trailing zeros in the priority breakdown", which two runners read two different ways.

**Step-6 split.**
- **Text assertions:** 4 of 4 fail on `HEAD`'s copy and pass on the fix, all fix-dependent: the singular, the zeros
  rule, the todo-0 parenthetical, and how to read the template. The script is `task355-check.sh` in the session
  scratchpad.
- **Behaviour:**
  - **Before:** both TASK-139 runners on this fixture raised all three points.
  - **After:** the `d355` runner raised none, and cited the new sentence for each.
- **Contract pin, not evidence:** skills-lint passes on both.

**Judgement calls.**
- **Singular for one, not "always plural".** The output is read by a person, and "1 epics" reads as a bug. The rule
  costs one note.
- **Zero status rows are printed.** A fixed set of rows lets a reader find `blocked: 0` where they expect it. Only
  `verify:` is dropped, because its own rule already says so. Not changed.
- **The heading parenthetical is printed.** It tells the reader what the list is: three tasks, blocked ones excluded.
- **Folded in:** the padding and connector readings. They have the same root cause, a template that never says how it
  is read, and they are one sentence. Recorded with their runner counts above.

**Close gate (inline, about 12 lines of prose):**
- **Standards:** rules sit inline where the agent branches on them, and the `←` note shape stays consistent.
- **Intent:** all three criteria met, plus the stated fold-in.
- **Correctness:** dashboard rules in `triage.md` are untouched. That file has its own `todo` line rule ("omit the
  whole line"), and the two views differ deliberately.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged, not fixed.** The `d355` runner raised two one-runner readings. Neither was filed, both are recorded here:
- whether DV5 findings should surface with no `docs/features/` — owned by [[roadmap]]'s slice;
- whether `<E> epics` counts closed epics.

## Progress log

- step 2 — picked by the user ("do 355 first"), ahead of the ranked next pick TASK-347; no ranking applied
- step 3 — verified: held. All three readings are in skills/tasks/SKILL.md § Status snapshot steps 2–3
- step 3b — planned: drafted inline as /tasks plan --no-grill (three criteria)
- step 4 — layer: local
- step 5 — fix in skills/tasks/SKILL.md § Status snapshot (how to read the template, singular counts, the zeros rule); assertions in scratchpad task355-check.sh
- step 6 — reverted fix (HEAD copy): 4/4 assertions failed; fix-dependent = B1 singular, B2 zeros rule, B3 todo-0 parenthetical, B4 template reading; contract pins = skills-lint. Behavioural baseline = both TASK-139 drills (d139), which raised all three on this fixture; fixed-text cold drill running (d355)
- step 7 — respecced work-tracking (surgical); requirement changed: Status snapshot and help (counts, zeros, template notes); intended — TASK-355 criteria 1–3
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
