---
id: TASK-138
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
priority: P2
assignee: agent
picked-by: fix-next
created: 2026-09-17
depends-on: []
blocks: []
related: [TASK-110]
# findings: ids this task remediates, from a review/audit/harvest/drill pass. Prefixes: see /tasks intake
findings: [DRILL-110-1]
pr: null
github-issue: null
jira-key: null
---

# A conditional row says what settles **Yes** and never what settles **No** — and a wrong No is the one state nothing reports

## Context

**From TASK-110's cold drill, 2026-09-17** — the drill that confirmed the fix works. Both front doors
reached the same verdict on the same repo, so this is not a failure of that task; it is the one judgement
its runner could not point at a sentence for, and it named that plainly:

> *"This is the judgement I'm least able to point at a sentence for. `LAYER.md` says any component
> answering yes settles Yes, but doesn't state the symmetric rule for No. … The consequence of being
> wrong here is invisible, because `not applicable` earns no checklist line, so I'm naming it plainly."*

### The asymmetry

`LAYER.md` § *Conditional rows* is explicit in one direction — *"**any** component answering yes settles
it"* — which is the right rule for a compound repo: one service among four projects makes the answer Yes.
**It never states the No.** A reader must decide for themselves whether No requires *every* component to
answer no, and whether "no component answers yes" is the same thing as "every component answers no" when
some component could not be classified at all.

The runner supplied the missing rule correctly (all three components enumerated, each with its run mode
given explicitly, so the evidence **determines** rather than merely permits) and said it would have asked
had the brief been vaguer — *"Had the brief said only 'a note-taking app', I would have asked."* That is
the right instinct, arrived at without a rule, which is the defect: the next reader may not have it.

### Why it is P2 rather than a nicety — the error is silent by construction

A wrong **Yes** is visible: an artifact appears, or the survey reports `missing`, and somebody looks at it.
A wrong **No** produces `not applicable`, which by design **suppresses the fill, the offer, and any later
re-ask** — and, since TASK-110, earns no line in `new-project`'s step 6 closing checklist either, on the
reasoning that a settled No was decided and needs no report. That reasoning holds only while the No is
actually settled. The two rules compose into: *the one verdict a reader is least equipped to reach is also
the only one nothing will ever surface again.*

## Acceptance criteria

- [x] `LAYER.md` § *Conditional rows* states what settles **No**, symmetrically with the existing
      *"any component answering yes settles it"*
- [x] It says what to do when a component **cannot be classified** — specifically whether "no component
      answered yes" may be read as No, or whether an unclassifiable component forces `unknown`
- [x] The rule distinguishes *evidence determines the answer* from *evidence is merely consistent with it*,
      matching the test the consuming guide's § *A derived state must never be cached as a decision* sets
- [x] Re-examine whether a settled `not applicable` should stay silent in `new-project` step 6's checklist,
      **given that this task's whole argument is that a wrong No is unreportable** — either state why
      silence is still right, or give it a line
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The **Yes** rule, and the `requires`-vs-`reads` calibration — [[TASK-136]] owns the latter.
- Whether `not applicable` and `not applicable yet` stay distinct; that is settled and not in question.

## Outcome

**What the fix was.** A conditional row in the shared layer inventory asked a yes/no question about a repo
— *does anything here require an env var to run?* — and stated only what settles **Yes**: any one component
answering yes is enough. It never said what settles **No**. That matters because *"no component answered
yes"* and *"every component answered no"* are different sentences, and they differ exactly when some
component could not be classified at all. A reader who collapsed them reached `not applicable`, which is
**settled** — it suppresses the fill, the offer and every later re-ask — so a real gap became a design
decision nobody made, permanently. The row now carries a four-row table for the No direction, and the
unclassifiable case resolves to `unknown` and a question instead.

**The step-6 split.** 8 sites × 2 halves, HEAD vs working tree: **no-rule 0/8 → 8/8, exit 1 → 0.**
Fix-dependent: `No: asymmetry stated`, `No: every-component clause`, `No: unclassified ⇒ unknown`,
`No: wrong-No-is-invisible`, `No: derived-No is reported`, `No: rows 2 and 4 named`, `No: row 3 is not a
No`, `report: derived No gets line`. A ninth, `Yes rule intact`, is asserted green on **both** sides.
Contract pins, **not evidence**: the 47 `skills-lint-test.sh` cases and `skills-lint.sh`.

**Judgement calls, and why the stricter option was rejected.**

- **AC4 asked whether a settled `not applicable` should stay silent in the scaffolder's checklist; I took
  neither offered option.** The strict reading was "give every No a line" — rejected, because most repos
  are legitimately No for `Dockerfile`, so a line on each is noise a reader learns to skip, and the one
  that mattered gets skipped with it. Staying silent was the other option and it is what this task argues
  against. **The split is on provenance, not on the verdict:** a No that was *declared* stays silent
  because someone decided it; a No *derived* by classifying components prints one line naming what carried
  it. That is the only state with no other check on it, and it follows the declared-vs-derived spine the
  rest of the rulebook already runs on.
