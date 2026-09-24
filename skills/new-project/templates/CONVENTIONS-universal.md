<!-- comment-rule:start -->
### Comments

Write the comment the code cannot carry, and nothing else. Judge each line by **what it carries, not how many there are**: a long block where every line earns its place is correct, and a comment restating the line below it is not.

**The test — delete the line, then ask where its content already lives:**

| It already lives… | Then |
|---|---|
| in the code itself — the name, the type, the signature, the line below | delete it; if the comment was compensating for a bad name, fix the name |
| in version history — the commit message, `git blame` | delete it; that is what the history is for |
| in the ticket — `tasks/` | delete it; if the work is not filed yet, file it (`/tasks spawn`) and then delete it |
| in a decision record — `docs/adr/`, the feature's `decisions.md` | delete it, or leave one line pointing at the record |
| in the project's own guide — `CLAUDE.md` § Conventions, or wherever this project records its standing rules | delete it, or leave one line pointing at the section |
| **nowhere** | **keep it, at whatever length it takes** |

Only *nowhere* survives, and it survives at **any** length. *Nowhere* means the content has no home but this comment — not merely that nobody has written it down yet. Content belonging in one of the first five rows goes there first, then the comment goes. Never delete the only copy of something: relocate it, then leave the pointer.

**A pointer is not a copy.** One line naming where the rest lives is what makes the destination reachable, and it always survives — a test comment naming the finding it pins and the mechanism it proves, a line citing the record that explains a choice. What fails the test is reproducing the content here.

**A doc comment is a published output, and its content is still checked.** A docstring, XML doc or JSDoc block is not commentary, so it survives even where it restates the signature — the published documentation needs it and a build may require it. It carries nothing else this section bans: judge each of its lines by what it adds beyond the signature. A line that adds nothing goes — unless the tag is structurally required, and then **fill it rather than delete it**. An empty `@param tolerance the tolerance` is the violation; the fix is saying what the caller cannot read off the type.

**These four are always violations, and none of them is about length:**

- **A changelog** — "2025-03-04 added X; 2025-05-11 renamed Y". Version history already has it.
- **A QA log** — "tested 3.4.2025, works". That belongs in the ticket, or in a test that asserts it.
- **A rationale essay above a declaration** — the paragraph arguing why this approach beat the alternatives. That is a decision record.
- **Ten lines of prose above one property, const, enum member or field.** The length is the symptom; the violation is that nine of them restate the name. The same ten lines above an algorithm whose correctness is not visible from the code are correct.

**Never report a comment for being long.** A thirty-line block explaining a non-obvious algorithm, a protocol quirk, or why the obvious implementation is wrong is compliant — every line carries something the code cannot. Comments that pass this test usually come out short, because most content has somewhere better to live; that is an outcome of the test, never a limit on it. Length is a reason to look, never a finding by itself.
<!-- comment-rule:end -->

### Keeping conventions current (register-on-introduce)
- When a change **introduces a new cross-cutting pattern** — a new framework/major dependency, a UI pattern, a new architectural layer or module shape, a new naming or testing convention — **record it in this section in the same change**. Updating the rulebook is part of "done", exactly like updating the decision ledger. A pattern that lives only in one file is not a convention; it's drift waiting to be copied wrong.
- If the change alters structure, update **## Architecture** too — a stale architecture doc is a defect, not stale-but-harmless.
- `/verify-conventions` flags a change that introduced a new pattern without recording it here.

