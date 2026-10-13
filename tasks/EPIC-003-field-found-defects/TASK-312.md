---
id: TASK-312
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-10-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-310-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` step 6's stale-plan offer has no question text

## Context

Found by TASK-310's cold drill (2026-10-13). `skills/tasks/verbs/pick.md` step 6 says: when a plan
predates changes to the code it references, "flag it and offer `/tasks plan {{ID}} --replan`". The runner
reported that the flag has no fixed wording and composed its own, and the offer states no answer-less
path. The missing-plan offer in the same step already quotes its question. AGENTS.md § Output/prose rules,
*An ask-step carries the question it puts and the answer-less path*.

## Acceptance criteria

- [x] The stale-plan offer states its exact question
- [x] It states what happens with no answer (proceed on the existing plan, reported as possibly stale)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Detecting staleness itself

## Human test plan

N/A — a two-line wording change to one offer, of the same shape TASK-309 and TASK-310 drilled; the lint
covers the link, and the next drill touching `pick` exercises it.

## Implementation plan

Not drafted: a one-offer wording change.

## Outcome

`pick.md` step 6 puts `TASK-NNN's plan dates from <date>, and <paths> changed since. Replan it with
/tasks plan TASK-NNN --replan first? [y/N]`. Unanswered, the plan is kept and the hand-off says it may be
stale, because replanning overwrites it. Review run inline for a five-line diff. Standards: the ask-step
rule is met. Fidelity: all three criteria met. Correctness: `--replan` is declared by `plan.md`, whose own
in-progress confirmation still applies; `/fix-next` never reaches this step. Security and comments: not
applicable.
