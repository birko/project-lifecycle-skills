---
id: TASK-030
parent: STORY-011
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# `close`'s single-branch SHA backfill instructs an impossible amend

## Context

Found on 2026-08-19 while closing TASK-026 on this repo, by trying to follow the instruction.

`skills/tasks/verbs/close.md` step 7 says:

> **SHA backfill:** if `pr:` should reference this very commit, write the short SHA into the task file
> now and stage that one-line edit so it rides in the *merge* (PR-per-task) — or, on a plain
> single-branch flow, fold it into the commit by amending before anything else references it.

The PR-per-task half is sound: the SHA of the *work* commit is recorded, and the edit rides in a
separate *merge* commit. The single-branch half cannot be done. To write the SHA you must first have
the commit; amending then produces a **different** SHA, so `pr:` names a commit that no longer
exists (the pre-amend object is unreachable). There is no fixed point — a commit cannot contain its
own hash.

This repo runs `integration: single-branch`, so it is the branch of that sentence this repo always
takes. What actually works is a small follow-up commit that writes the reference, which is what
TASK-026 did.

It matters beyond tidiness now that TASK-026 has landed: `pr:` is the strong path for `/specs`
provenance and a stale or missing one drops the task to the message fallback. An instruction that
cannot be followed gets silently skipped, which is how `pr: null` became the norm on 390 of 392
tasks in the first place.

## Acceptance criteria

- [x] The single-branch path prescribes a mechanism that terminates — a follow-up commit that records the reference, or an explicit "leave `pr:` null on this flow and rely on the subject rule", decided rather than left ambiguous
- [x] Whichever is chosen, the reason is stated inline: the amend has no fixed point
- [x] The PR-per-task path is untouched — it is correct as written
- [~] If the answer is a follow-up commit, `close` says what it contains and that the task file's status flip stays in the *work* commit (the ordering rationale in step 6 must survive)
      — **N/A: the follow-up commit was the option rejected.** Its costs are recorded inline in step 7 so the next reader does not re-propose it. Step 6's ordering rationale is untouched.
- [x] The interaction with [[specs]] provenance is named: a task left with `pr: null` falls back to the subject rule, which is weaker but honest
      — named, and **corrected in the stronger direction**: on `single-branch` the subject rule is not a weaker fallback, it is the **only** provenance path, so it is load-bearing rather than optional. `regen.md` said the opposite and was fixed in the same commit.
- [x] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Making the backfill retroactive for tasks already closed (still out of scope, as in TASK-026).
- The PR-per-task merge mechanics.

## Human test plan
**Items 1 and 3 were written for the option that was rejected** — both presuppose `pr:` gets filled. Restated
below with the originals struck through, so it is visible that the target moved because the **decision** went
the other way, not because it was lowered. What they were really asking — *does provenance actually resolve
after a single-branch close?* — is unchanged and is what was run.

- [x] ~~"Close a throwaway task on a `single-branch` project following the revised text verbatim, and confirm `pr:` names a commit that `git cat-file -e` resolves"~~ → **confirm `pr:` is left null and provenance still resolves.** Exercised on **three real closes from today**, on this `single-branch` repo, rather than a throwaway: TASK-010, TASK-045 and TASK-062 all carry `pr: null`, and in each case the **first task id in the commit subject is that task's own** — so `regen`'s subject rule attributes each correctly. The designed path works end to end.
- [x] Close one on a PR-per-task project and confirm nothing changed
      — verified by diff rather than by a second repo: the PR-per-task behaviour is character-for-character the same instruction (write the SHA, stage it, let it ride in the *merge*), with only the *reason* it works added. No `pr-per-task` project is to hand, and inventing one would test the fixture, not the change.
- [x] ~~"Run `/specs regen` afterwards on the single-branch project and confirm the task resolves through the `pr:` path, not the fallback"~~ → **confirm it resolves through the subject rule, which is now the designed path here.** Verified as the mechanism above; a full `regen` could not run regardless — `docs/specs/.map.yml` is `areas: []`, so there is no mapped area to regenerate.

## Implementation plan

_Populated by `/tasks plan TASK-030` — leave empty until then._

## Outcome

