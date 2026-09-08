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
blocks: [TASK-118]
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

## Out of scope

- **The `research` type and sub-agent dispatch** — **TASK-118**, which depends on rounds existing.
- Where the questions are stored — **TASK-114**.
- `grill-me`'s use outside the feature lifecycle stays working; this task must not narrow it to features.

## Human test plan

- [ ] Run a grill on a real plan with a genuinely wide frontier. Expected: the round is answerable in one
      sitting and each question carries a recommendation. Have a second person read the round cold and
      say whether it reads as a conversation or a form — withhold which answer you expect.
