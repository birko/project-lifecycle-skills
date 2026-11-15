---
id: TASK-385
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-15
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [FIELD-021]
pr: null
github-issue: null
jira-key: null
---

# The record-branch and nothing-on-the-default-branch rules ignore `integration: single-branch`

## Context

Found 2026-11-15 while recording FEATURE-004's changed decisions. `/feature decide` step 6, `/feature review` step
5b and `/tasks close` § *Closing a STORY / EPIC* step 5 put a record on a `record/<ID>` branch whenever the default
branch has an upstream, for a person to land through a PR; `close` step 10 writes no generated file on the default
branch whenever there is an upstream. None of them reads `integration:`.

This repo declares `integration: single-branch` and has an upstream, so by the text every decide, review and
container close here should go to a record branch and the dashboard should never be committed on `main`. In
practice every one has been committed on `main` and pushed (`b94dd8c` FEATURE-004's own decide, `fd0f3ca` a
container close, today's dashboard refreshes). Either the rules are right and this repo has been breaking them, or
they were written for `pr-per-task` and `workspace: worktree` (FEATURE-001 D23, D25–D29, D31) and their scope was
never stated. AGENTS.md § Conventions states the upstream rule "under `workspace: worktree`" in one entry and
without that scope in the next.

On 2026-11-15 the FEATURE-004 decide record was committed on `main`, following this repo's precedent, and this task
was filed rather than a record branch opened.

## Acceptance criteria

- [ ] Each of the four sites states the configuration its record-branch or nothing-on-default rule applies to, read
      from the declarations (`integration:`, `workspace:`), never inferred
- [ ] Under `integration: single-branch` the outcome is stated: commit on the default branch, or a record branch, with
      the reason
- [ ] The two AGENTS.md entries agree on the scope
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Re-landing any record already committed on `main`

## Human test plan

- [ ] Cold-drill `/feature decide` on a single-branch fixture with an upstream (a bare local remote). Expected: it
      commits where the fixed text says, and does not report the scope as undecided

## Implementation plan

_Populated by `/tasks plan TASK-385` — leave empty until then._
