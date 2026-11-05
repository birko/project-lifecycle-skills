---
id: TASK-344
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
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

## Open decision

Which behaviour should a detached run of a T1-failing task have: (a) stop before the work at the first failing
criterion, or (b) work it and stop at `verify`? I recommend **(a)**. The test failing is exactly the signal that
the task needs a person, and (a) stops before any judgement is spent rather than after.

## Acceptance criteria

- [ ] `pick.md` step 9b states which choices stop a detached run, for a task whose detached test failed
- [ ] The detached contract says whether a detached run may spawn tasks with nobody present
- [ ] TASK-120's plan step and this rule agree, and a re-run of the TASK-121 drill (fixtures and brief on TASK-120's log) meets it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The mechanical half of the detached run, which passed

## Human test plan

- [ ] Re-run the TASK-121 drill's judgement half (`d121b`, brief on TASK-120's Progress log) with a cold runner. Expected: the outcome the chosen rule states

## Implementation plan

_Populated by `/tasks plan TASK-344` — leave empty until then._
