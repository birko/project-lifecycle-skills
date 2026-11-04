---
id: TASK-336
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-321-1, DRILL-321-2]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/feature pick` has no rule for an idea.md with no open-questions section, and words gate D's question twice

## Context

Found by the TASK-321 and TASK-323 drills (2026-11-04). Both runners hit both findings independently.

- **DRILL-321-1:** `skills/feature/questions.md` and `verbs/pick.md` step 3b cover a current table, a pre-table section and a section kept by choice. They do not cover an `idea.md` with **no** `## Open questions` section, which every feature created before the table existed has. Both runners passed gate Q as "no open rows" and made up their own step-6 open-questions line.
- **DRILL-321-2:** gate D's question is worded twice: the gate table's "N approved or changed decision(s) have no tasks. Decompose now? [Y/n]" and step 4's list ending "Decompose these 2 decisions into tasks now? [Y/n]". Step 4's form renders "these 1 decisions".

## Acceptance criteria

- [x] An `idea.md` with no open-questions section has a stated reading at gate Q and a stated step-6 line
- [x] Gate D's question is worded once, and reads correctly for one row
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [x] Re-run TASK-321's drill brief (on its Progress log) on a fresh fixture with a cold runner. Expected: neither finding appears in its "left undecided" section
  - **Passed 2026-11-04:** TASK-321's brief, verbatim, on a freshly built `%LOCALAPPDATA%/Temp/d321`: `idea.md` with no open-questions section, one approved row D1 with no tasks, and `feature`, `tasks` and `roadmap` copied after this fix. Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. It printed `open questions: no section in idea.md — none recorded` from the rule, `FEATURE-001 has 1 approved or changed decision(s) with no tasks: D1. Decompose now? [Y/n]`, and `not decomposed: D1 with no tasks — nobody answered`, and neither finding is in its "left undecided" section. Coldness: it listed no skills

## Outcome

**What was fixed.** `/feature pick` had no rule for an `idea.md` with no `## Open questions` section, so every runner invented its own report. It now has a fourth state, defined in `questions.md` and reported as `open questions: no section in idea.md — none recorded`. Pick writes nothing for it, and gate Q offers nothing and continues. Gate D's question is now worded once, in step 4: the gate table and `decompose.md` point there. Its form, `FEATURE-NNN has N approved or changed decision(s) with no tasks: <ids>. Decompose now? [Y/n]`, reads correctly for one row, and so does the no-answer report (`D1 with no tasks`).

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed.

**Judgement calls.**
- **No offer to add the section.** An added section would be an empty table, which `new` forbids, or a no-open-rows line asserting a grill nobody declared. Reporting the absence is the only outcome that claims nothing.
- **Gate Q passes but reports.** Silence would read as "every question resolved".
- **Pick's step 6 points at the § instead of listing the states.** The copied list is how the missing state went unseen, per "defer to a shared inventory".

**Review (close step 5b, inline).** Adherence: no new ask-step, and the list is replaced by a pointer. Fidelity: both criteria are met. Correctness: "No open rows" is narrowed to a current table, so the two bullets cannot both match.

**Flagged, not fixed.** Gate B's question is also worded twice (the gate-table cell and the ask-table). It is a split signal left in the plan, not spawned, and offered in the report.

## Implementation plan

### Decisions
- **An absent section is a fourth state, not a gap, and gets no new question.** There are no items to upgrade. Adding a section would write either an empty table (new.md forbids it) or a no-open-rows line, which asserts a grill nobody declared. So the run reports and writes nothing, and with no ask-step there is no no-answer path to define.
- **Gate Q passes, but not silently.** Silence cannot be told apart from a grill that resolved everything.
- **Gate D's no-answer report is fixed too.** It is the same gate's text, printed in the very case the drill exercised: `D2 have no tasks` becomes `D2 with no tasks`.

### Steps
1. `questions.md` § *Current or pre-table*: say what an absent heading means, drop the hard-coded "three", and add the row `open questions: no section in idea.md — none recorded`.
2. `pick.md` 3b: narrow "No open rows" to a current table, and add the absent-section bullet (report, offer nothing, continue to gate A).
3. `pick.md` step 6: point at the § for the report line instead of restating its list, which is how the missing state went unseen.
4. Gate D: the table cell points at step 4. Step 4's question becomes `FEATURE-NNN has N approved or changed decision(s) with no tasks: <ids>. Decompose now? [Y/n]` (gate B's form, grammatical at N=1) and is marked as the exact question. `decompose.md` drops its third paraphrase.
5. Spec `feature-lifecycle`: the pick requirement gains the absent-section clause, the decompose scenario quotes the new question, and one scenario is added.
6. Lint; then re-run TASK-321's brief.

### Split signal
- Gate B's question is also worded twice (the gate-table cell and the ask-table). It is outside this task's criteria. ⚠ split signal — not spawned: nobody answered

## Progress log

- step 2 — picked; ranked above TASK-337 because key 5: both findings were raised independently by two cold runners (TASK-321 and TASK-323 drills), and key 1: the missing-section case hits every feature created before the questions table existed, where TASK-337's three are one-reader readings; keys 3 and 7 tie (silent, P3)
- step 3 — verified: held. questions.md § Current or pre-table names three states and none for an idea.md with no `## Open questions` section; pick 3b has no bullet for it, and step 6's line lists only the three. Gate D's question is worded in the step-3 table and again in step 4, whose form renders "these 1 decisions"; the no-answer report renders "D2 have no tasks"
- step 3b — planned: /tasks plan --no-grill (three skill files plus the spec); one split signal (gate B's doubled wording), not spawned: nobody answered
- step 4 — layer: local
- step 5 — fix in skills/feature/questions.md (the absent-section state), skills/feature/verbs/pick.md (3b bullet; step 6 points at the §; gate D worded once, grammatical for one row; no-answer report "with no tasks"), skills/feature/verbs/decompose.md (drops its paraphrase); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced feature-lifecycle; requirements changed: Pick enters a feature at the stage that unblocks it (absent-section clause; decompose scenario's quoted question; +1 scenario); intended — TASK-336's criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
