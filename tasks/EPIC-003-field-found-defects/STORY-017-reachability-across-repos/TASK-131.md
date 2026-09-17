---
id: TASK-131
parent: STORY-017
feature: null
status: review
priority: P2
assignee: unassigned
picked-by: fix-next
created: 2026-09-16
depends-on: []
blocks: []
related: [TASK-130]
findings: []
pr: null
github-issue: null
jira-key: null
---

# `fix-next` names an opt-in for hand-filed defects that has no key — a field-found bug cannot mint a finding id

## Context

Found 2026-09-16 alongside [[TASK-130]], while a hand-filed defect in the Birko family had to be picked
by naming it explicitly because nothing would rank it.

`fix-next` SKILL.md §&nbsp;Step 1 defines the pool:

> A `status: todo` TASK is in the pool when **either** holds:
> - its frontmatter carries a non-empty `findings:` list; **or**
> - it sits under an EPIC stamped `kind: review-intake`.
>
> … **the pool is explicit or it doesn't exist.** (A field-found bug filed by hand joins the pool the
> moment someone puts its finding id in `findings:`; that's the whole onboarding cost.)

**The gating itself is correct and should stay.** An explicit pool is the whole reason this skill can run
unattended, and widening it to "any task that looks like a bug" would be exactly the prose-sniffing the
same paragraph rules out.

## The actual defect is the escape hatch

That parenthesis names an opt-in — *"put its finding id in `findings:`"* — which **assumes the bug has a
finding id.** A defect found in the field has no harvest behind it: no sweep, no `SH-*` number, and
**nothing in any skill mints one**. Measured: no verb in `tasks/` or `fix-next/` issues a finding id, and
no documented scheme describes what a hand-filed one should look like.

So the door is named and no key is cut for the case the sentence is explicitly about.

This is the pattern the consuming project's own conventions record as
§&nbsp;SH-H037 — ***verify the escape hatch opens; a guard whose opt-out throws is a wall wearing a door's
label***. Here it does not throw, it simply cannot be satisfied, which is quieter.

### Observed cost

A genuine reproducibility defect (`Birko.Random`, seeded noise not stable across .NET versions) sat in
`_loose/` with `findings: []` and no `review-intake` parent. It was worked only because a human named it.
Had nobody done so it would have aged indefinitely while `fix-next --loop` reported the pool empty —
**and reported it empty truthfully**, which is what makes this hard to notice.

## Candidate fixes

1. **Mint ids.** `/tasks new` (or a `--defect` flag) issues a local finding id — e.g. `FIELD-001` — and
   writes it to `findings:`. Smallest change, keeps the pool explicit, makes the documented opt-in real.
2. **A `kind: defect` task stamp** that the pool also accepts, mirroring the existing `kind: review-intake`
   epic stamp one level down.
3. **Document that hand-filed defects are out of scope** and route them to `/tasks pick`. Honest, cheapest,
   and contradicts the skill's own parenthesis — so if this is the answer, **delete that sentence**.

Option 1 or 2. ⚠ Not 3 without editing the text that promises otherwise; a documented mechanism that does
not exist is worse than an absent one.

## Acceptance criteria

- [x] 1. A defect found in the field can enter the pool **through a documented step**, without inventing
      an id by hand or borrowing an unrelated one.
- [x] 2. The pool stays explicit. No inference from titles, prose, labels, or `priority:`. This must not
      become "rank anything that reads like a bug".
- [ ] 3. The opt-in is **exercised by a test** — a task filed through the documented path is picked by a
      subsequent `fix-next` run. Asserting the sentence exists is not asserting the door opens; that
      distinction is the whole of this task.
      **Half met.** The mechanical half is proven: `skills-lint.sh` check 4 now binds `--from-field`, and
      removing the declaration fails the repo's only gate (step 6). The *door-opens* half is the cold drill
      in `## Human test plan` and is **unrun** — it needs a cold runner in a fresh session. This box stays
      unticked until it is.
- [~] 4. **N/A — option 3 was not chosen.** If option 3 is chosen instead, the parenthesis in §&nbsp;Step 1 is **deleted**, not left standing
      beside a contradicting rule.
- [x] 5. ⚠ Minted ids must not collide with harvest ids (`SH-*`, `CR-*`) — a field id should be visibly a
      field id, so provenance stays readable at a glance.

## Out of scope

- The blast-radius ranking itself — it works, and is not in question.
- [[TASK-133]] — `spawn`'s `_loose` rescue still tests for a *review* finding; spawned from this task's
  close gate, it routes to the mechanism built here rather than changing it.
- [[TASK-130]] — cross-repo collection is a different mechanism. Note they **compound**: a sub-repo task
  is invisible to collection *and*, if hand-filed, ineligible for the pool. Fixing either alone still
  leaves that task unreachable.

## Human test plan

**A cold drill**, because the whole of AC3 is the distinction between *the sentence exists* and *the door
opens*, and only execution separates those.

