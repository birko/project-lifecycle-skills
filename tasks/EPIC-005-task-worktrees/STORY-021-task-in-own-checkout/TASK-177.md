---
id: TASK-177
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: ai
created: 2026-09-24
depends-on: [TASK-173]
blocks: [TASK-179]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# Ship `workspace:` / `worktree-root:` through both front doors

## Context

FEATURE-001 D9, and the layer-parity hard rule (AGENTS.md § Code structure): a change to the universal
layer updates [[new-project]] **and** [[adopt-project]] in the same change, through
`skills/new-project/LAYER.md`.

The `tasks/` row in `LAYER.md` names one declaration its owner needs today (`integration:`). This task
adds the new ones to that row, so the adopter's survey probes them (anchored and uncommented —
`LAYER.md` § *A named declaration is not a version*), and the scaffolder's intake can ask for them and
pass them to `/tasks init`.

One question to settle in the plan: `integration:` is always asked because it is a real choice with no
safe default. `workspace:` absent already *means* `in-place`, today's behaviour — so is it a question
the frontier round must raise, or an absence that is correct until someone opts in (like `siblings:`)?
The answer decides whether the adopter reports it as a gap. Record it with `/feature decide FEATURE-001`.

## Acceptance criteria

- [ ] `LAYER.md`'s `tasks/` row names the new declaration(s) and what absence means.
- [ ] `new-project` passes the answer(s) to `/tasks init` (`workspace=`, `worktree-root=`), and `init.md` declares those args.
- [ ] `adopt-project`'s survey reads the declarations off the row, never off a list kept in the adopter, and reports them per the decided absence semantics.
- [ ] The absence-semantics decision is recorded on FEATURE-001.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The config template and `init` reconcile — TASK-173.

## Human test plan

- [ ] Cold-run `/new-project` into a scratch folder choosing `workspace: worktree` with a root. Expected: `tasks/.config.yml` carries both as live keys.
- [ ] Cold-run `/adopt-project` on a consumer whose config lacks the fields. Expected: the survey reports them according to the recorded absence semantics, and a re-run after answering reports them settled.

## Implementation plan

_Populated by `/tasks plan TASK-177` — leave empty until then._
