---
id: TASK-021
parent: STORY-002
feature: null
# status: todo | in-progress | review (code done, sign-off pending) | blocked | done | cancelled
status: todo
priority: P1
assignee: agent
created: 2026-08-18
depends-on: []
blocks: []
findings: []
pr: null
github-issue: null
jira-key: null
---

# The survey reads a repo's shape and history where the layer records a declared value

## Context

Found in the `adopt-project` drill on `C:\Source\Birko\Consumers\Presenter` (2026-08-18). One root
cause, two visible failures.

**The artifact was judged from the outside.** `tasks/` was surveyed `present` — evidence *"(mode:
local), README.md, 7 epics / 1 story / 9 tasks"* — and the fill skipped it as *"already
skill-shaped, no `/tasks init` needed"*. But its `.config.yml` is still the shape `/tasks import`
wrote on 2026-05-28 and carries **no `integration:` field** at all. That field is exactly what the
layer grew since, and reconciling a repo that adopted an older version is this skill's advertised
second entry case. LAYER.md's *"present but thin is `present`, with the gap named"* rule was written
for a missing `##` section; nobody extended it to **schema growth inside an artifact another skill
owns**. And the delegated inits are all delta-based and safe to re-run — which is why the row says
*delegate*, not *delegate unless it looks fine*. A shape check is not a version check.

**Then the missing field got inferred from git history.** With nothing declaring the integration
model, the run read the log, found a `Merge branch 'build/birko-src-bucket-layout'`, and concluded
the repo uses topic branches — so it cut `chore/adopt-project-lifecycle`, merged `--no-ff`, and
afterwards deleted the branch because *"merged branches evidently don't stick around here"*. It
happened to land right. It is also the one inference [[tasks]] explicitly forbids: *"Declare the
integration model, don't infer it. Reading it beats reading `git log`, which cannot tell a
commit-to-main repo from a squash-merge one."* A squash-merge repo and a commit-to-main repo produce
the same log, and the branch deletion was a second inference layered on the first — neither was in
"merge it into main".

Both failures are the same mistake at different altitudes: **derive from observation what the layer
stores as a declaration.** The whole point of that field is that no agent has to guess, and the
reason it was missing is that the survey never looked inside the artifact carrying it.

## Acceptance criteria

- [ ] LAYER.md's `tasks/` row — and every other row naming an **Owner** — states that a present artifact is still **delegated to its owner's init**. Those inits are delta-based, and only the owner knows what its own current shape is; "looks skill-shaped" is not a version check
- [ ] The states in LAYER.md cover **an artifact present in an older version of its own shape** — a missing field, not a missing file. Whether that is a qualifier on `present` or its own state is the implementer's call; what must not survive is a `present` row that hides a field the layer has since added
- [ ] `adopt-project` never derives git policy from history. Branch / commit / merge behaviour comes from `tasks/.config.yml`'s `integration:`, and when the field is absent adoption **backfills it by asking** — that absence is the same missing declaration this skill exists to reconcile
- [ ] **Branch deletion is never inferred.** Cleaning up a merged branch is its own ask, whatever the log looks like
- [ ] `/tasks init`'s delta behaviour is checked against this: re-running it on a pre-field `.config.yml` must add `integration:` without disturbing the tree. If it does not, that is a [[tasks]] defect and gets its own task rather than a workaround here
- [ ] One sentence covering the smaller version of the same error from the same run: a **count** in survey evidence states its provenance or is not given. "148 test methods" came from grepping `[Fact]`/`[Theory]`; `dotnet test` discovers 143. Evidence read off a grep must not read as evidence read off a run
- [ ] `skills-lint` and `skills-lint-test` stay green

## Out of scope

- Presenter's own `.config.yml` — a one-line backfill in that repo, not this task's deliverable.
- Re-litigating the `pr-per-task` vs `single-branch` default; [[tasks]] owns that.
- Whether adoption should commit at all — settled: it offers, never commits unasked.

## Human test plan

- [ ] Re-drill **Presenter**: `tasks/` reports the missing `integration:` field, adoption asks for it and backfills, and no branch is cut before that answer exists
- [ ] Drill a repo whose `.config.yml` already declares `single-branch` and confirm no branch is cut and no merge offered, whatever its log shows
- [ ] Manufacture the ambiguity the inference cannot survive — a fixture with a linear squash-merge-style history and `single-branch` declared — and confirm the declared value wins
- [ ] Confirm no branch is deleted without an explicit ask

## Implementation plan

_Populated by `/tasks plan TASK-021` — leave empty until then._
