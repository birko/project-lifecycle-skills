---
id: TASK-134
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-127]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs init` step 1's meta-root ask has no question text and no unattended path

## Context

Found 2026-09-17 during [[TASK-127]]'s step-3 re-verification, and **deliberately not folded into it**.
It is the same defect shape as that task's four sites, but it resolves *project scope* rather than
blessing a map, so pulling it in would have widened TASK-127 rather than completed it.

`skills/specs/verbs/init.md` step 1:

> Polyrepo Shape A: if cwd is inside a subproject, init that subproject's `docs/specs/`; at the
> meta-root, **ask whether the user wants meta-level (cross-cutting) specs or a specific subproject**.

No wording, and no statement of what a run does when nobody answers. TASK-127 brought the other nine
ask-steps in `tasks` and `specs` up to the standard now recorded in `AGENTS.md` § Conventions
(*"An ask-step carries the question it puts and the answer-less path, or it is not a step"*); this one
was left, so the rule is nine-tenths applied in the two skills it was written from.

**Why it is P3 and not P2.** The branch needs a polyrepo meta-root to fire at all, where TASK-127's sites
sit on every first run of either front door. The consequence when it does fire is real though — a run that
guesses *meta-level* writes a `.map.yml` at the aggregator root whose globs reach every sibling, which is
the exact shape [[specs]] `regen` step 6 records as having reported "nothing unmapped" forever while
covering 97 sibling projects.

## Acceptance criteria

- [ ] Step 1's meta-root branch states **the question actually put**, in the form the other nine sites now use
- [ ] It states what happens when **no answer comes**, and that outcome is a reported unresolved state —
      never a silently-chosen scope
- [ ] The choice, once made, is **recorded** where a later run can read it rather than re-guess, or the
      task says explicitly why it is not worth recording
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The other nine ask-steps — built under [[TASK-127]].
- Whether Polyrepo Shape A is the right model at all; that is [[TASK-130]]'s territory, and undecided.

## Human test plan

N/A pending the decision in AC3 — if the branch stays prose-only, this is a reviewer check against the
`AGENTS.md` rule. If it grows a recorded scope, that is a drill-worthy change and this line is replaced
with one, per `AGENTS.md` § Testing.

## Implementation plan

_Populated by `/tasks plan TASK-134` — leave empty until then._
