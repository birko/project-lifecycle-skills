---
id: TASK-330
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P3
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/tasks migrate` prompts for the repo or project with no question text and no answer-less path

## Context

Spawned 2026-11-04 from TASK-218, whose plan found it while fixing `migrate`'s other ask-steps. It is not one of
TASK-218's four findings, so it was filed rather than folded in.

`skills/tasks/verbs/migrate.md` step 2: `--repo owner/name` (GH) or `--project KEY` (Jira) "overrides interactive
prompt". The prompt itself is never worded, and nothing says what a run does when nobody answers it. AGENTS.md
§ Output/prose rules requires both. The safe unattended outcome is the one step 4 now takes: push nothing,
write nothing, report that the run did not migrate because no target was given.

## Acceptance criteria

- [ ] Step 2 states the question it puts when `--repo`/`--project` is absent, in the form the other ask-steps use
- [ ] It states what happens when nobody answers: nothing pushed, nothing written, the report names the missing target
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Step 4's confirmation, dry run, milestone linkage and the export hand-off — TASK-218

## Human test plan

N/A — wording of one ask-step; the reviewer check against the AGENTS.md rule at close covers it.

## Implementation plan

_Populated by `/tasks plan TASK-330` — leave empty until then._
