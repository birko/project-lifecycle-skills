---
id: TASK-060
parent: EPIC-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-053-1, DRILL-053-2, DRILL-053-3, DRILL-053-4, DRILL-053-5, DRILL-053-6, DRILL-053-7, DRILL-053-8, DRILL-053-9, DRILL-053-10]
pr: null
github-issue: null
jira-key: null
---

# Triage the cold-drill findings on both front doors

## Context

**This task is a holding pen with a deadline, and that is deliberate.** It carries ten findings from one
audit pass so none of them evaporates before someone decides where each belongs. Its own job is to be
**decomposed** — see the acceptance criteria. Do not fix the findings from inside this task; a
ten-finding task cannot be reviewed as one change.

### Where these came from

**Filed at epic level, not inside a story, on purpose.** The ten findings fan out across `new-project`,
`adopt-project`, `LAYER.md` and `tasks` — so any single story would pre-judge the routing this task exists
to decide. EPIC-002 is stamped `kind: review-intake`, which is exactly what this pass is.


At TASK-053's close gate, its `## Human test plan` was run as a **cold drill**: a fresh agent was given
the repo and told to *execute* `new-project` and `adopt-project` as written, with the test plan's expected
answers **withheld**, so it reported what the prose actually led it to rather than confirming a claim.
Three runs: a scaffold of a throwaway `library` / docs-only project, and read-only surveys of
`Birko/Consumers/WorkoutTracker` and of this repo.

**TASK-053's own four drills passed** — that is not what this task is about. These are the defects the
drill exposed *in the surrounding skills*, which is the value a cold run adds over the author's own pass:
every one of them reads as obvious once stated, which is exactly why the author could not see it.

### The ten findings

| id | Where | The defect |
|---|---|---|
| **DRILL-053-1** | `new-project/LAYER.md` vs `new-project/SKILL.md:14-38, :83, :84, :131` | `LAYER.md` opens by declaring itself *"the single definition of what a lifecycle-ready repo contains"* (15 rows), but `new-project` also creates **`LICENSE`**, **`.env.example`** and **`Dockerfile`/`.dockerignore`**, none of which is a row. `adopt-project` walks `LAYER.md`, so **adoption can never notice a missing licence**. The two skills' notion of "the layer" differs by three artifacts — the exact drift the layer-parity rule exists to prevent, inside the file that rule points at. |
| **DRILL-053-2** | `LAYER.md:111` (test-harness evidence ladder) | The globs are `*.Tests` / `*_test.*` / `*.spec.*` / `*Test*.cs`, preceded by "a test runner in the manifest". **This repo has no manifest and matches no glob**: its suite is `.github/workflows/skills-lint-test.sh` — hyphen-`test`, and `.sh`. Applied literally the ladder reports `missing` on the repo that ships it — the false-`missing` the whole section exists to prevent, on the most self-referential possible target. Only the § preamble ("detect by **evidence**, not by path") saved the drill. |
| **DRILL-053-3** | `LAYER.md:122` (`present, outdated`) + the agent-guide row | The state is claimable only where a verb's delta is the evidence, and its own parenthetical scopes the fallback to *"an agent guide missing a section"*. **Measured on WorkoutTracker:** its `CLAUDE.md` has every `##` section, so "merge by section" has nothing to add, while the guide is a demonstrably older vintage — its close gate names `/code-review` only (no `/verify-conventions`), and it carries no *task-first gate*, no *generated files are owned by their verbs*, no *status changes go through their verbs*. The staleness is **inside** a section. So `adopt-project`'s advertised headline use — *"the UPGRADE path — re-run it whenever the universal layer grows"* — has **no state and no remedy** for the artifact the layer grows fastest, and lands as hand-written prose under the table. Related to TASK-024 but not the same: that is about owner verbs answering; this is about a row whose shape no verb owns at all. |
| **DRILL-053-4** | `new-project/SKILL.md:64` vs `LAYER.md:22` | `SKILL.md` says of `docs/BRIEF.md`: *"Skip only for a truly throwaway/docs-only repo with no stated requirements"* — which described the drill's input **exactly**. `LAYER.md` lists the row unconditionally and declares itself the inventory while `SKILL.md` carries only creation detail. The two genuinely disagree for that input; the drill created the file and flagged that skipping was the arguably more correct reading. |
| **DRILL-053-5** | `templates/README.seed.md:3`, `templates/CLAUDE.seed.md:3` vs `SKILL.md:44-52` | Both templates require `{{ONE_LINE_PURPOSE}}`; **step 1's intake never asks for a purpose** (name, location, kind, stack, scaffolder, task mode, license, agent file). Against this repo's own *"ship no unrendered placeholder tokens"* rule, that leaves a scaffolder three bad options: leave the token, invent a purpose (the fabrication `docs/BRIEF.md` exists to prevent), or write a line saying none was given. The drill chose the third and said so. Fix is probably one intake question. |
| **DRILL-053-6** | `new-project/SKILL.md:99` → `tasks/verbs/init.md:30` | `new-project` chains `/tasks init mode=<mode>` and passes **no** `integration=`, so the template default `pr-per-task` is written silently — into a project where the drill was told to skip `git init`. A repo with no git now declares a PR-per-task policy, and nothing ever asked. `init.md:32` protects an *existing* config's silence from being defaulted over; a new one gets the default unexamined. |
| **DRILL-053-7** | `adopt-project/SKILL.md:47-51, :73-78` + `LAYER.md:61-66` | **A scoped or read-only survey has no state for a present row whose owner verb has not run.** § 1 says don't guess the version and leave it to § 3's delegation; a "complete" table needs every verb to have answered; `unknown` is defined for *a verb that answered with silence*, not one never invoked. The drill had to invent *"present, currency unresolved"* for `tasks/` and `docs/specs/.map.yml` on **both** target repos, and state that its survey therefore certified nothing-missing rather than completeness. A pre-flight survey is a plausible thing to want and the state list cannot express its central result. |
| **DRILL-053-8** | `adopt-project/SKILL.md:90-93`, `:274` | § 4's report owes output only § 2 produces — the rulebook-coverage statement (*"say when you skip… and again in step 4's report"*) and the glossary-candidate sentence. A run scoped to § 1 + § 4 owes a report the skill's own text calls defective if omitted. The drill produced both anyway, labelled *"would have been step 2's own output"*. Same root as DRILL-053-7: the skill assumes every run is a full run. |
| **DRILL-053-9** | `LAYER.md:133-138` vs `adopt-project/SKILL.md` § 3c | For a generated file that is **uncommitted** *and* carries content its verb cannot reproduce, "offer to land it" and "render, compare, then write" point opposite ways. Hit on this repo's own `tasks/README.md`. The drill offered only to *land* (which changes nothing inside the file) and declined to regenerate, leaning on § 3c's stop-on-unreproducible-content row — and noted nothing stated that precedence. |
| **DRILL-053-10** | Two unstated defaults the drill had to invent | (a) **`## Conventions` with stack "none"**: `SKILL.md:75` says seed the stack's idiomatic defaults and lists TS/Python/.NET/Go; `:79` forbids a dangling token or an empty subsection. With no stack there are no idioms, so the drill wrote markdown-repo rules and a Testing line stating there is no runner yet. (b) **No documented empty-case render** for `docs/features/README.md` or `tasks/README.md` — neither `/feature status` step 7 nor `triage` step 7 says what a zero-item render looks like, so the drill invented placeholder prose. Group these two only if the fix is one "what does the degenerate case look like" pass; otherwise split. |

