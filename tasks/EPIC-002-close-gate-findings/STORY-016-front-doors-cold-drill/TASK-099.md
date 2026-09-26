---
id: TASK-099
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
related: [TASK-110]
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-091-2, DRILL-097-2, DRILL-149-1, CR-110-5]
pr: null
github-issue: null
jira-key: null
---

# A row that names two artifacts never says whether the second carries its own state

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `Symbio`.**

One row in the inventory names a companion artifact parenthetically:

```
| Dockerfile (+ .dockerignore) (conditional — …) | … |
```

Nothing says whether `.dockerignore` is surveyed as part of that row or carries a state of its own. The
runner:

> *"The row is written **`Dockerfile` (+ `.dockerignore`)**, and never says whether the parenthesised
> companion carries its own state. I folded it into the same row as `present, elsewhere` (deviating in
> **both** path and name) rather than reporting a missing root `.dockerignore` beside a present-elsewhere
> `Dockerfile`."*

Its choice is almost certainly right, and the measured case shows why the question is not academic: that
repo has `deploy/Dockerfile` **and** `deploy/Dockerfile.dockerignore` — Docker's per-Dockerfile ignore
convention, so the companion deviates from the row's canonical form in **both** path and name at once. Under
the other reading the survey reports a present-elsewhere `Dockerfile` beside a missing root `.dockerignore`,
and then offers to create one — the false-`missing` this inventory calls the dangerous direction, arriving
through a parenthesis.

### The general question, which is why it is worth an id at all

This is the last unstated axis of the composition rules. § *Location is orthogonal too* now settles that
location composes with every row, and the agent-guide row settles that a linked companion is part of one
artifact. **A parenthesised companion is the third shape and nothing covers it** — and the answer is not
obviously the same as the guide's, because a guide's companion is *linked from* the entry point while a
`.dockerignore` is bound to its `Dockerfile` by a filename convention the tooling enforces.

Today `Dockerfile (+ .dockerignore)` is the only row of this shape, so the fix is small. It will not stay
the only one — `.env` / `.env.example` are already an implicit pair handled by prose rather than by a row,
and the inventory has grown steadily.

**Do not answer it by splitting the row.** Two rows for one deployment concern would report two states for
one decision, and the `(conditional)` marker would then have to be duplicated and kept in sync — the
restated-list defect at row granularity.

### A second row with the same shape, from the 2026-09-01 `WorkoutTracker` drill (DRILL-097-2)

The `tasks/` row is written `` `tasks/` (`.config.yml` + `README.md`) `` — the same parenthesised-companion
shape as the `Dockerfile` row, and it produced the same undecided question, on a row where **the answer
changes the state**:

> *"Probed as those two files it is plain **present**; probed as the directory it is **present, uncommitted**
> (`TASK-166…md` modified). I took the directory reading — the state's own text treats these as *'the layer's
> directory artifacts'* — and I am reporting both readings **because the choice changes the row**."*

Both named files were **clean**; only a third file inside the directory was modified. So the narrow reading
says `present` and the directory reading says `present, uncommitted`, and the row does not say which it is.

**This widens the task in two ways.** First, it is no longer one row: two rows carry the parenthesis, so
whatever lands must cover both rather than being written for `Dockerfile`. Second — and this is the harder
half — the two rows want **different** answers. `.dockerignore` is a *sibling artifact* the tooling pairs by
filename; `.config.yml` and `README.md` are *members of a directory the row names*. A rule that folds a
sibling into its partner's state does not obviously tell you whether a directory row is probed as its named
members or as the whole directory. The state's own prose calls these *"the layer's directory artifacts"*,
which points at the directory reading — but that phrase sits in a state definition, not in the row, and the
runner had to go find it.

### Merged in 2026-09-26: TASK-150 — The `docs/architecture.md` row names a state but no fill action, and the two doors disagree

_Merged because all three are LAYER.md row-wording fixes with the same new-project/adopt-project parity edit. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-150.md`._

Raised by the cold runner during TASK-149's verification drill, 2026-09-19 — unprompted, and about the
skill's own instructions rather than the repo it was adopting. Its words: *"two readings exist and the
row doesn't settle which… This isn't a rule-ran-out `unknown` — the row's state is plainly `missing`;
the gap is in its prescribed action."*

`skills/new-project/LAYER.md:23` reads:

```
| `docs/architecture.md` | — | Leave it; report if absent. |
```

**"Leave it; report if absent" names no fill action**, while [[new-project]] creates the file as part of
scaffolding. So for an adopted repo the row is silent on the question that matters: does the adopter
*offer* to create it, or only report it missing?

**This is not hypothetical — the two drill runs took opposite readings.** The 2026-09-19 failing run
(DRILL-138-1) *generated* a `docs/architecture.md`; the passing re-run *reported it missing* and created
nothing. Same skill, same fixture, same brief.

**And the first reading is how a wrong verdict became durable.** That generated file asserted *"Nothing
here is deployed as a running service. Two CLIs and a library, distributed as packages and invoked on
demand"* — a run-mode claim about a component whose run mode could not be determined. A wrong line in a
report is read once; a wrong line in a committed architecture document is read by everyone afterwards
and is exactly the sort of thing `/adopt-project` is not supposed to author. TASK-149 fixed the
*classification* that produced that sentence. It did not settle whether the adopter should be writing
the file at all.

**Note the row also has an empty middle column** where its siblings carry a detection signal, which may
be part of why it reads as under-specified. Check whether that is deliberate before filling it.

### Merged in 2026-09-26: TASK-136 — Three files state the `.env.example` condition as *reads*, two as *requires* — and the two answer differently

_Merged because all three are LAYER.md row-wording fixes with the same new-project/adopt-project parity edit. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-012-universal-layer-declarations/TASK-136.md`._

