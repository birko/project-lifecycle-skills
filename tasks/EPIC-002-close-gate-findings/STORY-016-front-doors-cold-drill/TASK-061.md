---
id: TASK-061
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-1]
pr: null
github-issue: null
jira-key: null
---

# `LAYER.md` calls itself the whole layer while `new-project` creates three artifacts it never lists

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance).

`skills/new-project/LAYER.md` opens: *"The single definition of what a lifecycle-ready repo contains…
a second copy is exactly the drift the layer-parity rule exists to prevent."* Its table has 15 rows.

`new-project/SKILL.md` also creates three artifacts that are **not rows**: `LICENSE` (`:84`),
`.env.example` (`:83`), and `Dockerfile`/`.dockerignore` (`:131`).

**The consequence is one-directional and that is what makes it a defect rather than an untidiness.**
`adopt-project/SKILL.md:34` says *"Walk `LAYER.md` and classify every artifact"* — so **adoption can
never notice a missing `LICENSE`**. The drill hit this directly and had to decide for itself that an
artifact with no row gets no state; it chose that reading because `LAYER.md` is the named authority, and
flagged that the two skills' notion of "the layer" therefore differs by three artifacts.

`.env.example` is the sharper half: `LAYER.md`'s own `.gitignore` row implicitly depends on it (the
check is that `.env`/`.env.*` are covered, which the seed writes as `!.env.example`), so the inventory
references an artifact it does not contain.

**The fix is a judgement, not a mechanical addition.** Three plausible shapes, and the task is to pick
one and say why: add all three as rows; add a stated exclusion rule (*"conditional, kind-dependent
artifacts are `new-project`'s alone and adoption does not survey them"*) so the omission becomes
deliberate and documented; or split the file into layer-always and layer-conditional. What must not
survive is the current state, where the omission is indistinguishable from an oversight.

## Acceptance criteria

- [ ] `LICENSE`, `.env.example` and `Dockerfile`/`.dockerignore` are each either a row, or covered by a **stated** rule that says why the inventory excludes them
- [ ] Whichever shape is chosen, `LAYER.md`'s opening claim about being the single definition is true afterwards — amend the claim if the answer is that it is not
- [ ] `adopt-project` can answer "does this repo have a licence?" — or the report states that it deliberately does not, so a reader is not left guessing
- [ ] The `.gitignore` row no longer depends on an artifact the inventory does not account for
- [ ] Layer parity holds: whatever changes, both front doors read it from the one file
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The other seven drill findings — separate tasks under STORY-016.
- Making adoption *fill* a missing licence. Surveying it and offering it are different decisions; this task settles whether it is visible.
- `Dockerfile` content or `.env.example` content. This is about whether the layer accounts for them.

## Human test plan

- [ ] Run `adopt-project`'s survey against a repo with **no** `LICENSE` and confirm the outcome matches whichever shape was chosen — a state, or a stated reason the row is absent from the survey
- [ ] Re-read `LAYER.md`'s opening paragraph against its own table and confirm the claim it makes is now true

## Implementation plan

_Populated by `/tasks plan TASK-061` — leave empty until then._
