---
id: TASK-117
parent: STORY-004
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-08
depends-on: [TASK-114]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `grill-me` switches from one question at a time to frontier rounds

## Context

`grill-me` today asks strictly one question at a time. The story changes it to **frontier rounds**: ask
every question whose prerequisites are settled in one numbered round, each with a recommended answer,
then recompute the frontier from the replies.

**Keep the `## Resolved decisions` emit block.** The story is explicit that it is what makes the grill
composable — [[new-project]]'s scope grill folds those lines into README/CLAUDE.md and [[feature]] `new`
turns each into a `proposed` row. The yolobox original has no equivalent, and losing it would trade a
working integration for a cosmetic change.

**The risk this task carries:** one-at-a-time is what makes a grill feel like a conversation. A round of
nine questions is a form. The recommended-answer-per-question rule is what keeps it answerable — it must
survive the change, not be dropped as round overhead.

### Merged in 2026-09-26: TASK-118 — `research` becomes a question type that dispatches a sub-agent, not a skill of its own

_Merged because a research question not blocking its round is part of designing the frontier rounds. The original file stays, cancelled, at `tasks/EPIC-001-adopt-yolobox-ideas/STORY-004-durable-question-ledger/TASK-118.md`._

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

- [ ] A round asks every question whose prerequisites are settled, numbered, **each with a recommended
      answer** — the property that makes a round answerable rather than an interrogation
- [ ] The frontier is recomputed from the replies, and the next round is derived, never accumulated
- [ ] `## Resolved decisions` still emits in its current shape; its existing consumers are unchanged
- [ ] A round of one is a normal outcome and reads as a question, not as a form with one field
- [ ] Round size is addressed: what a runner does when the frontier is very wide, stated as a rule rather
      than left to taste
- [ ] Nothing restates TASK-114's frontier query
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-118:*

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

- **The `research` type and sub-agent dispatch** — **TASK-118**, which depends on rounds existing.
- Where the questions are stored — **TASK-114**.
- `grill-me`'s use outside the feature lifecycle stays working; this task must not narrow it to features.

*From TASK-118:*

- Round mechanics — **TASK-117**.
- Making `research` a skill or a verb. The story rejects that explicitly.
- Which sub-agent is used, beyond naming the dispatch — runtime-specific and not this repo's to fix.

## Human test plan

- [ ] Run a grill on a real plan with a genuinely wide frontier. Expected: the round is answerable in one
      sitting and each question carries a recommendation. Have a second person read the round cold and
      say whether it reads as a conversation or a form — withhold which answer you expect.

*From TASK-118:*

- [ ] Grill a plan containing at least one question answerable only by looking at the environment.
      Expected: it is not asked of you, its answer lands in the table, and the rest of the round proceeds
      without waiting for it.