- **Asserted the Yes rule must survive, as a deliberate seventh check.** The cheap version of this fix is
  "make the two directions symmetric", and the laziest route to symmetry is deleting the asymmetric Yes
  rule. That would be a regression a one-directional 0/6 → 6/6 count would score as a clean pass.
- **Did not touch `adopt-project`, and checked rather than assumed.** The rule lands in `LAYER.md`, which
  both front doors read, so the adopter inherits the evaluation without an edit. Its *reporting* gap is
  pre-existing and already owned by [[TASK-112]].

**Flagged but not fixed.**

- **[[TASK-112]]** — the adopter's per-state report list still has no `not applicable` entry. Cross-referenced
  there with a note that the entry now needs the same derived/declared split, so the two doors do not
  describe one state in two shapes. Not folded in: different surface, already filed, filed P3 for a reason.
- **`docs/specs/` has no bodies**, so step 7 respecced nothing — owned by TASK-080.
- **The cold drill in `## Human test plan` is unrun.** It needs a runner whose context does not already
  hold these skills, so this closes at `review`, not `done`.

## Human test plan

- [ ] Cold-drill the adopter against a **deliberately ambiguous** compound repo — one component clearly not
      a service, one whose run mode cannot be determined from the repo at all — and confirm the runner
      reaches `unknown` and asks, rather than reading "nothing answered yes" as a settled No. The brief must
      not say which component is the ambiguous one.

## Progress log

