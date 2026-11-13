---
id: TASK-102
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-098-2, DRILL-098-3]
pr: null
github-issue: null
jira-key: null
picked-by: fix-next
---

# Nothing says whether a step-3 fill offer joins step 2's round or comes after it

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `Latent`.** Two instances, one question, so they are
filed together.

Step 2 closes with a hard rule:

> *"Put the inferences and the choices in **one frontier round** ([[grill-me]]'s shape), not a queue of
> single questions. A 15-rule proposal asked one at a time becomes an interrogation."*

Step 3 then makes **offers** — land this, append that, add these lines — and nothing says whether they
belong in that round or come afterwards. The runner hit it twice and folded both into the round, reasoning
from the interrogation clause rather than from anything that addresses the case:

> *"What is unsettled: whether the offer is a round item or a separate ask. … **I put it in the round**
> rather than deferring it to the report: it is a yes/no about writing to a file, the user is being asked
> three other questions in the same breath, and a fourth queued separately is the interrogation the
> one-round rule exists to prevent."*

> *"What is unsettled: which step the landing offer belongs to. It is described in step 3, but making it
> there would open a question after the round closed. **I folded it into the round.**"*

Its answer is almost certainly right, and it produced a genuinely good round — four items, itemised,
answerable as a subset. But it is a judgement the text does not make, and the other reading is available:
step 3's offers are *described in step 3*, so a reader who follows the steps in order asks them there, one
at a time, which is the interrogation the rule forbids.

### Why this is not just tidiness

**The one-round rule has a stated failure mode and this reintroduces it by the back door.** Step 2 is
protected; step 3 is where the actual writes are, and it currently makes at least four separate offers —
land the unlanded paths, append the `## Amendments` heading, add the `.gitignore` lines, create each missing
artifact. Asked serially those are exactly the queue the rule was written against, and the user's attention
is worst at the end.

**It also interacts with a rule installed the same day.** TASK-035 made step 2 pass declarations to their
owning verbs *"from here, so the question stays in this round instead of surfacing inside step 3's
delegation, which is the one-round rule below breaking by another route."* That sentence establishes the
principle for *declarations*. Fill offers are the same shape and were not covered — so the fix is likely to
be one sentence generalising what TASK-035 already argued, rather than a new mechanism.

**What must not happen is a second round.** Two rounds is the interrogation split in half. If offers cannot
all be known before step 3 begins — and some cannot, since what needs creating depends on what the round
answered — then the rule has to say which offers are foreseeable at step 2 and what happens to the rest.
That is the interesting part and it should not be waved through.

### Two more instances, 2026-11-13 (TASK-065's full-pass drill)

`%LOCALAPPDATA%/Temp/d065b/full`, one cold runner, a full run with nobody present:

- **Questions raised inside delegations.** `populate-tests adopt` asked its § Testing question, and `/specs init`
  asked its blessing question, both inside step 3, after step 2's round had closed. The runner quoted step 2's "pass
  them from here, so the question stays in this round instead of surfacing inside step 3's delegation" and could not
  apply it: those two questions only exist once the delegation runs. These are the same offers that "cannot be known
  until the round has been answered" that the criteria below ask about.
- **Creating a missing artifact: offer or write?** The runner created `.gitattributes`, `.editorconfig` and the
  `CHANGELOG.md` skeleton without asking, reading "Ask about an artifact the survey found missing" as covering choices
  only. The step-3 list above names "create each missing artifact" as an offer.
- **The scoped side of the same question.** A scoped run owes "every question step 2 would have put". In
  `d065b/scoped` that report carried the `.gitignore` and CI offers but not the README "How we work" pointer, and its
  README row read plain `present`. Whether a fill offer counts as a step-2 question decides whether that is an omission.

### One more instance, 2026-11-13 (TASK-354's full-pass re-drill, `%LOCALAPPDATA%/Temp/d354`)

- **The round's size limit.** [[grill-me]] says "**At most five questions in a round.**", and adoption puts every
  inference and choice in one round. With the guide-section offer now pinned to step 2 (TASK-354), the runner kept
  only inferences and declarations in the round, three items. It moved every other row offer (the README pointer,
  `.gitignore`, the CHANGELOG backfill, CI) to step 3, citing that limit. Whatever this task decides has to say what
  happens when the round would exceed five.
