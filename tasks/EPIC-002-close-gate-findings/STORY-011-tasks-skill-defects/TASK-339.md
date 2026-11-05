---
id: TASK-339
parent: STORY-011
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
findings: [DRILL-325-1, DRILL-325-2, DRILL-325-3, DRILL-325-4]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# `/tasks intake --epic` leaves story reuse, the epic update, titles and group priority to the reader

## Context

Found by TASK-325's two drill runs (2026-11-04, recorded on TASK-325). Both runners raised 1, 2 and 4
independently, in `skills/tasks/verbs/intake.md`:

- **DRILL-325-1:** under `--epic`, step 5 says "STORY per theme" and "chain new.md (`epic`) … write the pass into
  `## Area of concern`", but not whether an existing story with the same `theme:` is reused, nor what happens
  to the existing epic's `source:` and Area of concern. The only sentence near it ("A list is fine when a second
  pass is adopted") is about `--adopt`. Both runners reused the story and appended to the epic, by guessing.
- **DRILL-325-2:** intake chains `new` without a title or assignee, so `new` asks both questions per task and
  every task intake files carries `> Filed with nobody to answer — inferred, not chosen: title, assignee, body
  sections`. Yet a title derived from the finding is intake's own rule-set output, not a guess. This is the
  same family as TASK-331's DRILL-318-1, which covers a value the user stated, but this case is a calling verb's.
- **DRILL-325-3:** "Priority from severity" covers one severity per task, not a group holding a blocker and a
  warning.
- **DRILL-325-4:** step 8's report relays reopen and `record/` lines. SKILL.md also says "the verb's confirmation
  names the unreadable copies", and step 8 does not mention that line. Both runners added it by their own choice.

## Acceptance criteria

- [x] Step 5 states, for `--epic`, whether a story with a matching `theme:` is reused and how the epic's `source:` and Area of concern are updated
- [x] Intake passes a title (and the assignee) to `new`, so a filed task's inferred-values line names only what intake did not set
- [x] The priority of a mixed-severity group is stated
- [x] Step 8 relays the unreadable-copies line, or says why not
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The record-line relay itself, which TASK-325 fixed and its drill passed

## Human test plan

- [x] Re-run TASK-325's second drill brief (on its Progress log) on a freshly built `d325b` fixture with a cold runner. Expected: none of the four appears in its "left open" section
  - **Passed 2026-11-05:** TASK-325's second brief verbatim on a rebuilt `%LOCALAPPDATA%/Temp/d325b` (upstream, unlanded `record/STORY-001`, three correctness findings; `tasks` copied after this fix). Runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep Edit Write < brief.txt`. It reused STORY-001, appended a `source:` entry and an Area-of-concern paragraph, and filed TASK-003 (CR-3) and TASK-004 (CR-4 blocker + CR-5 warning) both at P0 with `assignee: agent`, each marked inferred for `body sections` only. Its report relayed the record line and the unseen-copy line. None of the four findings is in its "left undecided" section. Coldness: it listed no skills

## Outcome

**What was fixed.** `/tasks intake --epic` now says:
- a theme the epic already holds a story for reuses that story, matched on `theme:` (a `done` one reopens; a `cancelled` one is replaced and named);
- a later pass appends its own `source:` entry, an Area-of-concern paragraph and its dropped findings, editing nothing already written.

Intake now sets each task's title (the group's root cause), assignee (`agent`) and priority, so `new` no longer marks them "inferred, not chosen" on every task. A mixed-severity group takes the highest priority any one finding would get. Intake's report, and every verb whose summary replaces `new`'s confirmation, relays the line naming copies of the tree the id scan could not read.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill, which passed.

**Judgement calls.**
- **"Warnings → P1/P2" is resolved by theme** (theme 1–2 → P1, others → P2), mirroring the blocker split. Otherwise "the highest priority" of a mixed group is still undefined. It changes no existing task.
- **`body sections` stays marked:** Out of scope and the test plan are still drafted by judgement.
- **One relay rule, not one per verb:** the duty is extended once in SKILL.md, and `new` step 13's intro says the replacing verb relays every line.

**Review (close step 5b, inline).** Adherence: the relay is stated once, and `source:`'s one reader (improve-architecture, which matches a name within it) still works on a list. Fidelity: all five criteria are met. Correctness: the cancelled-story exception keeps reuse from reopening work nobody chose to reopen.

**Flagged, not fixed.**
- Findings with no severity (`DRILL-*`) have no stated priority.
- Under `--epic`, the scope argument has no stated use.
- How an existing scalar `source:` is rewritten as a list is not shown.

## Implementation plan

### Decisions
- **Title:** intake writes it by a stated rule (the group's root cause from step 4; a single finding's claim, shortened), so `new` reads it as caller-derived and does not mark it. **Assignee:** `agent`, stated as intake's default. **Priority:** a mixed group takes the highest priority any one finding would get alone.
- **"Warnings → P1/P2" is resolved by theme** (theme 1–2 → P1, others → P2), mirroring how blockers already split. Without it, "the highest" of a mixed group would still be undefined.
- **`body sections` stays marked.** Out of scope and the Human test plan are still drafted by judgement in `new` step 9.
- **One relay rule, not one per verb:** SKILL.md's relay duty gains the unreadable-copies line, and `new` step 13's intro says the replacing verb relays every line.

### Steps
1. intake step 5, EPIC: under `--epic` or adopt, the pass appends a `source:` entry, an Area-of-concern paragraph, and its dropped findings to the existing list; nothing already written is edited.
2. intake step 5, STORY: a theme the epic holds is reused, matched on `theme:` (a `done` one reopens; a `cancelled` one is replaced and named; no `theme:` matches nothing). The `--epic` arg points at step 5.
3. intake step 5, TASK: title, `agent` and priority set by intake, plus the mixed-severity rule.
4. intake step 8, SKILL.md § ID generation and the relay bullet, and new step 13: the unreadable-copies line is relayed.
5. Spec `work-tracking`: Filing a review pass (+1 scenario), Globally unique ids, Parents rolled up. Lint; then re-run TASK-325's second brief.

### Left out
- Findings with no severity (`DRILL-*`) still have no stated priority. That is outside these criteria.

## Progress log

- step 2 — picked; ranked above TASK-341 because key 1: DRILL-325-2 writes "inferred, not chosen: title, assignee" on every task intake files, a false provenance record on each, where TASK-341 is three readings in pick; key 5: two runners raised three of the four independently; keys 6 and 7 tie (correctness-invariants, P3)
- step 3 — verified: held. intake step 5 under `--epic` says nothing on reusing a same-theme story or updating the existing epic's `source:` and Area of concern; the TASK bullet passes no title or assignee to new, so both are marked inferred on every task; "warnings → P1/P2" and a mixed-severity group have no stated priority; step 8 relays reopen and record lines but not the unreadable-copies line SKILL.md § ID generation requires
- step 3b — planned: /tasks plan --no-grill (five criteria, three files); no split signal
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/intake.md (--epic story reuse and epic update; intake sets title, assignee, priority; mixed-severity rule; step 8 relays unreadable copies), skills/tasks/SKILL.md (§ ID generation and the relay bullet), skills/tasks/verbs/new.md (step 13's relay duty in its intro); `source:` readers checked (improve-architecture matches by name within it, so a list still matches); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the Human test plan drill
- step 7 — respecced work-tracking; requirements changed: Filing a review pass (title, assignee and priority set by intake; --epic reuse and epic update; +1 scenario), Globally unique ids (unreadable copies named in a replacing report), Parents rolled up (the same line carried); intended — TASK-339's criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
