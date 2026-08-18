---
id: TASK-021
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: done
priority: P1
assignee: agent
created: 2026-08-18
depends-on: [TASK-023]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The survey reads a repo's shape and history where the layer records a declared value

## Context

Found in the `adopt-project` drill on `C:\Source\Birko\Consumers\Presenter` (2026-08-18). One root
cause, two visible failures.

**The artifact was judged from the outside.** `tasks/` was surveyed `present` — evidence *"(mode:
local), README.md, 7 epics / 1 story / 9 tasks"* — and the fill skipped it as *"already
skill-shaped, no `/tasks init` needed"*. But its `.config.yml` is still the shape `/tasks import`
wrote on 2026-05-28 and carries **no `integration:` field** at all. That field is exactly what the
layer grew since, and reconciling a repo that adopted an older version is this skill's advertised
second entry case. LAYER.md's *"present but thin is `present`, with the gap named"* rule was written
for a missing `##` section; nobody extended it to **schema growth inside an artifact another skill
owns**. And the delegated inits are all delta-based and safe to re-run — which is why the row says
*delegate*, not *delegate unless it looks fine*. A shape check is not a version check.

**Then the missing field got inferred from git history.** With nothing declaring the integration
model, the run read the log, found a `Merge branch 'build/birko-src-bucket-layout'`, and concluded
the repo uses topic branches — so it cut `chore/adopt-project-lifecycle`, merged `--no-ff`, and
afterwards deleted the branch because *"merged branches evidently don't stick around here"*. It
happened to land right. It is also the one inference [[tasks]] explicitly forbids: *"Declare the
integration model, don't infer it. Reading it beats reading `git log`, which cannot tell a
commit-to-main repo from a squash-merge one."* A squash-merge repo and a commit-to-main repo produce
the same log, and the branch deletion was a second inference layered on the first — neither was in
"merge it into main".

Both failures are the same mistake at different altitudes: **derive from observation what the layer
stores as a declaration.**

**Post-review correction, same day.** A second `/code-review` pass — run while closing TASK-023 —
found this task's rule shipped inert: step 1 still ended *"for a repo that is already complete, this
is the entire run"*, and on a repo where every artifact is present (Presenter, exactly) the run would
stop there and never reach the delegation the rule exists to force. Fixed: completeness is now only
callable once every row naming a verb has had that verb answer. The same pass found the ripple in the
other direction — with `/tasks init` now reporting three distinct outcomes, this skill's hardcoded
*"nothing to do" → `unknown`* would have reported a genuine reconciliation as "I could not tell" —
and that an `unknown` arising from a verb's silence was falling under the ask-to-fill rule, i.e.
offering to create a `tasks/` tree sitting in plain sight. Both fixed here rather than deferred: a
rule that cannot fire is worse than an unwritten one, because it reads as covered. The whole point of that field is that no agent has to guess, and the
reason it was missing is that the survey never looked inside the artifact carrying it.

## Acceptance criteria

- [x] Stated **once** for every Owner row, as `LAYER.md` § *A row with an Owner is delegated regardless*, rather than repeated in each row — per-row copies are exactly what the shared-inventory convention forbids, and the failure mode was a missing rule, not a missing repetition. Presence now decides whether to *create*, never whether to *delegate*
- [x] `present, outdated` added to the state list — there, but in an earlier version of its own shape. For an Owner row it is a **finding, not a judgement**: the owner's init reports the delta. Note this reinstates vocabulary TASK-003 originally had (*"present / missing / present-but-outdated"*) and TASK-008 dropped when it rewrote the states around evidence
- [x] `adopt-project` § Conventions: branch / commit / merge come from `tasks/.config.yml`'s `integration:`; absent → ask and backfill. Never `git log` — with the reason stated inline, that a squash-merge repo and a commit-to-main repo produce the same history. Placed in the skill rather than `LAYER.md` because the temptation is brownfield-only
- [x] **Branch deletion is never inferred** — cleanup is its own ask, however tidy the log looks
- [x] `/tasks init`'s delta behaviour **verified, and it does not hold**: `verbs/init.md` reports-and-changes-nothing when both files exist, step 3 refuses to touch an existing config, and its edge cases cover a tree with *no* config rather than one in an older shape. Filed as **TASK-023** (this task `depends-on` it) rather than worked around — writing the field from `adopt-project` would put the config's shape in two skills. **So this rule ships ahead of its dependency, and says so where it matters**: `LAYER.md` now states that *"nothing to do" is not "up to date"* and routes such a row to `unknown`, so an adoption pass cannot report a reconciliation that never happened
- [x] `LAYER.md` § *Detect*: a count in evidence names its source, or no number is given — "148 `[Fact]`/`[Theory]` attributes" and "143 tests discovered" are different claims, and both were reported for one repo an hour apart
- [x] `skills-lint` OK (16 skills); `skills-lint-test` re-run for this change

