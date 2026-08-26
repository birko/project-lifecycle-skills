---
id: TASK-078
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-077]
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# Findings end at `/tasks intake`, and the skill is actually installed

## Context

The last task in STORY-007, and it carries the story's sharpest sentence:

> **Findings end at `/tasks intake`, not at a grill.** The report is the means; tracked, ranked, pickable
> refactor tasks are the deliverable. Ending at "here is a report, pick one" means the other findings
> evaporate — `intake` already exists to drain exactly this kind of pass.

**This repo has the measurement that proves it.** `AGENTS.md § Findings become tasks, or they evaporate`
exists because review passes write no files; 17 correctly-written defect tasks once sat in `_loose/` where
`/fix-next` could see 2 of them (TASK-040, TASK-042). An architecture pass is a *pass*, so `intake` is the
entry point — not `spawn`, which is for a single adjacent finding.

**And the pool rule applies, which is the part easy to get wrong.** Filing the tasks is not enough: a task
outside a pool is filed but unranked. `intake` stamps the epic `kind: review-intake`, which is what puts them
in [[fix-next]]'s pool — so the handoff must go through `intake` rather than a batch of `/tasks new` calls
that would land the findings somewhere nothing ranks them.

### The second half: it has to be installed

A **new skill folder needs an installer re-run** before either runtime can resolve it — one junction is made
per folder, at install time ([ADR 0009](../../../../docs/adr/0009-installers-link-rather-than-copy.md)).
This is not a footnote: **TASK-011 exists because `adopt-project` shipped invisible to both runtimes** for
exactly this reason. The lint's advisory install-root check will report the drift, and it is advisory, so
nothing fails the build to remind anyone.

New skills go in `skills/` — the only tree linked into *both* roots
([ADR 0010](../../../../docs/adr/0010-skills-pi-is-frozen-and-pi-only.md)).

## Acceptance criteria

- [ ] The skill's findings hand off to [`/tasks intake`](../../../../skills/tasks/verbs/intake.md), producing an epic stamped `kind: review-intake` with stories by theme — **not** a batch of `/tasks new` calls
- [ ] The handoff states that ending at the report is the failure mode, and why: an unfiled finding is invisible to `pick`, to the `Next up` snapshot, and to [[fix-next]]
- [ ] Each filed task carries enough of its candidate's report content to be picked **without** re-reading the report — the report is provenance, not the brief (`intake`'s own rule for `--source`)
- [ ] A theme slug is chosen from `intake`'s ladder for each story, so `fix-next`'s key 6 has something to read — never inferred from a title
- [ ] Both installers are re-run and the skill resolves in **both** roots; `skills-lint`'s install-root section reports no drift for it
- [ ] The skill is registered where the repo expects a new one: `README.md`'s skill list and `docs/architecture.md` if it changes the picture
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- The scan, the finding classes and the report — **TASK-076** and **TASK-077**.
- Changing `intake` itself. If the architecture pass needs something `intake` cannot express, that is a finding against `intake` and gets its own task rather than a local workaround.
- Draining the tasks the first run files. That is `/fix-next`'s job afterwards, and deliberately a separate session.

## Human test plan

- [ ] Run the whole pass on this repo end to end and confirm the deliverable is **tracked tasks in a pool**, not a report — then check `/fix-next` can actually see them
- [ ] Pick one filed task and confirm it is workable without opening the report
- [ ] Confirm the skill resolves in both `~/.claude/skills` and `~/.pi/agent/skills` after the installer re-run — the TASK-011 failure mode, which is silent
- [ ] Confirm at least one finding is *rejected* by the deletion test and does **not** become a task, so the filter is visibly doing work

## Implementation plan

_Populated by `/tasks plan TASK-078` — leave empty until then._
