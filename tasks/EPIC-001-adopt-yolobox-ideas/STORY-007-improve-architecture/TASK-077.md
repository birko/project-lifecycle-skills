---
id: TASK-077
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-08-26
depends-on: [TASK-076]
blocks: [TASK-078]
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# The report surface — an Artifact, a fallback, and what each candidate must carry

## Context

STORY-007 asks for the pass to **report as an Artifact** (a shareable published page), *"falling back to a
temp HTML file where the runtime has no Artifact surface — the same runtime-degradation pattern
`tasks/close` already uses for `code-review`."*

**That precedent is the thing to copy, and it is a specific one.** `close` step 5b's rule is: the skill is
runtime-provided, and **if the name does not resolve, do the pass inline — never skip the gate because a
skill did not resolve.** Applied here: an absent Artifact surface degrades the *delivery*, never the
*analysis*. A run that produces no report because it could not publish one is the failure this task exists to
prevent.

**Why the report earns its own task rather than riding along with the skill.** Two independent reasons: the
runtime-degradation path is a distinct behaviour with its own precedent to follow and its own way of going
wrong silently; and the **per-candidate shape** is what makes findings comparable to each other. A report
whose candidates each argue in their own format cannot be ranked, and ranking is what TASK-078 hands to
`intake`.

### What each candidate carries, per STORY-007

Files · problem · solution · **benefits stated in terms of leverage and locality** · a before/after visual ·
a recommendation strength.

The benefits framing is the non-obvious one and should not be softened to "why it's good": **leverage** is how
much else gets easier, **locality** is how much stays put. Those are the two things a reader trades against
the cost of the refactor, and a benefit stated in any other terms cannot be compared with the next
candidate's.

**Recommendation strength is not priority.** Strength is confidence that the candidate is real; priority is
blast radius, and [[fix-next]] computes that from its own keys when the task exists. Conflating them here
would pre-empt a ranking that belongs downstream.

## Acceptance criteria

- [ ] The report publishes as an Artifact, and **degrades to a temp HTML file** when no Artifact surface exists — never to "no report"
- [ ] The degradation is written as the `close`-step-5b pattern (delivery degrades, the pass does not), and says so, so the next reader recognises it as the house pattern rather than a local invention
- [ ] Every candidate carries all six parts, and the shape is stated once for all candidates rather than described per candidate
- [ ] **Benefits are in leverage and locality terms**, with both defined inline — a benefit phrased another way is not comparable and the criterion is that comparability, not the wording
- [ ] The before/after visual is specified concretely enough to produce without a design decision per candidate
- [ ] Recommendation **strength** is defined as confidence-that-it-is-real, and explicitly **not** priority — with the reason that ranking belongs to `intake`/[[fix-next]] downstream
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The scan and the finding classes — **TASK-076**, which this depends on.
- The `intake` handoff — **TASK-078**. This task produces the report; that one turns it into tracked work.
- Prescribing a diagram *tool*. The visual's content is specified here; how it is drawn is the runtime's business.

## Human test plan

- [ ] Produce a report with at least two candidates and confirm their benefits are stated so the two can be **compared** — that is the whole point of fixing the shape
- [ ] Force the fallback path (no Artifact surface) and confirm a readable report still lands as a temp HTML file, with the analysis intact
- [ ] Check that no candidate's *strength* reads as a priority, and that nothing in the report pre-ranks the work

## Implementation plan

_Populated by `/tasks plan TASK-077` — leave empty until then._
