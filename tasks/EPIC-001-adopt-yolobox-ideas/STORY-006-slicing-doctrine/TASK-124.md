---
id: TASK-124
parent: STORY-006
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: review
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

- [x] The fourth form is documented beside the existing three, with the question it answers stated in
      the same terms — so a reader picking a form can tell them apart
- [x] **Both** free-play controls and tabbed guided walkthroughs are required, with the reason each
      exists, so neither is dropped as optional polish
- [x] The single-file, no-toolchain constraint is stated as a constraint, with why
- [x] Guidance exists on choosing the walkthrough cases — the ones hard to reason about on paper, not a
      demo of the happy path
- [x] **Throwaway discipline** is stated for all four forms, including what "deleted" means for one that
      was shared with a stakeholder
- [x] The form says what its *output* is — a reaction, recorded where decisions go — not the file
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- **Inlining a prototype-derived snippet into a decision** — TASK-125.
- **The slicing doctrine** — TASK-122 (TASK-123 merged into it), the story's other half.
- Building a prototype for any real feature. This task documents the form.

## Human test plan

- [ ] Build one for a real state model — [[tasks]]'s own status vocabulary would do — and give it to
      someone who does not read this codebase. Expected: they drive it unaided and produce at least one
      reaction about the state model, not about the visuals. Withhold that expectation from them.
  - **Ready, not yet run (2026-09-29).** Built by following the new `prototype.md` text literally: a single self-contained page, published privately at https://claude.ai/artifact/GHk9TKVgAHws8snCjj2KaY (source: this session's scratchpad `prototype-states.html`; the scratchpad is not kept). It has free play over a three-task story, with unavailable moves shown disabled and their reason, plus five walkthrough tabs: finished-but-not-merged, built-not-checked, reopening shipped work, cancelling done work, the last task closing. Each ends with a question. **To run:** share it from the page's Share menu with someone who does not read this codebase, give them only the link, and record what they say. Then follow the form's own throwaway rule: unpublish the page once the reaction is recorded.

## Implementation plan

Planned inline at pick (2026-09-29). One verb (`feature/verbs/prototype.md`) plus the readers that break when a prototype is deleted.

1. Add the fourth form's row to step 2's table, and give every form a "question it answers" column, so a reader can tell the forms apart.
2. Build instructions for the form: the single-file constraint and why; free play and walkthroughs, both required, with the job of each; a table of hard cases for choosing walkthroughs.
3. Step 4: the output of every form is the reaction, recorded as a History line.
4. A § *Throwaway discipline* covering all four forms: when to delete, what remains, a shared copy that cannot be recalled, and re-prototyping.
5. Readers that must not break on deletion: `pick` gate C reads the `## Prototype` line, not the folder; `status` renders a deleted prototype from the line; the `idea.md` template and the router layout learn the new form and the `Built, then deleted` value. [[roadmap]] reads `Built / Skipped / N/A / Pending`, and `Built, then deleted` still leads with `Built`, so it needs no change.

## Progress log

- 2026-09-29 — Picked; planned inline (one verb plus its readers).
- 2026-09-29 — `prototype.md`: the fourth form "State-model playground" (`prototype-states.html`); a question-it-answers column for all four forms; build instructions (single file with nothing installed, free play plus walkthroughs, a walkthrough-case table); step 4's output rule; § *Throwaway discipline*. `pick.md` gate C now reads the recorded line. `status.md` renders a deleted prototype from the line. `idea.md` template and `feature/SKILL.md` layout updated. Lint OK.
- 2026-09-29 — Close review. **Standards:** pass. Tables for branching, the rationale inline, the verb standalone. The deletion rule was checked against every reader of prototype state (`pick` gate C, `status`, [[roadmap]]); the two that would have broken are fixed in the same change. **Intent:** pass, all 7 criteria met. "Deleted" for a shared copy is answered: it cannot be recalled, so it is declared dead and unpublished where possible. **Correctness:** pass. `Built, then deleted` keeps [[roadmap]]'s `Built` prefix; a deleted spike uses `git branch -d`, consistent with the never-force rule. **Security:** not applicable. **Comments:** not applicable.
- 2026-09-29 — Closed to `review`. The human test needs a real person who does not read this codebase; the prototype is built and published, and the run is pending.
- 2026-09-29 — TASK-125's drill caught a modelling error in the test playground: `review` could not be blocked, but `/tasks block` refuses only `done`/`cancelled`. Fixed and republished as version 2 at the same URL, before any human run.
- 2026-09-30 — Playground translated into Slovak (version 3, same URL) at the user's request, for a Slovak-speaking test subject. The model is unchanged from version 2.
- 2026-09-30 — First reaction, from the user opening version 3: *"nerozumiem trochu tomu ihrisku, že čo sa vlastne očakáva"* ("I don't quite understand what is expected of me"). It is about the form, not the state model, so it does not satisfy the human test. It is recorded as a defect in the form: `prototype.md` step 4 now requires every stakeholder-driven form to open with what it models, what to do, and what answer is wanted. The playground gained that box (version 4, same URL, now shared with the organization).
- 2026-09-30 — Second reaction, from the user, on the state model itself: *"dal by sa tento workflow nejak zredukovať podľa štandardov … projekt management má určite na to už nejaké postupy"* (could it be reduced to follow project-management standards). Compared with Jira, Linear, GitHub Projects and Kanban, the two deviations are `blocked` as a state (elsewhere a flag) and `review` meaning manual verification (elsewhere code review). At the user's request the playground now shows both models side by side (version 5): today's 6 states, and a proposed 5 states plus a `blocked` flag with `review` renamed "Čaká na overenie". It has a sixth walkthrough, block then unblock, and a model-specific question on each walkthrough. All 12 walkthrough runs were checked by simulation. The user is the author, so this is a weaker test than the plan asks for; a reader who does not know the codebase is still pending. If the proposed model is wanted, it is a requirement change: a `docs/BRIEF.md` amendment and `/feature new`.
