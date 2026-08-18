---
id: TASK-003
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: unassigned
created: 2026-08-18
depends-on: []
blocks: [TASK-004, TASK-005]
findings: []
pr: null
github-issue: null
jira-key: null
---

# adopt-project: survey and fill

## Context

The brownfield front door, paired with [[new-project]] by name and role. This task builds the
mechanical core — survey what the repo has, fill only what is missing, report both — with **no
inference and no grilling**; TASK-004 adds those. Split this way so the skill is usable and
testable after this task alone.

Every sub-init it orchestrates is already delta-based and safe to re-run: `tasks init` adopts a
pre-skill tree without disturbing it (`verbs/init.md` edge cases), `specs init` re-discovers and
proposes a delta rather than dropping areas (`verbs/init.md:9`), `populate-tests` has an `adopt`
mode, and `new-project` merges rather than clobbers. Nothing here reimplements those — it calls
them in dependency order and reports.

## Acceptance criteria

- [x] `skills/adopt-project/SKILL.md` exists with frontmatter whose `name` matches the folder, and trigger phrases covering the two entry cases: a repo with an older/partial layer, and a repo with code and no layer at all (include the Slovak phrasings this team uses)
- [x] **Survey** compares the repo against the current universal layer and reports per artifact: present / missing / present-but-outdated
- [x] **Fill** creates only what is missing, delegating to the owning skill (`tasks init`, `specs init`, `populate-tests adopt`) rather than hand-rolling file shapes
- [x] **Never overwrites** a file the repo already owns; a conflict is reported, not resolved silently
- [x] Idempotent — a second run on an unchanged repo reports zero gaps and writes nothing
- [x] Ends with a report of what was created versus what was left alone
- [x] `docs/BRIEF.md` follows the adopted-repo rule from STORY-001: stamp the adoption date, state that no original ask survives, never reconstruct one from the README
- [x] Listed in `README.md` **§1** (the at-a-glance table) rather than §5, and cross-linked from `new-project`. Criterion amended deliberately: §5 is *Satellite skills — by where they plug in*, and this is a front door, not a satellite. Placing it there would have miscategorised it
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Inferring conventions from the codebase and confirming them with the user → TASK-004.
- Backporting the brownfield rules into `new-project` → TASK-005.
- Any change to the sub-skills' own init verbs; if one is found lacking, spawn a task rather than widening this one.

## Human test plan

- [x] Run it on **this** repo — must report zero gaps, since STORY-001 built the layer by hand. Anything it reports is either a real STORY-001 defect or a bug here; both are findings worth having — run from the repo copy, pre-junction
- [x] Run on **Presenter** (2026-08-18, installed skill) — the target this line named, and the first exercise of the fill on a repo with code, tasks and tests but no agent guide. Created: `CLAUDE.md` (184 lines, § Conventions carrying rules read out of the code and confirmed), `docs/BRIEF.md` as an adoption stamp rather than a reconstruction, `docs/specs/.map.yml` via delegation to `/specs init` (11 areas), `docs/features/README.md` from the feature template, a `CHANGELOG.md` stub with no unasked backfill. Left alone: README (pointer offered, declined), `tasks/`, the xUnit harness, and `docs/architecture.md` — deliberately not created, because `SPEC.md` is that repo's architecture record and a second overview would drift from the first. Two defects filed against this behaviour from the same run: TASK-020 (found defects fixed without an id) and TASK-022 (the dashboard left stale by construction)
- [x] Run it twice in a row on Latent: identical output, second run wrote nothing — run from the repo copy, pre-junction
- [x] Latent README untouched by the fill — run from the repo copy, pre-junction

## Implementation plan

1. Read `new-project/SKILL.md` step 3 and enumerate the universal layer as a checklist — that list is the survey's definition of "complete", and TASK-005 makes it a shared one rather than two copies.
2. Write the survey: for each artifact, classify present / missing / outdated, and print the table before writing anything.
3. Write the fill: delegate per artifact, in dependency order (agent guide and ground truth first, then `tasks init`, then `specs init`), skipping everything already present.
4. Write the report and the idempotence guarantee.
5. Run the drill on this repo; file anything it surfaces.
