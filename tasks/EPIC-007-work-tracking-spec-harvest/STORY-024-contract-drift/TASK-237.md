---
id: TASK-237
parent: STORY-024
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-03
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-28]
pr: null
github-issue: null
jira-key: null
---

# Three skills still advise a project-local skill that shadows them, which does not work

## Context

Found by the defect-draining spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-28.** `skills/fix-next/SKILL.md` § Conventions: "A project needing more than that should ship a project-local
  skill that shadows this one." Name-shadowing does not work. `skills/verify-conventions/SKILL.md` § Scope layering
  records the measurement (2026-09-07, Claude Code): a name present at both user and project level resolves user-level
  first, so the project copy never runs. That skill's fix is a **distinct** name (`verify-<project>-conventions`) that
  the generic skill discovers in its step 0 and hands off to.
- **Same advice, same root cause, outside this harvest's area:** `skills/roll-changelog/SKILL.md` (intro: "A repo may
  ship its own project-local `roll-changelog` that shadows this one") and `skills/new-project/SKILL.md` (§ Related
  skills: "a project-local variant may shadow it"). Fixed in the same edit, because leaving two of the three copies
  keeps the advice alive.

## Acceptance criteria

- [ ] None of the three skills advises shadowing by name
- [ ] Each says what a project does instead: either the distinct-name hand-off `verify-conventions` uses (which the
      skill must then actually perform), or that project specifics go in the project's own guide, which the skill
      already reads
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Adding a step-0 discovery to `fix-next` or `roll-changelog`. If the chosen wording needs one, that is a spawned task

## Human test plan

N/A — wording, checked against `verify-conventions` § Scope layering.

## Implementation plan

_Populated by `/tasks plan TASK-237` — leave empty until then._
