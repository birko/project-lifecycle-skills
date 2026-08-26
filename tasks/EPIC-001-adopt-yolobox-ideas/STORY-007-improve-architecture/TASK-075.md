---
id: TASK-075
parent: STORY-007
feature: null
# status — one of: todo, in-progress, review (code done, sign-off pending), blocked, done, cancelled
status: todo
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

- [ ] All four land in `skills/tdd/deep-modules.md` or `skills/tdd/interface-design.md` — whichever already owns the surrounding idea, decided per concept rather than dumped in one file
- [ ] Each states its **observable signal** (what you see that makes it apply) and not only the principle — matching how `refactoring.md`'s smell inventory is written, since that is the shape a review skill can read
- [ ] The deletion test is written so a **"merely moves it"** answer is a legitimate, recordable outcome — a test whose only output is "finding" is not a test
- [ ] Nothing is duplicated from the other `tdd/` files, and nothing that already exists there is restated
- [ ] No forward reference to `improve-architecture` that would fail the lint — the skill does not exist yet ([[tasks]]'s wikilink contract is enforced inside `skills/`; see TASK-074 for why a forward reference cannot be written)
- [ ] `bash .github/workflows/skills-lint.sh` passes

## Out of scope

- The `improve-architecture` skill itself — **TASK-076**, which depends on this.
- Reorganising `tdd/`'s existing files. Additive only; a restructure would break every current reader for no gain.
- The smell inventory in `refactoring.md`. It is already shared with [[verify-conventions]] and is not what these four extend.

## Human test plan

- [ ] Read each of the four cold and confirm its **signal** is concrete enough to apply to a real file without the author present — a principle with no signal is a slogan
- [ ] Take one small module in this repo's own `skills/` tree and run the deletion test on it out loud; confirm the test can return *"merely moves it"* and that doing so feels like a result rather than a failure

## Implementation plan

_Populated by `/tasks plan TASK-075` — leave empty until then._