- step 2 — picked; ranked above TASK-136 (`reads` vs `requires`) on **key 3, silence**, which outranks key 4 self-containment where the two disagree. TASK-136's failure is a *false gap* — a missing-template report on a repo that needs none, which a reader sees and dismisses. This one is the inverse: a wrong **No** becomes `not applicable`, which suppresses the fill, the offer **and** any later re-ask, and since TASK-110 earns no closing-checklist line either. A false gap is noise; a hidden gap is a real finding laundered into a design choice with nothing left to surface it. Key 6 (theme) inert — every STORY in EPIC-002/EPIC-003 declares `correctness-invariants`. TASK-067 excluded at step 1 (unmet `depends-on: TASK-032`); DV12 clean.
- step 3 — verified: **holds, and the gap is narrower and sharper than filed.** Three partial rules exist and none is the missing one. `LAYER.md:171` states the Yes — *"**any** component answering yes settles it"*. `:199` states a No for **zero** components — *"A repo with no components of its own answers no"*. § *Treat signals as evidence* states *"where they conflict or run out, the state is **unknown** … Do not default to not applicable"*. **What is absent is the general No for a repo that HAS components:** is "no component answered yes" the same as "every component answered no"? It is not, when a component could not be classified at all — and that distinction is exactly what the cold runner reconstructed unaided (*"the brief enumerates all three components and gives each one's run mode explicitly, so the evidence **determines** rather than merely permits"*). So the fix is a symmetry rule, not a new state. **The `LICENSE` row is the model and needed no change** — checked rather than assumed: it already states all three directions explicitly (open + absent → `missing`; proprietary → `not applicable`; no evidence → `unknown`), which is why no drill has ever gone wrong on it. **Pack: both conditional rows share the gap** (`.env.example` and `Dockerfile` ask the same shape of question), so one rule covers both; nothing else to pull in.
- step 4 — layer: local. The defect is in this repo's own `skills/new-project/LAYER.md`, the shared inventory both front doors read; nothing upstream.
- step 5 — fix in `skills/new-project/LAYER.md` (§ *Conditional rows* gains the No-direction table and the asymmetry rationale) and `skills/new-project/SKILL.md` (step 6's checklist gains the derived-No line). No code, so the suite is `bash .github/workflows/skills-lint.sh` — **green, 18 skills, exit 0**. **Layer parity checked, not assumed:** this does not extend the layer — no row added, removed or re-conditioned — and the rule lands in `LAYER.md`, the shared inventory **both** doors read, so the adopter inherits the evaluation rule without an edit. Its *reporting* half is a pre-existing gap already owned by [[TASK-112]] (`not applicable` missing from the adopter's per-state list); cross-referenced there rather than folded in, with a note that the entry now needs the same derived/declared split.
- step 6 — bidirectional assertion (populate-tests § *Prove the guard can fail*, third form) over 6 sites × 2 halves, detached worktree at HEAD vs the working tree: **no-rule 0/6 → 6/6, exit 1 → 0.** Fix-dependent by name: `No: asymmetry stated`, `No: every-component clause`, `No: unclassified ⇒ unknown`, `No: wrong-No-is-invisible`, `No: derived-No is reported`, `report: derived No gets line`. **A seventh assertion runs the other way and must stay green on BOTH sides — `Yes rule intact` (1/1 before and after)**: the Yes rule is what makes one component sufficient, and a "fix" that achieved symmetry by deleting it would be a regression wearing a fix's clothes, which no one-directional count would catch. Contract pins, **not evidence**: the 47 `skills-lint-test.sh` cases and `skills-lint.sh` — green either way, and they would stay green with this change absent. **The assertion found a real contradiction I had just introduced**: `LAYER.md` still asserted *"the scaffolder's closing checklist prints no line for a settled No"* while the `SKILL.md` edit two steps earlier had made a **derived** No print one — the two files disagreeing about one behaviour, which is the same defect class TASK-110 existed to fix, re-created inside its own remediation. Fixed before the assertion could pass. **Also caught two bad patterns of mine**: one spanned a line wrap so it could never match wrapped prose (now matched on whitespace-squashed text), and one (`it was decided`) was present at HEAD *and* after, so it discriminated nothing — a pattern that passes on both sides is a test that is not testing.
- step 7 — respecced: nothing to respec, flagged rather than skipped. `project-baseline` → `skills/new-project/**` covers the changed files, but `docs/specs/` still holds only `.map.yml`; no spec body exists, because TASK-080 (the first harvest) is `todo`. Generating one here would be that task's job and its diff would read "everything new", carrying no evidence for this fix. Requirements changed: none.
- step 8 — 5b gate, **three axes side by side, not merged**. **standards** ([[verify-conventions]]): rulebook = AGENTS.md § Conventions via the CLAUDE.md @import bridge, rung 1; project extension none found; 4 of 4 changed files linted. Register-on-introduce: nothing new to record — this sharpens an existing row's evaluation, and the derived/declared split is an application of § *Read the declaration, never infer it*. Layer parity checked: no row added, removed or re-conditioned. **fidelity** ([[verify-intent]]): all 5 criteria built; **AC4 answered with a third option neither of its two branches offered** (a line conditional on provenance rather than "always" or "never") — flagged rather than passed quietly, since taking neither offered branch is exactly what should be visible; nothing out of scope built, and the Yes rule was not merely left alone but *asserted* intact. **correctness** ([[code-review]] medium): **six findings plus one minor, every one legitimate, all seven fixed.** (1) **the worst, and mine**: the paragraph said *"a No reached by **row 3's** route is reported"* — row 3 produces `unknown`, never a No; the derived No is row 2. Followed literally it would double-report the `unknown` case and stay **silent** on the derived No, which is the exact invisible state this task exists to surface — the fix inverting itself one paragraph after stating the rule. (2) **the split had no producer**: step 6 branches on `declared` vs `derived`, and steps 3 and 5 recorded neither, so a run would reach the checklist with nothing to branch on and default to silence — the rule retired on the case it was written for. Both step-3 and step-5 bullets now carry the provenance forward. (3) *"One line is the whole check there is"* was false for [[adopt-project]], the door where component classification actually happens and which has no `not applicable` entry at all; the sentence now scopes itself per door and names the gap (TASK-112). (4) the worked example justified a No with *"nothing binds a port"* — narrower than the row's own *deployed as a running service*, so a queue worker or scheduled container job is a Yes it would miss — and then carried the verdict on three **kind labels**, in the file written to kill kind-gating; rewritten to name what each component does. (5) table row 4 (no components) is derived but fell outside a trigger reading *"derived from classifying components"*, leaving an aggregator silent; row 4 is now named as deliberately included, since the shape with the least evidence behind its answer must not be the one that reports nothing. (6) the drill citation read *"a cold drill of this very section"* — it was TASK-110's drill, run **before** this section existed, and AGENTS.md § Testing requires a drill record to name how its runner was obtained; re-attributed, with this section stated as undrilled. (minor) *"the line below"* resolved to a different rule once a bullet was inserted between. **`skills-lint.sh` then caught my own fix for (3) and (6)** — I wrote task ids as `[[TASK-110]]` inside `skills/`, where `[[...]]` is the skill-reference contract; plain ids instead. **security-review** not applicable — markdown prose about which artifacts a scaffolder creates; no auth, data-access, input-handling, crypto, secrets, dependency or endpoint surface. 5c skipped — `integration: single-branch`. 5d sweep: both `## Out of scope` bullets are **boundaries** with named owners (TASK-131 n/a here; the Yes rule and the lazy/conditional distinction), 0 spawned.
- step 8 — closed **review**; dashboard regenerated, parents checked and already correct (STORY-012 and EPIC-002 both `in-progress` with open children). Steps 6-9 of `close` skipped per the review-park path (`integration: single-branch`; a task at `review` must not close a remote). Commit carries no `Co-Authored-By:` trailer — AGENTS.md § Working rules and [[tasks]] § Conventions forbid it, and a repo rule outranks the harness default.
