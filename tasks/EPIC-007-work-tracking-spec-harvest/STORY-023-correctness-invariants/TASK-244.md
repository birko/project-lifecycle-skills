---
id: TASK-244
parent: STORY-023
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [SH-62, SH-63]
pr: null
github-issue: null
jira-key: null
---

# The adopter's inference rules leave one case unruled, and write where they say to write nothing

## Context

Found by the project-baseline spec harvest (2026-10-04, TASK-080, EPIC-007 third pass) and confirmed by a second
reader against the files at `adc4c27`. Both are in `skills/adopt-project/INFER.md`.

- **SH-62 — a threshold gap.** § *Convention or accident?* gives three rows:
  - "~80%+ **and** at least 5 files" → propose
  - "roughly 20–80%" → ask
  - "under 20%, or fewer than 3 files" → silent

  A pattern at 80% or more across 3 or 4 files falls into no row.
- **SH-63 — glossary candidates are written on the path that writes nothing.** § *Glossary candidates* says, with
  no condition, "Record them in the agent guide meanwhile, under its § Conventions › Naming subsection". § *When the
  rulebook already answers it* says "All covered → skip the round … and write nothing", and on that skip path
  candidates are "reported, not asked". The unconditional write also skips the confirmation that "propose, never
  assert" requires.

## Acceptance criteria

- [ ] Every combination of share and file count maps to exactly one of propose / ask / silent
- [ ] Glossary candidates are written to the guide only when a round runs and the user confirms; on the skip path they are reported only
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The inference skip rule's subsection count (TASK-028)

## Human test plan

N/A — rule text, checked by walking the threshold table for 3, 4 and 5 files at 85%, and the glossary rule on both the round and the skip path.

## Implementation plan

_Populated by `/tasks plan TASK-244` — leave empty until then._