### One finding is about this repo and is filed here on purpose

The drill also flagged that **`docs/features/README.md` carries a hand-written line** — `_No features yet._
See EPIC-001 in tasks/ — the current work is deliberately task-only.` — which this repo's own `AGENTS.md`
forbids (*"Nothing goes in a generated file that its verb cannot derive"*). It is not derivable from the
template's three tokens.

**Why it matters more than its size:** at the same close gate, `/code-review` caught that line being used
as *justification* — the dashboard's DV5 drift callout was suppressed on the grounds that the features
index "declares" the tree deliberately task-only. Two independent passes reached the same line from
opposite directions. Its home is the EPIC body's `§ State as of`, and DRILL-053-10(b) is the reason it
exists at all — there is no documented empty render, so someone wrote one by hand.

## Acceptance criteria

- [ ] Each of the ten findings is **routed**, not fixed here: decomposed into tasks via [`/tasks intake --epic EPIC-002`](../../skills/tasks/verbs/intake.md), or — where one is judged a non-defect — recorded as such **with the reason**, in this task's body
- [ ] The routing decision names, per finding, which skill owns the fix (`new-project`, `adopt-project`, `LAYER.md`, `tasks`) so the intake groups by subject rather than by discovery order
- [ ] DRILL-053-7 and DRILL-053-8 are considered **together** — both are "the skill assumes every run is a full run", and splitting them buries that
- [ ] Any finding that turns out to duplicate an open task (TASK-024 for the reconcile family, TASK-025 for the "code that is prose" family) is **linked, not re-filed** — the audit duplicate rule
- [ ] This task closes only when every finding has an id or a recorded non-defect verdict; a finding listed with neither means the routing did not run
- [ ] The cold-drill method is recorded somewhere durable enough to repeat — withholding the expected answers is what made this pass work, and it is not written down anywhere yet

## Out of scope

- **Fixing any of the ten.** Each fix is its own task with its own review; this task decides where they go.
- **TASK-053's four drills** — they passed, and that task closed on them.
- Re-running the drill. A second cold run is worth having *after* the fixes land, not before the findings are routed.
- The consumer-repo reconciliation the drill's Run B implies — **TASK-059** owns that.
- WorkoutTracker's own two findings (hand-extended generated files, no git remote). They belong in **that repo's** `tasks/`, and the read-only drill could not file them there. Note them when TASK-059 runs.

## Human test plan

N/A — fully covered by the routing itself. This task produces task ids and recorded verdicts, not
behaviour: the check is that every finding has one, which is the acceptance criteria restated. The
findings' own fixes each carry their own test plan.

## Implementation plan

_Populated by `/tasks plan TASK-060` — leave empty until then._
