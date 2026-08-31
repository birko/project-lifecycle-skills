---
id: TASK-085
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [VC-027-1]
pr: null
github-issue: null
jira-key: null
---

# `LAYER.md`'s survey-state list has outgrown the shape it is written in

## Context

**Spawned from TASK-027's close gate on 2026-08-31** (`/verify-conventions`, 💡).

`LAYER.md` § *Report the state precisely* is a bullet list of **eight** survey states. Each bullet now
carries the state's definition, its probe, its claimability guard, its interactions with other states, and
a worked example — and the `present, uncommitted` bullet reached **~350 words in a single bullet** after
TASK-027 (which lengthened an already-long one, so this is partly that task's doing and is filed rather
than hidden).

`AGENTS.md` § Conventions › Output/prose rules says: *"Tables and short lists beat paragraphs for anything
an agent must branch on. Reserve prose for the why."* The states **are** a branch — an agent picks exactly
one per artifact — and they are currently the longest prose in the file.

**Why this is filed at P3 and not treated as urgent.** No behaviour is wrong. Every bullet is individually
correct, and TASK-027 put the branch on its own bolded line precisely so the rule is readable ahead of the
rationale. This is a readability trajectory, not a defect: the list has gained states steadily (the file
itself says it *"grows as real repos turn up conditions it cannot yet express"*), and a growing branch list
written as prose bullets is exactly the shape the convention warns about.

**Do not assume the answer is a table.** The bullets carry genuinely different *kinds* of content, and a
table with a 350-word cell is worse than the bullet it replaced. Shapes worth weighing: a compact
decision table (state · when it applies · what it suppresses) with the rationale moved below as named
subsections; or leaving the list and extracting only the probes. **The risk to respect is that every
consumer reads this file**, so a reshape that loses a guard — `present, outdated`'s *claim it only where
something can tell you*, or `not applicable yet`'s lazy-row-only restriction — trades a readability win
for a correctness loss. That is the real constraint, not the formatting.

## Acceptance criteria

- [ ] An agent can determine which state applies to an artifact without reading a paragraph per state
- [ ] Every guard, suppression rule and claimability restriction currently attached to a state survives verbatim in meaning — enumerate them before and after and show none was dropped
- [ ] The rationale is still present, not deleted for brevity — the *why* is what stops a state being claimed wrongly
- [ ] `new-project` and `adopt-project` both still resolve every state they reference (layer parity)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Adding, removing or redefining any state. This is the shape the list is written in, not its content — a change to the content is a different task with a different review.
- The rest of `LAYER.md`. If the row table has the same problem it is its own task.

## Human test plan

- [ ] Hand the reshaped section to a reader who has not seen it and ask them to classify three artifacts (one present, one staged-but-uncommitted, one lazy-and-absent); confirm they reach the right state without reading the whole section
- [ ] Diff the guard inventory before and after and confirm it is unchanged

## Implementation plan

_Populated by `/tasks plan TASK-085` — leave empty until then._
