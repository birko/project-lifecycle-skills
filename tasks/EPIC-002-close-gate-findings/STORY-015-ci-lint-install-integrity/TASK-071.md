---
id: TASK-071
parent: STORY-015
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
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

- [ ] The rulebook's *"CI resolves it"* claim is true wherever it is stated, either by widening enforcement or by scoping the sentence
- [ ] If enforcement widens: a prose-example escape exists, and ADR 0002's literal `[[wikilink]]` still passes
- [ ] The `skills-pi/`-only resolution of `[[review]]` and `[[code-review]]` is handled deliberately — those names resolve in one runtime and not the other, and whatever the lint does about that is stated
- [ ] TASK-043 is read first and this task either folds into it or states why the two stay separate
- [ ] A change to `skills-lint.sh` carries a case in `skills-lint-test.sh` that **fails without it** — `AGENTS.md § Testing`'s hard rule, since the lint is the repo's only gate
- [ ] `bash .github/workflows/skills-lint.sh` and `skills-lint-test.sh` both pass

## Out of scope

- The ADR content itself — the records are TASK-054's and TASK-069's business.
- Widening the lint to every tracked markdown file. `docs/` is where the measured false guarantee is; a general sweep is a different, larger question.
- Check 4's advisory install-root section. Unrelated, and its advisory status is settled.

## Human test plan

- [ ] Add a deliberately broken wikilink to a scratch file under `docs/` and confirm the lint's behaviour matches whatever the resolution promises — caught, or documented as unchecked
- [ ] Confirm the prose example in ADR 0002 does not fail the lint
- [ ] Re-read the rulebook sentence and confirm a reader writing a wikilink in `docs/` now knows whether it is checked

## Implementation plan

_Populated by `/tasks plan TASK-071` — leave empty until then._
