---
id: TASK-031
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `missing, not offered` never reopens, even when a filed task removes the reason

## Context

Found in the TASK-020 drill on the `widget-store` fixture (2026-08-19), outside that task's
acceptance criteria.

`missing, not offered` exists to record an **adjudication** rather than an absence, and
[LAYER.md](../../../skills/new-project/LAYER.md) § *Detect what the repo has* says why: *"collapsed
into `missing`, the question is re-opened on every re-run and the user re-reads the same explanation
each time."* That is right, and § *CI a repo cannot pass* leans on it — the standing example is a repo
whose build escapes its own root, where a workflow would be red forever.

The drill hit the case that reasoning does not cover. `widget-store`'s CI row went
`missing, not offered` because `tsconfig.json` mapped `@shared/*` outside the repo root — **and the
same defect was filed as a task in the same run** (the fixture's TASK-002). So the premise of the
adjudication has an owner and an expiry: resolve that task and CI becomes offerable. Nothing connects
them. A re-run after it closes reads CI as settled and never re-offers it, which is the *opposite*
failure from the one the state was invented to fix — permanent silence instead of permanent nagging.

This is not exotic. Adoption's own § 3b now guarantees that a fill-blocking defect gets a task, and
`CI a repo cannot pass` is the standing consumer of exactly such defects, so the two rules *routinely*
produce this pair. On a repo where the external path is deliberate (a shared framework tree obtained
outside the repo, the `Latent` case), no task is filed and the state behaves correctly — the two
situations look identical in the survey table and differ only in whether a task exists.

## Acceptance criteria

- [ ] A `missing, not offered` verdict records **whether its reason is owned by a task**, and the task id when it is — the survey and the report both carry it
- [ ] A re-run finding that task `done`/`cancelled` treats the verdict as **expired** and re-asks, rather than reading it as settled
- [ ] A verdict with **no** owning task (a deliberate external dependency) keeps today's behaviour exactly — it must not start re-asking every run, which is the defect the state was created to prevent
- [ ] The distinction is stated where it is decided, not only in `LAYER.md` — a reader of § *CI a repo cannot pass* learns that a filed defect changes the verdict's lifetime
- [ ] Layer parity honoured if `LAYER.md` changes: `new-project` and `adopt-project` both reconciled in the same change
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Any change to *when* CI is offered. The isolation test itself is correct and TASK-019 owns the stub it offers.
- Re-litigating `missing, not offered` as a state. It earns its place; this is about its lifetime.
- The fixture repo — a throwaway, not a drill target to preserve.

## Human test plan

- [ ] Drill a repo whose CI row is `missing, not offered` **with** an owning task; close that task; re-run adoption and confirm CI is re-offered
- [ ] Drill a repo whose external dependency is deliberate and has no task; re-run twice and confirm it is not re-asked either time
- [ ] Confirm the report distinguishes the two, so a reader can tell "settled" from "waiting on TASK-NNN"
