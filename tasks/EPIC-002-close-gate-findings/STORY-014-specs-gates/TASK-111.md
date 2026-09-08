---
id: TASK-111
parent: STORY-014
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-6]
pr: null
github-issue: null
jira-key: null
---

# regen.md quotes a status-comment format the task template no longer emits

## Context

**From a [[code-review]] pass on 2026-09-08.**

`skills/specs/verbs/regen.md:54` quotes the task template's enum comment verbatim —
`# status: todo | in-progress | review (…) | blocked | done | cancelled` — and says it is *"what the
task template emits on every file"*. TASK-073 changed the template (and STORY/EPIC/idea) to
`# status — one of: todo, in-progress, …`, so **that claim is now false**: the quoted string survives in
only two historical task files.

**The hazard it describes is still real** — a regen reading the commented enum instead of the live
`status:` field is exactly what TASK-036 fixed — but an agent grepping for the quoted line finds
nothing and may conclude the hazard is gone. A stale quote is worse than a paraphrase here: it looks
checkable.

This is the writing-side/reading-side contract AGENTS.md already names: the template changed and the
skill that reads its shape was not updated in the same change.

## Acceptance criteria

- [ ] `regen.md:54` describes the comment format the templates emit **today**, or stops quoting a
      literal string and describes the hazard by shape instead
- [ ] The guidance still prevents reading the commented enum rather than the live field — the fix must
      not lose what TASK-036 established
- [ ] Any other skill quoting the old literal is found and fixed in the same change, or its absence is
      stated as checked
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Changing the template's comment format again — TASK-073 settled it.
- Whether the enum comment should exist at all — also TASK-073.

## Human test plan

- [ ] N/A — fully covered by a grep: the quoted literal must not appear in `skills/` except where it
      genuinely matches what a template emits. A human adds nothing to a string comparison.
