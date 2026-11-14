---
id: TASK-375
parent: STORY-011
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P3
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-14
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-375-5]
pr: null
github-issue: null
jira-key: null
---

# `triage` is told to flag a parent that contradicts its children, and its verb file has no step for it

## Context

Filed 2026-11-14 from the dashboard refresh (`%LOCALAPPDATA%/Temp/d375`, `report-run1.md` point 5 and
`report-run2.md` point 1). `skills/tasks/SKILL.md` says "`triage` / `audit`: flag any parent whose status contradicts
its children (e.g. all-children-done under an `in-progress` story, or a story listed in an EPIC body that no longer
exists), and offer to reconcile." `skills/tasks/verbs/triage.md` has no step for it, no question text, no
answer-less path and no slot in the dashboard. Both runners therefore handled it on their own: run 1 rendered the
parents as stored and wrote its own question, run 2 printed flags and a question to stdout and left the file silent.

**The live case:** STORY-023 reads `in-progress` with 36 of 36 tasks done, and STORY-017 has only a cancelled task
open. Neither is flagged anywhere a reader of `tasks/README.md` would see.

## Acceptance criteria

- [ ] `triage.md` owns the check as a step: what counts as a contradiction, the question it puts (verbatim), and what
      the run does with no answer, per `AGENTS.md` § *An ask-step carries the question it puts and the answer-less path*
- [ ] Whether and where a flagged parent appears in `tasks/README.md` is stated
- [ ] `SKILL.md`'s line becomes a pointer to that step rather than a second statement of it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Closing STORY-023 itself: the owner's call (`/tasks close STORY-023`)
- `audit`'s side of the same line, unless the fix shows it shares the step

## Human test plan

- [ ] Run `/tasks triage` with a cold runner on a fresh clone of this repo with `skills/` at the fix. Expected:
      STORY-023 is flagged in the stated place, the question is the stated text, and with no answer nothing is
      reconciled and the report says so
