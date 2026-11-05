---
id: TASK-028
parent: STORY-012
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-19
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-035-4, DRILL-091-1]
pr: null
picked-by: fix-next
github-issue: null
jira-key: null
---

# The inference skip rule counts five subsections when one of them is conditional

## Context

Found by `/code-review` on TASK-026's diff (2026-08-19), in a file that diff did not touch.

`skills/adopt-project/INFER.md:91` decides whether to run the convention-inference round by counting
coverage over the five subsections of § *What to read, per subsection*: **all covered → skip**,
**some covered → run a round scoped to the rest** ("four of five covered is a one-subsection round").
But that same section makes **UI / UX** conditional — *only when a human-facing surface exists*,
otherwise *drop the subsection rather than filling it emptily*.

On a headless library the two rules collide. An agent following the arithmetic literally either never
reaches "all covered" — UI / UX cannot be covered, because it does not apply — and runs a pointless
round forever, or runs a one-subsection round proposing UI rules to a repo with no UI, which is
precisely the empty fill the conditional exists to prevent. TASK-017 gave this round its skip
condition; this is that condition meeting a repo shape it does not describe.

### Merged in 2026-09-26: TASK-095 — "Thinly answered" has one calibration point, and two drills split on it

_Merged because both are INFER.md's covered / thin / skip arithmetic. The original file stays, cancelled, at `tasks/EPIC-002-close-gate-findings/STORY-016-front-doors-cold-drill/TASK-095.md`._

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

#### A second instance, on a different rule (DRILL-091-1)

The 2026-09-01 `Symbio` drill hit the same defect class in § *Matching a guide's sections* rather than in
`INFER.md`: **by-meaning matching has no depth bar either.**

The seed's `## How we work — feature lifecycle` section answers the flow, the `/feature` verbs, the decision
states, the task-first gate, the human test plan, the review gate and the record-altitude table. The runner
found that `README.md` § *How we work* carries a record-altitude map, the flow and the branch convention —
and resolved the section `present` on it, while naming what that answer does **not** reach:

> *"README's is pointer-depth — it does not carry the prototype/decide/decompose verbs, the review gate, the
> task-first gate, or the register-on-introduce rule. **Nothing in the text sets a depth bar for 'answers
> the question'.** I resolved it `present` and am naming the shortfall here rather than silently."*

**Why this belongs here rather than in its own task:** it is the same shape as the thin/covered split — a
by-meaning verdict with a binary outcome and no stated bar — and the two may well take **one** answer. It is
also evidence that the gap is not peculiar to proposal coverage, which was the reading available when this
task was filed from two runs of one rule.

**The two are not identical, and the fix must not assume they are.** Proposal coverage has a safe fallback
(*offer, don't run*) that both runners found; section matching has **no third option** — a section is
answered or it is not, and the runner had to pick one and annotate it. So whatever bar is chosen, section
matching may need an *undetermined* route that § *Matching a guide's sections* already provides for genuine
ambiguity but not for a **shallow** answer, which is a different thing from an ambiguous one.

## Acceptance criteria

- [x] The rule counts **applicable** subsections, not five — an inapplicable subsection is neither covered nor outstanding
- [x] A headless library whose rulebook answers its four applicable subsections **skips** the round, and says which subsection it dropped and why
- [x] A repo with a human-facing surface is unchanged: UI / UX still counts, and still runs when uncovered
- [x] The applicability test is stated where the count is made, so the two rules cannot be read separately again
- [x] Any arithmetic example in the file ("four of five") is restated in terms that survive a dropped subsection
- [x] `skills-lint` and `skills-lint-test` stay green

*From TASK-095:*

- [x] The thin/covered line is decidable well enough that two runs over one unchanged guide reach the same verdict, **or** the rule states plainly that the verdict is a judgement and always routes to the **offer** — either is acceptable, silence is not
- [x] If it stays a judgement, the offer becomes the *stated* default for the borderline case rather than something two runners each had to derive
- [x] The rule does not become a rule count, and says why not
- [x] The existing WorkoutTracker calibration point is kept or replaced with a better one, not deleted
- [x] **§ *Matching a guide's sections*' answer-depth verdict is covered too** (DRILL-091-1) — either by the same answer or by its own, and if by its own, the reason the two differ is stated
- [x] A **shallow** answer is distinguishable from an **ambiguous** one, since that section's existing *undetermined* route was written for the second and a shallow answer is not that
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- Whether the five subsections are the right five. This task only fixes the count.
- The layer's other conditional artifacts (CI's `missing, not offered`), which carry their own adjudication already.