### Working rules
- **Task-first gate (hard rule):** for non-trivial work, the task exists (`status: todo`, with acceptance criteria) **before any code is written — tests included** — and work starts by picking it (`/tasks pick`, which flips it to `in-progress` and cuts the task branch); then tick boxes as they're met. Code before task is a lifecycle violation, not a style choice. If you catch code already written without a task, **stop implementing**: backfill the task with honest status (`in-progress`, acceptance criteria reconstructed from the decision/request — never written after the fact and dropped straight into `review`), then continue. Small conversational fixes can track at the parent EPIC level.
- **Plan before implementing.** A non-trivial task gets its `## Implementation plan` drafted *before* work starts — `/tasks new` auto-plans, and `/tasks pick` offers `/tasks plan` (default yes) for any task that reached work without one. Improvising an unplanned task is how scope quietly grows past the acceptance criteria. Genuine one-liners may skip it deliberately.
- **New scope discovered mid-work gets its own task — never an extra criterion on the one in hand.** When something surfaces outside the current task's acceptance criteria (a refactor the change exposed, a bug found in passing, a plan step that's really its own unit), **offer `/tasks spawn` unprompted** — don't widen the task, don't silently do the extra work, don't drop it. Spawn files the new task under the same parent, inherits its `feature:`, rewrites the displaced plan step to `→ deferred to TASK-NNN`, and reconciles the feature ledger (adding a `proposed` decision row when nothing covers the discovery, so it comes back through `/feature decide`). Widening an in-flight task destroys its acceptance list as an independent target — the task-first gate's failure arriving from the other direction.
- Before flipping a **non-trivial** task to `done`, run the review passes `/tasks close` step 5b lists — adherence to the rules above, fidelity to the task, and correctness always, plus the conditional ones when the diff reaches them — then address the findings or note in the task why any are deferred — tests passing ≠ reviewed-and-conventional. Skip for trivial mechanical changes (docs, renames, one-liners). **This `/tasks close` step *is* the merge gate** — for git/PR projects the default is one branch + PR per task (plus `/review` on the PR diff), and `done` means *merged*, not just locally reviewed — if the merge is deferred (stacked PR, external reviewer, batch-merge policy), the task ends at `blocked` with the reason recorded and re-closes after `/tasks unblock`, never at `done`. Code is reviewed once, here, per task; `/feature review` then only confirms completeness, it doesn't re-run these wholesale.
  - **Security surface → one more pass.** If the diff touches auth/session, data access, user input, file/path handling, crypto, secrets/config, a new dependency, or a newly exposed endpoint, also run `/security-review` before `done`. Conditional, not routine — most diffs have none and say so in a line — but a task that touches one doesn't merge on a correctness pass alone. (`/feature review`'s security pass is optional and feature-wide; it is not a backstop for this.)
  - **These checks are agent-run, not CI-enforced.** The CI workflow gates build + tests; it does **not** run `/verify-conventions` or `/code-review` (they're agent skills). So the convention/review gate is a *convention the agent follows*, not a hard guarantee. To make it enforced, wire a git pre-commit hook (via the `update-config` skill) that blocks on convention/review findings — recommended once the rulebook above stabilizes.
- **Generated files are owned by their verbs — never hand-edit them.** `docs/features/*/status.md` and `docs/features/README.md` → `/feature status`; `tasks/README.md` (dashboard) → `/tasks triage`; `docs/specs/*.md` → `/specs regen` (only `.map.yml` is hand-edited). "Keep it current" means *run the owning verb*, not edit the file — a hand edit is silently overwritten on the next regeneration, so it's a lie with a countdown. If you catch a hand edit (yours or anyone's), re-run the owning verb so the generator's output wins. Keeping `docs/features/*/status.md` current matters — it's how non-devs see progress — and `/feature status FEATURE-NNN` is the only way to do it.
- **Status changes go through their verbs, never hand-edits.** `/tasks pick/close/block/cancel` and `/feature decide/review` are what set `status:` frontmatter — each carries gates and side effects (human-test check, convention/correctness review, dashboard + rollup regen, remote issue sync) that a direct edit silently skips. Hand-flipping `status: done` in a task file is the same violation as hand-editing a generated file: the state changes, but the process that makes that state trustworthy never ran.
- To see where things stand, use `/tasks` (the status snapshot is feature-aware — it cross-checks `docs/features/` and flags any drift) or `/roadmap` for the full epic→feature→task view plus a divergence audit. Both span the two trees, so "what's next / what's planned" never misses a feature.
- No `Co-Authored-By:` trailers in commit messages.