**From the [[code-review]] pass at TASK-110's close gate, 2026-09-17.** Spawned rather than folded in:
TASK-110 fixed how the condition is *decided* (artifact question, not project kind); this is a defect in
**what the condition says**, and the two are independent — the wording split was there before that task
and survives it untouched.

`LAYER.md:206` settles the calibration explicitly:

> **The condition means *requires*, not merely *reads* — the row's own definition says so and the
> question did not.** … **Ask: would a new contributor be unable to run this without being told a value?**

Two sites match it (`LAYER.md:32`'s row, and `new-project/SKILL.md`'s bullet as of TASK-110). **Three do
not**, and still say *reads*:

| Site | Says |
|---|---|
| `AGENTS.md:291` | *"does anything here **read** runtime config from the environment? and any component answering yes settles it"* |
| `skills/adopt-project/SKILL.md:77` | *"is deployed, **reads** env config, or ships as a package"* |
| `LAYER.md` § *Conditional rows*, the "Ask the artifact's own question" paragraph | *"does anything here **require** an environment variable to run?"* — correct, but it is the paragraph the other two were copied from before `:206` narrowed it |

#### Why it matters

The two readings **disagree on a measured, real repo.** `LAYER.md:206` records a web app that reads three
runtime environment variables and boots correctly with **none** of them set, because every value lives in
committed `appsettings*.json`. Read as *reads*, the row fires and reports a missing template for variables
nobody must supply. Read as *requires*, it is correctly `not applicable`.

So an adopter following `SKILL.md:77` produces a false gap on exactly the repo shape `:206` was written
from — and `AGENTS.md:291`, the convention pointer, tells a reader the looser rule is the rule.

**TASK-110 widened the split rather than causing it**: it brought `new-project` onto *requires*, taking
the count from 2-vs-1 to 3-vs-2. That is a reason to fix it, not a reason to have left `new-project` wrong.

## Acceptance criteria

- [ ] Whether a parenthesised companion carries its own state is stated once, where a reader of any such row will find it — not per row
- [ ] The measured case resolves without a false gap: `deploy/Dockerfile` + `deploy/Dockerfile.dockerignore` must not produce a missing root `.dockerignore`
- [ ] The answer says how a **convention-bound** companion (a filename the tooling pairs) differs from a **linked** one (an agent-guide companion), or states that they take the same treatment and why
- [ ] The row is not split into two, and the reason is recorded
- [ ] Layer parity: the rule lands in `LAYER.md`, which both front doors read
- [ ] `bash .github/workflows/skills-lint.sh` passes

*From TASK-150:*

- [ ] The row states what the adopter does when `docs/architecture.md` is absent: report only, offer, or create — one of the three, not a sentence that admits two.
- [ ] Whichever is chosen, `new-project`'s behaviour and the adopter's are consistent with each other, or the row says plainly why they differ.
- [ ] If the adopter may create or offer it, the row says what the file may and may not assert — a run mode or a deployment claim must not be written where the underlying question reached `unknown` (TASK-149's states).
- [ ] The empty middle column is filled or its emptiness is explained.
- [ ] `bash .github/workflows/skills-lint.sh` passes.

*From TASK-136:*

- [ ] All five sites state the same condition, and it is the one `LAYER.md:206` settles (*requires*)
- [ ] `AGENTS.md:291`'s pointer matches, since § Conventions is what `/verify-conventions` lints against
- [ ] `adopt-project/SKILL.md:77`'s detection list matches — it is the line a survey actually executes
- [ ] The *"any component answering yes settles it"* clause survives: the fix narrows **which** question is
      asked, not the rule that one component is enough
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The location states themselves — **TASK-091** settled path / name / file and their composition with every row.
- The agent-guide companion rule — also TASK-091, and this task must stay consistent with it rather than reopening it.
- Whether `Dockerfile` should be a layer row. It is, and the conditional-row design is not in question.

*From TASK-150:*

- The classification rule that produced the bad content — TASK-149, done.
- The adopter's per-state reporting list — TASK-112.

*From TASK-136:*

- The `Dockerfile` row's condition — *deployed as a running service* has no reads/requires ambiguity.
- Re-deciding the calibration itself. `LAYER.md:206` settled it with a measured instance; this task
  propagates that decision, it does not reopen it.

## Human test plan

- [ ] Cold-drill a repo whose `Dockerfile` and its ignore file both sit off the canonical path, expected answers withheld, and confirm the runner reports one state without listing the companion under what it had to decide

*From TASK-150:*

- [ ] Re-run the adopter on the `drill-138` fixture (resettable with `git reset --hard && git clean -fd`). Expected: it takes the row's single reading, and if it creates or offers the file, the content asserts nothing about `feedsync`'s run mode, which is `unknown`.
- [ ] Run it twice and compare. Expected: the same decision both times. The defect this task exists to fix is precisely two runs differing, so one run proves nothing.

*From TASK-136:*

- [ ] Grep the five sites and confirm one wording. Then re-walk `LAYER.md:206`'s measured repo shape (a web
      app whose three env vars all have committed defaults) against the adopter's detection list and
      confirm it now reaches `not applicable` rather than reporting a missing template.

## Implementation plan

_Populated by `/tasks plan TASK-099` — leave empty until then._
