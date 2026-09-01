---
id: TASK-100
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-086-4]
pr: null
github-issue: null
jira-key: null
---

# Step 3c derives its set from what a run *created*, and landing is the one act that invalidates without creating

## Context

**From the 2026-09-01 cold drill of `adopt-project` on a cloned consumer with constructed git state.**

Step 3c says an adoption that **creates** an input to a generated file owes a re-run of that file's owning
verb, and is explicit that the set is derived from creation rather than from survey rows:

> *"An adoption that creates an input to a generated file owes a re-run of that file's owning verb."*
> *"3c derives its set from what this run **actually created**, not from a list here."*

**Landing an unlanded file creates nothing and invalidates a generated file anyway.** The measured case: an
untracked `tasks/_loose/TASK-022-…md` is offered for landing; `tasks/README.md` was generated before it
existed and does not list it. Take the offer and the dashboard is stale against history the moment the
commit lands — but this run created nothing, so 3c's set is empty by its own derivation rule and the step
never fires. The runner found the hole and declined to act on it:

> *"The step is written around **creation**, and a landing is the one act that changes what a generated
> file should say without creating its input. … hand-shaping a generated file to fix it is forbidden and
> re-running it uninvited is outside 3c's derived set."*

So it correctly did neither, and raised it as a question instead. That is the right behaviour and it should
not require a runner to reason its way there.

### Why the obvious fix is wrong

**Do not widen the trigger to "created or landed".** A landing is not always an invalidation — landing a
`.gitignore` or a `CHANGELOG.md` feeds nothing — and 3c's whole design is that the set is *derived*, never
listed, precisely so it stays correct as the layer grows. A second trigger word invites the same list-drift
the step avoided.

The shape that fits the existing rule: 3c already asks, of each artifact the run touched, *"is anything's
output computed from this?"* The defect is that **"touched" is currently spelled "created"**. Landing is a
touch. So is an owner verb's amendment, which raises the same question one step further out and should be
checked while the fix is open.

**The ordering constraint already in the file must survive.** Step 3's *land before any re-run that would
rewrite the same file* is explicit and load-bearing — landed-then-overwritten is a `git revert` away,
overwritten-then-landed is gone. Any regeneration this task adds happens **after** the landing, never
instead of it.

**And the no-op invariant must survive too.** 3c's own table says a pure no-op *"writes nothing, and says
nothing"*. A landing that turns out not to change a generated file's content must stay silent rather than
announcing a regeneration it did not perform.

## Acceptance criteria

- [ ] Landing an unlanded artifact that is an input to a generated file triggers the owning verb's re-run, without widening 3c into a list of trigger verbs
- [ ] The derivation stays a derivation — the set is still computed by asking what reads the touched artifact, not enumerated in prose
- [ ] An owner verb's **amendment** of an existing artifact is checked against the same question, and either covered or explicitly excluded with a reason
- [ ] Step 3's land-before-rewrite ordering is unchanged and still explicit
- [ ] A landing whose regeneration is a pure no-op still writes nothing and says nothing
- [ ] Layer parity: the rule lands where both front doors read it
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Which verb owns which generated file. `LAYER.md`'s Owner column already answers that and 3c already reads it.
- Whether spec bodies are regenerated automatically. They stay an offer — `/specs regen` is real token spend, and 3c says so.
- The `present, uncommitted` offer's shape — **TASK-086** settled that; this is what happens *after* the offer is taken.

## Human test plan

- [ ] Cold-drill a repo with an unlanded task file and a dashboard generated before it, expected answers withheld, and confirm the runner reaches the regeneration question from the instructions rather than deriving it
- [ ] Confirm a landing that feeds nothing generated produces no regeneration and no mention of one

## Implementation plan

_Populated by `/tasks plan TASK-100` — leave empty until then._
