---
id: TASK-011
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

# `adopt-project` is not installed in either runtime — a new skill folder needs an installer re-run

## Context

`skills/adopt-project/` shipped today (`ef22e64`, `7375162`), but neither runtime can resolve it:

```
ls ~/.claude/skills      → new-project, birko-new-project, …  (no adopt-project)
ls ~/.pi/agent/skills    → new-project, …                     (no adopt-project)
```

`install.ps1` enumerates `skills/` with `Get-ChildItem -Directory` and creates **one junction per
folder**. That is what makes an *edit* live immediately — and exactly why a *new folder* is not:
the junction for it has never been created. So `/adopt-project` does not resolve, and the
description's trigger phrases reach nothing.

This also puts a question mark on STORY-002's drill evidence: any drill recorded before the
junction exists was run by reading `skills/adopt-project/*.md` out of this repo, not by invoking
the installed skill. That is a weaker test — it never exercised discovery, and discovery is the
half that is currently broken.

The repo's own `## Commands` section documents `./install.sh` / `install.ps1` but nothing says
*when* a re-run is required, so the same gap will recur for the next new skill.

## Acceptance criteria

- [ ] `adopt-project` resolves in Claude Code (`~/.claude/skills/adopt-project` exists and points at this repo)
- [ ] It resolves in the pi runtime too (`~/.pi/agent/skills/adopt-project`)
- [ ] The repo records that **adding a skill folder requires re-running the installers** (editing an existing one does not) — in `AGENTS.md` § Commands or § Architecture, wherever it will actually be read
- [ ] Any STORY-002 drill whose evidence predates the junction is re-run against the installed skill, or its human-test line is honestly marked as run from the repo copy

## Out of scope

- Making the installers self-healing (watching for new folders, or a lint that compares `skills/` against the two install roots) — worth considering, but it is a design change, not this fix. If it is wanted, it gets its own task.
- The four-state survey drift → TASK-012.

## Human test plan

- [ ] Re-run `./install.ps1` and `./pi-install.ps1`, then confirm both roots list `adopt-project`
- [ ] In a fresh Claude Code session, type "adopt this repo" and confirm the skill is offered by description match — not by anyone naming the file path
- [ ] Edit one line in `skills/adopt-project/SKILL.md` and confirm the change is live without another install (proving the junction, not a copy)

## Implementation plan

_Populated by `/tasks plan TASK-011`._
