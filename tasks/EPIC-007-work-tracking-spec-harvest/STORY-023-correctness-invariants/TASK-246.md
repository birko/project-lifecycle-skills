---
id: TASK-246
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-75, SH-77, SH-78]
pr: null
github-issue: null
jira-key: null
---

# `verify-intent` never maps its classes to severities, and leaves "which task" open

## Context

Found by the change-review spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second reader
against the files at `adc4c27`. All three are in `skills/verify-intent/SKILL.md`.

- **SH-75 — no class-to-severity mapping.** § *The three classes* defines Missing, Wrong and Scope creep with no
  severity.
  - The only mapping is the sample in § Output format: 🛑 Missing, ⚠ Wrong, 💡 Scope creep.
  - § Intent calls implementing a `removed`/`deferred` decision "scope creep of the worst kind", which that mapping
    ranks lowest.
  - § Related skills says "same severities" as `verify-conventions`, but that skill grades by how hard the rule is,
    not by class.
- **SH-77 — several tasks in progress.** The intent table's row "Nothing, but a task is in progress → that task's
  criteria — name which task you picked" says nothing about several in-progress tasks, which is normal under
  parallel worktrees.
- **SH-78 — the sample breaks its own rule.** The class table requires "the `file:line` where the implementation
  *should* have gone". The sample Missing finding gives "expected at skills/verify-intent/SKILL.md § What it reads",
  which is a section, not a line.

## Acceptance criteria

- [x] The class table states each class's severity, and a scope-creep finding that implements a removed or deferred decision is not 💡
- [x] "Same severities" is either defined or dropped
- [x] The intent table says how the task is chosen when more than one is in progress, including the answer-less outcome
- [x] The sample Missing finding gives a `file:line`
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-task ask-step's question wording (TASK-247)

## Human test plan

- [x] On a fixture whose staged diff builds a `removed` decision and misses a criterion, with two tasks in progress,
      run `/verify-intent TASK-001` twice and bare `/verify-intent` twice, unattended. Expected: the removed-row build
      is 🛑 in every run, and the bare runs choose no task.
  - **Passed 2026-10-11:** `%TEMP%\d246`. The named runs gave 🛑 Missing (with `file:line`) and 🛑 scope creep for the
    removed D2, 2/2. The bare runs gave `Intent: unresolved — 2 tasks in progress, none chosen` and still raised the
    removed-row build at 🛑, 2/2. The brief was the bare command (bare runs: plus "unattended"). The runner holds the
    installed skills, which this behaviour drill needs

## Implementation plan

_Populated by `/tasks plan TASK-246` — leave empty until then._

## Outcome

**The fix.**
- **Severities:** the class table now has a Severity column: Missing 🛑, Wrong ⚠, and Scope creep 💡 by default.
  Scope creep is ⚠ when it implements a `proposed` row or contradicts a spec requirement, and 🛑 when it implements
  a `removed` or `deferred` row, which is the worst case the skill names. The rule behind it is that severity
  tracks how far the change departs from what was agreed.
- **"Same severities":** this now means the same three marks, graded differently by each skill.
- **Several tasks in progress:** take the one the checkout's `task/TASK-NNN` branch names. Otherwise ask, with the
  question written out. With no answer, choose none, report the intent as unresolved, and still run the spec
  baseline.
- **The sample:** its Missing finding now cites a line.

**Step 6 split.** Pre-fix, 4 runs on the same fixture:
- the `removed`-row build was **💡 in 3 and 🛑 in 1**;
- both bare runs **picked TASK-001 because the diff matched it**.

Fixed, 4 runs: **🛑 in 4/4**, and both bare runs **chose none**. **Fix-dependent:** both. **Contract pins:** Missing
🛑 with a `file:line`, the same in all runs. Nobody tested the `task/TASK-NNN` branch rule, so it rests on the text.

**Judgement calls.**
- *Never pick the best-matching task.* Both pre-fix runners did exactly this. It infers the intent from the change
  being judged, so every diff looks faithful to something.
- *Wrong stays ⚠, not 🛑.* A divergent implementation may be a criterion written loosely. Missing has no such
  reading.

**Flagged, not fixed.** Nothing new.

## Progress log

- step 2 — picked; ranked above TASK-247 because the only severity mapping ranks building a `removed` decision as 💡, the lowest, while the text calls it the worst scope creep, so the merge gate under-reports it (key 1: unapproved behaviour merged; key 3: reads as minor), reached at every `/tasks close` (key 2), and all fixes sit in one file (key 4); TASK-247 is unworded asks. Key 6 inert: both `correctness-invariants`
- step 3 — verified: held as written. The class table carries no severity and the only mapping is the sample (🛑 Missing, ⚠ Wrong, 💡 Scope creep), which ranks a `removed`-row build lowest; "same severities" is undefined; the in-progress row assumes one task; the sample Missing finding cites a section, not a line
- step 4 — layer: local (`skills/verify-intent/SKILL.md`)
- step 5 — fix in `skills/verify-intent/SKILL.md`: Severity column on the class table (scope creep 💡/⚠/🛑 by what it departs from) with its rule; several in-progress tasks → the checkout's `task/TASK-NNN`, else the written question, unanswered → none, intent unresolved, baseline still run; sample Missing cites `SKILL.md:38`; "same severities" → same marks, graded differently. Lint green; drill 4/4 on `%TEMP%\d246`
- step 6 — reverted: pre-fix removed-row build 💡 3/4 (🛑 1/4), bare runs picked the best-matching task 2/2; fixed 🛑 4/4, bare runs chose none 2/2. Fix-dependent = both; contract pins = Missing 🛑 with `file:line`; branch rule not drilled
- step 7 — respecced change-review (intent sources: several in progress; classification: severities; removed-decision scenario expects 🛑; new scenario "Several tasks in progress, nobody to ask"); `generated-at` restamped
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
