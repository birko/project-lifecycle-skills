---
id: TASK-015
parent: STORY-011
feature: null
status: done
priority: P3
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `close` step 5d needs an unattended path — fix-next drives close with no user to take the offer

## Context

`e7f5bd1` added step 5d to `skills/tasks/verbs/close.md`: every `## Out of scope` bullet is
classified as a boundary, as work, or as decided-not-to-do, and work **gets an id now** —
"offer [`spawn`]" — with the hard line *"a close that adds an unowned work bullet is not done."*

Written for an interactive close, and correct there. But `close` is also the merge gate
[[fix-next]] runs **unattended** (its step 8, "do not re-implement any of it"), and that skill's
whole contract is draining defects without holding a user in the loop. Step 5d does not say what
that run does when it meets a work bullet: offering is impossible, auto-spawning is a decision
nobody sanctioned, and stopping contradicts the loop's purpose.

Left ambiguous, the likeliest reading in a long unattended run is the one that keeps the loop
moving — close anyway — which is exactly the evaporation the step exists to prevent, now with a
rule quoted over the top of it.

`fix-next` already declares `spawn` "takes everything this loop surfaces but doesn't own", so the
answer is probably auto-spawn plus a line in the closing report. It should be written down rather
than re-derived by each reader.

## Acceptance criteria

- [x] Step 5d states the unattended behaviour explicitly, distinct from the interactive offer
- [x] The chosen behaviour is reflected where `fix-next` describes what `close` does on its behalf, so the two skills agree in writing
- [x] Whatever the unattended path spawns is named in fix-next's closing report — not only in step 12's `out-of-scope:` counts, which a session nobody watched will never show anyone
- [x] The interactive path is unchanged

## Out of scope

- Changing what counts as a boundary vs work; the classification is settled.
- Whether `fix-next` should ever stop for a user — the broader autonomy question, not this.
- Verifying that a flag one skill passes exists in the receiving verb's arg list — **TASK-045**, spawned
  by this task's own close sweep. `--unattended` is the first instance of that unchecked contract.

## Human test plan

- [x] Run `/fix-next` on a task whose `## Out of scope` holds one unowned work bullet, and confirm the
      run ends with an id for that bullet and a line naming it in the report — **drilled on this task's
      own close**: its Out of scope carried one unowned work bullet, the sweep spawned TASK-045 without
      offering, rewrote the bullet to name it, and reported `2 boundary, 1 spawned, 0 declined`
- [x] Run `/tasks close` interactively on the same shape and confirm the offer still appears — verified
      by diff rather than by a second run: the interactive branch is **byte-identical**, `git diff` on
      `close.md` touches no line containing the `offer [`spawn`]` wording. The change adds a branch
      beside it and replaces nothing

## Implementation plan

**Decision taken: auto-spawn, and name the ids in the report.** The task proposed it and the repo's own
declarations settle it — `fix-next` already states that `spawn` "takes everything this loop surfaces but
doesn't own", and the standing preference is that *a spare task is cheap noise you can cancel, an
untracked paragraph is work that silently disappears*. The two alternatives both defeat step 5d:
stopping to ask strands a half-closed task in a session nobody is watching, and closing anyway is the
evaporation the step exists to prevent.

1. **`close` gains `--unattended`** — a **declared** flag, not an inferred condition. Whether a human is
   watching is not readable from the repo, and this repo's own rule is to read a declaration rather than
   deduce it from observable state. Today it changes exactly one step.
2. **Step 5d gains an unattended branch**, leaving the interactive path byte-identical: work bullets are
   spawned outright; a bullet that cannot be confidently classified is treated as work and spawned; the
   run never stops to ask and never closes with the bullet unowned.
3. **Step 12 names each spawned id**, not just `spawned: N` — an unwatched run is read later from the
   report alone, and a count names nothing anyone can act on.
4. **`fix-next` passes the flag** at its step 8 and lists every spawned id in its closing report.

## Progress log

- step 2 — picked; named as the runner-up at TASK-037's close and the defect blocking this loop from
  running unattended at all.
- step 3 — verified: held. `close.md:96` says "offer [`spawn`]" with no other branch, and `close.md`
  had no `--unattended` arg. Confirmed by reading both files, not from the task's description.
- step 4 — layer: local. Both sides of the contract are skills in this repo.
- step 5 — fix in `skills/tasks/verbs/close.md` (arg, step 5d branch, step 12) and
  `skills/fix-next/SKILL.md` (step 8 passes the flag, step 9 reports the ids). Prose-only; no code path
  and no automated suite covers skill semantics.
- step 6 — **no guard exists to fail.** `skills-lint.sh` validates frontmatter, wikilinks and file
  references; it does not read a verb's arg list or a step's branching, so nothing here is
  lint-visible and the revert-and-split has nothing to split. Recorded as an absence rather than
  glossed: the fix-dependent evidence for this change is the drill below, not a test. The missing
  guard is itself now filed — TASK-045.
- step 7 — no usable spec map (`docs/specs/.map.yml` has `areas: []`) — run `/specs init` to bootstrap
  the spec layer. Nothing to respec; not skipped silently.
- step 8 — out-of-scope sweep, run under the rule this task added: **2 boundary, 1 spawned, 0 declined**.
  Spawned **TASK-045** — a flag one skill passes is never checked to exist in the receiving verb. The
  bullet was rewritten to name it.

## Outcome

**What was broken.** `close` step 5d classifies every `## Out of scope` bullet and, for one that
describes work with no owner, says *offer `spawn`* — correct interactively, undefined when [[fix-next]]
drives the same verb with nobody present. Left undefined, the reading that keeps an unattended loop
moving is to close anyway, which is the evaporation the step exists to prevent, with a rule quoted over
the top of it.

**The fix.** `close` takes `--unattended`; step 5d gains a branch that spawns instead of offering,
treats an unclassifiable bullet as work, and never stops to ask or closes with the bullet unowned. Step
12 names each spawned id rather than counting them. `fix-next` passes the flag and lists the ids in its
closing report.

**Judgement call: declared, not inferred.** `close` could have detected unattendedness from context.
Rejected — whether a human is watching is not readable from the repo, and this repo's own rule is to
read a declaration rather than deduce it from observable state. An inferred answer that happens to be
right is still unreproducible, and wrong in either direction it either hangs on an offer nobody can take
or drops work silently.

**Judgement call: spawn rather than stop.** Stopping is the safer-*looking* option and was rejected: a
half-closed task in a session nobody is watching is worse than a spare task, and the repo already
settles the tie — *a spare task is cheap noise you can cancel, an untracked paragraph is work that
silently disappears*.

**Step 6 has no split, and that is the finding.** Nothing in `skills-lint.sh` reads a verb's arg list or
a step's branching, so there is no guard to revert. The evidence for this change is the drill: the close
that closed it exercised the new path end to end. The absent guard is filed as TASK-045.

**Flagged and not fixed:** the `--unattended` contract between the two skills is unenforced —
TASK-045, spawned by this task's own sweep.
