---
id: TASK-286
parent: STORY-026
feature: FEATURE-004
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: done
# blocked: <reason> — add this line while the task is blocked, keeping its status; /tasks unblock removes it
priority: P2
assignee: unassigned
created: 2026-10-08
depends-on: [TASK-285]
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/specs regen` names every scenario a regeneration dropped

## Context

FEATURE-004 D3. Nothing in `regen` compares scenarios before and after, so a regeneration that loses a `#### Scenario:` passes review unless a reader happens to spot it. OpenSpec (v1.8.0, v1.9.0, v1.13.2) fails a MODIFIED requirement that would drop a scenario, and names the scenario.

## Acceptance criteria

- [x] Regen compares the old and new scenarios of each requirement that survives, and names every one that disappeared — `regen` step 4: by scenario name, for every changed or renamed requirement
- [x] Before the spec is written, each lost scenario is either explained as behaviour that is really gone (a finding, classified as in step 4) or restored — settled by the code: restored when the code still behaves so, classified as a change when it does not
- [x] A renamed requirement (TASK-285) is compared against the scenarios under its old name — stated in the rule; not exercised by the drill (see the test plan)
- [x] `bash .github/workflows/skills-lint.sh` passes — OK (20 skills)

## Out of scope

- The scenarios of a requirement removed as a whole: the removal itself is the finding

## Human test plan

- [x] Drill: install the changed skill and run `/specs regen <area>` on a real area of this repo, or on a fixture spec staged to exercise the change. Record how the runner was obtained (AGENTS.md § Testing); a scenario deliberately left out of the harvest is named in the review
  - **Passed 2026-11-15**, cold runner: `claude -p --disable-slash-commands --permission-mode acceptEdits` in
    `%LOCALAPPDATA%/Temp/d286`, the cwd holding only `brief.txt`, `skill/specs` at the fix and an invented repo with a
    committed spec and a staged harvested body; its report says no skills were available. The harvest left out
    `Division`'s `Divide by zero panics`: the review printed `lost scenario: "Division" / "Divide by zero panics"`,
    read `src/core.rs:2`, found the code still panics, and restored it word for word, not a change. A requirement
    whose statement was also reworded showed as one removal and one addition, its lost `Subtract` scenario going with
    the removal, as the rule says. **Not exercised:** a rename whose statement is identical but which lost a
    scenario; the fixture's rename was reworded, so it was not a rename by TASK-285's rule.

## Implementation plan

Not planned: one file (`regen` step 4), four criteria, no unknowns.

## Outcome

**What was built:** `/specs regen`'s review names every scenario a changed or renamed requirement lost, and settles
each before writing by reading the code: restored word for word when the code still behaves so, classified as a
change when it does not (FEATURE-004 D3).

**Judgement call:** the code decides, not a question. A lost scenario is either a harvest slip or a real change, and
the code tells them apart; asking a person would turn every slip into a finding nobody needs.

**Flagged, not fixed:** the renamed-with-a-lost-scenario case is stated but was not drilled.

**Close gate (inline; one skill file, one spec):** standards and intent met; correctness by d286; layer parity,
security, comments not applicable; local lint passes; specs-from-code gained the rule and a scenario.

## Progress log

- picked 2026-11-15 in FEATURE-004's build, after TASK-285
- built in skills/specs/verbs/regen.md step 4; drilled d286; closed inline
