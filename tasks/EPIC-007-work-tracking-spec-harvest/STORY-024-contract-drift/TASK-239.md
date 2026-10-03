---
id: TASK-239
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
findings: [SH-37, SH-38, SH-41]
pr: null
github-issue: null
jira-key: null
---

# The spec template emits a key `regen` says to omit, and `regen`'s steps run out of order

## Context

Found by the specs-from-code spec harvest (2026-10-03, EPIC-007, spec committed in b24eb8b).

- **SH-37 — template vs regen.** `skills/specs/verbs/regen.md` step 5b says to omit `shaped-by-unresolved` when
  `shaped-by-derived` is `false`. `skills/specs/templates/spec.md` always emits `shaped-by-unresolved: {{N}}`, with no
  note that the line is conditional. A faithful render therefore writes a count for a derivation that never ran, which
  is the shape § Conventions *A template ships nothing a render cannot make true* forbids. (`source-commits:` is
  conditional too, and its template line already says so.)
- **SH-41 — step order.** `regen.md`'s steps run 5, 5c, 5a, 5b. Step 5 refers forward to 5a, 5b and 5c, and 5c sits
  before the two it follows by letter.
- **SH-38 — root marker (cosmetic).** `verbs/init.md` step 1 names the root marker `tasks/.config.yml`. `SKILL.md`
  § Project root names it `.config.yml`. The [[tasks]] walk it defers to uses `tasks/.config.yml`.

## Acceptance criteria

- [ ] `templates/spec.md` marks `shaped-by-unresolved` as omitted when derivation did not run, in the way the template
      already marks `source-commits`
- [ ] `regen.md`'s steps appear in the order they run, with no forward reference
- [ ] `SKILL.md` and `init.md` name the root marker identically
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- `verify`/`show` drift — TASK-238

## Human test plan

N/A — template and step order, checked by rendering the template once for a run where derivation did not run.

## Implementation plan

_Populated by `/tasks plan TASK-239` — leave empty until then._
