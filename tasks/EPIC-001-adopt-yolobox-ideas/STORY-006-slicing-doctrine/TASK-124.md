---
id: TASK-124
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
priority: P2
assignee: agent
created: 2026-09-09
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# `/feature prototype` gains a fourth form — "does this state model feel right?"

## Context

`/feature prototype` has three forms — HTML mockup, markdown wireframe, code spike — and the story's
observation is that **all three answer the same question**: *what should this look like.* None answers
*does this state model feel right*, which is the question you cannot settle on paper and cannot settle
by looking at a picture.

The fourth form, from the story: **a single shareable HTML file** with **free-play controls** *plus*
**tabbed guided walkthroughs** that push the state machine through the cases that are hard to reason
about on paper — and **drivable by a non-developer**, which is the whole point. A stakeholder who cannot
run the code can still answer "no, it should not let me do that from here".

### Throwaway discipline, stated plainly

Ships in the same change because it governs all four forms and is currently implicit: **a prototype
answers its question and is then deleted.** Do not architect it, do not polish it, do not wire it into
the repo. A prototype that survives becomes a second implementation nobody maintains.

### Two things this must get right

- **Free play and guided walkthroughs are both required, and they do different jobs.** Free play finds
  the case the author did not think of; the walkthroughs cover the cases the author knows are hard.
  Ship one without the other and the form answers half its question.
- **The artifact has to reach the person who decides.** *"Single shareable HTML file"* is a constraint,
  not a suggestion — a prototype needing a dev environment cannot be driven by the stakeholder whose
  reaction is the entire output.

## Acceptance criteria

- [ ] The fourth form is documented beside the existing three, with the question it answers stated in
      the same terms — so a reader picking a form can tell them apart
- [ ] **Both** free-play controls and tabbed guided walkthroughs are required, with the reason each
      exists, so neither is dropped as optional polish
- [ ] The single-file, no-toolchain constraint is stated as a constraint, with why
- [ ] Guidance exists on choosing the walkthrough cases — the ones hard to reason about on paper, not a
      demo of the happy path
- [ ] **Throwaway discipline** is stated for all four forms, including what "deleted" means for one that
      was shared with a stakeholder
- [ ] The form says what its *output* is — a reaction, recorded where decisions go — not the file
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Inlining a prototype-derived snippet into a decision** — TASK-125.
- **The slicing doctrine** — TASK-122 and TASK-123, the story's other half.
- Building a prototype for any real feature. This task documents the form.

## Human test plan

- [ ] Build one for a real state model — [[tasks]]'s own status vocabulary would do — and give it to
      someone who does not read this codebase. Expected: they drive it unaided and produce at least one
      reaction about the state model, not about the visuals. Withhold that expectation from them.