## Out of scope

- Presenter's own `.config.yml` — a one-line backfill in that repo, not this task's deliverable.
- Re-litigating the `pr-per-task` vs `single-branch` default; [[tasks]] owns that.
- Whether adoption should commit at all — settled: it offers, never commits unasked.

## Human test plan

- [x] Re-drilled **Presenter** (2026-08-18) and every part held: the survey **refused to call the repo complete** — `tasks/` names a verb to delegate to, so only `/tasks init` could say whether its config was current — the `integration:` question was **asked** (with Presenter's topic-branch history offered as context for the decision, not acted on), the answer `pr-per-task` was written by the delegated verb, and no branch was cut before that answer existed. `docs/BRIEF.md` now surveys as plain `present`, the earlier pass's untracked case having been committed
- [x] Covered twice: this repo declares `single-branch` and no branch was cut for any task all session, and the fixture below declares it against a deliberately misleading log
- [x] Fixture built: a linear history (**zero** merge commits) whose middle commit subject reads `Merge pull request #12 from feature/thing (squashed)`. The two available inferences contradict each other — subject says PR-merge workflow, shape says commit-to-main — and `integration: single-branch` settles it without the log being consulted. This is the case the old inference could not survive, made concrete
- [x] Exercised end to end on Presenter (2026-08-18): the reconcile commit went on `chore/reconcile-tasks-config` and merged `--no-ff` **because the config now declares `pr-per-task`**, not because the log showed merges. After the merge the branch was left in place and its deletion **asked for** — the previous adoption branch had vanished from the branch list, which is exactly the evidence the old behaviour deleted on. Answer given, branch deleted with `-d` (`a95d1b6`), merge preserved as `86f24bf`

## Implementation plan

_Drafted in-conversation; this session holds the drill evidence and the harness rules out spawning
a Plan agent unasked._

1. **`LAYER.md` — a state for an artifact present in an older version of its own shape.**
   `present, outdated`. Worth knowing: TASK-003's original criteria said *"present / missing /
   present-but-outdated"* — the vocabulary existed and was lost when TASK-008 rewrote the states
   around evidence. This reinstates it with the evidence it lacked then: for an artifact with an
   **Owner**, the owner's init reports the delta, so being outdated is a *finding*, not a judgement.
2. **`LAYER.md` — a paragraph under the artifact table: a row with an Owner is delegated whether or
   not it is present.** The inits are all delta-based; presence is not a version, and a shape check
   from outside cannot see a missing field. Name Presenter as the observed instance so the rule is
   not re-derived from scratch next time.
3. **`LAYER.md` § *Detect* — the count-provenance sentence.** One line: evidence that is a count
   says where the count came from.
4. **`adopt-project` step 1** — the survey often cannot tell an outdated shape from the outside; say
   that plainly and let step 3's delegation settle it, rather than implying the table is the last
   word.
5. **`adopt-project` step 3** — a bullet beside the existing never-overwrite rules: never skip a
   delegated init because the artifact looks right.
6. **`adopt-project` § Conventions — git policy is read, not inferred.** Branch / commit / merge come
   from `tasks/.config.yml`'s `integration:`; absent → ask and backfill; never `git log`; never
   delete a branch on inference. This lands here rather than in `LAYER.md` because the temptation is
   brownfield-only — `new-project` has no history to misread.
7. **Spawn the `/tasks init` half.** Verified from `verbs/init.md`: step 3 says *don't overwrite an
   existing config* and the verb reports-and-changes-nothing when both files exist. Its edge cases
   cover a tree with **no** config, not a config in an older shape — so delegation alone would still
   not backfill `integration:`. That is a [[tasks]] defect, and criterion 5 says it gets its own task.
8. **Verify** — `skills-lint` + `skills-lint-test`, then the gate (`verify-conventions`,
   `code-review`). Layer parity holds by construction for 1–3; 4–6 are adoption-side only, stated.
