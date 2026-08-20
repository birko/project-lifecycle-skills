---
id: TASK-048
parent: STORY-005
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
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

- [ ] The twelve smells are recorded with the observable signal that identifies each — not the name alone
- [ ] The repo-overrides rule is stated with its rationale, and a worked example shows a documented rule
      suppressing a conflicting smell
- [ ] Smell findings are emitted as labelled judgement calls, distinguishable in the output from a
      documented-rule violation — a reader must be able to tell which kind a finding is without guessing
- [ ] The skip-what-tooling-enforces rule is stated
- [ ] A repo with **no** recorded conventions now gets a useful pass instead of "nothing to verify" —
      and the report still says plainly that no documented rules were found, so the two are not confused
- [ ] The existing behaviour on a repo **with** a rulebook is unchanged; the rulebook sweep still runs
      first and still leads the report
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **`verify-intent`** — TASK-046 and TASK-047. This task is the standards axis only.
- **Reporting the two axes side by side** — TASK-049 owns the combined output.
- TASK-009 and TASK-013, which are separately filed defects in this same skill.
- Auto-fixing. Advisory, as the skill already is.

## Human test plan

- [ ] Run against a repo with no recorded conventions and confirm the pass is useful, with every finding
      labelled a judgement call
- [ ] Run against this repo and confirm the documented rules still lead, and that no smell contradicts
      a recorded rule
- [ ] Construct a case where a documented rule and a smell disagree, and confirm the rule wins and the
      smell is suppressed rather than reported alongside
- [ ] Confirm a smell a linter already reports is not restated

## Implementation plan

_Populated by `/tasks plan TASK-048` — leave empty until then._
