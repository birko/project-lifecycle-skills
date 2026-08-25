---
id: TASK-048
parent: STORY-005
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-20
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The smell baseline — `verify-conventions` has something to say about a repo that documented nothing

## Context

The other half of STORY-005's two axes. [[verify-conventions]] becomes the **standards** axis, and today
that axis is empty on a repo with no recorded rules: the skill reads the project's guide, finds no
normative content, and correctly reports that there is nothing to verify against. Correct, and useless
exactly where help is most needed.

The story's answer is a **fixed smell baseline** that applies even when a repo documents nothing:
mysterious name, duplicated code, feature envy, data clumps, primitive obsession, repeated switches,
shotgun surgery, divergent change, speculative generality, message chains, middle man, refused bequest.

Two rules bind it, and both exist to stop the baseline overriding the thing the skill is actually for:

- **The repo overrides.** A documented standard always wins and **suppresses a conflicting smell**. The
  skill's whole premise is that it checks what the project agreed to, not what it believes; a baseline
  that argues with a recorded rule would invert that.
- **Every smell is a labelled judgement call**, never a hard violation. They are heuristics with known
  false positives, and the skill's existing severity model already has the right slot — warnings and
  suggestions, not blockers.
- **Skip anything tooling already enforces.** Restating a linter's output is noise that buries the
  findings only a reader can make.

**Relationship to open defects in the same skill.** TASK-009 (no rule about generated and vendored
files) and TASK-013 (the report has no slot for the sections it read) both touch this skill, and
TASK-013 touches the **report format** this task also extends. Whoever picks these should read all
three; landing TASK-013 first would probably make this one smaller. Not declared a hard `depends-on`,
because either order works and a false dependency blocks the ready pool for no reason.

## Acceptance criteria

- [x] The twelve smells are recorded with the observable signal that identifies each — not the name alone
- [x] The repo-overrides rule is stated with its rationale, and a worked example shows a documented rule
      suppressing a conflicting smell
- [x] Smell findings are emitted as labelled judgement calls, distinguishable in the output from a
      documented-rule violation — a reader must be able to tell which kind a finding is without guessing
- [x] The skip-what-tooling-enforces rule is stated
- [x] A repo with **no** recorded conventions now gets a useful pass instead of "nothing to verify" —
      and the report still says plainly that no documented rules were found, so the two are not confused
- [x] The existing behaviour on a repo **with** a rulebook is unchanged; the rulebook sweep still runs
      first and still leads the report
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **`verify-intent`** — TASK-046 and TASK-047. This task is the standards axis only.
- **Reporting the two axes side by side** — TASK-049 owns the combined output.
- TASK-009 and TASK-013, which are separately filed defects in this same skill.
- Auto-fixing. Advisory, as the skill already is.

## Human test plan

- [x] Run against a repo with no recorded conventions and confirm the pass is useful, with every finding
      labelled a judgement call — fixture A: two findings (repeated switches, data clumps), both prefixed
      `smell:` and both carrying the "not a documented rule" line. Previously printed "nothing to verify"
- [x] Run against this repo and confirm the documented rules still lead, and that no smell contradicts
      a recorded rule — confirmed; the baseline runs after the § Conventions sweep and never reorders it
- [x] Construct a case where a documented rule and a smell disagree, and confirm the rule wins and the
      smell is suppressed rather than reported alongside — fixture B: a guide forbidding a mapper layer
      against textbook duplicated code. Suppressed, and **reported as suppressed** — silence there is
      indistinguishable from the baseline having missed it
- [x] Confirm a smell a linter already reports is not restated — fixture C: `.eslintrc.json` erroring on
      `no-unused-vars` and `complexity`; the unused parameter is listed as tooling-enforced, not reported

## Implementation plan

_Populated by `/tasks plan TASK-048` — leave empty until then._

## Progress log

- step 2 — picked as the last piece making `verify-conventions` useful on a repo with no rulebook, and
  materially cheaper now that TASK-013 and TASK-009 settled the report header it extends.
- step 3 — verified: held, and **rescoped before writing**. The task assumed a new twelve-smell list.
  `skills/tdd/refactoring.md` already held six candidates, two of them among the twelve — so this is a
  shared-inventory change, not a new list.
- step 4 — layer: local.
- step 5 — fix in `skills/tdd/refactoring.md` (expanded to 15 rows, each with an observable signal and a
  suggested move) and `skills/verify-conventions/SKILL.md` (the baseline section, the `smell:` label in
  § Output format, and the frontmatter description). Registered in `AGENTS.md`.
- step 6 — **no guard to fail**; the lint reads frontmatter, wikilinks and file references, not a skill's
  reasoning. Evidence is the four drills, recorded as drills.
- step 7 — no usable spec map (`areas: []`). Nothing to respec.

## Outcome

**What was broken.** On a repo that documented nothing, the standards axis was empty: the skill read the
guide, found no normative content, and correctly reported there was nothing to verify against. Correct,
and useless exactly where help is most needed.

**The rescope, and the reason it matters.** The task assumed a new list of twelve smells.
`skills/tdd/refactoring.md` already carried six candidates including two of the twelve, so writing a
second list would have been the defect this repo's own convention forbids. The pull toward a copy was
strong **because** the two skills use the list for different jobs — TDD's refactor step prescribes a
move, a review gate reports a finding — and that difference is precisely what makes a copy look
justified. It is not: the list is one inventory, and the job-specific part is the handful of rules each
consumer adds around it. Expanded the existing owner to 15 rows rather than starting a neutral one, since
moving a list to a "better" home breaks its current reader (`tdd/SKILL.md:123`) for no gain.

**Judgement call: suppression is reported, not silent.** A documented rule that conflicts with a smell
suppresses it — but the report *says* it suppressed one and which rule did it. Silence there is
indistinguishable from the baseline having missed the smell, which is the same invisible-gate defect
TASK-013 fixed for the rulebook line and TASK-009 for the exclusions. The three compose: the header now
accounts for what was read, what was skipped, and what was overridden.

**Judgement call: `smell:` is a prefix, not a tone.** A reader who cannot distinguish a heuristic from a
rule the project wrote down will either dismiss the real violations or act on the heuristics as though
they were agreed. Never a 🛑.

**Drilled on four fixtures** — no rulebook (findings appear, labelled), a rule that conflicts
(suppressed and said so), a linter that already covers it (skipped as tooling-enforced), and this repo
(documented rules still lead).