**Fixture — not this repo and not Birko.** The change is justified by naming the Birko family, so per
`skills/populate-tests/SKILL.md` § *The cold drill* that family is disqualified as the fixture. Use a
throwaway git repo under the scratchpad with a minimal `tasks/` tree: one `kind: review-intake` EPIC with
one `todo` TASK under it, and one hand-written defect task in `tasks/_loose/` carrying `findings: []`.

**Acquiring a cold runner** — `claude --disable-slash-commands` from a guide-free cwd (no `CLAUDE.md`,
no `AGENTS.md` above it). A subagent here is never cold: this repo's skills are installed at user level,
so every agent on the machine already holds the subject. Record the command, the cwd, and the coldness
check per § *Acquiring a cold runner*.

**The brief withholds the answer.** Hand the runner `skills/tasks/verbs/new.md`, `skills/tasks/SKILL.md`
and `skills/fix-next/SKILL.md` as prose plus the fixture, and ask only:

> This defect was found by using the tool — nobody reviewed anything. File it so the defect-draining
> skill will rank it, then list the tasks that skill's pool contains and say why each is in it.

Do **not** say `FIELD`, do not name `--from-field`, and do not say the loose task should end up in the
pool — naming any of those turns the drill into a confirmation.

- [ ] Run the drill as specified above and record the runner, cwd and coldness check.
- [ ] Classify the result against the pass/fail bar below; file any failure as `DRILL-131-*`.

**Pass** = the runner reaches `--from-field` unaided, mints a `FIELD-NNN` (tree-wide counter, zero-padded),
writes it into `findings:`, and then lists the loose task as in-pool *by that id*. **Fail, and the finding
that matters**, is any of: it invents an id by hand; it borrows `CR-*` or `DRILL-*` for a defect no pass
produced; it widens the pool by reading the task's prose; or it reports the pool without the newly-filed
task. Each of those is a `DRILL-131-*` finding for `/tasks intake --epic EPIC-003`.

## Outcome

**What the fix was.** A bug you find by *using* these skills had no way into the queue that fixes bugs.
`fix-next` told you to "put its finding id in `findings:`", but every kind of finding id named a review
pass — a code review, a security review, a spec harvest, a conventions lint, a drill — and a bug found in
ordinary use has had none of those. There was no id to put there and nothing that would issue one. So the
instruction described a door that had no key. This adds the key: a `FIELD-*` id, minted by
`/tasks new task --from-field`, which puts the task in the pool the moment it is filed.

**The step-6 split.** Fix-dependent: **one** assertion — `skills-lint.sh` check 4 over the real tree.
Removing the `--from-field` declaration from the receiving verb alone took the lint from `OK (18 skills)`
to `FAILED`, one error: *"skills/fix-next/SKILL.md passes --from-field to /tasks new — not declared in
skills/tasks/verbs/new.md"*. Contract pins, **not evidence**: all 47 `skills-lint-test.sh` cases, green
before and after — none exercises `--from-field`; they pin the lint's own behaviour and would pass with
this change absent.

**Judgement calls, and why the stricter option was rejected.**

- **Option 1 (mint a `FIELD-*` id) over option 2 (a `kind: defect` task stamp).** Option 2 is the stricter
  reading of "keep the pool explicit" — a stamp is a flat boolean with no counter and no collision surface.
  Rejected because it adds a **third arm** to a pool definition whose two arms are already the subject of
  three open tasks, and because AC5 asks that a field id be *visibly a field id*: a stamp carries no
  provenance, so once filed, a field defect and a reviewed one are indistinguishable in the tree. Option 1
  also makes the existing sentence in `fix-next` true rather than leaving it standing beside a new rule.
- **Option 3 (delete the parenthesis) rejected outright**, per the task's own ⚠ and AC4: it is the cheapest
  and it strands every field-found defect permanently outside the pool, which is the defect, not a fix for it.
- **A new prefix row over reusing an existing one.** `FIELD-*` breaks the table's stated "a prefix names the
  *pass* that produced the finding" shape, and I stated that in the table rather than quietly widening the
  sentence. Reusing `DRILL-*` was the tempting alternative — a drill is also execution — and it is wrong:
  a drill has a brief and a cold runner, and labelling an unplanned field report as one makes the provenance
  the prefix exists to carry a lie.
- **Tree-wide numbering over per-epic.** Every other prefix numbers within its pass. `FIELD-*` has no pass,
  and field reports arrive one at a time over months, so a per-epic counter restarts in each epic and
  collides the first time two field defects land under different parents.
- **`--from-field` over `--defect`** (the name the task floated). The receiving verb already has a
  `--from-feature` / `--from-review` family meaning *this task originates in X*; a third `--from-` member
  composes and reads consistently, where `--defect` names the task's kind and collides conceptually with
  every review-found defect, which is also a defect.

