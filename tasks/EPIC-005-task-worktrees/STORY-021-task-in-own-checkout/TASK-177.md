---
id: TASK-177
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
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

- [x] `LAYER.md`'s `tasks/` row names the new declaration(s) and what absence means.
- [x] `new-project` passes the answer(s) to `/tasks init` (`workspace=`, `worktree-root=`), and `init.md` declares those args.
- [x] `adopt-project`'s survey reads the declarations off the row, never off a list kept in the adopter, and reports them per the decided absence semantics.
- [x] The absence-semantics decision is recorded on FEATURE-001.
- [x] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The config template and `init` reconcile — TASK-173.

## Human test plan

- [x] Cold-run `/new-project` into a scratch folder choosing `workspace: worktree` with a root. Expected: `tasks/.config.yml` carries both as live keys.
- [x] Cold-run `/adopt-project` on a consumer whose config lacks the fields. Expected: the survey reports them according to the recorded absence semantics, and a re-run after answering reports them settled.

## Implementation plan

Decision first: D24 (approved 2026-09-24) — both front doors **ask**, with one wording owned by `/tasks init`.
1. `init.md`: add the `workspace=` / `worktree-root=` args (live keys, like `integration=`). Replace "not asked here" with "asked by the front doors, never by init itself", and hold the **workspace question** verbatim with its answer-less path (absent = `in-place`, reported undeclared).
2. `LAYER.md` `tasks/` row: name `workspace:` (plus `worktree-root:` once chosen) as declarations the survey probes.
3. `new-project`: intake item 7b puts the question and passes the args to `/tasks init`.
4. `adopt-project`: the declaration list and the probe name `workspace:`; the answers pass to `/tasks init`.
5. Drill: `/new-project` choosing worktrees into a scratch folder, and `/adopt-project` unattended on a Presenter copy lacking the fields.

**Drill round 1 (2026-09-24).** Two `claude -p` runners (`--permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(mkdir:*)" "Bash(ls:*)" --add-dir <skills> <repo> <scratch>`). **Not cold on names**, since the skills are installed. This drills behaviour, and each brief held only the person's answers.
- **`/new-project`** into an empty scratch folder, the person answering *its own worktree* and `../wt`. The workspace question was put **verbatim**, then the root question, and `tasks/.config.yml` ended up with live `workspace: worktree` and `worktree-root: ../wt`. **Flaw it exposed:** the root question was `pick`'s wording, which promises a commit on the default branch. Nothing is committed at intake, and the review found the same thing (M1). Fixed: `init` now owns a front-door root question and checks the answer.
- **`/adopt-project`** on a Presenter clone whose config predates the fields, nobody answering. The survey read `^integration:` as settled and `^workspace:` as outstanding, and put the question in the single frontier round. With no answer, nothing was passed or written; `init` added the commented blocks and the report said *workspace undeclared — tasks work in place*. The root was left to `pick`.

**Review (three passes)** — correctness: 2 medium, 3 low, all fixed:
- the borrowed root wording (M1);
- an unchecked root written at setup (M2);
- the question is now skipped under `single-branch`;
- a remote caveat is said at intake;
- the adopter defers the root rather than breaking its one-round rule.

Intent: 4 of 5 met, the fifth being this drill. Conventions: a repo-internal decision id was removed from a shipped skill, and the root question's words now live in `init`.

**Drill round 2, on the fixed text (2026-09-24).** Same runner command.
- **`/new-project`**: again ended with live `workspace: worktree` and `worktree-root: ../wt`, and `../wt` passed the new outside-the-repo check. The runner summarised rather than quoting the root question, so the new wording is confirmed by the review, not by this run.
- **`/adopt-project`, person answers *its own worktree*, then a second pass**. Pass 1: `workspace:` was found outstanding, the question was put verbatim, the answer became a live `workspace: worktree` via `/tasks init workspace=worktree`, and the root was left commented with *worktree-root undeclared — pick will ask*. **Pass 2: `workspace:` was reported settled and not asked again, and `init` reported *already current* and wrote nothing.** Both halves of the human-test step pass.
- The runner raised whether a re-run should ask the root, since the one-round reason no longer applies. Fixed: adoption never asks the root, on any pass, and `workspace: worktree` with no root is a settled state there.