*From TASK-095:*

- The declaration/proposal split, which the same drills confirmed working — **TASK-035**.
- Whether a thin subsection's round should be run automatically. `propose, never assert` settles that; this is about detecting thinness at all.
- `verify-conventions`' coverage ladder, which both runners used without difficulty and which is not the ambiguous part.

## Human test plan

- [x] Run `/adopt-project` step 2 against a headless library whose guide answers framework, structure, naming and testing — confirm it skips and names the dropped subsection
  - **Passed 2026-11-05:** `d028a` (a Python library; guide answers framework, structure, naming, testing; UI section `(none recorded)`): "Skipping convention proposals — your rulebook already answers every applicable subsection", with "UI / UX — dropped: no human-facing surface. There is no UI import and no view files". runner `claude -p --disable-slash-commands --permission-mode acceptEdits --allowedTools "Bash(git:*)" "Bash(cd:*)" "Bash(ls:*)" Read Glob Grep < brief.txt`, brief "Run /adopt-project against repo/ up to and including its step 2, then stop. Change no file. Report what step 2 decided for each part of the conventions it considers, with the evidence, and what it would ask or offer." (shared preamble and closing asks; no expected outcome). Fixtures built by `build_028.py`: an adopted layer plus code, skills copied after this fix
- [x] Run it against a repo with a UI whose guide has no UI rules — confirm UI / UX is still proposed
  - **Passed 2026-11-05:** `d028b` (a React app; four subsections answered, no UI rules): "All five subsections apply… Not covered: UI / UX… The round is scoped to that subsection", proposing "Styling values come from src/theme/tokens.ts [4/4 files]" and an accessible-names rule. The first run counted and scoped UI / UX the same way but proposed nothing, because each UI pattern was in only 2 files, under the 3-file evidence bar; two components were added and it was re-run
- [x] Run it against a repo with a UI and a complete rulebook — confirm the skip still fires
  - **Passed 2026-11-05:** `d028c` (a React app; all five answered, UI included): proposals skipped for every covered subsection, UI / UX by its three rules. Code structure was judged thin on evidence the guide does not reach ("named exports only; no default exports [6/6 files]") and offered as a one-subsection round, not run: the thin rule, as written

*From TASK-095:*