**Flagged but not fixed.**

- **The `## Human test plan` drill above has not been run** — it needs a cold runner in a fresh session,
  which this one is not. AC3's *door-opens* half rests on it; AC3's mechanical half (the flag contract is
  enforced) is met and proven in step 6.
- **`docs/specs/` has no bodies**, so step 7 respecced nothing. Owned by TASK-080, already filed.
- **TASK-130 is untouched and still `todo`** — the two compound, so a *sub-repo* field defect is still
  unreachable by collection even though it can now enter the pool. TASK-130's AC1 is a decision for the
  user, which is why this run did not take it.
- **`spawn.md`'s `_loose` rescue fires only for a *review* finding** — so a pass-less discovery spawned from
  a loose origin still lands outside the pool, which is this task's defect reached through a side door. Found
  by the close gate's `/code-review` pass (`CR-131-1`) and **spawned as [[TASK-133]]**, not folded in here.

## Progress log

- step 2 — picked; ranked above TASK-127 because key 3 (silence): a field-found defect is ineligible for the pool while `fix-next --loop` reports it empty truthfully, where TASK-127's failure stalls a run visibly. Key 6 inert — every declared theme in the pool is `correctness-invariants`. TASK-130 excluded: its AC1 is a decision for the user.
- step 3 — verified: held. Confirmed by hand: `skills/fix-next/SKILL.md:62-64` promises the opt-in; `skills/tasks/verbs/intake.md:50-63` is the sole prefix table and every one of its five prefixes (`CR-*`, `SEC-*`, `SH-*`, `VC-*`, `DRILL-*`) names a **review pass**; `intake.md` step 2 is the only minting site and runs only over a pass. One quote drift corrected in Context — the parenthesis ends "that's the whole onboarding cost", not "that's the whole mechanism"; same claim. Two further sites carry the same gap and are pulled in as sharing the root cause: `skills/tasks/verbs/move.md` ("Backfill `findings:`" — with what id?) and `skills/tasks/SKILL.md` § *A task outside a pool*.
- step 4 — layer: local. Every affected file is a skill definition in this repo; there is no upstream.
- step 5 — fix in skills/tasks/verbs/intake.md (new `FIELD-*` prefix row + tree-wide numbering rule), skills/tasks/verbs/new.md (declares `--from-field`, mints the id, reports it at step 13, `{{FINDINGS}}` doc widened), skills/tasks/templates/TASK.md (comment widened), skills/fix-next/SKILL.md (step 1 names the verb instead of assuming an id), skills/tasks/SKILL.md (§ *A task outside a pool* gains the field arm), skills/tasks/verbs/move.md (its `--adopt` pointer says what to do when no pass minted an id). Tests: `.github/workflows/skills-lint.sh` check 4 now binds the contract — 47/47 regression cases green, lint OK.
- step 6 — reverted fix: removed the `--from-field` declaration from the receiving verb (new.md) only; lint went OK → FAILED, 1 error, `skills/fix-next/SKILL.md passes --from-field to /tasks new — not declared in skills/tasks/verbs/new.md`. fix-dependent = that one check-4 assertion. contract pins = all 47 skills-lint-test.sh cases (green before and after; none exercises `--from-field`, so they pin the lint's own behaviour and are not evidence for this fix). The door-opens half of AC3 is not machine-checkable here and is the cold drill in `## Human test plan`.
- step 7 — respecced: nothing to respec. The map is usable (14 areas; `work-tracking` → `skills/tasks/**` and `defect-draining` → `skills/fix-next/**` both cover this change), but `docs/specs/` holds only `.map.yml` — no spec body has ever been generated, because TASK-080 (the first full harvest) is still `todo`. Generating these two from scratch here would be TASK-080's job, and its diff would be "everything new", which carries no evidence for this fix. Requirements changed: none. Flagged, not skipped silently.
- step 8 — 5b gate: **standards** (verify-conventions) pass after two self-findings fixed — a growable-list copy in `templates/TASK.md` and a "two arms" header contradicted by a three-item body in `tasks/SKILL.md`; rulebook read = AGENTS.md § Conventions via the CLAUDE.md @import bridge, ladder rung 1; project extension: none found. **fidelity** (verify-intent) pass — AC1/2/5 built, AC3 half-built and unticked with the gap named, AC4 n/a, nothing out of scope built. **correctness** (code-review) one real finding, fixed: `intake.md` quoted fix-next's opt-in in the present tense after this same diff deleted that sentence. **security-review** not applicable — the diff is markdown skill prose about task tracking, with no auth, data-access, input-handling, crypto, secrets, dependency or endpoint surface. Verdicts reported side by side, not merged. 5c skipped — `integration: single-branch`. 5d sweep: 2 bullets on Out of scope are boundaries; 1 aside reclassified as work and spawned as TASK-133 (`CR-131-1`). Closed **review**, not done: the cold drill is real and unrun.
