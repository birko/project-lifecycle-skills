---
id: TASK-001
parent: null
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# STORY.md cannot express dependency edges

## Context

Discovered while seeding EPIC-001 (STORY-001). `templates/TASK.md` carries `depends-on: []` and
`blocks: []` in its frontmatter, but `templates/STORY.md` carries neither — its frontmatter is
`id / parent / status / created` only. `templates/EPIC.md` has no edge fields either.

So a story that genuinely gates another story has nowhere to record it. In EPIC-001 the whole
eight-story sequence had to be written as a prose table in the EPIC body, which no verb reads:
`/tasks pick` cannot tell that STORY-004 is blocked by STORY-003, `/tasks triage` renders no edge
in the tree, and `/roadmap` cannot audit an ordering it cannot see. The dependency information
exists but is invisible to every consumer of it.

Filed rather than fixed inline because this is a defect in the `tasks` skill itself, not part of
EPIC-001's scope — hence `_loose`, not a story under that epic.

## Acceptance criteria

- [ ] `templates/STORY.md` carries `depends-on: []` and `blocks: []`, matching `TASK.md`'s shape and field names exactly — no new vocabulary for the same concept
- [ ] Decide and document whether `EPIC.md` needs them too (epics may legitimately gate each other), or record why it deliberately does not
- [ ] `verbs/block.md` works at story level, not tasks only
- [ ] `verbs/triage.md` renders story edges in the tree view
- [ ] `verbs/new.md` sets the fields when a story is created with a stated blocker
- [ ] `roadmap`'s cross-tree pass reads story edges, so an out-of-order story is auditable drift
- [ ] EPIC-001's prose sequence table is replaced by real frontmatter edges on its eight stories, and the table either goes or is explicitly kept as human-readable narrative
- [ ] `skills-lint` or a verb rejects an edge pointing at a non-existent id

## Out of scope

- Cross-epic edges (a story in one epic gating a story in another) — decide only if it falls out naturally; do not design for it here.
- Any change to `TASK.md`'s existing fields, which already work.

## Human test plan

- [ ] Create a two-story epic where story B declares `depends-on: [STORY-A]`; run `/tasks triage` and confirm the dashboard tree shows the edge
- [ ] Run `/tasks pick` with only the blocked story available and confirm it declines or warns rather than offering blocked work
- [ ] Run `/roadmap` and confirm an out-of-order story is reported as drift

## Implementation plan

_Populated by `/tasks plan TASK-001` — leave empty until then._
