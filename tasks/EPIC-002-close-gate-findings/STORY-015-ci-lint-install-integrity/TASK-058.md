---
id: TASK-058
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
findings: [CR-053-7]
pr: null
github-issue: null
jira-key: null
---

# STORY-015's theme ranks the repo's only gate last

## Context

**Found by `/code-review` at TASK-053's close gate.** This story — the one this task sits under — carries
`theme: docs-i18n-coverage`. Its four tasks are TASK-029, TASK-037, TASK-043 and TASK-045, and every one
of them is a **correctness defect in `skills-lint.sh`**, the repo's only automated gate. TASK-045 is
*"a flag one skill passes is never checked to exist in the receiving verb"*; TASK-043 is the wikilink
contract's enforcement boundary. None of that is documentation or i18n coverage.

**Why the wrong label has teeth.** `docs-i18n-coverage` is rung 7 — the bottom of `intake`'s subject
ladder — and [[fix-next]] reads `theme:` as tie-break **key 6**. So the field ranks this repo's
gate defects *below every other EPIC-002 story*, all of which carry `correctness-invariants`. TASK-044
added `theme:` specifically so the ranking would stop being inferred from titles and become reproducible;
here it is reproducibly wrong, which is the failure mode a declared field trades for — an inference that
guesses right sometimes is replaced by a declaration that is confidently wrong until someone corrects it.

**This is a re-classification, not a typo fix, which is why it gets an id rather than a quiet edit.**
Changing a ranking key changes what `/fix-next` picks next, so it deserves to be visible and reviewable
rather than folded into an unrelated close. Read `intake`'s ladder before writing the new value —
`correctness-invariants` is the obvious candidate and almost certainly right, but the ladder is the
authority and it may have a rung that fits gate-infrastructure defects better.

**Check the sibling stories while here.** If one label drifted from its contents, the others are worth a
glance — but only a glance: re-theming a story whose label is defensible is churn, and disagreement about
a borderline rung is not a defect.

## Acceptance criteria

- [x] STORY-015's `theme:` names a rung that matches what its four tasks actually are, chosen against `intake`'s ladder rather than by analogy to the other stories
- [x] The reason is recorded on this task — which rung, and why the tasks fit it — so the next reader does not re-derive it
- [x] Every other EPIC-002 story's `theme:` is checked against its tasks; each is either left alone or corrected, and the sweep's outcome is stated either way
- [x] `/fix-next`'s ranking is re-read (not re-implemented) to confirm the new value orders these tasks the way the change intends

### The rung, and why (AC 1, 2)

**`correctness-invariants`** — rung 2. Read against `intake`'s ladder, not by analogy to the sibling
stories. The story's six tasks:

| Task | What it is |
|---|---|
| TASK-029 | the lint's own test coverage grew 16→25 cases with nothing recording what the nine pin |
| TASK-037 (done) | nothing detects a `skills-pi/` stub shadowing a runtime built-in |
| TASK-043 | the wikilink contract is enforced only inside `skills/` and cannot naively be widened |
| TASK-045 | a flag one skill passes is never checked to exist in the receiving verb |
| TASK-071 | the rulebook says CI resolves wikilinks; in `docs/` that is false |

Five of six are defects **in the repo's only automated gate** — an undetected shadow, an unenforced
contract, an unchecked flag, a false guarantee. `docs-i18n-coverage` is rung 7 and its scope is *"audits
that **spawn** fix work rather than fixing in place"*; none of these spawns work elsewhere, they each fix
the gate. TASK-029 is the only arguable one — it is about *recording* what test cases pin — and it is still
about the gate's own trustworthiness rather than documentation coverage.

**Note the filing drifted:** this task's Context says "four tasks", written when the story had four.
TASK-058 and TASK-071 were added after, so it is six. The reading is unchanged; the count was stale.

### The sweep (AC 3) — and what it reveals

Every EPIC-002 story checked against its own tasks, not just the flagged one:

| Story | Theme | Verdict |
|---|---|---|
| STORY-010 `verify-conventions` gaps | `correctness-invariants` | correct, left alone |
| STORY-011 the `tasks` skill's defects | `correctness-invariants` | correct, left alone |
| STORY-012 universal-layer declarations | `correctness-invariants` | correct, left alone |
| STORY-013 the drift audit | `correctness-invariants` | correct, left alone |
| STORY-014 `specs` gates | `correctness-invariants` | correct, left alone |
| STORY-015 CI lint + install integrity | ~~`docs-i18n-coverage`~~ → `correctness-invariants` | **corrected** |
| STORY-016 front doors under a cold drill | `correctness-invariants` | correct, left alone |

**One was wrong; six were right.** Stating the outcome either way, because a sweep that only reports its
hits cannot be told from one that never ran.

### The consequence, and why it is not a defect (AC 4)

After this fix **every story in EPIC-002 declares the same theme**, so key 6 now discriminates *nothing*
across this epic. That is not a regression — it is the expected shape, and `fix-next` already anticipates
it exactly:

> Three cases make it inert: no candidate declares a theme, **every candidate declares the same one**, or
> the pool separated on keys 1-5 before reaching it. A degenerate ladder is normal on a repo whose defects
> cluster in one theme — **a codebase whose product is prose rules yields almost only correctness
> defects** — so a run that never mentions key 6 is indistinguishable from one where the key did the work.

So the requirement lands on the *reporting*, not the field: a `/fix-next` run on this epic must **say** key
6 was inert rather than passing over it silently. Re-read rather than re-implemented, per this task's own
criterion — and **nothing is spawned**, because the machinery already handles the case the fix creates.
Which is the pleasing part: the rule that made this field a declaration also predicted what the corrected
value would do to the ranking.

**Practical effect on drainage:** these tasks now separate on keys 1–5 (blast radius, finding count,
dependency edges) rather than being pushed behind every other story by a rung-7 label. That was the whole
point of the fix.


## Out of scope

- Changing `intake`'s ladder, or `fix-next`'s key order. If the ladder has no rung that fits gate-infrastructure defects, that is a finding to spawn, not to fix here.
- The four tasks themselves — TASK-029, TASK-043, TASK-045 stay `todo` and are unaffected by their story's label.
- TASK-044, which added the field and is `done`. This is a data correction to one story, not a defect in that work.

## Human test plan

N/A — fully covered by reading `intake`'s ladder against the four task titles, plus re-reading
`fix-next`'s key 6. There is no runtime: the "test" is that a human agrees the rung matches the contents,
which is the acceptance criteria restated, and running `/fix-next` to watch the order change would
confirm the field is read — never that the value is right.

## Implementation plan

_Populated by `/tasks plan TASK-058` — leave empty until then._
