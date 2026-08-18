---
id: TASK-015
parent: null
feature: null
status: todo
priority: P3
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `close` step 5d needs an unattended path — fix-next drives close with no user to take the offer

## Context

`e7f5bd1` added step 5d to `skills/tasks/verbs/close.md`: every `## Out of scope` bullet is
classified as a boundary, as work, or as decided-not-to-do, and work **gets an id now** —
"offer [`spawn`]" — with the hard line *"a close that adds an unowned work bullet is not done."*

Written for an interactive close, and correct there. But `close` is also the merge gate
[[fix-next]] runs **unattended** (its step 8, "do not re-implement any of it"), and that skill's
whole contract is draining defects without holding a user in the loop. Step 5d does not say what
that run does when it meets a work bullet: offering is impossible, auto-spawning is a decision
nobody sanctioned, and stopping contradicts the loop's purpose.

Left ambiguous, the likeliest reading in a long unattended run is the one that keeps the loop
moving — close anyway — which is exactly the evaporation the step exists to prevent, now with a
rule quoted over the top of it.

`fix-next` already declares `spawn` "takes everything this loop surfaces but doesn't own", so the
answer is probably auto-spawn plus a line in the closing report. It should be written down rather
than re-derived by each reader.

## Acceptance criteria

- [ ] Step 5d states the unattended behaviour explicitly, distinct from the interactive offer
- [ ] The chosen behaviour is reflected where `fix-next` describes what `close` does on its behalf, so the two skills agree in writing
- [ ] Whatever the unattended path spawns is named in fix-next's closing report — not only in step 12's `out-of-scope:` counts, which a session nobody watched will never show anyone
- [ ] The interactive path is unchanged

## Out of scope

- Changing what counts as a boundary vs work; the classification is settled.
- Whether `fix-next` should ever stop for a user — the broader autonomy question, not this.

## Human test plan

- [ ] Run `/fix-next` on a task whose `## Out of scope` holds one unowned work bullet, and confirm the run ends with an id for that bullet and a line naming it in the report
- [ ] Run `/tasks close` interactively on the same shape and confirm the offer still appears

## Implementation plan

_Populated by `/tasks plan TASK-015`._
