---
id: TASK-340
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-331-1, DRILL-331-2]
pr: null
github-issue: null
jira-key: null
---

# The task template has no `{{FINDINGS}}` token for `new` to fill, and the N/A test-plan wording differs

## Context

Found by TASK-331's verification drill (2026-11-04, recorded on TASK-331). Both claims checked by hand:

- **DRILL-331-1:** `skills/tasks/verbs/new.md` steps 0 and 8 say to set `{{FINDINGS}}` to the id list
  (`--from-review`, `--from-field`). But `skills/tasks/templates/TASK.md` hard-codes `findings: []`, so a literal
  render has no token to fill. A renderer that substitutes only the tokens it finds writes `[]`. The task then
  drops out of `/fix-next`'s pool, because the pool is defined by a non-empty `findings:` (or an intake epic,
  which a `--from-field` loose task does not have). The drills so far wrote the ids by editing the line, so
  nothing has measured the failure yet. A literal reading reaches it.
- **DRILL-331-2:** `skills/tasks/SKILL.md` (Lifecycle, about line 404) writes the plan's opt-out as
  `N/A — covered by automated tests`. `new.md` step 9, `close.md` step 5 and the template write
  `N/A — fully covered by automated tests`. A gate matching one wording misses the other.

## Acceptance criteria

- [ ] `templates/TASK.md` carries a `{{FINDINGS}}` token in YAML-safe form, or `new` says to edit the `findings:` line rather than fill a token. Check AGENTS.md § *A template ships nothing a render cannot make true* for the YAML token rule first
- [ ] One N/A wording across SKILL.md, `new`, `close` and the template
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- TASK-331's three findings

## Human test plan

- [ ] A cold runner files a task with `/tasks new task --from-field` from the template, rendering literally. Expected: the file's `findings:` holds the minted `FIELD-NNN`

## Implementation plan

_Populated by `/tasks plan TASK-340` — leave empty until then._
