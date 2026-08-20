---
id: TASK-039
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P3
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The dashboard template has no slot for the todo-by-priority breakdown

## Context

Found by TASK-034's criterion 4 — *"brought back to a state a plain `triage` run reproduces exactly"*.
Making this repo's `tasks/README.md` template-faithful **removed a useful line**:
`` `todo` by priority: 15× P2 · 3× P3. ``

That line is not narrative and not a convention violation of the kind TASK-034 fixed: it is **fully
derivable** from task frontmatter, and the bare-`/tasks` stdout snapshot renders exactly it
(`SKILL.md` § *Status snapshot*, the `todo:` row with its `(<p0>× P0, …)` breakdown). The gap is that
`templates/README.md.tmpl` has no placeholder for it and `triage` step 7 does not list one, so the
persisted dashboard cannot show what the transient snapshot does.

So it was dropped rather than hand-added back — hand-adding it is what TASK-034 exists to stop. Filed
instead, which is the point of the rule.

**P3, deliberately:** the information is one `/tasks` away and nothing is wrong, only thinner than it
could be. Recording the reason so a re-reader does not mistake the low priority for low confidence.

## Acceptance criteria

- [ ] `templates/README.md.tmpl` gains a placeholder for the breakdown, and `triage` step 7 lists it with the others
- [ ] It follows the snapshot's own suppress-zeros rule — a priority with no tasks is omitted, not shown as `0×`
- [ ] Absent when there are no `todo` tasks at all, rather than rendering an empty tail
- [ ] This repo's dashboard reproduces byte-identically from a plain render **after** the change, so TASK-034's criterion is not quietly undone
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Any other difference between the stdout snapshot and the persisted dashboard. If there are more, they are their own finding — do not sweep them in here without measuring first.
- Changing what counts as `todo`, or the priority vocabulary.

## Human test plan

- [ ] Render the dashboard on this repo and confirm the breakdown matches what bare `/tasks` prints
- [ ] Cancel or close every `todo` task in a throwaway fixture and confirm the line disappears rather than rendering empty