- [x] Two independent cold readers judge the same borderline guide (`Birko.Framework`'s `### Naming` is the measured case) and either reach the same verdict or both route it to the offer
  - **Passed 2026-11-05:** `d028d1` and `d028d2` (a Python library whose `### Naming` has three rules while the code also shows `_private` helpers and `UPPER_SNAKE` constants): both judged Naming **covered**, the same verdict. d028d2 named the further shapes and set them below the evidence bar (2 files each). The criterion's first branch (same verdict) holds; the borderline offer default was not exercised, since neither reader found it borderline

## Outcome

**What was fixed** (two merged findings in `adopt-project`'s convention inference):
- **The skip arithmetic counts applicable subsections, not five.** UI / UX applies only where a human-facing surface exists, by the evidence named; a dropped one is counted on neither side and named with its evidence. A headless library whose guide answers the other four now skips instead of running a pointless round or proposing UI rules. An undetermined surface counts as applicable.
- **"Thin" is a stated judgement with its evidence, never a rule count, and the offer is the default for a borderline call.** Birko.Framework's `### Naming` is added beside WorkoutTracker as the borderline calibration.
- **LAYER.md says a shallow guide section is `present`,** naming what it does not reach, not *undetermined*, and why that differs from INFER's offer.

**Step-6 split:** 0/0, because this is prose only. Evidence is four drills over five runs, all passed; one was re-run on a larger fixture.

**Judgement calls.**
- **Undetermined applicability counts as applicable:** one extra item, against a hidden gap.
- **The applicability test points at new-project's keep-or-drop rule,** adding only the adoption-time evidence.
- **Not a rule count,** because counts reward padding.

**Review (close step 5b, inline).** Adherence: cross-skill references use `[[new-project]]` and `[[adopt-project]]`, and no list is restated. Fidelity: all thirteen criteria across both blocks are met. Correctness: the skip-path paragraph's "answers all five" was restated too.

**Flagged, not fixed.** The borderline offer default went unexercised, because both readers called the thin naming section covered. The rule is stated; a future drill on a genuinely contested section would exercise it.

## Implementation plan

### Steps
1. **INFER.md § When the rulebook already answers it** gains its first bullet, **Count applicable subsections, not five**. UI / UX applies only where a human-facing surface exists, by the same test [[new-project]] uses. The evidence that settles it is named. A dropped subsection is counted on neither side and named with its evidence. An undetermined one counts as applicable, since including it costs one item and dropping it on a guess hides a gap.
2. **The arithmetic is restated in applicable terms:** "every applicable subsection covered → skip"; "one uncovered subsection is a one-subsection round, whether one of five or one of four"; "answers every applicable subsection". § What to read points at the count.
3. **The thin bullet:** thin is a judgement with its evidence named, never a rule count (a count rewards padding and penalises one rule that settles a subsection). **The offer is the stated default for a borderline call.** WorkoutTracker stays the clear case, and Birko.Framework's `### Naming` (three real rules, two drills split) is added as the borderline case.
4. **LAYER.md § Matching a guide's sections:** a shallow answer is `present`, naming what it does not reach, and does not go to *undetermined*, which stays for ambiguous meaning. Why it differs from INFER's offer: that row's only remedy is to append, which would create a second home.
5. **Spec `project-baseline`:** the inference requirement (applicable count, thin as judgement, offer default; +1 scenario for a headless library), guide matching (shallow is present), and split findings (every applicable subsection).

### Risks
- Counting undetermined as applicable can bring back a near-empty UI round; the silent rows bound it.

## Progress log

- step 2 — picked; ranked above TASK-089 because key 1: on a headless library the skip arithmetic never reaches "all covered", so adopt-project runs a pointless round or proposes UI rules to a repo with no UI (a wrong result), where TASK-089 concerns a branch never observed; key 4: one file (INFER.md); key 5: two cold drills split on the thin line (TASK-095); key 6 ties
- step 3 — verified: held. INFER.md § When the rulebook already answers it counts "all covered", "four of five" and "answers all five" over five subsections while § What to read makes UI/UX apply "only when a human-facing surface exists"; the thin bullet has one calibration point (WorkoutTracker) and no stated route for a borderline call; LAYER.md § Matching a guide's sections has only an *undetermined* route, written for ambiguous meaning, not for a shallow answer
- step 3b — planned: /tasks plan --no-grill (thirteen criteria across two merged findings); no split signal; the Birko.Framework calibration checked against the drill record quoted in this file
- step 4 — layer: local
- step 5 — fix in skills/adopt-project/INFER.md (applicable count with its evidence and the undetermined rule; the arithmetic restated; thin as a judgement with the offer as the borderline default and a second calibration point) and skills/new-project/LAYER.md (shallow answers are present; why that differs from INFER's offer); lint OK (20 skills)
- step 6 — reverted fix: 0/0 failed — prose only; fix-dependent = none; contract pins = skills-lint.sh; evidence = the four test-plan drills
- step 7 — respecced project-baseline; requirements changed: Conventions are inferred (applicable count, thin as judgement, offer default, +1 scenario), Agent-guide sections are matched by meaning (shallow is present), Glossary candidates and split findings (every applicable subsection); intended — TASK-028's criteria
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
