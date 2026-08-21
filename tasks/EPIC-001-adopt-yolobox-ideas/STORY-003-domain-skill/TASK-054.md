---
id: TASK-054
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-21
depends-on: [TASK-052]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Backfill the decision records this repo already owes

## Context

**A group task, deliberately.** These are individually small, share one shape, and splitting them would
bury the connection that makes them cheap to write together — the repo's own *group rather than
fragment* rule.

`AGENTS.md § Conventions` says an ADR that hardens into a standing rule gets a one-line entry pointing
back at it, with the ADR carrying the trade-off and the alternatives. This repo has the **inverse**: rule
entries carrying their reasoning inline, because there was nowhere to put it. Eight records are owed.

**Four named by STORY-003**, all pre-dating `docs/adr/`:

| # | Decision | Why it clears the three-part bar |
|---|---|---|
| 1 | Bash + a CI harness in a repo whose stack rule says *markdown only, no new language without an ADR* | the stack rule explicitly demands one; hard to reverse once CI depends on it |
| 2 | `AGENTS.md` canonical with a one-line `CLAUDE.md` import bridge | surprising without context — every reader meets `CLAUDE.md` first |
| 3 | `integration: single-branch` for this repo | hard to reverse (history shape), and it hid the TASK-050 defect |
| 4 | Reimplementing the yolobox ideas against our artifact model rather than porting them | the trade-off that defines EPIC-001 |

**Four more created 2026-08-20/21**, each currently a `§ Conventions` bullet carrying its own trade-off:

| # | Standing rule | The trade-off it is carrying inline |
|---|---|---|
| 5 | Independent review axes are never merged or reranked | one ranked list is easier to read, and that ease is the harm |
| 6 | A shared vocabulary has one owning file, expanded in place | the two consumers use the list for different jobs, which is what makes a copy look justified |
| 7 | A flag declaring an absent capability must cover every point needing it | scoping it narrowly looks safer and blocks in the untested configuration |
| 8 | A ranking key that cannot discriminate must say so | silent degeneracy is indistinguishable from the key having worked |

## Acceptance criteria

- [ ] Eight records exist under `docs/adr/`, each carrying context, the decision, the **rejected**
      alternatives, and consequences
- [ ] Each is **dated honestly** — the date the decision was made, not the date it was written down, with
      the retroactive authorship stated so nobody reads it as contemporaneous
- [ ] Each of rules 5-8 has its `§ Conventions` bullet **trimmed to the enforceable one-liner plus a
      pointer**, with the trade-off moved into its record — the split the convention itself mandates
- [ ] Records 1-4 are written from evidence in the repo (commits, `EPIC.md` bodies, `.config.yml`), and
      where the reasoning cannot be reconstructed the record **says so** rather than inventing a rationale
- [ ] Every record clears the three-part bar; if one does not on a closer read, it is **not written**, and
      the task says which and why
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The ADR shape and the three-part bar — TASK-052 owns both; this task applies them.
- Any decision made *after* this task is picked. Those go through `domain` normally; a backfill that
  keeps growing never closes.
- Consumer-repo ADRs. Their decisions are theirs.

## Human test plan

- [ ] Read records 5-8 cold and confirm each explains a rule whose § Conventions line no longer carries
      its own justification — the two halves must compose without repeating
- [ ] Confirm no record reads as contemporaneous when it was written retroactively
- [ ] Pick the weakest of the eight and argue it against the three-part bar out loud; if it fails, delete
      it and record that it failed. A backfill that quietly waves the bar through discredits the bar

## Implementation plan

_Populated by `/tasks plan TASK-054` — leave empty until then._
