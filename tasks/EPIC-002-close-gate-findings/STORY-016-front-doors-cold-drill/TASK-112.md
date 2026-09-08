---
id: TASK-112
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-08
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [CR-7]
pr: null
github-issue: null
jira-key: null
---

# The adopter's report list gained no entry for the `not applicable` state

## Context

**From a [[code-review]] pass on 2026-09-08.**

`skills/adopt-project/SKILL.md:362`'s per-state report list covers `not applicable yet` — the `(lazy)`
state — but has no entry for **`not applicable`**, the settled state the conditional rows introduced.
The paragraph above it claims to cover *"the states that exist today"*, so the omission reads as a
statement that the state does not exist.

`AGENTS.md` is explicit that the two must not be collapsed: *"a library does not acquire a `Dockerfile`
by aging, so one state is settled and the other is pending, and collapsing them loses whether anyone
should look again."* A report list that names only the pending one invites exactly that collapse.

**Filed P3 deliberately.** The generic catch-all rule at `:350` does cover the state, so the adopter
will not misreport it — the defect is that the list contradicts the paragraph introducing it, and a
reader trusting the list over the catch-all gets it wrong.

## Acceptance criteria

- [ ] The report list carries `not applicable` with its own line, distinct from `not applicable yet`
- [ ] The distinction is visible in the wording, not just the label — a reader can tell settled from
      pending without consulting `LAYER.md`
- [ ] The list and the paragraph that introduces it agree about which states exist
- [ ] Nothing restates `LAYER.md`'s state definitions — the list points, it does not copy
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The state definitions themselves — `LAYER.md` § *Conditional rows* owns them.
- The `unknown` state and the frontier-round question — TASK-097 owns that.

## Human test plan

- [ ] Run the adopter's survey over a library with no `Dockerfile` and read the report. Expected: the
      row reports `not applicable`, and the report's own legend explains it without sending the reader
      elsewhere.
