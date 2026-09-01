---
id: TASK-086
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-31
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [CR-027-2, DRILL-097-1]
pr: null
github-issue: null
jira-key: null
---

# Adoption cannot tell its own unlanded writes from the user's work in progress

## Context

**Spawned from TASK-027's close gate on 2026-08-31** (`/code-review`).

`present, uncommitted` exists to catch **one** situation: *an earlier adoption pass wrote layer files and
stopped before committing.* The whole justification — *"the next clone will not have it and the next pass
will write over it"* — is about files **adoption itself wrote**. The offer that follows is to land the file
**in the adoption commit**.

The probe cannot see intent. It reports that git does not have all of a path, and every reason for that
looks identical:

| Why the path is unlanded | What the run should do |
|---|---|
| an earlier adoption pass wrote it and stopped | land it — the state's whole purpose |
| the **user** has work in progress under a layer path — a half-written `README.md`, edits staged in `docs/` | **not** adoption's business |

In the second case adoption offers to sweep the user's half-finished work into a commit whose message says
*adoption*, having neither written nor reviewed it.

**Not introduced by TASK-027, and the honest framing matters.** The old rule already matched ` M` — a
tracked file modified and unstaged — which is the single most likely shape of a developer's WIP. TASK-027
widened the aperture to staged work as well, so the exposure grew; it did not appear. Filing it against the
widening alone would misdate the defect and imply the previous rule was safe.

**Why it was not simply narrowed at the point of discovery.** Every candidate is a real design decision
with consequences beyond this row: comparing content against what the fill *would* write (which needs the
fill to have run); restricting the state to artifacts the run itself created (which defeats the re-run case
the state exists for, since a *previous* run wrote them); showing the paths and asking; or accepting the
conflation and making the offer per-path rather than wholesale. Picking one inside a close gate, unattended,
is exactly the "decision nobody sanctioned" that the guardrails forbid.

**The sharpest sub-case to keep in view:** a *directory* artifact like `tasks/`, where the probe returns
members. One member from an old adoption pass and one from the user's WIP produce a single row and a single
offer.

### Independent second instance, 2026-09-01 (DRILL-097-1)

A cold drill of `WorkoutTracker` reached this exact conflation from the other direction, with no knowledge of
this task, and articulated the defect more sharply than the filing did:

> *"The probe rule is mechanical and I applied it mechanically. But the seven modified files here are **not**
> an unlanded adoption pass — they are current work (two generated files `/feature status` owns, three
> generated spec bodies, one in-flight task file). **"The file is already right" is an assumption that does
> not hold for someone's WIP**, and *"offer it in the adoption commit"* would sweep unrelated work into an
> adoption commit. Nothing in the instructions distinguishes the two provenances, so I assigned the state and
> am flagging that the remedy attached to it looks wrong for this instance."*

**What this adds to the filing.** The original was written around the *offer* being wrong. This runner
locates it one step earlier: the state's **justification** — *"the file is already right; what is missing is
the commit"* — is itself false for WIP, so the remedy is wrong because the premise is. That reframes the fix:
narrowing the offer is not enough if the state's own rationale still asserts something untrue about half the
cases it catches.

**It also raises the count of measured instances to two, on different repos, from independent runners** — and
this one is seven files at once, including three files a *different* verb owns (`/specs regen` bodies) plus a
task file mid-edit. A wholesale land offer here would commit another verb's in-flight regeneration.

**Not resolved by TASK-091's location work or TASK-097's `unknown` split** — both were checked. This is
provenance, not location, and not a state-versus-finding question: the state is correct and its attached
remedy is not.

## Acceptance criteria

- [ ] Adoption does not offer to commit user work it neither wrote nor reviewed — by narrowing the state, by making the offer per-path with the paths shown, or by a **recorded decision** that the conflation is acceptable and why
- [ ] The re-run case still works: a *previous* adoption pass's unlanded files are still caught, since that is the state's entire purpose
- [ ] The directory-artifact sub-case is covered explicitly — mixed provenance among members cannot collapse into one silent offer
- [ ] Whatever is chosen, `LAYER.md` states which situation the state claims to identify, so the next reader is not left inferring it from the rationale
- [ ] Layer parity: both front doors read the outcome from `LAYER.md`
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The porcelain reading rule itself — **TASK-027** settled that, including the deletion, unmerged and ancestor-repo exclusions.
- Landing versus regenerating precedence — **TASK-066**.
- Whether adoption should commit at all. It should; this is about *what* it sweeps in.

## Human test plan

- [ ] In a repo with a layer already present, make an unrelated edit under a layer path (staged, and again unstaged), run the survey, and confirm the run does not offer to commit it without saying what it is
- [ ] With genuinely unlanded layer files from a previous pass, confirm the land offer still fires
- [ ] With a `tasks/` directory holding one unlanded layer file and one user-edited file, confirm the two are distinguishable in the report

## Implementation plan

_Populated by `/tasks plan TASK-086` — leave empty until then._
