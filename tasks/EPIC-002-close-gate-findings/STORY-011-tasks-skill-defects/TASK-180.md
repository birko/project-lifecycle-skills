---
id: TASK-180
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: ai
created: 2026-09-24
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-173-1, DRILL-173-2]
pr: null
github-issue: null
jira-key: null
---

# `/tasks init` contradicts two sibling verbs — when mode detection runs, and whether a re-run writes

## Context

Found by TASK-173's re-drill (2026-09-24): a `claude -p` runner executed `skills/tasks/verbs/init.md`
twice, unattended, on a scratch fixture whose `tasks/.config.yml` already existed with `mode: local`.
Both findings predate TASK-173 and are unrelated to its change. They are grouped because both are
`init.md` contradicting a verb it delegates to, and both were resolved by the runner by *choosing*
which text to obey, which is the defect.

| Id | Where | Contradiction |
|---|---|---|
| DRILL-173-1 | `init.md` step 2 vs `new.md` § *Mode detection flow* | Step 2 says: `mode=` absent → run the mode detection flow. `new.md` says that flow *"runs once per project, when `.config.yml` is missing"*. On an existing config with no `mode=` arg, one text says ask and the other says don't. The runner followed `new.md`. A different runner could ask a question whose answer the file already holds |
| DRILL-173-2 | `init.md` intro (*"a second run on an up-to-date tree writes nothing"*) vs step 4 / `triage.md` (always regenerate `tasks/README.md`) | The dashboard carries a generation timestamp, so step 4 rewrites it on every run, and "writes nothing" is false by construction. Two runners split: one rewrote `README.md` and reported the contradiction, the other skipped the regen to honour the idempotency claim |

## Acceptance criteria

- [ ] `init.md` step 2 states that mode detection runs only when `.config.yml` is absent. An existing config's `mode:` is read, and the mode-conflict branch covers the arg-vs-file case. The wording agrees with `new.md`.
- [ ] `init.md`'s idempotency claim and step 4 agree. Either the claim is scoped to the config ("the config is not rewritten"), or step 4 skips a regen whose only change would be the timestamp. Pick one and say why.
- [ ] A cold drill on an existing up-to-date config, run twice, reports the same file changes from two independent runners.

## Out of scope

- Everything worktree-related — EPIC-005.

## Human test plan

- [ ] Two cold runners each run `/tasks init` twice on a scratch copy of a consumer tree that already has `mode:` and `integration:` declared. Expected: neither asks the mode question, and both report the same set of written files on the second run. The brief withholds the expected answer (populate-tests § *The cold drill*).

## Implementation plan

_Populated by `/tasks plan TASK-180` — leave empty until then._
