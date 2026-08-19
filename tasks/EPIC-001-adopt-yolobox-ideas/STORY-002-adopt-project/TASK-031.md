---
id: TASK-031
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: in-progress
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

## Implementation plan

### Design question settled, 2026-08-19 — before planning

The question was *where does a `missing, not offered` verdict persist, so a later run can tell that its
premise expired?* Two shapes were on the table: the verdict carries the owning task id, or an adoption
stamp holds the open adjudications. **Both are wrong, and the question dissolves.** Three facts:

1. **There is nowhere to persist it.** `adopt-project`'s survey and report are **stdout only** — no verb
   writes either to a file. A re-run therefore cannot read a previous run's verdict at all, so "the
   verdict carries the id" has no medium. (The report's own line about "the part that outlives the
   conversation" means it outlives the *step*, not the session.) The stamp shape would work but costs a
   new persistent field, a `LAYER.md` row and a parity change — heavy, for the next point's reason.
2. **The verdict is not a memory; it is a derivation.** `LAYER.md` § *CI a repo cannot pass* gates the
   offer on a cheap, deterministic evidence check — an MSBuild `Import`/`ProjectReference`, a Cargo
   `path =`, an npm `file:`, or an editable Python install whose **resolved** target lands outside the
   repo root. Re-running that check answers the question directly and for free: fix the escaping
   dependency and the check passes, so the offer returns **with no bookkeeping at all**.
3. **CI is the only producer of this state, and the skill decides it, not the user.** `LAYER.md`:
   *"the skill has decided **not** to offer it"*. A user who declines an offer lands in a different
   bucket entirely (`left alone` — "you declined"). So every instance of this state is skill-derived
   from evidence, and none of it is a user judgement that would need remembering.

**So the real defect is the framing, not a missing mechanism.** `LAYER.md` describes the state as a
remembered adjudication — *"that state is what stops the next run from putting the same question
again"* — which invites an implementer to treat it as sticky when it is in fact re-derived every run
from evidence that can change. A state that is *derived* must never be cached as a *decision*; that is
the mirror image of the repo's existing "read the declaration, never infer it" rule, and it is the
sentence to fix.

**The tension that made this look hard, and its resolution.** `LAYER.md` wants to stop re-explaining
the same thing every run, but recomputing means the run does mention it every time. These are different
acts, and separating them is the whole fix:

| Act | Every run? |
|---|---|
| Re-deriving the evidence check | **yes** — cheap, and the only thing that can notice the premise expired |
| Re-opening the *offer* ("shall I add CI?") | **no** — suppressed while the evidence holds. This is the "question" the state exists to stop |
| Printing a one-line status (`CI: not offered — <dep> escapes the root`) | **yes** — a status line is not a question, and silence here would hide a real gap |

The owning task id, where one exists, appears in that status line as **information** (`… — TASK-003
owns it`). It is a courtesy to the reader, never the mechanism — nothing reads it back.

⚠ **Acceptance criteria question.** Criterion 2 says *"A re-run finding that task `done`/`cancelled`
treats the verdict as expired and re-asks"* — that prescribes consulting the owning task, which this
design rejects: the re-run consults **the evidence**, and the task's state is irrelevant to it (a task
can be closed without the dependency actually being resolved, and the evidence would then correctly
still suppress the offer — a strictly better answer than trusting the task). Criterion 1 survives
unchanged. Flagging rather than editing; the intent — "the verdict expires when its premise does" — is
met by the stronger route.

### Steps

_To be drafted once the criteria question above is answered. The shape is a `LAYER.md` § *CI a repo
cannot pass* rewording plus the matching line in `adopt-project` step 4, both small; layer parity
applies because `LAYER.md` changes, so `new-project` is checked in the same change even if it needs no
edit._