**What was broken.** `close` step 7 told a `single-branch` project to write the commit's own SHA into `pr:`
and *amend*. **A commit cannot contain its own hash**: amending yields a different SHA, so `pr:` would name
an object that is now unreachable. There is no fixed point, so the instruction could not terminate — and an
instruction that cannot be followed gets silently skipped, which is how `pr: null` became the norm on 390 of
392 tasks in the first place. This repo declares `single-branch`, so it is the branch of that sentence every
close here takes.

**Decided: leave `pr:` null on `single-branch`, explicitly.** Not as a shrug — the field is *structurally
unfillable* on a flow with no second commit, and saying so is what stops the next reader trying again.

**Rejected: a follow-up commit that records the SHA.** It terminates, and it is what was done by hand when
this was found. Rejected on two costs, both recorded inline in step 7: it doubles the commit count on every
close, and — the one that decided it — the follow-up **names the task in its own subject**, so `regen`
attributes that commit too, and `shaped-by`'s file list gains the task file for a commit containing nothing
but a one-line frontmatter edit. The fix would pollute the provenance it exists to serve.

**Why null is safe here, and why that makes another rule load-bearing.** `regen` attributes a commit to the
task whose id **leads its subject** — and step 7's *own* message bullet, three lines above, mandates exactly
that subject shape and explains why. So a `single-branch` repo resolves by construction. Step 7 now says the
subject rule is therefore **not optional** on this flow: it is the only provenance path, and anyone
tightening or removing it must fix this first.

**A ripple this change created, fixed in the same commit.** `regen.md:69` claimed *"[[tasks]] `close` writes
the commit SHA into `pr:`, so tasks closed since that shipped never reach this path."* That became false the
moment `single-branch` was told to leave it null — those repos reach the fallback on **every** task,
permanently. Corrected, with the consequence spelled out for a reader who finds an empty field: **do not read
`pr: null` on a `single-branch` repo as a close that was skipped** — read `integration:` in
`tasks/.config.yml` before concluding anything from it.

**Step 6 — verified on real closes, not a fixture.**

| Check | Result | Role |
|---|---|---|
| `pr:` null + subject rule resolves, on this single-branch repo | TASK-010, TASK-045, TASK-062: all `pr: null`, and the **first** subject id is the task's own in every case | **fix-dependent** — this is the mechanism the change chose |
| PR-per-task instruction unchanged | diff is +4/−1 on one file; the deleted line's PR-per-task half is restated verbatim with only its rationale added | contract pin |
| `skills-lint` / `skills-lint-test` | OK (18 skills) · 40 passed, 0 failed | contract pin |

**Step 7.** No usable spec map (`areas: []`) — no regen. Stated, not skipped. And the irony is recorded rather
than smoothed: this task is *about* spec provenance, and the spec layer it feeds does not exist here yet
(STORY-008).

## Progress log

- step 2 — picked; ranked above TASK-024 on key 2 (**reachability**: this repo declares `single-branch`, so the broken branch of that sentence is on the path *every* close here takes — seven of them today — whereas TASK-024 is an adoption-time gap with TASK-063 already reopening the adjacent row). Key 6 (theme) **inert**: every EPIC-002 story declares `correctness-invariants`.
- step 3 — verified: **held, and the reasoning checked out under scrutiny.** Also checked whether this repo's own commit convention (`fix(skills): TASK-NNN — …`) satisfies `regen`'s leading-id rule, since the chosen fix depends on it: `regen.md:68` covers it explicitly — *"the leading id is the author whether or not a prefix precedes it"*.
- step 4 — layer: **local.**
- step 5 — fix in `skills/tasks/verbs/close.md` step 7 (single-branch leaves `pr:` null, with the no-fixed-point reason and the rejected alternative), plus `skills/specs/verbs/regen.md:69` whose claim this made false.
- step 6 — exercised on three real closes from today; PR-per-task pinned by diff; lint 18/18 and suite 40/0.
- step 7 — no usable spec map (`areas: []`); regen skipped and stated.
- step 8 — 5d sweep: both bullets are boundaries (retroactive backfill out per TASK-026; PR-per-task merge mechanics out). Nothing spawned. Gate: standards pass, intent pass, correctness pass; security not applicable.
