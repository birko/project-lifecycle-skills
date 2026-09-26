---
id: TASK-182
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: ai
created: 2026-09-24
depends-on: []
blocks: []
related: [TASK-127]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-174-1]
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` step 7's two questions carry no wording and no answer-less path

## Context

Found by TASK-174's drill on 2026-09-24. Three `claude -p` runners ran `skills/tasks/verbs/pick.md`
unattended on `pr-per-task` fixtures. All three reached step 7 and met two ask-steps. Neither is quoted
verbatim, and neither says what happens when nobody answers. Both break AGENTS.md § Output/prose rules:
*an ask-step carries the question it puts and the answer-less path, or it is not a step*. The two are:

- *"offer to cut `task/TASK-NNN` so the work is isolated"*. One runner cut the branch and reported *"that
  was my decision, not the verb's"*. With no rule, another runner is equally entitled to skip the cut
  and work on the default branch, which on a `pr-per-task` project is exactly what that model forbids.
- *"ask whether to fill `pr:` now"*. All three left it null, but by inference, not instruction.

This predates FEATURE-001 and is unrelated to its change. Step 6b, which that feature added, is
compliant and was not touched.

### Merged in 2026-09-26: TASK-134 — `/specs init` step 1's meta-root ask has no question text and no unattended path

_Merged because same defect shape (ask-step with no question text and no answer-less path) under one AGENTS.md rule. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-014-specs-gates/TASK-134.md`._

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

- [ ] Both step-7 questions are quoted verbatim in `pick.md`.
- [ ] Each has a stated answer-less path. For the branch offer, the path is read off `integration:`. Under `pr-per-task`, with nobody to ask, the branch is cut and the report says the cut was the documented default and nobody chose it. A run that works on the default branch under a policy forbidding it is the one outcome ruled out. For `pr:`, it stays null and `close` asks later.
- [ ] A drill with two unattended runners gives the same outcome and the same report line from both.

*From TASK-134:*

- [ ] Step 1's meta-root branch states **the question actually put**, in the form the other nine sites now use
- [ ] It states what happens when **no answer comes**, and that outcome is a reported unresolved state —
      never a silently-chosen scope
- [ ] The choice, once made, is **recorded** where a later run can read it rather than re-guess, or the
      task says explicitly why it is not worth recording
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Step 6b — FEATURE-001 (TASK-174/175).

*From TASK-134:*

- The other nine ask-steps — built under [[TASK-127]].
- Whether Polyrepo Shape A is the right model at all; that is [[TASK-130]]'s territory, and undecided.

## Human test plan

- [ ] Two cold runners each run `/tasks pick` unattended on a `pr-per-task` fixture with no `workspace:`. Expected: both cut `task/TASK-NNN`, leave `pr:` null, and print the same line saying the cut was the documented default. The brief withholds the expected outcome.

*From TASK-134:*

N/A pending the decision in AC3 — if the branch stays prose-only, this is a reviewer check against the
`AGENTS.md` rule. If it grows a recorded scope, that is a drill-worthy change and this line is replaced
with one, per `AGENTS.md` § Testing.

## Implementation plan

_Populated by `/tasks plan TASK-182` — leave empty until then._
