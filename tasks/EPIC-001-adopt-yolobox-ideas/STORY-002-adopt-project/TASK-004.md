---
id: TASK-004
parent: STORY-002
feature: null
status: done
priority: P1
assignee: unassigned
created: 2026-08-18
depends-on: [TASK-003]
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# adopt-project: infer conventions from the code, then grill

## Context

This is what makes `adopt-project` more than skip-if-exists. `new-project` *asks* for conventions
up front because there is no code to read. An existing repo has already answered most of those
questions in its source — the job is to read the answers out, propose them, and have the user
confirm or correct.

Reading rules **out** of a codebase is a different discipline from collecting them, and it is
most of this skill's value: an adopted repo whose `§ Conventions` block is empty gets nothing
from [[verify-conventions]], which is the single biggest payoff of adopting at all.

## Acceptance criteria

- [x] Surveys the codebase for recurring patterns and proposes them as `§ Conventions` entries, each shown **with the evidence that suggested it** (file count + representative paths) so the user can judge rather than rubber-stamp
- [x] Covers the seed's subsections: framework/stack (from manifests + imports), code structure & patterns, naming, testing (from the test runner actually present), and UI/UX only when a human-facing surface exists
- [x] **Proposes, never asserts.** Every inferred rule is confirmed by the user before it is written; an unconfirmed inference is dropped, not written as a guess
- [x] Distinguishes *convention* from *accident*: a pattern in 3 of 30 files is offered as a question, not a rule
- [x] Surfaces candidate glossary terms — recurring domain nouns, and pairs that look like synonyms for one concept — for [[domain]] once STORY-003 lands; until then it records them in the guide and says so
- [x] Uses the frontier-round grill shape from [[grill-me]], not one question at a time
- [x] A repo where nothing can be inferred degrades gracefully: say so and leave the subsections empty rather than inventing rules the project never agreed to

## Out of scope

- The survey/fill mechanics → TASK-003.
- Writing the glossary/ADR files themselves → STORY-003 owns `domain`; this task only feeds it candidates.

## Human test plan

- [x] Drilled on **BardStudio** (70 files): four rules proposed with evidence, all four judged and recorded — run from the repo copy, pre-junction
- [x] **Closed on Presenter's evidence instead, deliberately — the named targets are no longer valid subjects.** With TASK-017's skip rule in place, a repo whose rulebook already answers all five subsections correctly gets *no* inference round, and as of 2026-08-18 that is every repo in the fleet: WorkoutTracker (~24 flat rules), Symbio (twelve `KRITICKE` sections, naming included via the permissions convention), BardStudio, Latent, Presenter and flappy-dragon — several of them filled by our own adoption passes. Drilling either named repo now would prove the skip, not the inference. **What this line was actually for — an owner catching a plausible-but-wrong proposal — happened on Presenter:** the commit-subject rule was proposed off a 53/67 majority and the owner overrode it (chose lowercase conventional, the minority shape, which is what got written); and the `Deck`/`Presentation` synonym claim was refused rather than accepted — *"check the code how is it used"* — which on inspection turned out to be two genuinely distinct concepts plus a third (`PresentationEntity`), and was recorded as a distinction. Both are the failure mode this line names, caught by the owner, in a real repo. The next genuinely unadopted repo is the better subject for a fresh run, and it does not exist yet
- [x] The WorkoutTracker attempt is now **moot rather than pending**: TASK-017 sanctioned the skip, so that repo correctly produces no round at all, and the re-drill under TASK-017 confirmed it (four subsections richly answered, naming thinly answered and therefore *offered* rather than run, zero proposals written)
- [x] Both halves confirmed on Presenter. **Evidence**: every proposal carried a count and representative paths (`[142/148]`, `[5/5 pages]`, `[4/4]`, plus `file:line` for the resolution-order rule). **Declining leaves it unwritten**: the 53/67 `Area: subject` majority was declined in favour of the minority shape and the majority rule was never written; the synonym claim was declined outright and replaced by what the code actually showed. Additionally, three fill items the owner did not select (`.gitignore`, `.editorconfig`, `.gitattributes`) were left alone and reported rather than quietly applied
- [x] Mixed-codebase behaviour confirmed on **Presenter** (2026-08-18): commit subjects split 53/67 `Area: subject` against three recent lowercase-conventional commits, and the run **asked** rather than proposing the majority shape as a rule — the 20–80% band behaving as `INFER.md` specifies. The `Deck` / `Presentation` synonym pair was likewise not asserted either way: it went back to the code, came out as two genuinely distinct concepts (transient render model vs persisted pointer, with `PresentationEntity` a third), and was recorded as a distinction rather than a merge

## Implementation plan

1. Written as `INFER.md` rather than inline: the router stays small per the prose rules, and the
   inference discipline is long enough to be its own reference.
2. Prevalence thresholds chosen over raw counts — 80%+ of *applicable* files proposes a rule,
   20-80% asks a question, below that stays silent. A split codebase is a finding worth surfacing,
   not a failure to classify.
3. Glossary candidates collected but not written: `domain` does not exist yet, and the reference
   is deliberately plain text because a wikilink to an absent skill degrades silently at runtime.
   STORY-003 promotes it.
