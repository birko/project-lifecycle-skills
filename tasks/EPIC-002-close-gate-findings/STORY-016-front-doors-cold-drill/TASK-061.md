---
id: TASK-061
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P1
assignee: agent
picked-by: fix-next
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-1]
pr: null
github-issue: null
jira-key: null
---

# `LAYER.md` calls itself the whole layer while `new-project` creates three artifacts it never lists

## Context

**From the 2026-08-22 cold drill** (STORY-016 § Provenance).

`skills/new-project/LAYER.md` opens: *"The single definition of what a lifecycle-ready repo contains…
a second copy is exactly the drift the layer-parity rule exists to prevent."* Its table has 15 rows.

`new-project/SKILL.md` also creates three artifacts that are **not rows**: `LICENSE` (`:84`),
`.env.example` (`:83`), and `Dockerfile`/`.dockerignore` (`:131`).

**The consequence is one-directional and that is what makes it a defect rather than an untidiness.**
`adopt-project/SKILL.md:34` says *"Walk `LAYER.md` and classify every artifact"* — so **adoption can
never notice a missing `LICENSE`**. The drill hit this directly and had to decide for itself that an
artifact with no row gets no state; it chose that reading because `LAYER.md` is the named authority, and
flagged that the two skills' notion of "the layer" therefore differs by three artifacts.

`.env.example` is the sharper half: `LAYER.md`'s own `.gitignore` row implicitly depends on it (the
check is that `.env`/`.env.*` are covered, which the seed writes as `!.env.example`), so the inventory
references an artifact it does not contain.

