---
id: TASK-053
parent: STORY-003
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-21
depends-on: [TASK-051, TASK-052]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# Layer parity — both front doors learn the glossary and the ADR home

## Context

`AGENTS.md` makes this a **hard rule**, not a nice-to-have:

> **Layer parity (hard rule):** any change that extends the **universal project layer** must update
> **`new-project`** *and* **`adopt-project`** in the same change. […] In practice that means editing
> **`skills/new-project/LAYER.md`**, the single inventory both skills consume — if a layer change does
> not touch that file, it is being copied somewhere instead of shared.

`domain` adds two artifacts to that layer, so both doors must know them: the scaffolder creates the layer
for new repos, the adopter reconciles it for existing ones. Extending one strands every project already
using the skills.

**The interesting half is what "seed" means for a lazily-created artifact.** Every other `LAYER.md` row
names something that always exists — a README, a CHANGELOG, a `tasks/` folder. `docs/glossary.md` and
`docs/adr/` exist **only when there is something to write** (TASK-051, TASK-052), so seeding them empty
would contradict the rule that makes them useful. The row therefore has to express *"this layer includes
a glossary, created on first real term"* rather than *"create this file"* — and the adopter's survey has
to report a legitimately-absent glossary as **not applicable yet**, distinctly from **missing**.

**The owner-verb reconcile rule applies** (`AGENTS.md`): whichever verb owns each row must answer *"is
this instance current?"*, not only *"does it exist?"*, and must report **already current** separately
from **brought up to date**. TASK-024 records that most owner verbs still cannot do this — so state which
answer these rows give rather than inheriting the gap silently.

## Acceptance criteria

- [ ] `skills/new-project/LAYER.md` gains the glossary and ADR rows — the single inventory, edited once
- [ ] Neither `new-project` nor `adopt-project` restates the row's content; both read `LAYER.md`
- [ ] The rows express **lazy** creation: the layer includes these artifacts, and an absent one in a repo
      with nothing to record is correct, not a gap
- [ ] `adopt-project`'s survey distinguishes **not applicable yet** from **missing**, so a legitimately
      absent glossary is never reported as drift — and never offered as a fill
- [ ] Each row names its **Owner** verb, and that verb's answer to *"is this current?"* is stated
- [ ] `new-project` does not create empty `docs/glossary.md` or `docs/adr/` at scaffold time
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **The skill itself** — TASK-051 and TASK-052.
- **Backfilling this repo's owed ADRs** — TASK-054. Adoption machinery and content are separate.
- Teaching the other owner verbs to reconcile (TASK-024's scope). This task states what *these* rows
  answer; it does not fix the others.
- Retro-adopting the consumer repos. That is a drill, and it belongs to whoever runs `adopt-project`
  there next.

## Human test plan

- [ ] Run `new-project` on a throwaway repo and confirm **no** empty glossary or `docs/adr/` is created,
      while the layer report still names them as part of the layer
- [ ] Run `adopt-project` on a repo with no glossary and confirm the survey says *not applicable yet*
      rather than *missing*, and offers no fill
- [ ] Run it again on a repo that *does* have a glossary and confirm it reports **already current** as
      distinct from having brought it up to date
- [ ] Drill the adopter on a real consumer repo (WorkoutTracker is the smallest with a live layer) and
      confirm the two new rows do not produce spurious findings

## Implementation plan

_Populated by `/tasks plan TASK-053` — leave empty until then._
