---
id: TASK-174
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: ai
created: 2026-09-24
depends-on: [TASK-173]
blocks: [TASK-175, TASK-176]
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks pick` creates the task worktree, asking for the root when undeclared

## Context

FEATURE-001 D5 and D6. When `.config.yml` declares `workspace: worktree`, `pick` step 7
(`skills/tasks/verbs/pick.md`, *Cut the task branch*) creates a worktree on a new `task/TASK-NNN`
branch under `worktree-root:` instead of cutting the branch in the main copy. The root is **outside**
the repository by decision (D5); an in-repo path is refused rather than accepted.

When `worktree-root:` is absent, `pick` asks. Per the ask-step rule (AGENTS.md § Output/prose rules)
the question is written verbatim into the verb, with its answer-less path. Starting wording, to be
refined in the plan but kept to this shape:

> **Where should task worktrees live?** They go outside this repository, one folder per task.
> Suggested: `../wt` (relative to the repository root). Give a path, or leave it blank to work in
> place this time.

- **Answer given** → write `worktree-root:` into `.config.yml` (the answer is the declaration), then create the worktree.
- **Blank, or nobody to ask** → write nothing, cut `task/TASK-NNN` in place as today, and report `worktree-root undeclared`. The suggestion never becomes the declaration.

The folder layout under the root (for example `<root>/<repo>/TASK-NNN`) is observable behaviour —
choose it in the plan and record it with `/feature decide`. Note the `check_root` comment in
`.github/workflows/skills-lint.sh`: a `<repo>/wt/<repo>` layout already broke shortest-prefix path
stripping once.

## Acceptance criteria

- [ ] `pick.md` step 7 branches on `workspace:`; absent or `in-place` is unchanged byte for byte.
- [ ] `worktree` → `git worktree add <path> -b task/TASK-NNN` from the default branch, at the recorded layout.
- [ ] A declared or answered root that resolves **inside** the repository is refused with the reason, and the run falls back to in-place.
- [ ] The undeclared-root question is quoted verbatim in `pick.md` with both paths; the answer-less path writes nothing and reports `worktree-root undeclared`.
- [ ] Any no-user flag that reaches `pick` lists this ask-step in its definition (AGENTS.md § *A flag that declares an absent capability*).
- [ ] Layout decision recorded on FEATURE-001.
- [ ] `integration: single-branch` + `workspace: worktree` → works in place and prints the fixed report line FEATURE-001 D11 records, on every run that reaches the branch step (added 2026-09-24 from TASK-173's plan: `pick`'s single-branch branch returns before `workspace:` is read, so without this nothing carries D11 out). The line lives in `pick.md`; `skills/tasks/SKILL.md` § *Where the work happens is declared too* deliberately states only that `worktree` has no effect there, and gains a one-clause pointer to `pick` once this lands.
- [ ] A `workspace:` value that is neither `in-place` nor `worktree` (a typo such as `worktrees`) is reported by name and treated as in-place for the run — never silently (added 2026-09-24 from TASK-173's correctness review: only the absent case was defined).

## Out of scope

- Moving into the worktree and proving it — TASK-175. This task must not ship a path that creates a worktree without entering it: land the two together, or keep this path unreachable until TASK-175 is in.
- Merge and removal — TASK-176.

## Human test plan

Runs on a `pr-per-task` consumer project — **not this repo**, which declares `single-branch`.

- [ ] `workspace: worktree`, no `worktree-root:`; answer the question with a path outside the repo. Expected: the path is written to `.config.yml`, the worktree exists there on `task/TASK-NNN`, the main copy is still on the default branch.
- [ ] Same, but leave the answer blank. Expected: no `worktree-root:` written, branch cut in place, report says `worktree-root undeclared`.
- [ ] Answer with a path inside the repo. Expected: refused with a reason, in-place fallback.

## Implementation plan

_Populated by `/tasks plan TASK-174` — leave empty until then._
