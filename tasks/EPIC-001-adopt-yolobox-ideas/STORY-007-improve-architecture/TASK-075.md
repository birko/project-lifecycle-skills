---
id: TASK-075
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: done
priority: P2
assignee: agent
created: 2026-08-26
depends-on: []
blocks: [TASK-076]
# findings: ids this task remediates, from a review/audit/spec-harvest pass (CR-* SEC-* SH-* VC-*)
findings: []
pr: null
github-issue: null
jira-key: null
---

# Backfill the four ideas `improve-architecture` will need into `tdd`'s existing files

## Context

STORY-007 is explicit that the new skill **"reuses `tdd/deep-modules.md` and `interface-design.md` rather
than duplicating them, and backfills the four things they are missing."** This task is that backfill, and it
comes **first** for a reason that is a standing rule here rather than a preference: *a vocabulary shared by
several skills has one owning file, and the owner is wherever it already lives* — expand the existing owner,
never start a neutral one. So the concepts land in `tdd/`, and `improve-architecture` points at them.

**Verified absent, 2026-08-26.** Case-insensitive greps across all of `skills/tdd/` for *deletion test*,
*adapter*, *test surface* and *in parallel* return **nothing**. All four are genuinely missing, so this is
not a tidying pass.

### The four

| # | Idea | Why it is load-bearing for the new skill |
|---|---|---|
| 1 | **The deletion test** — would deleting this abstraction *concentrate* complexity, or merely *move* it? Only "concentrates" is a finding | STORY-007 makes this the filter on every shallow-module candidate. Without it the skill reports every small module as a problem, which is noise |
| 2 | **One adapter means a hypothetical seam; two means a real one** | The discipline that stops "what if we swap the database" from justifying an interface nobody needs. It is the cheapest test for a speculative abstraction |
| 3 | **The interface is the test surface** | Reframes untestability as an *interface* defect rather than a testing one. STORY-007 lists "what is untestable through its current interface" as a finding class, and this is the sentence that makes it actionable |
| 4 | **Design the interface twice, in parallel, before choosing** | The one that is a *practice* rather than a test. Cheap at design time, near-impossible to retrofit — which is exactly why it belongs in the file a designer reads, not in a review skill |

## Acceptance criteria

