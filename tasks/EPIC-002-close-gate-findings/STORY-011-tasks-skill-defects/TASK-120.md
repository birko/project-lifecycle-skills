---
id: TASK-120
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-09
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: []
pr: null
github-issue: null
jira-key: null
---

# `pick`'s handoff branches on an `assignee:` value no task in the tree has

## Context

**Found 2026-09-09 while answering a question about running a picked task in a subagent.**

`skills/tasks/verbs/pick.md` step 9 dispatches on three `assignee:` values:

| Branch | Behaviour |
|---|---|
| a specific agent name (`CSharpCodingAgent`) | suggest spawning that agent with the task body as the brief |
| **`ai` (generic)** | present the task body; this conversation begins work |
| `human` | print and wait |

Measured across the tree:

```
111  assignee: agent
  8  assignee: unassigned
  0  assignee: ai
```

**No task in this repo matches the generic branch**, and `unassigned` matches nothing at all. The
template writes `{{ASSIGNEE}}`, and whatever fills it has never produced `ai`.

### Why this survived

The fallthrough happens to do the right thing — the conversation just starts work, which is what the
`ai` branch would have said anyway. So the defect is **invisible while the branches agree** and bites the
moment they differ, which is exactly what TASK-121 proposes to make them do.

This is the contract-drift shape AGENTS.md already names: *"a format one skill reads is a contract the
writing skill must state too"*. Recorded on the reading side alone, the writing side changed and the
reader degraded silently instead of failing.

## Acceptance criteria

- [ ] `pick` step 9 dispatches on the values that are actually written — `agent` and `unassigned` at
      minimum — with no branch that matches nothing
- [ ] The **writing** side states the vocabulary too: whatever fills `{{ASSIGNEE}}` names its allowed
      values, so the two sides cannot drift again unnoticed
- [ ] `unassigned` has defined behaviour; today it falls through every branch
- [ ] Whether `ai` remains a synonym is decided explicitly, not left as a stale third value
- [ ] The vocabulary is stated **once**, and the other reader points at it — `new`, `pick` and the
      template must not each carry a list
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Offering a subagent for the generic case** — TASK-121, which depends on this dispatch being correct
  before it adds a branch to it.
- Any other step of `pick`.

## Human test plan

- [ ] N/A — fully covered by inspection: every `assignee:` value present in a real tree must match a
      branch, and every branch must match a value something writes. A human adds nothing to a set
      comparison.
