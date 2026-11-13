---
id: TASK-354
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
findings: [DRILL-065-4, DRILL-065-5, DRILL-065-6]
pr: null
github-issue: null
jira-key: null
---

# A full `adopt-project` run writes three things the skill does not say it may write

## Context

Spawned 2026-11-13 from TASK-065's full-pass drill (`%LOCALAPPDATA%/Temp/d065b/full`, brief and report kept there).
One cold runner ran a full `/adopt-project` on an adopted fixture with nobody to answer. It raised these
readings; none of them is about scoped runs, and all three predate TASK-065. They are grouped because each is a
write in a full run whose permission or timing the text leaves open.

- **DRILL-065-4 — guide sections written without consent.** `skills/adopt-project/SKILL.md` says "nothing is
  written unasked", and the report's **amended** bucket is "changed with the user's consent". But the agent-guide row
  in `skills/new-project/LAYER.md` reads as an instruction: "**Merge by section.** Add missing `##` sections". With
  nobody present, the runner appended `## How we work`, `## Architecture` and `## Commands` to `CLAUDE.md` unasked and
  reported them as amended.
- **DRILL-065-5 — `## Commands` is stale on arrival.** The guide's sections are rendered before
  `populate-tests adopt` wires a harness in the same run. So `## Commands` read "None found" while the run went on to
  write `pytest.ini` and a `python -m pytest` command. Nothing says which order these steps run in, or that a section
  rendered earlier is refreshed afterwards.
- **DRILL-065-6 — `populate-tests adopt` adds `.gitignore` lines that adoption only offers.**
  `skills/populate-tests/REFERENCE.md` § harness invariants says "add the runner's output dirs … to `.gitignore`".
  Under adoption, `.gitignore` lines are an *offer* (step 3, and the never-write-unasked rule above). The runner held
  back and did not add `.pytest_cache/`, reasoning from the adopter's rule. Neither file says which rule wins.

## Acceptance criteria

- [ ] Whether adoption appends missing guide sections unasked or offers them is stated in one place. The agent-guide
      row and the "nothing is written unasked" sentence agree with it
- [ ] Either a guide section is rendered after the steps that create what it describes, or the run refreshes it.
      `## Commands` is the measured case
- [ ] Whether `populate-tests adopt`'s `.gitignore` lines are written or offered inside an adoption is stated, on the
      side that owns the rule, and the other side points at it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Where fill offers and delegated questions are asked: TASK-102
- An absent `workspace:` under `single-branch`: TASK-353 (DRILL-065-2)

## Human test plan

- [ ] Re-run the full-pass brief (`%LOCALAPPDATA%/Temp/d065b/full/brief.txt`, on a fresh copy of `d065/adopted` and of
      `skills/`) with a cold runner. Expected: none of DRILL-065-4 … 6 in its "left undecided" section

## Implementation plan

_Populated by `/tasks plan TASK-354` — leave empty until then._
