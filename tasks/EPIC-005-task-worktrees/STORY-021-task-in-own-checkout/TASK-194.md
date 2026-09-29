---
id: TASK-194
parent: STORY-021
feature: FEATURE-001
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: unassigned
created: 2026-09-29
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-186-2, DRILL-186-3]
pr: null
github-issue: null
jira-key: null
---

# `pick` step 3 leaves open whether this machine's tasks also appear as `taken`, and step 9 calls `gh` in local mode

## Context

Found by the TASK-186/188 drill (2026-09-29). The runner's output was correct on both points, but it
had to resolve each by choosing one of two readings. This task groups the two findings, because both
are unclear wording in `skills/tasks/verbs/pick.md` that the same drill found.

- **DRILL-186-2.** Step 3 hides every task whose branch exists and prints it under `taken (hidden)`. It then
  prints a worktree-held `in-progress` branch "apart", and says a `review` branch copy "belongs to 2b's
  verification debt, not to this line". Neither says whether the task is **also** dropped from
  `taken (hidden)`. The runner reported: *"It's just as plausible that 'this line' means only the 'in progress on this
  machine' line, which would mean TASK-012 is listed a second time as taken."* Listed twice, the session's own
  task reads as someone else's, which is the defect CR-F001-5 fixed.
- **DRILL-186-3.** Step 9 runs `gh issue view <num> --comments` whenever `github-issue:` is set, whatever the
  `mode:`. A repo that went from `hybrid` back to `local` keeps its `github-issue:` values, so a pick calls
  GitHub in a repo that declared it does not sync. The fixture reached this state by construction: its
  config was switched to `mode: local`. A real repo reaches it by switching back.

## Acceptance criteria

- [ ] Step 3 says outright that a task reported on the "in progress on this machine" line or as verification debt is **not** also listed under `taken (hidden)`, or that it is, whichever is intended.
- [ ] Step 9 fetches GitHub comments only under `mode: hybrid` with `provider: github`, or states why `github-issue:` alone is enough.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

## Out of scope

- The tie-break for equal priority and date in the pick list. That is TASK-139.

## Human test plan

- [ ] Re-run the TASK-186 fixture's bare `/tasks pick` brief (recorded on TASK-186). The runner reports no ambiguity on either point, and `taken (hidden)` does not list TASK-011 or TASK-012.
