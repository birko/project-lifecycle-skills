---
id: TASK-019
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# new-project still offers a CI stub a fresh consumer cannot pass

## Context

Spawned from TASK-018's close gate: `/verify-conventions` on that diff flagged a **layer-parity
gap that predates it**, so it does not belong in that task.

`LAYER.md`'s CI row carries TASK-007's rule — never offer CI to a repo whose build depends on paths
outside itself, because a permanently-red gate is worse than no gate. `new-project`'s own § step-5
**CI stub** bullet carries no such caveat: *"write a minimal `.github/workflows/ci.yml` … that runs
install → build → test"*, keyed only on whether the chosen stack has a known CI shape.

That is exactly backwards for the shape this team scaffolds most. `birko-new-project` hands off to
[[new-project]] for the universal layer and then wires the consumer to framework **source** through
`$(BirkoSrc)` / `BIRKO_SRC`. So a brand-new Birko consumer is created with the red-on-first-run
workflow that TASK-007 established must never be offered — the greenfield door writing what the
brownfield door refuses to write.

Two front doors, one shared inventory, and the rule living only in the row that adoption happens to
read. It is the layer-parity failure mode described in `AGENTS.md § Conventions`, arriving through
creation detail rather than through the inventory.

**Confirmed still open, and sharpened, by TASK-031's parity inspection (2026-08-19).**
`new-project/SKILL.md:124` carries no isolation guard at all — its only conditions are "skip for
docs-only" and "ask before assuming a non-GitHub CI host" — so unlike `adopt-project` it cannot reach
the `missing, not offered` state even where the state is correct. The worked case is not hypothetical:
`birko-new-project`, chained by `new-project`, wires `$(BirkoSrc)` at a sibling framework tree, which is
the `Latent` shape `LAYER.md` § *CI a repo cannot pass* exists for — arriving on a brand-new project
rather than an adopted one.

When this lands, carry `LAYER.md`'s re-derivation framing with it (reworded by TASK-031): the isolation
check is re-read from the manifests, never a remembered verdict, and what it suppresses is the offer, not
the status line.

## Acceptance criteria

- [ ] `new-project`'s CI-stub step defers to `LAYER.md`'s CI row rather than restating the offer — the isolation check is the row's rule, and the step should not carry a second, weaker copy of it
- [ ] Scaffolding a project whose build will reference an out-of-repo path (the stack scaffolder wires one, or the user says the framework lives outside the repo) **skips the CI stub and says why**, matching adoption's `missing, not offered` reporting
- [ ] `birko-new-project`'s handoff is checked end to end: a fresh consumer gets no `ci.yml`, with the reason stated once, not a workflow plus an apology
- [ ] Whatever wording lands is checked against the layer-parity rule: if it is a *rule*, it lives in `LAYER.md`; if it is *creation detail*, it lives in the step — and nothing lives in both
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Making Birko consumers CI-able at all — a distribution decision, tracked as STORY-009's territory.
- Adoption's side of the rule; TASK-007 settled it and TASK-018 gave it a state name.

## Human test plan

- [ ] Scaffold a throwaway .NET project through `birko-new-project` and confirm no `ci.yml` is written and the reason is reported once
- [ ] Scaffold a self-contained node project through `new-project` and confirm the CI stub is still written exactly as before — the caveat must not suppress the normal case
- [ ] Re-read `new-project` step 5 and `LAYER.md`'s CI row back to back and confirm the rule appears in one of them, not both

## Implementation plan

_Populated by `/tasks plan TASK-019` — leave empty until then._
