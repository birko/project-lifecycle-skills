---
id: TASK-242
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P1
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-65, SH-67, SH-70]
pr: null
github-issue: null
jira-key: null
---

# `new-project`'s fill steps can ship unrendered tokens, and run a remote command before the repo exists

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`. All three are in `skills/new-project/SKILL.md` steps 3–6 and its § Conventions.

- **SH-70 — four tokens have no fill rule.** `README.seed.md`'s `{{GETTING_STARTED_COMMANDS}}` and `{{LAYOUT_TREE}}`,
  and `CLAUDE.seed.md`'s `{{ARCHITECTURE_NOTES}}` and `{{BUILD_RUN_COMMANDS}}`.
  - Step 3 says to fill README tokens "from intake", and intake gathers none of them.
  - `{{ARCHITECTURE_NOTES}}` has a source only when the scope grill runs, and the grill is skipped silently for
    throwaway and docs-only repos.
  - Two of them describe a skeleton that is only written in step 5, and no step comes back to fill them.
  - The no-dangling-token rule covers `## Conventions` subsections only.
  - Result: an unrendered token, or an invented value, can reach a consumer repo.
- **SH-65 — remote before repo.** For hybrid-GitHub, step 4 says "do step 6's remote action now (offer
  `gh repo create` …)". Step 6's command is `gh repo create <name> --private --source=. --remote=origin`. That fails
  on a directory that is not a git repo, and `git init` is only asked about in step 6. The "ask for `owner/name`"
  alternative still works.
- **SH-67 — clobber with consent vs never overwrite.** § Conventions says "never clobber a present
  README/CLAUDE/.gitignore without showing the diff and confirming", which allows overwriting with consent.
  `LAYER.md`'s README and agent-guide rows say never rewrite a human's README and never touch an existing guide's
  content. Step 1 defers to LAYER's merge column.

## Acceptance criteria

- [ ] Each of the four tokens has a stated source, and a stated outcome when that source is absent (docs-only, grill skipped) — neither outcome being an unrendered token or an invented value
- [ ] Tokens that describe the skeleton are filled after step 5 writes it, or the step that fills them says why it can do so earlier
- [ ] Hybrid-GitHub never runs `gh repo create --source=.` before the git-root question is answered
- [ ] § Conventions states the same merge rule as LAYER's rows, with no "overwrite after confirming" path for the files LAYER protects
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Disagreements between the layer rows and the front doors (TASK-243)
- The seed templates' own wording (TASK-248)

## Human test plan

- [ ] Scaffold a docs-only project with the grill skipped, from a cold runner, and grep the result for `{{`. Expected: none, and every section that had no source is either removed or says so honestly
- [ ] Scaffold a hybrid-GitHub project into an empty folder and decline git at first. Expected: no `gh` command fails, and the remote is created or deferred cleanly

## Implementation plan

_Populated by `/tasks plan TASK-242` — leave empty until then._