- [x] All four land in `skills/tdd/deep-modules.md` or `skills/tdd/interface-design.md` — whichever already owns the surrounding idea, decided per concept rather than dumped in one file
- [x] Each states its **observable signal** (what you see that makes it apply) and not only the principle — matching how `refactoring.md`'s smell inventory is written, since that is the shape a review skill can read
- [x] The deletion test is written so a **"merely moves it"** answer is a legitimate, recordable outcome — a test whose only output is "finding" is not a test
- [x] Nothing is duplicated from the other `tdd/` files, and nothing that already exists there is restated
- [x] No forward reference to `improve-architecture` that would fail the lint — the skill does not exist yet ([[tasks]]'s wikilink contract is enforced inside `skills/`; see TASK-074 for why a forward reference cannot be written)
- [x] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `improve-architecture` skill itself — **TASK-076**, which depends on this.
- Reorganising `tdd/`'s existing files. Additive only; a restructure would break every current reader for no gain.
- The smell inventory in `refactoring.md`. It is already shared with [[verify-conventions]] and is not what these four extend.
- Deferred to TASK-261 — the `help.md` verb files that the deletion test showed concentrate (found during this task's test plan).

## Human test plan

- [x] Read each of the four cold and confirm its **signal** is concrete enough to apply to a real file without the author present — a principle with no signal is a slogan
- [x] Take one small module in this repo's own `skills/` tree and run the deletion test on it out loud; confirm the test can return *"merely moves it"* and that doing so feels like a result rather than a failure

## Implementation plan

Drafted 2026-10-06 by the `Plan` agent; references checked against the files before writing. No grill.

**Placement, decided per concept.** Everything is added after the existing content, so nothing is renumbered or moved. `SKILL.md` is not edited, because lines 85–86 already point at both files.

| # | Concept | File | Where |
|---|---|---|---|
| 1 | The deletion test | `deep-modules.md` | new `## The deletion test` at the end. This file defines *shallow module*, which is what the test filters |
| 2 | One adapter / two adapters | `interface-design.md` | new item 4. Item 1 ("accept dependencies") creates the seam this item judges |
| 3 | The interface is the test surface | `interface-design.md` | new item 5. Its fix is a change to the interface, not to the test |
| 4 | Design it twice, in parallel | `interface-design.md` | new `## Design it twice` after the list. It is a practice, not a property of an interface |

**Shape of each:** a signal, then the principle, then the outcome. Overlaps are linked, never restated:
- Concept 1 links `refactoring.md`'s *Shallow module* and *Middle man* rows.
- Concept 2 separates itself from *Speculative generality* explicitly: it counts implementations, while that row counts callers. A test double at a system boundary counts as a second adapter, and a mock of an internal collaborator does not, per `mocking.md`.
- Concept 3 links `tests.md`'s red flags.
- Concept 4 links `deep-modules.md`'s design questions.

**The deletion test's direction, as written:** inline the module into its callers.
- **Concentrates:** the logic collapses or disappears. Callers were working around the module, so this is a finding.
- **Merely moves:** the same logic reappears at every caller, so the module earns its place. This is recorded as a result, with the callers checked, so the next pass does not raise it again.

This is the reading TASK-076 builds on. STORY-007's one sentence ("only 'concentrates' is a finding") does not settle it alone.

**Checks:** each of the four grep terms ("deletion test", "adapter", "test surface", "in parallel") appears literally. There are no `[[…]]` links: in particular, no forward reference to the not-yet-existing skill. Every relative link is an existing sibling file. Then run `bash .github/workflows/skills-lint.sh`.

## Progress log

- 2026-10-06 — Picked; plan drafted by the `Plan` agent and checked against the files. The four ideas were written per the plan: the deletion test in `deep-modules.md`, and items 4–5 plus `## Design it twice` in `interface-design.md`. Lint passes.
- 2026-10-06 — **Human test plan, step 2:** the deletion test was run out loud on two modules from this repo's `skills/`. `skills/tasks/slicing.md` (5 callers) **merely moves**: inlined, the doctrine would reappear in `decompose`, the router, `new`, `plan` and `spawn`, so the module earns its place, and the outcome reads as a result. `skills/tasks/verbs/help.md` (1 caller) **concentrates**: the router already says "print the verb table and exit", so that is a small real finding, filed as TASK-261 (the `specs` and `feature` help verbs follow the same pattern).
- 2026-10-06 — **Human test plan, step 1: two cold readers.**
  - **How the readers were obtained:** `claude -p --disable-slash-commands < brief`, run in `C:/Source/WebChecker` and then in `C:/Source/EventSourcing`, both repos with no agent guide. **Coldness:** each was asked first to list its skills, and both answered "none". The brief held the four rule texts and the passages they link to, and asked the reader to apply each rule to the repo's code and rate whether its signal was concrete enough. It gave no expected answer.
  - **Reader 1** found harness and prose problems:
    - its appendix lacked `tests.md`'s red-flag list (my extraction stopped at a blank line; a harness fault);
    - "module" was unscoped, so a data-only class fit neither outcome row, and the *Concentrates* row asserted a cause that does not always hold;
    - "injected dependency" was undefined for events.

    The last two are fixed: data-shape types are out of the test's scope, the row is reworded to "the logic it held collapses or disappears, and no caller grows", and events are named.
  - **Reader 2** (revised text, corrected appendix) applied the deletion test unaided and got **both outcomes**: `IdFilter` concentrates and `ListFilter` merely moves. It rated it "mostly yes". Its one guess, single-caller blur, is held: one reader only.
  - **Both readers agreed on two points, both fixed:**
    - the test-surface signal assumed a test exists, and now covers "cannot observe it through the interface at all";
    - design-it-twice was invisible to a reviewer, and now names its form in finished code: an interface with few or no callers yet.
  - Reader 2's "callback" ambiguity, a notification versus a predicate passed in, is fixed too.
  - **For TASK-076:** design-it-twice is still mainly a designer's practice. A review skill can see only its late form.
- 2026-10-06 — **Close gate (step 5b), each axis reported separately:**
  - **Standards** ([[verify-conventions]]): pass, no blockers. Two warnings, both addressed: the dashboard predated TASK-261 (regenerated at this close), and TASK-261's `N/A` test plan is now real steps.
  - **Fidelity** ([[verify-intent]]): pass. All six criteria are built, with no scope creep.
  - **Correctness** ([[code-review]] pass): 8 findings, all fixed before close.
    - The deletion test now judges the **total** logic, so partial reappearance is covered. "Merely moves" now points at deepening, the *Shallow module* row's other move. A one-caller module defers to the *Speculative generality* row. The result is recorded in the review's record, never in a code comment.
    - Item 4 says to keep injecting the dependency, typed as the concrete class.
    - Item 5 excludes side effects at a system boundary, per `mocking.md`.
    - *Design it twice* no longer contradicts itself about callers, has a fallback for a single agent, and names its comparison questions.
  - **Security:** not applicable, because the diff is prose with no security surface.
  - **Comments:** not applicable, because there are no code comments in range.
  - **Out of scope (5d):** 4 boundaries, 0 spawned, 0 declined (TASK-261 was spawned earlier, during the test plan).
