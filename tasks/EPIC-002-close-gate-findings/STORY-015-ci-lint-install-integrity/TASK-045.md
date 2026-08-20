---
id: TASK-045
parent: STORY-015
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# A flag one skill passes is never checked to exist in the receiving verb

## Context

Spawned by TASK-015's `close` step 5d sweep — the first run of the unattended path that task added.

TASK-015 made [[fix-next]] pass `--unattended` to [`/tasks close`](../../../skills/tasks/verbs/close.md),
and `close` step 2 now documents that flag. Nothing verifies the two stay in agreement. Rename the flag
on one side, drop it, or typo it, and the other keeps passing it into a verb that silently ignores an
unrecognised argument — the out-of-scope sweep reverts to *offering* in exactly the unattended run where
nobody is present to see the offer go unanswered. The failure is silent on both sides: no error, and a
close that looks identical to a correct one.

This is a **cross-skill contract with no enforcement**, the same shape as two findings already filed:

- `AGENTS.md § Conventions` states it as a rule — *"A format one skill reads is a contract the writing
  skill must state too"* — and that rule is honoured by convention alone.
- TASK-043 covers the neighbouring case: `[[link]]` references are resolved by CI inside `skills/` and
  nowhere else, so the same contract is enforced in one tree and not another.

`skills-lint.sh` already parses every skill markdown file for links and file references, so the walk
exists; what is missing is the assertion. The check is plausibly cheap: find `<verb> --flag` mentions in
one skill and confirm the flag appears in the target verb's arg list.

**Not assumed to be easy.** `--unattended` is the only instance today, so a check written for it risks
being a one-case check. Whether flags are consistently written in a greppable form across the skill set
is the first thing to establish, and if they are not, saying so and closing is a legitimate outcome.

## Acceptance criteria

- [ ] Establish first whether cross-skill flag passing is written consistently enough to detect — survey
      the actual instances before designing anything, and record the count
- [ ] If it is: a check asserts every flag one skill passes to another verb exists in that verb's args
- [ ] If it is not: say so with the evidence, and close the task — a check that catches one hard-coded
      case is worse than none, because it reads as coverage
- [ ] Whichever way it goes, `--unattended` specifically is covered — by the general check, or by a
      pinned case in `skills-lint-test.sh`
- [ ] Any check added is advisory or fatal by the existing rule (advisory only when the remedy lives
      outside the repo — this one does not, so fatal is the default), and carries a test that fails
      without it

## Out of scope

- The `[[link]]`-in-`tasks/` coverage gap — TASK-043 owns it. Related, and worth doing in the same
  sitting if both land, but they are separately scoped.
- Validating flag *semantics* (that the receiving verb does the right thing with the flag). Existence
  is what is silently wrong here.

## Human test plan

- [ ] Rename `--unattended` in `close.md` only, run the check, and confirm it fails naming both sides
- [ ] Restore, and confirm the run is clean
- [ ] Confirm a flag mentioned in prose but not passed to a verb is not reported (the false-positive
      direction — the same trap TASK-043 documents for wikilinks)

## Implementation plan

_Populated by `/tasks plan TASK-045` — leave empty until then._
