---
id: TASK-098
parent: STORY-016
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P3
assignee: agent
created: 2026-09-01
depends-on: []
blocks: []
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: [DRILL-096-3]
pr: null
github-issue: null
jira-key: null
---

# The adopted-repo brief describes the substitute and never the original

## Context

**From the 2026-09-01 cold drill of `adopt-project` on `Latent`.**

`LAYER.md` § *The adopted-repo brief* prescribes a stamp for a repo joining the layer: an `## Origin`
section recording the adoption date and that no original brief exists, plus an empty `## Amendments` log.
It is written entirely for the case where **nothing survives** — which is the common case and the reason
the section exists.

`Latent`'s `docs/BRIEF.md` has neither section. It has something better: a genuine dated
`## Opening ask (2026-07-14)` quoted verbatim, plus a scope confirmation. The runner:

> *"`docs/BRIEF.md` has neither, but it **does** have a genuine dated verbatim opening ask — which is
> exactly the thing the stamp substitutes for when it is absent. I chose `present` with nothing owed,
> reasoning that the stamp exists for repos with no surviving original ask. **The text does not say this;
> it describes the stamp without saying what to do when the real thing is there.**"*

Its reading is right, and the cost of the gap is small — the row lands `present` either way, so nothing is
mis-surveyed. What it costs is a judgement a runner should not have to make, and the risk is the wrong
direction: a runner who reads the stamp as *the* required shape reports a brief with a real verbatim ask as
thin, or worse offers to append an `## Origin` section saying no original exists **beside** the original.

### Why this is P3 and should stay small

No state is wrong, no artifact is at risk, and one sentence fixes it. The temptation to over-answer is the
real hazard: this must not turn into a prescribed schema for `docs/BRIEF.md`, because the brief is
append-only ground truth whose whole point is that it carries whatever the user actually said. The
`## Amendments` half may genuinely be owed in both cases — an adopted repo with a real opening ask still
needs somewhere for later requirement changes to land — and that is the one part worth thinking about
rather than asserting.

**A second observation from the same drill was considered and deliberately not filed.** The seed's guide
carries an opening bullet list (`**Stack:**`, `**Kind:**`, `**Specs:**`, `**Changelog:**`, …) and `Latent`'s
guide omits two of them while both artifacts exist. The runner noticed that, unlike the rule-list diff
§ *A guide's vintage is not surveyable* rejected, *"this omission **is** reproducible and mechanical"* — and
still declined to call it a gap, because § *Matching a guide's sections* scopes the inventory to `##`
headings. That is the right call and the reason not to file it: widening the inventory to header bullets
reopens exactly the question TASK-063 measured and settled, and it would fail the same negative control
(this repo's own guide omits seed bullets too). Recorded so the next reader finds a decision instead of
rediscovering the idea.

## Acceptance criteria

- [ ] § *The adopted-repo brief* says what to do when the repo already carries a genuine verbatim ask — one sentence, not a schema
- [ ] Whether `## Amendments` is owed in that case is decided explicitly rather than left to follow from the stamp's absence
- [ ] Nothing in the change prescribes the *content* of `docs/BRIEF.md` beyond what the append-only rule already requires
- [ ] The never-reconstruct rule is untouched and still unambiguous
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The seed guide's header bullet list — considered and declined above, with reasons.
- Anything about `## Amendments` content or how later requests are appended. [[new-project]] owns the append-only rule and it is not in question.
- Reconstructing a brief from a README. Forbidden, and this task does not soften it.

## Human test plan

- [ ] Cold-drill a repo whose `docs/BRIEF.md` carries a real verbatim ask, expected answers withheld, and confirm the runner reports the row without listing it as something it had to decide

## Implementation plan

_Populated by `/tasks plan TASK-098` — leave empty until then._
