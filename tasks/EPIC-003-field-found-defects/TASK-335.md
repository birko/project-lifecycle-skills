---
id: TASK-335
parent: EPIC-003
feature: null
# status — one of: todo, in-progress, verify (code done, sign-off pending), done, cancelled
status: todo
# blocked: <reason> — set by /tasks block, never by hand; status stays as it is; /tasks unblock removes it
priority: P2
# assignee — one of: agent (default), unassigned, human, or an installed agent type's name; ai is read as agent, never written
assignee: agent
created: 2026-11-04
depends-on: []
blocks: []
# findings: ids this task remediates — from a review/audit/harvest/drill pass, or from ordinary
# field use with no pass behind it at all. Prefixes: see /tasks intake
findings: [DRILL-323-1, DRILL-323-2]
pr: null
github-issue: null
jira-key: null
---

# `/feature pick` names decompose as the next action while a sign-off waits, against the debt rule

## Context

Found by TASK-323's cold drill (2026-11-04), which **failed** on it and stays at `verify` until this lands. Recorded on TASK-323.

- **DRILL-323-1:** `skills/feature/SKILL.md` § *Verification debt surfaces first* says any "what's next?" answer states the pending sign-off as the next action first. The same file's `pick` summary says approved rows with no tasks go to `decompose`, which "outranks sign-off", and `verbs/pick.md` gate E never fires beside D. On a feature with a task at `verify` and a new undecomposed row, the runner gave decompose as the single next action and never mentioned the waiting sign-off. Both rules are stated; nothing says which wins, or that step 6 can name both.
- **DRILL-323-2:** bare `/feature` reads the phase off `status.md` (roadmap step 5: renderers do not re-derive), while `pick` derives it by `status.md` rule 2. A `status.md` written before a new row was decided shows `review` in the listing and `building` in `pick`, and no rule flags the disagreement. (The drill's fixture had such a stale file by hand, so this half is partly a fixture artefact. But `/feature decide` adding a row after the last status run produces the same state.)

## Acceptance criteria

- [ ] `pick` step 6's next action on a debt feature with undecomposed rows is stated once, and agrees with § *Verification debt surfaces first*: either it names the pending sign-off too, or the debt rule says where pick is the exception and why
- [ ] A stored phase that disagrees with the derived one is either recomputed by the listing or reported, and the rule says which
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The behaviour the originating task fixed, which its drill passed

## Human test plan

- [ ] Re-run TASK-323's drill brief (on its Progress log) on the same fixture shape with a `status.md` that `/feature status` would write. Expected: the listing leads with FEATURE-001 labelled `building · 1 task awaiting sign-off`, and `pick`'s confirmation names the pending sign-off as well as the decompose offer. Then re-run TASK-323's plan step and close it

## Implementation plan

_Populated by `/tasks plan TASK-335` — leave empty until then._