**The fix is a judgement, not a mechanical addition.** Three plausible shapes, and the task is to pick
one and say why: add all three as rows; add a stated exclusion rule (*"conditional, kind-dependent
artifacts are `new-project`'s alone and adoption does not survey them"*) so the omission becomes
deliberate and documented; or split the file into layer-always and layer-conditional. What must not
survive is the current state, where the omission is indistinguishable from an oversight.

## Acceptance criteria

- [x] `LICENSE`, `.env.example` and `Dockerfile`/`.dockerignore` are each either a row, or covered by a **stated** rule that says why the inventory excludes them
- [x] Whichever shape is chosen, `LAYER.md`'s opening claim about being the single definition is true afterwards — amend the claim if the answer is that it is not
- [x] `adopt-project` can answer "does this repo have a licence?" — or the report states that it deliberately does not, so a reader is not left guessing
- [x] The `.gitignore` row no longer depends on an artifact the inventory does not account for
- [x] Layer parity holds: whatever changes, both front doors read it from the one file
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The other seven drill findings — separate tasks under STORY-016.
- Making adoption *fill* a missing licence. Surveying it and offering it are different decisions; this task settles whether it is visible.
- `Dockerfile` content or `.env.example` content. This is about whether the layer accounts for them.

## Human test plan

- [x] Run `adopt-project`'s survey against a repo with **no** `LICENSE` and confirm the outcome matches whichever shape was chosen — a state, or a stated reason the row is absent from the survey — **run 2026-09-01 against three real repos; Symbio `not applicable` (evidenced), Latent `unknown` (no evidence), Affiliate `present` (control)**
- [x] Re-read `LAYER.md`'s opening paragraph against its own table and confirm the claim it makes is now true

## Implementation plan

_Populated by `/tasks plan TASK-061` — leave empty until then._

## Outcome

**What the fix was.** `LAYER.md` opened by calling itself *"the single definition of what a
lifecycle-ready repo contains"* while `new-project` created three artifacts it never listed — `LICENSE`,
`.env.example`, `Dockerfile`/`.dockerignore`. The consequence was one-directional, which is what made it a
defect rather than an untidiness: [[adopt-project]] walks those rows **and nothing else**, so it could
never notice a repo with no licence. All three are now rows marked **(conditional)**, each naming the
condition it turns on, with a `not applicable` state and a § *Conditional rows* section defining both.

**Measured, on real repos: five of seven Birko consumers have no `LICENSE`** — BardStudio, Latent,
Presenter, Symbio, WorkoutTracker — and the survey could not raise the question on any of them. Some may
legitimately be proprietary; the point is that the answer was unaskable.

**Step-6 split.**

| | HEAD | Now |
|---|---|---|
| Rows in the inventory | 29 | 32 |
| `LICENSE` visible to adoption | **no** | yes |
| `.env.example` visible | **no** | yes |
| `Dockerfile` visible | **no** | yes |
| `adopt-project` knows what a project *kind* is | **0 mentions** | yes |
| `adopt-project` knows what licensing *posture* is | **0** | yes |
| The seed negates `.env.example` in `.gitignore` | **0** | yes |
| Kind enum values reaching a defined state | 0 of 7 | **7 of 7** |

The lint and its 43 cases pass and are **contract pins, not evidence** — neither reads these rows.

**The shape was the user's decision, and the alternatives were costed before asking.** Plain rows were
rejected because *absent ⇒ missing* would report a missing `Dockerfile` **and** `.env.example` on every
library and CLI — measured, two false gaps each on three of the same seven repos, on their first run. A
stated exclusion rule was rejected because it leaves adoption unable to answer the licence question, which
is this task's third criterion.

**Judgement calls, and why the stricter option was rejected.**

- **The marker is `(conditional)`, not `(kind-conditional)` as first drafted and approved.** The gate
  caught that `LICENSE`'s condition is **licensing posture, not kind** — a proprietary and an open-source
  service are the same kind and want opposite answers. The original name would have invited an agent to
  reach for the kind, get "library", and report an unlicensed open-source library `not applicable`,
  laundering away the exact gap this task exists to close. **The approved behaviour is unchanged**; only
  the marker generalised, and each row now names its own condition and the evidence that settles it.
- **Layer parity is what made this shippable, and it caught a hard failure.** `adopt-project` had **zero**
  notion of project kind. Three new rows in the shared inventory would have been structurally unevaluable
  by the one skill that reads them — the "silently strands every project already using the skills" case the
  hard rule names. It now detects kind *and* posture, **before the table prints** rather than after, since
  a survey that resolves its inputs late prints `unknown` on every row and calls itself complete.
- **The seed actively ignored the file the new row creates.** `new-project` wrote *"Always include `.env`
  and `.env.*`"*, and `.env.*` matches `.env.example`. So the template would have been created, ignored,
  reported `present` by the coverage rules (an ignored path yields no porcelain output), and never landed
  in history. Fixed at the source with `!.env.example`, in the same change — a row whose creator
  contradicts it is not a row.
- **Rejected: inferring the kind confidently.** *"The kind is read, never guessed"* was the first draft and
  it contradicted its own next sentence. The signals — a listening port, a `bin` mapping, a published
  manifest — are *consistent with* several readings, which by the repo's own declaration-versus-derivation
  rule is the shape that **had to be declared**. Undetermined evidence now yields `unknown` and a question
  in step 2's round, never `not applicable`.
- **Surveying only, not filling.** The `LICENSE` row reports a missing licence and does **not** offer to
  write one — the first draft did, which is the decision this task's `## Out of scope` explicitly defers.

**A pre-existing contradiction fixed in passing:** `new-project` scoped `.env.example` as *"service/API/web
kinds only"* in its summary and *"skip for pure libraries"* in its detail — those already disagreed about
CLIs before this change. Both now match the row.

**Flagged, not fixed:** nothing. Both out-of-scope bullets name owners.

## Drill outcome — 2026-09-01: PASSED

A cold survey drill ran `adopt-project` step 1, read-only, against three real consumer repos. The brief
**never named the three new artifacts** and **never mentioned kind or licensing posture** — it asked for
every row of the inventory with the state assigned, and for "any fact the instructions told you to
determine before classifying". Anything that surfaced, surfaced from the prose.

| Repo | `LICENSE` | `.env.example` | `Dockerfile` | Why it was the right answer |
|---|---|---|---|---|
| **Affiliate** *(control — has a licence)* | **present** | missing | missing | the check stays quiet when it should |
| **Symbio** | **not applicable** | missing | present | posture settled by evidence: README's `## License` says *Proprietary — Birko s.r.o.* |
| **Latent** | **unknown** | not applicable | not applicable | zero licence evidence in any direction — **did not launder to `not applicable`** |

**The control is the result that matters most.** Every other drill this session confirmed a check *fires*;
this is the first to confirm one stays **quiet**. A survey reporting a missing licence on the repo that has
a `LICENSE` file would have been worse than the gap it was written to close. And the runner determined kind
and licensing posture unprompted, which is the detection added to step 1 working.

**Three defects it found, all fixed here.** The drill did not fail the criterion — it found that the
condition was framed too narrowly:

- **Kind labels run out.** `Latent` declares its kind as *"desktop app + CLI + core library"*. The intake
  enum offers no **desktop app** at all, and the rows split service/API/web/worker against library/CLI, so
  the runner had to map desktop onto a binary that does not contain it.
- **Every repo surveyed was compound** — a web app plus a console importer, an API host plus a frontend, a
  desktop app plus a CLI plus a library. Three of three. The prose said *"the project's kind"*, singular; a
  row demanding one kind must pick one and discard the rest.
- **A declared kind beat my signals, and my prose denied it existed.** § *Conditional rows* asserted the
  adopter *"has only signals"* — false for any already-adopted repo, whose guide states the kind outright.
  That is the consuming project's own *read the declaration, never infer it* rule, and this section was
  arguing against it.

**So the rows now ask a question about the artifact, not about the repo's label** — *does anything here read
runtime config from the environment?*, *is anything here deployed as a running service?* — and any component
answering yes settles it. Kind became evidence toward that answer, with a declared kind outranking an
inferred one.

**Findings that belong to other tasks, not fixed here:**

- Latent's `tasks/` row reads **present** while the surveyor can plainly see `.config.yml` has no
  `integration:` field. The runner called this out as the survey's most misleading cell and was right that
  a reader stopping at the table is less informed than the surveyor. It is also *deliberate* — a shallow
  read must not stand in for the owner verb's authoritative one — and it is exactly what **TASK-024** and
  **TASK-035** already own. Corroboration, not a new finding.
- Whether an agent guide's own architecture section satisfies the `docs/architecture.md` row is unsettled;
  the runner extended the rule to reach *present, elsewhere* and flagged that a stricter reader would say
  *missing*. Pre-existing, and it produced inconsistent answers across two repos on its first pass.
- *"Whether a git remote exists"* is gathered by step 1 and consumed by no row in it. Pre-existing.
- **Corroboration worth recording:** Latent's `.gitignore` already carries an uncommitted
  `!.env.example` line, stamped *added by adopt-project 2026-08-18*. A previous adoption reached by hand
  the exact fix this task just put into the seed.

## Progress log

- step 2 - picked. Runner-up on four previous ranking passes, always losing on key 4 (self-containment): its resolution is a three-way design choice, which is a poor fit for an unattended drain. Picked now with the user available to settle it.
- step 3 - verified: HOLDS. All three confirmed created by new-project (SKILL.md:23,24,33,92,93,140) and absent from all 28 LAYER.md rows. The .gitignore row's dependency confirmed too.
- step 4 - layer: local.
- step 5 - 3 conditional rows + a section in LAYER.md; kind AND licensing-posture detection in adopt-project; !.env.example in the seed; AGENTS.md convention entry. Lint OK (18 skills), 43/43.
- step 6 - 3/3 artifacts invisible -> visible; adopt-project kind mentions 0 -> present; 7 of 7 kind enum values reach a defined state. Lint + 43 cases are contract pins, NOT evidence.
- step 5b - standards OK (1 register-on-introduce gap, fixed), intent OK, correctness found EIGHT defects in my own diff: a seed behaviour I asserted that did not exist (and that actively ignored the new file), LICENSE mis-filed as kind-conditional, the kind enum not covered (worker/other unreachable), a restated list the rulebook forbids, "read never guessed" contradicting its own inference, no CLI signal, kind framed as a fill-time fact when it gates the survey, and an offer-to-fill the task had deferred. All eight fixed.
- step 5d - 2 boundaries, 0 spawned.
- step 7 - respec skipped: areas: [] (TASK-079).
- step 8 - parked at REVIEW: the survey drill is real and unrun.
- 2026-09-01 drill - PASSED. Three real repos, read-only, artifacts and facts unnamed in the brief. Control (Affiliate, has a LICENSE) correctly reported `present` - the first drill this session to confirm a check stays QUIET. Symbio `not applicable` from a README licence line; Latent `unknown` rather than laundered. Kind and posture were both determined unprompted.
- Fixed three drill findings in the same close: kind labels run out (desktop app is in no enum), every repo surveyed was compound (3 of 3), and a declared kind beat my signals while my prose denied declarations exist. Rows now ask a question about the artifact; kind is evidence, and a declaration outranks a signal.
- status review -> done.
