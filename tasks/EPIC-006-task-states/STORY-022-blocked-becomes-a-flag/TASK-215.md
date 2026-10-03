---
id: TASK-215
parent: STORY-022
feature: FEATURE-003
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
findings: [CR-141, VC-058]
pr: null
github-issue: null
jira-key: null
---

# The `blocked:` writers do not quote their value, and two readers of the block note are undeclared

## Context

Found by `/feature review FEATURE-003` (2026-10-03).

- **CR-141 — unquoted values break strict YAML.** `close` step 6 writes
  `blocked: merge deferred: <reason>; code complete on task/TASK-NNN`. It contains `: `, so unquoted it is a
  YAML error, and pi parses frontmatter strictly (AGENTS.md § Framework / stack). `block` step 4 writes
  `blocked: <reason>` with no quoting rule at all. `init` step 3b already has the rule (quote last, single
  quotes, the non-string scalars).
- **VC-058 — format contracts stated on one side only.** `skills/tasks/verbs/export.md` reads the
  `> Blocked <date> — <reason>` note, but `block.md`'s "keep that shape" names only `init` 3b. Tracker comments
  starting `Blocked:` are written by `block` step 5b and `export`, and read by `import` ("newest comment
  starting `Blocked:`"); neither writer says so. AGENTS.md § *A format one skill reads is a contract the
  writing skill must state too*.

## Acceptance criteria

- [ ] Every writer of a `blocked:` value (`block` step 4, `close` step 6, `import`) applies one quoting rule,
      stated once and pointed at, not copied three times (AGENTS.md § *Defer to a shared inventory*)
- [ ] `block.md` step 5's shape contract names every reader of the note (`init` 3b and `export`)
- [ ] The `Blocked:` tracker comment's writers state that `import` parses it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The wording sweep — TASK-213; `close`'s blocked refusal — TASK-214

## Human test plan

- [ ] Run `/tasks close` with a deferred merge on an invented task, then load its frontmatter with a strict
      YAML parser: it parses, and `blocked` is the full string

## Implementation plan

_Populated by `/tasks plan TASK-215` — leave empty until then._
