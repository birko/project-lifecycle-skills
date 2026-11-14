---
id: TASK-370
parent: STORY-016
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-13
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-067-1, DRILL-067-2]
pr: null
github-issue: null
jira-key: null
---

# The seed's hint comments sit above their tokens, and `.gitignore` creation disagrees with its own check

## Context

Filed 2026-11-13 at TASK-067's close, from comparing its drill (`%LOCALAPPDATA%/Temp/d067`, `report.md`, § 4) with
earlier ones. Both readings now meet FEATURE-002 D10's two-runner bar.

- **DRILL-067-1 — hint comments above the token.** The seed rule removes "the hint comment (`<!-- … -->`) directly
  beneath" a filled token. In `templates/CLAUDE.seed.md` the Code structure, Naming and UI/UX hints sit **above**
  their tokens, so a faithful render leaves them in the consumer's rulebook. Raised by d360 (point 7) and d067
  (point 2), and a third time by d132 (2026-11-14, a Python scaffold, point 7: it kept the hints above their tokens).
- **DRILL-067-2 — `.gitignore`, creation against check.** LAYER.md's `.gitignore` row creates an absent file "with
  the same entries the Present check looks for … the `!.env.example` negation" unconditionally. Its check offers the
  negation only where the `.env.example` row applies (TASK-357). A file created for a repo whose `.env.example` row
  is `not applicable` therefore carries a line its own check would never offer. Raised by d102b (point 2) and d067
  (point 6).

## Acceptance criteria

- [ ] Each seed hint comment's position matches the removal rule, or the rule names both positions, so a faithful
      render leaves no hint in a consumer's rulebook
- [ ] The `.gitignore` row's create branch and check branch agree on the `!.env.example` negation
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The no-stack `## Conventions` shape: TASK-067 (done)

## Human test plan

- [ ] Re-run TASK-067's brief (`%LOCALAPPDATA%/Temp/d067/brief.txt`, on a fresh empty `fieldnotes/` and `skills/` at the
      fix) with a cold runner. Expected: no `<!-- -->` hint left in `## Conventions`, and the `.gitignore` it creates
      matches what its check would ask for

## Implementation plan

_Populated by `/tasks plan TASK-370` — leave empty until then._
