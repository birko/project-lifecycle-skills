---
id: TASK-071
parent: STORY-015
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-22
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-054-6]
pr: null
github-issue: null
jira-key: null
---

# The wikilink contract says "CI resolves it", and in `docs/` that is false

## Context

**From the cold read of `docs/adr/` on 2026-08-22.**

`AGENTS.md § Conventions › Framework / stack` states the contract without qualification:

> **Cross-skill references use `[[skill-name]]`**, never a bare path — the link is the contract, and **CI
> resolves it**.

`skills-lint.sh` does not scan `docs/` at all. The cold reader grepped it for `docs/` and `adr` and got
nothing. Meanwhile `docs/adr/` uses **nine** wikilinks, and two of them — `[[review]]` and
`[[code-review]]` — resolve only into `skills-pi/`, the frozen pi-only tree, so their status differs by
runtime and nothing says so.

**The sentence is not wrong about `skills/`; it is wrong about where it appears.** It sits in the rulebook
as an unscoped claim, so a reader writing a wikilink in `docs/` believes it is checked. That is worse than
an unchecked link: it is an unchecked link with a documented guarantee.

**Two complications that make this less trivial than widening a glob**, and they are why this is a task
rather than a one-line change:

1. **Prose examples would false-positive.** ADR 0002 contains a literal `[[wikilink]]` as an example of
   what the lint checks — *"A `[[wikilink]]` that resolves to no folder…"*. Widening the scan without an
   escape breaks the build on a record that is discussing the lint.
2. **TASK-043 already establishes that the contract cannot naively be widened.** That task exists because
   enforcement is scoped to `skills/` and widening it has consequences elsewhere. Read it before choosing;
   this may fold into it, and if so, say so and fold rather than shipping two half-answers.

**Three honest resolutions, and the task is to pick one:** widen the lint to `docs/` with a prose escape;
scope the rulebook sentence to `skills/` and stop using wikilink form in `docs/`; or keep the form in
`docs/` explicitly unchecked and say so where the claim is made. The last is legitimate — a documented
limitation beats a false guarantee — but it must be written down, not left implied.

## Acceptance criteria

- [x] The rulebook's *"CI resolves it"* claim is true wherever it is stated, either by widening enforcement or by scoping the sentence
- [~] If enforcement widens: a prose-example escape exists, and ADR 0002's literal `[[wikilink]]` still passes
      — **N/A: the condition never fired.** Enforcement did **not** widen, so no escape was built and none was needed. Marked `[~]` rather than `[x]`: ticking a conditional whose condition failed reads as *"we built the escape"*, which would be a false claim about work that does not exist.
- [x] The `skills-pi/`-only resolution of `[[review]]` and `[[code-review]]` is handled deliberately — those names resolve in one runtime and not the other, and whatever the lint does about that is stated
- [x] TASK-043 is read first and this task either folds into it or states why the two stay separate
- [~] A change to `skills-lint.sh` carries a case in `skills-lint-test.sh` that **fails without it** — `AGENTS.md § Testing`'s hard rule, since the lint is the repo's only gate
      — **N/A: this task changed no lint code.** The resolution was a rulebook edit. (`skills-lint.sh` *was* changed the same day by **TASK-045**, which carries its own failing case — that rule was honoured there, not skipped.)
- [x] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- The ADR content itself — the records are TASK-054's and TASK-069's business.
- Widening the lint to every tracked markdown file. `docs/` is where the measured false guarantee is; a general sweep is a different, larger question.
- Check 4's advisory install-root section. Unrelated, and its advisory status is settled.

## Human test plan

- [x] Add a deliberately broken wikilink to a scratch file under `docs/` and confirm the lint's behaviour matches whatever the resolution promises — caught, or documented as unchecked
      — verified without a scratch file, because the repo already contains 24 of them: every unresolved wikilink outside the two trees was enumerated, and the lint reports none. The rulebook now says exactly that, so behaviour and promise agree.
- [x] Confirm the prose example in ADR 0002 does not fail the lint
      — it cannot: `docs/` is not scanned, which is now the documented behaviour rather than an accident.
- [x] Re-read the rulebook sentence and confirm a reader writing a wikilink in `docs/` now knows whether it is checked
      — it now says *"CI resolves it inside `skills/` and `skills-pi/`, and nowhere else"* and adds that elsewhere the form is documentation, not a contract.

## Implementation plan

_Populated by `/tasks plan TASK-071` — leave empty until then._

## Outcome — folded into TASK-043

**Closed as the same defect, not as a false positive.** This task said the rulebook claims *"CI resolves it"*
while the lint never scans `docs/`, where nine wikilinks live. TASK-043 said the contract is enforced only
inside `skills/` and that naive widening is wrong. **One edit to `AGENTS.md § Conventions` answers both**, and
this task's own criterion required exactly that reading — *"TASK-043 is read first and this task either folds
into it or states why the two stay separate."* It folds.

**Of the three resolutions this task listed, the second was chosen: scope the sentence.** The first — widen
the lint with a prose escape — was rejected on a re-run measurement: 170 wikilinks outside the two trees, 24
unresolved, **all 24 syntax placeholders and none a real reference.** An escape would be doing all the work
and the check none. See TASK-043's `## Outcome` for the full accounting.

**This task's distinct finding survived and is now documented**, which is why it was worth filing separately
even though it folded: `[[review]]`, `[[code-review]]` and `[[security-review]]` are folders in `skills-pi/`
**only** — Claude Code ships them as built-ins — so those links resolve in one runtime and not the other.
Nothing had said that anywhere, and the rulebook now does.

**Acceptance criteria** are met via TASK-043's edit rather than a separate change; each is ticked with that
provenance rather than left open, since closing them elsewhere and leaving them unticked here would make the
record read as abandoned.
