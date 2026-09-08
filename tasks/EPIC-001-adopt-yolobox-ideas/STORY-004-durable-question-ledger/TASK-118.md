---
id: TASK-118
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-114, TASK-117]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `research` becomes a question type that dispatches a sub-agent, not a skill of its own

## Context

The story's principle: **facts are the agent's job; decisions are the user's.** A frontier question that
needs an environment fact — what version ships, what the API returns, what the repo already does —
**dispatches a sub-agent rather than asking the user.** Asking a human to go and look something up is
how a grill stalls.

Two consequences, and the second is the one that is easy to miss:

- `research` is a **question type**, a value in TASK-114's `type` column. Not a verb, not a skill. The
  story's argument against a separate map tree applies here too: everything already has a home.
- **A dispatched question does not block its round.** Only the questions *downstream of it* wait. A round
  that stalls on one lookup has reintroduced the one-at-a-time behaviour TASK-117 just removed.

## Acceptance criteria

- [ ] `research` exists as a `type` value with a stated dispatch rule — what gets dispatched, what is
      asked of the user, and how a runner tells them apart
- [ ] A dispatched question **does not block its own round**; only its dependents wait, and that is
      stated where a runner will read it
- [ ] The fact/decision split is written as a test an agent can apply, not a principle it must intuit —
      a question with one discoverable answer is a fact; one with a trade-off is the user's
- [ ] What happens when a dispatched lookup **fails or returns ambiguously** is defined; it must not
      silently become an unanswered question with no trace
- [ ] The result is written back into the table, so a resumed session sees the fact rather than
      re-dispatching it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Round mechanics — **TASK-117**.
- Making `research` a skill or a verb. The story rejects that explicitly.
- Which sub-agent is used, beyond naming the dispatch — runtime-specific and not this repo's to fix.

## Human test plan

- [ ] Grill a plan containing at least one question answerable only by looking at the environment.
      Expected: it is not asked of you, its answer lands in the table, and the rest of the round proceeds
      without waiting for it.
