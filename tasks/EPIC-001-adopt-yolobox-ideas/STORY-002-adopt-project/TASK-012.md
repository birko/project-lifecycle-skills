---
id: TASK-012
parent: STORY-002
feature: null
status: todo
priority: P1
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The adopt-project router still teaches three survey states; LAYER.md now mandates four

## Context

`e5ce252` added § *Detect what the repo has* to `skills/new-project/LAYER.md`, which requires the
survey to report **four** states — `present`, `present, elsewhere`, `unknown`, `missing` — because
a false "missing" invites a fill that writes over a working setup (the .NET repo with 54 test
files in sibling `*.Tests` projects, reported as having no harness).

`skills/adopt-project/SKILL.md` was not updated with it:

- Step 1 (`:31`) still says classify as **present / missing / present but incomplete** — a
  complete-looking, closed list of three, and it is the file an agent loads first.
- Step 4's report (`:73`) has three buckets — created / left alone / still missing — with nowhere
  to put "present, elsewhere" or "unknown".
- Step 3 does not carry LAYER.md's rule that **`unknown` stops the fill**.

Step 1 does point at LAYER.md, so a thorough agent would read the four states there and hit a
direct contradiction with the sentence that sent it. Either way the fix is overridable by the
defect it was written to prevent — and this is precisely the drift the LAYER.md/SKILL.md split
("inventory here, creation detail there") was introduced to stop.

## Acceptance criteria

- [ ] Step 1's classification uses LAYER.md's four states, or defers to it rather than restating a shorter list
- [ ] Step 4's report has a bucket for **present, elsewhere** (saying *where*) and for **unknown** (saying what could not be determined)
- [ ] Step 3 records that an `unknown` row stops the fill for that artifact and asks instead
- [ ] The two files are checked for any other place where one restates the other's list — the split is "two axes, not two copies", and a restatement is the drift itself

## Out of scope

- Changing the four states themselves; they are settled by TASK-008's finding.
- The installer gap that keeps the skill unreachable → TASK-011.

## Human test plan

- [ ] Run the survey against a .NET repo with sibling `*.Tests` projects and no `tests/` folder — the harness row must read *present, elsewhere* with the paths, never *missing*
- [ ] Run it against a repo where a row genuinely cannot be determined and confirm it reports `unknown` and declines to fill that row
- [ ] Confirm the printed report shows all four states, so a reader can tell "not found" from "did not look properly"

## Implementation plan

_Populated by `/tasks plan TASK-012`._
