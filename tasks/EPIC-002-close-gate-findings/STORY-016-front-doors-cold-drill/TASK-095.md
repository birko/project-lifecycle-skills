---
id: TASK-095
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-035-4]
pr: null
github-issue: null
jira-key: null
---

# "Thinly answered" has one calibration point, and two drills split on it

## Context

**From both 2026-09-01 cold drills of `adopt-project` step 2.** `INFER.md` § *When the rulebook already
answers it* draws a three-way distinction — **covered → skip**, **not covered → propose**, and
**thinly answered → offer, don't run**. The third has exactly one calibration point in the text:
WorkoutTracker, where *"naming is answered by one file-naming rule."*

Both runners reached the thin/covered line, and both flagged their verdict as a judgement nothing counted:

> *"`### Naming` (3 rules) and `### Testing` (2 rules) are borderline against a benchmark of **one**. I
> chose to judge all five answered-and-not-thin and skip, while surfacing the Naming thinness as an
> explicit offer."* — the BardStudio run

> *"**thinly answered → offered, not run** … A judgement, and the same one `INFER.md`'s own WorkoutTracker
> measurement calls a judgement. **Nothing counted it.**"* — the Birko.Framework run

And the second projected the divergence directly:

> *"A second run could reasonably call naming **covered** (the `*All` rule, the `Birko.{Project}` scheme and
> the GUID format are real naming rules), which would collapse the round to items 1–6 and produce a clean
> four-of-four skip announcement."*

**Two runs over one unchanged repo would put a different question to the user.** That is the
non-reproducibility this repo removes elsewhere by declaring a value rather than deriving it.

Note which way the ambiguity currently leans: both runners resolved it by *offering* rather than running,
because `INFER.md` names both alternatives as failures — *"Skipping silently hides a real gap; proposing
unasked contradicts propose, never assert."* The offer is the only move that violates neither, so **the
rule presently works by leaving its gap in the one place a runner cannot get it wrong.** That is luck
holding a rule up, not a rule.

**Do not over-fix this.** A hard rule count would be worse: a subsection answered by one excellent rule can
be genuinely finished, and three vague ones can be thin. The BardStudio runner's own instinct — *"each
carries ≥ 2 normative rules with measured counts"* — is a heuristic, not a threshold, and encoding it as a
threshold is how a judgement becomes a wrong answer with a number attached.

## Acceptance criteria

- [ ] The thin/covered line is decidable well enough that two runs over one unchanged guide reach the same verdict, **or** the rule states plainly that the verdict is a judgement and always routes to the **offer** — either is acceptable, silence is not
- [ ] If it stays a judgement, the offer becomes the *stated* default for the borderline case rather than something two runners each had to derive
- [ ] The rule does not become a rule count, and says why not
- [ ] The existing WorkoutTracker calibration point is kept or replaced with a better one, not deleted
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The declaration/proposal split, which the same drills confirmed working — **TASK-035**.
- Whether a thin subsection's round should be run automatically. `propose, never assert` settles that; this is about detecting thinness at all.
- `verify-conventions`' coverage ladder, which both runners used without difficulty and which is not the ambiguous part.

## Human test plan

- [ ] Two independent cold readers judge the same borderline guide (`Birko.Framework`'s `### Naming` is the measured case) and either reach the same verdict or both route it to the offer

## Implementation plan

_Populated by `/tasks plan TASK-095` — leave empty until then._
