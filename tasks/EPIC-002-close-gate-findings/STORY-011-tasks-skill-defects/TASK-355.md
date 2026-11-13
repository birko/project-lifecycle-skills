---
id: TASK-355
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
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

- [ ] The count line states its form for a count of one, or states that the plural is used regardless
- [ ] "Suppress trailing zeros" says which lines it covers, and whether a status row with a zero count is printed
- [ ] The template marks which of its text is printed and which is a note to the renderer
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The order of the "Next up" list and its tie line: TASK-139

## Human test plan

- [ ] Re-run TASK-139's brief (`%LOCALAPPDATA%/Temp/d139/fix/brief.txt`, on a fresh copy of that fixture and of
      `skills/`) with a cold runner. Expected: none of DRILL-139-1 … 3 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-355` — leave empty until then._