- The same runner again raised questions arising inside delegations (the specs blessing, populate-tests' § Testing),
  and step 3's "Create if absent" rows against "nothing is written unasked".

## Acceptance criteria

- [x] Where a step-3 fill offer is asked is stated — in step 2's round, or at the fill, or a stated split — and the reason is given
- [x] The answer covers offers that **cannot** be known until the round has been answered, rather than assuming all are foreseeable
- [x] No second round is introduced, and the one-round rule's failure mode is not reachable by asking step 3's offers serially
- [x] Consistent with TASK-035's rule that a declaration is passed from step 2 rather than surfacing inside step 3's delegation
- [x] The measured instances both resolve without a runner having to reason it out: the `## Amendments` offer and the `present, uncommitted` landing offer
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The *shape* of the landing offer — **TASK-086** settled that (one itemised offer, subset acceptable, members listed).
- Whether `## Amendments` is owed — **TASK-098** settled that it is.
- The content of step 2's inference round. This is about where fill offers go, not about what the round proposes.

## Human test plan

- [x] Cold-drill a repo with at least two step-3 offers available, expected answers withheld, and confirm the runner does not list offer placement among the things it had to decide
- [x] Confirm the run still produces one round, not two
  - **Both passed 2026-11-13.** Two cold full-adoption runs on fresh copies of `d065/adopted`, using the d065b full
    brief and runner command, with `skills/` at this fix. Both left `CLAUDE.md` and `.gitignore` untouched and
    committed nothing.
    - **Coldness:** no skills listed and no Skill tool, both runs.
    - **First run, `%LOCALAPPDATA%/Temp/d102`.**
      - The round was one round, two items: the licence question and the a–g fill item.
      - The specs blessing and the § Testing question were asked at their delegations.
      - `.pytest_cache/` was reported as `offered, not asked — found after the round`.
      - It still raised two placement points, both from this task's own wording. "Create it" collided with
        `docs/architecture.md`'s *leave it* row, and the adoption commit offer had no stated place. Both were fixed.
    - **Second run, `%LOCALAPPDATA%/Temp/d102b`, on the fixed text.**
      - It left `docs/architecture.md` and reported it ("Row says leave and report").
      - It ended with `adoption commit: offered, unanswered — nothing committed`.
      - **None of its twelve undecided points is about where a question or offer goes.**
    - **New one-runner readings, recorded here and not filed:**
      - `.gitattributes` and `.editorconfig` content with no template;
      - the `!.env.example` negation with that row not applicable;
      - pinning with no manifest;
      - the `## Commands` token's source column naming CI and manifests but not a runner config such as `pytest.ini`,
        which TASK-354's ordering text implies;
      - `architecture.md` `missing` versus `missing, not offered`;
      - where empty Conventions subsections are recorded;
      - timestamp-only regeneration;
      - creating `docs/features/`;
      - rendering empty generated sections;
      - commented template blocks as fields;
      - the specs scan set seeing nothing uncommitted;
      - the "nothing at risk" phrasing.

## Implementation plan

Written 2026-11-13 by `/fix-next` after the user's decision (Progress log). All changes are in `skills/adopt-project/SKILL.md`.

1. **Step 2 — fill offers join the round as one item.** Every foreseeable offer to change an owned file is one
   itemised question with a stated wording, counting as one toward grill-me's five. With no answer, none is made,
   and each is reported as `offered, unanswered`.
2. **Step 2 — creating is not an offer.** An absent layer artifact is created, because the invocation asked for it.
   A row whose cell says *offer* stays an offer. The "Ask about an artifact the survey found missing" sentence is
   narrowed to the *choice* such an artifact needs (which guide file, which licence).
3. **Step 2 — the one exception.** A question a delegated verb puts itself (the specs blessing, populate-tests'
   § Testing) is asked at that delegation, with its own no-answer outcome. Declarations stay passed from step 2.
   An offer found only inside a delegation is reported as `offered, not asked — found after the round`, never asked
   late.
4. **The opening's promise** reads "nothing the repo already owns is changed unasked", and says absent artifacts
   are created.
5. **Step 4's *left alone* reasons** gain the two `offered …` values.
6. **Respec `project-baseline`** for the round requirement.

## Outcome

**The fix (the user's decision, 2026-11-13: the recommendation on all three questions).** `/adopt-project` now says
where every question it can put goes:
- **Every foreseeable offer to change a file the user already owns** goes in the opening round as one itemised
  question, "Shall I make any of these changes? a) … b) …". The guide sections, the README pointer, `.gitignore`
  lines, the Amendments heading, landing uncommitted paths, CI and a backfill are all in it. It counts as one
  question toward grill-me's five, and with no answer none is made.
- **Creating a layer file that does not exist needs no question**, because running adoption asked for it. The row's
  own cell still decides: *offer* rows are offers, and *leave it* rows (`docs/architecture.md`) are left.
- **Three things are stated as outside the round:**
  - questions a delegated skill puts itself (the spec-map blessing, the Testing section), asked when it runs, each
    with its own safe no-answer outcome;
  - offers that only appear inside a delegation, reported but not asked;
  - the adoption commit, the closing question, with its wording and its no-answer outcome.

**Step-6 split.**
- **Text assertions:** 8 of 8 fail on `HEAD`'s copy and pass on the fix, all fix-dependent: the one item, it counting
  as one, creating not being an offer, the delegation exception, late offers reported, the choice-not-creation
  sentence, the row deciding creation, and the commit offer's place and wording. The script is
  `task102-check.sh` in the session scratchpad.
- **Behaviour:**
  - **Before:** on the old text, three runners (d065b/full, d353, d354) each listed offer placement as undecided.
  - **After:** the d102b runner did not.
- **Contract pin, not evidence:** skills-lint.

**Judgement calls.**
- **The decision was asked, not taken.** It is the "convention that isn't settled" case the guardrail names. It was
  put in plain language, one question per open point, with a recommendation each, and the user took all three.
- **The cap is met by grouping, not by a second round.** The fills are one item, so the round keeps its five for
  inferences and declarations. Two rounds is what this task's Context calls "the interrogation split in half".
- **The delegation exception is narrow on purpose.** Declarations are still passed from step 2, as TASK-035 ruled.
  Only questions that cannot exist before their verb runs are excepted, and each already has a stated no-answer path.
- **An offer found after the round is reported, not asked**, so the one-round rule has no back door.

**Close gate (inline, about 45 lines of prose in one file):**
- **Standards:** every new ask-step states its question and its no-answer path, per § *An ask-step carries the
  question it puts*. The row inventory stays in LAYER.md, and the fill list names its members as "today", pointing at
  the rows' cells for the rest.
- **Intent:** criteria met, including the two measured instances: the `## Amendments` offer and the
  `present, uncommitted` landing are both items in the round.
- **Correctness:** two problems this change introduced were found by the drill and fixed: the creation rule
  colliding with *leave it* rows, and the commit offer's placement.
- **Security, comments:** not applicable.
- **CI:** `ci: main green — 1 workflow read`.

**Flagged, not fixed.** The twelve one-runner readings under the Human test plan.

Filed 2026-11-13, after comparing all six adoption drills: the readings here that a second runner also raised are TASK-356 and TASK-357. Pinning with no manifest is TASK-072.

## Progress log

- step 2 — picked; ranked first among the remaining STORY-016 tasks (correctness-invariants, key 6 inert) because three drills on 2026-11-13 (d065b/full, d353, d354) each raised it again, so it now sits under more open readings than any other task in the pool (keys 1–2). Key 4 counts against it: the answer is a rule to design, so the guardrail path is taken (non-controversial work, then ask)
- step 3 — verified: held, and wider than filed. Four open questions: where foreseeable offers to amend an owned file go; whether creating an absent layer file needs an offer at all (runners split); questions that exist only inside a delegation (specs blessing, populate-tests § Testing); grill-me's five-question cap against the one round
- step <guardrail> — decision put to the user (2026-11-13), three questions, recommendation taken on each: (1) every foreseeable offer to change an owned file goes in step 2's round as one itemised item; (2) creating an absent layer file needs no offer — the invocation asked for it; (3) questions that exist only inside a delegation (specs blessing, populate-tests § Testing) are asked there, as a stated exception, each with its own no-answer outcome
- step 3b — planned: written after the decision (one file, five criteria)
- step 4 — layer: local
- step 5 — fix in skills/adopt-project/SKILL.md (opening, step 2 fill item and its two exceptions, the missing-artifact sentence, step 4 left-alone reasons)
- step 6 — reverted fix (HEAD copy): 8/8 assertions failed; fix-dependent = F1–F8; contract pins = skills-lint. Behaviour: three runners raised offer placement on the old text; d102b (fixed) did not
- step 7 — respecced project-baseline (Inferences and declarations go to the user in one frontier round), surgical, restamped; intended — the user's decision
- step 8 — handed to /tasks close --unattended; outcome in status:, commit in git log
