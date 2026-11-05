---
id: TASK-344
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-05
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-121-1]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# A detached run of a judgement task does its judging instead of stopping

## Context

Found by TASK-121's drill (2026-11-05, recorded on TASK-120), in `skills/tasks/verbs/pick.md` step 9b.

**DRILL-121-1.** TASK-002 asked for error messages that "read naturally to a first-time user". Its detached test
failed on T1, so 9b's offer defaulted to `[y/N]`; the drill accepted it. The subagent then wrote the wording
itself, parked the task at `verify` with both judgement criteria unticked, and spawned two follow-up tasks with
nobody present. TASK-121's test plan expected it to **stop at its first real decision and say so**. 9b's contract
has a decision stop (fix-next's decision-pending pattern), but it never says which choices count as decisions. A
judgement criterion is therefore worked, and left for the `verify` gate.

Nothing unsafe resulted: the work stopped at `verify`, where a person signs off. But the run spent its effort
on a judgement it was never sure of, and it filed tasks nobody placed. Two readings:

- **(a) Stop.** When the detached test failed and the run was detached anyway, the subagent stops before work at the
  first criterion that failed T1. It records that as the decision pending, and keeps the branch per fix-next's
  pattern. This matches TASK-121's expectation.
- **(b) Keep the current behaviour, and revise the expectation.** A judgement criterion is worked, and the
  `verify` gate is the stop. TASK-120's plan step is rewritten to expect a `parked: verify` report naming the
  unticked criteria. The run should spawn nothing with nobody present, or it should say why spawning is allowed.

## Decision

Decided by the user, 2026-11-05:

- **(a) Stop.** A detached run of a task whose detached test failed stops before any work, at the first criterion that failed T1, and records it as the decision pending.
- **A detached run spawns nothing.** It lists what it found in its report, and the person decides what to file.

## Acceptance criteria

- [x] `pick.md` step 9b states which choices stop a detached run, for a task whose detached test failed
- [x] The detached contract says whether a detached run may spawn tasks with nobody present
- [x] TASK-120's plan step and this rule agree, and a re-run of the TASK-121 drill (fixtures and brief on TASK-120's log) meets it
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The mechanical half of the detached run, which passed

## Human test plan

- [x] Re-run the TASK-121 drill's judgement half (`d121b`, brief on TASK-120's Progress log) with a cold runner. Expected: the outcome the chosen rule states
  - **Passed 2026-11-05:** the TASK-121 drill re-run on rebuilt `%LOCALAPPDATA%/Temp/d121a` and `d121b` (skill `tasks` copied after TASK-344), runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" "Bash(grep:*)" Read Glob Grep Edit Write Agent < brief.txt`, the same briefs. **d121a:** the subagent received the brief with "Detached test: passed", did the step, closed `done` (`4dcf99f`) and returned `closed: done — 4dcf99f`. **d121b:** the brief carried "Detached test: failed: T1 — …"; the subagent did no work (`src/cli.py` unchanged), blocked TASK-002 with `decision pending: what decides "Error messages read naturally to a first-time user"?`, reported `stopped: decision pending: …` and `found, not filed: none`, and spawned nothing. Its record was left uncommitted, because 9b's summary of the decision stop named only the task-branch case; corrected in 9b before close to commit on the default branch when no task branch was cut, as fix-next's pattern does. Coldness: neither parent listed skills

## Outcome

**What was fixed.** `/tasks pick` 9b now follows the user's decision.
- **A detached run of a task whose detached test failed stops before any work,** at the failing item, by the decision stop. The offer says so, and the brief carries the test result so the subagent knows.
- **A detached run spawns nothing.** Adjacent work becomes `found, not filed:` lines in its report and its last log line, and the contract table's spawning rows are rewritten to match.
- **The decision stop's summary covers both cases:** a task branch, or the default branch when no task branch was cut.

**Step-6 split:** 0/0, because this is prose only. Evidence is the drill re-run of both halves, which passed; the default-branch commit wording was fixed from what it showed.

**Judgement calls.** `close`'s out-of-scope sweep (5d) still spawns the bullets the task's author wrote. Those were not found by the run, and the run now adds none.

**Review (close step 5b, inline).** Adherence: every point a detached run reaches still has a contract row, now including the failed test. Fidelity: all four criteria are met. Correctness: the drill-found uncommitted record is fixed.

**Flagged, not fixed.** `close` 5b's own review can still spawn adjacent findings during an unattended close. Whether the user's "spawn nothing" reaches into `close` is asked separately.

## Implementation plan

### Steps
1. The 9b offer's failed form adds "a detached run stops there", so the person knows what a yes buys.
2. The brief carries the detached-test result, since the subagent never sees the offer. If the test failed, the subagent does no work and takes the decision stop at that item, asking `what decides "<item>"?` (T1) or the marker's own question (T2). Either way it spawns nothing, lists found work as `found, not filed:`, and adds no Out-of-scope bullet.
3. The decision-stop paragraph opens with the failed-test rule: it stops before any work and commits nothing beyond steps 1–8.
4. The report drops "spawned ids" and lists `found, not filed: <what> — <where>` lines. They are the person's to file or drop, and the last log line repeats them.
5. The contract table:
   - a new row for the failed test;
   - the adjacent-work row is not spawned;
   - the feature-decision spawn row is removed;
   - shape 3 lists its residue instead of spawning;
   - the close row says 5d spawns only the author's Out-of-scope bullets.
6. Spec `work-tracking`, Picking a task: the detached sentence, the offer scenario, and a new scenario for a detached run of a judgement task.

### Boundary
- `close` 5b's review can spawn adjacent findings into Out of scope, and 5d files them unattended. That is `close`'s table, outside these criteria, and is asked of the user separately.

## Progress log

- step 2 — picked; the user decided its open question on 2026-11-05 and asked to continue, and it holds TASK-120 at verify; ranked by the user's direction, not keys 1–8
- step 3 — verified: held, by the TASK-121 drill (d121b): 9b names a decision stop but no rule for which choices are decisions, and its contract does not forbid spawning
- step 3b — planned: /tasks plan --no-grill (four criteria); no split signal; close 5b's own spawning recorded as a boundary for the user
- step 4 — layer: local
- step 5 — fix in skills/tasks/verbs/pick.md step 9b (the offer says a failed test stops; the brief carries the test result, the stop rule and "spawn nothing"; the decision stop opens with the failed-test rule; the report lists found, not filed work; contract rows for the failed test, adjacent work, shape 3 and the close); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the TASK-121 drill re-run, both halves
- step 7 — respecced work-tracking; requirements changed: Picking a task (detached stop and no spawning; +1 scenario, offer scenario updated); intended — TASK-344's criteria and the user's decision
- step 5 (amended after the drill) — 9b's decision-stop summary commits the record on the default branch when no task branch was cut; "commits nothing beyond steps 1–8" reworded to "does no work beyond steps 1–8"
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
